###
* File: visualization-tree-directive
* User: David
* Date: 2019/01/16
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class VisualizationTreeDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "visualization-tree"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.search = ""
      scope.filter = scope.parameters.filter ? true
      sources = []

      join = (station) =>
        ret = {id: station.model.station, title: station.model.name, folder: true, level: "station"}
        ret.icon = @getIcon station.model.type
        if station.stations.length and station.model.type isnt "station"
          ret.children = []
          ret.children.push join sta for sta in station.stations
          ret.expanded = true
          ret.lazy = true
        else
          ret.expanded = false
          ret.lazy = true
        ret

      roots = _.filter scope.project.stations.items, (item) ->
        if item.model.station.charAt(0) isnt "_"
          not item.model.parent
      sources.push join(root) for root in roots

      element.find('.tree').fancytree {
        checkbox: scope.parameters.checkbox ? false
        selectMode: 3
        source: sources
        extensions: ["filter"]
        filter:
          autoApply: true,   ## Re-apply last filter if lazy data is loaded
          autoExpand: true, # Expand all branches that contain matches while filtered
          counter: true,     # Show a badge with number of matching child nodes near parent icons
          fuzzy: false,      # Match single characters in order, e.g. 'fb' will match 'FooBar'
          hideExpandedCounter: true,  # Hide counter badge if parent is expanded
          hideExpanders: false,       # Hide expanders if all child nodes are hidden by filter
          highlight: true,   # Highlight matches by wrapping inside <mark> tags
          leavesOnly: false, # Match end nodes only
          nodata: true,      # Display a 'no data' status node if result is empty
          mode: "hide"       # Grayout unmatched nodes (pass "hide" to remove unmatched node instead)
        lazyLoad: (event, data) =>
          arr = []
          station = _.find scope.project.stations.items, (item) ->item.model.station is data.node.data.id and item.model.station.charAt(0) isnt "_"
          data.result = $.Deferred (dtd) =>
            arr = []
            station?.loadEquipment "_station_management", null, (err, equipment) =>
              equipment?.loadProperties null, (err, properties) =>
                configdiagram = _.find properties, (property) -> property.model.property is "configdiagram"
                #以下处理tree的懒加载数据
                if station.stations.length is 0 #无下级站点无组态图
                  if !configdiagram
                    arr.push {id: "no-message", title: "暂无信息", icon: @getIcon("null"), level:"station"}
                    dtd.resolve arr
                    return
                  else if configdiagram.value.length is 0
                    arr.push {id: "no-message", title: "暂无信息", icon: @getIcon("null"), level:"station"}
                    dtd.resolve arr
                    return

                if station.stations.length > 0 #有下级站点无组态图
                  if !configdiagram or configdiagram.value.length is 0
                    _.map station.stations, (child) =>
                      arr.push {id: child.model.station, title: child.model.name, icon: @getIcon(child.model.type), station: child.model.station, level:"station", expanded: false, lazy: true}
                      dtd.resolve arr
                    return

                if station.stations.length > 0 #有下级站点有组态图
                  _.map station.stations, (child) =>
                    arr.push {id: child.model.station, title: child.model.name, icon: @getIcon(child.model.type), station: child.model.station, level:"station", expanded: false, lazy: true}
                  if configdiagram or configdiagram.value.length > 0
                    try
                      visualization = JSON.parse configdiagram.value
                      _.map visualization, (vis) =>
                        arr.push {id: vis.id, title: vis.title, icon: @getIcon("visualization"), level:"visualization"}
                      dtd.resolve arr
                    catch error
                      console.log error
                    return

                if station.stations.length is 0 #无下级站点有组态图
                  if configdiagram or configdiagram.value.length > 0
                    try
                      visualization = JSON.parse configdiagram.value
                      _.map visualization, (vis) =>
                        arr.push {id: vis.id, title: vis.title, icon: @getIcon("visualization"), level:"visualization"}
                      dtd.resolve arr
                    catch error
                      console.log error
                    return

        activate: (event, data) =>
          selectNode = data.node
          @publishEventBus "selectStation", selectNode.data
        select: (event, data)=>
          selects = []
          selectNodes = data.tree.getSelectedNodes()
          selects.push node.data for node in selectNodes
          @publishEventBus "checkStations", selects
      }

      scope.filterTree = ->
        tree = $.ui.fancytree.getTree()
        opts = {"autoApply":true,"autoExpand":true,"fuzzy":false,"hideExpanders":false,"highlight":true,"leavesOnly":false,"nodata":false}
        filterFunc = tree.filterBranches
        match = scope.search
        filterFunc.call(tree, match, opts);

      scope.clearSearch = ->
        scope.search = ""

    getIcon: (type) ->
      switch type
        when "visualization"
          return { html: '<img src="'+@getComponentPath("icons/visualization.svg")+'" class="icon"/>' };
        when "null"
          return { html: '<img src="'+@getComponentPath("icons/null.svg")+'" class="icon"/>' };
        when "site"
          return { html: '<img src="'+@getComponentPath("icons/site.svg")+'" class="icon"/>' };
        when "datacenter"
          return { html: '<img src="'+@getComponentPath("icons/datacenter.svg")+'" class="icon"/>' };
        when "station"
          return { html: '<img src="'+@getComponentPath("icons/station.svg")+'" class="icon"/>' };
        when "central-station"
          return { html: '<img src="'+@getComponentPath("icons/station.svg")+'" class="icon"/>' };
    resize: (scope)->

    dispose: (scope)->


  exports =
    VisualizationTreeDirective: VisualizationTreeDirective