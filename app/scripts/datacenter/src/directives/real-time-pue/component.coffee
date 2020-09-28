###
* File: real-time-pue-directive
* User: David
* Date: 2019/03/05
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class RealTimePueDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "real-time-pue"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.xData = []
      @getPueSignal scope, =>
        @commonService.querySignalHistoryData scope.signal, moment().startOf("day"), moment().endOf("day"), (err, records, pageInfo) =>
          for record in records
            scope.xData.push {value: [record.timestamp, record.value?.toFixed(2)]}

          @createLineCharts scope, element
        scope.equipSubscriptionrealpue?.dispose()
        scope.equipSubscriptionrealpue=@commonService.subscribeSignalValue scope.signal, (sig) =>
          if sig.data.timestamp
            scope.option.series[0].data.push {value:[sig.data.timestamp, sig.data.value.toFixed(2)]}
          scope.echart?.setOption scope.option


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

    dispose: (scope)->
      scope.equipSubscriptionrealpue?.dispose()


  exports =
    RealTimePueDirective: RealTimePueDirective