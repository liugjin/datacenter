###
* File: real-time-pue-hmu2500-directive
* User: David
* Date: 2020/05/07
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class RealTimePueHmu2500Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "real-time-pue-hmu2500"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @formulaAll = ""
      @formulaIT = ""
      scope.variablesCount = 0 # key后面的唯一标识
      scope.variablesAll = [] # 总能耗的所有变量
      scope.variablesIT = [] # IT能耗的所有变量
      scope.pueSignal = {} # pue 信号
      scope.pueEquips = [] # 和 pue 相关的设备
      scope.xData = []
      @getPueEquipmentSignal(scope)
      @getPueSignal(scope, () =>
        @commonService.querySignalHistoryData scope.signal, moment().startOf("day"), moment().endOf("day"), (err, records, pageInfo) =>
          for record in records
            scope.xData.push {value: [record.timestamp, record.value?.toFixed(2)]}

          @createLineCharts scope, element
        scope.equipSubscriptionrealpue?.dispose()
        scope.equipSubscriptionrealpue=@commonService.subscribeSignalValue scope.signal, (sig) =>
          if sig.data.timestamp
            scope.option.series[0].data.push {value:[sig.data.timestamp, sig.data.value?.toFixed(2)]}
          scope.echart?.setOption scope.option
      )
      # 选中的设备
      scope.selectEquipment = (variable) => (
        variableValueArr = variable.value.split("/")
        variableStation = variableValueArr[0]
        variable.equipmentInfo = _.find(scope.pueEquips, (equip)-> equip.model.equipment == variable.equipment)
        variable.signal = variable.equipmentInfo.signals.items[0].model.signal
        variable.value = "#{variableStation}/#{variable.equipment}/#{variable.signal}"
        scope.selectRefresh++
      )
      scope.slelectSignal = (variable) => (
        variableValueArr = variable.value.split("/")
        variableStation = variableValueArr[0]
        variableEquipment = variableValueArr[1]
        variable.value = "#{variableStation}/#{variableEquipment}/#{variable.signal}"
      )
      # 删除变量
      scope.deleteVariable = (variable, type) => (
        if(type == "all")
          scope.variablesAll = _.reject(scope.variablesAll, (item) -> item.key == variable.key)
        else if(type == "IT")
          scope.variablesIT = _.reject(scope.variablesIT, (item) -> item.key == variable.key)
      )
      # 新增变量
      scope.addVariable = (type) => (
        isKeyRepeat = (variableKey) -> (
          changeVariableKey = variableKey
          hasAll = _.find(scope.variablesAll, (item)-> item.key == variableKey)
          hasIT = _.find(scope.variablesIT, (item)-> item.key == variableKey)
          if(!_.isEmpty(hasAll) || !_.isEmpty(hasIT))
            scope.variablesCount++
            changeVariableKey = "v#{scope.variablesCount}"
            isKeyRepeat(changeVariableKey)
          else
            return changeVariableKey
        )
        variableKey = "v#{scope.variablesCount}"
        variableKey = isKeyRepeat(variableKey)
        firstPueEquipment = scope.pueEquips[0]
        firstPueEquipmentSignal = scope.pueEquips[0].signals.items[0]
        variable = {
          equipment: firstPueEquipment.model.equipment,
          equipmentInfo: firstPueEquipment,
          key: variableKey,
          signal: firstPueEquipmentSignal.model.signal,
          symbol: "+",
          type: "signal-value"
          value: "#{firstPueEquipment.station.model.station}/#{firstPueEquipment.model.equipment}/#{firstPueEquipmentSignal.model.signal}"
        }
        if(type=="all")
          scope.variablesAll.push(variable)
        else if(type=="IT")
          scope.variablesIT.push(variable)
      )
      # 保存变量
      scope.saveVariable = (type, variables) => (
        return @display("总体能耗和IT能耗均不能为空") if (_.isEmpty(variables))
        # 判断是否有重复的项
        isHasCommonObj = (arr, key, val) => (
          repeatVariable = [] # 用来存找到重复的对象
          for variable in arr
            if(variable[key] == val)
              repeatVariable.push(variable)
          if(repeatVariable.length >= 2)
            return repeatVariable
        )
        for variable in variables
          isCommonObj = isHasCommonObj(variables, "value", variable.value)
          return @display("保存的项目中不能有重复的项") if (!_.isEmpty(isCommonObj))

        # 修改公式
        newFormula = "("
        _.each(variables, (item, num)=>
          if(num == 0 && item.symbol == "+")
            newFormula = newFormula + item.key
          else
            newFormula = newFormula + item.symbol + item.key
        )
        newFormula = newFormula + ")"
        if(type == "all")
          scope.pueSignal.model.expression.formula = "#{newFormula}/#{@formulaIT}"
        else if(type == "IT")
          scope.pueSignal.model.expression.formula = "#{@formulaAll}/#{newFormula}"
        # 修改变量
        newVariables = []
        newVariables = newVariables.concat(scope.variablesAll)
        newVariables = newVariables.concat(scope.variablesIT)
        scope.pueSignal.model.expression.variables = _.map(newVariables, (item)->
          return {
            type: item.type
            value: item.value
            key: item.key
          }
        )
        scope.pueSignal.save()
      )
    # 获取 PUE 设备相关的设备以及信号
    getPueEquipmentSignal: (scope) => (
      # 获取站点能效设备的PUE信号
      getStationEfficientPue = (_station_efficient) => (
        _station_efficient.loadSignals(null, (err, signals)=>
          scope.pueSignal = _.find(signals, (signal) -> signal.model.signal == "pue-value")
          formula = scope.pueSignal.model.expression.formula # 表达式
          variables = scope.pueSignal.model.expression.variables # 构成表达式的变量集合
          formulaArr = formula.split("/")
          @formulaAll = formulaArr[0] # pue总能耗
          @formulaIT = formulaArr[1] # pueIT能耗
          # 把他的属性信息添加到弹框里面
          _.each(variables, (variable) =>
            _variableArr = variable.value.split("/")
            variable.equipment = _variableArr[1] # 设备
            variable.signal = _variableArr[2] # 信号
            _hasAll = @formulaAll.indexOf(variable.key) # 是否是总能耗
            _hasIT = @formulaIT.indexOf(variable.key) # 是否是IT能耗
            _symbol = @formulaAll[_hasAll-1] || @formulaIT[_hasIT-1] # 变量前的符号 ( + -
            variable.equipmentInfo = _.find(scope.pueEquips, (equip) -> equip.model.equipment == variable.equipment)
            if(_symbol == "(" || _symbol == "+")
              variable.symbol = "+"
            else
              variable.symbol = "-"
            if(_hasAll != -1) # 是总能耗时
              scope.variablesAll.push(variable)
            else if(_hasIT != -1) # 是IT能耗时
              scope.variablesIT.push(variable)
          )
        )
      )
      scope.station.loadEquipments({}, null, (err,equips)=>
        scope.pueEquips = _.filter(equips, (equip) -> equip.model.type == "pdu" || equip.model.type == "ups" || equip.model.type == "low_voltage_distribution" || equip.model.type == "meter")
        pueEquipsLength = scope.pueEquips.length # 用来调整异步
        _station_efficient = _.find(equips, (equip) -> equip.model.equipment == "_station_efficient")
        _.each(scope.pueEquips, (equip) ->
          equip.loadSignals(null,(err,signals)->
            pueEquipsLength--
            equip.signals.items = _.filter(equip.signals.items, (item)-> item.model.unit == "active-power")
            if(pueEquipsLength == 0)
              getStationEfficientPue(_station_efficient)
          )
        )
      )
    )

    
    getPueSignal: (scope, callback) =>
      @commonService.loadEquipmentById scope.station, "_station_efficient", (err, equip)=>
        equip?.loadSignals null, (err, sigs) =>
          scope.signal = _.find sigs, (sig)->sig.model.signal is "pue-value"
          callback?()

    createLineCharts: (scope, element) =>
      line = element.find(".signal-line")
      scope.echart?.dispose()
      scope.option =
        xAxis:
          type: 'time'
          axisLine:
            lineStyle:
              color: "#A2CAF8"
          splitLine:
            lineStyle:
              color: "rgba(0,77,160,1)"
        yAxis:
          type: 'value'
          axisLine:
            lineStyle:
              color: "#A2CAF8"
          splitLine:
            lineStyle:
              color: "rgba(0,77,160,1)"
        tooltip:
          trigger: "axis"

        series: [
          data: scope.xData
          type: 'line'
          smooth: true
          lineStyle:
            normal:
              color: "rgba(67,202,255,1)"
          areaStyle:
            normal:
              color:
                type: 'linear'
                x: 1
                y: 1
                x2: 1
                y2: 1
                colorStops: [
                  {
                    offset: 0, color: 'rgba(67,202,255,1)'
                  }
                  {
                    offset: .5, color: 'rgba(67,202,255,.8)'
                  }
                  {
                    offset: 1, color: 'rgba(67,202,255,.3)'
                  }
                ]
        ]

      scope.echart = echarts.init line[0]
      scope.echart?.setOption scope.option
    resize: (scope)->
      scope.echart?.resize()

    dispose: (scope)->
      scope.equipSubscriptionrealpue?.dispose()

  exports =
    RealTimePueHmu2500Directive: RealTimePueHmu2500Directive