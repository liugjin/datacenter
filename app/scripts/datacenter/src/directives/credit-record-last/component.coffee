###
* File: credit-record-last-directive
* User: bingo
* Date: 2019/03/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CreditRecordLastDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "credit-record-last"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attr) =>
      return if not $scope.firstload
      element.css("display", "block")
      $scope.setting = setting
      openDoorResults = [
        {result: 1, name: '开门成功'}
        {result: 2, name: '无效的用户卡刷卡'}
        {result: 3, name: '用户卡的有效期已过'}
        {result: 4, name: '当前时间用户卡无进入权限'}
      ]
      $scope.equipments = null
      doorEquip = []
      $scope.peopleEquip = []
      $scope.cardEquip = []
      $scope.project.loadStations null, (err, stations) =>
        return if err or stations.length < 1
        $scope.stations = stations

      $scope.subBus?.dispose()
      $scope.subBus = @subscribeEventBus 'stationId', (d) =>
        @commonService.loadStation d.message.stationId, (err,station) =>
          $scope.station = station

      $scope.$watch "station", (station) =>
        return if not station
        loadEquipmentsByType () =>
          queryCreditSignal()
      # 加载所有的用户
      $scope.loadAllUsers = () =>
        userService = @commonService.modelEngine.modelManager.getService 'users'
        filter = {}
        fields = null
        userService.query filter, fields, (err, data) =>
          if not err
            $scope.userMsg = data
      $scope.loadAllUsers()

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
            equip.loadProperties()
            if equip.model.template.indexOf("door_") >= 0
              doorEquip.push equip
            if equip.model.template.indexOf("people_") >= 0
              $scope.peopleEquip.push equip
            if equip.model.template.indexOf("card_") >= 0
              $scope.cardEquip.push equip
          callback?()

      # 查询刷卡记录
      queryCreditSignal = () =>
        $scope.currentCreditInfo = null
        filter = $scope.station.getIds()
        filter.station = {$in: _.map @commonService.loadStationChildren($scope.station, true), (sta)->sta.model.station}
        filter.signal = "credit-card-info"
        filter.mode = "threshold"
        filter.startTime = moment().startOf('day').subtract(7, 'days')
        data =
          filter: filter
          fields: null
        @commonService.reportingService.querySignalRecords data, (err, records) =>
          return if err or records.length < 1
          filterRecords = []
          _.map records, (record) =>
            record.value = JSON.parse record.value if typeof record.value == "string"
            currentDoor = _.find doorEquip, (equip) => equip.model.equipment is record.equipment
            if currentDoor and currentDoor.getPropertyValue("door-id") == record.value.door
              filterRecords.push record if !(_.contains filterRecords, record)
          simpleData(filterRecords)

      # 获取开门结果
      getOpenDoorResult = (result) =>
        openDoorResult = _.find openDoorResults, (item) -> item.result is result
        if openDoorResult
          openDoorName = openDoorResult.name
        else
          openDoorName = '未知'
        openDoorName

      # 获取持卡人Name
      getCardOwner = (cardNo)->
        equipName = '未知'
        equip = _.find $scope.cardEquip, (equip)=>
          return equip.model.equipment is cardNo
        if equip
          userId = equip.getPropertyValue('card-owner')
          userEquip = _.find $scope.peopleEquip, (equip) => equip.model.equipment is userId
          equipName = userEquip.model.name if userEquip
        equipName

      # 简化数据(格式数据)
      simpleData = (records) =>
        $scope.creditRecords = null
        $scope.currentCreditInfo = null
        return if records.length < 1
        dataRecords = []
        _.map records, (data) =>
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

    resize: ($scope)->

    dispose: ($scope)->
      $scope.subBus?.dispose()


  exports =
    CreditRecordLastDirective: CreditRecordLastDirective