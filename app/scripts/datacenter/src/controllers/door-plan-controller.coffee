###
* File: door-plan-controller
* User: bingo
* Date: 2019/04/11
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/controllers/project-base-controller'], (base) ->
  class DoorPlanController extends base.ProjectBaseController
    constructor: ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) ->
      super $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options


  exports =
    DoorPlanController: DoorPlanController
