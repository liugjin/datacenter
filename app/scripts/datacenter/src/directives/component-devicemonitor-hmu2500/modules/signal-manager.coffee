###
* File: history-signal-report
* User: Dow
* Date: 12/4/2016
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['./record-manager-base'], (base) ->
  class SignalManager extends base.RecordManagerBase
    constructor: (options, reportingService, @eventSeverities) ->
      super options, reportingService

    initialize: (callback) ->
      super callback

      @recordTypes = [
#        {type: '60minutes', name: '60分钟信号记录'}
        {type: 'hour', name: '小时信号记录'}
        {type: 'day', name: '今日信号记录'}
        {type: 'week', name: '本周信号记录'}
        {type: 'month', name: '本月信号记录'}
        {type: 'year', name: '本年信号记录'}
      ]

      @signalStorageModes =
        threshold: '绝对阈值'
        percentage: '百分比阈值'
        period: '存储周期'
        event: '事件触发'
        statistic: '统计数据'
        record: '远程抄表'
        communication: '通信异常'

      @selectRecordType @recordTypes[0]

    queryReport: (data, callback) ->
      @reportingService.querySignalRecords data, callback

    processRecord: (record) ->
      signal = record

      signal.eventSeverity = @eventSeverities?.getItem(signal.severity)?.model
      signal.color = signal.eventSeverity?.color

      signal.modeName = @signalStorageModes[signal.mode] ? signal.mode

      signal


  exports =
    SignalManager: SignalManager
