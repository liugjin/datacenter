###
* File: alarms-monitoring-directive
* User: David
* Date: 2019/07/19
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "rx"], (base, css, view, _, moment, Rx) ->
  class AlarmsMonitoringDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "alarms-monitoring"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.alarms = {}
      scope.types = []

      scope.datacenters = _.filter scope.project.stations.items, (sta)->_.isEmpty(sta.model.parent) and sta.model.station.charAt(0) isnt "_"
      scope.parents = []
      
      @findParent scope, scope.station
      scope.stations = scope.parents[0]?.stations ? scope.datacenters
      scope.parents = scope.parents.reverse()
      scope.severities = scope.project?.dictionary?.eventseverities.items

      scope.getEventColor = (severity) =>
        color = scope.project?.dictionary?.eventseverities?.getItem(severity)?.model.color
        color

      scope.selectEquipmentType = (type) =>
        if type is "all"
          scope.types = []
        else
          index = scope.types.indexOf type
          if index < 0
            scope.types.push type
          else
            scope.types.splice index, 1

        @commonService.publishEventBus 'event-list-equipmentTypes',scope.types

      scope.selectStation = (station)->
        scope.station = station

      scope.selectChild = (station)->
        scope.stations = scope.station.stations
        scope.parents.push scope.station
        scope.station = station

      scope.selectParent = (station)->
        index = scope.parents.indexOf(station)
        scope.parents.splice index, scope.parents.length-index
        scope.station = station
        scope.stations = station.parentStation?.stations ? scope.datacenters

      if scope.firstload
        #第一次把所有站点的告警加载处理
        for station in scope.project.stations.nitems
          scope.alarms[station.model.station] = {count:0, severity:0, list:{}, severities:{}, types: {}}
          _.each scope.severities, (severity)->
            scope.alarms[station.model.station].severities[severity.model.severity] = 0

        subject = new Rx.Subject

        filter =
          user: scope.project.model.user
          project: scope.project.model.project

        scope.eventSubscription?.dispose()
        scope.eventSubscription = @commonService.eventLiveSession.subscribeValues filter, (err, d) =>
          return if not d.message?.event or not scope.alarms[d.message.station]
          event = d.message
          key = "#{event.user}.#{event.project}.#{event.station}.#{event.equipment}.#{event.event}.#{event.severity}.#{event.startTime}"
          scope.alarms[event.station].list[key] = event
          delete scope.alarms[event.station].list[key] if event.endTime

          subject.onNext()

        subject.debounce(100).subscribe =>
          @processEvents scope
      @processEvents scope

    processEvents: (scope) =>
      for key, value of scope.alarms
        _.each scope.severities, (severity)=>
          value.severities[severity.model.severity] = 0

        value.types = {}
        value.count = (_.keys value.list).length
        value.starts = _.filter(_.values(value.list), (item)->item.phase is "start").length
        value.ends = _.filter(_.values(value.list), (item)->item.phase is "end").length
        value.confirms = _.filter(_.values(value.list), (item)->item.phase is "confirm").length
        value.severity = (_.max(_.filter(_.values(value.list),(item)->not item.endTime), (it)->it.severity))?.severity
        map = _.countBy _.values(value.list), (item)->item.severity

        for key,val of map
          value.severities[key] = val
        types = _.countBy _.values(value.list), (item)->item.equipmentType

        for key,val of types
          value.types[key] =
            name: _.find(scope.project.dictionary?.equipmenttypes?.items, (item)->item.model.type is key)?.model.name
            value: val
            severity: (_.max(_.filter(_.values(value.list),(item)->item.equipmentType is key), (it)->it.severity))?.severity

      for station in scope.project.stations.nitems
        stations = @commonService.loadStationChildren station, false
        currentStation = scope.alarms[station.model.station]
        for sta in stations
          if sta.stations.length is 0
            currentStation.count += scope.alarms[sta.model.station].count
            currentStation.starts += scope.alarms[sta.model.station].starts
            currentStation.ends += scope.alarms[sta.model.station].ends
            currentStation.confirms += scope.alarms[sta.model.station].confirms
            currentStation.severity = scope.alarms[sta.model.station].severity if currentStation.severity < scope.alarms[sta.model.station].severity
            for key,val of currentStation.severities
              currentStation.severities[key] += (scope.alarms[sta.model.station].severities[key] ? 0)

            for key,val of scope.alarms[sta.model.station].types
              if currentStation.types[key]
                currentStation.types[key].value += scope.alarms[sta.model.station].types[key].value
                currentStation.types[key].severity = scope.alarms[sta.model.station].types[key].severity if currentStation.types[key].severity < scope.alarms[sta.model.station].types[key].severity
              else
                currentStation.types[key] = JSON.parse JSON.stringify scope.alarms[sta.model.station].types[key]

        currentStation.statistic =
          counts:
            confirmedEvents: currentStation.confirms
            startEvents: currentStation.starts
            endEvents: currentStation.ends
            allEvents: currentStation.count
          severities: currentStation.severities
      scope.$applyAsync()

    findParent: (scope, station) ->
      parent = _.find scope.project.stations.items, (sta) ->sta.model.station is station.model.parent
      if parent
        scope.parents.push parent
        @findParent scope, parent

    resize: (scope)->


    dispose: (scope)->


  exports =
    AlarmsMonitoringDirective: AlarmsMonitoringDirective