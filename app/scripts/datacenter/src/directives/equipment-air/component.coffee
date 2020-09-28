###
* File: equipment-air-directive
* User: David
* Date: 2019/12/04
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentAirDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-air"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.selectEquipment = (equip) => (
        if(equip.model.equipment)
          filter = {
            project: equip.model.project,
            user: equip.model.user,
            station: equip.model.station,
            equipment: equip.model.equipment,
            signal: "communication-status"
          }
          scope.theAirStatu.equipStatu = "--"
          scope.theAirStatu.equipName = equip.model.name
          scope.subscribeStation?.dispose()
          scope.subscribeStation = @commonService.signalLiveSession.subscribeValues(filter, (err, signal)=>
            if signal.message
              if signal.message.value == 0
                scope.colorChange = false
                scope.theAirStatu.equipStatu = "正常"
              else
                scope.colorChange = true
                scope.theAirStatu.equipStatu = "断开"
          )
        else
          scope.theAirStatu.equipName = "无空调设备"
          scope.theAirStatu.equipStatu = "--"
      )
      init = () => (
        scope.theAirStatu = {
          equipName : ""
          equipStatu : ""
        }
        scope.equipments = []
        scope.colorChange = false
        scope.stations = _.each scope.project.stations.nitems,(n)-> n.model.station
        stationsNum = scope.project.stations.items.length # 所有站点数量,显示第一个空调的状态
        _.each scope.stations,(station)=> (
          station?.loadEquipments({type: "aircondition"}, null, (err, equips)=>
            stationsNum--
            scope.equipments = scope.equipments.concat(equips)
            if(stationsNum == 0) # 默认显示第一个空调的状态
              scope.selectEquipment(scope.equipments[0])
          , true)
        )
      )
      init()
    resize: (scope)->

    dispose: (scope)->
      scope.subscribeStation?.dispose()


  exports =
    EquipmentAirDirective: EquipmentAirDirective