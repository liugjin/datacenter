###
* File: equipment-breadcrumbs-directive
* User: David
* Date: 2019/03/16
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentBreadcrumbsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-breadcrumbs"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      element.css("display", "block")

      @showStation scope

      scope.selectStation = (station)=>
        scope.station = station
        @showStation scope

      scope.selectEquipment = (equip)=>
#        console.log "station:"+station.model.name
        scope.equipment = equip
        @publishEquipmentId scope

    showStation: (scope) ->
      scope.parents = []
      filter = if scope.parameters.type then {type: scope.parameters.type} else null
      scope.station.loadEquipments filter, null, (err, equips)=>
        scope.equipments = equips if not err
        if not scope.equipment or scope.equipment.model.station isnt scope.station.model.station
          scope.equipment = equips?[0]
          @publishEquipmentId scope

      @findParent scope, scope.station
      scope.stations = scope.parents[0]?.stations
      scope.parents = scope.parents.reverse()

    findParent: (scope, station) ->
      parent = _.find scope.project.stations.items, (sta) ->sta.model.station is station.model.parent
      if parent
        scope.parents.push parent
        @findParent scope, parent

    publishEquipmentId: (scope) ->
      @commonService.publishEventBus "equipmentId", {stationId: scope.equipment?.model?.station, equipmentId: scope.equipment?.model?.equipment}

    resize: (scope)->

    dispose: (scope)->


  exports =
    EquipmentBreadcrumbsDirective: EquipmentBreadcrumbsDirective