###
* File: discovery-station-directive
* User: David
* Date: 2019/03/18
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "jszip2", "./jszip-utils"], (base, css, view, _, moment, zip, util) ->
  class DiscoveryStationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "discovery-station"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.list = []
      scope.mus = sessionStorage.getItem("discovery")
      scope.mus = if scope.mus then JSON.parse scope.mus else {}

      @getAllTemplates scope, (err, templates)=>
        scope.templates = templates if not err
        @discovery scope

      clearInterval scope.timer
      scope.timer = setInterval =>
        return if scope.list.length is 0 or scope.new
        scope.new = true
        scope.element = scope.list.shift()
        template = scope.element.template
        scope.station = scope.project.createStation null
        scope.station.model.station = scope.element.mu
        scope.station.model.name = template.name+scope.element.mu
        scope.modal = M.Modal.getInstance $("#add-station-modal")
        scope.modal.open()
        scope.$applyAsync()
      ,5000

      scope.saveStation = () =>
        scope.station.save (err, station)=>
          @display "新增站点失败，因为："+err if err
          @saveStationEquipments scope

          scope.new = false
          scope.modal.close()
          scope.project.loadStations null, null, true
#          @commonService.publishEventBus "stationId", {stationId: scope.station.model.station}

      scope.cancel = () =>
        scope.new = false
        scope.station = null

    saveStationEquipments: (scope) ->
      equipmentsService = @commonService.modelEngine.modelManager.getService("equipments")
      for equip in scope.element.template.equipments
        delete equip._id
        delete equip._index
        equip.user = scope.station.model.user
        equip.project = scope.station.model.project
        equip.station = scope.station.model.station
        _.each equip.sampleUnits, (su)->
          su.value = scope.element.mu+"/"+su.value.split("/")[1] if su.value.split("/").length>1
        equipmentsService.save equip

    getAllTemplates: (scope, callback) ->
      templates = _.filter scope.project.model.features, (item)->item.image.indexOf('.zip?')>0
      tps = _.map templates, (template) ->
        arr = template.desc.split(":")
        return {id: arr[0], name: arr[1], zip: template.image}
      n = 0
      _.each tps, (tp)=>
        @getZipContent tp.zip, (equips)=>
          n++
          console.log "模型"+tp.name+"("+tp.id+")未配置任何站点设备" if not equips? or equips.length is 0
          tp.equipments = equips
          callback? null, tps if n is tps.length

    getZipContent: (filename, callback) ->
      uploadService = @commonService.modelEngine.modelManager.getService("uploadUrl")
      util.getBinaryContent uploadService.url+"/"+ filename, (err, data) ->
        zip.loadAsync(data).then (zfile)->
          file = _.find zfile.files, (fi) ->fi.dir is false and fi.name.indexOf("project/")>= 0
          file?.async("text").then (text)->
            content = JSON.parse text
            equipments = _.filter content.data.equipments, (equipment)->equipment.station is content.data.stations[0].station
            callback? equipments

    discovery: (scope) =>
      scope.subscription?.dispose()
      scope.subscription = @commonService.liveService.subscribe "sample-values/+/_/_state", (err, sample)=>
        mu = sample.message.monitoringUnitId
        su = sample.message.sampleUnitId
        label = mu + "/"+ su
        return if scope.mus.hasOwnProperty label
        scope.mus[label] = 1
        if @filter scope, mu, su
          template = @find scope, mu, su
          scope.list.push {template: template, mu: mu, su: su} if template

    filter: (scope, mu, su) =>
      id = _.find scope.project.stations.items, (station)->
        station.model.station is mu
      return false if id
      return true

    find: (scope, mu, su) =>
      template = _.find scope.templates, (template)->
        key = template.id
        return mu.indexOf(key) >= 0
      template

    resize: (scope)->

    dispose: (scope)->
      clearInterval scope.timer
      scope.subscription?.dispose()


  exports =
    DiscoveryStationDirective: DiscoveryStationDirective