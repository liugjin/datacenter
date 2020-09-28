###
* File: alarm-action-directive
* User: David
* Date: 2020/05/14
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class LogicActionDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "alarm-action"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.items = {}
      scope.stas = {}
      scope.equips = {}
      scope.cmds = {}
      scope.sigs = {}
      scope.equipments = []

      scope.info = scope.project.model.setting?.logics ? []
      scope.logics = JSON.parse JSON.stringify(scope.info)
#      scope.logics = [
#        {id: new Date().getTime(), enable:true, input:[{station:"demo", equipment:"1", event:'alarm-temperature-high', value: 'start'},{station:"demo", equipment:"2", event:'trigger-alarm-signal'}], operator: "AND", output:[{station:"demo", equipment:"4", command:"alarm-status", value:"1", valueType:"int"}]}
#        {id: new Date().getTime(), enable:false, input:[{station:"demo2", equipment:"5", event:'alarm-humidity-high', value:'end'}], operator: "OR", output:[{station:"demo2", equipment:"6", command:"alarm-status", value:"0", valueType: "int"}]}
#      ]

      @getAllEquipments scope, =>
        @getLogicsInfo scope

      scope.add = =>
        scope.logic = {id: new Date().getTime(), enable:true, input:[{station:"",equipment:"", event:"", value:""}], operator: "AND", output:[{station:"",equipment:"", command:"", value:"", valueType:""}]}
        scope.index = null

      scope.editLogic = (logic, index) =>
        scope.logic = JSON.parse JSON.stringify logic
        scope.index = index

      scope.deleteLogic = (logic, index) =>
        scope.prompt "联动规则删除确认", "请确认是否删除该联动规则？删除后将从系统中移除不可恢复！", (ok) =>
          if ok
            scope.info.splice index, 1
            scope.project.model.setting?.logics = scope.info
            scope.project.save (err, model) =>
              scope.logics = JSON.parse JSON.stringify(scope.info)
              @getLogicsInfo scope

      scope.selectEquipment = (sta, equip) =>
        equipment = _.find scope.equipments, (item)->item.model.station is sta and item.model.equipment is equip
        return if not equipment
        equipment?.loadSignals null, (e,d) -> scope.$applyAsync()
        equipment?.loadEvents null, (e,d) -> scope.$applyAsync()
        equipment?.loadCommands null, (e,d) -> scope.$applyAsync()
        scope.equips[equipment.model.station+"."+equipment.model.equipment] = equipment

      scope.selectSignal = (sta, equip, sig) =>
        signal = _.find scope.equips[sta+"."+equip].signals.items, (item)->item.model.signal is sig
        return if not signal
        parameter = {enums: _.map(signal.model.format.split(","), (item)->{id: item.split(":")[0], name: item.split(":")[1]})}
        scope.sigs[sta+"."+equip+"."+sig] = parameter

      scope.selectCommand = (sta, equip, cmd) =>
        command = _.find scope.equips[sta+"."+equip].commands.items, (item)->item.model.command is cmd
        return if not command
        parameter = _.find command.model.parameters, (item)->item.key is "value"
        parameter ?= command.model.parameters[0]
        parameter.enums = _.map(parameter.definition.split(","), (item)->{id: item.split(":")[0], name: item.split(":")[1]}) if parameter?.definition
        scope.cmds[sta+"."+equip+"."+cmd] = parameter ? {type: "string"}

      scope.saveLogic = =>
        if @checkInvalidValue scope.logic.input
          return @display "输入项配置有误"
        if @checkInvalidValue scope.logic.output
          return @display "输出项配置有误"
        scope.logic.enable ?= true
        scope.info.push scope.logic if not scope.index?
        scope.info[scope.index] = scope.logic if scope.index?
        scope.project.model.setting?.logics = scope.info
        scope.project.save (err, model) =>
          M.Modal.getInstance($("#logic-modal")).close()
          scope.logics = JSON.parse JSON.stringify(scope.info)
          @getLogicsInfo scope

      scope.filterEnumSignal = ->
        (item) ->
          return item.model.dataType is "enum"

    getPhaseName: (scope, value) ->
      return "所有状态" if value is "+"
      phase = _.find scope.project.dictionary.eventphases.items, (item)->item.model.phase is value
      phase?.model.name ? value

    getAllEquipments: (scope, callback) =>
      scope.stations = scope.project.stations.nitems
      i = 0
      for station in scope.stations
        scope.stas[station.model.station] = station
        station.loadEquipments null, null, (err, equips) =>
          scope.equipments = scope.equipments.concat equips
          i++
          callback?() if i is scope.stations.length

    getLogicsInfo: (scope) ->
      items = []
      _.each scope.logics, (item) ->
        it.id = item.id for it in item.input
        it.id = item.id for it in item.output
        items = items.concat(item.input).concat(item.output)
      for item in items
        id = if item.event then "event."+item.event else if item.command then "command."+item.command else if item.signal then "signal."+item.signal
        item.key = item.id+"."+item.station+"."+item.equipment+"."+id+"."+item.value
        @getItemInfo scope, item

    getItemInfo: (scope, item) ->
      station = _.find scope.stations, (it)->it.model.station is item.station
      sName = station?.model.name ? (if item.station is "+" then "所有站点" else item.station)

      equipment = _.find scope.equipments, (it)->it.model.station is item.station and it.model.equipment is item.equipment
      eName = equipment?.model.name ?  (if item.equipment is "+" then "所有设备" else item.equipment)

      if item.event
        if item.event is "+"
          scope.items[item.key] = {stationName: sName, equipmentName: eName, eventName: "所有告警", valueName: @getPhaseName(scope, item.value)}
        else
          equipment?.loadEvents null, (err, events) =>
            event = _.find events, (it)->it.model.event is item.event
            scope.items[item.key] = {stationName: sName, equipmentName: eName, eventName: event?.model.name ? item.event, valueName: @getPhaseName(scope, item.value)}
            scope.equips[equipment.model.station+"."+equipment.model.equipment] = equipment
      if item.signal
          equipment?.loadSignals null, (err, signals) =>
            signal = _.find signals, (it)->it.model.signal is item.signal
            scope.items[item.key] = {stationName: sName, equipmentName: eName, signalName: signal?.model.name ? item.signal, valueName: @parseEnumValue(signal?.model.format, item.value)}
            scope.equips[equipment.model.station+"."+equipment.model.equipment] = equipment
            parameter = {enums: _.map(signal.model.format.split(","), (item)->{id: item.split(":")[0], name: item.split(":")[1]})}
            scope.sigs[equipment.model.station+"."+equipment.model.equipment+"."+signal.model.signal] = parameter
      if item.command
        equipment?.loadCommands null, (err, commands) =>
          command = _.find commands, (it)->it.model.command is item.command
          parameter = _.find command?.model.parameters, (item)->item.key is "value"
          parameter ?= command?.model.parameters[0]
          scope.items[item.key] = {stationName: sName, equipmentName: eName, commandName: command?.model.name ? item.command, valueName: @parseEnumValue(parameter?.definition, item.value)}
          scope.equips[equipment.model.station+"."+equipment.model.equipment] = equipment
          parameter.enums = _.map(parameter.definition.split(","), (item)->{id: item.split(":")[0], name: item.split(":")[1]}) if parameter?.definition
          scope.cmds[equipment.model.station+"."+equipment.model.equipment+"."+command.model.command] = parameter ? {type: "string"}

    parseEnumValue: (definition, value) ->
      return value if not definition
      arrs = definition.split(",")
      for arr in  arrs
        values = arr.split(":")
        return values[1] if values[0] is value
      return value

    checkInvalidValue: (items) ->
      for item in items
        delete item.key
        delete item.id
        for key, val of item
          return true if _.isEmpty val
          return true if key is "cammand" and val is "+"
      return false

    resize: (scope)->

    dispose: (scope)->


  exports =
    LogicActionDirective: LogicActionDirective