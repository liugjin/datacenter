###
* File: alarm-severity-boxes-directive
* User: David
* Date: 2019/05/30
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class AlarmSeverityBoxesDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "alarm-severity-boxes"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.severities = {}
      _.each scope.project.dictionary.eventseverities.items, (item)->
        scope.severities[item.model.severity] = {name: item.model.name, color: item.model.color, value: 0}

      scope.subscriptions = {}
      scope.events = {}
      @subscribeStationEvents scope, scope.station

    subscribeStationEvents: (scope, station) =>
      return if not station
      filter =
        user: station.model.user
        project: station.model.project
        station: station.model.station
      scope.subscriptions[station.model.station]?.dispose()
      scope.subscriptions[station.model.station] = @commonService.eventLiveSession.subscribeValues filter, (err, event) =>
        @processEvent scope, event?.message
      for sta in station.stations
        @subscribeStationEvents scope, sta

    processEvent: (scope, event) ->
      return if not event
      key = "#{event.user}.#{event.project}.#{event.station}.#{event.equipment}.#{event.event}.#{event.severity}.#{event.startTime}"
      if not scope.events[key] and not event.endTime
        if scope.severities[event.severity]
          scope.severities[event.severity].value += 1
      else if scope.events[key] and not scope.events[key].endTime and event.endTime
        scope.severities[event.severity].value -= 1
      scope.events[key] = event

    resize: (scope)->

    dispose: (scope)->
      for key, subscribe of scope.subscriptions
        subscribe?.dispose()


  exports =
    AlarmSeverityBoxesDirective: AlarmSeverityBoxesDirective