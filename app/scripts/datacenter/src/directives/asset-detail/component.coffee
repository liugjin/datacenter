###
* File: asset-detail-directive
* User: David
* Date: 2019/10/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class AssetDetailDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "asset-detail"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 选择框选择链路设备执行的函数
      scope.slecetLinkDevice = (deviceId) => (
        scope.linkDeviceId = deviceId
        scope.deviceStation.loadEquipment scope.linkDeviceId, null, (err,linkEquip) ->
          scope.linkDeviceInfo = linkEquip
          scope.linkDeviceInfo.loadPorts null, (err, ports)=>
            scope.selectRefresh++
          # console.log "链路设备信息:",scope.linkDeviceInfo,scope.linkDevicePortId
      )
      # 选择框选择链路端口执行的函数
      scope.slecetLinkPort = (portId) => (
        scope.linkDevicePortId = portId
        scope.linkDeviceName = scope.linkDeviceInfo.model.name
        _.each scope.linkDeviceInfo.ports.items, (item)->
          if scope.linkDevicePortId == item.model.port 
            scope.linkDevicePortName = item.model.name
            scope.linkDevicePortType =item.model.portType
      )
      # 编辑设备数据
      scope.editData = (equipment) =>(
        scope.detailShow = false
        scope.editShow = true
        if equipment
          scope.equipment = equipment
        setEquipmentData()
      )
      # 显示弹框
      scope.popoutOperate = (type) => (
        scope.popoutShow = true
        scope.popoutLeftWidth = "100%"
        scope.popoutTypeShow = type
        if type == "port"
          scope.popoutTitle = "端口列表信息"
          scope.equipment.loadPorts null, (err, ports)=>
            scope.selectRefresh++
        else if type == "repair"
          scope.popoutTitle = "设备维修记录"
        else if type == "ops"
          scope.popoutTitle = "设备运维信息"
      )
      # 关闭弹框
      scope.closePopout = () => (
        scope.popoutShow = false
        scope.operateShow = false
        scope.popoutLeftWidth = "100%"
      )
      # 弹框的操作按钮执行的函数
      scope.showOperate = (port) => (
        scope.linkDeviceInfo = {}
        scope.linkDevicePortId = ""
        scope.linkDevicePortType=""
        scope.selectRefresh++
        scope.operateShow = true
        scope.popoutLeftWidth = "70%"
        scope.devicePortInfo = port
      )
      # 弹框里面取消按钮执行的操作
      scope.cancelOperate = () => (
        scope.operateShow = false
        scope.popoutLeftWidth = "100%"
      )
      # 弹框里面的确定按钮执行的操作
      scope.confirmOperate = () => (
        # console.log "设备端口:",scope.devicePortInfo.model
        # console.log "链路设备信息",scope.linkDeviceInfo
        if scope.linkDeviceId && scope.linkDevicePortId
          # tips = ""
          stationId = scope.deviceStation.model.station
          portId = scope.devicePortInfo.model.port
          portType=scope.devicePortInfo.model.portType
          linkPortId = scope.linkDevicePortId
          linkPortType=scope.linkDevicePortType
          portName = scope.devicePortInfo.model.name
          LinkPortName = scope.linkDevicePortName
          equipmentName = scope.equipment.model.name
          linkEquipmentName = scope.linkDeviceName
          equipmentId = scope.equipment.model.equipment
          linkEquipmentId = scope.linkDeviceId
          changeOrAdd = _.some scope.equipment.model.ports, (item) -> item.id == portId
          if changeOrAdd
            _.each scope.equipment.model.ports, (item) ->
              if item.id == portId
                item.port = {
                  station: stationId,
                  equipment: linkEquipmentId,
                  port: linkPortId,
                  portType:linkPortType,
                  portName: LinkPortName,
                  equipmentName: linkEquipmentName
                }
            _.each scope.linkDeviceInfo.model.ports, (item) ->
              if item.id == linkPortId
                item.port = {
                  station: stationId,
                  equipment: equipmentId,
                  port: portId,
                  portType:portType,
                  portName: portName,
                  equipmentName: equipmentName
                }
            # tips = "是否修改链路"
            # scope.equipment.s
          else
            scope.equipment.model.ports.push(
              {
                id: portId,
                portType:portType,
                port: {
                  station: stationId,
                  equipment: linkEquipmentId,
                  port: linkPortId,
                  portType:linkPortType,
                  portName: LinkPortName,
                  equipmentName: linkEquipmentName
                  # equipmentName:
                }
              }
            )
            scope.linkDeviceInfo.model.ports.push(
              {
                id: linkPortId,
                portType: linkPortType,
                port: {
                  station: stationId,
                  equipment: equipmentId,
                  port: portId,
                  portType:portType,
                  portName: portName,
                  equipmentName: equipmentName
                  # equipmentName:
                }
              }
            )
          #   # tips = "是否添加链路"
          scope.equipment.save (err,res)->
            addPortStatus()
          scope.linkDeviceInfo.save()
      )
      # 点击后去到指定锚点
      scope.goAnchor = (type) => (
        scope.anchor = type
        element.find(".asset-detail-list [anchor=#{type}]").focus()
      )
      # 保存旧数据
      scope.saveValue = (value) =>
        scope.oldValue = value
      # 检查数据是否有变化
      scope.checkValue = (item) =>
        if scope.oldValue == item.value || scope.oldValue == item
          return
        else
          scope.saveEquipment(item)
      # 检测站点变化
      scope.stationCheck = () =>
        if scope.equipment.model.station
          scope.saveEquipment()
      # 保存设备信息
      scope.saveEquipment = (item) =>
        if item
          property = _.find scope.equipment.model.properties, (pro)-> pro.id == item?.model?.property
          if property && (item.model.dataType == "float" || item.model.dataType == "int")
            property.value = Number(item.value)
          else if property
            property.value = item.value
        scope.equipment.save (err, model) =>
          loadStatisticByEquipmentTypes()
      # 查看设备数据
      scope.lookData = (equipment) =>
        scope.detailShow = true
        scope.editShow = false
        if equipment
          scope.equipment = equipment
        setEquipmentData()

        
      # 搜索设备属性-设备编辑
      scope.filterEditItems = ()=>
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
      # 返回按钮执行的函数
      scope.publishBack = () => (
        @publishEventBus('backList', "backList")
      )
      # 添加端口状态
      addPortStatus = () =>
        _.each scope.equipment.ports.items, (item) => (
          item.model.staus = false
          item.model.linkPort = {}
          _.each scope.equipment.model.ports, (port) => (
            if port.id == item.model.port
              item.model.staus = true
              item.model.linkPort = {
                equipment: port.port.equipment
                equipmentName: port.port.equipmentName
                port: port.port.port
                portType:port.port.portType
                portName: port.port.portName
              }

          )
        )
      # 加载所有的用户
      loadAllUsers = () =>
        userService = @commonService.modelEngine.modelManager.getService 'users'
        userService.query {}, null, (err, data) =>
          if not err
            scope.userMsg = data
      #获取所有站点类型
      getStationEquipTypes = (callback) =>
        @allassetStations = []
        @getAllStations scope,scope.station.model.station
        allassetStationsLen = @allassetStations.length
        allassetStationsCount = 0
        allEquipModels = []

        for stationObj in @allassetStations
          stationObj.loadStatisticByEquipmentTypes (err, mod)->
            allEquipModels.push mod
            allassetStationsCount++
            if allassetStationsCount == allassetStationsLen
              callback? allEquipModels
          , true

      # 加载特定类型的设备
      selectType = (type, callback, refresh) =>
        return if not type
        scope.equipments = []
        getStationEquipment = (station, callback) =>
          for sta in station.stations
            getStationEquipment sta, callback
          @commonService.loadEquipmentsByType station, type, (err, mods) =>
            callback? mods
          , refresh
        getStationEquipment scope.station, (equips) =>
          diff = _.difference equips, scope.equipments
          scope.equipments = scope.equipments.concat diff
          scope.$applyAsync()
          for equip in equips
            equip.loadProperties()
            equip.loadPorts()
            equip.model.typeName = (_.find scope.project.dictionary.equipmenttypes.items, (type)->type.key is equip.model.type)?.model.name
            equip.model.templateName = (_.find scope.project.equipmentTemplates.items, (template)->template.model.type is equip.model.type and template.model.template is equip.model.template)?.model.name
            equip.model.vendorName = (_.find scope.project.dictionary.vendors.items, (vendor)->vendor.key is equip.model.vendor)?.model.name
            equip.model.stationName = (_.find scope.project.stations.items, (station)->station.model.station is equip.model.station)?.model.name
      # 对设备类型进行处理
      processTypes = (data, refresh) =>
        return if not data?.statistic
        types = []
        for key, value of data.statistic when value.type[0] isnt '_' #and value.base
          types.push value
        _.map types, (type)=>
          currentType = _.find scope.project.dictionary.equipmenttypes.items, (item) => item.model.type is type.type
          if currentType.model.image
            type.image = currentType.model.image
        scope.equipTypes = types
        typesArr = _.filter scope.equipTypes, (type)=>
          return type.count isnt 0 and type.type isnt 'KnowledgeDepot'
        if !scope.currentType
          scope.currentType = typesArr[0]
        selectType scope.currentType.type, null , refresh
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
          processTypes stationType, true
      # 格式化设备的数据
      setEquipmentData = () =>(
        scope.sizeInfo = []
        scope.maintenanceInfo = []
        scope.useInfo = []
        scope.otherInfo = []
        _.each scope.equipment.properties.items, (item) =>(
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
            scope.equipment.model.remainDate = life?.value - moment().diff(item.value, 'months')
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
          # 获取该设备的维修记录
          if item.model.property == "repair-records"
            return if not item.value
            scope.repairRecords = JSON.parse(item.value)
          if item.model.dataType != "json"
            if item.model.group == "位置信息"
              scope.sizeInfo.push(item)
            else if item.model.group == "维保信息"
              scope.maintenanceInfo.push(item)
            else if item.model.group == "使用信息"
              scope.useInfo.push(item)
            else
              # 是分组为其他信息或者没有设置时
              scope.otherInfo.push(item)
        )
      )
      getWorkFlowRecord = () => (
        @commonService.loadProjectModelByService 'tasks', {}, null, (err, taskModels) => (
          scope.workFlowRecord = taskModels
          processModelDB = @commonService.modelEngine.modelManager.getService 'processes'
          filter = {
            project: scope.project.model.project
          }
          processModelDB.query filter, null, (err, data) =>
            if not err
              scope.processModelDB = data
        )
      )
      getDeviceWorkOrder = () => (
        scope.deviceWorkOrder = _.filter scope.workFlowRecord, (task)->
          task.nodes[0].parameters.equipment == scope.equipment.model.equipment && task.nodes[0].parameters.station == scope.equipment.model.station
        _.each scope.deviceWorkOrder, (item) -> (
          _.each scope.processModelDB, (processModel)->(
            if item.process == processModel.process
              item.processName  = processModel.name
              if processModel.priority == 1
                item.priority = "高"
                item.priorityColor = "#DB4E32"
              if processModel.priority == 2
                item.priority = "中"
                item.priorityColor = "#E9B943"
              if processModel.priority == 3
                item.priority = "低"
                item.priorityColor = "#BECA32"
              if processModel.priority == 4
                item.priority = "其他"
                item.priorityColor = "#FFFF00"
              return
          )
          if item.nodes[0].state == "approval"
            item.status = "批准"
            item.statusColor = "#32CA59"
          else if item.nodes[0].state == "forward"
            item.status = "转发"
            item.statusColor = "#4CA7F8"
          else if item.nodes[0].state == "save"
            item.status = "保存"
            item.statusColor = "#BECA32"
          else if item.nodes[0].state == "reject"
            item.status = "拒绝"
            item.statusColor = "#DB4E32"
          else
            item.status = "未处理"
            item.statusColor = "#E9B943"
        )
      )
      init = () => (
        scope.status = false
        scope.selectRefresh = 0 # 刷新select框用的
        scope.linkDeviceId = "" # 链路设备的id
        scope.linkDeviceInfo = {} # 链路的设备信息
        scope.linkPortInfo = {}
        scope.linkDevicePortId = "" # 链路端口的id
        scope.linkDevicePortType=""
        scope.devicePortInfo = {} # 当前设备操作的网口信息
        scope.deviceStation = {} # 选中设备的当前站点信息
        scope.stationHasDevice = [] # 当前站点的所有设备
        scope.repairRecords = {} # 当前设备维修记录
        scope.popoutShow = false
        scope.userMsg = [] # 所有用户集合
        scope.sizeInfo = []
        scope.maintenanceInfo = []
        scope.useInfo = []
        scope.otherInfo = []
        scope.detailShow = true
        scope.editShow = false
        scope.setting = setting
        scope.anchor = "基本信息"
        scope.popoutTitle = "" # 弹框信息
        scope.equipment = {}
        scope.secondChangeImg = false # 这个是为了第一次进入编辑页面不改变数据
        scope.processModelDB = [] # 运维工单流程模板类型
        scope.workFlowRecord = []# 获取运维工单记录
        scope.tasksDB = [] # 运维工单数据库
        scope.deviceWorkOrder = [] # 当前设备运维工单记录
        loadAllUsers()
        getWorkFlowRecord()
        scope.subscribeEquipment?.dispose()
        scope.subscribeEquipment = @commonService.subscribeEventBus 'equipmentid', (msg) =>
          @commonService.loadStation msg.message.stationid, (err,station)=>
            station.loadEquipment msg.message.equipmentid, null, (err, equipment)=>
              scope.deviceStation = station
              if msg.message.type == "editData"
                scope.detailShow = false
                scope.editShow = true
                scope.secondChangeImg = false
              else
                scope.detailShow = true
                scope.editShow = false
              scope.equipment = equipment
              # 获取当前端口状态
              scope.equipment.loadPorts null, (err, ports)=>
                addPortStatus()
              # 获取当前属性
              scope.equipment.loadProperties null, (err, props) ->
                setEquipmentData()
                getDeviceWorkOrder()
              scope.stationHasDevice = []
              # 获取当前站点下的所有设备
              station.loadEquipments {}, null, (err,equipments) ->
                scope.stationHasDevice = equipments
                scope.stationHasDevice = _.filter scope.stationHasDevice, (item)->
                  item.model.equipment.indexOf("_") == -1
              # console.log "设备信息", scope.equipment
        # 监听设备图片变化
        return if not scope.firstload
        scope.$watch 'equipment.model.image', ()=>(
          if scope.editShow && scope.secondChangeImg
            scope.saveEquipment()
          scope.secondChangeImg = true
        )
      )
      init()

    getAllStations:(refScope,refStation)=>
      stationResult = _.filter refScope.project.stations.items,(stationItem)->
        return stationItem.model.station == refStation
      for stationResultItem in stationResult
        childStations = _.filter refScope.project.stations.items,(stationItem)->
          return stationItem.model.parent == refStation
        @allassetStations.push stationResultItem
        if !childStations
          return

        for childStationsItem in childStations
          @getAllStations(refScope,childStationsItem.model.station)

    resize: (scope)->

    dispose: (scope)->
      scope.subscribeEquipment?.dispose()


  exports =
    AssetDetailDirective: AssetDetailDirective