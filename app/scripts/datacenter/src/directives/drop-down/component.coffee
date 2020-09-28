###
* File: drop-down-directive
* User: David
* Date: 2018/11/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DropDownDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "drop-down"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      $scope.selectedName = ''
      $scope.itemArr = []
      allSelect =
        id: 'all'
        name: '全选'
        checked: true

      $scope.$watch 'parameters.all', (allItems)=>
        return if not allItems
        #console.log allItems
        #allItems.push allSelect
        $scope.all = allItems
        for i in [0...Math.ceil allItems?.length / 10]
          item =
            index: i
            items: allItems.slice(i*10,(i+1)*10)
          $scope.itemArr.push item

      $scope.$watch 'parameters.selected', (selectedItem)=>
        return if not selectedItem
        #console.log selectedItem
        #orderItem selectedItem
        setItemName(selectedItem)

      # 单选
      $scope.selectOne = () =>
        selected = []
        _.each $scope.all, (item) =>
          if item.checked
            selected.push item.id.toString()
        @publishEventBus "drop-down-select", {origin: $scope.parameters.origin, selected: selected}
        setItemName selected

      # 选择checkbox
      $scope.selectItem = ($event, item)->
        index = _.indexOf $scope.parameters.selected, item.id.toString()
        if index > -1
          $scope.parameters.selected.splice index, 1
        else
          if $($event.target).is(':checked')
            $scope.parameters.selected.push item.id.toString()
        orderItem $scope.parameters.selected

      $scope.dropDown = ($event)=>
        $('.venting').slideUp 500
        $($($event.target).siblings('.venting')[0]).slideDown(500)

      # 对selected进行排序
      orderItem = (orderItem)=>
        newArr = []
        for item in $scope.all
          current = _.find orderItem, (single)=>
            return single is item.id.toString()
          if current
            newArr.push current
        setItemName(newArr)

      # 设置选中的值
      setItemName = (selectedItem)=>
        $scope.selectedName = ''
        for item in selectedItem
          current = _.find $scope.all, (single) => single.id.toString() is item
          if current
            $scope.selectedName += current.name + ','
        $scope.selectedName = $scope.selectedName.slice(0, $scope.selectedName.length-1)

    resize: ($scope)->

    dispose: ($scope)->


  exports =
    DropDownDirective: DropDownDirective