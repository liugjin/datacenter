// Generated by IcedCoffeeScript 108.0.13

/*
* File: alarm-setting-controller
* User: Pu
* Date: 2019/07/08
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var AlarmSettingController, exports;
  AlarmSettingController = (function(_super) {
    __extends(AlarmSettingController, _super);

    function AlarmSettingController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      AlarmSettingController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return AlarmSettingController;

  })(base.ProjectBaseController);
  return exports = {
    AlarmSettingController: AlarmSettingController
  };
});
