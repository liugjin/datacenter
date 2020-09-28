###
* File: equip-door-directive
* User: bingo
* Date: 2019/03/28
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipDoorDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equip-door"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      element.css("display", "block")
      $scope.setting = setting
      $scope.noEquipImg = @getComponentPath('image/door.png')
      $scope.equipments = null
      $scope.doorEquips = null
      $scope.pageIndex = 1
      $scope.pageItems = 6
      doorEquip = []

      $scope.project.loadStations null, (err, stations) =>
        return if err or stations.length < 1
        $scope.stations = stations

      $scope.subBus?.dispose()
      $scope.subBus = @subscribeEventBus 'stationId', (d) =>
        @commonService.loadStation d.message.stationId, (err,station) =>
          $scope.station = station

      $scope.$watch "station", (station) =>
        return if not station
        loadEquipmentsByType()

      # 加载门禁设备
      loadEquipmentsByType = (callback) =>
        $scope.equipments = null
        doorEquip = []
        mods = []
        getStationEquipment = (station, callback) =>
          for sta in station.stations
            getStationEquipment sta
          await @commonService.loadEquipmentsByType station, "access", defer(err, mod), false
          mods = mods.concat mod
          callback? mods
        getStationEquipment $scope.station, (equips) =>
          $scope.equipments = equips
          _.each equips, (equip) =>
            if equip.model.template.indexOf("door_") >= 0
              equip.loadProperties()
              equip.loadCommands()
              doorEquip.push equip
          $scope.doorEquips = doorEquip
          callback?()

      # 选择设备
      $scope.selectEquip = (equip) =>
        if $scope.equipment and $scope.equipment.model.equipment is equip.model.equipment
          $scope.equipment = null
          @commonService.publishEventBus "equipDoorId", {equipDoorId: ""}
        else
          $scope.equipment = equip
          @commonService.publishEventBus "equipDoorId", {equipDoorId: equip.model?.equipment}

      # 执行控制命令
      $scope.executeCommand = (door) =>
        doorNum = door.propertyValues['door-id']
        cmd = {}
        cmd = _.find door.commands.items, (item) -> item.model.command == "remote-open"
        if cmd
          $scope.prompt "执行远程开门确认", "请确认是否执行远程开门命令？", (ok) =>
            return if not ok
            cmd.model.parameters[0].value = doorNum
            @executeCommand $scope, cmd
        else
          @display "未配置命令"

      # 设备图片路径
      $scope.imgString = (str) =>
        url = ""
        if str
          url = "url('#{$scope.setting.urls.uploadUrl}/#{str}')"
        else
          url = "url('#{$scope.noEquipImg}')"
        return url

      # 选择页数
      $scope.selectPage = (page) =>
        $scope.pageIndex = page

      # 对设备进行分页设置
      $scope.filterEquipmentItem = ()=>
        return if not $scope.doorEquips
        items = []
        items = _.filter $scope.doorEquips, (equip) =>
          text = $scope.search?.toLowerCase()
          if not text
            return true
          return false
        pageCount = Math.ceil(items.length/$scope.pageItems)
        result = {page:1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      # 限制每页的个数
      $scope.limitToEquipment = () =>
        if $scope.filterEquipmentItem() and $scope.filterEquipmentItem().pageCount is $scope.pageIndex
          aa = $scope.filterEquipmentItem().items % $scope.pageItems;
          result = -(if aa==0 then $scope.pageItems else aa)
        else
          result = -$scope.pageItems
        result

    resize: ($scope)->

    dispose: ($scope)->
      $scope.subBus?.dispose()


  exports =
    EquipDoorDirective: EquipDoorDirective