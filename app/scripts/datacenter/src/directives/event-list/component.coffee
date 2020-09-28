###
* File: event-list-directive
* User: David
* Date: 2018/11/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'lodash', "moment"], (base, css, view, _, moment) ->
  class EventListDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "event-list"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      stationId:"="
      pageItem:"@"
    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      window.debugR = scope
      scope.eventLiveSession= @commonService.eventLiveSession

      eventSeverity = scope.project?.typeModels?.eventseverities?.items
      $(element.find('#event-list-prompt-modal')).modal()
      scope.prompt=(title, message, callback, enableComment, comment, password, preCommand) ->
          scope.modal =
            title: title
            message: message
            enableComment: enableComment
            comment: comment
            passwordFlag: password
            password: ""
            preCommand: preCommand

            confirm: (ok) ->
              callback? ok, @comment, @password

            preConfirm: ()->
              callback? "preCommand", @comment, @password


          $('#event-list-prompt-modal').modal('open')

          return

      updateDuration=() =>
        scope.timer = setInterval ()=>
          for key, event of scope.startEvents
            event.duration = new Date() - event.startTime2
            progress = (event.duration / 3600000 * 100).toFixed(1)
            event.progress = "#{progress}%"
          scope.$applyAsync()
        , 1000

      scope.confirmActiveEvent=(event, forceToEnd) ->
        return if not event
        scope.modal = {}
        action = if forceToEnd then "强制结束" else "确认"
        title = "#{action}活动告警: #{event.stationName} / #{event.equipmentName} / #{event.eventName}"
        message = "请输入备注信息："
        $('#event-list-prompt-modal').modal('open')
        scope.prompt title, message, (ok, comment) =>
          return if not ok

          confirmActiveEvent2 event, comment, forceToEnd
        , true, event.comment

      confirmActiveEvent2=(event, comment, forceToEnd) ->
        # one active event only
        data =
          _id: event._id
          user: event.user
          project: event.project
          station: event.station
          equipment: event.equipment
          event: event.event

        scope.confirmData data, comment, forceToEnd

        if forceToEnd
          scope.eventLiveSession.forceEndEvent data
        else
          scope.eventLiveSession.confirmEvent data


      scope.confirmStationEvents=(station, forceToEnd) ->
        action = if forceToEnd then "强制结束" else "确认"
        title = "#{action}机房及其子机房下属所有告警: #{station.model.name}"
        message = "请输入备注信息："

        scope.prompt title, message, (ok, comment) =>
          return if not ok

          confirmStationEvents2 station, comment, forceToEnd
        , true

      confirmStationEvents2=(station, comment, forceToEnd) ->
        # match events belong to this station and its children station
        data = station.getIds()
        data.stations = station.stationIds
        scope.confirmData data, comment, forceToEnd

        # event may have multiple active events so that use confirm all event command
        scope.eventLiveSession.confirmAllEvents data

      scope.confirmData=(data, comment, forceToEnd) ->
        data.operator = scope.$root?.user.user
        data.operatorName = scope.$root?.user.name
        data.confirmTime = new Date
        data.comment = comment
        data.forceToEnd = forceToEnd
        return data

      scope.predicate = "index"
      scope.reverse = false
      scope.sortBy=(predicate) ->
        if scope.predicate is predicate
          scope.reverse = !scope.reverse
        else
          scope.predicate = predicate
          scope.reverse = true

      scope.filterEvent=() ->
        (event) =>
          if scope.statisticLegends[event.phase] is false or scope.statisticLegends[event.severity] is false
            return false

          return false if scope.eventType and scope.eventType isnt event.eventType

          return false if scope.equipmentTypes?.length and scope.equipmentTypes?.indexOf(event.equipmentType) == -1

          return false if scope.search and scope.search != "" and event.equipmentName.indexOf(scope.search) == -1 and event.stationName.indexOf(scope.search) == -1 and event.title.indexOf(scope.search) == -1

          return true

      scope.filterStationEventsResult = null
      scope.selectedPage = 1
      scope.filterStationEvents=()->
        scope.eventsArray
        events = _.filter(scope.eventsArray,scope.filterEvent())
        pageCount = Math.ceil(events.length / scope.parameters.pageItem)
        if scope.selectedPage > pageCount
          @changePage(pageCount)

        result = {
          pageCount:pageCount
          pages:[1..pageCount]
        }
        scope.filterStationEventsResult = result
        return result

      getSortedEventArray= ()=>
        f = _.filter(scope.eventsArray,scope.filterEvent())
        events = _.sortBy(f,(e)=>
          return e[scope.predicate]
        )
        if scope.reverse
          result = events.reverse()
        else
          result = events
        return result

      scope.selectNext=()=>
        events = getSortedEventArray()
        index = events.indexOf(scope.selectedEvent)
        if index+1 < events.length-1
          scope.selectEvent(events[index+1])

      scope.selectPrevious=()=>
        events = getSortedEventArray()
        index = events.indexOf(scope.selectedEvent)
        if index-1 >=0
          scope.selectEvent(events[index-1])


      scope.changePage=(page)->
        return if page < 1 or page > scope.filterStationEventsResult.pageCount
        scope.selectedPage = page

      scope.events={}
      scope.eventsArray = []
      scope.startEvents = {}
      scope.eventSubscriptionArray = []
      subscribeStationEvent=(stationId)=>
        scope.events={}
        scope.eventsArray = []
        scope.startEvents = {}

        scope.eventSubscriptionArray.forEach (sub)=>
          sub.dispose()


        stationIdArray=[]
        userName=scope.project.model.user
        projectName=scope.project.model.project
        stationIdArray.push(stationId)
        station = scope?.project?.stations?.getItem(userName+"_"+ projectName+"_"+stationId)
        scope.station = station
        return if not station

        addChildrenStations=(sta)->
          sta.stations.forEach (s)->
            stationIdArray.push(s.model.station) if s?.model?.station
            addChildrenStations(s) if s?.stations?.length > 0

        addChildrenStations(station)

        stationIdArray.forEach (id)=>
          filter =
            user: scope.project.model.user
            project: scope.project.model.project
            station: id
          eventSubscription=@commonService.eventLiveSession.subscribeValues filter,(err,msg) =>
            return console.log(err) if err
            processEvent(msg)
          scope.eventSubscriptionArray.push(eventSubscription)


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
          scope.eventsArray.push event
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

        event.startTime2 = new Date event.startTime
        # to trigger event statistic
        event

#      选择事件，发布消息 ，event对象
      scope.selectedEvent = null
      scope.selectEvent=(event)->
        scope.selectedEvent = event
        scope.queryEventRecords(event)

#    scope.decorateEvent=(event) ->
#      event.updateTime = event.endTime ? event.confirmTime ? event.startTime
#      event.eventSeverity = @project.typeModels.eventseverities.getItem(event.severity)?.model
#      event.color = event.eventSeverity?.color ? @endColor
#
#      endTime = if event.endTime then new Date(event.endTime) else new Date
#      event.duration = endTime - new Date(event.startTime)
#      event.startTime2 = new Date event.startTime
#
#      event

      scope.eventRecordTypes = [
        {type: '60minutes', name: '60分钟事件记录'}
        {type: 'hour', name: '小时事件记录'}
        {type: 'day', name: '今日事件记录'}
        {type: 'week', name: '本周事件记录'}
        {type: 'month', name: '本月事件记录'}
        {type: 'year', name: '本年事件记录'}
      ]
      scope.eventRecordType = scope.eventRecordTypes[2]

      scope.selectEventRecordType=(type = scope.eventRecordType) ->
        scope.eventRecordType = type

      getPeriod=(type = scope.eventRecordType) ->
        switch type.type
          when '60minutes'
            startTime = moment().subtract 60, 'minutes'
            endTime = moment()
          when 'hour'
            startTime = moment().startOf 'hour'
            endTime = moment().endOf 'hour'
          when 'day'
            startTime = moment().startOf 'day'
            endTime = moment().endOf 'day'
          when 'week'
            startTime = moment().startOf 'week'
            endTime = moment().endOf 'week'
          when 'month'
            startTime = moment().startOf 'month'
            endTime = moment().endOf 'month'
          when 'year'
            startTime = moment().startOf 'year'
            endTime = moment().endOf 'year'
          else
            startTime = moment().subtract 60, 'minutes'
            endTime = moment()

        scope.period =
          startTime: startTime
          endTime: endTime
          type: type.type

      nextPeriod= () ->
        if not scope.period
          return getPeriod()

        switch scope.period.type
          when '60minutes'
            startTime = scope.period.endTime
            endTime = moment(scope.period.endTime).add(60, 'minutes')
          when 'hour'
            startTime = moment(scope.period.startTime).add(1, 'hour').startOf 'hour'
            endTime = moment(scope.period.startTime).add(1, 'hour').endOf 'hour'
          when 'day'
            startTime = moment(scope.period.startTime).add(1, 'day').startOf 'day'
            endTime = moment(scope.period.startTime).add(1, 'day').endOf 'day'
          when 'week'
            startTime = moment(scope.period.startTime).add(1, 'week').startOf 'week'
            endTime =moment(scope.period.startTime).add(1, 'week').endOf 'week'
          when 'month'
            startTime = moment(scope.period.startTime).add(1, 'month').startOf 'month'
            endTime = moment(scope.period.startTime).add(1, 'month').endOf 'month'
          when 'year'
            startTime = moment(scope.period.startTime).add(1, 'year').startOf 'year'
            endTime = moment(scope.period.startTime).add(1, 'year').endOf 'year'
          else
            startTime = scope.period.endTime
            endTime = moment(scope.period.endTime).add(60, 'minutes')

        scope.period =
          startTime: startTime
          endTime: endTime
          type: scope.period.type

      previousPeriod= () ->
        if not scope.period
          return getPeriod()

        switch scope.period.type
          when '60minutes'
            startTime = moment(scope.period.startTime).subtract(60, 'minutes')
            endTime = scope.period.startTime
          when 'hour'
            startTime = moment(scope.period.startTime).subtract(1, 'hour').startOf 'hour'
            endTime = moment(scope.period.startTime).subtract(1, 'hour').endOf 'hour'
          when 'day'
            startTime = moment(scope.period.startTime).subtract(1, 'day').startOf 'day'
            endTime = moment(scope.period.startTime).subtract(1, 'day').endOf 'day'
          when 'week'
            startTime = moment(scope.period.startTime).subtract(1, 'week').startOf 'week'
            endTime =moment(scope.period.startTime).subtract(1, 'week').endOf 'week'
          when 'month'
            startTime = moment(scope.period.startTime).subtract(1, 'month').startOf 'month'
            endTime = moment(scope.period.startTime).subtract(1, 'month').endOf 'month'
          when 'year'
            startTime = moment(scope.period.startTime).subtract(1, 'year').startOf 'year'
            endTime = moment(scope.period.startTime).subtract(1, 'year').endOf 'year'
          else
            startTime = moment(scope.period.startTime).subtract(60, 'minutes')
            endTime = scope.period.startTime

        scope.period =
          startTime: startTime
          endTime: endTime
          type: scope.period.type

      scope.eventRecords = []
      scope.queryEventRecords= (event, periodType, page = 1, pageItems = 20) =>
        switch periodType
          when 'next'
            period = nextPeriod()
          when 'previous'
            period = previousPeriod()
          when 'refresh'
            period = scope.period ? getPeriod()
          else
            period = getPeriod()

        event.getIds=()->
          return {
            user: event.user
            project: event.project
            station: event.station
            equipment: event.equipment
            event: event.event
          }

        paging =
          page: page
          pageItems: pageItems

        sorting = {}
        sorting[scope.predicate] = if scope.reverse then -1 else 1

        scope.eventRecordsParameters =
          event: event
          startTime: period.startTime
          endTime: period.endTime
          queryTime: moment()
          periodType: periodType

          paging: paging
          sorting: sorting
          predicate:"index"
          reverse:false


#        data =
#          filter: filter
#          fields: null
#          paging: paging
#          sorting: sorting

        scope.eventRecords = []
        @commonService.queryEventRecords event,period?.startTime,period?.endTime,null, (err, records, paging2) =>
          if records
            for event in records
              eventSeverity.forEach (e)=>
                event.color = e?.model?.color if event?.severity is e?.model?.severity
              scope.eventRecords.push event
  #            scope.decorateEvent event

            scope.$applyAsync()

  #        paging2?.pages = [1..paging2.pageCount]
  #        @eventRecordsParameters.paging = paging2

      updateDuration()
      scope.eventRecordsSort=(predicate)=>
        if scope.eventRecordsParameters.predicate is predicate
          scope.eventRecordsParameters.reverse = !scope.eventRecordsParameters.reverse
        else
          scope.eventRecordsParameters.predicate = predicate
          scope.eventRecordsParameters.reverse = true

      # subscribe event-statistic-directive select event
      scope.statisticLegends = {}
      scope.eventBus1?.dispose()
      scope.eventBus1 = @commonService.subscribeEventBus 'event-statistic-phase-severity', (d) =>
        for k, v of d.message.data.legends
          scope.statisticLegends[k] = v

        scope.$applyAsync()

      #选择事件类型，接收 字符串，如 'ac','system'等等
      scope.eventBus2?.dispose()
      scope.eventBus2 = @commonService.subscribeEventBus 'event-list-eventType',(msg) =>
        scope.eventType = msg.message
        scope.$applyAsync()

      #选择设备类型，接收数组 如：['environmental','ac']
      scope.eventBus3?.dispose()
      scope.eventBus3 = @commonService.subscribeEventBus 'event-list-equipmentTypes',(msg) =>
        scope.equipmentTypes = msg.message
        @commonService.publishEventBus 'event-equipment-scope-publish',true
        scope.$applyAsync()

      scope.eventBus4?.dispose()
      scope.eventBus4 = @commonService.subscribeEventBus 'search',(msg)=>
        scope.search = msg.message
        scope.$applyAsync()

      scope.eventBus5?.dispose()
      scope.eventBus5 = @commonService.subscribeEventBus 'stationId',(msg)=>
        stationId = msg.message.stationId
        return if not stationId
        subscribeStationEvent(stationId)
        scope.$applyAsync()

      scope.$watch "parameters.stationId",(stationId)=>
        return if not stationId
        subscribeStationEvent(stationId)

    dispose: (scope)->
      clearInterval(scope.timer)
      scope.eventSubscriptionArray.forEach (sub)=>
        sub.dispose()
      scope.eventBus1?.dispose()
      scope.eventBus2?.dispose()
      scope.eventBus3?.dispose()
      scope.eventBus4?.dispose()
      scope.eventBus5?.dispose()

  exports =
    EventListDirective: EventListDirective