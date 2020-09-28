###
* File: discovery-station-management-directive
* User: David
* Date: 2019/05/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "jszip2", "./jszip-utils"], (base, css, view, _, moment, zip, util) ->
  class DiscoveryStationManagementDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "discovery-station-management"
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

      scope.stations = _.filter scope.project.stations.items, (item)->
        if scope.parameters.filter
          return item.model.station.indexOf(scope.parameters.filter)>=0
        return true

      @getAllTemplates scope, (err, templates)=>
        scope.templates = templates if not err
        @discovery scope

      scope.getStationParentName = (stationId) =>
        stationName = _.find @project.stations.items, (station) -> station.model.station is stationId
        if stationName
          return stationName.model.name

      scope.addStationItem = (item) =>
        scope.element = item
        template = item.template
        station = _.omit template.station, "user", "project", "station", "name", "_id", "_index", "_key" ,"createtime", "updatetime"
        scope.station = scope.project.createStation null
        for key, val of station
          scope.station.model[key] = val
        scope.station.model.station = item.mu
        scope.station.model.name = template.name+item.mu
        scope.modal = M.Modal.getInstance $("#add-station-modal")
        scope.modal.open()
        scope.$applyAsync()

      scope.saveStation = () =>
        scope.station.save (err, station)=>
          @display "新增站点失败，因为："+err if err
          @saveStationEquipments scope

          scope.modal.close()
          scope.project.loadStations null, =>
            @commonService.publishEventBus "stationId", {stationId: scope.station.model.station}
          , true

      scope.cancel = () =>
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
      tps = []
      _.each templates, (template) ->
        arr = template.desc.split(":")
        if not scope.parameters.filter or scope.parameters.filter is arr[0]
          tps.push {id: arr[0], name: arr[1], zip: template.image}
      n = 0
      scope.name = tps[0].name if tps.length is 1
      _.each tps, (tp)=>
        @getZipContent tp.zip, (station, equips)=>
          n++
          console.log "模型"+tp.name+"("+tp.id+")未配置任何站点设备" if not equips? or equips.length is 0
          tp.station = station
          tp.equipments = equips
          callback? null, tps if n is tps.length

    getZipContent: (filename, callback) ->
      uploadService = @commonService.modelEngine.modelManager.getService("uploadUrl")
      util.getBinaryContent uploadService.url+"/"+ filename, (err, data) =>
        zip.loadAsync(data).then (zfile)=>
          file = _.find zfile.files, (fi) ->fi.dir is false and fi.name.indexOf("project/")>= 0
          file?.async("text").then (text)->
            content = JSON.parse text
            equipments = _.filter content.data.equipments, (equipment)->equipment.station is content.data.stations[0].station
            callback? content.data.stations[0], equipments
          d3s = _.filter zfile.files, (fi) ->fi.dir is false and fi.name.indexOf("d3/")>= 0
          images = _.filter zfile.files, (fi) ->fi.dir is false and fi.name.indexOf("image/")>= 0
          @uploadReferenceFiles d3s.concat images

    uploadReferenceFiles: (files) =>
      for file in files
        name = file.name.split("/")[1]
        await file.async("arraybuffer").then defer buffer
        data = new File [buffer], name
        url = setting.urls.uploadUrl + "/" + name
        await @commonService.uploadService.upload data, name, url, defer result

    discovery: (scope) =>
      scope.subscription?.dispose()
      scope.subscription = @commonService.liveService.subscribe "sample-values/+/_/_state", (err, sample)=>
        mu = sample.message.monitoringUnitId
        su = sample.message.sampleUnitId
        label = mu + "/"+ su
        scope.status[mu] = if sample.message.value is 0 then "通讯正常" else "通讯中断"
        return if scope.mus.hasOwnProperty label
        scope.mus[label] = 1
        if @filter scope, mu, su
          template = @find scope, mu, su
          scope.list.push {template: template, mu: mu, su: su} if template

    filter: (scope, mu, su) =>
      id = _.find scope.project.stations.items, (station)->
        mu in [station.model.station, station.model.group, station.model.address, station.model.desc]
      return false if id
      return true

    find: (scope, mu, su) =>
      template = _.find scope.templates, (template)->
        key = template.id
        return mu.indexOf(key) >= 0
      template

    resize: (scope)->

    dispose: (scope)->
      scope.subscription?.dispose()


  exports =
    DiscoveryStationManagementDirective: DiscoveryStationManagementDirective