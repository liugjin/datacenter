###
* File: rack-3d-component-directive
* User: David
* Date: 2019/02/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'lodash', "moment","./room","./thing","threejs", "rx"], (base, css, view, _, moment,Room,Thing,Three, Rx) ->
  class Rack3dComponentDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "rack-3d-component"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      window.debugRack3d = scope
      scope.sceneLoadedCompleted = true

      # 3D 服务器 可选 模型，其模板id必须为以下值才有效，否则显示默认值

      room = new Room(
        "rack-3d-room",
        element.find('.rack-3d-canvas')[0],
        {
          camera:{
            type:scope.parameters.camera?.type||"PerspectiveCamera",
            fov:scope.parameters.camera?.fov||50,
            x:scope.parameters.camera?.x||0,
            y:scope.parameters.camera?.y||0,
            z:scope.parameters.camera?.z||0,
            rotationX:scope.parameters.camera?.rotationX||0,
            rotationY:scope.parameters.camera?.rotationY||0,
            rotationZ:scope.parameters.camera?.rotationZ||0
          },
          renderder:{alpha:true,antialias:true},
          orbitControl:true
        }
      )
      scope.room = room

      # 找出子设备
      loadChildren = () =>
        scope.equipment?.children = []
        name = scope.equipment.model.equipment
        _.forEach(scope.equipments,(equip) =>
          if equip.model.parent is name
            scope.equipment?.children.push(equip)
        )
#        console.log("loadChildren", scope.equipment?.model?.equipment,scope.equipment.children.length)

      getServerByRow = (row)->
        result = null
        return if not scope.equipment?.children
        for server in scope.equipment?.children
          min = server.row-server.height+1
          max = server.row
          if row in [min..max]
            result = server

        return result

      # 点击时发出 selectRow消息
      RaycasterClickCallback = (err,intersects) =>
        return console.error err if err
        thing = room.getThingByObject3D(intersects[0].object)
        @commonService.publishEventBus("selectRow",thing.row)
      room.setRaycasterCallback({click:RaycasterClickCallback})

      #订阅 selectRow消息，选中服务器
      scope.subscribeSelectRow?.dispose()
      scope.subscribeSelectRow = @commonService.subscribeEventBus "selectRow",(data) =>
        server = getServerByRow(data.message)
        @commonService.publishEventBus("rack-3d-select-server",{equipment:server})
        thing = room.getThingByName(server?.key)
        room.selectThing(thing)

      # 更新3D模型
      updateRack3D = () =>
        if !_.has(room.thingList, "rack") and scope.equipment?.model?.equipment
          setTimeout(() =>
            changeEquipment(scope.equipment.model.equipment)
          , 1000)
          return 
        rack = room.getThingByName('rack')
        return if not rack
        rack?.removeAllChildren()
        i = 0
        return console.warn("空对象",scope.equipment) if not scope.equipment.model.equipment
        console.log(scope.equipment)
        _.forEach(scope.equipment?.children,(equip) =>
          equip.loadProperties null,(err,properties) =>
            i += 1
            scene = room.scene
            server = equip
            server.row = equip.getPropertyValue("row")
            server.height = equip.getPropertyValue("height")
            server.name = equip.key
            server.type = equip.model.type
            thing = null
            if !server or !server.row or !server.height or server.row < 1
              return console.log('设备参数异常（没有设备、row异常、height异常）：', server,server.row,server.height)
            return console.log("scene 末加载完") if not room.scene?.children?.length > 0
            server3d = equip.getPropertyValue("3d-server")
            if server.type isnt '_server' and server.height
              obj = null
              if server3d 
                obj = scene.getObjectByName(server3d).clone()
              else 
                obj = scene.getObjectByName('server-' + server.height + 'u-real').clone()
              thing = new Thing(server.name, obj, rack)
              thing.setPosition
                x: 1
                y: 4.75 * server.row - 0.5 - 4.35 * server.height
                z: 0
              if thing 
                thing.row = server.row
                thing.setScale 1
                rack.addChild thing
                room.thingList[server.name] = thing
                
            else if server.type is '_server'
              switch server.height
                when 1
                  obj = scene.getObjectByName('server-1u-virtual').clone()
                  thing = new Thing(server.name, obj, rack)
                  thing.setPosition
                    x: 1
                    y: 4.75 * (server.row - 1)
                    z: 0
                when 2
                  obj = scene.getObjectByName('server-2u-virtual').clone()
                  thing = new Thing(server.name, obj, rack)
                  thing.setPosition
                    x: 1
                    y: 4.65 * (server.row - 1)
                    z: 0
                else
                  console.log server.height, ' is not handle.'
                  break
              if thing
                thing.row = server.row
                thing.setScale 1
                rack.addChild thing
                room.thingList[server.name] = thing
            else
              console.warn(server,'is not server or _server.')

            if i >= scope.equipment?.children.length
              room.setRaycasterCheckList rack?.children, true, room.raycaster.callback
        )

      updateRack3DLazy = _.throttle(updateRack3D, 200, { leading: false });

      changeStation = (stationId) =>
        return if not stationId
        @getStation(scope,stationId)
        station = scope.station
        station.loadEquipments({station: station.model.station,project: station.model.project,user: station.model.user},null,(err,equipments) =>
          return console.error(err) if err
          scope.equipments = equipments

          scope.racks = {}
          scope.racks.items = _.filter(equipments?.items, (equipment) => equipment.model.type is 'rack')
          updateRack3DLazy()

        )

      preloadCallback = (preloadValue) =>
        scope.preloadValue = preloadValue

      changeEquipment = (equipmentId) =>
        @getEquipment(scope,equipmentId,(err) =>
          return console.error(err) if err
          return console.warn("空对象",equipmentId,scope.equipment) if not scope.equipment?.model?.equipment
          sceneFile = null
          switch scope.equipment?.model.type
            when "rack"
              sceneFile = @getComponentPath("./files/rack.json") 
              break;
            else
              sceneFile = @getComponentPath("./files/rack-model.json")
              break;
              
          if(sceneFile != scope.sceneFile)
            scope.sceneFile = sceneFile
            room.sceneLoaded = false
            scope.sceneLoadedCompleted = false
            room.loadScene(sceneFile,() =>
              scope.sceneLoadedCompleted = true
              room.sceneLoaded = true
              loadChildren()
              updateRack3DLazy()
              room.orbitControl.enabled = false
            , preloadCallback)
          else
            loadChildren()
            updateRack3DLazy()
        )

      scope.$watch 'parameters.equipmentId',(equipmentId) =>
        return if not equipmentId
        changeEquipment(equipmentId)

      scope.subscribeSelectEquipment?.dispose()
      scope.subscribeSelectEquipment = @commonService.subscribeEventBus "room-3d-select-equipment", (msg) =>
        return if not msg.message.equipment
        equipment = msg.message.equipment
        changeEquipment(equipment.model.equipment)

      # 订阅站点里所有设备变化消息：相关设备变化，然后更新rows
      subscribeConfigurationChanges = () =>
        model = scope.station.model
        station = scope.station
        subject = new Rx.Subject
        topic = "configuration/equipment/+/#{model.user}/#{model.project}/#{model.station}/+"
        scope.configurationHandle?.dispose()
        scope.configurationHandle = @commonService.signalLiveSession.subscribe(topic, (err, d) =>
          return if err
          subject.onNext()
        )
        subject.debounce(500).subscribe =>
          filter = {
            station: station.model.station,
            project: station.model.project,
            user: station.model.user
          }
          station.loadEquipments(filter, null, (err, equipments) =>
            # console.log(equipments)
            return if err
            scope.equipments = equipments

            scope.racks = {}
            scope.racks.items = _.filter(equipments?.items, (equipment) => equipment.model.type is 'rack')
            loadChildren()
            updateRack3DLazy()

          , true)

      subscribeConfigurationChanges()

      changeStation(scope.station.model.station)

    resize: (scope)->

    dispose: (scope)->
      scope.room.dispose()
      scope.sceneFile = null
      scope.subscribeSelectRow?.dispose()
      scope.subscribeSelectEquipment?.dispose()
      scope.configurationHandle?.dispose()



  exports = 
    Rack3dComponentDirective: Rack3dComponentDirective