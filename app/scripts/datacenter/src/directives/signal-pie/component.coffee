###
* File: signal-pie-directive
* User: bingo
* Date: 2019/05/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class SignalPieDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "signal-pie"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>

      createChartOption = (value, color) =>
        colorArr = []
        if color
          colorArr.push color
        else
          colorArr.push "#1d95ff"
        data = [0]
        option =
          color: colorArr,
          title: {
            text: value || "-"
            textStyle: {
              color: '#fff',
              fontSize: 14
            },
            subtextStyle: {
              fontSize: 14,
              color: '#fff'
            },
            x: 'center',
            y: 'center'
          },
          series:[
            {
              name: "",
              type:'pie',
              radius: ['70%', '95%'],
              avoidLabelOverlap: false,
              clockwise: true,
              hoverAnimation: false,
              hoverOffset: 0,
              startAngle: 0,
              label: {
                normal: {
                  show: false,
                  position: 'outside'
                }
              },
              labelLine: {
                normal: {
                  show: false
                }
              },
              data: data
            }
          ]
        option

      e = element.find('.signal-pie')
      option = null
      $scope.myChart = null
      $scope.myChart?.dispose()
      $scope.myChart = echarts.init(e[0])
      option = createChartOption()
      $scope.myChart.setOption(option)

      $scope.$watch "equipment", (equipment) =>
        #console.log(equipment)
        return if not equipment
        equipment.loadSignals null, (err, signals) =>
          #console.log(signals)
          return if err or signals.length < 1
          $scope.signal = _.find signals, (signal) => signal.model.signal is $scope.parameters.signal
        , true

      $scope.$watch "signal", (signal) =>
        #console.log(signal)
        return if not signal
        signal.model.unitName = $scope.project?.typeModels.signaltypes.getItem(signal.model.unit)?.model?.unit
        $scope.signalSubscrip?.dispose()
        $scope.signalSubscrip = @commonService.subscribeSignalValue signal, (sig) =>
          return if not sig or not sig.data.value
          #console.log(sig)
          severity = $scope.project?.typeModels.eventseverities.getItem(sig.data.severity)?.model
          sig.data.color = severity?.color ? '#1d95ff'
          option = createChartOption(sig.data.value.toFixed(1), sig.data.color)
          if not $scope.myChart
            $scope.myChart = echarts.init(e[0])
          $scope.myChart?.setOption(option)

    resize: ($scope)->
      $scope.myChart?.resize()

    dispose: ($scope)->
      $scope.myChart?.dispose()
      $scope.myChart = null
      $scope.signalSubscrip?.dispose()

  exports =
    SignalPieDirective: SignalPieDirective