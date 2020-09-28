###
* File: server-performanceinfo-directive
* User: David
* Date: 2019/10/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class ServerPerformanceinfoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "server-performanceinfo"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.subscribObjs = {}
      scope.showSignals = []
      scope.chartDatas = []
      scope.selectedSig = ""
      scope.selectSignalObj = null
      scope.chartDataObj = {}
      scope.echart?.dispose()
      scope.optioninfo = null
      scope.selectMode = "now"
      chartLine = element.find(".my-chart")

      @waitingLayout @$timeout, chartLine, =>
        scope.echart?.dispose()
        scope.echart = echarts.init chartLine[0]

        scope.$watchCollection "chartDatas", (value)=>
          return if not value
          options = @createOption(value)
          scope.echart.setOption(options)



      stationResult = _.filter scope.project.stations.items,(stationItem)->
        return stationItem.model.station == scope.parameters.station
      if stationResult.length > 0
        stationResult[0].loadEquipment scope.parameters.equipment, null, (err, equipment) =>
          equipment?.loadSignals null, (err, signals) =>
            for signalItem in signals
              if signalItem.model.visible
                signalItem.model.value = "--"
                signalItem.model.station = signalItem.equipment.model.station
                signalItem.model.equipment =  signalItem.equipment.model.equipment
                signalItem.model.unitName = @getSignalUnitName(scope,signalItem.model.unit)
                scope.showSignals.push signalItem.model
            sortSignals = _.sortBy scope.showSignals,(item)=>
              return -item.index
            scope.showSignals = sortSignals
            if scope.showSignals.length > 0
              scope.selectedSig = scope.showSignals[0].name
              scope.selectSignalObj = scope.showSignals[0]
            for showSignalItem in scope.showSignals
              @getRealDatas scope,showSignalItem

      scope.selectSignal = (signal)=>
        scope.selectedSig = signal.name
        scope.selectSignalObj = signal
        if scope.selectMode == "now"
          @getRealDatas(scope,signal)
        else
          @querydata(scope,scope.selectSignalObj,scope.selectMode)

      scope.selectStatisticMode = (mode)=>
        scope.selectMode = mode
        if mode == "now"
          @getRealDatas(scope,scope.selectSignalObj)
        else
          @querydata(scope,scope.selectSignalObj,mode)



    getRealDatas:(scope,signal)=>
      #获取信号实时数据
      scope.chartDatas = []
      scope.signalObjVal = {}
      subId = signal.station + "." + signal.equipment + "." + signal.signal
      filter = scope.project.getIds()
      filter.station = signal.station
      filter.equipment = signal.equipment
      filter.signal = signal.signal
      scope.subscribObjs[subId]?.dispose()
      scope.subscribObjs[subId] = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
        tmpSignal = _.filter scope.showSignals,(signalItme)->
          return signalItme.signal == d.message.signal
        if tmpSignal.length > 0
          tmpSignal[0].value = d.message.value

        if scope.selectMode == "now"
          if scope.selectSignalObj.signal == d.message.signal
            scope.signalObjVal[scope.selectSignalObj.signal] = {} if !scope.signalObjVal[scope.selectSignalObj.signal]
            scope.signalObjVal[scope.selectSignalObj.signal][moment(d.message.timestamp).format("HH:mm")] = d.message.value?.toFixed(2)
            scope.chartDatas = []
            _.mapObject scope.signalObjVal[scope.selectSignalObj.signal],(value,key)=>
              scope.chartDatas.push {name:"性能曲线",key:key,value:value}
            scope.$applyAsync()
      ,true
    querydata:(scope,signal,mode)=>
      #根据条件和时间模式获取统计数据
      scope.chartDatas = []
      filter = scope.project.getIds()
      filter.station = signal.station
      filter.equipment = signal.equipment
      filter.signal = signal.signal
      if mode == "day"
        filter.mode = "hour"
        filter.period = {$gte:moment().startOf('day'),$lte:moment().endOf('day')}
      else if mode == "month"
        filter.mode = "day"
        filter.period = {$gte:moment().startOf('month'),$lte:moment().endOf('month')}

      @commonService.reportingService.querySignalStatistics {filter:filter}, (err, records) =>
        scope.chartDatas = []
        if records
          if angular.isObject records
            currDatas = []
            _.mapObject records,(val,key)=>
              for val in val.values
                currDatas.push {name:"性能曲线",key:val.period.substr(val.period.length-2,2),value:val.avg.toFixed(2)}

            scope.chartDatas = _.sortBy currDatas,(dataItem)->
              return dataItem.key
        scope.$applyAsync()

    createOption: (chartdatas) =>
      xAxisDatas = _.pluck chartdatas,'key'
      yAxisDatas = _.pluck chartdatas,'value'
      option =
        grid:
          left: "13%"
          right: "13%"
          top: "22%"
          bottom: "10%"
        xAxis:
          boundaryGap: false
          data: xAxisDatas
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
  #          formatter: "{c}"
          backgroundColor: "rgba(67,202,255,1)"
          padding: [5, 10]
          textStyle:
            color: "#e2edf2"
            fontWeight: "bold"

        series: [
          data: yAxisDatas
          itemStyle:
            normal:
              color: '#7DE6C2'
          type: 'line'
          smooth: true
          lineStyle:
            normal:
              color: "rgba(67,202,255,1)"
          areaStyle:
            normal:
              color:
                type: 'linear'
                x: 0
                y: 0
                x2: 0
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

    getSignalUnitName:(scope,id)->
      unitRel = _.filter scope.project.dictionary.signaltypes.items,(unitItem)->
        return unitItem.model.type==id
      if unitRel.length > 0
        return unitRel[0].model.unit
      else 
        return ""
    resize: (scope)->

    dispose: (scope)->
      _.mapObject scope.subscribObjs,(val,key)->
        val?.dispose()


  exports =
    ServerPerformanceinfoDirective: ServerPerformanceinfoDirective