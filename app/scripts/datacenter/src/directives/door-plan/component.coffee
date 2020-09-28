###
* File: door-plan-directive
* User: David
* Date: 2019/04/11
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DoorPlanDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "door-plan"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      element.css("display", "block")
      $scope.setting = setting
      $scope.doorImg = @getComponentPath('image/door-manage.svg')
      $scope.noEquipImg = @getComponentPath('image/door.png')
      $scope.closeImg = @getComponentPath('image/close.svg')
      $scope.saveImg = @getComponentPath('image/save.svg')
      $scope.cancelImg = @getComponentPath('image/cancel.svg')
      $scope.doorEquips = []
      $scope.cardEquips = []
      $scope.peopleEquips = []
      doorEquips = []
      peopleEquips = []
      cardEquips = []
      $scope.select = false     # 全选
      selectEquips = []         # 选择的设备
      $scope.pageIndexCard = 1      # 页数
      $scope.pageItemsCard = 4     # 每页项
      $scope.pageIndexAuthorize = 1      # 页数
      $scope.pageItemsAuthorize = 12     # 每页项
      doorCommands = []
      doorIndex = null
      cardNo = null
      userPassword = null
      userId = null
      expireDate = null
      cardType = null
      byCardValid = null
      byDoorRight = null
      fingerid = null

      findParent = ($scope, station) =>
        parent = _.find $scope.project.stations.items, (sta) ->sta.model.station is station.model.parent
        if parent
          $scope.parents.push parent
          findParent $scope, parent

      dataCenters = _.filter $scope.project.stations.items, (sta)->_.isEmpty sta.model.parent
      $scope.datacenters = dataCenters
      $scope.parents = []
      findParent $scope, $scope.station
      $scope.stations = $scope.parents[0]?.stations
      $scope.parents = $scope.parents.reverse()

      # 加载卡模板
      $scope.project.loadEquipmentTemplates {template: "card_template"}, 'user project type vendor template name base index image', (err, templates) =>
        return if err or templates.length < 1
        templates[0].loadProperties null, (err, properties) =>
          return if err or properties.length < 1
          $scope.cardProperties = properties

      $scope.selectStation = (station) ->
        $scope.station = station

      $scope.selectChild = (station) ->
        $scope.stations = $scope.station.stations
        $scope.parents.push $scope.station
        $scope.station = station

      $scope.selectParent = (station) ->
        index = $scope.parents.indexOf(station)
        $scope.parents.splice index, $scope.parents.length-index
        $scope.station = station
        $scope.stations = station.parentStation?.stations ? $scope.datacenters

      $scope.$watch "station", (station) =>
        return if not station
        loadEquipmentsByType()

      # 加载门禁设备
      loadEquipmentsByType = (callback) =>
        $scope.currentDoor = null
        $scope.currentCard = null
        $scope.cardsData = null
        $scope.equipments = null
        $scope.doorEquips = []
        $scope.cardEquips = []
        $scope.peopleEquips = []
        doorEquips = []
        peopleEquips = []
        cardEquips = []
        mods = []
#        kaishi
        for sta in $scope.project.stations.items
          @commonService.loadEquipmentsByType sta, "access", (err,model)=>
            $scope.equipments = _.uniq model
            _.each model, (equip) =>
              equip.loadProperties()
              if equip.model.template.indexOf("door_") >= 0
                doorEquips.push equip
              if equip.model.template.indexOf("people_") >= 0
                peopleEquips.push equip
              if equip.model.template.indexOf("card_") >= 0
                cardEquips.push equip
            $scope.doorEquips = doorEquips
            $scope.cardEquips = cardEquips
            $scope.peopleEquips = peopleEquips
            if doorEquips.length > 0
              selectEquip = null
              if @$routeParams.equipment?
                selectEquip = _.find doorEquips,(equip) => equip.model.equipment is @$routeParams.equipment
              if not selectEquip
                selectEquip = doorEquips[0]
              $scope.selectDoor selectEquip

          , false


      init = () =>
        doorCommands = []
        doorIndex = null
        cardNo = null
        userPassword = null
        userId = null
        expireDate = null
        cardType = null
        byCardValid = null
        byDoorRight = null
        fingerid = null

      # 选择门设备
      $scope.selectDoor = (door) =>
        $scope.currentDoor = door
        $scope.currentDoorSignals = {}
        init()
        getAuthorizeList(door)
        element.find('#equipments').hide()
        door?.loadSignals null, (err, signals) =>
          filter=
            user: $scope.station.model.user
            project: $scope.station.model.project
            station: $scope.station.model.station
            equipment: door.model.equipment
          $scope.oneSubscription2?.dispose()
          $scope.oneSubscription2 = @commonService.signalLiveSession.subscribeValues filter, (err, d) =>
            if not err and d.message
              $scope.currentDoorSignals[d.message.signal] = d.message
        door.loadCommands null, (err, commands) =>

          return if err or commands.length < 1
          if door.model.vendor is "weigeng"

            # 远程开门 remote-open
            doorCommandRemoteOpen = _.find commands, (cmd) -> cmd.model.command is "remote-open" if !err
            doorIndex = _.find doorCommandRemoteOpen?.model.parameters, (ps) -> ps.key is "door"
            doorCommands.push doorCommandRemoteOpen

            # 时间同步 door-time
            doorCommandDoorTime = _.find commands, (cmd) -> cmd.model.command is "door-time" if !err
            doorCommands.push doorCommandDoorTime

            # 增加门禁卡 add-cards
            doorAddCards = _.find commands, (cmd) -> cmd.model.command is "add-cards" if !err
            doorCommands.push doorAddCards
            cardNo = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "cardNo"
            expireDate = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "expireDate"
            byDoorRight = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "byDoorRight"

          if door.model.vendor== "hikvision"

            # 远程开门 remote-open
            doorCommandRemoteOpen = _.find commands, (cmd) -> cmd.model.command is "remote-open" if !err
            doorIndex = _.find doorCommandRemoteOpen?.model.parameters, (ps) -> ps.key is "door"
            doorCommands.push doorCommandRemoteOpen

            # 时间同步 door-time
            doorCommandDoorTime = _.find commands, (cmd) -> cmd.model.command is "door-time" if !err
            doorCommands.push doorCommandDoorTime

            # 增加门禁卡 6
            doorAddCards = _.find commands, (cmd) -> cmd.model.command is "add-cards" if !err
            doorCommands.push doorAddCards
            cardNo = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "cardNo"
            userPassword = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "userPassword"
            userId = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "userId"
            expireDate = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "expireDate"
            cardType = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "cardType"
            byCardValid = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "byCardValid"
            byDoorRight = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "byDoorRight"
            fingerid = _.find doorAddCards?.model.parameters, (ps) -> ps.key is "fingerprint"

        , false

      # 选择页数
      $scope.selectPageAuthorize = (page) =>
        $scope.pageIndexAuthorize = page

      # 对设备进行分页设置
      $scope.filterAuthorizeItem = ()=>
        return if not $scope.cardsData
        items = []
        items = _.filter $scope.cardsData, (equip) =>
          text = $scope.search?.toLowerCase()
          if not text
            return true
          return false
        pageCount = Math.ceil(items.length / $scope.pageItemsAuthorize)
        result = {page: 1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      # 限制每页的个数
      $scope.limitToAuthorize = () =>
        if $scope.filterAuthorizeItem() and $scope.filterAuthorizeItem().pageCount is $scope.pageIndexAuthorize
          aa = $scope.filterAuthorizeItem().items % $scope.pageItemsAuthorize;
          result = -(if aa==0 then $scope.pageItemsAuthorize else aa)
        else
          result = -$scope.pageItemsAuthorize
        result

      # 选择页数
      $scope.selectPageCard = (page) =>
        $scope.pageIndexCard = page

      # 对卡设备进行分页设置
      $scope.filterCardEquipItem = ()=>
        return if not $scope.cardEquips
        items = []
        items = _.filter $scope.cardEquips, (equip) =>
          text = $scope.search?.toLowerCase()
          if not text
            return true
          return false
        pageCount = Math.ceil(items.length / $scope.pageItemsCard)
        result = {page: 1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      # 限制卡列表每页的个数
      $scope.limitToCardEquip = () =>
        if $scope.filterCardEquipItem() and $scope.filterCardEquipItem().pageCount is $scope.pageIndexCard
          aa = $scope.filterCardEquipItem().items % $scope.pageItemsCard;
          result = -(if aa==0 then $scope.pageItemsCard else aa)
        else
          result = -$scope.pageItemsCard
        result

      # 格式化数据
      $scope.formatValue = (propertyId, value) =>
        val = ''
        property = _.find $scope.cardProperties, (property) => property.model.property is propertyId
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

      # 通过卡ID获取持卡人姓名
      $scope.getUserNameByCard = (cardId) =>
        nameStr = ""
        oweId = (_.find cardEquips, (tmp)->tmp.model.equipment is cardId)?.getPropertyValue('card-owner')
        nameStr = $scope.getOweName(oweId)
        nameStr
      $scope.getcardtype = (cardType) =>
        cardtypesrt="1类卡"
        if cardType?
          switch cardType
            when '1'
              cardtypesrt="1类卡"
              break
            when '2'
              cardtypesrt="2类卡"
              break
            when '3'
              cardtypesrt="3类卡"
              break
            when '4'
              cardtypesrt="4类卡"
              break
            else
              cardtypesrt = "1类卡"
              break
        return cardtypesrt

      $scope.getcardstatus = (byCardValid) =>
        cardstatusstr="正常"
        if byCardValid?
          switch byCardValid
            when '1'
              cardstatusstr="正常"
              break
            when '0'
              cardstatusstr="挂失"
              break
            else
              cardstatusstr = "正常"
              break
        return cardstatusstr

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

      # 门禁卡授权初始化变量
      $scope.addDoorCardAuthorize = ()->
        mJson = {}
        mJson[$scope.currentDoor.getPropertyValue('door-id')] = 1
        str = JSON.stringify mJson
        $scope.doorCardAuthorize =
          cardType: '1'
          cardId: ''
          userPassword: ''
          userId: ''
          expireDate: moment().format("YYYY-MM-DD")
          byCardValid: ''
          byDoorRight: str
          fingerid:''

      # 选择卡
      $scope.selectCardEquip = (card) =>
        $scope.currentCard = card
        $scope.doorCardAuthorize.cardType = card.getPropertyValue('card-type')
        $scope.doorCardAuthorize.cardTypeName = $scope.formatValue('card-type', card.getPropertyValue('card-type'))
        $scope.doorCardAuthorize.cardId = card.getPropertyValue('card-id')
        $scope.doorCardAuthorize.userId = $scope.doorCardAuthorize.cardId.substr(-8)
        $scope.doorCardAuthorize.byCardValid = card.getPropertyValue('card-status')
        $scope.doorCardAuthorize.expireDate = card.getPropertyValue('card-active-end-time')
        $scope.doorCardAuthorize.fingerid =card.getPropertyValue('finger-id')

# 门禁卡授权验证
      $scope.confirmDoorCardAuthorize = ()->
        if not $scope.doorCardAuthorize.cardType or not $scope.doorCardAuthorize.cardId  or not $scope.doorCardAuthorize.userId
          @display "请选择一个卡"
          return
        if not $scope.doorCardAuthorize.userPassword
          $scope.doorCardAuthorize.userPassword = "123456"
        setDoorRight () =>
          $scope.executeCommand("add-cards")

      # 设置门权限
      setDoorRight = (callback) =>
        byDoorRight = {}
        authorizeJson = null    # 当前卡授权过的门
        cardAuthorize = $scope.currentCard.getPropertyValue('card-door')
        if cardAuthorize
          if typeof cardAuthorize is 'string'
            authorizeJson = JSON.parse(cardAuthorize)
          else
            authorizeJson = cardAuthorize
          currentSampleUnit = _.find $scope.currentDoor.model.sampleUnits, (sample) => sample.id is "su" #or sample.id is "su-1"
          currentSampleUnit = (_.find $scope.currentDoor.model.sampleUnits, (sample) => sample.id is "su-1") if not currentSampleUnit
          if currentSampleUnit
            currentDoorGroup = _.filter doorEquips, (door) => door.sampleUnits[currentSampleUnit.id].value is currentSampleUnit.value
            _.each currentDoorGroup, (door) =>
              if authorizeJson and authorizeJson[door.model.equipment]
                byDoorRight[door.getPropertyValue('door-id')] = 1
                #byDoorRight[door.getPropertyValue('door-id')] = parseInt authorizeJson[door.model.equipment].byCardValid
            byDoorRight[$scope.currentDoor.getPropertyValue('door-id')] = 1
            doorRightJson = JSON.stringify byDoorRight
            $scope.doorCardAuthorize.byDoorRight = doorRightJson
        callback?()

      # 执行控制
      $scope.executeCommand = (commandId) =>
        return if not commandId
        commandObj = null
        if $scope.currentDoor.model.vendor is "hikvision" and doorCommands
          commandObj = _.find doorCommands, (cmd) => cmd.model.command is commandId
          return @display "模板未配置此命令！" if not commandObj
          switch commandId
            when "remote-open"
              doorIndex.value = 1
            when "door-time"
              console.log commandObj
            when "add-cards"
              try
                cardNo?.value = $scope.doorCardAuthorize.cardId
                userPassword?.value = $scope.doorCardAuthorize.userPassword
                userId?.value = $scope.doorCardAuthorize.userId
                expireDate?.value = moment($scope.doorCardAuthorize.expireDate).format("YYYYMMDD")
                cardType?.value = $scope.doorCardAuthorize.cardType
                byCardValid?.value = $scope.doorCardAuthorize.byCardValid
                byDoorRight?.value = $scope.doorCardAuthorize.byDoorRight
                commandObj.model.parameters[6].value= byDoorRight.value
                fingerid?.value=$scope.doorCardAuthorize.fingerid
              catch
                console.log("hikvision-doorCommands-add-cards-参数缺少")
            else
              return
          @executeCommand($scope, commandObj)
          setTimeout =>
            filter =
              user: $scope.station.model.user
              project: $scope.station.model.project
              station: $scope.station.model.station
              equipment: $scope.currentDoor.model.equipment
              command: commandObj.model.command
            $scope.oneSubscription?.dispose()
            $scope.oneSubscription = @commonService.commandLiveSession.subscribeValues filter, (err, d) =>
              if !err and d.message
                #@display "操作成功" if d.message.phase is "complete"
                #@display "操作失败" if d.message.phase is "error"
                #@display "操作超时" if d.message.phase is "timeout"
                if d.message.phase is "complete" and d.message.command is "add-cards"
                  setDoorAuthorize(d.message)
          , 100
        if $scope.currentDoor.model.vendor is "weigeng" and doorCommands
          commandObj = _.find doorCommands, (cmd) => cmd.model.command is commandId
          return @display "模板未配置此命令！" if not commandObj
          switch commandId
            when "remote-open"
              doorIndex.value = 1
            when "door-time"
              console.log commandObj
            when "add-cards"
              cardNo?.value = $scope.doorCardAuthorize.cardId
              expireDate?.value = moment($scope.doorCardAuthorize.expireDate).format("YYYYMMDD")
              byDoorRight?.value = $scope.doorCardAuthorize.byDoorRight
            else
              return
          @executeCommand($scope, commandObj)
          setTimeout =>
            filter =
              user: $scope.station.model.user
              project: $scope.station.model.project
              station: $scope.station.model.station
              equipment: $scope.currentDoor.model.equipment
              command: commandObj.model.command
            $scope.oneSubscription1?.dispose()
            $scope.oneSubscription1 = @commonService.commandLiveSession.subscribeValues filter, (err, d) =>
              if !err and d.message
                #@display "操作成功" if d.message.phase is "complete"
                #@display "操作失败" if d.message.phase is "error"
                #@display "操作超时" if d.message.phase is "timeout"
                if d.message.phase is "complete" and d.message.command is "add-cards"
                  setDoorAuthorize(d.message)
          , 100

      # 设置门授权列表
      setDoorAuthorize = (message)->
        a = {}
        _.each message.parameters, (param) =>
          if param.key is 'expireDate'
            year = parseInt(param.value.substring(0,4))
            month = parseInt(param.value.substring(4,6))-1
            day = parseInt(param.value.substring(6))
            param.value = moment().set({'year': year, 'month': month, 'date': day}).format("YYYY-MM-DD")
          a[param.key] = param.value
        cardAuthorize = $scope.currentCard.getPropertyValue('card-door')
        if not cardAuthorize
          cardAuthorize = {}
        cardAuthorize[$scope.currentDoor.model.equipment] = a
        _.map $scope.currentCard.properties.items, (property) =>
          if property.model.property is "card-door"
            property.value = cardAuthorize
        $scope.currentCard.setPropertyValue 'card-door', cardAuthorize
        $scope.currentCard.save (err, model) =>
          getAuthorizeList($scope.currentDoor)

      # 获取门授权列表
      getAuthorizeList = (equip)->
        $scope.accessData = true
        cardsData = []
        _.each cardEquips, (card)=>
          cardDoor = card.getPropertyValue('card-door')
          if typeof cardDoor is 'string'
            mJson = JSON.parse(cardDoor)
          else
            mJson = cardDoor
          if mJson? and mJson[equip.model.equipment]
            cardsData.push mJson[equip.model.equipment]
        $scope.cardsData = cardsData

      # 关闭弹出框
      $scope.closeModal = () =>
        $('#door-plan-modal').modal('close')

    resize: ($scope)->

    dispose: ($scope)->
      $scope.oneSubscription?.dispose()
      $scope.oneSubscription1?.dispose()
      $scope.oneSubscription2?.dispose()


  exports =
    DoorPlanDirective: DoorPlanDirective