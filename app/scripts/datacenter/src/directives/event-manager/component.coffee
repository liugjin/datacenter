###
* File: event-manager-directive
* User: David
* Date: 2018/11/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'lodash', "moment",'rx'], (base, css, view, _, moment,rx) ->
  class EventManagerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "event-manager"

    setScope: ->
#      "stationId":"="
    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      window.debugEventManager=scope

      getStatistic= () ->
        statistic =
          counts:
            confirmedEvents: 0
            startEvents: 0
            endEvents: 0
            allEvents: 0

          severities: {}
          severity: 0
        
      changeStation=(stationId)=>
        return if not stationId or scope.stationId is stationId
        scope.stationId = stationId
        scope.statistic = getStatistic()
        @getStation(scope,stationId)
        subscribeStationEvent(stationId)
        @commonService.publishEventBus "stationId", {stationId: stationId}
        scope.$applyAsync()

      # 加载项目站点
      scope.project.loadStations null, (err, stations)=>
        dataCenters = _.filter stations, (sta)->(sta.model.parent is null or sta.model.parent is "") and sta.model.station.charAt(0) isnt "_"
        scope.datacenters = dataCenters
        scope.stations = dataCenters
        scope.station = dataCenters[0]
        scope.parents = []

      # 选择站点
      scope.selectStation = (station)=>
        scope.station = station
        changeStation(station?.model?.station)

      # 选择子站点
      scope.selectChild = (station)=>
        scope.stations = scope.station.stations
        scope.parents.push scope.station
        scope.station = station
        changeStation(station?.model?.station)

      # 选择父站点
      scope.selectParent = (station)=>
        index = scope.parents.indexOf(station)
        scope.parents.splice index, scope.parents.length-index
        scope.station = station
        changeStation(station?.model?.station)
        scope.stations = station.parentStation?.stations ? scope.datacenters



      ALL_EVENT_STATISTIC = 'event-statistic/all'
      EVENT_COMPLETED = 'completed'
      scope.allEventsValue = 0
      eventSeverity = scope.project?.typeModels?.eventseverities?.items

      scope.selectAllEquipmentTypes=()=>
        scope.equipmentTypes = {}
        scope.equipmentTypesCount = 0
        @commonService.publishEventBus 'event-list-equipmentTypes',[]

      scope.selectEquipmentType= (type) =>
        if scope.equipmentTypes.hasOwnProperty(type.type)
          delete scope.equipmentTypes[type.type]
          scope.equipmentTypesCount--
        else
          scope.equipmentTypes[type.type] = type.type
          scope.equipmentTypesCount++

        arr=[]
        _.forEach scope.equipmentTypes,(type)=>
          arr.push(type)

        @commonService.publishEventBus 'event-list-equipmentTypes',arr

      statisticEvents=() ->
      # reset all count
        all = getStatistic()
        scope.statistics = {}
        scope.statistics[ALL_EVENT_STATISTIC] = all

        for key, event of scope.eventsArray when event.phase isnt EVENT_COMPLETED
          key = "event-statistic/#{event.user}/#{event.project}/#{event.station}"
          statistic = scope.statistics[key]
          if not statistic
            statistic =  getStatistic()
            scope.statistics[key] = statistic

          # count event phase
          switch event.phase
            when 'start'
              all.counts.startEvents++
              statistic.counts.startEvents++
            when 'end'
              all.endEvents++
              statistic.counts.endEvents++
            when 'confirm'
              all.confirmedEvents++
              statistic.counts.confirmedEvents++

          # count event severity
          if statistic.severities.hasOwnProperty event.severity
            statistic.severities[event.severity] += 1
          else
            statistic.severities[event.severity] = 1

          if all.severities.hasOwnProperty event.severity
            all.severities[event.severity] += 1
          else
            all.severities[event.severity] = 1

          if statistic.severity < event.severity
            statistic.severity = event.severity

          all.counts.allEvents++
          statistic.counts.allEvents++

          # count by event type
          statistic.types ?= {}

          type = event.equipmentType

          if statistic.types.hasOwnProperty type
            statisticType = statistic.types[type]
            statisticType.count++
            statisticType.severity = event.severity if event.severity > statisticType.severity
          else
            statistic.types[type] =
              name: (_.find scope.project.dictionary.equipmenttypes.items, (tp)->tp.key is type)?.model.name
              type: type
              count: 1
              severity: event.severity

        for station in scope.project.stations.items
          key = "event-statistic/#{station.model.user}/#{station.model.project}/#{station.model.station}"
          station.statistic = scope.statistics[key] ? getStatistic()


        # count datacenters
        for datacenter in scope.datacenters
          datacenterStatistic = datacenter.statistic
          datacenterCounts = datacenterStatistic.counts
          datacenterSeverities = datacenterStatistic.severities

          # count by event type
          datacenterStatistic.types ?= {}

          for station in datacenter.stations
            stationStatistic = station.statistic
            stationCounts = stationStatistic.counts

            datacenterCounts.startEvents += stationCounts.startEvents
            datacenterCounts.endEvents += stationCounts.endEvents
            datacenterCounts.confirmedEvents += stationCounts.confirmedEvents
            datacenterCounts.allEvents += stationCounts.allEvents

            stationSeverities = stationStatistic.severities
            for k, v of stationSeverities
              datacenterSeverities[k] = (datacenterSeverities[k] ? 0) + v

            if datacenterStatistic.severity < stationStatistic.severity
              datacenterStatistic.severity = stationStatistic.severity
            #            datacenterStatistic.color = stationStatistic.color

            for key, type of stationStatistic.types
              if datacenterStatistic.types.hasOwnProperty type.type
                statisticType = datacenterStatistic.types[type.type]
                statisticType.count += type.count
                statisticType.severity = type.severity if type.severity > statisticType.severity
              else
                datacenterStatistic.types[type.type] =
                  type: type.type
                  count: type.count
                  severity: type.severity


      statisticEventsLazy=_.throttle(statisticEvents, 200,{leading: false});

      scope.getEventColor=(severity) ->
        color = scope.project?.dictionary?.eventseverities?.getItem(severity)?.model.color



      statisticStationEvents= ()->
        statistic = getStatistic()
        n = 0
        for event in scope.eventsArray
          switch event.phase
            when 'start'
              statistic.counts.startEvents++
            when 'confirm'
              statistic.counts.confirmedEvents++
            when 'end'
              statistic.counts.endEvents++
            else
              console.log(n++,event)
            # don't process completed event
              continue

          statistic.counts.allEvents++

          if statistic.severities.hasOwnProperty event.severity
            statistic.severities[event.severity] += 1
          else
            statistic.severities[event.severity] = 1

          if event.severity > statistic.severity
            statistic.severity = event.severity

          # count by event type
          statistic.types ?= {}
          type = event.equipmentType
          if statistic.types.hasOwnProperty type
            statisticType = statistic.types[type]
            statisticType.count++
            statisticType.severity = event.severity if event.severity > statisticType.severity
          else
            statistic.types[type] =
              name: (_.find scope.project?.dictionary?.equipmenttypes?.items, (tp)->tp.key is type)?.model.name
              type: type
              count: 1
              severity: event.severity

        scope.statistic = statistic
        scope.$applyAsync()

      statisticStationEventsLazy=_.throttle(statisticStationEvents, 1000,{leading: false});

      scope.allEvents={}
#      查询数据库，获取所有站点的事件，过滤掉completed事件。
      queryStationsEvent=()=>
        return if not scope.project?.stations?.items.length > 0
        i = 0
        scope.project?.stations?.items.forEach((station)=>
          @commonService.reportingService.queryEventRecords {filter: station.getIds(),padding:null,sorting:{startTime: 1}},(err, records)=>
            return console.log("err:",err) if err
            i++
            if records.length > 0
              for event in records
                scope.allEvents["#{event.user}/#{event.project}/#{event.station}/#{event.equipment}/#{event.event}/#{event.startTime}"] = event
#            console.log("queryEventRecords:",station.getIds(),records)
        )


      statisticAllEvent=()=>
        return if not scope.project?.stations?.items.length > 0
        scope.statistic2={}
        stationsList = []

        addStations=(ids,station)=>
          # 先加本身站点
          ids.push(station.model.station)
          # 添加子站点
          for sta in station.stations
            ids.push(sta.model.station)
            #子站点又有自己的子站点
            addStations(ids,sta)

        # 用于统计 站点以及子站点
        for station in scope.project?.stations?.items
          id = station.model.station
          scope.statistic2[id] =
            ids:[]
            count:0

          stationsList.push(id)

          ids=[]
          ids.push(id)
          addStations(ids,station)
          # ids可能会有重复的站点id，去重
          scope.statistic2[id].ids = _.uniq(ids)

        #遍历所有事件，进行统计，不统计comleted的。
        _.forEach(scope.allEvents,(event)=>
          for sta in stationsList
            if scope.statistic2[sta].ids.includes(event.station)
              scope.statistic2[sta].count += 1 if event.phase != 'completed'
        )
#        console.log("scope.statistic2",scope.statistic2)
      statisticAllEventLazy=_.throttle(statisticAllEvent, 200,{leading: false});


      scope.events={}
      scope.eventsArray = []
      scope.startEvents = {}
      scope.eventSubscriptionArray = {}

      subscribeStationEvent=(stationId)=>
        scope.events={}
        scope.eventsArray = []
        scope.startEvents = {}
        queryStationsEvent()

        stationIdArray=[]
        userName=scope.project.model.user
        projectName=scope.project.model.project
        stationIdArray.push(stationId)
        station = scope?.project?.stations?.getItem(userName+"_"+ projectName+"_"+stationId)
        scope.station = station

        addChildrenStations=(sta)->
          sta.stations.forEach (s)->
            stationIdArray.push(s.model.station) if s?.model?.station
            addChildrenStations(s) if s?.stations?.length > 0

        addChildrenStations(station)
        station.stationIdArray = stationIdArray;


        stationIdArray.forEach (id)=>
          filter =
            user: scope.project.model.user
            project: scope.project.model.project
            station: id
#          console.log("eventSubscription:",id)
          scope.eventSubscriptionArray[id]?.dispose()
          eventSubscription=@commonService.eventLiveSession.subscribeValues filter,(err,msg)->
            return console.log(err) if err
#            console.log(msg)
            event = msg.message
            scope.allEvents["#{event.user}/#{event.project}/#{event.station}/#{event.equipment}/#{event.event}/#{event.startTime}"] = event
            statisticAllEventLazy()
            processEvent(msg)
            statisticStationEventsLazy()
            statisticEventsLazy()
          scope.eventSubscriptionArray[id] = eventSubscription


      processEvent=(data) ->
        return if not data
        message = data.message
        key = "#{message.user}.#{message.project}.#{message.station}.#{message.equipment}.#{message.event}.#{message.severity}.#{message.startTime}"

        if scope.events.hasOwnProperty key
          event = scope.events[key]
          # update existing event
          for k, v of message
            event[k] = v

          if event.endTime
            delete scope.startEvents[key]
        else
          event = angular.copy message
          scope.events[key] = event
          # bug: all event will be subscribe,so it should pick up by stationId
          scope.eventsArray.push event if scope.station.stationIdArray.includes(event.station)
          event.color = 'grey'
          eventSeverity.forEach (e)=>
            event.color = e?.model?.color if event?.severity is e?.model?.severity

          scope.startEvents[key] = event if not event.endTime

        # remove the completed event
        if message.phase is 'completed'
          event = scope.events[key]
          delete scope.events[key]
          delete scope.startEvents[key]
          _.remove scope.eventsArray,(e)=>
            return e["_id"] is event["_id"]
          scope.$applyAsync()

        # to trigger event statistic
        event



      scope.selectDatacenter=(datacenter)=>
        return if not datacenter
        scope.datacenter = datacenter
#        stationId = datacenter.stations[0]?.model?.station
        stationId = datacenter.model.station
        changeStation(stationId)
        scope.$applyAsync()



      scope.selectStation = (station)=>
        return if not station
        stationId = station?.model?.station
        changeStation(stationId)

      scope.selectAllEquipmentTypes()

      scope.busSubscription?.dispose()
      scope.busSubscription = @commonService.subscribeEventBus 'stationId',(msg)=>
        return if not msg
        stationId = msg.message.stationId
        changeStation(stationId)


      scope.selectParent(scope.datacenters[0])
      scope.selectChild(scope.datacenter?.stations[0] || scope.project?.stations?.items[0])
      scope.selectDatacenter(scope.datacenters[0])

    resize: (scope)->

    dispose: (scope)->
      scope.eventSubscriptionArray[sub]?.dispose() for sub of scope.eventSubscriptionArray
      scope.eventSubscriptionArray={}
      scope.busSubscription?.dispose()


  exports =
    EventManagerDirective: EventManagerDirective