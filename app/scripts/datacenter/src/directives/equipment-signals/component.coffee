###
* File: equipment-signals-directive
* User: David
* Date: 2019/05/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentSignalsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-signals"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      if not scope.equipment
        @getEquipment scope, "_station_management", () =>
          @getEquipmentSignals scope, scope.equipment

    getEquipmentSignals: (scope, equipment) ->
      equipment?.loadProperties null, (err, pts) =>
        console.log "properties:", pts
        properties = equipment.getPropertyValue "_focus", ["communication-status", "alarms", "equipments", "alarmSeverity"]
        equipment?.loadSignals null, (err, signals) =>
          scope.signals = _.filter signals, (sig)->sig.model.signal in properties
          scope.esubscription?.dispose()
          scope.esubscription = @commonService.subscribeEquipmentSignalValues scope.equipment


    resize: (scope)->

    dispose: (scope)->
      scope.esubscription?.dispose()


  exports =
    EquipmentSignalsDirective: EquipmentSignalsDirective