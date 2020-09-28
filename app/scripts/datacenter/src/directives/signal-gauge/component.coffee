###
* File: signal-gauge-directive
* User: David
* Date: 2019/02/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'echarts'], (base, css, view, _, moment, echarts) ->
  class SignalGaugeDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "signal-gauge"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      min: '='
      max: '='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      gauge = element.find(".signal-gauge")
      @waitingLayout @$timeout, gauge, =>
        scope.echart?.dispose()
        scope.echart = echarts.init gauge[0]

        scope.$watch "signal.data.value", (val) =>
          value = val ? 0
          option = @createOption value, scope.parameters.min, scope.parameters.max
          scope.echart.setOption option
        ,true

    createOption: (value, min, max) ->
#      multiple = (window.innerHeight/1080).toFixed(2)
      multiple = 1
      option =
        series:[
          {
            type:'gauge'
            splitNumber:3
            startAngle:180
            endAngle:0
            min: min ? 1
            max: max ? 4
            radius:'100%'
            axisLine:
              lineStyle:
                width:3* multiple
                color:[[0.3, 'lime'],[0.7, 'orange'],[1, '#ff4500']]
                shadowColor : '#fff'
                shadowBlur: 10
            axisTick:
              lineStyle:
                color:'auto'
#                width:2* multiple
                shadowColor : '#fff'
                shadowBlur: 10
              length:15
              splitNumber:10
            splitLine:
              length:24
              lineStyle:
                color:'#fff'
                width:3*multiple
                shadowColor : '#fff'
                shadowBlur: 10
            axisLabel:
              distance:2
              textStyle:
                color:'#fff'
                fontWeight: 'bolder'
                fontSize:12* multiple
                shadowColor : '#fff'
                shadowBlur: 10
            itemStyle:
              normal:
                color:'transparent'
                borderColor:'rgba(72,207,255)'
                borderWidth:2* multiple
              emphasis:
                color:'transparent'
                borderColor:'rgba(72,207,255)'
                borderWidth:2* multiple
            pointer:
              length:'60%'
              width: 4
            detail:
              textStyle:
                fontWeight: 'bolder'
                color: 'auto'
              offsetCenter:['0%','-20%']
            data:[{value:if value? then value.toFixed(2)}]
          }
        ]
      option

    resize: (scope)->
      scope.echart?.resize()

    dispose: (scope)->
      scope.echart?.dispose()


  exports =
    SignalGaugeDirective: SignalGaugeDirective