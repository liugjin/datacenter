###
* File: equip-lineorbar-hmu2500-directive
* User: David
* Date: 2020/05/30
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipLineorbarHmu2500Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equip-lineorbar-hmu2500"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.hasSelectSignal = []
      scope.chartValues = []
      currentEquip = null
      currentStation = null
      dictToName = {}
      scope.currentSignalName = "信号选择"
      if !scope.mode
        scope.mode = "now"
      currentTime = ""
      currentSignal = []
      scope.signalList = []
      subscribeTodayValue = null
      severityType = {}
      _.map(scope.project.dictionary.eventseverities.items, (d) =>
        severityType[d.model.severity] = d.model.color
      )

      scope.tipFun = (params, ticket, callback) =>
        html = "<div>" + params[0].name + "</div>"
        _.map(params, (d) =>
          _obj= _.find(scope.chartValues, (m) => m.key is d.name and m.category is d.seriesName)
          if _obj
            if severityType[_obj?.severity]
              color = severityType[_obj?.severity]
            else color='green'
            if _obj.severity is 0
              html += "<div><div style='margin-top:5px;margin-right:3px;float: left;height: 12px;width: 12px;border-radius: 50%;background-color:green;'></div>" + _obj?.category + ":" + _obj.value + "</div>"
            else
              html += "<div><div style='margin-top:5px;margin-right:3px;float: left;height: 12px;width: 12px;border-radius: 50%;background-color:" + color + "'></div>" + _obj?.category + ":" + _obj.value + "</div>"
        )
        return html

      # 点击事件
      scope.selectSignal = (signal, index) =>
        sigId = _.indexOf(currentSignal, signal.signal)
        if sigId is -1 and currentSignal.length < 3
          currentSignal.push(signal.signal)
        else if sigId != -1 and currentSignal.length > 1
          currentSignal = _.filter(currentSignal, (d) => d != signal.signal)
        else
#          scope.controller.prompt '错误', '请选择1-3个信号!!'
          @display '请选择1-3个信号!'
          return
        scope.signalList[index].check = !signal.check
        scope.hasSelectSignal = _.filter(scope.signalList, (signal)-> signal.check == true)
        if scope.mode == "now"
          getTodayData()
        else
          getHistoryData()
        scope.$applyAsync()

      cleanData = () =>
        scope.chartValues = []
        scope.signalList = []

      # 创建订阅 查询设备实时信息 - 并修改全局变量chartValues
      getNewData = (equipment) =>
        if subscribeTodayValue
          subscribeTodayValue.dispose()
        subscribeTodayValue = @commonService.subscribeEquipmentSignalValues(equipment, (d) =>
          if scope.mode == "now"
            _.map(scope.signalList, (m) =>
              if d.model.signal  == m.signal
                scope.chartValues.push({name: m.signal, key: moment(d.data.timestamp).format("HH:mm"), value: d.data.value, type:'line', category: dictToName[m.signal]}, severity: d.data.severity)

            )
#            scope.chartValues.sort(compare('key'))
            scope.chartValues = _.sortBy scope.chartValues,'key'

        )

      # 获取 设备信号存储表 今日的记录
      getTodayData = () =>
#        if !currentStation and !currentEquip
#          cleanData()
#          return
        filter = scope.project.getIds()
        filter.station = scope.equipment.model.station
        filter.equipment = scope.equipment.model.equipment
        filter.signal = {$in:currentSignal}
        filter.startTime = moment().format("YYYY-MM-DD 00:00:00")
        filter.endTime = moment().format("YYYY-MM-DD 23:59:59")

        @commonService.reportingService.querySignalRecords { filter: filter, fileds :null,paging:null,sorting:null },(err,records) =>
          return console.warn(err.toString()) if not records

          scope.chartValues = _.map records, (d) => {  name: d.signal, key: moment(d.timestamp).format("HH:mm"), value: d.value, type:'line', category: dictToName[d.signal], severity: d.severity }
          scope.chartValues = _.sortBy scope.chartValues,'key'
#          console.log scope.chartValues
          window.setTimeout(() =>
            getNewData(currentEquip)
            500)

      # 获取 设备信号记录表 历史的记录
      getHistoryData = (message) =>
        mode = scope.mode
        time = currentTime
        if message
          mode = message.type
          time = message.time
          currentTime = message.time
        filter = scope.project.getIds()
        filter.station = scope.equipment.model.station
        filter.equipment = scope.equipment.model.equipment
        filter.signal = {$in:currentSignal}
        newSignalsArr = []
        if mode is "day"
          filter.period = {$gte:time + " 00:00:00", $lt:time + " 23:59:59"}
        else if mode is "week"
          filter.period =
            $gte:moment().year(time.slice(0,4)).week(time.slice(6,time.length-1)).isoWeekday(1).format("YYYY-MM-DD")
            $lt:moment().year(time.slice(0,4)).week(time.slice(6,time.length-1)).isoWeekday(7).format("YYYY-MM-DD")
        else if mode is "month"
          filter.period = {$gte:moment(time, "YYYY-MM").startOf('month'), $lt:moment(time, "YYYY-MM").endOf('month')}
        @commonService.reportingService.querySignalStatistics { filter: filter, fileds: null,paging:null,sorting:null },(err,statistic) =>
          if typeof(statistic) is "object"
            _chartValues = []
            result = _.map(statistic, (d) -> d)
            if result.length == 0
              result = _.map(currentSignal, (d) -> {signal:d,values:[]})
            if result.length < currentSignal.length
              for i in result
                newSignalsArr.push(i.signal)
              for j in currentSignal
                if j not in newSignalsArr
                  result.push(signal:j,values:[])
            if mode is "day"
              for sig in result
                _chartValues = _chartValues.concat(
                  _.map([1..24], (d) =>
                    hour = if d < 10 then ("0" + d) else d.toString()
                    _obj = _.find(sig.values, (m) => moment(m.timestamp).format("HH") is hour and m.mode is "hour")
                    if _obj
                      return { name: sig.signal, type: "line", category: dictToName[sig.signal], key: hour + "时", value: _obj.value, severity: _obj.severity }
                    return { name: sig.signal, type: "line", category: dictToName[sig.signal], key: hour + "时", value: 0, severity: 0 }
                  )
                )
            else if mode is "week"
              for sig in result
                _chartValues = _chartValues.concat(
                  _.map(["周一", "周二", "周三", "周四", "周五", "周六", "周日"], (d, i) =>
                    day = moment().year(time.slice(0,4)).week(time.slice(6,time.length-1)).isoWeekday(i+1).format("YYYY-MM-DD")
                    _obj = _.find(sig.values, (m) => m.period is day and m.mode is "day")
                    if _obj
                      return { index:i,name: sig.signal, type: "line", category: dictToName[sig.signal], key: d, value: _obj.value, severity: _obj.severity }
                    return { index:i,name: sig.signal, type: "line", category: dictToName[sig.signal], key: d, value: 0, severity: 0 }
                  )
                )
            else if mode is "month"
              for sig in result
                _chartValues = _chartValues.concat(
                  _.map([1..moment(time, "YYYY-MM").endOf('month').format("DD")], (d, i) =>
                    day = if d < 10 then "0" + d else d.toString()
                    today = time + "-" + day
                    _obj = _.find(sig.values, (m) => m.period is today and m.mode is "day")
                    if _obj
                      return { name: sig.signal, type: "line", category: dictToName[sig.signal], key: day, value: _obj.value, severity: _obj.severity }
                    return {  name: sig.signal, type: "line", category: dictToName[sig.signal], key: day, value: 0, severity: 0 }
                  )
                )
            _chartValues =_.sortBy _chartValues,(item)->item.index
            sum = 0

            scope.chartValues = _chartValues
          else
            cleanData()


      # 监听 - 时间
      scope.timeSubscribe?.dispose()
      scope.timeSubscribe = @commonService.subscribeEventBus "equipment-time", (msg) =>
        scope.mode = msg.message?.type
        if msg.message?.type == "now"
          getTodayData()
        else
          getHistoryData(msg.message)


      scope.equipment.loadSignals null, (err, signallists) =>
        signals = _.find(scope.equipment.properties.items, (d) -> d.model.property == "_signals")
        if signals and signals.value
          scope.signalList = _.map(JSON.parse(signals.value), (d, i) =>
            _signal = _.find(signallists, (m) => m.model.signal == d.signal)
            return { signal: d.signal, name: _signal?.model.name, check: if i == 0 then true else false }
          )
        else
          scope.signalList = _.map(signallists, (d, i) -> { signal: d.model.signal, name: d.model.name, check: if i == 0 then true else false })
        currentSignal = [scope.signalList[0].signal]
        scope.hasSelectSignal = [scope.signalList[0]]
        _.map(scope.signalList, (d) => dictToName[d.signal] = d.name)
        if scope.mode == "now"
          getTodayData()
        else
          getHistoryData()
        scope.subscribSignalID?.dispose()
        scope.subscribSignalID = @commonService.subscribeEventBus 'signalId', (d)=>
          result = _.indexOf(currentSignal, d.message.signalId.signal)
          if result == -1
            currentSignal.push d.message.signalId.signal
          sigObj = _.find scope.signalList,{signal:d.message.signalId.signal}
          if sigObj
            sigObj.check = true

          getTodayData()
        scope.$applyAsync()
      ,true

    resize: (scope)->

    dispose: (scope)->
      scope.timeSubscribe?.dispose()
      scope.treeSubscribe?.dispose()
      scope.subSignal?.dispose()



  exports =
    EquipLineorbarHmu2500Directive: EquipLineorbarHmu2500Directive