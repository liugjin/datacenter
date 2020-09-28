###
* File: command-manager
* User: Dow
* Date: 12/4/2016
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['./record-manager-base'], (base) ->
  class CommandManager extends base.RecordManagerBase
    constructor: (options, reportingService) ->
      super options, reportingService

    initialize: (callback) ->
      super callback

      @recordTypes = [
#        {type: '60minutes', name: '60分钟控制记录'}
        {type: 'hour', name: '小时控制记录'}
        {type: 'day', name: '今日控制记录'}
        {type: 'week', name: '本周控制记录'}
        {type: 'month', name: '本月控制记录'}
        {type: 'year', name: '本年控制记录'}
      ]

      @selectRecordType @recordTypes[1]

    queryReport: (data, callback) ->
      @reportingService.queryCommandRecords data, callback

    processRecord: (record) ->
      command = record

      parameters = {}
      parameters3 = ''
      if command.parameters
        for p in command.parameters
          parameters[p.key] = p.value
          parameters3 += "#{p.key}=#{p.value}; "
      #      command.parameters = parameters
      command.parameters3 = parameters3

      if command.trigger is 'user'
        command.triggerName = command.operatorName
      else
        command.triggerName = command.trigger

      command


  exports =
    CommandManager: CommandManager
