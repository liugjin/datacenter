// Generated by IcedCoffeeScript 108.0.13

/*
* File: card-manage-controller
* User: Pu
* Date: 2019/04/08
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var CardManageController, exports;
  CardManageController = (function(_super) {
    __extends(CardManageController, _super);

    function CardManageController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      CardManageController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
    }

    return CardManageController;

  })(base.ProjectBaseController);
  return exports = {
    CardManageController: CardManageController
  };
});
