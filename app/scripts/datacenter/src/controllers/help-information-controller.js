// Generated by IcedCoffeeScript 108.0.11

/*
* File: help-information-controller
* User: Pu
* Date: 2020/06/04
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var HelpInformationController, exports;
  HelpInformationController = (function(_super) {
    __extends(HelpInformationController, _super);

    function HelpInformationController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      HelpInformationController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return HelpInformationController;

  })(base.ProjectBaseController);
  return exports = {
    HelpInformationController: HelpInformationController
  };
});
