###
* File: total-energy-bar-directive
* User: David
* Date: 2019/03/06
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class TotalEnergyBarDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "total-energy-bar"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      @initPicker(scope)
      @$timeout =>
        scope.selectMode null,scope.picker[0]
      ,0
      @subBus?.dispose()
      @subBus = @subscribeEventBus 'stationId', (d) =>
        @initPicker(scope)
        scope.stationId = d.message.stationId
        scope.selectMode null,scope.picker[0]

      scope.selectMode = ($event,option) =>
        $('.date-value1').removeClass('date-active1')
        if $event
          $($event.target).addClass('date-active1')
        else
          @$timeout =>
            $(element.find('.date-value1')[0]).addClass('date-active1')
          ,0
        @queryDatabase scope, option, (value) =>
          if _.isEmpty value
            @createLineCharts scope,element,0
            return
          data = (_.values value)[0]
          _.map data.values, (value) ->
#            value.timestamp = moment(value.timestamp).format(option.format)
            value.value = value.value.toFixed(2)
          currentData = data.values
          @createLineCharts(scope, element, currentData)

    initPicker: (scope) =>
      scope.picker = [
        {mode: 'hour', name:'日', period: {$gte:moment().startOf('day'), $lt:moment().endOf('day')}, format:'HH:00'}
        {mode: 'day', name:'月', period: {$gte:moment().startOf('month'), $lt:moment().endOf('month')}, format:'YYYY-MM-DD'}
        {mode: 'month', name:'年', period: {$gte:moment().startOf('year'), $lt:moment().endOf('year')}, format:'YYYY-MM'}

      ]

    queryDatabase: (scope,option,callback) =>
      filter =
        user: @$routeParams.user
        project: @$routeParams.project
        station: scope.stationId
        equipment: '_station_efficient'
        signal: 'power-value'
        period: option.period
        mode: option.mode

      @commonService.reportingService.querySignalStatistics {filter:filter}, (err,records) =>
        return if err
        callback? records

    createLineCharts: (scope, element, data) =>
      data = _.sortBy data, (item)->item.period
      xDataTime = _.pluck data, "period"
      xDataSort = _.sortBy xDataTime, (date) -> date
      xData = _.pluck data, "value"

      line = element.find(".signal-line")
      scope.echart?.dispose()
      option =
        xAxis:
          type: 'category',
          boundaryGap: false,
          data: xDataSort
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
        grid:
          left: '3%',
          right: '3%',
          bottom: '10%'
          containLabel: true
        tooltip :
          formatter: "{a} <br/>{b} : {c}%"
        series: [
          name: '总能耗'
          data: xData
          type: 'line'
#          smooth: true
          lineStyle:
            normal:
              color: "rgba(67,202,255,1)"
        ]

      scope.echart = echarts.init line[0]
      scope.echart.setOption option

    resize: (scope)->

    dispose: (scope)->


  exports =
    TotalEnergyBarDirective: TotalEnergyBarDirective
