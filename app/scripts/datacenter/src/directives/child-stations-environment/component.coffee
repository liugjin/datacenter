###
* File: child-stations-environment-directive
* User: David
* Date: 2019/06/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ChildStationsEnvironmentDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "child-stations-environment"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.stations = {}
      scope.subscriptions = {}
      scope.templates = {}
      scope.project.loadEquipmentTemplates {type: "environmental"}, null, (err, templates) =>
        for template in templates
          scope.templates[template.model.type+"."+template.model.template] = template

        scope.station.stations = _.sortBy scope.station.stations, (item)->10-item.model.index
        _.each scope.station.stations, (sta)=>
          scope.stations[sta.model.station] = {id: sta.model.station, name: sta.model.name}
          @getStationEnvironment scope, sta

    getStationEnvironment: (scope, station) ->
      @commonService.loadEquipmentsByType station, "environmental", (err, equipments)=>
        ths = @getTemplatesByBase scope, "environmental.temperature_humidity_template"
        leaks = @getTemplatesByBase scope, "environmental.leak_sensor_template"
        smokes = @getTemplatesByBase scope, "environmental.smoke_template"
        th = _.max(_.filter(equipments, (equip)->equip.model.type+"."+equip.model.template in ths), (item)->item.model.index)
        leak = _.max(_.filter(equipments, (equip)->equip.model.type+"."+equip.model.template in leaks), (item)->item.model.index)
        smoke = _.max(_.filter(equipments, (equip)->equip.model.type+"."+equip.model.template in smokes),(item)->item.model.index)
        @subscribeSignalValues scope, th
        @subscribeSignalValues scope, leak
        @subscribeSignalValues scope, smoke

    getTemplatesByBase: (scope, base) ->
      result = [base]
      templates = _.filter scope.templates, (val, key)->val.model.base is base
      for template in templates
        result = result.concat @getTemplatesByBase scope, template.model.type+"."+template.model.template
      result

    subscribeSignalValues: (scope, equipment) ->
      if not _.isEmpty equipment
        scope.subscriptions[equipment.key]?.dispose()
        scope.subscriptions[equipment.key] = @commonService.subscribeEquipmentSignalValues equipment, (signal)=>
          unitName = scope.project?.typeModels.signaltypes.getItem(signal.model.unit)?.model?.unit ? ""
          color = scope.project?.typeModels.eventseverities.getItem(signal.data.severity)?.model?.color ? ""
          scope.stations[equipment.model.station][signal.model.signal] = {value: signal.data?.formatValue + unitName, color: color}

    resize: (scope)->

    dispose: (scope)->
      for key, value of scope.subscriptions
        value?.dispose()

  exports =
    ChildStationsEnvironmentDirective: ChildStationsEnvironmentDirective