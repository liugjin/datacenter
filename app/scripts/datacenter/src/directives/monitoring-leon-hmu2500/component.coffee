###
* File: monitoring-leon-hmu2500-directive
* User: David
* Date: 2020/05/30
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class MonitoringLeonHmu2500Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "monitoring-leon-hmu2500"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      scope.categories = {}
      scope.equipTypeLists = []
      scope.status = {}
      scope.alarms = {}
      scope.currentType = null
      scope.stationCurrentType = null    #存放站点下‘所有类型’按钮数据
      scope.treeEquipmentFlag = false    #是否选中左侧树的设备
      scope.view = false
      scope.detail = false
      scope.viewName = '视图'
      scope.pageIndex = 1
      scope.pageItems = 8
      scope.groups = []
      scope.group = "all"
      scope.filterType = scope.parameters.filterType ? false

      scope.selectEquipType = (type) =>
        return if not type
        scope.pageIndex = 1
        scope.detail = false
        scope.currentType = type
        scope.treeEquipKey = null
        @selectType scope, type, null, false
        scope.group = "all"

#      scope.selectEquipType = (type,firstLoad) =>
#        # 如果firstLoad参数为true 则为首次加载页面，要打开此类型第一个设备的详情页面
#        return if not type
#        scope.pageIndex = 1
#        scope.detail = false
#        scope.currentType = type
#        scope.treeEquipKey = null
#        if firstLoad is true
#          @selectType scope, type, (equips)=>
#            console.log equips
#            scope.showEquipment(equips[0])
#          , false
#        else
#          @selectType scope, type, null, false
#        scope.group = "all"

      # 选择所有设备类型
      scope.selectAllTypes = ()=>
        @selectStation(scope,scope.station)

      # 设备树选择设备
      scope.treeEquipId?.dispose()
      scope.treeEquipId = @commonService.subscribeEventBus 'treeEquipKey', (d)=>
#        console.log "选择设备树的设备"
        scope.treeEquipKey = d.message.key
        scope.treeEquipmentFlag = true
        equip = _.find scope.equipments,(item)->
          item.key is d.message.key
        scope.showEquipment(equip)

      # 过滤设备-设备列表
      scope.filterEquipment = () =>
        (equipment) =>
          if equipment.model.template is 'card-sender' or equipment.model.template is 'card_template' or equipment.model.template is 'people_template'
            return false
          if scope.group isnt "all" and equipment.model.group isnt scope.group
            return false
          if scope.treeEquipKey and (equipment.key != scope.treeEquipKey)
            return false
          text = scope.searchLists?.toLowerCase()
          if not text
            return true
          if equipment.model.equipment?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.tag?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.typeName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.stationName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.vendorName?.toLowerCase().indexOf(text) >= 0
            return true
          return false

      # 对设备进行分页设置
      scope.filterEquipmentItem = ()=>
        return if not scope.equipments
        items = []
        items = _.filter scope.equipments, (equipment) =>
          if equipment.model.template is 'card-sender' or equipment.model.template is 'card_template' or equipment.model.template is 'people_template'
            return false
          if scope.group isnt "all" and equipment.model.group isnt scope.group
            return false
          text = scope.searchLists?.toLowerCase()
          if not text
            return true
          if equipment.model.equipment?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.tag?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.typeName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.stationName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.vendorName?.toLowerCase().indexOf(text) >= 0
            return true
          return false
        pageCount = Math.ceil(items.length / scope.pageItems)
        result = {page:1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      # 限制每页的个数
      scope.limitToEquipment = () =>
        if scope.filterEquipmentItem() and scope.filterEquipmentItem().pageCount is scope.pageIndex
          aa = scope.filterEquipmentItem().items % scope.pageItems;
          result = -(if aa==0 then scope.pageItems else aa)
        else
          result = -scope.pageItems
        result

      # 选择页数
      scope.selectPage = (page)=>
        scope.pageIndex = page

      # 切换视图
      scope.switchView = () =>
        scope.view = !scope.view
        scope.pageIndex = 1
        if scope.view
          scope.pageItems = 12
          scope.viewName = '表格'
        else
          scope.pageItems = 8
          scope.viewName = '视图'

      # 查看设备数据
      scope.showEquipment = (equipment) =>
#        console.log "--showEquipment---"
        scope.detail = true;
        if equipment
          equipment.loadEquipmentTemplate null, (err, template) =>
            scope.equipment = null
            @commonService.publishEventBus 'equipmentId',{equipmentId:{station:equipment.model.station,equipment:equipment.model.equipment}}
      #        setEquipmentData()

      scope.goBack = =>
        scope.detail = false
      scope.goAhead = =>
        scope.detail = true

      scope.selectGroup = (group)=>
        scope.group = group
        scope.treeEquipKey = null

      scope.getEquipmentImage = (equip) =>
        return equip.model.image if not _.isEmpty equip.model.image
        item = _.find scope.templates, (template)->template.model.type is equip.model.type and template.model.template is equip.model.template
        item?.model?.image

      scope.project.loadEquipmentTemplates null, null, (err, templates) =>
        scope.templates = templates
        n = 0
        for station in scope.project.stations.nitems
          @loadStationEquipStatistics scope, station, =>
            n++
            if n is scope.project.stations.nitems.length
              _.each scope.project.stations.nitems, (sta)=>
                @computeStationStatistic scope, sta
              @selectStation scope, scope.station,true

      scope.statusSubscription?.dispose()
      filter1 = scope.project.getIds()
      filter1.station = "+"
      filter1.equipment = "+"
      filter1.signal = "communication-status"
      scope.statusSubscription = @commonService.signalLiveSession.subscribeValues filter1, (err, d)=>
        scope.status[d.message.station+"."+d.message.equipment] = d.message.value

      scope.alarmsSubscription?.dispose()
      filter2 = scope.project.getIds()
      filter2.station = "+"
      filter2.equipment = "+"
      filter2.signal = "_alarms"
      scope.alarmsSubscription = @commonService.signalLiveSession.subscribeValues filter2, (err, d)=>
        scope.alarms[d.message.station+"."+d.message.equipment] = d.message.value

      scope.stationSubscription?.dispose()
      scope.stationSubscription = @commonService.subscribeEventBus "selectStation", (msg) =>
        station = _.find scope.project.stations.items, (sta)->sta.model.station is msg.message.id
        @selectStation scope, station

    selectStation: (scope, station, firstLoad) ->
      # 在选择站点后得到站点所有设备，放到一个对象， 当左侧选择树的设备时候用
      scope.treeEquipKey = null
      scope.treeEquipmentFlag = false
      scope.station = station
      scope.equipTypeLists = _.map scope.categories[station.model.station], (value, key)->
        item = _.find scope.project.dictionary.equipmenttypes.items, (it)->it.model.type is key
        if item
          value.image = item.model.image
          value.index = item.model.index
        value
      scope.equipTypeLists = _.sortBy scope.equipTypeLists, (item)->0-item.index
      if @$routeParams.type
        type = _.find scope.equipTypeLists, (item)=>item.type is @$routeParams.type
      type = type ? scope.equipTypeLists[0]
      if scope.equipment
        type = _.find scope.equipTypeLists, (item)=>item.type is scope.equipment.model.type

      stationTypeArr = []
      stationEquipCounts = 0
      for key,value of scope.categories[station.model.station]
        stationTypeArr.push key
        stationEquipCounts += value.count
      all = {type:'all',name:'所有类型',count:stationEquipCounts,allTypes:stationTypeArr}
      scope.stationCurrentType = all

      if firstLoad is true
        scope.selectEquipType type,true        #选择站点时加载站点下的所有设备类型而不是某一种,除了首次加载的情况
      else
        scope.selectEquipType all

      if scope.equipment
        setTimeout =>
          scope.showEquipment scope.equipment
        ,10
      scope.$applyAsync()

    loadStationEquipStatistics: (scope, station, callback) ->
      station.loadStatisticByEquipmentTypes (err, statistic) =>
        value = JSON.parse JSON.stringify statistic.statistic
        @filterStationStatistic station, value, =>
          if scope.filterType
            for key, val of value
              type = _.find scope.project.dictionary.equipmenttypes.items, (item)->item.model.type is key
              delete value[key] if type?.model.visible is false
          station.categories = value
          callback?()

    filterStationStatistic: (station, statistic, callback)->
      station.loadEquipments {type: "access", template: {$nin:['card-sender', 'card_template', 'people_template']}}, null, (err, equips)=>
        statistic["access"]?.count = equips.length
        callback?()

    computeStationStatistic: (scope, station) ->
      scope.categories[station.model.station] = item = JSON.parse JSON.stringify station.categories
      stations = @commonService.loadStationChildren station, false
      for sta in stations
        _.mapObject sta.categories, (val, key)->
          item[key].count += val.count
      _.mapObject item, (val, key)->
        delete item[key] if val.count is 0 or key.substr(0,1) is "_"

    selectType: (scope, type, callback ,refresh) ->
      scope.equipments = []
      scope.groups = []
      stations = @commonService.loadStationChildren scope.station, true
      if type.type is 'all'
        scope.currentType = type
        scope.stationCurrentType = type
        len = 0
        for station in stations
          filter = {}
          filter.type = {$in:type.allTypes}
          station.loadEquipments filter,null,(err,equips)=>
            len++
            for equip in equips
              equip.model.typeName = (_.find scope.project.dictionary.equipmenttypes.items, (tp)->tp.key is equip.model.type)?.model.name
              equip.model.templateName = (_.find scope.templates, (template)->template.model.type is equip.model.type and template.model.template is equip.model.template)?.model.name
              equip.model.vendorName = (_.find scope.project.dictionary.vendors.items, (vendor)->vendor.key is equip.model.vendor)?.model.name
              equip.model.stationName = (_.find scope.project.stations.items, (station)->station.model.station is equip.model.station)?.model.name
              scope.groups.push equip.model.group if equip.model.group and scope.groups.indexOf(equip.model.group) is -1
            scope.equipments = scope.equipments.concat equips
            if len == stations.length
              callback? scope.equipments
          ,refresh
      else
        len = 0
        for station in stations
          @commonService.loadEquipmentsByType station, type.type, (err, equips)=>
            len++
            for equip in equips
              equip.model.typeName = (_.find scope.project.dictionary.equipmenttypes.items, (tp)->tp.key is equip.model.type)?.model.name
              equip.model.templateName = (_.find scope.templates, (template)->template.model.type is equip.model.type and template.model.template is equip.model.template)?.model.name
              equip.model.vendorName = (_.find scope.project.dictionary.vendors.items, (vendor)->vendor.key is equip.model.vendor)?.model.name
              equip.model.stationName = (_.find scope.project.stations.items, (station)->station.model.station is equip.model.station)?.model.name
              scope.groups.push equip.model.group if equip.model.group and scope.groups.indexOf(equip.model.group) is -1
            scope.equipments = scope.equipments.concat equips
            if len == stations.length
              callback? scope.equipments
          ,refresh

    resize: (scope)->

    dispose: (scope)->
      scope.statusSubscription?.dispose()
      scope.alarmsSubscription?.dispose()
      scope.stationSubscription?.dispose()
      scope.treeEquipId?.dispose()


  exports =
    MonitoringLeonHmu2500Directive: MonitoringLeonHmu2500Directive