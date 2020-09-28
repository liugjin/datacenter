###
* File: discovery-management-directive
* User: David
* Date: 2020/01/13
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DiscoveryManagementDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "discovery-management"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      filter: '='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.list = []
      scope.mus = sessionStorage.getItem("discovery")
      scope.mus = if scope.mus then JSON.parse scope.mus else {}
      scope.status = {}

      @getAllEquipments scope, (equips)=>
#        equip.loadEquipmentTemplate() for equip in equips
        scope.equipments = equips
        scope.unlinkEquipments = _.filter equips, (equip)->equip.model.sampleUnits.length is 0 or _.isEmpty equip.model.sampleUnits[0]?.value
        filter = JSON.parse JSON.stringify scope.parameters.filter
        scope.project.loadEquipmentTemplates filter, null, (err, templates)=>
          templates = _.filter templates, (template)->template.model.type.substr(0,1)!="_" and template.model.template.substr(0,1)!="_" and template.model.template not in ["facility_base", "It-base"]
          scope.templates = templates if not err
          scope.name = if templates.length > 1 then "设备" else templates[0]?.model.name
          @discovery scope

      scope.addEquipment = (item) =>
        scope.item = item
        template = item.template
        scope.candidates = _.filter scope.unlinkEquipments, (equip)->equip.model.type is template.model.type and equip.model.vendor is template.model.vendor and equip.model.template is template.model.template
        scope.method = if scope.candidates?.length > 0 then 'link' else 'create'
        scope.equipment = scope.station?.createEquipment {type:template.model.type, vendor:template.model.vendor, template:template.model.template}, null
        scope.equipment.model.equipment = if template.model.type is "rack" then item.mu else item.mu+"_"+item.su
        scope.equipment.model.name = item.template.model.name+scope.equipment.model.equipment
        if template.model.type is "rack"
          scope.equipment.loadProperties null, (err, properties)=>
            scope.equipment.setPropertyValue "has-u-locator", "1"
        scope.equipment.model.typeName = (_.find scope.project.dictionary.equipmenttypes.items, (item)->item.model.type is template.model.type)?.model.name
        scope.equipment.model.vendorName = (_.find scope.project.dictionary.vendors.items, (item)->item.model.vendor is template.model.vendor)?.model.name
        scope.equipment.loadEquipmentTemplate null, (err, template) =>
          keys = _.keys scope.equipment.sampleUnits
          if keys?.length is 1
            id = if template.model.type is "rack" then item.mu else item.mu+"/"+item.su
            scope.equipment.sampleUnits[keys[0]].value = id
          else if keys?.length > 1
            su = _.find keys, (s)->s.indexOf('su')>=0
            su = keys[0] if not su
            scope.equipment.sampleUnits[su].value = item.mu+"/"+item.su
            mu = _.find keys, (s)->s.indexOf('mu')>=0
            scope.equipment.sampleUnits[mu].value = item.mu+"/_" if mu
        scope.modal = M.Modal.getInstance $("#add-equipment-modal")
        scope.modal.open()
        scope.$applyAsync()

      scope.selectLinkEquipment = (value)->
        equipment = _.find scope.candidates, (equip) ->equip.key is value
        equipment?.loadEquipmentTemplate null, (err, template) =>
          keys = _.keys equipment.sampleUnits
          if keys?.length is 1
            id = if template.model.type is "rack" then scope.element.mu else scope.element.mu+"/"+scope.element.su
            equipment.sampleUnits[keys[0]].value = id
          else if keys?.length > 1
            su = _.find keys, (s)->s.indexOf('su')>=0
            su = keys[0] if not su
            equipment.sampleUnits[su].value = scope.element.mu+"/"+scope.element.su
            mu = _.find keys, (s)->s.indexOf('mu')>=0
            equipment.sampleUnits[mu].value = scope.element.mu+"/_" if mu
        scope.linkEquipment = equipment

      scope.saveEquipment = () =>
        scope.equipment = scope.linkEquipment if scope.method is "link"
        scope.equipment.save (err, equip)=>
          @display "新增设备失败，因为："+err if err
          scope.modal.close()
          @getAllEquipments scope, (equips) =>
            scope.equipments = equips
            scope.list.splice scope.list.indexOf(scope.item), 1

    getAllEquipments: (scope, callback) =>
      equipments = []
      i = 0
      for station in scope.project.stations.items
        filter = JSON.parse JSON.stringify scope.parameters.filter
        station.loadEquipments filter, null, (err, equips) ->
          equips = _.filter equips, (equip)->equip.model.type.substr(0,1)!="_" and equip.model.template.substr(0,1)!="_" and equip.model.equipment.substr(0,1)!="_"
          equipments = equipments.concat equips if not err
          i++
          if i is scope.project.stations.items.length
            callback? equipments
        , true

    discovery: (scope) =>
      scope.subscription?.dispose()
      scope.subscription = @commonService.liveService.subscribe "sample-values/+/+/_state", (err, sample)=>
#        console.log("发现新设备：",sample)
        mu = sample.message.monitoringUnitId
        su = sample.message.sampleUnitId
        label = mu + "/"+ su
        scope.status[label] = if sample.message.value is 0 then "通讯正常" else "通讯中断"
        scope.status[label] = "通讯中断" if scope.status[mu+"/_"] is "通讯中断"
        return if scope.mus.hasOwnProperty(label) or scope.mus.hasOwnProperty(mu)
        scope.mus[label] = 1
        if @filter scope, mu, su
          template = @find scope, mu, su
          return console.warn("新设备没有对应的设备类型，请检查model配置有无配置描述",mu,su) if not template
          scope.mus[mu] = 1 if template.model.type is "rack"

          scope.list.push {template: template, mu: mu, su: su}

    filter: (scope, mu, su) =>
      id = _.find scope.equipments, (equip)->
        sus = _.pluck equip.model.sampleUnits, "value"
        return mu in sus or mu+"/"+su in sus
      return false if id
      return true

    find: (scope, mu, su) =>
      template = _.find scope.templates, (template)->
        feature = template.model.tag
        return mu.indexOf(feature) >=0 or su.indexOf(feature) >= 0
#        features = template.model.desc?.split "|"
#        key = features?[0]
#        if features?.length is 1 and not _.isEmpty key
#          return mu.indexOf(key) >= 0
#        else if features?.length is 2 and not _.isEmpty key
#          sampleId = features[1]
#          return mu.indexOf(key) >= 0 and su.indexOf(sampleId) >= 0
#        else
#          return false
      template

    resize: (scope)->

    dispose: (scope)->


  exports =
    DiscoveryManagementDirective: DiscoveryManagementDirective