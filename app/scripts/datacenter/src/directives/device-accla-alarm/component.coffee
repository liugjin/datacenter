###
* File: device-accla-alarm-directive
* User: David
* Date: 2019/12/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "fancytree"], (base, css, view, _, moment, fct) ->
  class DeviceAcclaAlarmDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-accla-alarm"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if !scope.parameters.template or scope.parameters.template == ""

      scope.search = ""
      scope.filter = scope.parameters.filter ? true
      sources = []
      # 获取子节点
      join = (station) =>
        ret = {id: station.model.station, title: station.model.name, folder: true, level: "station", index: station.model.index}
        ret.icon = @getIcon station.model.type
        if station.stations.length
          ret.children = []
          # 回调
          for sta in station.stations
            result = join(sta)
            ret.children.push(result)
          # 排序子站点
          ret.children = _.sortBy(ret.children, (d) -> d.index)
          ret.expanded = true
        else
          ret.lazy = true
          ret.expanded = false
        return ret

      # 获取父站点第一层 + 根据索引排序
      roots = _.sortBy(_.filter(scope.project.stations.items, (item) ->
        if item.model.station.charAt(0) isnt "_"
          return !item.model.parent
        else
          return false
      ), (d) -> d.model.index)

      sources.push(join(root)) for root in roots

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
        lazyLoad: (event, data)=>
          arr = []
          station = _.find scope.project.stations.items, (item)->item.model.station is data.node.data.id && item.model.station.charAt(0) isnt "_"
          data.result = $.Deferred (dtd)=>
            arr = []
            station?.loadEquipments { type: scope.parameters.template }, null, (err, equips)=>
              _.each equips,(equip)=>
                if equip.model.type.substr(0, 1) isnt "_"
                  arr.push {id: equip.model.equipment, title: equip.model.name, icon: @getIcon(equip.model.type), station: equip.station.model.station, level:"equipment"}

              dtd.resolve arr
        activate: (event, data)=>
          selectNode = data.node
          @publishEventBus "selectEquip", selectNode.data

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
    DeviceAcclaAlarmDirective: DeviceAcclaAlarmDirective