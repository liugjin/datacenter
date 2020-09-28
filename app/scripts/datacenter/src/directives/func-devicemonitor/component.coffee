###
* File: func-devicemonitor-directive
* User: James
* Date: 2019/03/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class FuncDevicemonitorDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "func-devicemonitor"
      super $timeout, $window, $compile, $routeParams, commonService
      @allInventoryStations = []

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      element.css("display", "block")
      scope.searchLists = ""
      scope.setting = setting
      scope.currentType = null
      scope.equipTypes = null
      scope.view = true
      scope.detail = false
      scope.edit = false
      scope.add = false

      scope.viewName = '视图'
      scope.pageIndex = 1
      scope.pageItems = 8
      scope.addImg = @getComponentPath('image/add.svg')
      scope.viewImg = @getComponentPath('image/view.svg')
      scope.backImg = @getComponentPath('image/back.svg')
      scope.detailBlueImg = @getComponentPath('image/detail-blue.svg')
      scope.editBlueImg = @getComponentPath('image/edit-blue.svg')
      scope.saveImg = @getComponentPath('image/save-blue.svg')
      scope.detailGreenImg = @getComponentPath('image/detail-green.svg')
      scope.editGreenImg = @getComponentPath('image/edit-green.svg')
      scope.deleteGreenImg = @getComponentPath('image/delete-green.svg')
      scope.equipSubscription = {}

      scope.project.loadEquipmentTemplates {}, 'user project type vendor template name base index image'
      scope.controller.$location.search 'station', scope.station?.model.station

      # 加载项目站点
      scope.project.loadStations null, (err, stations)=>
        dataCenters = _.filter stations, (sta)->(sta.model.parent is null or sta.model.parent is "") and sta.model.station.charAt(0) isnt "_"
        scope.datacenters = dataCenters
        scope.stations = dataCenters
        scope.station = dataCenters[0]
        scope.parents = []

      # 选择站点
      scope.selectStation = (station)=>
        scope.station = station
        scope.controller.$location.search 'station', station?.model.station

      # 选择子站点
      scope.selectChild = (station)=>
        scope.stations = scope.station.stations
        scope.parents.push scope.station
        scope.station = station
        scope.controller.$location.search 'station', station?.model.station

      # 选择父站点
      scope.selectParent = (station)=>
        index = scope.parents.indexOf(station)
        scope.parents.splice index, scope.parents.length-index
        scope.station = station
        scope.stations = station.parentStation?.stations ? scope.datacenters

      # 加载所有的用户
      loadAllUsers = () =>
        userService = @commonService.modelEngine.modelManager.getService 'users'
        filter = {}
        fields = null
        userService.query filter, fields, (err, data) =>
          if not err
            scope.userMsg = data

      # 监听站点变化
      scope.$watch 'station', (station)=>
        scope.detail = false
        scope.edit = false
        scope.add = false
        scope.currentType = null
        scope.childStations = []
        #loadAllChildStation()
        loadStatisticByEquipmentTypes()
        loadAllUsers()

      # 加载设备类型
      loadStatisticByEquipmentTypes = () =>
        getStationEquipTypes (equipTypeDatas)=>
          stationType = {
            statistic:{}
          }

          for equipTypeDataItem in equipTypeDatas
            for j, item of equipTypeDataItem.statistic
              it = _.findWhere stationType.statistic, {type: item.type}
              if it
                it.count = it.count + item.count
              else
                stationType.statistic[item.type] = item
          loadAccessEquips (equips) =>
            _.map stationType.statistic, (value, key) =>
              if value.type is "access"
                value.count = equips.length
            processTypes stationType, true

      #获取所有站点类型
      getStationEquipTypes = (callback) =>
        @allInventoryStations = []
        @getAllStations scope,scope.station.model.station
        allInventoryStationsLen = @allInventoryStations.length
        allInventoryStationsCount = 0
        allEquipModels = []

        for stationObj in @allInventoryStations
          stationObj.loadStatisticByEquipmentTypes  (err, mod)->
            allEquipModels.push mod
            allInventoryStationsCount++
            if allInventoryStationsCount == allInventoryStationsLen
              callback? allEquipModels
          , true

      # 加载门禁门设备
      loadAccessEquips = (callback) =>
        accessEquips = []
        getStationEquips = (station, callback) =>
          for sta in station.stations
            getStationEquips sta, callback
          filter =
            user:  station.model.user
            project: station.model.project
            station: station.model.station
            type: "access"
            template: {$nin:['card-sender', 'card_template', 'people_template']}
          station.loadEquipments filter, null, (err, mods) ->
            callback? mods
          , true
        getStationEquips scope.station, (equipments) =>
          diff = _.difference equipments, accessEquips
          accessEquips = accessEquips.concat diff
          callback? accessEquips
          scope.$applyAsync()

      # 对设备类型进行处理
      processTypes = (data, refresh) =>
        return if not data?.statistic
        types = []
        for key, value of data.statistic when value.type[0] isnt '_' #and value.base
          types.push value
        _.map types, (type) =>
          currentType = _.find scope.project.dictionary.equipmenttypes.items, (item) => item.model.type is type.type
          if currentType
            type.index = currentType.model.index
            if currentType.model.visible
              type.visible = currentType.model.visible
            else
              type.visible = true
            if currentType.model.image
              type.image = currentType.model.image
        scope.equipTypes = types
        typesArr = _.filter scope.equipTypes, (type)=>
          return type.count isnt 0 and type.type isnt 'KnowledgeDepot' #and type.type isnt 'hmu' and type.type isnt 'rack' and type.type isnt 'server' and type.type isnt 'video'
        if !scope.currentType
          type = (_.find typesArr, (type) => type.type is @$routeParams.equipmentType) if @$routeParams.equipmentType
          if type
            scope.currentType = type
          else
            scope.currentType = typesArr[0]
        selectType scope.currentType.type, null , refresh

      # 加载特定类型的设备
      selectType = (type, callback, refresh) =>
        return if not type
        mods = []

        getStationEquipment = (station, callback) =>
          for sta in station.stations
            getStationEquipment sta
          await @commonService.loadEquipmentsByType station, type, defer(err, mod), refresh
          mods = mods.concat mod
          callback? mods

        processEquipinfos = (equips,callback) =>
          tmpLen = equips.length
          equipCount = 0
          for equip in equips
            equip.loadProperties()
            equip.model.typeName = (_.find scope.project.dictionary.equipmenttypes.items, (type)->type.key is equip.model.type)?.model.name
            equip.model.templateName = (_.find scope.project.equipmentTemplates.items, (template)->template.model.type is equip.model.type and template.model.template is equip.model.template)?.model.name
            equip.model.vendorName = (_.find scope.project.dictionary.vendors.items, (vendor)->vendor.key is equip.model.vendor)?.model.name
            equip.model.stationName = (_.find scope.project.stations.items, (station)->station.model.station is equip.model.station)?.model.name
            equip.loadEquipmentTemplate null, (err, refTemplate) =>
              equipCount++
              if equipCount == tmpLen
                callback? equips

        getStationEquipment scope.station, (equips) =>
          processEquipinfos equips,(equipData) =>
            scope.equipments = equipData
            scope.$applyAsync()
            _.map scope.equipments, (equipment) =>
              equipment.loadSignals null, (err, signals)=>
                status = _.find signals, (signal) => signal.model.signal is 'communication-status'
                if status
                  str = equipment.key + "-communication-status"
                  scope.equipSubscription[str]?.dispose()
                  scope.equipSubscription[str] = @commonService.subscribeSignalValue status, (signal) =>
                    if signal.data.value == 0
                      signal.data.format = "在线"
                    else
                      signal.data.format = "离线"
                alarms = _.find signals, (signal) => signal.model.signal is 'alarms'
                if alarms
                  str = equipment.key + "-alarms"
                  scope.equipSubscription[str]?.dispose()
                  scope.equipSubscription[str] = @commonService.subscribeSignalValue alarms, (signal) =>
                    if signal.data.value > 0
                      signal.data.format = "告警"
                    else
                      signal.data.format = "正常"

      # 选择设备类型
      scope.selectEquipType = (type) =>
        scope.pageIndex = 1
        scope.detail = false
        scope.edit = false
        scope.currentType = type
        selectType scope.currentType.type, null, false

      # 选择设备
      scope.selectEquip = (equipment) =>
        scope.equipment = equipment
        setEquipmentData()

      # 格式化设备的数据
      setEquipmentData = () =>
        _.map scope.equipment.properties.items, (item) =>
          if item.model.property is 'status'
            scope.equipment.model.status = item.value
            statusArr = item.model.format.split(',')
            for lt in statusArr
              if lt.split(":")[0] is item.value or lt.split(":")[1] is item.value
                scope.equipment.model.statusName = lt.split(":")[1]
                item.model.value = lt.split(":")[1]
          if item.model.property is 'install-date'
            life = _.find scope.equipment.properties.items, (item) ->
              return item.model.property is 'life'
            scope.equipment.model.remainDate = life.value - moment().diff(item.value, 'months')
          if item.model.property is 'guarantee-month'
            if item.value
              install = _.find scope.equipment.properties.items, (item) ->
                return item.model.property is 'install-date'
              scope.equipment.model.repairDate = item.value - moment().diff(install.value, 'months') % item.value
            else
              scope.equipment.model.repairDate = 0

          if _.isNaN(scope.equipment.model.remainDate)
            scope.equipment.model.remainDate = '-'
          if _.isNaN(scope.equipment.model.repairDate)
            scope.equipment.model.repairDate = '-'

      # 切换视图
      scope.switchView = () =>
        scope.view = !scope.view
        scope.pageIndex = 1
        if scope.view
          scope.pageItems = 8
          scope.viewName = '视图'
        else
          scope.pageItems = 12
          scope.viewName = '列表'


      # 选择页数
      scope.selectPage = (page)=>
        scope.pageIndex = page

      # 返回到设备列表
      scope.backList = ()=>
        scope.detail = false
        scope.edit = false
        scope.add = false

      # 保存设备信息
      scope.saveEquipment = () =>
        scope.equipment.save (err, model) =>
          loadStatisticByEquipmentTypes()

      # 新增设备
      scope.addEquipment = () =>
        scope.add = true
        scope.edit = true
        scope.equipment = scope.station.createEquipment null

      # 设备类型检测
      scope.equipTypeChange = () =>
        selectType scope.equipment.model.type, null, false

      # 设置设备的参数
      scope.settingEquipId = () =>
        template = scope.equipment.model.template
        equipmentTemplate = _.find scope.project.equipmentTemplates.items, (item) ->
          return item.model.template is template
        equipmentTemplate?.loadProperties null, (err, result)=>
          _.each result, (item) ->
            if item.model.dataType is 'date' or item.model.dataType is 'time' or item.model.dataType is 'datetime'
              item.model.value = moment(item.model.value).toDate()
            item.value = item.model.value
          scope.equipment._properties = result
        scope.equipment._sampleUnits = equipmentTemplate?.model.sampleUnits
        name = equipmentTemplate?.model.name.replace /模板/, ''
        loadEquipsByAdd (num) =>
          equipID = scope.equipment.model.type + '-' + scope.equipment.model.template + '-' + num
          equipName = name + '-' + num
          scope.equipment.model.equipment = equipID
          scope.equipment.model.name = equipName
          settingEquipSampleUnits()

      # 加载指定类型和模板设备
      loadEquipsByAdd = (callback) =>
        filter = {
          user: scope.equipment.model.user
          project: scope.equipment.model.project
          station: scope.equipment.model.station
          type: scope.equipment.model.type
          template: scope.equipment.model.template
        }
        scope.station.loadEquipments filter, null, (err, equips) =>
          return if err
          callback? getEquipNumber(equips)

      # 获取指定类型和模板设备的编号
      getEquipNumber = (equips) =>
        i = 0
        _.map equips, (equip) ->
          arr = equip.model.name.split('-')
          str = arr[arr.length-1]
          num = str.replace(/[^0-9]/ig, "")
          if (num-i) > 0
            i = num
        i++
        result = i
        return result

      # 设置设备采集单元
      settingEquipSampleUnits = () =>
        mu = 'mu-' + scope.equipment.model.user + '.' + scope.equipment.model.project + '.' + scope.equipment.model.station
        su = 'su-' + scope.equipment.model.equipment
        scope.equipment.model.sampleUnits = []
        _.each scope.equipment._sampleUnits, (sampleUnits) =>
          sampleUnits.value = mu + '/' + su
          sample = {}
          sample.id = sampleUnits.id
          sample.value = mu + '/' + su
          scope.equipment.model.sampleUnits.push sample
          scope.equipment.sampleUnits[sampleUnits.id] = sampleUnits
        return

      # 保存新增设备
      scope.saveEquipmentGroups = () =>
        scope.add = false
        scope.edit = false
        scope.detail = false

        scope.currentType = _.find scope.equipTypes, (type) =>
          return type.type is scope.equipment.model.type
        scope.saveEquipment()

      # 删除设备
      scope.deleteEquip = (equip)=>
        scope.equipment = equip
        title = "删除设备确认: #{scope.project.model.name}/#{scope.station.model.name}/#{scope.equipment.model.name}"
        message = "请确认是否删除设备: #{scope.project.model.name}/#{scope.station.model.name}/#{scope.equipment.model.name}？删除后设备和数据将从系统中移除不可恢复！"
        scope.prompt title, message, (ok) =>
          return if not ok
          scope.equipment.remove (err, model) =>
            loadStatisticByEquipmentTypes()

      # 编辑设备数据
      scope.editData = (equipment) =>
        scope.edit = true;
        if equipment
          scope.equipment = equipment
        setEquipmentData()

      # 保存旧数据
      scope.saveValue = (value) =>
        scope.oldValue = value

      # 检查数据是否有变化
      scope.checkValue = (value) =>
        if scope.oldValue is value
          return
        else
          scope.saveEquipment()

      # 监听设备图片变化
      scope.$watch 'equipment.model.image', ()=>
        if scope.edit and !scope.add
          scope.saveEquipment()

      # 检测站点变化
      scope.stationCheck = () =>
        if scope.equipment.model.station
          scope.saveEquipment()

      #监控设备信息

      # 查看设备数据
      scope.lookData = (equipment) =>
        scope.edit = false;
        scope.detail = true;
        if equipment
          scope.equipment = equipment
          scope.controller.$location.search 'station', equipment?.model.station
          scope.controller.$location.search 'equipment', equipment?.model.equipment

        @publishEquipInstance?.dispose()
        @publishEquipInstance = @commonService.publishEventBus 'equipmentId',{equipmentId:{station:equipment.model.station,equipment:equipment.model.equipment}}
        setEquipmentData()

      # 过滤设备类型-设备类型
      scope.filterTypes = () =>
        (type)=>
          return type.count isnt 0 and type.type isnt 'KnowledgeDepot' #and type.type isnt 'hmu' and type.type isnt 'rack' and type.type isnt 'server' and type.type isnt 'video'

      # 过滤设备-设备列表
      scope.filterEquipment = () =>
        (equipment) =>
          if equipment.model.template is 'card-sender' or equipment.model.template is 'card_template' or equipment.model.template is 'people_template'
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

      # 搜索设备属性-设备详情
      scope.filterProperties = ()->
        (item) =>
          if item.model.dataType is "json" or item.model.dataType is "script" or item.model.dataType is "html" or item.model.dataType is "image" or item.model.visible is false
            return false
          text = scope.searchDetail?.toLowerCase()
          if not text
            return true
          if item.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if item.model.property?.toLowerCase().indexOf(text) >= 0
            return true
          return false

      # 搜索设备属性-设备编辑
      scope.filterEditItems1 = ()=>
        (item)=>
          if item.model.dataType is "json" or item.model.dataType is "script" or item.model.dataType is "html" or item.model.visible is false
            return false
          if item.model.property is 'production-time' or item.model.name is '生产日期'
            return true
          if item.model.property is 'buy-date' or item.model.name is '购买日期'
            return true
          if item.model.property is 'install-date' or item.model.name is '安装日期'
            return true
          return false

      # 搜索设备属性-设备编辑
      scope.filterEditItems2 = ()=>
        (item)=>
          if item.model.dataType is "json" or item.model.dataType is "script" or item.model.dataType is "html" or item.model.visible is false
            return false
          if item.model.property is 'production-time' or item.model.name is '生产日期'
            return false
          if item.model.property is 'buy-date' or item.model.name is '购买日期'
            return false
          if item.model.property is 'install-date' or item.model.name is '安装日期'
            return false
          text = scope.searchEdit?.toLowerCase()
          if not text
            return true
          if item.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if item.model.property?.toLowerCase().indexOf(text) >= 0
            return true
          return false

      # 过去设备模板
      scope.filterEquipmentTemplate = ()=>
        (template) =>
          return false if not scope.equipment
          model = scope.equipment.model
          return template.model.type is model.type and template.model.vendor is model.vendor


    getAllStations:(refScope,refStation)=>
      stationResult = _.filter refScope.project.stations.items,(stationItem)->
        return stationItem.model.station == refStation
      for stationResultItem in stationResult
        childStations = _.filter refScope.project.stations.items,(stationItem)->
          return stationItem.model.parent == refStation
        @allInventoryStations.push stationResultItem
        if !childStations
          return

        for childStationsItem in childStations
          @getAllStations(refScope,childStationsItem.model.station)
    resize: (scope)->

    dispose: (scope)->
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()

  exports =
    FuncDevicemonitorDirective: FuncDevicemonitorDirective