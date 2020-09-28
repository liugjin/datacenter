###
* File: history-event-report
* User: Dow
* Date: 12/4/2016
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['./record-manager-base'], (base) ->
  class EventManager extends base.RecordManagerBase
    constructor: (options, reportingService, @eventSeverities) ->
      super options, reportingService

    initialize: (callback) ->
      super callback

      @recordTypes = [
#        {type: '60minutes', name: '60分钟事件记录'}
        {type: 'hour', name: '小时事件记录'}
        {type: 'day', name: '今日事件记录'}
        {type: 'week', name: '本周事件记录'}
        {type: 'month', name: '本月事件记录'}
        {type: 'year', name: '本年事件记录'}
      ]

      @selectRecordType @recordTypes[1]

    queryReport: (data, callback) ->
      @reportingService.queryEventRecords data, callback

    processRecord: (record) ->
      event = record

      event.updateTime = event.endTime ? event.confirmTime ? event.startTime
      event.eventSeverity = @eventSeverities?.getItem(event.severity)?.model
      event.color = event.eventSeverity?.color ? @endColor

      endTime = if event.endTime then new Date(event.endTime) else new Date
      event.duration = endTime - new Date(event.startTime)
      event.startTime2 = new Date event.startTime

      event


  exports =
    EventManager: EventManager
