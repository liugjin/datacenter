// Generated by IcedCoffeeScript 108.0.12

/*
* File: ip-setting-controller
* User: Pu
* Date: 2020/03/26
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var IpSettingController, exports;
  IpSettingController = (function(_super) {
    __extends(IpSettingController, _super);

    function IpSettingController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      IpSettingController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return IpSettingController;

  })(base.ProjectBaseController);
  return exports = {
    IpSettingController: IpSettingController
  };
});
