###
* File: card-manager-directive
* User: bingo
* Date: 2019/04/09
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CardManagerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "card-manager"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      element.css("display", "block")
      $scope.setting = setting
      $scope.addImg = @getComponentPath('image/add.svg')
      $scope.deleteImg = @getComponentPath('image/delete.svg')
      $scope.editImg = @getComponentPath('image/edit.svg')
      $scope.closeImg = @getComponentPath('image/close.svg')
      $scope.refreshImg = @getComponentPath('image/refresh.svg')
      $scope.saveImg = @getComponentPath('image/save.svg')
      $scope.uploadImg = @getComponentPath('image/upload.svg')
      $scope.linkImg = @getComponentPath('image/link.svg')
      $scope.downImg = @getComponentPath('image/download.svg')
      $scope.select = false     # 全选
      selectEquips = []         # 选择的设备
      $scope.pageIndex = 1      # 页数
      $scope.pageItems = 10     # 每页项
      $scope.cardEquips = []    # 卡设备
      $scope.sendCards = []     # 发卡器
      $scope.vendor = "hikvision"      #厂商ID 初始化取海康
      doorEquips = []
      peopleEquips = []
      cardEquips = []
      sendCards = []
      #获取所有设备厂商
      $scope.manufactorArr = []
      $scope.manufacturer = $scope.project.typeModels.vendors.items
      for value in $scope.manufacturer
        $scope.manufactorObj = {name:null,vendor:null}
        $scope.manufactorObj.name = value.model.name
        $scope.manufactorObj.vendor = value.model.vendor
        $scope.manufactorArr.push $scope.manufactorObj
      # 加载卡模板
      $scope.project.loadEquipmentTemplates {template: "card_template"}, 'user project type vendor template name base index image', (err, templates) =>
        return if err or templates.length < 1
        $scope.vendor = templates[0].model.vendor
        templates[0].loadProperties null, (err, properties) =>
          return if err or properties.length < 1
          $scope.properties = properties
      # 加载门禁设备
      loadEquipmentsByType = (refresh) =>
        $scope.cardEquips = []
        $scope.sendCards = []
        doorEquips = []
        peopleEquips = []
        cardEquips = []
        sendCards = []
        _.each $scope.stations, (station) =>
          @commonService.loadEquipmentsByType station, "access", (err, equips) =>
            _.each equips, (equip) =>
              equip.loadProperties()
              if equip.model.template.indexOf("door_") >= 0
                doorEquips.push equip
              if equip.model.template.indexOf("people_") >= 0
                peopleEquips.push equip
              if equip.model.template.indexOf("card_") >= 0
                cardEquips.push equip
              if equip.model.template is 'card-sender'
                sendCards.push equip
            $scope.peopleEquips = peopleEquips
            $scope.cardEquips = cardEquips
            $scope.sendCards = sendCards
          , refresh

      # 加载项目站点
      $scope.stations = @commonService.loadStationChildren $scope.station, true
      loadEquipmentsByType(true)

      # 选择页数
      $scope.selectPage = (page) =>
        $scope.pageIndex = page

      # 对设备进行分页设置
      $scope.filterEquipmentItem = ()=>
        return if not $scope.cardEquips
        items = []
        items = _.filter $scope.cardEquips, (equip) =>
          text = $scope.search?.toLowerCase()
          if not text
            return true
          return false
        pageCount = Math.ceil(items.length / $scope.pageItems)
        result = {page: 1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      # 限制每页的个数
      $scope.limitToEquipment = () =>
        if $scope.filterEquipmentItem() and $scope.filterEquipmentItem().pageCount is $scope.pageIndex
          aa = $scope.filterEquipmentItem().items % $scope.pageItems;
          result = -(if aa==0 then $scope.pageItems else aa)
        else
          result = -$scope.pageItems
        result

      # 格式化数据
      $scope.formatValue = (propertyId, value) =>
        val = ''
        property = _.find $scope.properties, (property) => property.model.property is propertyId
        if property
          arr = property.model.format.split(',')
          for i in arr
            if i.split(':')[0] == value
              val = i.split(':')[1]
        return val

      # 获取卡所属人
      $scope.getOweName = (oweId) =>
        namesStr = ""
        namesStr = (_.find peopleEquips, (tmp)->tmp.model.equipment is oweId)?.model.name
        return namesStr

      # 全选
      $scope.selectAll = () =>
        if $scope.select
          _.each $scope.cardEquips, (equip) =>
            equip.checked = true
            selectEquips.push equip.model.equipment
        else
          _.each $scope.cardEquips, (equip) =>
            equip.checked = false
            selectEquips = []
        selectEquips = _.uniq selectEquips

      # 单选
      $scope.selectOne = () =>
        _.each $scope.cardEquips, (equip) =>
          index = _.indexOf selectEquips, equip.model.equipment
          if equip.checked and index is -1
            selectEquips.push equip.model.equipment
          else if not equip.checked and index isnt -1
            selectEquips.splice(index, 1)
        if $scope.cardEquips.length is selectEquips.length
          $scope.select = true
        else
          $scope.select = false
        selectEquips = _.uniq selectEquips

      # 添加设备
      $scope.addEquip = () =>
        model =
          user: $scope.project.model.user
          project: $scope.project.model.project
          station: $scope.station.model.station
          equipment: ''
          name: ''
          type: 'access'
          vendor: $scope.vendor
          enable: true
          template: 'card_template'
        $scope.equipment = $scope.station.createEquipment model, null
        $scope.equipment.loadProperties()
        $scope.refreshData()

      # 删除设备
      $scope.deleteEquip = (equip)=>
        $scope.equipment = equip
        station = _.find $scope.stations, (station) => station.model.station is equip.model.station
        title = "删除设备确认: #{$scope.project.model.name}/#{station.model.name}/#{$scope.equipment.model.name}"
        message = "请确认是否删除设备: #{$scope.project.model.name}/#{station.model.name}/#{$scope.equipment.model.name}？删除后设备和数据将从系统中移除不可恢复！"
        $scope.prompt title, message, (ok) =>
          return if not ok
          $scope.equipment.remove (err, model) =>
            loadEquipmentsByType(true)

      # 选择人
      $scope.selectEquip = (card) =>
        $scope.equipment = card
        $scope.currentCard = {}
        $scope.currentCard.cardType = card.propertyValues['card-type']
        $scope.currentCard.cardId = card.propertyValues['card-id']
        $scope.currentCard.cardName = card.propertyValues['card-name']
        $scope.currentCard.cardOwner = card.propertyValues['card-owner']
        $scope.currentCard.cardStatus = card.propertyValues['card-status']
        $scope.currentCard.registrationTime = card.propertyValues['registration-time']
        $scope.currentCard.cardActiveStartTime = card.propertyValues['card-active-start-time']
        $scope.currentCard.cardActiveEndTime = card.propertyValues['card-active-end-time']
        $scope.currentCard.cardDescribe = card.propertyValues['card-describe']
        $scope.currentCard.cardDoor = card.propertyValues['card-door']
        $scope.currentCard.add = false
        $scope.currentCard.sendCard = '0'
        $scope.currentCard.vendor = card.model.vendor
        $scope.currentCard.station = card.model.station
      # 查找属性
      $scope.findProperty = (propertyId) =>
        property = _.find $scope.properties, (property) => property.model.property is propertyId
        return property if property
        return

      # 保存设备
      $scope.saveEquipment = () =>
        if not $scope.currentCard.cardId
          title = "ID不能为空"
          message = "ID不能为空，请获取ID。"
          return @display title,message
        if not $scope.currentCard.cardName
          title = "卡名称不能为空"
          message = "卡名称不能为空，请输入卡名称。"
          return @display title,message
        if $scope.currentCard.cardOwner is '0'
          title = "持卡人不能为空"
          message = "持卡人不能为空，请选择持卡人。"
          return @display title,message
        if $scope.currentCard.add
          card =  _.find cardEquips, (card) => card.model.equipment is $scope.currentCard.cardId
          if card
            title = "该卡已经存在"
            message = "该卡已经存在，请重新获取卡ID。"
            return @display title,message
#        if $scope.currentCard.cardStatus is '1'
#          $scope.currentCard.cardType = 3
        if not $scope.currentCard.cardActiveStartTime
          title = "有效开始时间不能为空"
          message = "有效开始时间不能为空，请输入有效开始时间。"
          return @display title,message
        if not $scope.currentCard.cardActiveEndTime
          title = "有效结束时间不能为空"
          message = "有效结束时间不能为空，请输入有效开始时间。"
          return @display title,message
        if $scope.currentCard.cardActiveEndTime && $scope.currentCard.cardActiveStartTime && (moment($scope.currentCard.cardActiveEndTime) < moment($scope.currentCard.cardActiveStartTime))
          title = "有效结束时间应该晚于有效开始时间"
          message = "有效结束时间应该晚于有效开始时间，请重新输入"
          return @display title,message
        if $scope.currentCard.vendor == "0"
          title = "设备厂商不能为空"
          message = "ID不能为空，请重新选择厂商"
          return @display title,message
        $scope.equipment.model.equipment = $scope.currentCard.cardId if not $scope.equipment.model.equipment
        $scope.equipment.model.name = $scope.currentCard.cardName
        $scope.equipment.model.vendor = $scope.currentCard.vendor
        $scope.equipment.model.station = $scope.currentCard.station
        _.map $scope.equipment.properties.items, (property) =>
          if property.model.property is "card-type"
            property.value = $scope.currentCard.cardType
          if property.model.property is "card-id"
            property.value = $scope.currentCard.cardId
          if property.model.property is "card-name"
            property.value = $scope.currentCard.cardName
          if property.model.property is "card-owner"
            property.value = $scope.currentCard.cardOwner
          if property.model.property is "card-status"
            property.value = $scope.currentCard.cardStatus
          if property.model.property is "registration-time"
            property.value = $scope.currentCard.registrationTime
          if property.model.property is "card-active-start-time"
            property.value = $scope.currentCard.cardActiveStartTime
          if property.model.property is "card-active-end-time"
            property.value = $scope.currentCard.cardActiveEndTime
          if property.model.property is "card-describe"
            property.value = $scope.currentCard.cardDescribe
          if property.model.property is "card-door"
            property.value = $scope.currentCard.cardDoor
        $scope.equipment.save (err, model) =>
          $scope.closeModal()
          loadEquipmentsByType(true)

      # 关闭弹出框
      $scope.closeModal = () =>
        $('#door-card-modal').modal('close')

      # 重置数据
      $scope.refreshData = () =>
        $scope.currentCard =
          cardType: '1'
          cardId:''
          cardName: 'new-card-name'
          cardOwner: '0'
          cardStatus: '1'
          registrationTime: moment().format("YYYY-MM-DD")
          cardActiveStartTime: moment().format("YYYY-MM-DD")
          cardActiveEndTime: moment().format("YYYY-MM-DD")
          cardDescribe: ''
          add: true
          sendCard: '0'
          vendor: '0'
          station: $scope.station.model.station

      #监听发卡器变化
      $scope.selectSendCard = () =>
        currentSendCard = _.find sendCards, (send) => send.model.equipment is $scope.currentCard.sendCard
        if currentSendCard
          currentSendCard.loadSignals null, (err, signals) =>
            return if err or signals.leader < 1
            getCardSignal = _.find signals, (signal) => signal.model.signal is "getCardID"
            if getCardSignal
              $scope.getCardSubscribe?.dispose()
              $scope.getCardSubscribe = @commonService.subscribeSignalValue getCardSignal, (signal) =>
                return if not signal or signal.data.value == "-"
                $scope.currentCard.cardId = signal.data.value
                len = signal.data.value.length
                while len < 10
                  signal.data.value = "0" + signal.data.value
                  len++
                $scope.currentCard.cardId = signal.data.value

      # 获取卡号
      $scope.getCardNumber = () =>
        currentSendCard = _.find sendCards, (send) => send.model.equipment is $scope.currentCard.sendCard
        if not currentSendCard
          @display "请选择发卡器！"
          return
        currentSendCard?.loadCommands null, (err, commands) =>
          return if err or commands.length < 1
          getCardNum = _.find commands, (cmd)->cmd.model.command is "card"
          if not getCardNum
            @display "模板配置错误，未找到控制命令！"
            return
          @executeCommand $scope, getCardNum
          $scope.commandSub?.dispose()
          $scope.commandSub = @commonService.subscribeCommandValue getCardNum, (cmd) =>
            return if cmd.data.phase is "executing"
            if cmd.data.phase is "complete" and cmd.data.command is "card"
              len = cmd.data.result.length
              while len < 10
                cmd.data.result = "0" + cmd.data.result
                len++
              $scope.currentCard.cardId = cmd.data.result

      # 过滤设备-设备列表
      $scope.filterCard = () =>
        (card) =>
          text = $scope.search?.toLowerCase()
          if not text
            return true
          if card.model.equipment.toLowerCase().indexOf(text) >= 0
            return true
          if card.model.name.toLowerCase().indexOf(text) >= 0
            return true
          if $scope.getOweName(card.getPropertyValue('card-owner'))?.toLowerCase().indexOf(text) >= 0
            return true
          if $scope.formatValue('card-type', card.getPropertyValue('card-type'))?.toLowerCase().indexOf(text) >= 0
            return true
          if $scope.formatValue('card-status', card.getPropertyValue('card-status'))?.toLowerCase().indexOf(text) >= 0
            return true
          return false

    resize: ($scope)->

    dispose: ($scope)->
      $scope.commandSub?.dispose()
      $scope.getCardSubscribe?.dispose()

  exports =
    CardManagerDirective: CardManagerDirective