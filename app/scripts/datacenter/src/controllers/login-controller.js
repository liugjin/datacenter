// Generated by IcedCoffeeScript 108.0.13
if (typeof define !== "function") { var define = require("amdefine")(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(["clc.foundation.angular/controllers/auth-controller", "tripledes", "underscore"], function(base, des, _) {
  var LoginController, exports;
  LoginController = (function(_super) {
    __extends(LoginController, _super);

    function LoginController($scope, $rootScope, $routeParams, $location, $window, authService, storage) {
      this.storage = storage;
      LoginController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, authService);
      this.user = {
        "enable": true,
        "visible": true
      };
    }

    LoginController.prototype.login = function() {};

    LoginController.prototype.logon = function() {
      var user, _ref, _ref1, _ref2, _ref3, _ref4;
      if (!((_ref = this.user) != null ? _ref.username : void 0)) {
        return this.display("用户名不能为空");
      }
      if (!((_ref1 = this.user) != null ? _ref1.password : void 0)) {
        return this.display("密码不能为空");
      }
      user = {
        username: (_ref2 = this.user) != null ? _ref2.username : void 0,
        password: this.encrypt((_ref3 = this.user) != null ? _ref3.password : void 0, (_ref4 = this.user) != null ? _ref4.username : void 0)
      };
      return this.authService.httpService.post(this.setting.authUrls.login, user, (function(_this) {
        return function(err, us) {
          if (err) {
            return _this.display(err);
          }
          _this.$rootScope.user = us;
          _this.storage.set("clc-login-info", user);
          _this.authService.setTokenCookie({
            username: us.user,
            token: us.token
          }, true);
          return _this.redirect("/" + _this.setting.namespace + "/");
        };
      })(this));
    };

    LoginController.prototype.enteronpress = function() {
      if ($event.keyCode === 13) {
        return logon();
      }
    };

    LoginController.prototype.encrypt = function(password, username) {
      if (!password || !username) {
        return;
      }
      return des.DES.encrypt(password, username).toString();
    };

    LoginController.prototype.register = function() {
      var user;
      if (!this.user.user) {
        return this.display("用户ID不能为空");
      }
      if (!this.user.name) {
        return this.display("用户名不能为空");
      }
      if (!this.user.password) {
        return this.display("密码不能为空");
      }
      if (this.user.password !== this.user.confirmPassword) {
        return this.display("两次输入密码不一致");
      }
      user = _.clone(this.user);
      user.password = this.encrypt(this.user.password, this.user.user);
      user.roles = [];
      return this.authService.httpService.post(this.setting.authUrls.register, user, (function(_this) {
        return function(err, us) {
          _this.display(err, "用户" + us.name + "注册成功");
          return _this.redirect("/" + _this.setting.namespace + "/#/login");
        };
      })(this));
    };

    LoginController.prototype.onKeyUp = function(event) {
      if (event.keyCode === 13 && this.user && this.user.username && this.user.password) {
        return this.logon();
      }
    };

    return LoginController;

  })(base.AuthController);
  return exports = {
    LoginController: LoginController
  };
});
