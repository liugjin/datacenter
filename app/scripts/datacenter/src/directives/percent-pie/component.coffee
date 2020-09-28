###
* File: percent-pie-directive
* User: bingo
* Date: 2019/06/04
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class PercentPieDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "percent-pie"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      createOption = (value) =>
        if not value
          data = [{value: 100, itemStyle: { normal: {color: 'transparent'}}}]
        else
          data = [
            {value: (100 - value).toFixed(0), itemStyle: { normal: {color: 'transparent'}}}
            {
              value: value.toFixed(0)
              label:
                normal:
                  show: true,
                  position: 'center',
                  color: 'white',
                  formatter: '{c}%',
                  textStyle:
                    fontSize: '18',
                    fontWeight: 'bold'
                emphasis:
                  show: true
                  position: 'center',
                  color: 'white',
                  formatter: '{c}%',
                  textStyle:
                    fontSize: '18',
                    fontWeight: 'bold'
              itemStyle:
                normal:
                  color: $scope.parameters.color ? new echarts.graphic.LinearGradient(1, 0, 0, 1, [
                    {offset: 0, color: 'rgb(78,112,234)'},
                    {offset: 1, color: 'rgb(32,193,244)'}], false)
            }
          ]
        option =
          series:[
            {
              type:'pie'
              radius: ['80%', '85%']
              hoverAnimation: false
              label:
                normal:
                  show: false
              itemStyle:
                normal:
                  color: 'rgba(158,158,158,0.3)'
              data:[{value:100}]
            },
            {
              type: 'pie'
              radius: ['75%', '90%']
              hoverAnimation: false
              clockwise: false
              label:
                normal:
                  show: false
              itemStyle:
                normal:
                  color: 'rgba(158,158,158,0.3)'
              data: data
            }
          ]
        #console.log(option)
        option

      e = element.find('.ratio-pie')
      option = createOption()
      $scope.myChart?.dispose()
      $scope.myChart = echarts.init(e[0])
      $scope.myChart.setOption(option)
      $scope.subscribePercent = null

      $scope.$watch "equipment", (equipment) =>
        #console.log(equipment)
        return if not equipment

      $scope.$watch "signal", (signal) =>
        #console.log(signal)
        return if not signal
        $scope.subscribePercent?.dispose()
        $scope.subscribePercent = @commonService.subscribeSignalValue signal, (sig) =>
          #console.log(sig)
          return if not sig or not sig.data.value
          option = createOption(sig.data.value)
          $scope.myChart?.setOption(option)

    resize: ($scope)->
      $scope.myChart?.resize()

    dispose: ($scope)->
      $scope.myChart?.dispose()
      $scope.myChart = null
      $scope.subscribePercent?.dispose()


  exports =
    PercentPieDirective: PercentPieDirective