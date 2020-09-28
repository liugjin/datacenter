###
* File: component-pie-directive
* User: James
* Date: 2019/04/18
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts","jquery.ui"], (base, css, view, _, moment, echarts) ->
  class ComponentPieDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "component-pie"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      #初始化图表
      @menuSubscribe?.dispose()
      @menuSubscribe = @subscribeEventBus 'menuState', (d) =>
        @$timeout =>
          @mychart?.resize()
        ,0
      scope.chartValue = scope.parameters.chartValue
      @mychart = null
      chartelement = element.find('.chart-pie')
      @mychart = echarts.init chartelement[0]
      @oldclickdata = null
      @mychart.on('click',(params)=>
        if scope.parameters.legendNames
          if params.name isnt @oldclickdata
            @oldclickdata = params.name
            if (_.indexOf scope.parameters.legendNames,params.name)>=0
              @commonService?.publishEventBus 'task-process-statics',{data:params.name}
      )

      createChartOption = (resscope,value) =>
        #dataformat
        #{orderid:1,name:"a",value:1}
        sortValue = []
        if value?.length > 0
          sortValue = _.sortBy value,(vItem)->
            return vItem.orderid

        data = []
        legendColors = [{startcolor:"#db115b",stopcolor:"#ff5c00"},{startcolor:"#62a89d",stopcolor:"#a7d68d"},{startcolor:"#5597fc",stopcolor:"#7edfd7"}]
        if !_.isEmpty scope.parameters.piecolors
          legendColors = scope.parameters.piecolors
        legendata= []
        colorCount = 0
        for valItem in sortValue
          legendata.push valItem.name
          serialdata =
            value: valItem.value,
            name: valItem.name,
            itemStyle:
              normal:
                color: { # 完成的圆环的颜色
                  colorStops: [{
                    offset: 0,
                    color: legendColors[colorCount].startcolor #0% 处的颜色
                  }, {
                    offset: 1,
                    color: legendColors[colorCount].stopcolor #100% 处的颜色
                  }]
                },
              label: {
                show: false
              },
              labelLine: {
                show: false
              }
          colorCount++
          data.push serialdata
          tooltipformatter= "{a} <br/>{b}: {c} ({d}%)"


        option =
          title: {
            text: scope.parameters.centertitle || "",
            x: 'center',
            y: 'center',
            textStyle: {
              fontWeight: 'normal',
              color: '#e6283f',
              fontSize: '16'
            }
          },
          tooltip: {
            trigger: 'item',
#            formatter: "{a} <br/>{b}: {c} ({d}%)"
#            formatter: "{a} <br/>{b}: ({d}%)"
            formatter: tooltipformatter

          },
          legend:
            orient: 'horizontal'
            x: 'center'
#            y: 'center'
            bottom: '5%'
            data: legendata
            itemGap: 22,
            textStyle:
              color: '#fff'
#          color: acolor
          series:[
            {
              name: scope.parameters.title,
              type:'pie',
              radius: ['35%', '50%'],
#              avoidLabelOverlap: false,
#              clockwise: true,
              itemStyle:
                normal:
                  label:
                    show: true
                    color: "white"
#                    position:'inside',
                    formatter: '{b} : {c} ({d}%)'
                  labelLine:
                    show: true

              hoverAnimation: true,
              data: data
            }
          ]
        option

      scope.$watch "chartValue", (data)=>
        return if not data
        @mychart?.clear()
        options = createChartOption(scope,data)
        @mychart.setOption options
      ,true


    resize: (scope)->
      @$timeout =>
        @mychart?.resize()
      ,0
    dispose: (scope)->
      @mychart?.dispose()


  exports =
    ComponentPieDirective: ComponentPieDirective