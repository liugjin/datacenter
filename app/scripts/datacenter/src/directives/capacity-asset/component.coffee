###
* File: capacity-asset-directive
* User: David
* Date: 2019/02/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CapacityAssetDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "capacity-asset"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 初始化构造单位映射
      if !scope.unitMap
        scope.unitMap = {}
        _.each(@project.dictionary.signaltypes.items, (d) => 
          scope.unitMap[d.model.type] = d.model.unit
        )
      
      hrefContent = "#/capacity-2d/#{scope.project.model.user}/#{scope.project.model.project}?station=#{scope.station.model.station}&signalId="
      # 页面展示默认值
      scope.showSignal = [{
        href: hrefContent + "space",
        id:"space", 
        name:"空间", 
        usedSignal:"used-space", 
        totalSignal:"rated-space", 
        ratioSignal:"ratio-space", 
        imgUrl:"#{@getComponentPath('images/space.png')}"
      }, {
        href: hrefContent + "power",
        id:"power", 
        name:"电力", 
        usedSignal:"used-power", 
        totalSignal:"rated-power", 
        ratioSignal:"ratio-power", 
        imgUrl:"#{@getComponentPath('images/power.png')}"
      }, {
        href: hrefContent + "cooling",
        id:"cooling", 
        name:"制冷", 
        usedSignal:"used-cooling", 
        totalSignal:"rated-cooling", 
        ratioSignal:"ratio-cooling", 
        imgUrl:"#{@getComponentPath('images/cooling.png')}"
      }, {
        href: hrefContent + "weight",
        id:"weight", 
        name:"承重", 
        usedSignal:"used-weight", 
        totalSignal:"rated-weight", 
        ratioSignal:"ratio-weight", 
        imgUrl:"#{@getComponentPath('images/weight.png')}"
      }, {
        id:"ports", 
        name:"端口", 
        usedSignal:"used-ports", 
        totalSignal:"rated-ports", 
        ratioSignal:"ratio-ports", 
        imgUrl:"#{@getComponentPath('images/ports.png')}"
      }]
      
      # 需要订阅的信号
      _.each(scope.subscribeArr, (d) => d.dispose()) if scope.subscribeArr
      scope.subscribeArr = {}
      subSignalArr = [
        "used-space", "rated-space", "ratio-space", # 空间
        "used-power", "rated-power", "ratio-power", # 电力
        "used-cooling", "rated-cooling", "ratio-cooling", # 制冷
        "used-weight", "rated-weight", "ratio-weight", # 承重
        "used-ports", "rated-ports", "ratio-ports" # 端口
      ]
      
      # 设备加载 - 站点容量管理设备
      scope.station.loadEquipment("_station_capacity", null, (err, equip) =>
        return console.error("告警: " + err) if err
        return console.warn("该站点没有配置容量管理设备!!") if !equip
        filter = equip.getIds()
        _.each(subSignalArr, (sigId, index) =>
          id = Math.ceil((index + 1) / 3) - 1
          filter.signal = sigId
          scope.subscribeArr[sigId] = @commonService.signalLiveSession.subscribeValues(filter, (err2, d) =>
            return console.error("告警: " + err2) if err2
            if index % 3 == 0
              scope.showSignal[id].usedValue = d.message.value
            else if index % 3 == 1
              scope.showSignal[id].totalValue = d.message.value
              if _.has(scope.unitMap, d.message.unit)
                scope.showSignal[id].unit = scope.unitMap[d.message.unit].toUpperCase()
            else
              scope.showSignal[id].ratioValue = d.message.value
          )
        )
      )

    resize: (scope) ->

    dispose: (scope) ->
      _.each(scope.subscribeArr, (d) => d.dispose())

  exports =
    CapacityAssetDirective: CapacityAssetDirective