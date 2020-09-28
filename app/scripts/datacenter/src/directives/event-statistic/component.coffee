###
* File: event-statistic-directive
* User: David
* Date: 2018/11/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EventStatisticDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "event-statistic"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      stationId:'='
      statisticValue:'='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      window.debugR =scope

      scope.selectEventType=(type) =>
        scope.eventType = type
        #选择事件类型，接收 字符串，如 'ac','system'等等
        @commonService.publishEventBus 'event-list-eventType',type?.key

      scope.$watch "parameters.stationId",(stationId)=>

        return if not stationId
        @getStation scope,stationId

#      @commonService.subscribeEventBus 'stationId',(msg)=>
#        stationId = msg.message?.stationId
#        return if not stationId
#        @getStation scope,stationId



    resize: (scope)->

    dispose: (scope)->


  exports =
    EventStatisticDirective: EventStatisticDirective