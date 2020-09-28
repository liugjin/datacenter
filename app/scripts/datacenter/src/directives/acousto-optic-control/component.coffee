###
* File: acousto-optic-control-directive
* User: David
* Date: 2019/06/14
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class AcoustoOpticControlDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "acousto-optic-control"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.image = @getComponentPath "images/alarm-off.png"
      scope.equip = null
      @getStationAcoustoOpticDevices scope, scope.station, (equip) =>
        return if scope.equip
        scope.equip = equip

        scope.subscription?.dispose()
        scope.subscription = @commonService.subscribeEquipmentSignalValues equip

      scope.offAlarm = =>
        scope.equip.loadCommands null, (err, cmds)=>
          cmd = _.find cmds, (cd)->cd.model.command is "alarm-status"
          if cmd
            value = _.find cmd.model.parameters, (ps)->ps.key is "value"
            value.value = "0"       ##赋值为0代表关闭声光告警
            @executeCommand scope, cmd

    getStationAcoustoOpticDevices: (scope, station, callback) ->
      station.loadEquipments {type: "environmental", template: scope.parameters.template ? "acousto_optic_template"}, null, (err, equips) =>
        if equips.length > 0
          equip = _.max equips, (eq)->eq.model.index
          callback? equip
        else
          for sta in station.stations
            @getStationAcoustoOpticDevices scope, sta, callback


    resize: (scope)->

    dispose: (scope)->


  exports =
    AcoustoOpticControlDirective: AcoustoOpticControlDirective