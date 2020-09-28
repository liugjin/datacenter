###
* File: login-hmu2500-directive
* User: David
* Date: 2020/05/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "tripledes"], (base, css, view, _, moment, des) ->
  class LoginHmu2500Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "login-hmu2500"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    link: (scope, element, attrs) => (
      @notificationsService = @commonService.modelEngine.modelManager.getService("notifications") # 短信服务
      @token = scope.parameters.token || "fa5d09d0-af61-11e8-acd7-937b5970daac" # 万能token
      @host = @$window.origin
      @users = [] # 所有用户集合
      @msgEquipment = {} # 短信设备
      @project = {} # 第一个项目的项目信息
      @adminUser = {} # 管理员用户
      @password = "" # 发送过去的密码
      scope.resetUser = "" # 输入框输入的重置密码字符串
      scope.appVersion = ""
      scope.hardwareVersion = ""
      scope.systemVersion = ""
      scope.tag = ""
      @init(scope)
      scope.user = {}
      # 回车键登录
      scope.onKeyUp = (event) => (
        if event.keyCode is 13 and scope.user and scope.user.username and scope.user.password
          scope.login()
      )
      # 登录
      scope.login = () => (
        return @display "用户名不能为空" if not scope.user?.username
        return @display "密码不能为空" if not scope.user?.password
        user = {username: scope.user?.username, password: @encrypt(scope.user?.password, scope.user?.username)}
        scope.controller.authService.httpService.post(scope.controller.setting.authUrls.login, user, (err, res) =>
          return @display err if err
          scope.controller.$rootScope.user = res
          scope.controller.storage.set("clc-login-info", user)
          scope.controller.authService.setTokenCookie({username: res.user, token: res.token}, true)
          scope.controller.redirect("/" + scope.controller.setting.namespace + "/")
        )
      )
      # 获取重置密码需要的信息
      scope.resetPassword = () => (
        if(_.isEmpty(@adminUser))
          # 查询所有用户
          @commonService.modelEngine.modelManager.$http.get("#{@host}/model/clc/api/v1/users?token=#{@token}").then((res1) =>
            @users = res1.data
            @adminUser = _.find(@users, (user)=> user.user == "admin")
            # 获取第一个项目
            @commonService.modelEngine.modelManager.$http.get("#{@host}/model/clc/api/v1/projects/admin?token=#{@token}").then((res2) =>
              @project= res2.data[0]
              @commonService.modelEngine.modelManager.$http.get("#{@host}/model/clc/api/v1/equipments/admin/#{@project.project}/+/_msg?token=#{@token}").then((res3) =>
                @msgEquipment = res3.data
                @restPassword(scope)
              )
            )
          )
        else
          @restPassword(scope)
      )
    )
    # 重置密码
    restPassword: (scope) => (
      resetUserObj = _.find(@users, (user)-> user.user == scope.resetUser)
      if(resetUserObj)
        @password = String(Math.random()).slice(2,8) # 随机生成六位数密码
#        console.log @password
        changepPasswordUrl = scope.controller.setting.authUrls.changePassword
        resetUser = {
          user: resetUserObj.user,
          oldPassword: @encrypt( resetUserObj.phone, resetUserObj.user)
          password: @encrypt(@password, resetUserObj.user),
          type: "sms"
          token: resetUserObj.token
        }
        scope.controller.authService.httpService.post(changepPasswordUrl,resetUser,(err,reback)=>
          return @display(err) if err
          # 密码修改完成后进行短信通知
          filter = {
            notification: {
              user: @adminUser.user,
              project: @project.project,
              type: "command",
              trigger: "user",
              timeout: 2000,
              notification: "test-notification",
              title: "#{@msgEquipment.station}/#{@msgEquipment.equipment}/SMS-comand"
              content: {
                #phone: resetUserObj.user,    # faner测试要求这里改为手机号码
                phone:  '"'+resetUserObj.phone+'"'
                msg: "【华远云联】你的新密码为：#{@password}"
              },
              phase: "start",
              priority: 0,
            }
          }
          # console.log("filter",filter)
          # 发短信
          msgUrl = @notificationsService.url.substr(0, @notificationsService.url.indexOf("/:user"))
          @notificationsService.postData(msgUrl, filter, (err2, data) =>
            @display "发送短信失败了" if err2 or data?.phase is "error"
            @display "发送超时失败了" if data?.phase is "timeout"
            @display "新密码已发送至尾号#{resetUserObj.phone.slice(7,11)}" if data?.phase is "completed"
          )
        )

      else
        @display "请输入正确的用户名"
    )
    # 密码加密
    encrypt: (password, username) =>
      return if not password or not username
      des.DES.encrypt(password, username).toString()

    init: (scope) => (
      @commonService.rpcGet("getVersionInfo", null, (err,res)=>
        scope.appVersion = res.data.appVersion
        scope.hardwareVersion = res.data.hardwareVersion
        scope.systemVersion = res.data.systemVersion
        scope.tag = res.data.tag
      )
    )


    resize: (scope)->

    dispose: (scope)->


  exports =
    LoginHmu2500Directive: LoginHmu2500Directive