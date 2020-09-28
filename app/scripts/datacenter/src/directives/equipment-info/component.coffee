###
* File: equipment-info-directive
* User: David
* Date: 2019/03/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentInfoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-info"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload

      scope.rackInfo= [] if not scope.rackInfo
      scope.serverInfo= [] if not scope.serverInfo

      parseEnum=(value,enumString)->
        #防止重复调用时导致的异常
        return value if not _.isNumber(Number(value))

        enumArray = enumString.split(',')
        enumObj = {}
        for i in enumArray
          number = i.split(':')[0]
          val = i.split(':')[1]
          if !number || !val
            return console.error("parseValue",this)
          enumObj[number] = val

        result = enumObj[value]
        return result

      setRackInfo=()->
        return if not scope.equipment
        scope.equipment.loadProperties(null,()=>
          scope.rackInfo = []
          for p in scope.equipment?.properties.items
            m = p?.model
            #按妥协方案，减少配置内容，不再采用分组info来标记，只按index来显示。当为0时，默认显示8个属性。
            #BUG:因为不再使用分组区分，当index 被其它页面使用时，会导致此页面显示受影响。
            #          if m.group?.includes("info")
            if m?.index and m?.index > 0 and m.dataType != 'json'
              value = m.value
              value = moment(m.value).format("YYYY-MM-DD") if m.dataType is "date"
              value = parseEnum(m.value,m.format) if m.dataType is "enum"
              if p.value
                value = p.value
                value = moment(p.value).format("YYYY-MM-DD") if m.dataType is "date"
                value = parseEnum(p.value,m.format) if m.dataType is "enum"
              scope.rackInfo.push({name:m.name,value:value,index:m.index})
          #        console.log("scope.rackInfo",scope.rackInfo)


          if scope.rackInfo.length is 0
            for i in [0..8]
              p = scope.equipment?.properties.items[i]
              m = p?.model
              if m and m.dataType != 'json'
                value = m.value
                value = moment(m.value).format("YYYY-MM-DD") if m.dataType is "date"
                value = parseEnum(m.value,m.format) if m.dataType is "enum"
                if p.value
                  value = p.value
                  value = moment(p.value).format("YYYY-MM-DD") if m.dataType is "date"
                  value = parseEnum(p.value,m.format) if m.dataType is "enum"
                scope.rackInfo.push({name:m.name,value:value,index:m.index})

        )

      setServerInfo=()=>
        return if not scope.server
        scope.server.loadProperties(null,()=>
          scope.serverInfo = []
          for p in scope.server?.properties.items
            m = p?.model
            #按妥协方案，减少配置内容，不再采用分组info来标记，只按index来显示。当为0时，默认显示8个属性。
            #BUG:因为不再使用分组区分，当index 被其它页面使用时，会导致此页面显示受影响。
            #          if m.group?.includes("info")
            if m?.index and m.index > 0 and m.dataType != 'json'
              value = m.value
              value = moment(m.value).format("YYYY-MM-DD") if m.dataType is "date"
              value = p.parseValue(m.value) if m.dataType is "enum"
              if p.value
                value = p.value
                value = moment(p.value).format("YYYY-MM-DD") if m.dataType is "date"
                value = p.parseValue(p.value) if m.dataType is "enum"
              scope.serverInfo.push({name:m.name,value:value,index:m.index})

          if scope.serverInfo.length is 0
            for i in [0..8]
              p = scope.server?.properties.items[i]
              m = p?.model
              if m and m.dataType != 'json'
                value = m.value
                value = moment(m.value).format("YYYY-MM-DD") if m.dataType is "date"
                value = p.parseValue(m.value) if m.dataType is "enum"
                if p.value
                  value = p.value
                  value = moment(p.value).format("YYYY-MM-DD") if m.dataType is "date"
                  value = p.parseValue(p.value) if m.dataType is "enum"
                  scope.serverInfo.push({name:m.name,value:value,index:m.index})
          )

      changeStation=(stationId)=>
        return if not stationId
        @getStation(scope,stationId)
        station=scope.station
        station.loadEquipments({station: station.model.station,project: station.model.project,user: station.model.user},null,(err)=>
          return console.error(err) if err
          scope.equipments = station.equipments?.items
        )

      changeEquipment=(equipmentId)=>
        return if not equipmentId
        @getEquipment scope,equipmentId,(err)=>
          setRackInfo()

      changeServer=(serverId)=>
        return scope.server = null if not serverId
        station=scope.station
        station.loadEquipment(serverId, null,(err, equip)=>
          return console.error(err) if err
          scope.server = equip
          setServerInfo()
#          if scope.station?.equipments?.items.length > 0
#            for equip in scope.station?.equipments?.items
#              if equip.model.equipment is serverId
#                scope.server = equip
#                return setServerInfo()
        )

      scope.$watch 'parameters.station',(stationId)->
        return if not stationId
        changeStation(stationId)

      scope.$watch 'parameters.equipment',(equipmentId)=>
        return if not equipmentId
        changeEquipment(equipmentId)

      scope.$watch 'parameters.server',(serverId)=>
        return if not serverId
        changeServer(serverId)

    resize: (scope)->

    dispose: (scope)->


  exports =
    EquipmentInfoDirective: EquipmentInfoDirective