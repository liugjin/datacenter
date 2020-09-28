###
* File: common-service
* User: David
* Date: 7/16/2018
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/services/service',
  'clc.foundation.angular/live/signal-live-session',
  'clc.foundation.angular/live/event-live-session',
  'clc.foundation.angular/live/statistic-live-session',
  'clc.foundation.angular/live/command-live-session',
  'clc.foundation.angular/live/signal-statistic-live-session',
  'clc.foundation.angular/live/configuration-live-session',
  'underscore', 'rx', 'moment'], (base, sls, els, esls, cls, ssls, confs, _, Rx, moment) ->
  class CommonService extends base.Service
    constructor: ($rootScope, $http, @modelEngine, @liveService, @reportingService, @uploadService) ->
      @signalLiveSession = new sls.SignalLiveSession @liveService
      @eventLiveSession = new els.EventLiveSession @liveService
      @eventStatisticLiveSession = new esls.StatisticLiveSession @liveService
      @commandLiveSession = new cls.CommandLiveSession @liveService
      @signalStatisticLiveSession = new ssls.SignalStatisticLiveSession @liveService
      @configurationLiveSession = new confs.ConfigurationLiveSession @liveService
      @subscriptions = {}

      @bus = new Rx.Subject
      @patterns = {}
      super $rootScope


    loadProject: (filter, fields, callback, refresh) ->
      if not refresh
        project = @$rootScope.project
        model = project?.model

        if model and model.user is filter.user and model.project is filter.project
          return callback? null, project

      @modelEngine.loadProject filter, fields, (err, project) =>
        @$rootScope.project = project
        @$rootScope.myproject = {user:project.model.user, project:project.model.project}

        # load project types definition
        n = 0
        project?.loadTypeModels (err, data)->
          n++
          callback? err, project if n is _.keys(project.typeModels).length
        ,refresh

      , refresh


    loadStations: (field, callback, refresh) ->
      @$rootScope.project?.loadStations field, (err, stations) ->
        callback err, stations
      ,refresh

    loadStationChildren: (station, includeSelf) ->
      ret = []
      ret = [station] if includeSelf
      for sta in station.stations
        ret = ret.concat @loadStationChildren sta, true
      ret

    loadStation: (stationId, callback ,refresh) ->
      @loadStations null, (err, stations) ->
        return callback err if err or stations.length<1
        station = _.find stations, (st)->st.model.station is stationId
        callback err, station
      ,refresh

    loadEquipmentById: (station, equipmentId, callback, refresh) ->
      return callback null if not station or not equipmentId
      station.loadEquipment equipmentId, null, (err, equip)->
        callback err, equip
      ,refresh

    loadEquipmentsByType: (station, typeId, callback, refresh) ->
      return callback null if not station or not typeId
      station.loadEquipments {type: typeId}, null, (err, equips) ->
        callback err, equips
      ,refresh

    loadEquipmentsByTemplate: (station, templateId, callback, refresh) ->
      return callback null if not station or not templateId
      station.loadEquipments {template: templateId}, null, (err, equips) ->
        callback err, equips
      ,refresh

    querySignalHistoryData: (signal, startTime, endTime, callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，���询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      filter = signal?.getIds()
      filter.startTime = moment(startTime) if startTime
      filter.endTime = moment(endTime) if endTime
      sorting = {timestamp: 1} if not sorting?
      @reportingService.querySignalRecords {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo)->
        callback? err, records, pageInfo

    querySignalsHistoryData: (signals, startTime, endTime, callback, paging = null, sorting = null) ->  #signals是signal对象的数组
      filter = @$rootScope.project.getIds()
      filter["$or"] = _.map signals, (sig)->return {station: sig.equipment.model.station, equipment: sig.equipment.model.equipment, signal:sig.model.signal}
      filter.startTime = moment(startTime) if startTime
      filter.endTime = moment(endTime) if endTime
      sorting = {station:1, equipment:1, signal: 1, timestamp: 1} if not sorting?
      @reportingService.querySignalGroupRecords {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo)->
        callback? err, records, pageInfo

    querySignalStatisticData: (signal, startTime, endTime, mode = "day", callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，查询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      filter = signal?.getIds()
      filter.mode = mode
      if mode is "year"
        filter.period = {$gte:moment(startTime).format("YYYY"), $lt:moment(endTime).format("YYYY-MM")}
      else if mode is "month"
        filter.period = {$gte:moment(startTime).format("YYYY-MM"), $lt:moment(endTime).format("YYYY-MM-DD")}
      else if mode is "day"
        filter.period = {$gte:moment(startTime).format("YYYY-MM-DD"), $lt:moment(endTime).format("YYYY-MM-DD HH")}
      else if mode is "hour"
        filter.period = {$gte:moment(startTime).format("YYYY-MM-DD HH"), $lt:moment(endTime).format("YYYY-MM-DD HH:mm")}
      sorting = {timestamp: 1} if not sorting?
      @reportingService.querySignalStatistics {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo) ->
        callback? err, records, pageInfo

    querySignalsStatisticData: (signals, startTime, endTime, mode = "day", callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，查询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      return callback? "no signals" if not signals or signals.length < 1
      filter = @$rootScope.project.getIds()
      filter["$or"] = _.map signals, (sig)->return {station: sig.equipment.model.station, equipment: sig.equipment.model.equipment, signal:sig.model.signal}
      filter.mode = mode
      if mode is "year"
        filter.period = {$gte:moment(startTime).format("YYYY"), $lt:moment(endTime).format("YYYY-MM")}
      else if mode is "month"
        filter.period = {$gte:moment(startTime).format("YYYY-MM"), $lt:moment(endTime).format("YYYY-MM-DD")}
      else if mode is "day"
        filter.period = {$gte:moment(startTime).format("YYYY-MM-DD"), $lt:moment(endTime).format("YYYY-MM-DD HH")}
      else if mode is "hour"
        filter.period = {$gte:moment(startTime).format("YYYY-MM-DD HH"), $lt:moment(endTime).format("YYYY-MM-DD HH:mm")}
      sorting = {station:1, equipment:1, signal:1,timestamp: 1} if not sorting?
      @reportingService.querySignalStatistics {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo) ->
        callback? err, records, pageInfo

    queryEventRecords: (event, startTime, endTime, severity, callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，查询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      filter = event?.getIds()
      filter.startTime = moment(startTime).startOf "day" if startTime
      filter.endTime = moment(endTime).endOf "day" if endTime
      filter.severity = severity if severity
      sorting = {startTime: 1} if not sorting?
      @reportingService.queryEventRecords {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo) ->
        callback? err, records, pageInfo

    queryEventsRecords: (events, startTime, endTime, severity, callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，查询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      return callback? "no signals" if not signals or signals.length < 1
      filter = @$rootScope.project.getIds()
      filter["$or"] = _.map events, (evt)->return {station: evt.equipment.model.station, equipment: evt.equipment.model.equipment, event:evt.model.event}
      filter.startTime = moment(startTime).startOf "day" if startTime
      filter.endTime = moment(endTime).endOf "day" if endTime
      filter.severity = severity if severity
      sorting = {station:1, equipment:1, event:1, startTime: 1} if not sorting?
      @reportingService.queryEventRecords {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo) ->
        callback? err, records, pageInfo

    queryCommandRecords: (command, startTime, endTime, callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，查询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      filter = command?.getIds()
      filter.startTime = moment(startTime).startOf "day" if startTime
      filter.endTime = moment(endTime).endOf "day" if endTime
      sorting = {startTime: 1} if not sorting?
      @reportingService.queryCommandRecords {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo) ->
        callback? err, records, pageInfo

    queryCommandsRecords: (commands, startTime, endTime, callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，查询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      return callback? "no signals" if not signals or signals.length < 1
      filter = @$rootScope.project.getIds()
      filter["$or"] = _.map commands, (cmd)->return {station: cmd.equipment.model.station, equipment: cmd.equipment.model.equipment, command:cmd.model.command}
      filter.startTime = moment(startTime).startOf "day" if startTime
      filter.endTime = moment(endTime).endOf "day" if endTime
      sorting = {station:1, equipment:1, command:1, startTime: 1} if not sorting?
      @reportingService.queryCommandRecords {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo) ->
        callback? err, records, pageInfo

    queryEquipmentEventRecords: (equipment, startTime, endTime, severity, callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，查询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      filter = equipment?.getIds()
      filter.startTime = moment(startTime).startOf "day" if startTime
      filter.endTime = moment(endTime).endOf "day" if endTime
      filter.severity = severity if severity
      sorting = {event:1, startTime: 1} if not sorting?
      @reportingService.queryEventRecords {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo) ->
        callback? err, records, pageInfo

    queryEquipmentCommandRecords: (equipment, startTime, endTime, severity, callback, paging = null, sorting = null) ->     #paging是分页查询条件，值为JSON对象，如{page:2,pageItems:50}，表示按50条记录一页来进行分页，查询第2页的内容，sorting是记录排序方式,如{equipment:1}表示按设备ID进行升序排列
      filter = equipment?.getIds()
      filter.startTime = moment(startTime).startOf "day" if startTime
      filter.endTime = moment(endTime).endOf "day" if endTime
      sorting = {command:1, startTime: 1} if not sorting?
      @reportingService.queryEventRecords {filter: filter, paging: paging, sorting: sorting}, (err, records, pageInfo) ->
        callback? err, records, pageInfo

    subscribeSignalValue: (signal, callback) ->
      return if not signal?.model?.signal
      topic = "signal-values/"+signal.model.user+"/"+signal.model.project+"/"+signal.equipment.model.station+"/"+signal.equipment.model.equipment+"/"+signal.model.signal
      if not @subscriptions[topic]?
        @subscriptions[topic] =
          count: 0
          callbacks: []
          dispose: =>
            cnt=eval("this.count")
            @subscriptions[topic]?.callbacks[cnt] = null
            @subscriptions[topic]?.count--
            if @subscriptions[topic]?.count is 0
              @subscriptions[topic].handler?.dispose()
              delete @subscriptions[topic]
      @subscriptions[topic].count++
      @subscriptions[topic].callbacks.push callback
      if not @subscriptions[topic].handler
        filter =
          user: signal.model.user
          project: signal.model.project
          station: signal.equipment.model.station
          equipment: signal.equipment.model.equipment
          signal: signal.model.signal
        @subscriptions[topic].handler = @signalLiveSession.subscribeValues filter, (err, d) =>
          signal.setValue d.message if d.topic is topic
          callback? signal for callback in @subscriptions[d.topic]?.callbacks
      else
        callback? signal
      return {count: @subscriptions[topic].count-1, dispose: @subscriptions[topic].dispose}

    subscribeEquipmentSignalValues: (equipment, callback) ->
      return if not equipment?.model?.equipment
      key = "signals_"+equipment.key
      if not @subscriptions[key]?
        @subscriptions[key] =
          count: 0
          callbacks: []
          dispose: =>
            cnt=eval("this.count")
            @subscriptions[key]?.callbacks[cnt] = null
            @subscriptions[key]?.count--
            if @subscriptions[key]?.count is 0
              @subscriptions[key].handler?.dispose()
              delete @subscriptions[key]
      @subscriptions[key].count++
      @subscriptions[key].callbacks.push callback
      if not @subscriptions[key].handler
        equipment.loadSignals null, (err, signals) =>
          filter =
            user: equipment.model.user
            project: equipment.model.project
            station: equipment.model.station
            equipment: equipment.model.equipment
          if @subscriptions[key]
            @subscriptions[key].handler?.dispose()
            @subscriptions[key].handler = @signalLiveSession.subscribeValues filter, (err, d) =>
              signal = _.find equipment.signals.items, (sig)->"signal-values/"+sig.model.user+"/"+sig.model.project+"/"+sig.equipment.model.station+"/"+sig.equipment.model.equipment+"/"+sig.model.signal is d.topic
              if signal
                signal.setValue d.message
                callback? signal for callback in @subscriptions["signals_"+signal.equipment.key]?.callbacks
      else
        signals = _.filter equipment.signals.items, (sig)->sig.data?.value?
        for signal in signals
          callback? signal
      return {count: @subscriptions[key].count-1, dispose: @subscriptions[key].dispose}

    subscribeEventValue: (event, callback) ->
      return if not event?.model?.event
      topic = "event-values/"+event.model.user+"/"+event.model.project+"/"+event.equipment.model.station+"/"+event.equipment.model.equipment+"/"+event.model.event
      if not @subscriptions[topic]?
        @subscriptions[topic] =
          count: 0
          callbacks: []
          dispose: =>
            cnt=eval("this.count")
            @subscriptions[topic]?.callbacks[cnt] = null
            @subscriptions[topic]?.count--
            if @subscriptions[topic]?.count is 0
              @subscriptions[topic].handler?.dispose()
              delete @subscriptions[topic]
      @subscriptions[topic].count++
      @subscriptions[topic].callbacks.push callback
      if not @subscriptions[topic].handler
        filter =
          user: event.model.user
          project: event.model.project
          station: event.equipment.model.station
          equipment: event.equipment.model.equipment
          event: event.model.event
        @subscriptions[topic].handler = @eventLiveSession.subscribeValues filter, (err, d) =>
          event.setValue d.message if d.topic is topic
          callback? event for callback in @subscriptions[d.topic]?.callbacks
      else
        callback? event
      return {count: @subscriptions[topic].count-1, dispose: @subscriptions[topic].dispose}

    subscribeEquipmentEventValues: (equipment, callback) ->
      return if not equipment?.model?.equipment
      key = "events_"+equipment.key
      if not @subscriptions[key]?
        @subscriptions[key] =
          count: 0
          callbacks: []
          dispose: =>
            cnt=eval("this.count")
            @subscriptions[key]?.callbacks[cnt] = null
            @subscriptions[key]?.count--
            if @subscriptions[key]?.count is 0
              @subscriptions[key].handler?.dispose()
              delete @subscriptions[key]
      @subscriptions[key].count++
      @subscriptions[key].callbacks.push callback
      if not @subscriptions[key].handler
        equipment.loadEvents null, (err, events) =>
          filter =
            user: equipment.model.user
            project: equipment.model.project
            station: equipment.model.station
            equipment: equipment.model.equipment
          if @subscriptions[key]
            @subscriptions[key].handler?.dispose()
            @subscriptions[key].handler = @eventLiveSession.subscribeValues filter, (err, d) =>
              event = _.find equipment.events.items, (evt)->"event-values/"+evt.model.user+"/"+evt.model.project+"/"+evt.equipment.model.station+"/"+evt.equipment.model.equipment+"/"+evt.model.event is d.topic
              if event
                event.setValue d.message
                callback? event for callback in @subscriptions["events_"+event.equipment.key]?.callbacks
      else
        events = _.filter equipment.events.items, (evt)->evt.data?.phase in ["start","comfirm"]
        for event in events
          callback? event
      return {count: @subscriptions[key].count-1, dispose: @subscriptions[key].dispose}

    subscribeCommandValue: (command, callback) ->
      return if not command?.model?.command
      topic = "command-values/"+command.model.user+"/"+command.model.project+"/"+command.equipment.model.station+"/"+command.equipment.model.equipment+"/"+command.model.command
      if not @subscriptions[topic]?
        @subscriptions[topic] =
          count: 0
          callbacks: []
          dispose: =>
            cnt=eval("this.count")
            @subscriptions[topic]?.callbacks[cnt] = null
            @subscriptions[topic]?.count--
            if @subscriptions[topic]?.count is 0
              @subscriptions[topic].handler?.dispose()
              delete @subscriptions[topic]
      @subscriptions[topic].count++
      @subscriptions[topic].callbacks.push callback
      if not @subscriptions[topic].handler
        filter =
          user: command.model.user
          project: command.model.project
          station: command.equipment.model.station
          equipment: command.equipment.model.equipment
          command: command.model.command
        @subscriptions[topic].handler = @commandLiveSession.subscribeValues filter, (err, d) =>
          command.setValue d.message if d.topic is topic
          callback? command for callback in @subscriptions[d.topic]?.callbacks
      else
        callback? command
      return {count: @subscriptions[topic].count-1, dispose: @subscriptions[topic].dispose}

    subscribeEquipmentCommandValues: (equipment, callback) ->
      return if not equipment?.model?.equipment
      key = "commands_"+equipment.key
      if not @subscriptions[key]?
        @subscriptions[key] =
          count: 0
          callbacks: []
          dispose: =>
            cnt=eval("this.count")
            @subscriptions[key]?.callbacks[cnt] = null
            @subscriptions[key]?.count--
            if @subscriptions[key]?.count is 0
              @subscriptions[key].handler?.dispose()
              delete @subscriptions[key]
      @subscriptions[key].count++
      @subscriptions[key].callbacks.push callback
      if not @subscriptions[key].handler
        equipment.loadCommands null, (err, commands) =>
          filter =
            user: equipment.model.user
            project: equipment.model.project
            station: equipment.model.station
            equipment: equipment.model.equipment
          if @subscriptions[key]
            @subscriptions[key].handler?.dispose()
            @subscriptions[key].handler = @commandLiveSession.subscribeValues filter, (err, d) =>
              command = _.find equipment.commands.items, (cmd)->"command-values/"+cmd.model.user+"/"+cmd.model.project+"/"+cmd.equipment.model.station+"/"+cmd.equipment.model.equipment+"/"+cmd.model.command is d.topic
              if command
                command.setValue d.message
                callback? command for callback in @subscriptions["commands_"+command.equipment.key]?.callbacks
      else
        commands = _.filter equipment.commands.items, (cmd)->cmd.data?.phase in ["complete", "error", "timeout"]
        for command in commands
          callback? command
      return {count: @subscriptions[key].count-1, dispose: @subscriptions[key].dispose}

    subscribe: (topic, callback) ->
      handler = @liveService.subscribe topic, (err, data)=>
        callback? err, data
      handler

    executeCommand: (command, comment) ->
      model = command.model
      parameters = command.getParameterValues()
      data = command.getIds()
      data.priority = model.priority
      data.phase = 'executing'
      data.parameters = parameters
      data.startTime = new Date
      data.endTime = null
      data.result = null
      data.trigger = 'user'
      data.operator = @$rootScope.user.user
      data.operatorName = @$rootScope.user.name
      data.comment = comment ? model.comment

      @commandLiveSession.executeCommand data

    cancelCommand: (command, comment) ->
      return if not command._data
      data = {}
      for k, v of command._data
        data[k] = v

      data.phase = 'cancel'
      data.trigger = 'user'
      data.endTime = new Date
      data.operator = @$rootScope.user.user
      data.operatorName = @$rootScope.user.name
      data.comment = comment ? command.model.comment

      @commandLiveSession.executeCommand data

    publishEventBus: (topic, message) ->
      @bus.onNext
        topic: topic
        message: message

    subscribeEventBus: (topic, callback, throttle) ->
      subject = @bus.where (d) =>
        @matchTopic topic, d.topic
      subject = subject.throttle throttle if throttle
      subject.subscribe callback

    matchTopic: (pattern, topic) ->
      regex = @patterns[pattern]
      if not regex
        expression = pattern.replace(/\+/g, '[^\/]+').replace(/#$/, '.+') + '$'
        regex = new RegExp expression
        @patterns[pattern] = regex
      regex.test topic

    loadProjectModelByService: (name, filter, fields, callback, refresh) ->
      filter ?= {}
      filter.user = @$rootScope.project.model.user
      filter.project = @$rootScope.project.model.project

      @loadModelByService name, filter, fields, callback, refresh

    loadModelByService: (name, filter, fields, callback, refresh) ->
      service = @modelEngine.modelManager.getService name
      service.query filter, fields, callback, refresh

    rpcGet: (method, parameters, callback) ->
      data =
        parameters: parameters
        startTime: new Date
      url = "rpc/#{method}"
      @$rootScope.loading = true
      data = @appendToken data
      @uploadService.$http.get(url, {params: data})
      .then (response) =>
        data = response.data
        if data?._err
          err = data._err.message ? data._err
        if not err and response.status isnt 200
          err = response.status
        @$rootScope.loading = false
        callback? err, data, data?._paging
      .catch (response) =>
        data = response.data
        if data?._err
          err = data._err.message ? data._err
        if not err and response.status isnt 200
          err = response.status
        @$rootScope.loading = false
        callback? err, data, data?._paging

    rpcPost: (method, parameters, callback) ->
      data =
        parameters: parameters
        startTime: new Date
      url = "rpc/#{method}"
      @$rootScope.loading = true
      data = @appendToken data
      @uploadService.$http.post(url, data)
      .then (response) =>
        data = response.data
        if data?._err
          err = data._err.message ? data._err
        if not err and response.status isnt 200
          err = response.status
        @$rootScope.loading = false
        callback? err, data, data?._paging
      .catch (response) =>
        data = response.data
        if data?._err
          err = data._err.message ? data._err
        if not err and response.status isnt 200
          err = response.status
        @$rootScope.loading = false
        callback? err, data, data?._paging

  exports =
    CommonService: CommonService
