###
* File: signal-configuration-hmu2500-directive
* User: David
* Date: 2020/06/19
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","rx"], (base, css, view, _, moment,Rx) ->
  class SignalConfigurationHmu2500Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "signal-configuration-hmu2500"
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
      @ruleOutSignals = ['device-flag','repaircout','deviceNum','online-status']
      scope.severities = _.sortBy scope.project.dictionary.eventseverities.items,(item)->item.model.severity
      scope.operatorTypes = [{ operator: null, name: " " }, { operator: "==", name: "==" }, { operator: "!=", name: "!=" }, { operator: ">", name: ">" }, { operator: ">=", name: ">=" }, { operator: "<", name: "<" }, { operator: "<=", name: "<=" }, { operator: "in", name: "in" }, { operator: "out", name: "out" }, { operator: "change", name: "change" }, { operator: "boundary", name: "boundary" }, { operator: "like", name: "like" }]
      scope.btnActive = "sample" # sample为float、int类型的信号； status为enum类型的信号；
      scope.searchShow = false
      scope.events = []
      scope.selectEventseverities = scope.project.dictionary.eventseverities.items
      @Rx.debounce(100).subscribe(() =>
        @display("操作成功")
        @loadEquipInfo(scope,@equipment.model.station,@equipment.model.equipment)
      )
      @init(scope)
      scope.getSeverityName = (severity) ->
        item = _.find scope.severities, (item)->item.model.severity is severity
        item?.model.name


#---------------btnActive为sample时 配置int float类型的信号及事件，为status时配置enum类型的信号及事件--start-------------------
      # 修改事件信息时,让当前事件的复选框打钩
      scope.tickCheckBox2 = (signal) => (
        # console.log '触发编辑',signal
        signal.signalInfo.checked = true
      )

      # 搜索功能
      scope.filterSignal = ()=> (
        (signal) =>
          text = scope.searchLists?.toLowerCase()
          if not text
            return true
          if signal.model.name.toLowerCase().indexOf(text) >= 0
            return true
          if signal.model.signal.charAt(0) is '_'
            return false
          if signal.model.signal in @ruleOutSignals
            return false
      )


      # 保存按钮
      scope.save = () => (
        return @display("请选择设备") if _.isEmpty(@equipment)
        signals = scope.equipment.signals.items
        judgeExecute = _.find(signals, (signal)=> signal.signalInfo.checked == true)
        return @display("当前无更改的信号") if _.isEmpty(judgeExecute)
        stationId = @equipment.station.model.station
        stationName = @equipment.station.model.name
        equipmentName =@equipment.model.name
        equipmentId = @equipment.model.equipment
        typeId = @equipment.model.type
        equipmentTemplateId = @equipment.model.template # 设备模板ID
        stationEquip = "#{stationId}_#{equipmentId}" # 当前的站点ID+设备ID,用来判断他的设备模板是否和他相同
        if(equipmentTemplateId == stationEquip) # 不是首次添加设备模板,这里直接修改事件
#          console.log '--已有设备模板--'
          @changeSignalAndEvents(scope, equipmentTemplateId, typeId)
        else # 创建设备模板
          postObj = {
            base: "#{typeId}.#{equipmentTemplateId}",
            name: "#{stationName}_#{equipmentName}",
            token: @token,
            vendor: @equipment.equipmentTemplate.model.vendor
            graphic: @equipment.equipmentTemplate.model.graphic
            image: @equipment.image
          }
          @commonService.modelEngine.modelManager.$http.post("#{@host}/model/clc/api/v1/equipmenttemplates/#{@userId}/#{@projectId}/#{typeId}/#{stationEquip}", postObj).then((res) =>
#            console.log '--创建模板--',res
            @equipment.model.template = stationEquip
            @equipment.save()
            @changeSignalAndEvents(scope, stationEquip, typeId)
          )
      )

  # 采集信号配置
    changeSignalAndEvents: (scope, equipmentTemplateId, typeId) => (
      _.each(scope.equipment.signals.items, (signal)=>
        if(signal.signalInfo.checked)  #选中的信号在模板上创建或修改此信号 + 创建或修改此事件
#          return @display("采集信号的阈值必须填入数字") if isNaN(signal.signalInfo.inputOverLimit) || isNaN(signal.signalInfo.inputLowLimit)
#          console.log '创建或修改信号及事件'

          #-------------------------------------创建或修改信号----------------------------------------
          if signal.model.template == equipmentTemplateId  # 如果是修改新模板已有的信号 需要传_id的参数才能修改
#            console.log '----修改信号-----'
            _id = signal.model._id
            signalPostObj = {name:signal.signalInfo.name,_id:_id,token:@token}    #在已有新增信号上改直接改名称
          else
#            console.log '----新增信号---'
            signalPostObj = _.extend (angular.copy signal.model),{name:signal.signalInfo.name,token:@token}  #新增信号拿老信号的模型更新
#            console.log 'signalPostObj',signalPostObj
            delete signalPostObj._id
            delete signalPostObj._index
          @postChangeSignal(typeId, equipmentTemplateId, signal, signalPostObj)

          #-----------------------创建或修改事件--(创建/修改 sample类型信号事件；创建/修改 status类型信号事件)------
          if signal.event.model?.template == equipmentTemplateId or signal.event.model?.event == signal.model.signal  # 已有新事件模板 或基类模板有此信号事件

            if signal.signalInfo.eventType is 'sample'       # 如果是修改新模板已有的sample事件
              console.log '-----修改sample事件----'
#              _.each(signal.event.model.rules, (rule)=>
#                _operator = rule.start.condition.operator # 符号
#                if(_operator == ">" || _operator == ">=") # 超限阈值
#                  rule.title = signal.signalInfo.name + " 超限告警"
#                  rule.start.condition.values = signal.event.eventInfo.overLimit
#                  rule.severity = Number(signal.event.eventInfo.overSeverity)
#                else if(_operator == "<" || _operator == "<=") # 低限阈值
#                  rule.title = signal.signalInfo.name + " 低限告警"
#                  rule.start.condition.values = signal.event.eventInfo.lowLimit
#                  rule.severity = Number(signal.event.eventInfo.lowSeverity)
#              )
              ruleHigh =         # 告警规则不使用原来模型里面的遍历来修改而是从新定义超限和低限阈值
                title: signal.signalInfo.name + " 高告警"
                name: "1"
                severity: Number(signal.event.eventInfo.overSeverity)
                start:{condition:{operator:">",values:signal.event.eventInfo.overLimit},delay:5}
                end: {}
              ruleLow =
                title: signal.signalInfo.name + " 低告警"
                name: "2"
                severity: Number(signal.event.eventInfo.overSeverity)
                start:{condition:{operator:"<",values:signal.event.eventInfo.lowLimit},delay:5}
                end: {}
              rules = [ruleHigh,ruleLow]
              eventPostObj = _.extend (angular.copy signal.event.model),{
                createtime: ""
                updatetime: ""
                enable: signal.event.eventInfo.enable
#                rules: signal.event.model.rules
                rules: rules
                name: signal.event.eventInfo.name
                token: @token
              }
              if signal.event.model?.event == signal.model.signal and (signal.event.model?.template != equipmentTemplateId)  # 如果是新模板没有的事件就新增 如果是新模板已有的就带上_id直接修改
                delete eventPostObj._id
                delete eventPostObj._index
              console.log 'eventPostObj',eventPostObj

            else if signal.signalInfo.eventType is 'status'   # 如果是修改新模板已有的status事件
#              console.log '--修改status事件---'
              if signal.event.model?.template == equipmentTemplateId or signal.event.model?.event==signal.model.signal  #新模板已有的事件 或者事件id和信号id一样
                rule = signal.event.model.rules[0]
                rule.severity = Number(signal.event.eventInfo.severity)
                rule.title = signal.event.eventInfo.name
                rule.start.condition.operator = "=="
                rule.start.condition.values = parseInt(signal.event.eventInfo.numberLimit)
                eventPostObj = _.extend (angular.copy signal.event.model),{
                  enable: signal.event.eventInfo.enable
                  rules: [rule]
                  name: signal.event.eventInfo.name
                  token: @token
                }
                if signal.event.model?.event == signal.model.signal and (signal.event.model?.template != equipmentTemplateId)   # 如果是新模板没有的事件就新增 如果是新模板已有的就带上_id直接修改
                  delete eventPostObj._id
                  delete eventPostObj._index

          else   # 没有新事件模板     之前模板没有对此信号配告警，现在要构造事件对象保存到数据库
#            console.log '----新增事件-----'
            # 如果是sample信号事件
            if signal.signalInfo.eventType is 'sample'
              console.log '--新增sample事件---'
              ruleHigh =
                title: signal.signalInfo.name + " 高告警"
                name: "1"
                severity: Number(signal.event.eventInfo.overSeverity)
                start:{condition:{operator:">",values:signal.event.eventInfo.overLimit},delay:5}
                end: {condition:{operator:"<",values:signal.event.eventInfo.lowLimit},delay:5} #
              ruleLow =
                title: signal.signalInfo.name + " 低告警"
                name: "2"
                severity: Number(signal.event.eventInfo.overSeverity)
                start:{condition:{operator:"<",values:signal.event.eventInfo.lowLimit},delay:5}
                end: {}
              rules = [ruleHigh,ruleLow]
              eventPostObj = {
                token: @token,
                name: signal.signalInfo.name + "告警", # 事件名为新信号名+‘告警’
                event: signal.model.signal # 事件id
                expression:{
                  variables:[{key:'v1',type:'template-signal-value',value:signal.model.signal,}]
                }
                user: @$routeParams.user
                project: @$routeParams.project
                type: signal.model.type
                template: equipmentTemplateId
                enable: signal.event.eventInfo.enable
                triggerValue: 'expression'
                rules: rules
              }

            # 如果是status信号事件
            else if signal.signalInfo.eventType is 'status'
              console.log '--新增status事件---'
              eventPostObj = {
                token: @token,
                name: signal.signalInfo.name + "告警", # 事件名为新信号名+‘告警’
                event: signal.model.signal # 事件id
                name: signal.event.eventInfo.name
                expression:{
                  variables:[{key:'v1',type:'template-signal-value',value:signal.model.signal,}]
                }
                user: @$routeParams.user
                project: @$routeParams.project
                type: signal.model.type
                template: equipmentTemplateId
                triggerValue: 'expression'
                rules:[
                  {
                    title: signal.event.eventInfo.name
                    name: "1"
                    severity: Number(signal.event.eventInfo.severity)
                    start:{condition:{operator:"==",values:signal.event.eventInfo.numberLimit},delay:5}
                    end: {}
                  }
                ]
              }
            else
              console.log '只处理信号类型为int float enum的告警，当前signal为: '+ signal.model.signal
          @postChangeEvent(typeId, equipmentTemplateId, signal, eventPostObj)
      )
    )

    # 通过HTTP请求添加或修改设备事件
    postChangeEvent: (typeId, equipmentTemplateId, signal, postObj) => (
      @commonService.modelEngine.modelManager.$http.post(
        "#{@host}/model/clc/api/v1/equipmentevents/#{@userId}/#{@projectId}/#{typeId}/#{equipmentTemplateId}/#{signal.model.signal}",
        postObj).then((res) =>
#        console.log '---新增&修改设备事件表---',res
        @Rx.onNext()
      )
    )
    # 通过HTTP请求添加或修改设备信号
    postChangeSignal: (typeId, equipmentTemplateId, signal, postObj) => (
      @commonService.modelEngine.modelManager.$http.post(
        "#{@host}/model/clc/api/v1/equipmentsignals/#{@userId}/#{@projectId}/#{typeId}/#{equipmentTemplateId}/#{signal.model.signal}",
        postObj).then((res) =>
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




    # 初始化函数
    init: (scope) =>
# 订阅设备树发出来的信号
      scope.subscribeSelectEquip?.dispose()
      scope.subscribeSelectEquip = @commonService.subscribeEventBus("selectEquip", (msg)=>
        if(msg.message.level == "equipment")
#          console.log 'msg',msg
          @loadEquipInfo(scope,msg.message.station,msg.message.id)

      )

    loadEquipInfo: (scope,stationId,equipId)=>
      nowStation = _.find(@stations, (station) -> station.model.station == stationId)
      nowStation.loadEquipment(equipId, null, (err,equip)=>
        @equipment = equip
        @equipment.loadEvents null, (err,events)=>
#          console.log '-----加载事件--'
          scope.events = []
          _.each(events, (event) =>
            event.eventInfo = {
              name: "" # 事件名称
            }
            scope.events.push event
          )
          scope.$applyAsync()
          @equipment.loadSignals null, (err,signals)=>
#            console.log '-----加载信号'
            scope.equipment = @equipment
            #                scope.signals = []
            _.each(signals, (signal) =>
              signal.signalInfo = {
                checked: false, # 是否给 checkbox 选中
                name: signal.model?.name || "" # 信号名称
              }
              signal.event = {}
              #根据信号类型显示告警配置
              if signal.model.dataType in ["float","int"] and signal.model.signal.charAt(0) isnt '_' and signal.model.signal not in @ruleOutSignals   # 过滤掉_alarms  _severity等信号
                signal.signalInfo.eventType = 'sample'
                eventInfo = {}
                eventInfo.event = signal.model.signal
                eventInfo.name = ""
                eventInfo.enable = ""
                eventInfo.type = signal.model.type
                eventInfo.overLimit = ""  # 超限阈值
                eventInfo.overSeverity = 1
                eventInfo.lowLimit = ""   # 低限阈值
                eventInfo.lowSeverity = 1
                signal.event.eventInfo = eventInfo
                # 判断现在的事件里是否有这个事件 如果有就修改，如果没有就定义一个新对象
                event = _.find scope.events,(event)->event.model.event is signal.model.signal  # 找与信号同名的事件
                if _.isEmpty(event)
# 新创建事件对象
                  signal.event.template = ""

                else  # 如果已有同名事件，不能单纯在它基础上修改 要考虑它原来只配了超限没有低限，前端设置低限无效的情况
                  event.eventInfo.enable = event.model.enable
                  event.eventInfo.name = event.model.name
                  event.eventInfo.overLimit = ""  # 超限阈值
                  event.eventInfo.overSeverity = 1
                  event.eventInfo.lowLimit = ""   # 低限阈值
                  event.eventInfo.lowSeverity = 1
                  _.each(event.model.rules, (rule)=>
                    _operator = rule.start.condition.operator # 符号
                    if(_operator == ">" || _operator == ">=") # 超限阈值
                      event.eventInfo.overLimit = rule.start.condition.values
                      event.eventInfo.overSeverity = String(rule.severity)
                    else if(_operator == "<" || _operator == "<=") # 低限阈值
                      event.eventInfo.lowLimit = rule.start.condition.values
                      event.eventInfo.lowSeverity = String(rule.severity)
                  )
                  signal.event = event
              else if signal.model.dataType is 'enum' and signal.model.signal.charAt(0) isnt '_' and signal.model.signal not in @ruleOutSignals  # 过滤掉_alarms  _severity等信号
                signal.signalInfo.eventType = 'status'
                # 判断现在的事件里是否有这个事件 如果有就修改，如果没有就定义一个新对象
                event = _.find scope.events,(event)->event.model.event is signal.model.signal  # 找与信号同名的事件

                if _.isEmpty(event)
# 新创建事件对象
                  eventInfo = {formatSelect:[]}
                  formatArr = (signal.model.format).split(",") # 解析枚举信号
                  _.each(formatArr, (format) =>
                    f = format.split(":")
                    obj = {
                      id: f[0],
                      name: f[1]
                    }
                    eventInfo.formatSelect.push(obj)
                  )
                  eventInfo.name = ""
                  eventInfo.enable = ""
                  eventInfo.numberLimit = ""
                  eventInfo.severity = ""
                  signal.event.eventInfo = eventInfo
                else  # 此信号有事件
                  event.eventInfo = {formatSelect:[]}
                  formatArr = (signal.model.format).split(",") # 解析枚举信号
                  _.each(formatArr, (format) =>
                    f = format.split(":")
                    obj = {
                      id: f[0],
                      name: f[1]
                    }
                    event.eventInfo.formatSelect.push(obj)
                  )
                  _rules = event.model.rules[0]
                  event.eventInfo.name = event.model.name
                  event.eventInfo.enable = event.model.enable
                  event.eventInfo.severity = String(_rules.severity)
                  event.eventInfo.numberLimit = (_.find(event.eventInfo.formatSelect, (item)-> Number(_rules.start.condition.values) == Number(item.id))).id
                  signal.event = event
              else
                signal.signalInfo.eventType = 'alarm'
# 此种类型不新增告警
            )
#                console.log '------@equipment---',@equipment
          ,true
        ,true
      ,true)



    resize: (scope)->

    dispose: (scope)->
      scope.subscribeSelectEquip?.dispose()

  exports =
    SignalConfigurationHmu2500Directive: SignalConfigurationHmu2500Directive