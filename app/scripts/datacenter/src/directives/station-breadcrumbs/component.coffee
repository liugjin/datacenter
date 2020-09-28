###
* File: station-breadcrumbs-directive
* User: David
* Date: 2018/11/01
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationBreadcrumbsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-breadcrumbs"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      element.css("display", "block")
      publishStationId = =>
        @commonService.publishEventBus "stationId", {stationId: scope.station?.model?.station}

      scope.datacenters = _.filter scope.project.stations.items, (sta)->_.isEmpty(sta.model.parent) and sta.model.station.charAt(0) isnt "_"
      scope.parents = []
      @findParent scope, scope.station
      scope.stations = scope.parents[0]?.stations ? scope.datacenters
      scope.parents = scope.parents.reverse()

      scope.selectStation = (station)->
        scope.station = station
        publishStationId()


      scope.selectChild = (station)->
#        console.log "station:"+station.model.name
        scope.stations = scope.station.stations
        scope.parents.push scope.station
        scope.station = station
        publishStationId()

      scope.selectParent = (station)->
        index = scope.parents.indexOf(station)
        scope.parents.splice index, scope.parents.length-index
        scope.station = station
        scope.stations = station.parentStation?.stations ? scope.datacenters
        publishStationId()

    findParent: (scope, station) ->
      parent = _.find scope.project.stations.items, (sta) ->sta.model.station is station.model.parent
      if parent
        scope.parents.push parent
        @findParent scope, parent

    dispose: (scope)->


  exports =
    StationBreadcrumbsDirective: StationBreadcrumbsDirective