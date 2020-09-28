###
* File: graphic-page-directive
* User: David
* Date: 2020/05/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class GraphicPageDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "graphic-page"
      super $timeout, $window, $compile, $routeParams, commonService
      @stationService = @commonService.modelEngine.modelManager.getService("stations")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) => (
      scope.treeData = []

      scope.stationMap = {}

      scope.stationId = scope.station.model.station

      initData = () => (
        if @$routeParams.station
          scope.stationId = @$routeParams.station
        console.log(scope.stationId)
        @getStation(scope, scope.stationId, null, true)
      )
      
      init = () => (
        scope.stationMap = {}
        @commonService.loadStations(null, (err, stations) =>
          _stations = _.map(stations, (sta) -> sta.model)
          result = @setStationTree(_stations)
          scope.treeData = result.treeData
          _.each(stations, (d) =>
            if d.model?.graphic && d.model?.graphic != ""
              scope.stationId = d.model.station
              scope.stationMap[d.model.station] = d.model?.graphic
          )
          initData()
        , true)
      )

      init()
      
      scope.subStation?.dispose()
      scope.subStation = @subscribeEventBus('list-breadcrumbs', (d) =>
        scope.stationId = d.message[0].key
        @getStation(scope, scope.stationId, null, true)
      )
    )

    # 转化 树组件需要的数据 并 滤出 站点类型 为 station 的数据
    setStation: (data, key) -> (
      parents = @group[key - 1]
      childs = []
      for item in data
        for parent in parents
          if item.parent == parent.key
            childs.push(item)
      if childs.length != 0
        @group[key] = childs
        newData = _.filter(data, (d) => !_.find(childs, (child) => child.key == d.key))
        @setStation(newData, key + 1)
    )

    setStationTree: (data, equips) -> (
      @group = []
      list = _.map(data, (d) -> {
        key: d.station,
        title: d.name,
        parent: d.parent,
        folder: false,
        type: d.type
      })
      list2 = _.map(equips, (d) -> {
        key: d.equipment,
        title: d.name,
        parent: d.parent,
        folder: false,
        type: d.type
      })
      @group[0] = _.filter(list, (d) -> d.parent == "")
      @setStation(_.filter(list, (d) -> d.parent != ""), 1)
      
      listData = []

      for x in [@group.length - 1..0]
        @group[x] = _.filter(@group[x], (d) => d.type == "station" || d.folder)
        listData = listData.concat(@group[x])
        if x != 0
          @group[x - 1] = _.map(@group[x - 1], (item) =>
            arr = _.filter(@group[x], (d) => d.parent == item.key)
            if arr.length != 0
              item.children = arr
              item.folder = true
            return item
          )
      return {
        treeData: @group,
        listData
      }
    )

    resize: (scope) ->

    dispose: (scope) -> (
      scope.subStation?.dispose()
    )

  exports =
    GraphicPageDirective: GraphicPageDirective