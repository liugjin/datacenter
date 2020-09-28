###
* File: station-tree-directive
* User: David
* Date: 2018/11/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationTreeDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-tree"
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
        ret = {id: station.model.station, key: station.model.station, title: station.model.name, folder: true, level: "station"}
        ret.icon = @getIcon station.model.type
        if station.stations.length
          ret.children = []
          ret.children.push join sta for sta in station.stations
          ret.expanded = true
        ret
      roots = _.filter scope.project.stations.items, (item)->not item.model.parent && item.model.station.charAt(0) isnt "_"
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
        activate: (event, data)=>
          selectNode = data.node
          #          console.log selectNode.data
          @publishEventBus "selectStation", selectNode.data if event.clientX?
        select: (event, data)=>
          selects = []
          selectNodes = data.tree.getSelectedNodes()
          selects.push node.data for node in selectNodes
          #          console.log selects
          @publishEventBus "checkStations", selects
      }

      if scope.station.model.station
        tree = $.ui.fancytree.getTree()
#        node = tree.findFirst (item)-> item.data.id is scope.station.model.station
        tree.activateKey(scope.station.model.station)

      scope.filterTree = ->
        tree = $.ui.fancytree.getTree()
        opts = {"autoApply":true,"autoExpand":true,"fuzzy":false,"hideExpanders":false,"highlight":true,"leavesOnly":false,"nodata":false}
        filterFunc = tree.filterBranches
        match = scope.search
        filterFunc.call(tree, match, opts);

      scope.clearSearch = ->
        scope.search = ""

    getIcon: (type) ->
      return { html: '<img src="'+@getComponentPath("icons/#{type}.svg")+'" class="icon"/>' };

    resize: (scope)->

    dispose: (scope)->


  exports =
    StationTreeDirective: StationTreeDirective