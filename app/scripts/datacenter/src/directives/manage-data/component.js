// Generated by IcedCoffeeScript 108.0.13

/*
* File: manage-data-directive
* User: David
* Date: 2020/05/18
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var ManageDataDirective, exports;
  ManageDataDirective = (function(_super) {
    __extends(ManageDataDirective, _super);

    function ManageDataDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.init = __bind(this.init, this);
      this.show = __bind(this.show, this);
      this.id = "manage-data";
      ManageDataDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    ManageDataDirective.prototype.setScope = function() {};

    ManageDataDirective.prototype.setCSS = function() {
      return css;
    };

    ManageDataDirective.prototype.setTemplate = function() {
      return view;
    };

    ManageDataDirective.prototype.show = function(scope, element, attrs) {
      this.equipmentsignalsService = this.commonService.modelEngine.modelManager.getService('equipmentsignals');
      this.project = scope.project.model.project;
      this.user = scope.project.model.user;
      scope.storeModel = "";
      scope.ftpInfo = {
        host: "",
        port: "",
        user: "",
        password: ""
      };
      this.init(scope);
      scope.confitmRadioMethod = (function(_this) {
        return function() {
          var postObj;
          postObj = {
            model: scope.storeModel,
            project: _this.project,
            user: _this.user
          };
          return _this.commonService.rpcPost("changeStoreMode", postObj, function(err, res) {
            if (res.parameters.model === "1800000") {
              return _this.display("数据储存策略已修改成精细模式");
            } else if (res.parameters.model === "14400000") {
              return _this.display("数据储存策略已修改成均衡模式");
            } else if (res.parameters.model === "28800000") {
              return _this.display("数据存储策略已修改成长时模式");
            } else {
              return _this.display(res.data.msg);
            }
          });
        };
      })(this);
      return scope.changeStoreInfo = (function(_this) {
        return function() {
          var postObj;
          if (_.isEmpty(scope.ftpInfo.host) || _.isEmpty(scope.ftpInfo.user) || _.isEmpty(scope.ftpInfo.password)) {
            return _this.display("必填项不能为空");
          }
          if (!isNaN(scope.ftpInfo.host)) {
            return _this.display("端口的格式应该是数字");
          }
          postObj = {
            project: _this.project,
            user: _this.user,
            address: scope.ftpInfo
          };
          return _this.commonService.rpcPost("changeStoreInfo", postObj, function(err, res) {
            if (res.data.status === true) {
              return _this.display("已成功修改备份地址");
            } else {
              return _this.display("请输入正确的备份地址");
            }
          });
        };
      })(this);
    };

    ManageDataDirective.prototype.init = function(scope) {
      return this.commonService.rpcGet("getStoreMode", null, (function(_this) {
        return function(err, res) {
          scope.storeModel = res.data.storeMode;
          return scope.ftpInfo = {
            host: res.data.host,
            port: res.data.port,
            user: res.data.user,
            password: res.data.password
          };
        };
      })(this));
    };

    ManageDataDirective.prototype.resize = function(scope) {};

    ManageDataDirective.prototype.dispose = function(scope) {};

    return ManageDataDirective;

  })(base.BaseDirective);
  return exports = {
    ManageDataDirective: ManageDataDirective
  };
});
