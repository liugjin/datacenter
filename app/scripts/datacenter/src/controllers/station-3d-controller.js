// Generated by IcedCoffeeScript 108.0.13

/*
* File: station-3d-controller
* User: Pu
* Date: 2019/07/07
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var Station3dController, exports;
  Station3dController = (function(_super) {
    __extends(Station3dController, _super);

    function Station3dController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      Station3dController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return Station3dController;

  })(base.ProjectBaseController);
  return exports = {
    Station3dController: Station3dController
  };
});
