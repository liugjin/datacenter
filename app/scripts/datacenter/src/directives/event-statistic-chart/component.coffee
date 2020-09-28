###
* File: event-statistic-chart-directive
* User: David
* Date: 2018/11/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'echarts'], (base, css, view, _, moment,echarts) ->
  class EventStatisticChartDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "event-statistic-chart"
      super $timeout, $window, $compile, $routeParams, commonService


    setScope: ->
      statistic: '='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      legendMapping = {}
      scope.setting =
        title: "站点告警"

        subTitle: '按告警状态类型统计'
        severities: scope.project.typeModels.eventseverities.items
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
        option = createChart scope.setting, scope.statistic
        scope.mychart.setOption option, true
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
          legendMapping[d.name] = d.key

        statisticData = [
          {
            key: 'start'
            name: "开始告警"
            value: statistic.counts.startEvents ? 0
          }
          {
            key: 'end'
            name: "结束告警"
            value: statistic.counts.endEvents ? 0
          }
          {
            key: 'confirm'
            name: "确认告警"
            value: statistic.counts.confirmedEvents ? 0
          }
        ]

        for d in statisticData
          legendMapping[d.name] = d.key

        series = [
          {
            name: '告警状态'
            type: 'pie'
            selectedMode: 'single'
            radius: [0, '30%']
            center: ['50%', '50%']
            itemStyle:
              normal:
                label:
                  position: 'inner'
                  formatter: (params) ->
                    if not params.value
                      return ""

                    return "#{params.name}(#{params.value})"
                labelLine:
                  show: false

            data: statisticData
          }
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
          statisticData: statisticData
          severityData: severityData
          series: series

      getLegend = (setting) ->
        legend = [
          "开始告警"
          "结束告警"
          "确认告警"
        ]

        for severity in setting?.severities
          legend.push severity?.model.name

        legend

      getColors = (setting) ->
        colors = [
          '#3B87ED'   # start
          '#5ABE7D'   # end
          '#74F3FD'  # confirm
        ]

        for severity in setting?.severities
          colors.push severity?.model.color

        colors

      getLegendSelected = (series) ->
        # disable the type if its count equals to 0
        legendSelected = {}
        for item in series.statisticData when not item.value
          legendSelected[item.name] = false
        for item in series.severityData when not item.value
          legendSelected[item.name] = false

        legendSelected
      createChart = (setting, statistic) ->
        legend = getLegend setting
        colors = getColors setting
        series = getSeries setting, statistic
        legendSelected = getLegendSelected series

        option =
          title:
            text: setting.title ? '告警统计信息'
            subtext: setting.subTitle
            textStyle:
              color: ["#ffffff"]
            subtextStyle:
              color: ["#ffffff"]

            x: 'center'
          tooltip:
            trigger: 'item'
            formatter: "{a} <br/>{b} : {c} ({d}%)"
          legend:
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
      #          console.log evt
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
    EventStatisticChartDirective: EventStatisticChartDirective