###
* File: station-3d-directive
* User: David
* Date: 2019/07/07
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class Station3dDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-3d"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      if scope.firstload
      #保证进入该组件时，站点切换到配有组态的站点
        station = _.find scope.project.stations.nitems, (sta)-> not _.isEmpty sta.model.d3
        @publishEventBus "stationId", {stationId: station.model.station} if station

    resize: (scope)->

    dispose: (scope)->


  exports =
    Station3dDirective: Station3dDirective