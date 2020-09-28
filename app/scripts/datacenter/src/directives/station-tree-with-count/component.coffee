###
* File: station-tree-with-count-directive
* User: David
* Date: 2019/07/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationTreeWithCountDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-tree-with-count"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      filter: "="
      filterType: "="

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.search = ""
      scope.filter = scope.parameters.filter ? true
      sources = []
      keys = {}

      getCount = (station) =>
        count = keys[station.model.station]
        for sta in station.stations
          count += getCount sta
        count

      join = (station) =>
        ret = {id: station.model.station, key: station.model.station, title: station.model.name+"("+getCount(station)+")", folder: true, level: "station"}
        ret.icon = @getIcon station.model.type
        if station.stations.length
          ret.children = []
          ret.children.push join sta for sta in station.stations
          ret.expanded = true
        ret

      #获取需要过滤掉的设备类型
      nonTypes = _.filter scope.project.dictionary.equipmenttypes.items, (item) ->
        if scope.parameters.filterType
          item.model.type.charAt(0) is "_" or item.model.visible is false
        else
          item.model.type.charAt(0) is "_"
      items = _.map nonTypes, (item)->item.model.type

      loadEquipments = (station, callback) =>
        station.loadEquipments {type:{$nin:items}, template:{$nin:['card-sender', 'card_template', 'people_template']}}, null, (err, equips) =>
          keys[station.model.station] = equips?.length
          callback?()

      roots = _.filter scope.project.stations.items, (item)->not item.model.parent && item.model.station.charAt(0) isnt "_"
      n = 0
      for station in scope.project.stations.nitems
        loadEquipments station, =>
          n++
          if n is scope.project.stations.nitems.length
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
    StationTreeWithCountDirective: StationTreeWithCountDirective