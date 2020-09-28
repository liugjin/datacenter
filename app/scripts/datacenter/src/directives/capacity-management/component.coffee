###
* File: capacity-management-directive
* User: Billy
* Date: 2019/02/20
* Desc: 资产管理组件
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CapacityManagementDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "capacity-management"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.showSignal = [
        {id:'cooling',signal:'ratio-cooling',name:'制冷容量'}
        {id:'port',signal:'ratio-ports',name:'端口容量'}
        {id:'space',signal:'ratio-space',name:'U位容量',mid:true}
        {id:'power',signal:'ratio-power',name:'电力容量'}
        {id:'weight',signal:'ratio-weight',name:'承重容量'}
      ]

      getCapcityEquipment = (stationId,callback) =>
        @commonService.loadStation stationId, (err,station) =>
          @commonService.loadEquipmentById station, '_station_capacity', (err,equipment) =>
            return console.warn("equipment is null",equipment) if not equipment
            callback? err,equipment
          ,true
        ,true
      # 清除 旧数据
      initData=()=>
        for signal in scope.showSignal
          signal.data = null

      scope.$watch 'parameters.stationId', (stationId) =>
        getCapcityEquipment stationId, (err,capacity) =>
          scope.subSignal?.dispose()
          initData()
          scope.subSignal = @commonService.subscribeEquipmentSignalValues capacity, (sig) =>
            _.map scope.showSignal, (signal) ->
              if sig.model.signal is signal.signal
                signal['data'] = sig.data

    resize: (scope)->

    dispose: (scope)->
      scope.subSignal?.dispose()
      scope.subSignal = null


  exports =
    CapacityManagementDirective: CapacityManagementDirective