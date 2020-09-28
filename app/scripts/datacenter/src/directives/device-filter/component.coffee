###
* File: device-filter-directive
* User: David
* Date: 2019/04/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DeviceFilterDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "device-filter"
      super $timeout, $window, $compile, $routeParams, commonService
      @allInventoryStations = []

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      element.css("display", "block")
      allStations = []
      scope.equipTypeLists = []
      scope.setting = setting
      scope.currentType = null
      scope.view = false
      scope.detail = false
      scope.edit = false
      scope.add = false
      scope.equipSubscription = {}
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

      sortList = _.map(_.sortBy(_.filter(scope.project.dictionary.equipmenttypes.items, (d) -> _.has(d.model, "visible") and d.model.visible), (m) -> m.index), (n) -> {key: n.key, img: n.image})
      scope.project.loadEquipmentTemplates {}, 'user project type vendor template name base index image'

      # 加载项目站点
      scope.project.loadStations null, (err, stations)=>
        dataCenters = _.filter stations, (sta)->(sta.model.parent is null or sta.model.parent is "") and sta.model.station.charAt(0) isnt "_"
        scope.datacenters = dataCenters
        scope.stations = dataCenters
        scope.station = dataCenters[0]
        scope.parents = []

      # 选择子站点
      scope.selectChild = (station)=>
        scope.stations = scope.station.stations
        scope.parents.push scope.station
        scope.station = station

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

      # 查询所有的子站点
      loadChildSta = (sta, allStations) =>
        _list = []
        getSta = (id) =>
          current = _.find(allStations, (d) => d.station is id)
          _list.push(id)
          if current.child.length != 0
            _.map(current.child, (d) => getSta(d))
        getSta(sta.station)
        return _list

      # 查询所有下属设备类型 并加和
      loadEquipType = (sta, allData) ->
        return _.map(_.groupBy(_.filter(allData, (d) => sta.child.indexOf(d.station) != -1), (m) -> m.type), (n) ->
          n[0].count += n[x].count for x in [1..n.length - 1] if n.length > 1
          return { type: n[0].type, name: n[0].name, count: n[0].count }
        )

      # 加载设备类型
      loadStatisticByEquipmentTypes = () =>
        getStationEquipTypes (equips, equipData)=>
          arr = equips
#          _.map(equips, (d) =>
#            d.child = loadChildSta(d, equips)
#            arr.push(d)
#          )
          allStations = _.sortBy(_.map(arr, (d) =>
            d.statistic = loadEquipType(d, equipData)
            return d
          ), (m) => arr.length - m.child.length)
          if _.has(@$routeParams, "station")
            _item = _.find(allStations, (d) => d.station is @$routeParams.station)
            selectStation(_item.station)
            processTypes _.map(_item.statistic, (d) -> d), true
          else
            selectStation(allStations[0].station)
            processTypes _.map(allStations[0].statistic, (d) -> d), true

      #获取所有站点类型
      getStationEquipTypes = (callback) =>
        @allInventoryStations = []
        @getAllStations scope,scope.station.model.station
        allInventoryStationsLen = @allInventoryStations.length
        allInventoryStationsCount = 0
        allEquipModels = []
        allTypeCount = []
        for stationObj in @allInventoryStations
          stationObj.loadStatisticByEquipmentTypes  (err, mod) =>
            if mod
              for x in @allInventoryStations
                if x.model.station is mod.station
                  allEquipModels.push({ station: mod.station, child: if _.has(x, "stations") then _.map(x.stations, (d) -> d.model.station).concat([mod.station]) else [mod.station] })
                  break
              _.map(mod.statistic, (d) =>
                allTypeCount.push({ type: d.type, name: d.name, count: d.count, station: mod.station }) if d.count != 0 and d.type != "_station_management"
              )
              allInventoryStationsCount++
              if allInventoryStationsCount == allInventoryStationsLen
                callback(allEquipModels, allTypeCount)
          , true

      loadStatisticByEquipmentTypes()

      # 对设备类型进行处理
      processTypes = (data, refresh) =>
        return if not data || data.length == 0
        _.map data, (type)=>
          currentType = _.find scope.project.dictionary.equipmenttypes.items, (item) => item.model.type is type.type
          if currentType.model.image
            type.image = currentType.model.image
        if _.has(@$routeParams, "equipmentType")
          _item = _.find(data, (d) => d.type is @$routeParams.equipmentType)
          scope.currentType = if _item then _item else data[0]
        else
          scope.currentType = data[0]
        selectType scope.currentType.type, null , refresh

      # 选择站点
      selectStation = (stationId)=>
        scope.station = _.find(@allInventoryStations, (d) => d.model.station == stationId)
        scope.detail = false
        scope.edit = false
        scope.add = false
        scope.currentType = null
        scope.childStations = []
        _sta = _.find(allStations, (d) => d.station == stationId)
        if _sta.statistic.length is 0
          scope.equipTypeLists = []
          scope.equipments = []
          scope.$applyAsync()
        else
          scope.equipTypeLists = _.sortBy(_sta.statistic, (m) => _.indexOf(sortList, (x) => x.key is m.type))
          processTypes scope.equipTypeLists, true
          loadAllUsers()

      # 加载特定类型的设备
      selectType = (type, callback, refresh) =>
        return if not type
        mods = []
        # 获取站点下属设备
        getStationEquipment = (station, callback) =>
          for sta in station.stations
            getStationEquipment sta
          await @commonService.loadEquipmentsByType station, type, defer(err, mod), refresh
          mods = mods.concat mod
          callback? mods
        # 字典值转化
        processEquipinfos = (equips,callback)=>
          tmpLen = equips.length
          equipCount = 0
          for equip in equips
            equip.loadProperties()
            equip.model.typeName = (_.find scope.project.dictionary.equipmenttypes.items, (type)->type.key is equip.model.type)?.model.name
            equip.model.templateName = (_.find scope.project.equipmentTemplates.items, (template)->template.model.type is equip.model.type and template.model.template is equip.model.template)?.model.name
            equip.model.vendorName = (_.find scope.project.dictionary.vendors.items, (vendor)->vendor.key is equip.model.vendor)?.model.name
            equip.model.stationName = (_.find scope.project.stations.items, (station)->station.model.station is equip.model.station)?.model.name
            equip.loadEquipmentTemplate null,(err,refTemplate)=>
              equipCount++
              if equipCount == tmpLen
                callback? equips
        getStationEquipment scope.station, (equips)=>
          processEquipinfos equips,(equipdatas)=>
            scope.equipments = equipdatas
            scope.$applyAsync()
            _.map(scope.equipments, (x) =>
              x.loadSignals(null, (err, signals) =>
                for d in ["alarms", "communication-status"]
                  scope.equipSubscription[x.key + "-" + d]?.dispose()
                  scope.equipSubscription[x.key + "-" + d] = @commonService.subscribeSignalValue(_.find(signals, (m) => m.model.signal is d), (signal) =>
                    if signal.model.signal is "alarms"
                      signal.data.format = if signal.data.value > 0 then "告警" else "正常"
                    else
                      signal.data.format = if signal.data.value > -1 then "在线" else "离线"
                  )
              )
            )

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
          scope.pageItems = 12
          scope.viewName = '表格'
        else
          scope.pageItems = 8
          scope.viewName = '视图'

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

        scope.currentType = _.find scope.equipTypeLists, (type) =>
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
        @publishEquipInstance?.dispose()
        @publishEquipInstance = @commonService.publishEventBus 'equipmentId',{equipmentId:{station:equipment.model.station,equipment:equipment.model.equipment}}
        setEquipmentData()

      # 过滤设备类型-设备类型
      scope.filterTypes = () =>
        (type)=>
          return type.count

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

      # 订阅左侧树的点击信息
      scope.subscribeTreeClick = @commonService.subscribeEventBus("selectStation", (msg) => selectStation(msg.message.id))

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
      scope.subscribeTreeClick?.dispose()

  exports =
    DeviceFilterDirective: DeviceFilterDirective