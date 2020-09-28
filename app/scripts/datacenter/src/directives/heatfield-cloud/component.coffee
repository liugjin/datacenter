###
* File: heatfield-cloud-directive
* User: David
* Date: 2019/12/03
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define(['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class HeatfieldCloudDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "heatfield-cloud"
      super $timeout, $window, $compile, $routeParams, commonService
      
    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 温场测点信号 -- 来自于机柜的 1 ~ 42 U 的 设备温度
      scope.signalIds = _.map([42..42], (d) -> "u-" + d + "-server-temperature")
      
      # 标准温度 23
      scope.colorList = [
        { color: "transparent", title: "背景色", desc: "没有温度测点, 默认颜色" },
        { color: "green", title: "温度正常", desc: "温度测点正常, 范围: 20℃ ~ 25℃" },
        { color: "orange", title: "温度较高", desc: "温度测点正常, 范围: 25℃ ~ 30℃" },
        { color: "red", title: "温度过高", desc: "温度测点正常, 高于 30℃" },
        { color: "cyan", title: "温度较低", desc: "温度测点正常, 范围: 15℃ ~ 20℃" },
        { color: "blue", title: "温度过低", desc: "温度测点正常, 小于 15℃" }
      ]
      
      scope.currentSingal = scope.signalIds[0]
      scope.date = moment().format("YYYY-MM-DD")
      scope.updateTime = 3000
      scope.stationId = "floor1"
      scope.lowest = 0
      scope.highest = 100
      scope.dataType = "0"

      # 储存所有信号
      scope.allSignal = {}

      # 设置信号订阅
      scope.heatSub = {}
      setSubsigs = () => (
        scope.allSignal = _.mapObject(scope.allSignal, (d) -> {})

        filter = scope.project.getIds()
        filter.station = scope.stationId
        filter.equipment = "+"
        
        _.each(scope.heatSub, (sub) -> sub?.dispose()) if !_.isEmpty(scope.heatSub) 
        _.each(scope.signalIds, (d) =>
          filter.signal = d
          scope.heatSub[d] = @commonService.signalLiveSession.subscribeValues(filter, (err, sig) =>
            return if !sig
            return if sig?.message?.equipmentType != "rack"
            if !_.has(scope.allSignal, sig.message.signal)
              scope.allSignal[sig.message.signal] = {}
            
            scope.allSignal[sig.message.signal][scope.equipMap[sig.message.equipment]] = sig.message.value
          )
        )
      )
      
      # 历史数据查询
      getHistoryData = (date) => (
        scope.allSignal[scope.currentSingal] = {}
        filter = scope.project.getIds()
        #filter.equipment = "+"
        filter.signal = scope.currentSingal
        filter.mode = "day"
        filter.period = date
        @commonService.reportingService.querySignalStatistics({ filter, paging: null, sorting: null }, (err, records) =>
          return if !records or _.isEmpty(records)
          scope.allSignal[scope.currentSingal] = _.object(_.map(records, (d) => scope.equipMap[d.equipment]), _.map(records, (d) -> d.values[0].value))
          scope.$applyAsync()
        , true)
      )
      
    resize: (scope) ->

    dispose: (scope) -> 

  return exports = { HeatfieldCloudDirective: HeatfieldCloudDirective }
)