###
* File: station-visualization-directive
* User: David
* Date: 2019/01/16
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationVisualizationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-visualization"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.visualizationId = "noStationVisualization"
      @subscribeEventBus 'selectStation', (d) =>
        if d.message.level is "visualization"
          scope.visualizationId = d.message.id
          scope.$applyAsync()
        else
          scope.visualizationId = "noStationVisualization"

    resize: (scope)->

    dispose: (scope)->


  exports =
    StationVisualizationDirective: StationVisualizationDirective