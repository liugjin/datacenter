
# compatible for node.js and requirejs
`if (typeof define !== "function") { var define = require("amdefine")(module) }`

define ["clc.foundation.angular/controllers/auth-controller", "tripledes", "underscore"], (base, des, _) ->

  class LoginController extends base.AuthController
    constructor: ($scope, $rootScope, $routeParams, $location, $window, authService, @storage) ->
      super $scope, $rootScope, $routeParams, $location, $window, authService
      @user = {
        "enable" : true
        "visible":true
      }

    login: ->

    logon: ->
      return @display "用户名不能为空" if not @user?.username
      return @display "密码不能为空" if not @user?.password
      user = {username: @user?.username, password: @encrypt(@user?.password, @user?.username)}
      @authService.httpService.post @setting.authUrls.login, user, (err, us) =>
        return @display err if err
        @$rootScope.user = us
        @storage.set "clc-login-info", user
        @authService.setTokenCookie {username: us.user, token: us.token}, true
        @redirect "/"+@setting.namespace+"/"

    enteronpress:->
      if $event.keyCode == 13
#回车
        logon()

    encrypt: (password, username) ->
      return if not password or not username
      des.DES.encrypt(password, username).toString()

    register: ->
      return @display "用户ID不能为空" if not @user.user
      return @display "用户名不能为空" if not @user.name
      return @display "密码不能为空" if not @user.password
      return @display "两次输入密码不一致" if @user.password != @user.confirmPassword
      user = _.clone @user
      user.password = @encrypt @user.password, @user.user
      user.roles = []
      @authService.httpService.post @setting.authUrls.register, user, (err, us) =>
        @display err, "用户"+us.name+"注册成功"
        #        @httpService.get @setting.urls.roles
        @redirect "/"+@setting.namespace+"/#/login"

    onKeyUp: (event)->
      if event.keyCode is 13 and @user and @user.username and @user.password
        @logon()



  exports =
    LoginController: LoginController