###
* File: credit-records-directive
* User: bingo
* Date: 2019/03/28
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CreditRecordsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "credit-records"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      return if not $scope.firstload
      element.css("display", "block")
      $scope.setting = setting
      openDoorResults = [
        {result: 1, name: '开门成功'}
        {result: 2, name: '无效的用户卡刷卡'}
        {result: 3, name: '用户卡的有效期已过'}
        {result: 4, name: '当前时间用户卡无进入权限'}
      ]
      $scope.pageIndex = 1
      $scope.pageItems = 7
      $scope.equipments = null
      $scope.subBus = {}
      doorEquip = []
      $scope.peopleEquip = []
      $scope.cardEquip = []
      $scope.project.loadStations null, (err, stations) =>
        return if err or stations.length < 1
        $scope.stations = stations

      $scope.subBus["stationId"]?.dispose()
      $scope.subBus["stationId"] = @subscribeEventBus 'stationId', (d) =>
        @commonService.loadStation d.message.stationId, (err,station) =>
          $scope.station = station

      $scope.subBus["equipDoorId"]?.dispose()
      $scope.subBus["equipDoorId"] = @subscribeEventBus 'equipDoorId', (d) =>
        $scope.search = d.message.equipDoorId

      $scope.$watch "station", (station) =>
        return if not station
        loadEquipmentsByType () =>
          queryCreditSignal()

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
          return callback?() if equips.length == 0
          n = 0
          _.each equips, (equip) =>
            equip.loadProperties null, (err, properties) ->
              n++
              if equip.model.template.indexOf("door_") >= 0
                doorEquip.push equip
              if equip.model.template.indexOf("people_") >= 0
                $scope.peopleEquip.push equip
              if equip.model.template.indexOf("card_") >= 0
                $scope.cardEquip.push equip
              callback?() if n == equips.length

      # 查询刷卡记录
      queryCreditSignal = () =>
        $scope.creditRecords = null
        $scope.currentCreditInfo = null
        filter = $scope.station.getIds()
        filter.station = {$in: _.map @commonService.loadStationChildren($scope.station, true), (sta)->sta.model.station}
        filter.signal = "credit-card-info"
        filter.mode = "threshold"
        filter.startTime = moment().startOf('month').subtract(7, 'months')
        data =
          filter: filter
          fields: null
        @commonService.reportingService.querySignalRecords data, (err, records) =>
          return if err or records.length < 1
          filterRecords = []
          _.map records, (record) =>
            try
              record.value = JSON.parse record.value if typeof record.value == "string"
              currentDoor = _.find doorEquip, (equip) => equip.model.equipment == record.equipment
              if currentDoor and currentDoor.getPropertyValue("door-id") == record.value.door
                filterRecords.push record if !(_.contains filterRecords, record)
            catch e
              console.log e

          simpleData(filterRecords)

      # 获取开门结果
      getOpenDoorResult = (result) =>
        openDoorResult = _.find openDoorResults, (item) -> item.result == result
        if openDoorResult
          openDoorName = openDoorResult.name
        else
          openDoorName = '未知'
        openDoorName

      # 获取持卡人Name
      getCardOwner = (cardNo)->
        equipName = '未知'
        if cardNo? && cardNo > 0
          equip = _.find $scope.cardEquip, (equip)=>
            return equip.model.equipment == cardNo.toString()
          if equip
            userId = equip.getPropertyValue('card-owner')
            userEquip = _.find $scope.peopleEquip, (equip) => equip.model.equipment.toString() == userId
            equipName = userEquip.model.name if userEquip
        equipName

      # 简化数据(格式数据)
      simpleData = (records) =>
        return if records.length < 1
        dataRecords = []
        _.map records, (data) =>

          usernamestr= getCardOwner(data.value.cardNo)

          usernamestr=data.value.userName

          if (usernamestr =="" || usernamestr==undefined )
            if data.value.cardNo == 0
                ownerobj=(_.find $scope.userMsg ,(userobj)=>userobj.user == data.value.operator)
                usernamestr=ownerobj?.name
              else
                usernamestr=getCardOwner data.value.cardNo

          dataRecords.push {
            station: data.station
            equipment: data.equipment
            signal: data.signal
            cardNo: data.value.cardNo
            cardOwner: usernamestr
            result: getOpenDoorResult data.value.result
            timestamp: moment(data.timestamp).format("YYYY-MM-DD HH:mm:ss")
            stationName: (_.find $scope.stations, (station) -> data.station == station.model.station)?.model.name || ""
            equipmentName: (_.find $scope.equipments, (equip) -> (data.equipment == equip.model.equipment) && (data.station == equip.model.station))?.model.name || ""
          }
        $scope.creditRecords = (_.sortBy dataRecords, (record) => record.timestamp).reverse()
        $scope.currentCreditInfo = $scope.creditRecords[0]

      # 选择页数
      $scope.selectPage = (page) =>
        $scope.pageIndex = page

      # 对设备进行分页设置
      $scope.filterEquipmentItem = ()=>
        return if not $scope.creditRecords
        items = []
        items = _.filter $scope.creditRecords, (record) =>
          text = $scope.search?.toLowerCase()
          if not text
            return true
          if record.equipment.toLowerCase().indexOf(text) >= 0
            return true
          return false
        pageCount = Math.ceil(items.length/$scope.pageItems)
        result = {page:1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      # 限制每页的个数
      $scope.limitToEquipment = () =>
        if $scope.filterEquipmentItem() and $scope.filterEquipmentItem().pageCount == $scope.pageIndex
          aa = $scope.filterEquipmentItem().items % $scope.pageItems;
          result = -(if aa==0 then $scope.pageItems else aa)
        else
          result = -$scope.pageItems
        result

      # 过滤记录
      $scope.filterRecord = () =>
        (record) =>
          text = $scope.search?.toLowerCase()
          if not text
            return true
          if record.equipment.toLowerCase().indexOf(text) >= 0
            return true
          return false

    resize: ($scope)->

    dispose: ($scope)->
      _.map $scope.subBus, (value, key) =>
        value?.dispose()

  exports =
    CreditRecordsDirective: CreditRecordsDirective