###
* File: three-quarter-pie-directive
* User: David
* Date: 2019/11/08
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment,echarts) ->
  class ThreeQuarterPieDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "three-quarter-pie"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      drawCharts = () => (
        option = {
          title: {
            text: scope.parameters.name || "没有设置",
            textStyle: {
              color: "#FFFFFF",
              fontWeight: 200,
              fontFamily: "PingFangSC-Regular",
              fontSize: 14,
            },
            left: "center",
            top: "70%"
          }
          series: [
            # 装饰
            {
              type: "pie",
              center: ["50%", "40%"]
              silent: true,
              radius: ["52%", "75%"],
              startAngle: 234
              labelLine: {
                normal: {
                  show: false
                }
              },
              data: [
                {
                  value: 4,
                  label: {
                    normal: {
                      formatter: scope.labelValue,
                      position: "center",
                      show: true,
                      textStyle: {
                        fontSize: 24,
                        fontWeight: "normal",
                        color: "#fff"
                      }
                    }
                  }
                  itemStyle: {
                    color: "rgba(108,228,236,0.1)",
                  }
                },
                {
                  value: 1,
                  itemStyle: {
                    color: "transparent",
                  }
                }
              ]
            },
            # 数据在这里
            {
              center: ["50%", "40%"]
              type: "pie",
              startAngle: 234,
              radius: ["52%", "75%"],
              labelLine: {
                normal: {
                  show: false
                }
              },
              data: [
                {
                  value: scope.value,
                  itemStyle: {
                    color: {
                      type: 'linear',
                      x: 0,
                      y: 0,
                      x2: 0,
                      y2: 1,
                      colorStops: [{
                        offset: 0, color: scope.parameters.startColor || "#3f3"
                      }, {
                        offset: 1, color: scope.parameters.endColor || "#f33"
                      }],
                      global: false
                    }
                  }
                },
                {
                  value: scope.blankArea,
                  itemStyle: {
                    color: "transparent",
                  }
                }
              ]
            }
          ]
        }
        # setTimeout(()->
        scope.myChart.setOption(option)
        scope.myChart.resize()
        # , 0 )
      )
      init = () => (
        return if not scope.firstload
        scope.myChart = echarts.init($(element).find(".pie-charts")[0])
        scope.blankArea = 1000
        scope.total = 1000
        scope.value = 0
        scope.labelValue = "0"
        scope.$watch "parameters", (msg) =>
          # return if msg.total == 0
          scope.total = msg.total || 1000
          scope.value = scope.parameters.value || 0
          blankArea = Number((scope.total * 0.25).toFixed(2)) # 应该多出来的面积
          addBlankTotal = blankArea + scope.total # 所有面积
          scope.blankArea = addBlankTotal - scope.value # 多余的空白面积
          if scope.parameters.showMode == "percent"
            scope.labelValue = (Number(( scope.value / scope.total )) *100).toFixed(0) + "%"
          else
            scope.labelValue = scope.value.toString() || "0"
          drawCharts()
        drawCharts()
      )
      init()

    resize: (scope)->
      scope.myChart.resize()

    dispose: (scope)->


  exports =
    ThreeQuarterPieDirective: ThreeQuarterPieDirective