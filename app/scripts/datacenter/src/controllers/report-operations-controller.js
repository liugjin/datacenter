// Generated by IcedCoffeeScript 108.0.13

/*
* File: report-operations-controller
* User: Pu
* Date: 2020/01/11
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var ReportOperationsController, exports;
  ReportOperationsController = (function(_super) {
    __extends(ReportOperationsController, _super);

    function ReportOperationsController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      ReportOperationsController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return ReportOperationsController;

  })(base.ProjectBaseController);
  return exports = {
    ReportOperationsController: ReportOperationsController
  };
});
