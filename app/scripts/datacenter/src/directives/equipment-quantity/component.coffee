###
* File: equipment-quantity-directive
* User: David
* Date: 2019/02/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentQuantityDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-quantity"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      initData = () =>
        @stationList = []
        scope.showEquipment = [
          {id:'ups',name:'ups',imgUrl: "#{@getComponentPath('/images/UPS.png')}",length: 0}
          {id:'low_voltage_distribution',name:'配电柜', imgUrl: "#{@getComponentPath('/images/power-box.png')}",length: 0}
          {id:'battery', name:'蓄电池', imgUrl: "#{@getComponentPath('/images/battery.png')}",length: 0}
          ]

      getAllStations = (station,callback) =>
        return if not station
        if station.stations.length > 0
          _.map station.stations, (child) ->
            getAllStations child

#        @stationList = []
        @stationList.push station
        callback? @stationList

      initData()

#      scope.$watch 'parameters.stationId', (stationId) =>
#        initData()
#      @commonService.loadStation stationId, (err,station) =>

      getAllStations scope.station, (stations) ->
#            _.map stations, (sta) ->
#            for sta in stations
#            @stationList = []
        stations.forEach (sta) ->
          sta.loadEquipment null, null, (err, equip) ->
            return if not equip
            typeLength = _.groupBy equip.station.equipments.items, (type) ->type.model.type
            _.map scope.showEquipment, (equipmentType) ->
              if typeLength[equipmentType.id]
                equipmentType.length += typeLength[equipmentType.id]?.length
#                return scope.showEquipment if stations.length == 1
#            stations=[]

    resize: (scope)->

    dispose: (scope)->


  exports =
    EquipmentQuantityDirective: EquipmentQuantityDirective