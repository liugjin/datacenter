###
* File: energy-year-pie-directive
* User: David
* Date: 2019/03/06
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class EnergyYearPieDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "energy-year-pie"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      initData = () =>
        scope.pieChart = null
        chartelement = element.find('.charts-pie')
        scope.pieChart = echarts.init chartelement[0]
        scope.pieChart?.clear()

        scope.energyOption = [
          {signal:"power-it-value", mode: 'year', name:'IT设备能耗', period: moment().format('YYYY')}
          {signal:"power-facility-value", mode: 'year', name:'总能耗', period: moment().format('YYYY')}
          {signal:"power-office-value", mode: 'year', name:'办公和照明能耗', period: moment().format('YYYY')}
          {signal:"other-value", mode: 'year', name:'制冷和其他能耗', period: moment().format('YYYY')}
        ]

      queryDataBase = (stationId, option, callback) =>
        filter =
          user: @$routeParams.user
          project: @$routeParams.project
          station: stationId
          equipment: '_station_efficient'
          signal: option.signal
          period: option.period
          mode: option.mode
        @commonService.reportingService.querySignalStatistics {filter:filter}, (err,records) =>
          return if err
          if not _.isEmpty records
            _.mapObject records, (val) =>
              callback? val.values[0]

      createPieOption = (getData) =>
        dataArray = []
        legendArray = []
        total = _.find getData, (signal) -> signal.signal is "power-facility-value"
        it = _.find getData, (signal) -> signal.signal is "power-it-value"
        office = _.find getData, (signal) -> signal.signal is "power-office-value"
        other = _.find getData, (signal) -> signal.signal is "other-value"
        otherValue = (total.value ? 0) - (it.value ? 0) - (office.value ? 0)
        other.value = otherValue

        _.map getData, (s) ->
          if s.signal isnt "power-facility-value"
            dataArray.push {name: s.name,value: s.value}
            legendArray.push s.name

        option =
          color: ["#1D94FF", "#10EBF4","#F4BD0F", "#BBD7F2"]
          tooltip:
            trigger: 'item',
            formatter: "{a} <br/>{b}: {c} ({d}%)"

          legend:
            x: 'center'
            y: 'bottom'
            data:legendArray
            icon: "circle"
            itemGap: 10
            textStyle:
              color: "#a2caf8"

          series: [
            name:'访问来源'
            type:'pie'
            radius: ['50%', '70%']
            clockwise: false
            avoidLabelOverlap: false
            data: dataArray
            itemStyle:
              normal:
                label:
                  show: true

                  formatter: '{d}%'
                labelLine:
                  show: true
          ]
        option

      scope.$watch 'parameters.stationId', (stationId) =>
        initData()
        _.map scope.energyOption, (energyType) =>
          queryDataBase stationId, energyType, (value) =>
            energyType.value = value.value.toFixed(2)
            options = createPieOption scope.energyOption
            scope.pieChart.setOption options


    resize: (scope)->

    dispose: (scope)->


  exports =
    EnergyYearPieDirective: EnergyYearPieDirective