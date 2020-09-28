###
* File: user-personinfo-directive
* User: David
* Date: 2018/12/18
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "tripledes"], (base, css, view, _, moment,des) ->
  class UserPersoninfoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "user-personinfo"
      super $timeout, $window, $compile, $routeParams, commonService
      @userService = commonService.modelEngine.modelManager.getService("user")
      @changePassword = commonService.modelEngine.modelManager.getService("changePassword")
      @logonUser = commonService.$rootScope.user

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.userObject = {}
      scope.showFlag = true
      scope.oldPassword = ""
      scope.newPassword = ""
      scope.confirmPassword = ""
      scope.setting = setting

      scope.prompt=(title, message, callback) ->
        scope.modal =
          title: title
          message: message
          confirm: (ok) ->
            callback? ok, @comment, @password
          preConfirm: ()->
            callback? "preCommand", @comment, @password

        $('#user-manager-prompt-modal').modal('open')

        return

      @userService.query {user:@logonUser.user},null,(err,userDatas)=>
        if !err
          scope.userObject = userDatas
          scope.userObject.private = false
      ,true

      scope.saveUser = ()=>
#        对显示或修改后的用户信息进行基本校验
        console.log scope.userObject
        scope.userObject.private = false
        userPhone = scope.userObject.phone
        r = /^\+?[1-9][0-9]*$/
        if userPhone.length != 11 || !r.test(userPhone)
           @display '电话为空或格式不正确'

        else
           @userService.save scope.userObject,(err,data)=>
             @display err, '温馨提示：保存成功！'

      scope.delUser = ()=>
        $('#user-manager-prompt-modal').modal('open')
        scope.prompt (ok, comment) =>
          return if not ok
          if ok
            @userService.remove scope.userObject,(err,data)=>
              @display err, '温馨提示：删除成功！'

      scope.updatePassword = ()=>

        if _.isEmpty scope.oldPassword
          @display '温馨提示：请输入旧密码！'
          return

        if _.isEmpty scope.newPassword
          @display '温馨提示：请输入新密码！'
          return

        if scope.confirmPassword != scope.newPassword
          @display '温馨提示：新密码与确认密码不一致，请重新输入新密码和确认密码！'
          return

        if scope.confirmPassword == scope.oldPassword
          @display '温馨提示：新密码与旧密码一致，请重新输入！'
          return
        tmpPasswordObj = {
          user:scope.userObject.user
          token:scope.userObject.token
          oldPassword:@encrypt(scope.oldPassword,scope.userObject.user)
          password:@encrypt(scope.newPassword,scope.userObject.user)
        }
        tmpUrl = scope.setting.urls.changePassword.substr(0,scope.setting.urls.changePassword.indexOf("auth")) + "auth/changepassword"

        @changePassword.postData tmpUrl,tmpPasswordObj,(err,retResult)=>
          if err
            @display null, '温馨提示：'+ err
          else
            @display null, '温馨提示：修改密码成功！'
            scope.newPassword = ''
            scope.oldPassword = ''
            scope.confirmPassword = ''

      scope.showUserInfo = (refFlag)=>
        scope.showFlag = refFlag


      # 选择用户类型
      scope.userchoice = (data)=>
        scope.userObject.private = data
        console.log("userObject",scope.userObject)

    encrypt: (password, username) ->
      return if not password or not username
      des.DES.encrypt(password, username).toString()

    resize: (scope)->

    dispose: (scope)->


  exports =
    UserPersoninfoDirective: UserPersoninfoDirective