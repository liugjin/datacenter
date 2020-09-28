###
* File: dispatch-controller
* User: Pu
* Date: 2019/05/18
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/controllers/project-base-controller', 'underscore'], (base, _) ->
  class DispatchController extends base.ProjectBaseController
    constructor: ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options) ->
      super $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options

    load: (callback, refresh) ->
      defaultUrl = "dashboard/"+@$routeParams.user+"/"+@$routeParams.project
      filter =
        user: @$routeParams.user
        project: @$routeParams.project
      @modelEngine.loadProject filter, null, (err, project) =>
        if !_.isEmpty project.model._role.portal
          defaultUrl = project.model._role.portal
        @goto defaultUrl

  exports =
    DispatchController: DispatchController
