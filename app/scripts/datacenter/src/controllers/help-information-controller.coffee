###
* File: help-information-controller
* User: Pu
* Date: 2020/06/04
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/controllers/project-base-controller'], (base) ->
  class HelpInformationController extends base.ProjectBaseController
    constructor: ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) ->
      super $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options


  exports =
    HelpInformationController: HelpInformationController
