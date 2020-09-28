###
* File: device-tree-leon-directive
* User: David
* Date: 2019/08/13
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "fancytree"], (base, css, view, _, moment, fct) ->
  class DeviceTreeLeonDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-tree-leon"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      filter: "="
      filterType: "="
      alarms: "="

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # return if not scope.firstload
      # alarms 传进来会导致树一直重新渲染
      scope.search = ""
      scope.filter = scope.parameters.filter ? true
      sources = []
      join = (station) =>
        ret = {id: station.model.station, title: station.model.name, folder: true, level: "station"}
        ret.icon = @getIcon station.model.type
        if station.stations.length
          ret.children = []
          ret.children.push join sta for sta in station.stations
          ret.expanded = true
        else
          ret.lazy = true
          ret.expanded = false
        ret
      roots = _.filter scope.project.stations.items, (item) ->
        if item.model.station.charAt(0) isnt "_"
          not item.model.parent
      sources.push join(root) for root in roots
      element.find('.tree').fancytree {
        checkbox: scope.parameters.checkbox ? false
        selectMode: 3
#        autoActivate: true, #Automatically activate a node when it is focused using keyboard
        autoCollapse: true, # Automatically collapse all siblings, when a node is expanded
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
        lazyLoad: (event, data)=>
          # 在这里做告警查询 如果某个设备节点有告警，让它显示红色 (执行选择站点的操作)
          setTimeout(()->
            # 判断节点中哪些是在告警的 告警的背景设为红色
#            console.log data.node.children
            for item in data.node.children
              key = item.data.station+"."+item.data.id
              if scope.parameters.alarms[key]
                a = item.li
                $(a).find('.fancytree-title').css("background-color":"#EF5350")
          ,2000)

          selectNode = data.node
          if data.node.data.level is 'station'
            @publishEventBus "selectStation", selectNode.data

          arr = []
          station = _.find scope.project.stations.items, (item)->item.model.station is data.node.data.id && item.model.station.charAt(0) isnt "_"
          data.result = $.Deferred (dtd)=>
            arr = []
            station?.loadEquipments {type:{"$nin":["server", "_server", "video"]}, template:{"$nin":["people_template", "card_template"]}}, null, (err, equips)=>
              for equip in equips
                if equip.model.type.substr(0, 1) isnt "_"
                  arr.push {id: equip.model.equipment, title: equip.model.name, icon: @getIcon(equip.model.type), station: equip.station.model.station, level:"equipment"}
              dtd.resolve arr
        activate: (event, data)=>
#          console.log "---activate--"
          selectNode = data.node
          if data.node.data.level is 'equipment'
            equipKey = scope.project.key + "_" + selectNode.data.station + "_" + selectNode.data.id
            @commonService.publishEventBus 'treeEquipKey',{key:equipKey}
          else if data.node.data.level is 'station'
            @publishEventBus "selectStation", selectNode.data if event.clientX?

        beforeSelect: (event,data)=>
          parstations = []
          for item in scope.project.stations.items
            if item.stations.length
              parstations.push item.model.station

          a = event.originalEvent.target
          if data.node.data.level is 'station' and !data.node.children
#            console.log '如果为根站点 并且没有子设备'
            $(a).prev().trigger('click')
            setTimeout(()->
              $(a).prev().trigger('click')
              $(a).trigger('click')
              $(a).trigger('click')
            ,100)
          else if data.node.data.level is 'station' and data.node.data.id in parstations
#            console.log "如果选中的为父站点 要得到它的所有根子站点 并触发点击事件"
            for item in data.node.children
              button = item.span.children[0]
              checkbox = item.span.children[1]
              $(button).trigger("click")
              ((button,checkbox)->
                setTimeout(()->
                  $(button).trigger('click')
                  $(checkbox).trigger('click')
                  $(checkbox).trigger('click')
                ,1000)
              )(button,checkbox)


        select: (event, data)=>
          selects = []
          selectNodes = data.tree.getSelectedNodes()
          selects.push node.data for node in selectNodes
          @publishEventBus "checkEquips", selects
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
      return { html: '<img src="'+@getComponentPath("icons/#{type}.svg")+'" class="icon"/>' };

    resize: (scope)->

    dispose: (scope)->


  exports =
    DeviceTreeLeonDirective: DeviceTreeLeonDirective