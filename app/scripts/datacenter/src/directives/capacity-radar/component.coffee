###
* File: capacity-radar-directive
* User: David
* Date: 2019/02/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'echarts'], (base, css, view, _, moment, echarts) ->
  class CapacityRadarDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "capacity-radar"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      radar = element.find(".capacity-radar")
      scope.ratios = {}
      @waitingLayout @$timeout, radar, =>
        scope.echart?.dispose()
        scope.echart = echarts.init radar[0]

        option = @createOption scope.ratios
        scope.echart.setOption option
        @createChart scope

        scope.subtopic?.dispose()
        scope.subtopic = @commonService.subscribeEventBus "stationId",(msg) =>
          scope.station = _.find scope.project.stations.items, (item)->item.model.station is msg.message.stationId
          @createChart scope

    createChart: (scope) =>
      scope.station?.loadEquipment "_station_capacity", null, (err, equipment) =>
        scope.subscription?.dispose()
        scope.subscription = @commonService.subscribeEquipmentSignalValues equipment, (signal) =>
          if signal.model.signal in ["ratio-cooling", "ratio-ports", "ratio-power", "ratio-space", "ratio-weight", "plan-ratio-cooling", "plan-ratio-ports", "plan-ratio-power", "plan-ratio-space", "plan-ratio-weight"]
            scope.ratios[signal.model.signal.replace("ratio-", "")] = signal.data.value
            option = @createOption scope.ratios
            scope.echart.setOption option

    createOption: (ratios) =>
      multiple = 1
      ratioCooling = ratios?.cooling?.toFixed(2) || 0
      ratioWeight = ratios?.weight?.toFixed(2) || 0
      ratioPower = ratios?.power?.toFixed(2) || 0
      ratioSpace = ratios?.space?.toFixed(2) || 0
      ratioPorts = ratios?.ports?.toFixed(2) || 0

      addCooling = ratios?["plan-cooling"]?.toFixed(2) || 0
      addWeight = ratios?["plan-weight"]?.toFixed(2) || 0
      addPower = ratios?["plan-power"]?.toFixed(2) || 0
      addSpace = ratios?["plan-space"]?.toFixed(2) || 0
      addPorts = ratios?["plan-ports"]?.toFixed(2) || 0

      option =
        tooltip:
          trigger:'axis'
          formatter: (params) ->
            relVal = params.data.name
            for i in [0...params.data.value.length]
              relVal += "<br>" + params.data.key[i] + "：" + params.data.value[i] + " %"
            relVal
        radar:
          name:
            textStyle:
              fontSize:14 * multiple
              color:'#fff'
          indicator:[
            {text:'制冷容量',max:100}
            {text:'承重容量',max:100}
            {text:'电力容量',max:100}
            {text:'空间容量',max:100}
            {text:'端口容量',max:100}
          ]
          axisLine:
            lineStyle:
              color:'#2d91bd'
              width:2* multiple
          splitLine:
            lineStyle:
              color: '#005b7d'
              width: 2* multiple
          splitArea:
            areaStyle:
              color: ['rgba(67,186,254,0.1)', 'transparent']

        series:[{
          type:'radar'
          tooltip:
            trigger:'item'
          symbolSize:0
          data:[
            {
              value:[ratioCooling+addCooling, ratioWeight+addWeight, ratioPower+addPower, ratioSpace+addSpace, ratioPorts+addPorts]
              key: ['制冷容量', '承重容量', '电力容量', '空间容量', '端口容量'] #key：自定义字段
              name:'附加计划用量'
              lineStyle:
                normal:
                  color:'#45cafe'
                  width:2* multiple
            }
            {
              value:[ratioCooling,ratioWeight,ratioPower,ratioSpace,ratioPorts]
              key: ['制冷容量', '承重容量', '电力容量', '空间容量', '端口容量'] #key：自定义字段
              name:'已使用量'
              lineStyle:
                normal:
                  color:'#00ffbb'
                  width:2* multiple
              areaStyle:
                normal:
                  color:'#33eee7'
                  opacity:0.3
            }

          ]
        }]

    resize: (scope)->
      scope.echart?.resize()

    dispose: (scope)->
      scope.echart?.dispose()
      scope.subtopic?.dispose()
      scope.subscription?.dispose()


  exports =
    CapacityRadarDirective: CapacityRadarDirective