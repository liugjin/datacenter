###
* File: percent-gauge-directive
* User: David
* Date: 2019/03/16
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'echarts'], (base, css, view, _, moment ,echarts) ->
  class PercentGaugeDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "percent-gauge"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      color:'='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.parameters.equipment
      gauge = element.find(".percent-gauge")
      @waitingLayout @$timeout, gauge, =>
        scope.echart?.dispose()
        scope.echart = echarts.init gauge[0]

        scope.$watch "signal.data.value", (value)=>
          option = @createOption scope, value
          scope.echart.setOption option

    createOption: (scope, value) =>
      if not value
        data = [{value: 100, itemStyle: { normal: {color: 'transparent'}}}]
      else
        data = [
          {value: (100-value).toFixed(2), itemStyle: { normal: {color: 'transparent'}}}
          {
            value: value.toFixed(2)
            label:
              normal:
                show: true,
                position: 'center',
                color: 'white',
                formatter: '{c}%',
                textStyle:
                  fontSize: '22',
                  fontWeight: 'bold'
              emphasis:
                show: true
                textStyle:
                  fontSize: '26',
                  fontWeight: 'bold'

            itemStyle:
              normal:
                color: scope.parameters.color ? new echarts.graphic.LinearGradient(1, 0, 0, 1, [
                  {offset: 0, color: 'rgb(78,112,234)'},
                  {offset: 1, color: 'rgb(32,193,244)'}], false)
          }
        ]
      option =
        series:[
          {
            type:'pie'
            radius: ['80%', '85%']
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
            label:
              normal:
                show: false
            itemStyle:
              normal:
                color: 'rgba(158,158,158,0.3)'
            data: data
          }
        ]
      option

    resize: (scope)->
      scope.echart?.resize()

    dispose: (scope)->
      scope.echart?.dispose()


  exports =
    PercentGaugeDirective: PercentGaugeDirective