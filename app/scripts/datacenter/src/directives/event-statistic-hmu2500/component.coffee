###
* File: event-statistic-hmu2500-directive
* User: David
* Date: 2020/04/29
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EventStatisticHmu2500Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "event-statistic-hmu2500"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      stationId:'='
      statisticValue:'='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.selectEventType=(type) =>
        scope.eventType = type
        #选择事件类型，接收 字符串，如 'ac','system'等等
        @commonService.publishEventBus 'event-list-eventType',type?.key

      scope.$watch "parameters.stationId",(stationId)=>

        return if not stationId
        @getStation scope,stationId
    resize: (scope)->

    dispose: (scope)->


  exports =
    EventStatisticHmu2500Directive: EventStatisticHmu2500Directive