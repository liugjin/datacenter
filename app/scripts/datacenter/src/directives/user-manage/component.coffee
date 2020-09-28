###
* File: user-manage-directive
* User: David
* Date: 2020/05/11
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "tripledes"], (base, css, view, _, moment, des) ->
  class UserManageDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "user-manage"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @userService = @commonService.modelEngine.modelManager.getService('user')
      @rolesService = @commonService.modelEngine.modelManager.getService('roles')
      @changePasswordService = @commonService.modelEngine.modelManager.getService("changePassword")
      @token = scope.controller.$rootScope.user.token
      @project = scope.project.model.project
      @host = @$window.origin
      @msgCommand = {} # 短信控制命令
      @userUrl = "#{@host}/model/clc/api/v1/users"
      @verificateCode = "" # 用来判断验证码是否正确
      @verificateCodeTimeout = null # 去除seTtimeout,防止内存谢鸥
      scope.selectRefresh = 0 # 用来刷新select框
      scope.roles = [] # 角色权限
      scope.rightTitle = "用户编辑" # 右边题头的题目
      scope.user = scope.controller.$rootScope.user.user
      scope.users = [] # 用户列表
      scope.selectUser = {} # 当前点击的用户
      scope.index = 0 # 用来控制点击编辑的时候,用户列表的高亮
      scope.addUserShow = false # 点击添加用户时候,控制dom显示
      @init(scope)
      
      # 修改密码
      scope.changePassword = () => (
        scope.selectUser.passwordVerificateCode == @verificateCode
        return @display '请输入旧密码' if(_.isEmpty(scope.selectUser.oldPassword))
        return @display '请输入新密码' if(_.isEmpty(scope.selectUser.password))
        return @display '请输入确认密码' if(_.isEmpty(scope.selectUser.confirmPassword))
        return @display "请输入验证码" if(_.isEmpty(scope.selectUser.passwordVerificateCode))
        return @display "输入的验证码有误" if(@verificateCode != scope.selectUser.passwordVerificateCode)
        if(scope.selectUser.password == scope.selectUser.confirmPassword)
          tmpPasswordObj = {
            user: scope.selectUser.user
            token: scope.selectUser.token
            oldPassword: @encrypt(scope.selectUser.oldPassword, scope.selectUser.user)
            password: @encrypt(scope.selectUser.password, scope.selectUser.user)
          }
          @commonService.modelEngine.modelManager.$http.post("#{@host}/auth/changepassword", tmpPasswordObj).then((res ,err)=>
            return @display(res.data._err) if res.data._err
            @display("用户#{scope.selectUser.name}修改密码成功")
            $("#user-manage-change-prompt-modal").modal("close")
            scope.selectUser.confirmPassword = ""
            scope.selectUser.oldPassword = ""
            scope.selectUser.password = ""
            scope.selectUser.passwordVerificateCode = ""
          )
        else
          @display '新密码与确认密码不一致'
      )
      # 点击删除用户执行的函数
      scope.deleteUser = (user,event) => (
        event.stopPropagation()  # 防止点击删除时触发编辑事件
        scope.prompt("是否删除该用户", "注：点击确定后无法撤销该操作", (cancel) =>
          return if not cancel
          return @display("无法删除超级管理员") if(user.user == "admin")
          @userService.remove({user: user.user, _id: user._id}, (err,data) => (
            if(err)
              console.log 'delete user err:',err
              @display("删除失败")
            else
              @display("已成功删除该用户")
              scope.users = _.filter(scope.users, (item)=> item._id != user._id)
          ))
        )
      )
      # 点击编辑用户执行的函数
      scope.editUser = (user, index) => (
        scope.index = index
        scope.selectUser = user
        scope.addUserShow = false
        scope.selectUser.verificateCode = ""
        @verificateCode = ""
      )
      # 点击新增用户执行的函数
      scope.addUser = () => (
        scope.addUserShow = true
        scope.selectUser = {}
      )
      # 保存用户信息
      scope.saveUser = () => (
        judge = @judgeInputFormat(scope)
        return @display "请输入验证码" if _.isEmpty(scope.selectUser.verificateCode)
        if(_.isEmpty(judge) && @verificateCode == scope.selectUser.verificateCode)
          userId = scope.selectUser.user
          @userService.update(scope.selectUser, (err,data)=>
            # 修改后用户当前所在的角色
            nowRole = _.find(scope.roles, (role) -> role.role == scope.selectUser.auth)
            scope.selectUser.authName = nowRole.name
            # 取消用户在其他角色里的权限
            _.each(scope.roles, (role)->
              role.users = _.filter(role.users, (item)-> item != userId)
            )
            rolesLength = scope.roles.length
            # 把修改后的用户填在到对应的角色里面
            nowRole.users.push(userId)
            _.each(scope.roles, (role, num)=>
              @rolesService.save(role, (err, data)=>
                return @display(err) if err
                if((num+1) == rolesLength)
                  @display("修改成功")
                  scope.selectUser.user = userId # 防抖
                  scope.selectRefresh++
                  @init(scope)
              )
            )
          )
        else if(_.isEmpty(judge) && @verificateCode != scope.selectUser.verificateCode)
          @display("输入的验证码有误")
      )
      # 获取验证码, 这里用了浅拷贝
      scope.getVerificationCode = () => (
        console.log("1234")
        msg = _.find(@msgCommand.model.parameters, (item) -> item.key== "msg") # 短信内容
        phone = _.find(@msgCommand.model.parameters, (item) -> item.key == "phone") # 手机信息
        phone.value = scope.selectUser.phone
        if(scope.user == "admin")
          phone.value = scope.controller.$rootScope.user.phone
        tailPhone = phone.value.slice(7,11) # 手机尾号
        romdomVerification = String(Math.random()).slice(2,6)
        msg.value = "【华远云联】验证码：#{romdomVerification}，五分钟内有效" # 随机四位数
        @verificateCode = romdomVerification
#        console.log '修改验证码：',romdomVerification
        @commonService.executeCommand(@msgCommand)
        @display("验证码已发送至尾号#{tailPhone}")
        if(@verificateCodeTimeout)
          clearTimeout(@verificateCodeTimeout)
        @verificateCodeTimeout = setTimeout(()=>
          @verificateCode = ""
        , 30000)

      )
      # 注册用户
      scope.registerUser = () => (
        judge = @judgeInputFormat(scope)
        if(_.isEmpty(judge))
          return @display "密码和确认密码均不能为空" if not scope.selectUser.password || not scope.selectUser.confirmPassword
          return @display "新密码与确认密码不一致" if scope.selectUser.password != scope.selectUser.confirmPassword
          postData = _.map([scope.selectUser], (user)=>
            return {
              email: user.email,
              name: user.name,
              password: @encrypt(user.password,user.user),
              phone: user.phone,
              user: user.user
            }
          )
          @commonService.modelEngine.modelManager.$http.post("#{@host}/auth/register", postData[0]).then((res)=>
            return @display(res.data._err) if(res.data._err)
            console.log("用户"+res.data.name+"注册成功")
            # 注册成功后 给此注册用户分配角色
            @roleAuth(scope,scope.selectUser.user,scope.selectUser.auth)
#            scope.users.push(_.extend postData[0],{auth:scope.selectUser.auth})
          )
      )
      # 判断输入的格式是否正确
    judgeInputFormat: (scope) => (
      return @display "用户名不能为空" if not scope.selectUser.user
      return @display "姓名不能为空" if not scope.selectUser.name
      return @display "邮箱为空或邮箱格式有误，请查证" if not scope.selectUser.email
      return @display "手机号码必须是11位数字" if not scope.selectUser.phone || scope.selectUser.phone.length != 11
    )
    # 获取用户列表
    getUsersInfo: (scope) => (
      # 给获取到的用户添加角色信息
      addPowerInfo = () => (
        for role in scope.roles
          _.each(scope.users, (user)->
            if( _.find(role.users, (item) -> item == user.user) )
              user.auth = role.role
              user.authName = role.name
          )
      )
      # 超级管理员登录时获取所有用户列表
      if(scope.user == "admin")
        @commonService.modelEngine.modelManager.$http.get(
          "#{@userUrl}?token=#{@token}"
          ).then((res) =>
            scope.users = res.data
            scope.selectUser = scope.users[0]
            addPowerInfo()
        )
      # 普通成员登录只获取自己的用户信息
      else
        @commonService.modelEngine.modelManager.$http.get(
          "#{@userUrl}/#{scope.user}?token=#{@token}"
          ).then((res) =>
            scope.users = [res.data]
            scope.selectUser = scope.users[0]
            addPowerInfo()
        )
    )
    # 密码加密
    encrypt: (password, username) ->
      return if not password or not username
      des.DES.encrypt(password, username).toString()

    # 保存新增用户的角色
    roleAuth: (scope,userId,userRole) =>
      roleObj = _.find scope.roles,(role)->
        role.role == userRole
      roleObj.users.push userId
      @rolesService.save roleObj,(err,data)=>
        @display err, '注册成功！'
        @init(scope)

    init: (scope) => (
      @commonService.modelEngine.modelManager.$http.get("#{@host}/model/clc/api/v1/roles/admin/#{@project}?token=#{@token}").then((res)=>
        scope.roles = res.data
        scope.selectRefresh++
        @getUsersInfo(scope)
      )
      scope.msgEquipment = scope.station.loadEquipment( scope.parameters.msg || "_msg", null, (err, equip)=>
        equip.loadCommands(null, (err, commands) =>
          msgCommand = scope.parameters.command || "SMS-comand"
          @msgCommand = _.find(commands, (item) -> item.model.command == msgCommand)
        )
      )
    )

    resize: (scope)->

    dispose: (scope)->
      if(@verificateCodeTimeout)
        clearTimeout(@verificateCodeTimeout)


  exports =
    UserManageDirective: UserManageDirective