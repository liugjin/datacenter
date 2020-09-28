###
* File: lineorbar-echart-directive
* User: David
* Date: 2020/01/03
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class LineorbarEchartDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "lineorbar-echart"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.mychart = null
      chartelement = element.find('.chart-line')
      scope.mychart = echarts.init chartelement[0]
      max = 31

      scope.$watch "parameters.chartValues", (data) =>

        values = _.sortBy(_.sortBy(data, 'index'), 'name')
        type = 'line' if !type
        legendData = _.uniq _.pluck values, 'name'
        xAxisData = _.uniq _.pluck values, 'key'
        yNameData = _.uniq _.pluck values, 'category'
        yNameData = [''] if _.isEmpty yNameData
        seriesData = []
        for value, index in legendData
          data =
            name: value
            data: _.pluck(_.where(values, {name:value, category: yNameData[index]}), 'value')
            yAxisIndex: index
          seriesData.push data
        series = [{
          name:''
          type:'line'
          symbol: "none"
          smooth:true
          data:[]
          lineStyle:
            normal:
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: '#1A45A2'
                }, {
                  offset: 1, color: '#00E7EE'
                }]
              }
          areaStyle:
            normal:
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                offset: 0, color: '#1A45A2'
              }, {
                offset: 0.34, color: '#00E7EE'
              }, {
                offset: 1, color: '#00e7ee33'
              }])
        }, {
          name:''
          type:'line'
          smooth:true
          symbol: "none"
          data:[]
          lineStyle:
            normal:
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: '#90D78A'
                }, {
                  offset: 1, color: '#1CAA9E'
                }]
              }
          areaStyle:
            normal:
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                offset: 0, color: '#90D78A'
              }, {
                offset: 0.34, color: '#1CAA9E'
              }, {
                offset: 1, color: '#1caa9e33'
              }])
        }, {
          name:''
          type:'line'
          smooth:true
          symbol: "none"
          data:[]
          lineStyle:
            normal:
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: '#F9722C'
                }, {
                  offset: 1, color: '#FF085C'
                }]
              }
          areaStyle:
            normal:
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                offset: 0, color: '#F9722C'
              }, {
                offset: 0.34, color: '#FF085C'
              }, {
                offset: 1, color: '#ff085c33'
              }])
        }]

        if xAxisData.length > max
          xAxisData = xAxisData.slice(xAxisData.length - max, xAxisData.length)

        for d,i in seriesData
          series[i].name = yNameData[i]
          if d.data.length > max
            series[i].data = d.data.slice(d.data.length - max, d.data.length)
          else
            series[i].data = d.data
          if xAxisData.length < (series[i].data.length - 1)
            series[i].data.slice(0, series[i].data.length - 1)

        _legendData = _.map(legendData, (d,i) => {name:yNameData[i],icon:"image://" + @getComponentPath('image/color'+(i+1)+'.svg')})
        option =
          tooltip:
            trigger: "axis"
          legend:
            show: true
            orient: "horizontal"
            right: "10%"
            textStyle:
              fontSize: 14
              color: "#FFFFFF"
            data: _legendData
          toolbox:
            show: true
            right: 20
            feature:
              dataZoom:
                show: false
              dataView:
                show: false
              magicType:
                type: ['line', 'bar']
              restore:
                show: false
              saveAsImage:
                show: false
          xAxis:[{
            data : xAxisData
            boundaryGap: false
            nameLocation: "middle"
            axisLine:
              lineStyle:
                color: "#204BAD"
            axisLabel:
              textStyle:
                color: "#A2CAF8"
              rotate: 30
              interval: 0
              fontSize: 14
              margin: 16
          }]
          yAxis: [{
            type : 'value'
            axisLine:
              lineStyle:
                color: "#204BAD"
            axisLabel:
              textStyle:
                color: "#A2CAF8"
            splitLine:
              lineStyle:
                color: ["#204BAD"]
          }]
          series: series.slice(0, seriesData.length)
        if typeof scope.parameters.legend == "boolean" and !scope.parameters.legend
          option.legend.show = false
        if typeof scope.parameters.switch == "boolean" and !scope.parameters.switch
          option.toolbox.show = false
        if _.has(scope.parameters, "tip")
          option.tooltip.formatter = scope.parameters.tip
        scope.mychart.clear()
        scope.mychart.setOption(option)




    resize: (scope)->
      @$timeout =>
        scope.mychart?.resize()
      ,0

    dispose: (scope)->
      scope.mychart?.dispose()


  exports =
    LineorbarEchartDirective: LineorbarEchartDirective