###
* File: paging-equipment-directive
* User: David
* Date: 2019/12/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class PagingEquipmentDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "paging-equipment"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.pages = { page: [], current: 1 } # 分页参数, 专用于刷新分页
      scope.count = 1
      # 分页初始化
      initPage = (len) =>(
        arr = []
        if len > 0
          count = Math.ceil(len / 10)
          if count <= 10
            arr.push(x) for x in [count..1]
          else
            for x in [count..1]
              if x <= 3 || x >= count - 2
                arr.push(x)
              else if x == 4
                arr.push(-2)
              else if x == count - 3
                arr.push(-1)
        scope.pages = { page: arr, current: 1 }
      )

      checkPage = (pages) -> (
        _pages = _.uniq(pages)
        _pageItems = _.filter(_pages, (d) -> d > 0)
        if _pageItems.length == 6
          return pages
        else
          _pageItems.push(-5) if _pages[_pages.length - 1] == 0
          _pageItems.unshift(-4) if _pages[0] == -3
          return _pageItems
      )

      # 分页点击切换页面
      scope.update = (page) => (
        return if scope.pages.current == page
        count = Math.ceil(scope.count / 10)
        if page <= 0 && count > 10
          if scope.pages.page.indexOf(-1) == -1 && scope.pages.page.indexOf(-2) == -1
            if page == -4
              max = _.max(scope.pages.page)
              min = _.min(_.filter(scope.pages.page, (p) -> p > 0))
              scope.pages.page = [max + 3, max + 2, max + 1, -1, -2, min + 2, min + 1, min]
            else if page == -5
              max = _.max(scope.pages.page)
              min = _.min(_.filter(scope.pages.page, (p) -> p > 0))
              scope.pages.page = [max, max - 1, max - 2, -1, -2, min - 1, min - 2, min - 3]
            scope.pages.page.unshift(-3) if scope.pages.page[0] != count
            scope.pages.page.push(0) if scope.pages.page[scope.pages.page.length - 1] != count
            return scope.$applyAsync()
          len = scope.pages.page.length
          if page == 0
            scope.pages.page = _.map(scope.pages.page, (d, i) => if (i >= 5 && d > 0) then d - 3 else d)
            scope.pages.page = _.filter(scope.pages.page, (d) -> d != 0) if scope.pages.page[len - 1] == 0 && scope.pages.page[len - 2] == 1
          else if page == -1
            scope.pages.page = _.map(scope.pages.page, (d, i) => if (i <= 3 && d > 0) then d - 3 else d)
            scope.pages.page.unshift(-3) if scope.pages.page[0] > 0 && scope.pages.page != count
          else if page == -2
            scope.pages.page = _.map(scope.pages.page, (d, i) => if (i >= 5 && d > 0) then d + 3 else d)
            scope.pages.page.push(0) if scope.pages.page[len - 1] > 1
          else if page == -3
            scope.pages.page = _.map(scope.pages.page, (d, i) => if (i <= 3 && d > 0) then d + 3 else d)
            scope.pages.page = _.filter(scope.pages.page, (d) -> d != -3) if scope.pages.page[1] == count
          scope.pages.page = checkPage(scope.pages.page)

          return scope.$applyAsync()
        scope.pages.current = page

        @commonService.publishEventBus 'pageTemplate', page

          # scope.data = allData[scope.currentType].slice(10 * page - 10, 10 * page)
        scope.$applyAsync()
      )

      scope.$watch("parameters.count", (count) =>
        if scope.count != count
          scope.count = count
          initPage(scope.count)
      )

      initPage(scope.parameters.count)


    resize: (scope)->

    dispose: (scope)->


  exports =
    PagingEquipmentDirective: PagingEquipmentDirective