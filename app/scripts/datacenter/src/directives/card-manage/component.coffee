###
* File: card-manage-directive
* User: David
* Date: 2019/04/01
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CardManageDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "card-manage"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      scope.factory = new dmf.DeviceModelFactory
      scope.cards = []
      scope.cardArr = []
      scope.peoplesselectoptions = [{id: '0', name: '请选择'}]
      scope.sendCardOptions = [{id:'0', name:'请选择'}]
      scope.currentcard = {}
      #数据来源是model中access/card_template
      scope.cardType =
        1: {type: '1', name: '普通卡'}
        2: {type: '2', name: '残疾人卡'}
        3: {type: '3', name: '黑名单卡'}
        4: {type: '4', name: '巡更卡'}
        5: {type: '5', name: '胁迫卡'}
        6: {type: '6', name: '超级卡'}
        7: {type: '7', name: '来宾卡'}
        8: {type: '8', name: '解除卡'}
        9: {type: '9', name: '员工卡'}
        10: {type: '10', name: '应急卡'}
        11: {type: '11', name: '应急管理卡'}
      scope.cardstatus=
        0: {type: '0', name: '挂失'}
        1: {type: '1', name: '正常'}
      scope.cardSelected = false
      console.log(scope.cardType)

      scope.data =

        cardtype: '1'
        cardid:''
        cardname: 'new-card-name'
        cardowner:'0'
        cardstatus: '1'
        registrationtime:moment().format("YYYY-MM-DD")
        cardactiveendtime:moment().format("YYYY-MM-DD")
        cardactivestarttime: moment().format("YYYY-MM-DD")
        carddescribe: ''
        add: true
        sendCard: '0'


      @datacenters = @project.stations.roots
      ids =
        user: @$routeParams.user
        project: @$routeParams.project
      scope.user=ids.user
      scope.project=ids.project
      # data center is the station whose parent is null
      console.log(@datacenters)
      @datacenter =  @datacenters[0]
      console.log(@datacenter)


      scope.selectStation = (station) ->
#      return false if not super station
        console.log(station)
        scope.station = station
        @station = station
        scope.data.user = @station.model.user
        scope.data.project = @station.model.project
        scope.data.station = @station.model.station


        scope.peoples = []
        #        console.log scope.station.equipment
        scope.cardEquips = []

        scope.station.loadEquipments {type: "access"}, null, (err, equips)=>
          return if err
          #          for equip in equips
          #          _.map equips, (equip) ->
          equips.forEach (equip) ->
            equip?.loadProperties()
            #            undefined 要考虑兼容
            scope.cardEquips.push equip if equip.propertyValues['card-active-end-time'] isnt undefined
            if equip.model.template is 'people_template'
              a={id: equip.getPropertyValue('people-id'), name: equip.getPropertyValue('people-name')}
              if !scope.peoplesselectoptions.includes a
                scope.peoplesselectoptions.push a
              scope.peoples.push equip
          console.log scope.cardEquips



          #          scope.isCoverCard(card) for card in scope.cardEquips
          _.map scope.cardEquips, (card) ->
            scope.isCoverCard(card)
          scope.cardEquips = scope.cardArr
          scope.cardArr = []
          console.log scope.cardArr
        ,true



      scope.selectStation @datacenter

      scope.isCoverCard = (card) ->
        if card.getPropertyValue('card-id') == scope.station.equipment.getPropertyValue('card-id')
          card = scope.station.equipment
          scope.cardArr.push card
        else
          scope.cardArr.push card

      scope.getOwername = (owerid)->
        namestr=""
        namestr=(_.find scope.peoples, (tmp)->tmp.model.equipment is owerid)?.model.name

        return namestr
      # 选择卡
      scope.selectCard =(card)->
#console.log card
        scope.cardSelected = true
        card.loadProperties()
        scope.data.cardtype = card.propertyValues['card-type']
        scope.data.cardid = card.propertyValues['card-id']
        scope.data.cardname = card.propertyValues['card-name']
        scope.data.cardowner = card.propertyValues['card-owner']
        scope.data.cardstatus = card.propertyValues['card-status']
        scope.data.carddescribe = card.propertyValues['card-describe']
        scope.data.registrationtime = card.propertyValues['registration-time']
        scope.data.cardactivestarttime = card.propertyValues['card-active-start-time']
        scope.data.cardactiveendtime = card.propertyValues['card-active-end-time']
        scope.data.cardDoor = card.propertyValues['card-door']
        scope.data.add = false
        scope.data.sendCard = '0'

      # 增加卡
      scope.addCard = (obj)->
        scope.cardSelected = false
        if obj?
          scope.data=obj
        else
          scope.data =
            user: scope.data.user
            project: scope.data.project

            station : scope.data.station
            cardtype: '1'
            cardid:''
            cardname: 'new-card-name'
            cardowner:'0'
            cardstatus: '1'
            registrationtime:moment().format("YYYY-MM-DD")
            cardactiveendtime:moment().format("YYYY-MM-DD")
            cardactivestarttime: moment().format("YYYY-MM-DD")
            carddescribe: ''
            add: true
            sendCard: '0'

      scope.saveEquipment = (obj,callback) ->
#        obj.save(err,model)
#        console.log(obj)

        if !obj?
          model =
            user: scope.data.user
            project: scope.data.project

            station : scope.data.station

            equipment:scope.data.cardid
            name:scope.data.cardname
            type: 'access'
            vendor:'huayuan-iot'
            enable: true
            template:'card_template'
          #          @clearEquipment()
          @equipment = @station.createEquipment model, null
          console.log(@equipment)
          @equipment.loadProperties null, (err, data)=>
            @equipment.setPropertyValue('card-id', scope.data.cardid)
            @equipment.setPropertyValue('card-name', scope.data.cardname)
            @equipment.setPropertyValue('card-type', scope.data.cardtype)
            @equipment.setPropertyValue('card-owner', scope.data.cardowner)
            @equipment.setPropertyValue('card-status', scope.data.cardstatus)
            @equipment.setPropertyValue('card-active-start-time', scope.data.cardactivestarttime)
            @equipment.setPropertyValue('card-active-end-time', scope.data.cardactiveendtime)
            @equipment.setPropertyValue('registration-time', scope.data.registrationtime)
            @equipment.setPropertyValue('card-describe', scope.data.carddescribe)
            @equipment.setPropertyValue('card-door', scope.data.cardDoor)

            @equipment.save(model)
            @station.save(@equipment)
            #            super (err, model) =>
            #  # reload equipments and statistic

            scope.selectStation(@station)
            console.log @station
            $('#door-card-modal').modal('close')
            callback? err, model
        else
          @equipment =obj
          #          super (err, model) =>
          #  # reload equipments and statistic
          scope.selectStation(@station)
          $('#equipment-modal-card').modal('close')
          callback? err, model

      # 删除设备
      scope.removeEquipment = (card)=>
#        scope.data.cardid = id
        card.loadProperties()
        scope.data.cardid = card.propertyValues['card-id']
#        scope.cardSelected = true
#        console.log @currentcard.cardid
# 得到设备id 在站点里找到此设备并删除
        @equipment = _.find @datacenter.equipments.items ,(item)=>
          console.log item.model.equipment
          console.log scope.data.cardid
          return item.model.equipment == scope.data.cardid
#        console.log @datacenter.equipments.items
        console.log @equipment
        title = "删除设备确认: #{@equipment.model.name}"
        message = "请确认是否删除设备: #{@equipment.model.name}？删除后设备和数据将从系统中移除不可恢复！"
        scope.prompt title, message, (ok) =>
          return if not ok
          type = @equipment.model.type
          @equipment.remove (err, model) =>
# switch to other equipment
#            firequiment = @station.getFirstEquipmentByType type
#            @selectEquipment firequiment if firequiment
#            @$rootScope.reloadEquipment = true
# close the model after equipment has been removed
            scope.selectStation(scope.station)
            $('#door-card-modal').modal('close')
            callback? err, model


      scope.removeStation = (station) =>
        title = station.model.name
        msg = ""
        $('#station-manager-prompt-modal').modal('open')
        scope.prompt title, msg, (ok) =>
          return if not ok
          if ok
            station?.remove()
            $('#station-manager-prompt-modal').modal('close')
            loadStations()
      scope.filterCard = () ->
        (equipment) =>
          text = scope.search?.toLowerCase()
          if not text
            return true
          if equipment.model.equipment.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.name.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.propertyValues['card-owner'].toLowerCase().indexOf(text) >= 0
            return true
          if scope.cardType[equipment.propertyValues['card-type']].name.toLowerCase().indexOf(text) >= 0
            return true
          if scope.cardstatus[equipment.propertyValues['card-status']].name.toLowerCase().indexOf(text) >= 0
            return true
          return false


      #      scope.filterStationEvents = ()->
      #        return if not @equipments
      #        @pageCountint=0
      #        items = []
      #        items = _.filter @equipments, (item)=>
      #          not @search or
      #            item.model.name?.toLowerCase().indexOf(@search)>=0   or
      #            item.model.assetnumber?.toLowerCase().indexOf(@search)>=0 or
      #            item.model.serialnumber?.toLowerCase().indexOf(@search)>=0 or
      #            item.model.statusName?.name.toLowerCase().indexOf(@search)>=0 or
      #            item.model.templateName?.toLowerCase().indexOf(@search)>=0  or
      #            item.model.typeName?.toLowerCase().indexOf(@search)>=0
      #
      #        pageCount = Math.ceil(items.length/@stationEvents.pageItems)
      #        @pageCountint=pageCount
      #        result = {page:1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
      #        result


      scope.sortBy=(predicate) ->
        if scope.predicate is predicate
          scope.reverse = !scope.reverse
        else
          scope.predicate = predicate
          scope.reverse = true

    resize: (scope)->

    dispose: (scope)->


  exports =
    CardManageDirective: CardManageDirective