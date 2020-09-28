###
* File: station-graphic-directive
* User: David
* Date: 2019/05/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationGraphicDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-graphic"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      type: "="

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      if scope.firstload
        #保证进入该组件时，站点切换到配有组态的站点
        scope.type = scope.parameters.type ? "graphic"
        station = _.find scope.project.stations.nitems, (sta)-> not _.isEmpty sta.model[scope.type]
        @publishEventBus "stationId", {stationId: station.model.station} if station

    resize: (scope)->

    dispose: (scope)->


  exports =
    StationGraphicDirective: StationGraphicDirective