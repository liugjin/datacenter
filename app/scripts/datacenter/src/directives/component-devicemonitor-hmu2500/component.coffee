###
* File: component-devicemonitor-hmu2500-directive
* User: David
* Date: 2020/05/30
* Desc:
###

# compatible for node.js and requirejs
define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",
  './models/paging-model',
  './modules/signal-manager',
  './modules/event-manager',
  './modules/command-manager',
  'tripledes'
], (base, css, view, _, moment, pm, sm, em, cm, CryptoJS) ->
  class ComponentDevicemonitorHmu2500Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "component-devicemonitor-hmu2500"
      super $timeout, $window, $compile, $routeParams, commonService
      @currStation =  null
      @currEquipment = null

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.tapFlag = 'overview'
      scope.fullscreen = (element) => (
        if not element
          return

        if typeof element is 'string'
          el = angular.element element
          element = el[0]
    
        exit = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement
    
        if exit
          if document.exitFullscreen
            document.exitFullscreen()
          else if document.webkitExitFullscreen
            document.webkitExitFullscreen Element.ALLOW_KEYBOARD_INPUT
          else if document.mozExitFullScreen
            document.mozExitFullScreen()
          else if document.msExitFullscreen
            document.msExitFullscreen()
        else
          if element.requestFullscreen
            element.requestFullscreen()
          else if element.webkitRequestFullscreen
            element.webkitRequestFullscreen Element.ALLOW_KEYBOARD_INPUT
          else if element.mozRequestFullScreen
            element.mozRequestFullScreen()
          else if element.msRequestFullscreen
            element.msRequestFullscreen()
          width = $("#snap-svg-canvas").width()
          height = $("#snap-svg-canvas").height()
          twidth = scope.controller.player.engine.template.propertyValues.width
          theight = scope.controller.player.engine.template.propertyValues.height
          if width/height > twidth/theight
            xoffset = (width - twidth)/2
            yoffset = 0
          else
            xoffset = 0
            yoffset = (height - theight)
          @pan(xoffset, yoffset, scope)
      )

      @eventSeverities = scope.project?.typeModels.eventseverities
      scope.signals = @signals = null
      scope.events = @events = null
      scope.commands = @commands = null
      @project = scope.project
      scope.signalManager = @signalManager = new sm.SignalManager {}, @commonService.reportingService
      scope.eventManager = @eventManager = new em.EventManager {}, @commonService.reportingService
      scope.commandManager = @commandManager = new cm.CommandManager {}, @commonService.reportingService
      scope.searchSignal = @searchSignal = null
      scope.searchEvent = @searchEvent = null
      scope.searchCommand = @searchCommand = null
      @eventManager.eventSeverities = @eventSeverities
      @signalManager.eventSeverities = @eventSeverities
      scope.signalValues = @signalValues = null
      scope.signalSetting = @signalSetting = null
      scope.signalValue = @signalValue = null
      @$routeParams.tab = null

#      scope.testdata = () =>
#        @publishInstance?.dispose()
#        @publishInstance = @commonService.publishEventBus 'equipmentId',{equipmentId:{station:"room1",equipment:"meter10"}}

      scope.setTab = (tab, manual) ->
        tab ?= @$routeParams?.tab ? scope.equipment_tab
        return if @tab is tab
        @tab = tab
        scope.tapFlag = tab
        scope.equipment_tab = tab
        @loadTabData(tab)
      scope.signalTrend = (signalObj)=>
        @commonService.publishEventBus 'signalId',{signalId:{signal:signalObj.model.signal,name:signalObj.model.name}}
        scope.setTab("chart")

      scope.loadTabData = (tab) =>
        tab ?= @tab ? @$routeParams.tab ? scope.equipment_tab
        tab = 'signals' if !tab

        switch tab
  #        when 'overview'
  #          @loadEquipmentGraphic @equipment
          when 'signals'
            @loadSignals @currEquipment,(err,model)=>
              @subscribeSignals(@currEquipment)
#              @subscribeSignalStatistics(@currEquipment)
            ,false
          when 'events'
            @loadEvents @currEquipment,(err,model)=>
              @subscribeEvents(@currEquipment)
            , false

          when 'commands'
            @loadCommands @currEquipment,(err,model)=>
              @subscribeCommands(@currEquipment)
            , false

      scope.filterSignal = () =>
        (signal) =>
          if @signalGroup and signal.model.group isnt @signalGroup
            return false

          text = scope.searchSignal
          if not text
            return true

          # filter by id or name
          if signal.model.signal.toLowerCase().indexOf(text) >= 0
            return true
          if signal.model.name.toLowerCase().indexOf(text) >= 0
            return true

          return false

      scope.queryToExecuteCommand = (command = @command) ->
        @queryToExecuting = true

      scope.queryToCancelCommand = (command = @command) ->
        @queryToExecuting = true

      scope.selectSignal = (signal) =>
        scope.signal = @signal = signal
        # load float signal only
        @queryRecentSignalRecords signal if signal.model?.dataType is 'float'

        @querySignalRecords signal
        return true

      scope.selectEvent = (event) =>
#        return false if @event is event
        scope.event = @event = event

        @queryEventRecords event
        return true

      scope.selectCommand = (command) =>
        scope.command = @command = command

        scope.stopQueryExecuting()

        @queryCommandRecords command
        return true

      scope.selectPreviousSignal = ()->
        items = @currEquipment.signals.items
        return if not items.length

        index = items.indexOf(@signal) + 1
        return if index >= items.length

        @selectSignal items[index]

      scope.selectNextSignal = ()->
        items = @currEquipment.signals.items
        return if not items.length

        index = items.indexOf(@signal) - 1
        return if index < 0

        @selectSignal items[index]

      scope.selectPreviousEvent = ()->
        items = @currEquipment.events.items
        return if not items.length

        index = items.indexOf(@event) + 1
        return if index >= items.length

        @selectEvent items[index]

      scope.selectNextEvent = ()->
        items = @currEquipment.events.items
        return if not items.length

        index = items.indexOf(@event) - 1
        return if index < 0

        @selectEvent items[index]

      scope.selectPreviousCommand =  ()->
        items = @currEquipment.commands.items
        return if not items.length

        index = items.indexOf(@command) + 1
        return if index >= items.length

        @selectCommand items[index]

      scope.selectNextCommand = ()->
        items = @currEquipment.commands.items
        return if not items.length

        index = items.indexOf(@command) - 1
        return if index < 0

        @selectCommand items[index]

      scope.saveSignalInstance = (signal, callback) ->
        # do nothing if instance definition is same as template
        model = signal.model
        instance = signal.instance

        # update equipment signals instance definition
        signals = @currEquipment.model.signals
        signals ?= []
        @currEquipment.model.signals = signals

        id = model.signal
        data = null
        for evt in signals
          if evt.id is id
            data = evt
            break

        if data
          data.signal ?= {}
          data.signal.name = instance.name if instance.name isnt model.name
          data.signal.enable = instance.enable if instance.enable isnt model.enable

        else
          data =
            id: id
            signal: {}

          data.signal.name = instance.name if instance.name isnt model.name
          data.signal.enable = instance.enable if instance.enable isnt model.enable

          signals.push data

        @currEquipment.save (err,model)->
          callback? err,model

      scope.saveEventInstance = (event, callback) ->
        # do nothing if instance definition is same as template
        model = event.model
        instance = event.instance

        # update equipment events instance definition
        events = @currEquipment.model.events
        events ?= []
        @currEquipment.model.events = events

        id = model.event
        data = null
        for evt in events
          if evt.id is id
            data = evt
            break

        if data
          data.event ?= {}
          data.event.name = instance.name if instance.name isnt model.name
          data.event.enable = instance.enable if instance.enable isnt model.enable

        else
          data =
            id: id
            event: {}

          data.event.name = instance.name if instance.name isnt model.name
          data.event.enable = instance.enable if instance.enable isnt model.enable

          events.push data

        @currEquipment.save (err,model)->
          callback? err,model


      scope.saveCommandInstance = (command, callback) ->
  # do nothing if instance definition is same as template
        model = command.model
        instance = command.instance
        #      return if instance.name is model.name and instance.enable is model.enable

        # update equipment commands instance definition
        commands = @currEquipment.model.commands
        commands ?= []
        @currEquipment.model.commands = commands

        id = model.command
        data = null
        for evt in commands
          if evt.id is id
            data = evt
            break

        if data
          data.command ?= {}
          data.command.name = instance.name if instance.name isnt model.name
          data.command.enable = instance.enable if instance.enable isnt model.enable

        else
          data =
            id: id
            command: {}

          data.command.name = instance.name if instance.name isnt model.name
          data.command.enable = instance.enable if instance.enable isnt model.enable

          commands.push data

        @currEquipment.save (err,model)->
          callback? err,model

      scope.confirmEquipmentEvents =(equipment, forceToEnd) =>
        action = if forceToEnd then "强制结束" else "确认"
        title = "#{action}设备所有告警: #{equipment.station.model.name} / #{equipment.model.name}"
        message = "请输入备注信息："

        scope.prompt title, message, (ok, comment) =>
          return if not ok

          @confirmEquipmentEvents2 equipment, comment, forceToEnd
        , true

      scope.confirmEquipmentEvent = (event, forceToEnd) =>
        return if not event

        action = if forceToEnd then "强制结束" else "确认"
        title = "#{action}设备告警: #{event.station.model.name} / #{event.equipment.model.name} / #{event.model.name}"
        message = "请输入备注信息："

        scope.prompt title, message, (ok, comment) =>
          return if not ok

          @confirmEquipmentEvent2 event, comment, forceToEnd
        , true, event.data.comment

      scope.stopQueryExecuting = () ->
        @queryToExecuting = false
        @commandError = null

      scope.doExecuteCommand = (command = @command) =>
        # return if not scope.queryToExecuting
        if command.model.password
          @validateCommandPassword (err) =>
            return if err
            scope.stopQueryExecuting()
            @executeCommand2 command
        else
          scope.stopQueryExecuting()
          @executeCommand2 command

        # require password validation

      scope.doCancelCommand = (command = @command) =>
        return if not scope.queryToExecuting

        # require password validation
        if command.model.password
          @validateCommandPassword (err) =>
            return if err

            scope.stopQueryExecuting()
            @cancelCommand2 command
        else
          scope.stopQueryExecuting()
          @cancelCommand2 command


      scope.setTab null, true

      scope.sortDataVal = (item)->
        if _.isEmpty item.data
          return 0
        else
         return 1

      @subStationEquipId?.dispose()
      @subStationEquipId = @commonService.subscribeEventBus 'equipmentId', (d)=>
        @resetEquipment()
        if d
          if  d.message.equipmentId.station
            stationResult =  _.filter scope.project.stations.items,(item)->
              return item.model.station ==  d.message.equipmentId.station

            if stationResult.length > 0
              @currStation = stationResult[0]
              filter = scope.project.getIds()
              filter.equipment =  d.message.equipmentId.equipment
              @currStation.loadEquipments filter,null,(err,equipDatas)=>
                if equipDatas
                  scope.currEquipment = @currEquipment = equipDatas[0]
                  scope.loadTabData scope.equipment_tab
#                  @updateDuration(scope)

    confirmEquipmentEvent2: (event, comment, forceToEnd) ->
      # this may end 0...* active events belongs to this event
      data = event.getIds()

      @confirmData data, comment, forceToEnd

      # event may have multiple active events so that use confirm all event command
      @commonService.eventLiveSession.confirmAllEvents data

    confirmData: (data, comment, forceToEnd) ->
      data.operator = @$window.$controller.$rootScope.user.user
      data.operatorName = @$window.$controller.$rootScope.user.name
      data.confirmTime = new Date
      data.comment = comment
      data.forceToEnd = forceToEnd

      data

    confirmEquipmentEvents2: (equipment, comment, forceToEnd) ->
      # this may end 0...* active events belongs to this event
      data = equipment.getIds()

      @confirmData data, comment, forceToEnd
       # event may have multiple active events so that use confirm all event command
      @commonService.eventLiveSession.confirmAllEvents data

    executeCommand2: (command, comment) ->
      model = command.model

      parameters = command.getParameterValues()

      data = command.getIds()
      #      data._id = model._id
      data.priority = model.priority
      data.phase = 'executing'
      data.parameters = parameters
      data.startTime = new Date
      data.endTime = null
      data.result = null
      data.trigger = 'user'
      data.operator =  @$window.$controller.$rootScope.user.user
      data.operatorName = @$window.$controller.$rootScope.user.name
      data.comment = comment ? model.comment

      @commonService.commandLiveSession.executeCommand data

    cancelCommand2: (command, comment) ->
      return if not command._data

      data = {}
      for k, v of command._data
        data[k] = v

      data.phase = 'cancel'
      data.trigger = 'user'
      data.endTime = new Date
      data.operator = @$window.$controller.$rootScope.user.user
      data.operatorName = @$window.$controller.$rootScope.user.name
      data.comment = comment ? command.model.comment

      @commonService.commandLiveSession.executeCommand data

    resetEquipment: ->
      @currProperties = null
      @currSignals = null
      @currEvents = null
      @currCommands = null
      @currEquipment = null

      @activeEvents = {}
      @equipmentStatistic = null


    loadSignals: (equipment = @equipment,callback, refresh) ->
#      return callback? null, @signals if not refresh and @signals

      return callback 'null equipment' if not equipment

      # initialize event instance definition
      instances = {}
      signals = equipment.model.signals
      if signals
        for sgl in signals
          instances[sgl.id] = sgl.signal
      equipment.signalInstances = instances

      fields = null
      equipment.loadSignals fields, (err, model) =>
        @signals = model

        if model
          for signal in model
            @initializeSignal signal, equipment

        callback? err, model
      , refresh

    loadEvents: (equipment = @equipment,callback, refresh) ->
#      return callback? null, @events if not refresh and @events
      return callback 'null equipment' if not equipment

      # initialize event instance definition
      instances = {}
      events = equipment.model.events
      if events
        for evt in events
          instances[evt.id] = evt.event
      equipment.eventInstances = instances

      # load template events
      fields = null
      equipment.loadEvents fields, (err, model) =>
        @events = model

        # initialize event instance
        if model
          for event in model
            @initializeEvent event, equipment

        callback? err, model
      , refresh

    loadCommands: (equipment = @equipment,callback, refresh) ->
      return callback 'null equipment' if not equipment

      # initialize command instance definition
      instances = {}
      commands = equipment.model.commands
      if commands
        for cmd in commands
          instances[cmd.id] = cmd.command
      equipment.commandInstances = instances

      # load commands
      fields = null
      equipment.loadCommands fields, (err, model) =>
        @commands = model

        # initialize event instance
        if model
          for command in model
            @initializeCommand command, equipment

        callback? err, model
      , refresh


    initializeSignal: (signal, equipment = @equipment) ->
      # initialize signal instance
      instance = equipment.signalInstances[signal.model.signal] ? {}
      instance.name ?= signal.model.name
      instance.enable ?= signal.model.enable

      signal.instance = instance

      # binding unit
      signal.unit = @project.typeModels.signaltypes.getItem(signal.model.unit)?.model

    initializeEvent: (event, equipment = @equipment) ->
      instance = equipment.eventInstances[event.model.event] ? {}
      instance.name ?= event.model.name
      instance.enable ?= event.model.enable

      event.instance = instance

    initializeCommand: (command, equipment = @equipment) ->
      instance = equipment.commandInstances[command.model.command] ? {}
      instance.name ?= command.model.name
      instance.enable ?= command.model.enable

      command.instance = instance

    subscribeSignals: (equipment) =>
      # to avoid repeat subscription
      return if not equipment or @equipmentOfSignalsSubscription is equipment
      @equipmentOfSignalsSubscription = equipment
      #equipment.signals.predicate = "data.value"
#      equipment.signals.predicate = "data.timestamp"
      equipment.signals.predicate = "data.severity"
      equipment.signals.reverse = true
      model = equipment.model

      filter =
        user: model.user
        project: model.project
        station: model.station
        equipment: model.equipment

      # keep one subscription only
      @signalSubscription?.dispose()

      @signalSubscription = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        #        console.log err ? d
        return if not d

        signal = @project.getSignalByTopic d.topic
        if signal
          signal.setValue d.message
          @processSignalData signal.data
#          @deviceModel?.updateSignal signal

          # update signal chart
          if signal is @signal
            @signalValue = d.message

    processSignalData: (data) =>
      severity = @eventSeverities.getItem(data.severity)?.model
      if not severity
        data.color = if data.severity < 0 then 'grey' else 'green'
        data.tooltip = data.severity
        data.newFormatValue = if data.severity== -1 then '' else data.formatValue
      else
        data.color = severity.color ? ((severity.severity) < 0 && 'grey' || 'green')
        data.tooltip = "#{severity.name}(#{severity.severity})"
        data.newFormatValue =  data.formatValue

      data.eventSeverity = severity


    updateDuration: (scope)=>
      scope.timer = setInterval ()=>
        if @activeEvents
          for key, startEvent of @activeEvents when not startEvent.data.endTime
            event = startEvent.data
            event.duration = new Date() - event.startTime2
            progress = (event.duration / @eventExpectedDuration * 100).toFixed(1)
            event.progress = "#{progress}%"
        scope.$applyAsync()
      , 1000

    subscribeSignalStatistics: (equipment = @equipment) =>
      # to avoid repeat subscription
      return if not equipment or @equipmentOfSignalStatisticsSubscription is equipment
      @equipmentOfSignalStatisticsSubscription = equipment

      model = equipment.model

      filter =
        user: model.user
        project: model.project
        station: model.station
        equipment: model.equipment

      # keep one subscription only
      @signalStatisticSubscription?.dispose()
      @signalStatisticSubscription = @commonService.signalStatisticLiveSession.subscribeValues filter, (err, d) =>
#        console.log err ? d
        return if not d

        # topic is suffix with minute/hour/day/year
        topic = d.topic.substr 0, d.topic.lastIndexOf('/')
        signal = @project.getSignalByStatisticTopic topic
        if signal
          signal.statistics ?= {}

          data = d.message
          signal.statistics[data.mode] = data

    subscribeEvents: (equipment = @equipment) ->
# to avoid repeat subscription
      return if not equipment or @equipmentOfEventsSubscription is equipment
      @equipmentOfEventsSubscription = equipment
      equipment.events.predicate = "data.startValue"
      equipment.events.reverse = false
      model = equipment.model

      filter =
        user: model.user
        project: model.project
        station: model.station
        equipment: model.equipment

      @eventSubscription?.dispose()
      @eventSubscription = @commonService.eventLiveSession.subscribeValues filter, (err, d) =>
        return if not d

        event = @project.getEventByTopic d.topic
        if event
          event.setValue d.message
          @processEventData event.data
          @processActiveEvent event
#          @deviceModel?.updateEvent event

          # update event records
#          @eventRecords.addItem event.data

    processEventData: (event) ->
# for event display
      event.updateTime = event.endTime ? event.confirmTime ? event.startTime
      event.eventSeverity = @eventSeverities.getItem(event.severity)?.model
      event.color = event.eventSeverity?.color ? 'grey'
      event.tooltip = "#{event.eventSeverity?.name ? '正常状态'} #{event.phase}"

      endTime = if event.endTime then new Date(event.endTime) else new Date
      event.duration = endTime - new Date(event.startTime)
      event.startTime2 = new Date event.startTime

    processActiveEvent: (event) ->
# maintain active event list
      id = event.model._id
      if event.phase is 'completed'
        delete @activeEvents[id]
      else
        @activeEvents[id] = event

      # count equipment severity
      count = 0
      severity = -1
      for id, evt of @activeEvents
        count++
        if severity < evt.data.severity
          severity = evt.data.severity

          eventSeverity = evt.data.eventSeverity

      @equipmentStatistic =
        severity: eventSeverity
        count: count

      return


    subscribeCommands: (equipment = @equipment) ->
# to avoid repeat subscription
      return if not equipment or @equipmentOfCommandsSubscription is equipment
      @equipmentOfCommandsSubscription = equipment

      model = equipment.model

      filter =
        user: model.user
        project: model.project
        station: model.station
        equipment: model.equipment

      @oneSubscription?.dispose()
      @oneSubscription = @commonService.commandLiveSession.subscribeValues filter, (err, d) =>
#        console.log err ? d
        return if not d

        command = @project.getCommandByTopic d.topic
        if command
          command.setValue d.message

          # update command records
#          @commandRecords.addItem command.data

    queryRecentSignalRecords: (signal) ->
      return if not signal
      filter = signal.getIds()

      # query last 20 points
      paging =
        page: 1
        pageItems: 20

      sorting = timestamp: -1

      @parameters =
        filter: filter

#        startTime: period.startTime
#        endTime: period.endTime
        queryTime: moment()
#        periodType: periodType

        paging: paging
        sorting: sorting

      data =
        filter: filter
        fields: null
        paging: paging
        sorting: sorting


      #      endTime = moment()
      #      startTime = moment().subtract 5, 'minutes'
      #
      #      filter.startTime = startTime
      #      filter.endTime = endTime

      @signalRecordsParameters =
        signal: signal
        queryTime: new Date

      @signalValues = null
      @signalSetting = null
      @signalValue = null

      @commonService.reportingService.querySignalGroupRecords data, (err, records) =>
# what if return empty records
        if records.hasOwnProperty(signal.key)
# composite color
          for key, record of records
            for s in record.values
              @processSignalData s
          @signalValues = records
        else
          m = signal.model
          svs = {}
          svs[signal.key] =
            user: m.user
            project: m.project
            station: m.station
            equipment: m.equipment
            signal: m.signal
            values: []
          @signalValues = svs

        title = "实时数据曲线 / #{signal.model.name}"
        title = "#{title}(#{signal.unit.unit})" if signal.unit?.unit

        @signalSetting =
          title: title
#          subTitle: "查询时间段: #{startTime.format('YYYY-MM-DD HH:mm:ss')} ~ #{endTime.format('YYYY-MM-DD HH:mm:ss')}"
          yScale: @yScale

    querySignalRecords: (signal) =>
      @signalManager.queryRecords signal

    queryEventRecords: (event) ->
      @eventManager.queryRecords event

    queryCommandRecords: (command) ->
      @commandManager.queryRecords command


    processCommandData: (data) ->
      parameters = {}
      parameters3 = ''
      if data.parameters
        for p in data.parameters
          parameters[p.key] = p.value
          parameters3 += "#{p.key}=#{p.value}; "
      #      data.parameters = parameters
      data.parameters3 = parameters3

      if data.trigger is 'user'
        data.triggerName = data.operatorName
      else
        data.triggerName = data.trigger

      data

    clearSignalRecords: () ->
      @signalRecords.setItems []
      @signalRecordsParameters = {}

    clearEventRecords: () ->
      @eventRecords.setItems []
      @eventRecordsParameters = {}

    clearCommandRecords: () ->
      @commandRecords.setItems []
      @commandRecordsParameters = {}

    loadEquipmentGraphic: (equipment = @equipment, refresh) ->
      return if not equipment

      #      graphic = equipment.model.graphic ? equipment.equipmentTemplate?.model.graphic
      graphic = equipment.getTemplateValue 'graphic'

      if graphic
        templateId =
          user: @$routeParams.user
          project: @$routeParams.project
# reference to equipment template graphic
          template: graphic

        templateId.timestamp = new Date if refresh

        @templateId = templateId
      else
        @templateId = null

      @directive = equipment.getTemplateValue 'directive'

    connect: (data, callback) ->
      @connectService ?= @modelManager.getService 'connect'
      url = @connectService.getUrl data

      @connectService.postData url, data, callback

    filterEquipment: () ->
      (equipment) =>
        if @group and equipment.model.group isnt @group
          return false

        text = @search
        if not text
          return true

        # filter by id or name
        if equipment.model.equipment.toLowerCase().indexOf(text) >= 0
          return true
        if equipment.model.name.toLowerCase().indexOf(text) >= 0
          return true

        return false

    selectSignalGroup: (group) ->
      @signalGroup = group

    filterEvent: () ->
      (event) =>
        if @eventGroup and event.model.group isnt @eventGroup
          return false

        text = @searchEvent
        if not text
          return true

        # filter by id or name
        if event.model.event.toLowerCase().indexOf(text) >= 0
          return true
        if event.model.name.toLowerCase().indexOf(text) >= 0
          return true

        return false

    selectEventGroup: (group) ->
      @eventGroup = group

    filterCommand: () ->
      (command) =>
        if @commandGroup and command.model.group isnt @commandGroup
          return false

        text = @searchCommand
        if not text
          return true

        # filter by id or name
        if command.model.command.toLowerCase().indexOf(text) >= 0
          return true
        if command.model.name.toLowerCase().indexOf(text) >= 0
          return true

        return false

    selectCommandGroup: (group) ->
      @commandGroup = group

    validateCommandPassword: (callback) ->
      if @password
        authService = @modelManager.getService 'validatePassword'

        username = @$rootScope.user.user
        data =
          username: username
          password: @encrypt @password, username
        #          password: @password

        authService.get data, (err, result) =>
          @commandError = if err or not result?.token then '密码验证失败，请重新输入有效用户密码！' else null
          callback? @commandError
      else
        @commandError = "请输入有效用户密码！"
        callback? @commandError

    encrypt: (value, key) ->
      encryptedValue = CryptoJS.DES.encrypt(value, key).toString()

    decrypt: (encryptedValue, key) ->
      value = CryptoJS.DES.decrypt encryptedValue, key
      value = CryptoJS.enc.Utf8.stringify value

    moreMessage: () ->
      @isMore = !@isMore
      if @isMore
        @info = '隐藏信息'
      else
        @info = '更多信息'


    saveValue: (value) ->
      @oldValue = value

    checkValue: (value) ->
      if @oldValue is value
        return
      else
        @saveEquipment()

    setYScale: () ->
      setting = {}
      for k, v of @signalSetting
        setting[k] = v
      setting.yScale = @yScale

      @signalSetting = setting

      @modelEngine.storage.set 'yScale', @yScale
    resize: (scope)->
      @$timeout =>
#        console.log $("#graphicparamter").width()
        if $("#graphicparamter").width() > 1600
          $("component-devicemonitor .graphic-height-equipment .box-content").css("height","94vh")
        else
          $("component-devicemonitor .graphic-height-equipment .box-content").css("height","")
      ,0
    dispose: (scope)->
      @subStationEquipId?.dispose()
      @signalSubscription?.dispose()
      @signalManager.dispose()
      @eventManager.dispose()
      @commandManager.dispose()
      clearInterval(scope.timer)

    sortFunction = (a,b)->
      sortList = ['ups','空调','机柜']
      aIndex = sortList.indexOf(a.name)
      bIndex = sortList.indexOf(b.name)
      if aIndex==-1
        aIndex = 999
      if bIndex==-1
        bIndex = 999
      if aIndex < bIndex
        return -1
      else if aIndex > bIndex
        return 1
      else if aIndex == bIndex
        return 0
    pan: (dx, dy, scope) ->
      setTimeout =>
        scope.controller.player.renderer?.transformControl?.pan(dx, dy)
      ,800
  exports =
    ComponentDevicemonitorHmu2500Directive: ComponentDevicemonitorHmu2500Directive