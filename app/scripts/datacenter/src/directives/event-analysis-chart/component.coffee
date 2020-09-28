###
* File: event-analysis-chart-directive
* User: David
* Date: 2019/11/04
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'echarts'], (base, css, view, _, moment,echarts) ->
  class EventAnalysisChartDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "event-analysis-chart"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload

      legendMapping = {}
      scope.setting =
        title: "站点告警"
        severities: _.sortBy scope.project.typeModels.eventseverities.items,'key'
      scope.statistic = scope.parameters.statistic

      scope.onWindowResize = () =>
        deviceWidth = document.documentElement.clientWidth
        if deviceWidth < 1025
          scope.chartSeries =
            radius: ['35%', '47%']
            labelLine:
              normal:
                length: -10
            legend:
              itemGap: 5
              width: '100%'
              left: '2%'
              right: '0%'
        else
          scope.chartSeries =
            radius: ['40%', '52%']
            labelLine:
              normal:
                length: 5
            legend:
              orient: 'vertical'
              itemGap: 30
              width: '100%'
              left: '2%'
              right: '10%'
      scope.onWindowResize()

      draw = ()->
        return if not scope.setting or not scope.statistic or (scope.statistic is lastStatistic and scope.setting is lastSetting)
        lastSetting = scope.setting
        lastStatistic = scope.statistic

        scope.mychart.clear()
        scope.option = createChart scope.setting, scope.statistic
        scope.mychart.setOption scope.option, true


      getSeries = (setting, statistic) ->
        definitions = setting.severities ? {}
        severities = statistic.severities ? {}

        severityData = []
        for definition in definitions
          value = severities[definition.model.severity]
          severityData.push
            key: definition.model.severity
            name: definition.model.name
            value: value ? 0

        for d in severityData
          legendMapping[d?.name] = d?.key
        series = [
          {
            name: '告警等级'
            type: 'pie'
            radius: scope.chartSeries.radius
            center: ['50%', '50%']
            itemStyle:
              normal:
                label:
                  formatter: "{b}({c})"
            labelLine: scope.chartSeries.labelLine
            data: severityData
          }
        ]
        result =
          severityData: severityData
          series: series

      getLegend = (setting) ->
        legend = []

        for severity in setting?.severities
          legend.push severity?.model.name

        legend

      getColors = (setting) ->
        colors = []

        for severity in setting?.severities
          colors.push severity?.model.color
        colors

      getLegendSelected = (series) ->
        legendSelected = {}
        for item in series.severityData when not item.value
          legendSelected[item.name] = true

        legendSelected

      createChart = (setting, statistic) ->
        legend = getLegend setting
        colors = getColors setting
        series = getSeries setting, statistic
        legendSelected = getLegendSelected series

        option =
          title:
            text: setting.title ? '告警统计信息'
            textStyle:
              color: ["#ffffff"]
            subtextStyle:
              color: ["#ffffff"]
              align: 'center'
            left: 'center'
            y: 10
          tooltip:
            trigger: 'item'
            formatter: "{a} <br/>{b} : {c} ({d}%)"
          legend:
            show: true
            orient: 'horizontal'
            bottom: 20
            itemGap: scope.chartSeries.legend.itemGap
            itemWidth: 24
            itemHeight: 16
            width: scope.chartSeries.legend.width
            left: scope.chartSeries.legend.left
            right: scope.chartSeries.legend.right
            formatter: "{name}"
            data: legend
            selected: legendSelected
            textStyle:
              color:[]
          toolbox:
            show: true
            left: '82%'
            top: '2%'
            feature:
              mark: show: false
              dataView:
                show: false
                readOnly: false
              restore: show: false
              saveAsImage:
                show: true

          calculable: false
          color: colors
          series: series.series


      scope.mychart = echarts.init element[0]
      scope.mychart.on 'legendselectchanged', (evt) =>
        legends = {}
        for name, value of evt.selected
          key = legendMapping[name]
          legends[key] = value

        @commonService?.publishEventBus 'event-statistic-phase-severity',
          data:
            legends: legends
            change: evt.name

      scope.$watch 'parameters.statistic', (statistic) ->
        return if not statistic
        scope.statistic = scope.parameters.statistic
        draw()

    resize: (scope)->
      scope.onWindowResize()
      scope.mychart?.resize()

    dispose: (scope)->


  exports =
    EventAnalysisChartDirective: EventAnalysisChartDirective
