###
* File: equipment-timefilter-directive
* User: David
* Date: 2019/04/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'gl-datepicker'], (base, css, view, _, moment, gl) ->
  class EquipmentTimefilterDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-timefilter"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      dictToFormat = {
        now: "YYYY-MM-DD HH:mm:ss"
        day: "YYYY-MM-DD"
        week: "YYYY年第WW周"
        month: "YYYY-MM"
      }
      $scope.mode = "now"
      $scope.formatTime = moment().format(dictToFormat[$scope.mode])
      $scope.tabs = [
        { title: "实时", key: "now", desc: "设备实时数据"},
        { title: "日", key: "day", desc: "设备日历史数据"},
        { title: "周", key: "week", desc: "设备周历史数据"},
        { title: "月", key: "month", desc: "设备月历史数据"}
      ]

      # 切换tab
      $scope.selectMode = (tab) =>
        $scope.mode = tab
        $scope.formatTime = moment().format(dictToFormat[tab])
        @commonService.publishEventBus "equipment-time", { type: $scope.mode, time: $scope.formatTime }
        setGlDatePicker($('.datepicker')[0], $scope.formatTime)

      # refreshing 刷新
      $scope.refreshTime = (type) =>
        time = null
        if type == 0
          time = moment().format(dictToFormat[$scope.mode])
        else if type == 1 && $scope.mode != "week"
          time = moment($scope.formatTime).add(1, $scope.mode + "s").format(dictToFormat[$scope.mode])
        else if type == -1 && $scope.mode != "week"
          time = moment($scope.formatTime).subtract(1, $scope.mode + "s").format(dictToFormat[$scope.mode])
        else if type == 1 && $scope.mode = "week"
          time = moment().day("Monday").year($scope.formatTime.slice(0, 4)).week($scope.formatTime.slice(6,
            $scope.formatTime.length - 1)).add(1, "weeks").format(dictToFormat[$scope.mode])
        else if type == -1 && $scope.mode = "week"
          time = moment().day("Monday").year($scope.formatTime.slice(0, 4)).week($scope.formatTime.slice(6,
            $scope.formatTime.length - 1)).subtract(1, "weeks").format(dictToFormat[$scope.mode])
        $scope.formatTime = time
        @commonService.publishEventBus "equipment-time", { type: $scope.mode, time: $scope.formatTime }

      # datapicker 日历点击
      $scope.selectDate = () =>
        @commonService.publishEventBus "equipment-time", { type: $scope.mode, time: $scope.formatTime }

      $scope.showSelect = () =>
        if $('.gldp-default:first').offset().left == 0
          $('.gldp-default:first').css("left":$('.datepicker:first').offset().left + "px", "top": $('.datepicker:first').offset().top + "px")

      # datapicker组件配置
      setGlDatePicker = (element,value) ->
        return if not value
        if value.indexOf("-") == -1
          value = moment().day("Monday").year(value.slice(0, 4)).week(value.slice(6, $scope.formatTime.length - 1))
        setTimeout =>
          gl = $(element).glDatePicker({
            dowNames:["日","一","二","三","四","五","六"],
            monthNames:["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"],
            selectedDate: moment(value).toDate()
            onClick:(target,cell,date,data) =>
              target.val(moment(date).format(dictToFormat[$scope.mode])).trigger("change")
          })
        ,500



    resize: (scope)->

    dispose: (scope)->


  exports =
    EquipmentTimefilterDirective: EquipmentTimefilterDirective