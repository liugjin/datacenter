###
* File: equipment-air-cloud-directive
* User: David
* Date: 2020/05/11
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentAirCloudDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-air-cloud"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.selectEquipment = (equip) => (
        onlineFilter = {
          project: equip.model.project,
          user: equip.model.user,
          station: equip.model.station,
          equipment: equip.model.equipment,
          signal: "communication-status"
        }
        # 订阅空调在线状态
        scope.theAirStatu = {
          equipName : equip.model.name,
          equipStatu : "--",
          supplyTemplate: "--",
          returnTemplate: "--",
          supplyHumidity: "--",
          returnHumidity: "--",
        }
        scope.subscribeOnline?.dispose()
        scope.subscribeOnline = @commonService.signalLiveSession.subscribeValues(onlineFilter, (err, signal)=>
          if signal.message
            if signal.message.value == 0
              scope.colorChange = false
              scope.theAirStatu.equipStatu = "正常"
            else
              scope.colorChange = true
              scope.theAirStatu.equipStatu = "断开"
        )
        # 订阅送风温度
        supplyTemplateFilter = {
          project: equip.model.project,
          user: equip.model.user,
          station: equip.model.station,
          equipment: equip.model.equipment,
          signal: scope.parameters.supplyTemplate || "supply-air-temperature"
        }
        scope.subscribeSupplyTemplate?.dispose()
        scope.subscribeSupplyTemplate = @commonService.signalLiveSession.subscribeValues(supplyTemplateFilter, (err, signal)=>
          scope.theAirStatu.supplyTemplate = (signal.message.value).tofixed(2)
        )
        if(scope.parameters.thShow)
          # 订阅回风温度
          returnTemplateFilter = {
            project: equip.model.project,
            user: equip.model.user,
            station: equip.model.station,
            equipment: equip.model.equipment,
            signal: scope.parameters.returnTemplate || "return-air-temperature"
          }
          scope.subscribeReturnTemplate?.dispose()
          scope.subscribeReturnTemplate = @commonService.signalLiveSession.subscribeValues(returnTemplateFilter, (err, signal)=>
            scope.theAirStatu.returnTemplate = (signal.message.value).tofixed(2)
          )
          # 订阅送风湿度
          supplyHumidityFilter = {
            project: equip.model.project,
            user: equip.model.user,
            station: equip.model.station,
            equipment: equip.model.equipment,
            signal: scope.parameters.supplyHumidity || "supply-air-humidity"
          }
          scope.subscribeSupplyHmidity?.dispose()
          scope.subscribeSupplyHmidity = @commonService.signalLiveSession.subscribeValues(supplyHumidityFilter, (err, signal)=>
            scope.theAirStatu.supplyHumidity = (signal.message.value).tofixed(2)
          )
          # 订阅回风湿度
          returnHumidityFilter = {
            project: equip.model.project,
            user: equip.model.user,
            station: equip.model.station,
            equipment: equip.model.equipment,
            signal: scope.parameters.returnTemplate || "return-air-humidity"
          }
          scope.subscribeReturnHmidity?.dispose()
          scope.subscribeReturnHmidity = @commonService.signalLiveSession.subscribeValues(returnHumidityFilter, (err, signal)=>
            scope.theAirStatu.returnHumidity = (signal.message.value).tofixed(2)
          )
      )
      init = () => (
        scope.theAirStatu = {
          equipName : "",
          equipStatu : "--",
          supplyTemplate: "--",
          returnTemplate: "--",
          supplyHumidity: "--",
          returnHumidity: "--",
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
      scope.subscribeOnline?.dispose()
      scope.subscribeSupplyTemplate?.dispose()
      scope.subscribeReturnTemplate?.dispose()
      scope.subscribeSupplyHmidity?.dispose()
      scope.subscribeReturnHmidity?.dispose()


  exports =
    EquipmentAirCloudDirective: EquipmentAirCloudDirective