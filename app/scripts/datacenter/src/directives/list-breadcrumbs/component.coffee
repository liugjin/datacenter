###
* File: list-breadcrumbs-directive
* User: David
* Date: 2020/04/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ListBreadcrumbsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "list-breadcrumbs"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) => (
      return if !scope.firstload
      
      scope.group = []
      scope.groupName = []
      scope.groupList = []
      scope.level = 0

      scope.change = (obj, level) => (
        scope.groupName[level] = obj.title
        scope.level = level
        if obj.folder
          scope.groupName[level + 1] = "选择下级"
          scope.groupList[level + 1] = obj.children
          scope.groupName = scope.groupName.slice(0, level + 2)
          scope.groupList = scope.groupList.slice(0, level + 2)
        else
          scope.groupName = scope.groupName.slice(0, level + 1)
        if scope.parameters?.needChild || !_.has(scope.parameters, "needChild")
          @list = []
          @getAllChild(obj)
          result = _.map(@list, (d) ->
            obj = {}
            _.each(d, (val, key) =>  
              obj[key] = val if key != "children"
            )
            return obj
          )
          @commonService.publishEventBus("list-breadcrumbs", result)
        else
          @commonService.publishEventBus("list-breadcrumbs", obj)
      )

      initData = (data) => (
        if data.length > 0 && !@$routeParams[scope.parameters?.key] && !scope.parameters?.stationId
          scope.group = data
          _root = scope.group[0][0]
          scope.groupName = if _root.folder then [_root.title, "选择下级"] else [_root.title]
          scope.groupList = if _root.folder then [scope.group[0], _root.children] else [scope.group[0]]
          scope.level = 0
        else if data.length > 0 && (@$routeParams[scope.parameters?.key] || scope.parameters?.stationId)
          stationId = if @$routeParams[scope.parameters?.key] then @$routeParams[scope.parameters?.key] else scope.parameters?.stationId
          scope.group = data
          _.each(scope.group, (group, index) =>
            _.each(group, (g) =>
              if g.key == stationId
                scope.groupName = @getAllParents(scope.group, g, index)
                scope.level = index + 1
                scope.groupList = if g.folder then scope.group.slice(0, scope.level + 1) else scope.group.slice(0, scope.level)
            )
          )
        else
          scope.group = []
          scope.groupName = []
          scope.level = 0
        scope.$applyAsync()
      )

      # 接参
      scope.$watch("parameters.data", (data) => initData(data))
    )

    getAllParents: (data, item, index) -> (
      current = item
      @list = if current.folder then [current.title, "选择下级"] else [current.title]
      if index > 0
        _.each([index - 1..0], (i) =>
          _.each(data[i], (d) => 
            if d.key == current.parent
              current = d
              @list.unshift(current.title)
          )
        )
      return @list
    )

    # 获取所有节点下属
    getAllChild: (data) -> (
      @list.push(data)
      if data.folder
        for i in [0..data.children.length-1]
          @getAllChild(data.children[i])
    )

    resize: (scope)->

    dispose: (scope)->


  exports =
    ListBreadcrumbsDirective: ListBreadcrumbsDirective