// Generated by IcedCoffeeScript 108.0.13

/*
* File: video_reliable_list-controller
* User: Pu
* Date: 2019/09/26
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.angular/controllers/project-base-controller'], function(base) {
  var Video_reliable_listController, exports;
  Video_reliable_listController = (function(_super) {
    __extends(Video_reliable_listController, _super);

    function Video_reliable_listController($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) {
      Video_reliable_listController.__super__.constructor.call(this, $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options);
      this.videotype = this.setting.videotype;
    }

    return Video_reliable_listController;

  })(base.ProjectBaseController);
  return exports = {
    Video_reliable_listController: Video_reliable_listController
  };
});
