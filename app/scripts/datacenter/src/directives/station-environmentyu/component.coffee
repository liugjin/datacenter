###
* File: station-environment-directive
* User: David
* Date: 2019/06/05
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationEnvironmentyuDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-environmentyu"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.subscriptions = {}
      scope.templates = {}
      scope.unitys = {}
      if scope.project?.dictionary?.signaltypes?.items
        for i in scope.project.dictionary.signaltypes.items
          scope.unitys[i?.key] = i.model?.unit

      scope.getUnity = (d) ->
        return "--" if !d or !_.has(scope.unitys, d)
        return scope.unitys[d]

      scope.project.loadEquipmentTemplates {type: "environmental"}, null, (err, templates) =>
        for template in templates
          scope.templates[template.model.type+"."+template.model.template] = template
        @getStationEnvironment scope, scope.station

      scope.selectEquipment = (equipment) =>
        @subscribeSignalValues scope, equipment
        scope.th = equipment if equipment.model.type+"."+equipment.model.template in @getTemplatesByBase scope, "environmental.temperature_humidity_template"
        scope.leak = equipment if equipment.model.type+"."+equipment.model.template in @getTemplatesByBase scope, "environmental.leak_sensor_template"
        scope.smoke = equipment if equipment.model.type+"."+equipment.model.template in @getTemplatesByBase scope, "environmental.smoke_template"

      scope.getSeverityColor = (severity) =>
        return "" if not severity
        return scope.project?.typeModels.eventseverities.getItem(severity)?.model?.color ? ""

    getStationEnvironment: (scope, station) ->
      @commonService.loadEquipmentsByType station, "environmental", (err, equipments)=>
        thTs = @getTemplatesByBase scope, "environmental.temperature_humidity_template"
        leakTs = @getTemplatesByBase scope, "environmental.leak_sensor_template"
        smokeTs = @getTemplatesByBase scope, "environmental.smoke_template"
        ths = _.filter equipments, (equip)=>equip.model.type+"."+equip.model.template in thTs
        leaks = _.filter equipments, (equip)=>equip.model.type+"."+equip.model.template in leakTs
        smokes = _.filter equipments, (equip)=>equip.model.type+"."+equip.model.template in smokeTs
        scope.th = if ths.length then _.max(ths, (item)->item.model.index) else null
        scope.leak = if leaks.length then _.max(leaks, (item)->item.model.index) else null
        scope.smoke = if leaks.length then _.max(smokes,(item)->item.model.index) else null
        scope.equipments = ths.concat(leaks).concat smokes
        @subscribeSignalValues scope, scope.th
        @subscribeSignalValues scope, scope.leak
        @subscribeSignalValues scope, scope.smoke

    filterTemplate: (scope, id, base) ->
      template = scope.templates[id]
      return false if not template
      return true if template.model.type+"."+template.model.template is base or template.model.base is base
      return @filterTemplate scope, template.model.base, base

    getTemplatesByBase: (scope, base) ->
      result = [base]
      templates = _.filter scope.templates, (val, key)->val.model.base is base
      for template in templates
        result = result.concat @getTemplatesByBase scope, template.model.type+"."+template.model.template
      result

    subscribeSignalValues: (scope, equipment) ->
      if equipment
        scope.subscriptions[equipment.key]?.dispose()
        scope.subscriptions[equipment.key] = @commonService.subscribeEquipmentSignalValues equipment

    resize: (scope)->

    dispose: (scope)->
      for key, value of scope.subscriptions
        value?.dispose()

  exports =
    StationEnvironmentyuDirective: StationEnvironmentyuDirective