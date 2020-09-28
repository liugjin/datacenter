###
* File: record-hiscurve-directive
* User: David
* Date: 2020/01/03
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class RecordHiscurveDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "record-hiscurve"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.paraName = scope.parameters.name
      scope.filterType = scope.parameters.filterType ? false

      scope.categories = {}
      scope.alarms = {}
      scope.equipTypeLists = []
      scope.signalList = []
      scope.currentType = null
      scope.groups = []
      scope.group = "all"


      scope.selectEquipType = (type) =>
        return if not type
        scope.currentType = type
        @selectType scope, type, null, false
        scope.group = "all"

      scope.project.loadEquipmentTemplates null, null, (err, templates) =>
        scope.templates = templates
        n = 0
        for station in scope.project.stations.nitems
          @loadStationEquipStatistics scope, station, =>
            n++
            if n is scope.project.stations.nitems.length
              _.each scope.project.stations.nitems, (sta)=>
                @computeStationStatistic scope, sta
              @selectStation scope, scope.station

      scope.statusSubscription?.dispose()
      filter1 = scope.project.getIds()
      filter1.station = "+"
      filter1.equipment = "+"
      filter1.signal = "communication-status"
      scope.statusSubscription = @commonService.signalLiveSession.subscribeValues filter1, (err, d)=>
        scope.status[d.message.station+"."+d.message.equipment] = d.message.value

      scope.alarmsSubscription?.dispose()
      filter2 = scope.project.getIds()
      filter2.station = "+"
      filter2.equipment = "+"
      filter2.signal = "alarms"
      scope.alarmsSubscription = @commonService.signalLiveSession.subscribeValues filter2, (err, d)=>
        scope.alarms[d.message.station+"."+d.message.equipment] = d.message.value

      scope.stationSubscription?.dispose()
      scope.stationSubscription = @commonService.subscribeEventBus "selectStation", (msg) =>
        scope.equipments = []
        station = _.find scope.project.stations.items, (sta)->sta.model.station is msg.message.id
        @selectStation scope, station

    selectStation: (scope, station) ->
      scope.station = station
      scope.equipTypeLists = _.map scope.categories[station.model.station], (value, key)->
        item = _.find scope.project.dictionary.equipmenttypes.items, (it)->it.model.type is key
        if item
          value.image = item.model.image
          value.index = item.model.index
        value
      scope.equipTypeLists = _.sortBy scope.equipTypeLists, (item)->0-item.index
      if @$routeParams.type
        type = _.find scope.equipTypeLists, (item)=>item.type is @$routeParams.type
      type = type ? scope.equipTypeLists[0]
      if scope.equipment
        type = _.find scope.equipTypeLists, (item)=>item.type is scope.equipment.model.type
      scope.selectEquipType type
      if scope.equipment
        @$timeout =>
          scope.showEquipment scope.equipment
        ,10

      scope.$applyAsync()

    loadStationEquipStatistics: (scope, station, callback) ->
      station.loadStatisticByEquipmentTypes (err, statistic) =>
        station.categories=[]
        value = JSON.parse JSON.stringify statistic.statistic
        @filterStationStatistic station, value, =>
          if scope.filterType
            for key, val of value
              type = _.find scope.project.dictionary.equipmenttypes.items, (item)->item.model.type is key
              delete value[key] if type?.model.visible is false
          station.categories = value
          callback?()
      ,true
    filterStationStatistic: (station, statistic, callback)->
      station.loadEquipments {type: "access", template: {$nin:['card-sender', 'card_template', 'people_template']}}, null, (err, equips)=>
        statistic["access"]?.count = equips.length
        callback?()

    computeStationStatistic: (scope, station) ->
      item= JSON.parse JSON.stringify station.categories
      scope.categories[station.model.station] = item
      stations = @commonService.loadStationChildren station, false
      for sta in stations
        _.mapObject sta.categories, (val, key)->
          item[key].count += val.count
      _.mapObject item, (val, key)->
        delete item[key] if val.count is 0 or key.substr(0,1) is "_"

    selectType: (scope, type, callback ,refresh) ->
      scope.equipments = []
      scope.groups = []
      stations = @commonService.loadStationChildren scope.station, true
      for station in stations
        @commonService.loadEquipmentsByType station, type.type, (err, equips)=>
          for equip in equips
            equip.model.typeName = (_.find scope.project.dictionary.equipmenttypes.items, (tp)->tp.key is equip.model.type)?.model.name
            equip.model.templateName = (_.find scope.templates, (template)->template.model.type is equip.model.type and template.model.template is equip.model.template)?.model.name
            equip.model.vendorName = (_.find scope.project.dictionary.vendors.items, (vendor)->vendor.key is equip.model.vendor)?.model.name
            equip.model.stationName = (_.find scope.project.stations.items, (station)->station.model.station is equip.model.station)?.model.name
            scope.groups.push equip.model.group if equip.model.group and scope.groups.indexOf(equip.model.group) is -1
          scope.equipments = scope.equipments.concat equips
        ,true

    resize: (scope)->

    dispose: (scope)->
      scope.statusSubscription?.dispose()
      scope.alarmsSubscription?.dispose()
      scope.stationSubscription?.dispose()



  exports =
    RecordHiscurveDirective: RecordHiscurveDirective