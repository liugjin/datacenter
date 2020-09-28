###
* File: signal-configuration-directive
* User: David
* Date: 2020/05/09
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "rx"], (base, css, view, _, moment, Rx) ->
  class SignalConfigurationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "signal-configuration"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @projectId = scope.project.model.project
      @userId = scope.project.model.user
      @token = scope.controller.$rootScope.user.token
      @host = @$window.origin
      @Rx = new Rx.Subject
      @equipment = {} # 当前选中的设备
      @stations = scope.project.stations.items
      scope.btnActive = "sample"
      scope.searchShow = false
      scope.sampleEvents = [] # 采集信号告警集合
      scope.alarmEvents = [] # 告警信号告警集合
      scope.statusEvents = [] # 状态信号告警集合
      scope.selectEventseverities = scope.project.dictionary.eventseverities.items
      @Rx.debounce(100).subscribe(() =>
        @display("操作成功")
      )
      @init(scope)

      # 修改事件信息时,让当前事件的复选框打钩
      scope.tickCheckBox = (event) => (
        event.eventInfo.checked = true
      )

      # 搜索功能
      scope.filterEvent = ()=> (
        (event) =>
          if scope.severity and event.severity isnt scope.severity
            return false
          text = scope.searchLists?.toLowerCase()
          if not text
            return true
          if event.model.name.toLowerCase().indexOf(text) >= 0
            return true
          return false
      )

      # 保存按钮
      scope.save = () => (
        return @display("请选择设备") if _.isEmpty(@equipment)
        events = @equipment.events.items
        judgeExecute = _.find(events, (event)=> event.eventInfo.checked == true)
        return @display("当前无更改的信号") if _.isEmpty(judgeExecute)
        stationId = @equipment.station.model.station
        stationName = @equipment.station.model.name
        equipmentName =@equipment.model.name
        equipmentId = @equipment.model.equipment
        typeId = @equipment.model.type
        equipmentTemplateId = @equipment.model.template # 设备模板ID
        stationEquip = "#{stationId}_#{equipmentId}" # 当前的站点ID+设备ID,用来判断他的设备模板是否和他相同
        if(equipmentTemplateId == stationEquip) # 不是首次添加设备模板,这里直接修改事件
          @changeSampleEvents(scope, equipmentTemplateId, typeId)
          @changeAlarmEvents(scope, equipmentTemplateId, typeId)
          @changeStatusEvents(scope, equipmentTemplateId, typeId)
        else # 创建设备模板
          postObj = {
            base: "#{typeId}.#{equipmentTemplateId}",
            name: "#{stationName}_#{equipmentName}",
            token: @token,
            vendor: @equipment.equipmentTemplate.model.vendor
          }
          @commonService.modelEngine.modelManager.$http.post("#{@host}/model/clc/api/v1/equipmenttemplates/#{@userId}/#{@projectId}/meter/#{stationEquip}", postObj).then((res) =>
            @equipment.model.template = stationEquip
            @equipment.save()
            @changeSampleEvents(scope, stationEquip, typeId)
            @changeAlarmEvents(scope, stationEquip, typeId)
            @changeStatusEvents(scope, stationEquip, typeId)
          )
      )

    # 通过HTTP请求添加或修改设备事件
    postChangeEvent: (typeId, equipmentTemplateId, event, postObj) => (
      @commonService.modelEngine.modelManager.$http.post(
        "#{@host}/model/clc/api/v1/equipmentevents/#{@userId}/#{@projectId}/#{typeId}/#{equipmentTemplateId}/#{event.model.event}",
        postObj).then((res) =>
        event.eventInfo.checked = false # 取消复选框打钩状态
        @Rx.onNext()
      )
    )

    # 修改告警名称
    changeAlarmName: (scope, event) => (
      eventName = event.model.name
      if event.eventInfo.name
        eventName = event.eventInfo.name
        event.model.name = event.eventInfo.name
      return eventName
    )

    # 告警信号配置
    changeAlarmEvents: (scope, equipmentTemplateId, typeId) => (
      _.each(scope.alarmEvents, (alarmEvent) =>
        if(alarmEvent.eventInfo.checked)
          eventName = @changeAlarmName(scope, alarmEvent) # 告警名字
          rule = alarmEvent.model.rules[0]
          rule.severity = Number(alarmEvent.eventInfo.severity)
          alarmEvent.eventInfo.eventName = (_.find(scope.selectEventseverities, (e)-> e.model.severity == Number(alarmEvent.eventInfo.severity))).model.name
          alarmPostObj = {
            _id: alarmEvent.model._id
            name: eventName,
            token: @token,
            group: "alarm",
            expression: {
              variables: alarmEvent.model.expression.variables
            },
            rules: [ rule ]
          }
          @postChangeEvent(typeId, equipmentTemplateId, alarmEvent, alarmPostObj)
      )
    )

    # 状态信号配置
    changeStatusEvents: (scope, equipmentTemplateId, typeId) => (
      _.each(scope.statusEvents, (statusEvent) =>
        if(statusEvent.eventInfo.checked)
          eventName = @changeAlarmName(scope, statusEvent)
          rule = statusEvent.model.rules[0]
          rule.severity = Number(statusEvent.eventInfo.severity)
          statusEvent.eventInfo.eventName = (_.find(scope.selectEventseverities, (e)-> e.model.severity == Number(statusEvent.eventInfo.severity))).model.name
          statusEvent.eventInfo.condition.name = (_.find(statusEvent.eventInfo.formatSelect, (f) -> f.id == rule.start.condition.values )).name
          statusPostObj = {
            _id: statusEvent.model._id
            name: eventName,
            token: @token,
            enable: statusEvent.model.enable, # 绑定是否设为告警
            group: "status",
            expression: {
              variables: statusEvent.model.expression.variables
            },
            rules: [ rule ]
          }
          @postChangeEvent(typeId, equipmentTemplateId, statusEvent, statusPostObj)
      )
    )

    # 采集信号配置
    changeSampleEvents: (scope, equipmentTemplateId, typeId) => (
      _.each(scope.sampleEvents, (sampleEvent)=>
        if(sampleEvent.eventInfo.checked)
          return @display("采集信号的阈值必须填入数字") if isNaN(sampleEvent.eventInfo.inputOverLimit) || isNaN(sampleEvent.eventInfo.inputLowLimit)
          variables = sampleEvent.model.expression.variables[0]
          eventName = @changeAlarmName(scope, sampleEvent)
          rules = sampleEvent.model.rules
          overRule = _.find(rules, (rule)=> rule.start.condition.operator == ">" || rule.start.condition.operator == ">=") # 超限阈值
          lowRule = _.find(rules, (rule)=> rule.start.condition.operator == "<" || rule.start.condition.operator == "<=") # 低限阈值

          overRule.severity = Number(sampleEvent.eventInfo.overSeverity) # 超限等级修改
          sampleEvent.eventInfo.overEventName = (_.find(scope.selectEventseverities, (item)-> item.model.severity == overRule.severity)).model.name
          sampleEvent.eventInfo.lowEventName = (_.find(scope.selectEventseverities, (item)-> item.model.severity == lowRule.severity)).model.name
          if sampleEvent.eventInfo.inputOverLimit # 修改超限阈值
            overRule.start.condition.values = sampleEvent.eventInfo.inputOverLimit
            sampleEvent.eventInfo.overLimit = sampleEvent.eventInfo.inputOverLimit
          lowRule.severity = Number(sampleEvent.eventInfo.lowSeverity)
          if sampleEvent.eventInfo.inputLowLimit # 修改低限阈值
            lowRule.start.condition.values = sampleEvent.eventInfo.inputLowLimit
            sampleEvent.eventInfo.lowLimit = sampleEvent.eventInfo.inputLowLimit
          samplePostObj = {
            _id: sampleEvent.model._id
            name: eventName, # 采集信号名修改
            token: @token,
            group: "sample",
            expression: { variables: variables },
            rules: [overRule, lowRule]
          }
          @postChangeEvent(typeId, equipmentTemplateId, sampleEvent, samplePostObj)
      )
    )

    # 初始化函数
    init: (scope) => (
      # 订阅设备树发出来的信号
      scope.subscribeSelectEquip?.dispose()
      scope.subscribeSelectEquip = @commonService.subscribeEventBus("selectEquip", (msg)=>
        if(msg.message.level == "equipment")
          nowStation = _.find(@stations, (station) -> station.model.station == msg.message.station)
          nowStation.loadEquipment(msg.message.id, null, (err,equip)=>
            @equipment = equip
            @equipment.loadSignals(null, (err,signals)=>
              @equipment.loadEvents(null, (err,events)=>
                scope.sampleEvents = [] # 采集信号告警集合
                scope.alarmEvents = [] # 告警信号告警集合
                scope.statusEvents = [] # 状态信号告警集合
                _.each(events, (event) =>
                  event.eventInfo = {
                    checked: false, # 是否给 checkbox 选中
                    name: "" # 事件名称
                  }
                  # 采集事件信号
                  if(event.model.group == "sample")
                    _.each(event.model.rules, (rule)=>
                      _operator = rule.start.condition.operator # 符号
                      event.eventInfo.inputOverLimit = "" # 输入框里的超限阈值,默认为空
                      event.eventInfo.inputLowLimit = "" # 输入框的低限阈值,默认为空
                      if(_operator == ">" || _operator == ">=") # 超限阈值
                        event.eventInfo.overLimit = rule.start.condition.values
                        event.eventInfo.overSeverity = String(rule.severity)
                        event.eventInfo.overEventName = (_.find(scope.selectEventseverities, (e)-> e.model.severity == rule.severity)).model.name
                      else if(_operator == "<" || _operator == "<=") # 低限阈值
                        event.eventInfo.lowLimit = rule.start.condition.values
                        event.eventInfo.lowSeverity = String(rule.severity)
                        event.eventInfo.lowEventName = (_.find(scope.selectEventseverities, (e)-> e.model.severity == rule.severity)).model.name
                    )
                    scope.sampleEvents.push(event)
                  # 告警事件信号
                  else if(event.model.group == "alarm")
                    event.eventInfo.eventName = (_.find(scope.selectEventseverities, (e)-> e.model.severity == event.model.rules[0].severity)).model.name
                    event.eventInfo.severity = String(event.model.rules[0].severity)
                    scope.alarmEvents.push(event)
                  # 状态事件信号
                  else if(event.model.group == "status")
                    _nowSignal = _.find(signals, (sig) -> sig.model.signal == event.model.expression.variables[0].value)
                    event.eventInfo.formatSelect = [] # 告警条件select框
                    _rules = event.model.rules[0]
                    formatArr = (_nowSignal.model.format).split(",") # 解析枚举信号
                    _.each(formatArr, (format) =>
                      f = format.split(":")
                      obj = {
                        id: f[0],
                        name: f[1]
                      }
                      event.eventInfo.formatSelect.push(obj)
                    )
                    event.eventInfo.eventName = (_.find(scope.selectEventseverities, (e)-> e.model.severity == _rules.severity)).model.name
                    event.eventInfo.severity = String(_rules.severity)
                    event.eventInfo.condition = _.find(event.eventInfo.formatSelect, (item)-> _rules.start.condition.values == item.id)
                    scope.statusEvents.push(event)
                )
                scope.$applyAsync()
              , true)
            )
          )
      )
    )

    resize: (scope)->

    dispose: (scope)->
      scope.subscribeSelectEquip?.dispose()


  exports =
    SignalConfigurationDirective: SignalConfigurationDirective