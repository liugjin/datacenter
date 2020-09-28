###
* File: energy-management-directive
* User: David
* Date: 2019/02/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class EnergyManagementDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "energy-management"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      initData = () =>
        scope.showSignal = [
          {id:'office',name:'办公能耗',signal:'power-office-value',value:0}
          {id:'it',name:'IT能耗',signal:'power-it-value',value:0}
          {id:'other',name:'制冷和其他能耗',value:0}
          {id:'total',name:'总能耗',signal:'power-facility-value',value:0}
        ]
        scope.chartSignal = [
          {id:'office',name:'办公能耗',signal:'power-office-value',value:0, itemStyle:{normal:{color:"#43caff"}}}
          {id:'it',name:'IT能耗',signal:'power-it-value',value:0,itemStyle:{normal:{color:"#1d94ff"}}}
          {id:'other',name:'制冷和其他能耗',value:0,itemStyle:{normal:{color:"#bbd7f2"}}}
        ]
        scope.mychart = null
        chartelement = element.find('.ratio-pie')
        scope.mychart = echarts.init chartelement[0]

        scope.mychart?.clear()
        options = createChartOption(scope.chartSignal)
        scope.mychart.setOption options

      createChartOption = (getData) =>
        option =
          tooltip: {
            trigger: 'item',
            formatter: "{a} <br/>{b}: {c} ({d}%)"
          },
          series : [
            {
              name: '',
              type: 'pie',
              radius :['45%', '60%'],
              data: getData,
              labelLine: {
                normal: {
                  lineStyle: {
                    type: "dashed"
                  }
                }
              },
              itemStyle: {
                emphasis: {
                  shadowBlur: 10,
                  shadowOffsetX: 0,
                  shadowColor: 'rgba(0, 0, 0, 0.5)'
                }
              }
            }
          ]
        option

      initData()
      @getEquipment scope, "_station_efficient", ()=>
        scope.subSignal?.dispose()
        scope.subSignal = @commonService.subscribeEquipmentSignalValues scope.equipment, (sig) =>
          return if sig.model.signal not in ["power-office-value","power-it-value", "power-facility-value"]
          _.map scope.showSignal, (signal) ->
            if sig.model.signal is signal.signal
              signal['value'] = sig.data.formatValue

          total = _.find scope.showSignal, (sig) -> sig.id is "total"
          it = _.find scope.showSignal, (sig) -> sig.id is "it"
          office = _.find scope.showSignal, (sig) -> sig.id is "office"
          other = _.find scope.showSignal, (sig) -> sig.id is "other"
          other.value = parseFloat(total.value) - parseFloat(it.value) - parseFloat(office.value)

          _.map scope.chartSignal, (signal1) ->
            if sig.model.signal is signal1.signal
              signal1['value'] = sig.data.formatValue

          other1 = _.find scope.chartSignal, (sig) -> sig.id is "other"
          other1.value = other.value

          scope.mychart?.clear()
          options = createChartOption(scope.chartSignal)
          scope.mychart.setOption options

    resize: (scope)->
      scope.mychart?.resize()

    dispose: (scope)->
      scope.subSignal?.dispose()
      scope.subSignal = null


  exports =
    EnergyManagementDirective: EnergyManagementDirective