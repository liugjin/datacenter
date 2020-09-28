###
* File: signal-gauge-picker-directive
* User: David
* Date: 2019/03/13
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class SignalGaugePickerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "signal-gauge-picker"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @initPicker(scope)
      @initModeValue(scope)
      @$timeout =>
        scope.stationId = scope.station.model.station
        scope.selectMode null,scope.picker[0]
      ,0
      @subBus?.dispose()
      @subBus = @subscribeEventBus 'stationId', (d) =>
        @initPicker(scope)
        @initModeValue(scope)
        scope.stationId = d.message.stationId
        scope.selectMode null,scope.picker[0]

      scope.selectMode = ($event,option) =>
        @initModeValue(scope)
        $('.date-value').removeClass('date-active')
        if $event
          $($event.target).addClass('date-active')
        else
          @$timeout =>
            $(element.find('.date-value')[0]).addClass('date-active')
          ,0
        @queryDatabase scope, option, (value) =>
          if _.isEmpty value
            @createOption(scope, element, 0)
            return
          #data = parseFloat (_.values value)[0].toFixed(2)
          data = (_.values value)[0]
          currentData = data.values[0]
          console.log currentData
          @createOption(scope, element, currentData.value.toFixed(2))
          scope.currentModeValue =
            Min: currentData.min
            Average: currentData.avg
            Max: currentData.max

    initPicker: (scope) =>
      scope.picker = [
        {mode: 'day', name:'日', period: moment().format('YYYY-MM-DD')}
        {mode: 'month', name:'月', period: moment().format('YYYY-MM')}
        {mode: 'year', name:'年', period: moment().format('YYYY')}
      ]

    initModeValue: (scope) =>
      scope.currentModeValue =
        Max: '-'
        Min: '-'
        Average: '-'

    queryDatabase: (scope,option,callback) =>
      filter =
        user: @$routeParams.user
        project: @$routeParams.project
        station: scope.stationId
        equipment: '_station_efficient'
        signal: 'pue-value'
        period: option.period
        mode: option.mode

      @commonService.reportingService.querySignalStatistics {filter:filter}, (err,records) =>
        return if err
        callback? records

    createOption: (scope, element, val) =>
      gauge = element.find(".signal-gauge")
      scope.echart?.dispose()

      option =
        tooltip :
          formatter: "{a} <br/>{b} : {c}%"
        series: [
          name: '业务指标'
          type: 'gauge'
          min: 1
          max: 4
          axisLine:
            lineStyle:
              color: [[0.2, '#43caff'],[0.8, '#1d94ff'],[1, '#10ebf4']]
              width: 8
              shadowColor : '#e2edf2'
              shadowBlur: 5

          splitLine:
            length: 14
            lineStyle:
              color: "auto"

          axisTick:
            length: 12
            lineStyle:
              color: "auto"

          pointer:
            length: "70%"

          title :
            offsetCenter: [0, '-30%']
            textStyle:
              color: '#e2edf2'
              fontSize: 20
              shadowColor : '#e2edf2'

          detail:
            formatter:'{value}'
            textStyle:
              fontWeight: 'bolder'
              color: '#43caff'
          data: [{value: val ? 0, name: 'PUE'}]
        ]

      #console.log option
      scope.echart = echarts.init gauge[0]
      scope.echart.setOption option

    resize: (scope) ->
      scope.echart?.resize()

    dispose: (scope) ->
      scope.echart?.dispose()
      @subBus?.dispose()


  exports =
    SignalGaugePickerDirective: SignalGaugePickerDirective
