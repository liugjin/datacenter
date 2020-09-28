###
* File: datacenter-controller
* User: Dow
* Date: 3/25/2017
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/controllers/project-base-controller'], (base) ->
  class DatacenterController extends base.ProjectBaseController
    constructor: ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, @datacenterService, options) ->
      super $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options
#
#    initialize: (callback)->
#      super callback
#
#    echo: ->
#      parameters =
#        user: @$rootScope.user.user
#        time: "client: #{new Date().toISOString()}"
#
#      @datacenterService.echo parameters, (err, result) =>
#        @echoResult = result
#        @display err, result?.method

    onLoad: (callback, refresh) ->
      @load callback, refresh

    load: (callback, refresh) ->
# last time access project
      @myproject = @modelEngine.storage.get 'myproject'

      @loadProjects callback, refresh

    loadProjects: (callback, refresh) ->
# load project including industry keyword (case insensitive)
      filter =
        user: @$rootScope.user?.user
        keywords: @setting.keyword

      fields = '_id user project name image updatetime stars keywords desc'

      @query filter, fields, (err, model) =>
        if model?.length == 1
          @goto "dispatch/"+model[0].user+"/"+model[0].project

        else if model?.length > 1
# mark project star
          for p in model
            p.stared = @isStared p

            # select the first star project by default if no last time access record
            @myproject = p if not @myproject and p.stared

        callback? err, model
      , refresh

  exports =
    DatacenterController: DatacenterController
