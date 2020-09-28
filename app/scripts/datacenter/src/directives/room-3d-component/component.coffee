###
* File: room-3d-component-directive
* User: David
* Date: 2019/02/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'lodash', "moment","./room"], (base, css, view, _, moment,Room) ->
  class Room3dComponentDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "room-3d-component"
      @d3Url = ""
      @oldStyle = {}
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      # window.debugRoom3d = scope
      # debugRoom3d.sel = @
      scope.showDetail = false
      scope.equipmentDetail = null
      scope.allIconVisible = true
      scope.subs={}
      scope.capacitySubscribe = {}
      scope.types = ["rack", "environmental", "Facility"]
      scope.showEquipmentDetail = () =>
        @commonService.loadEquipmentById(scope.station, scope.equipmentDetail.model.equipment, (err, equip) =>
          @commonService.publishEventBus("room-3d-select-equipment-detail", { equip: equip.model.equipment })
        )

      # 隐藏详细
      if scope.parameters.options?['hideDetail']
        scope.hideDetail = true
      # 隐藏 dataBox 信号名字
      if scope.parameters.options?['hideDataBox']
        scope.hideDataBox = true

      scope.hideSetting=(e)=>
        elementRelated = e.toElement || e.relatedTarget
        if element[0].contains(elementRelated)
          return
        else
          setTimeout(()=>
            scope.showSetting = false
          ,10000)

      scope.closeDetail=()=>
        scope.showDetail = false
        scope.equipmentDetail = null

      scope.formatUnit = (unit) =>
        item = _.find(scope.unitys2, (d) => d.key is unit)
        if item
          return item.unit
        else
          return ""

      scope.openDetail=()=>
        #如果不需要显示 直接返回
        return if scope.hideDetail
        if not scope.equipmentDetail
          #如果没有设备就隐藏
          scope.showDetail = false
        else
          scope.showDetail = true
          scope.equipmentDetail.loadSignals null, (err, signals) =>
            # 找出被标记为3d-detail的信号并订阅
            scope.equipmentDetail.signalsDetail = []
            _.forEach(signals, (signal)=>
              if signal.model.group is '3d-detail'
                scope.equipmentDetail.signalsDetail.push(signal)
                scope.subs[signal.key]?.dispose()
                scope.subs[signal.key] = @commonService.subscribeSignalValue signal
            )
            scope.$applyAsync()

      self = @

      updateStation = (equips) =>
        # 更新悬浮实时值
        getIcons()
        getDataBox(equips) if _.isEmpty(room.thingList)
        scope.updateIconsStyle(true)
        if scope.parameters?.options?.eventTipCube
          subscribeStationEvent()

      changeEquips = (err, equipments) =>
        return console.error("设备加载失败") if !equipments
        scope.equipments = equipments
        scope.racks={}
        scope.racks.items = _.filter(scope.equipments, (equipment) -> equipment.model.type is 'rack')
        scope.$root.$applyAsync()

      changeStation = (stationId) =>
        return if not stationId
        getUnitys()
        @commonService.loadStation(stationId, (err, station) =>
          station = scope.station
          return console.error("站点加载失败") if !station
          _param = {station: station.model.station,project: station.model.project,user: station.model.user}
          station.loadEquipments(_param, null, changeEquips) 
        )

      changeStationLazy = _.throttle(changeStation, 50, { leading: false })

      capacityList=[
        'ratio-comprehensive', 'ratio-cooling',
        'ratio-ports', 'ratio-power',
        'ratio-space', 'ratio-weight',
        'plan-ratio-comprehensive', 'plan-ratio-cooling',
        'plan-ratio-ports', 'plan-ratio-power',
        'plan-ratio-space', 'plan-ratio-weight'
      ]
      capacityCollection = {}
      scope.capacityCollection = capacityCollection
      colorMaps = [
        { value: 0, color: "#8bc34a" },
        { value: 50, color: "#ffeb3b" },
        { value: 80, color: "#ff9800" },
        { value: 100, color: "#f44336" }
      ]
      scope.tipBoxStyle = {}
      scope.tipBoxInnerStyle ={}
      param = {
        camera: {
          type: scope.parameters.camera?.type || "PerspectiveCamera",
          fov: scope.parameters.camera?.fov || 50,
          x: scope.parameters.camera?.x || 0,
          y: scope.parameters.camera?.y || 0,
          z: scope.parameters.camera?.z || 0,
          rotationX: scope.parameters.camera?.rotationX || 0,
          rotationY: scope.parameters.camera?.rotationY || 0,
          rotationZ: scope.parameters.camera?.rotationZ || 0
        },
        renderder: { alpha: true, antialias: true },
        orbitControl: true
      }
      room = new Room("room-1", element.find('.room-3d-canvas')[0], param)
      scope.room = room

      # 监听滚轮 缩放图标大小
      scope.iconSize = 48
      room.renderer.domElement.addEventListener("wheel", (e) =>
        scope.updateIconsStyle(true)
        if ( e.wheelDelta )
          delta = e.wheelDelta / 60
        else if ( e.detail )
          delta = -e.detail / 2
        # up
        if delta > 0 and scope.iconSize < 64
          scope.iconSize += 1
        # down
        else if delta < 0 and scope.iconSize >0
          scope.iconSize -= 1
      )

      getPosition3DByEquipmentName=(name)->
        return if not name
        equipment = _.find(scope.equipments,(e)->
          return e?.model.equipment is name
        )
        return equipment?.getPropertyValue("3d-position")

      calculateRatioComprehensive=()->
        for key of capacityCollection
          obj = capacityCollection[key]
          obj['ratio-comprehensive'] = 0
          for i in [1..5]
            capacity = capacityList[i]
            if obj[capacity] > obj['ratio-comprehensive']
              obj['ratio-comprehensive'] = obj[capacity]

          obj['plan-ratio-comprehensive'] = 0
          for i in [7..11]
            capacity = capacityList[i]
            if obj[capacity] > obj['plan-ratio-comprehensive']
              obj['plan-ratio-comprehensive'] = obj[capacity]
          # if over 100,make planValue = 0
          if obj['plan-ratio-comprehensive'] + obj['ratio-comprehensive'] >100
            obj['plan-ratio-comprehensive']=0

      getIcons = () =>
        scope.iconThings = _.filter(room.thingList, (thing) => thing.userData.icon)
        
      applyAsyncThrottle = _.throttle(scope.$applyAsync, 200)
      
      scope.updateIconsStyle = (reflesh) =>
        if scope.updateIconsFlag or reflesh
          if scope.iconThings?.length>0
            for thing in scope.iconThings
              coordinate = room.getScreenCoordinate(thing.showingObject)
              thing.iconStyle={}
              thing.iconStyle["width"] = scope.iconSize+'px'
              thing.iconStyle["height"] = scope.iconSize+'px'
              left = Number( (coordinate.x-room.offsetLeft-scope.iconSize/2).toFixed(0))
              top = (coordinate.y-room.offsetTop-scope.iconSize/2).toFixed(0)
              thing.iconStyle["left"] = left+'px'
              thing.iconStyle["top"] = top+'px'
          if scope.dataBoxThings?.length>0
            # 更新 data-box 样式
            for thing in scope.dataBoxThings
              coordinate = room.getScreenCoordinate(thing.showingObject)
              thing.dataBoxStyle={}
              left = Number((coordinate.x-room.offsetLeft).toFixed(0))
              top = (coordinate.y-room.offsetTop).toFixed(0)
              thing.dataBoxStyle["left"] = (left - 10)+'px'
              thing.dataBoxStyle["top"] = (top - 10)+'px'
            applyAsyncThrottle()

      getUnitys = () =>
        scope.unitys={}
        return console.warn("获取单位数据异常") if not scope.project?.dictionary?.units?.items?.length > 0
        scope.unitys2 = _.map(scope.project.dictionary.signaltypes.items, (d) -> { key: d?.key, unit: d?.model?.unit })
        for i in scope.project.dictionary.signaltypes.items
          scope.unitys[i?.key] = i.model?.unit
      
      getUnitys()

      getDataBox = () =>
        return if scope.hideDataBox
        equipments = scope.equipments
        _.forEach(scope.subs, (d) => subs?.dispose()) if !_.isEmpty(scope.dataBoxSignals)
        
        scope.dataBoxSignals = {}
        scope.dataBoxThings = _.filter(room.thingList, (thing) -> typeof(thing.userData?.dataBoxNumber) == 'number')
        
        # console.log("equipments:", _.map(equipments, (d) -> d.getPropertyValue('3d-position')))
        siteList = _.map(scope.dataBoxThings, (n) -> n.name)
        # console.log("siteList:", siteList)
        equipsList = _.filter(equipments, (equip) => siteList.indexOf(equip.getPropertyValue('3d-position')) != -1)
        if equipsList.length == 0
          equipsList = _.filter(equipments, (equip) => siteList.indexOf(equip?.position) != -1)
        # console.log("equipsList:", equipsList)
        _.forEach(equipsList, (equip) =>
          position = equip.getPropertyValue('3d-position')
          scope.dataBoxSignals[position] = [] if !_.has(scope.dataBoxSignals, position)
          equip.loadSignals(null, (err, signals) =>
            _signals = if signals.length == 0 then equip.signals.items else signals
            showSig = _.sortBy(_.filter(_signals, (sig) -> sig.model.group is '3d-data-box'), (d) -> d.model.index)
            for sig in showSig
              scope.dataBoxSignals[position].push(sig)
              scope.subs[sig.key]?.dispose()
              scope.subs[sig.key] = @commonService.subscribeSignalValue(sig)
          , true)
        )

      updateTipPosition = (thing, mouse) =>
        scope.tipBoxStyle = { top: (mouse.y - 50) + 'px', left: mouse.x + 'px' }

      raycasterMousemoveCallback = (err, intersects, mouse) =>
        return console.error(err) if err
        if !intersects[0]?.object
          scope.tipBoxVisible = false
          scope.$applyAsync()
          return
        thing = room.getThingByObject3D(intersects[0].object)
        equipment = _.find(scope.equipments, (equip) => equip.getPropertyValue('3d-position') == thing.name)
        return if !equipment
        if(thing.userData.selectedPositionOffset)
          updateTipPosition(thing, mouse)
          scope.tipBoxTitle = equipment?.model.name
          scope.tipBoxVisible = true
        else
          scope.tipBoxVisible = false
        scope.$applyAsync()

      # 通过 3d-position 获取设备对象
      getEquipmentByPosition = (position) ->
        result = null
        return console.log('err:equipments is null.') if !scope.equipments
        for equip in scope.equipments
          if equip.getPropertyValue('3d-position') == position
            result = equip 
            break;
        return result

      scope.selectEquipment = (thing) =>
        room.selectThing thing
        room.setOutline([thing.showingObject])
        # 设置该设备为选中设备
        scope.equipmentDetail = getEquipmentByPosition(thing.name)

        # 摄像头设备不显示详情
        if(scope.equipmentDetail?.model.type == "video")
          scope.hideDetail = true
        else
          scope.hideDetail = false
          scope.openDetail()

      raycasterClickCallback = (err, intersects) =>
        return console.error err if err
        thing = room.getThingByObject3D(intersects[0].object)
        @commonService.publishEventBus("room-3d-select-equipment", { position: thing.name, equipment: getEquipmentByPosition(thing.name) })
        scope.selectEquipment(thing) if(thing.userData.selectedPositionOffset)
      
      checkObj = (obj) =>
        thing = room.getThingByObject3D(obj)
        if _.find(scope.equipments, (equip) => equip.getPropertyValue("3d-position") == thing.name)
          return true
        return false

      room.setRaycasterCallback({ click: raycasterClickCallback, mousemove: raycasterMousemoveCallback, check: checkObj })

      scope.modeSubscription?.dispose()
      scope.modeSubscription = @commonService.subscribeEventBus("changeShowModel", (data) ->
        type = data.message.type
        subType = data.message.subType
        scope.changeShowModelType = type
        scope.changeShowModelSubType = subType
        #实体模式下才显示图标
        if type is 'object3D'
          scope.allIconVisible = true
          scope.wallFlag = false
        else
          scope.allIconVisible = false
        #实体模式下才显示图标
        if (type is "capacityObject3D")
          room.changeToCapacity()
          colorMaps = scope.project.dictionary.capacities.getItem(subType.split('-')[1])?.model.maps
          if !colorMaps 
            colorMaps = scope.project.dictionary.capacities.items[0]?.model.maps
          if !colorMaps 
            colorMaps = [
              { color: "#8bc34a", value: 0 },
              { color: "#ffeb3b", value: 50 },
              { color: "#ff9800", value: 80 },
              { color: "#f44336", value: 100 }
            ]

          if subType == 'ratio-comprehensive' 
            calculateRatioComprehensive()

          for key of capacityCollection
            value = capacityCollection[key][subType] || 0
            planValue = capacityCollection[key]['plan-'+subType] || 0
            # if over 100,make planValue = 0
            if planValue + value > 100
              planValue = 0
            color = '#ffffff'
            for v in colorMaps
              if value > v.value then color =v.color
            name = getPosition3DByEquipmentName(key)
            if name
              room.setThingCapacity(name, value, color)
              room.setThingCapacity(name, planValue, null, true)
        else if(type is "object3D")
          room.changeToNormal()
      )

      updateCapacityCollectionLazy = _.throttle(() =>
        type = scope.changeShowModelType
        subType = scope.changeShowModelSubType
        if type == 'capacityObject3D'
          if subType == 'ratio-comprehensive' then calculateRatioComprehensive()
          for key of capacityCollection
            value = capacityCollection[key][subType]
            planValue = capacityCollection[key]['plan-'+subType]
            color = '#ffffff'
            for v in colorMaps
              if value >= v.value 
                color = v.color
                break;
            name = getPosition3DByEquipmentName(key)
            if name
              room.setThingCapacity(name, value, color)
              room.setThingCapacity(name, planValue, null, true)
      , 1000)

      # get capacity value
      subscribeStationCapacity = (stationId) =>
        return if scope.parameters.noCapacity
        capacityCollection = {}
        scope.capacityCollection = capacityCollection
        for sig in capacityList
          filter =
            user: scope.project.model.user
            project: scope.project.model.project
            station: stationId
            equipment: '+'
            signal: sig
          n = 0
          scope.capacitySubscribe[sig]?.dispose()
          scope.capacitySubscribe[sig] = @commonService.signalLiveSession.subscribeValues(filter, (err, data) =>
            return console.error(err) if err
            if capacityList.indexOf(data.message.signal) != -1
              rackName = data.message.equipment
              signal =  data.message.signal
              value = data.message.value
              if not capacityCollection[rackName] then capacityCollection[rackName] = {}
              capacityCollection[rackName][signal] = value
              updateCapacityCollectionLazy()
          )

      # 告警统计
      subscribeArray=[]
      scope.eventEquipmentsName = new Set()
      setTipCubeLazy = _.throttle(()=>
        room?.deleteAllTingTipCube()
        scope.eventEquipmentsName?.forEach((n)=>
          position = getPosition3DByEquipmentName(n)
          thing = room.getThingByName(position)
          room.setThingTipCube(thing,0xff0000,0xffffff) if thing
        )
      ,500)

      scope.disposeSubscribe = () ->
        i?.dispose() for i in subscribeArray

      processEvent = (event)->
        return if not event
        if event.phase is "start"
          scope.eventEquipmentsName?.add(event?.equipment)
        else if scope.eventEquipmentsName.has(event?.equipment)
          scope.eventEquipmentsName?.delete(event?.equipment)
        setTipCubeLazy()

      subscribeStationEvent=()=>
        scope.disposeSubscribe()
        scope.eventEquipmentsName?.clear()
        user=scope.project.model.user
        project=scope.project.model.project
        if scope.station?.stations?.length > 0
          for station in scope.station?.stations
            filter = { user: user, project: project, station: station.model.station }
            subscribe = @commonService.eventLiveSession.subscribeValues(filter, (err, d) => processEvent(d.message))
            subscribeArray.push(subscribe)
        else
          filter = { user: user, project: project, station: scope.station?.model.station }
          subscribe = @commonService.eventLiveSession.subscribeValues(filter, (err, d) => processEvent(d.message))
          subscribeArray.push(subscribe)

      loadFun = (stationId) =>
        scope.sceneLoadedCompleted = true
        scope.showDetail = false
        scope.equipmentDetail = null
        room.initOutline()
        subscribeStationCapacity(stationId)
        getIcons()
        scope.equipments = []
        @commonService.loadStation(stationId, (err, station) =>
          return if !station
          scope.station = station
          param = scope.project.getIds()
          param.station = stationId
          if station.stations.length > 0
            scope.equipments = []
            staList = _.map([0..3], (d) =>
              if d <= 2
                return station.stations[d]
              else
                return station
            )
            _staListLen = staList.length
            _.each(staList, (sta) =>
              sta?.loadEquipments(null, null, (err2, equips) =>
                _staListLen--
                list = _.filter(equips, (d) -> d.model.template.indexOf("hw-collector") != -1 or d.model.template == "bset-th" or d.model.template == "interline-ac" or d.model.template == "kehua-ups")
                scope.equipments = scope.equipments.concat(list) if list.length > 0
                if _staListLen == 0
                  len = scope.equipments.length
                  _.each(scope.equipments, (e) =>
                    e.loadProperties(null, (err3, properties) =>
                      len--
                      if len == 0
                        scope.equipments = _.filter(scope.equipments, (m) -> m.getPropertyValue("3d-position"))
                        getDataBox()
                        scope.updateIconsStyle(true)
                    )
                  )
              )
            )
          else
            station.loadEquipments(null, null, (err2, equips) =>
              list = _.filter(equips, (equip) => scope.types.indexOf(equip.model.type) != -1)
              len = list.length
              _.each(list, (e) =>
                e.loadProperties(null, (err3, properties) =>
                  len--
                  if len == 0
                    scope.equipments = _.filter(list, (m) -> m.getPropertyValue("3d-position"))
                    getDataBox()
                    scope.updateIconsStyle(true)
                )
              )
            )
        )
        if scope.parameters?.options?.eventTipCube
          subscribeStationEvent()
        
      loadScene = (scene, stationId) =>
        return if !scene or typeof(scene) != "string"
        scene = "/resource/upload/img/public/" + scene if scene.substr(0,1) isnt "/"
        if scene == @d3Url
          loadFun(stationId)
          return
        @d3Url = scene
        preloadCallback = (preloadValue) =>
          scope.preloadValue = preloadValue
          scope.sceneLoadedCompleted = true if preloadValue == 100
          scope.$applyAsync()

        scope.sceneLoadedCompleted = false
        scope.rotateRoom(false)

        room.loadScene(scene, () =>
          loadFun(stationId)
          @commonService.publishEventBus("3dgameover", { scene: scene })
        , preloadCallback, { noCache: scope.parameters?.options?.noCache })

      scope.time = 5000
      rotateRoom = (flag) => (
        scope.flag = flag
        scope.room.autoRotate(flag, 1)
        @commonService.publishEventBus("capacity-rotate-control",flag)
        if flag
          scope.room.addAnimate('rotateRoom',() =>
            scope.updateIconsStyle(true)
          )
        else
          scope.room.removeAnimate('rotateRoom')
      )
      
      scope.rotateRoom = (flag) => (
        scope.time = 5000
        rotateRoom(flag)
      )
      # 定时器
      scope.interval = window.setInterval(() =>
        if scope.time <= 0 && !scope.flag
          rotateRoom(true)
        else if scope.time > 0
          scope.time = scope.time - 1000
      , 1000)
      
      onKeyDown = () =>
        scope.updateIconsStyle(true)

      # 3d漂浮图标点击
      scope.clickIcon = (thing) =>
        current = getEquipmentByPosition(thing.name)
        if(current)
          scope.equipmentDetail = current
          scope.openDetail()

      window.addEventListener( 'keydown', onKeyDown, false )

      # icon 墙 点击
      scope.wallFlag = false
      scope.setWall = () =>
        scope.wallFlag = !scope.wallFlag
        scope.room.setTopMeshWireframe(scope.wallFlag)

      # 站点切换订阅
      scope.subsribeStationId?.dispose()
      scope.subsribeStationId = @commonService.subscribeEventBus("stationId", (msg) =>
        _sta = _.find(scope.project.stations.items, (sta) -> sta.model.station is msg.message.stationId)
        if _sta.model?.group == "use-parent"
          url = if _sta.model?.d3 then _sta.model.d3 else _sta?.parentStation?.model?.d3
          loadScene(url, msg.message.stationId)
        else
          loadScene(_sta.model?.d3, msg.message.stationId)
      )

      scope.$watch("parameters.types", (types) =>
        if types instanceof Array
          scope.types = types
          scope.$applyAsync()
      )

      # 初始化
      init = () =>
        stationId = scope.station?.model?.station
        if _.has(scope.controller, "$location")
          obj = scope.controller.$location.search()
          stationId = obj.station if !stationId and _.has(obj, "station")
        _sta = _.find(scope.project.stations.items, (sta) => sta.model.station is stationId)
        return console.error("没有获取到站点!!") if !_sta

        if _sta.model?.group == "use-parent"
          url = if _sta.model?.d3 then _sta.model.d3 else _sta?.parentStation?.model?.d3
          loadScene(url, stationId)
        else
          loadScene(_sta.model?.d3, stationId)

      init()

    resize: (scope)->
      setTimeout(() -> 
        scope.updateIconsStyle(true)
      , 100)

    dispose: (scope) ->
      @d3Url = null
      scope.room?.dispose()
      scope.modeSubscription?.dispose()
      scope.subsribeStationId?.dispose()
      scope.subs[sub]?.dispose() for sub of scope.subs
      scope.capacitySubscribe[sub]?.dispose() for sub of scope.capacitySubscribe
      scope.disposeSubscribe()
      window.clearInterval(scope.interval)

  exports =
    Room3dComponentDirective: Room3dComponentDirective