###
* File: yingmai-environment-directive
* User: David
* Date: 2019/02/15
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class YingmaiEnvironmentDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "yingmai-environment"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.project.loadStations null,(err,stationObjs)=>
        scope.project.loadEquipmentTemplates null,null,(err,templates)=>
          selectTemplates = {}
          selectTemplates["intelli-tempera-humidity"] = []
          selectTemplates["intelli-tempera-humidity"].push "intelli-tempera-humidity"

          selectTemplates["leak_sensor_template"] = []
          selectTemplates["leak_sensor_template"].push "leak_sensor_template"
          selectTemplates["smoke_template"] = []
          selectTemplates["smoke_template"].push "smoke_template"
          for templateItem in templates
            if templateItem.model.base == "environmental.intelli-tempera-humidity"
              selectTemplates["intelli-tempera-humidity"].push templateItem.model.template
            else if templateItem.model.base == "environmental.smoke_template"
              selectTemplates["smoke_template"].push templateItem.model.template
            else if templateItem.model.base == "environmental.leak_sensor_template"
              selectTemplates["leak_sensor_template"].push templateItem.model.template

          @selectStation = scope.station
#          if scope.parameters.stationId
#            stationResult = _.filter scope.project.stations.items,(stationItem)->
#              return stationItem.model.station == scope.parameters.stationId
#            if stationResult.length > 0
#              @selectStation = stationResult[0]



          scope.selectEquipment = (equip) =>
            isFlag = _.indexOf selectTemplates["intelli-tempera-humidity"],equip.model.template
            if isFlag != -1
              @loadEquipmentSignalValues equip,@tempHumi, (signal) =>
                scope.tempHumi[signal.model.signal] = signal

            isFlag = _.indexOf selectTemplates["leak_sensor_template"],equip.model.template
            if isFlag != -1
              @loadEquipmentSignalValues equip,@waterAndSmoke, (signal) =>
                scope.water[signal.model.signal] = signal

            isFlag = _.indexOf selectTemplates["smoke_template"],equip.model.template
            if isFlag != -1
              @loadEquipmentSignalValues equip,@waterAndSmoke, (signal) =>
                scope.smoke[signal.model.signal] = signal

          @initData(scope)

          @commonService.loadEquipmentsByType @selectStation, "environmental", (err,equipments) =>
            return if equipments.length is 0
            @smokeEquip = []
            @waterEquip = []
            @tempHumiEquip = []
            _.map equipments, (equip) =>
              scope.selectEquip = equipments
              isFlag = _.indexOf selectTemplates["smoke_template"],equip.model.template
              if isFlag != -1
                #烟感
                @smokeEquip.push equip

              isFlag = _.indexOf selectTemplates["leak_sensor_template"],equip.model.template
              if isFlag != -1
                #水浸
                @waterEquip.push equip

              isFlag = _.indexOf selectTemplates["intelli-tempera-humidity"],equip.model.template
              if isFlag != -1
                #温湿度
                @tempHumiEquip.push equip

            @loadEquipmentSignalValues @tempHumiEquip[0],@tempHumi, (signal) =>
              scope.tempHumi[signal.model.signal] = signal
            @loadEquipmentSignalValues @waterEquip[0],@waterAndSmoke, (signal) =>
              scope.water = signal
            @loadEquipmentSignalValues @smokeEquip[0],@waterAndSmoke, (signal) =>
              scope.smoke = signal

    loadEquipmentSignalValues: (equipment,callbackList,callback) =>
      _.mapObject @subEquipment?, (val,key) =>
        val?.dispose()
      @subEquipment[equipment.key] = @commonService.subscribeEquipmentSignalValues equipment, (signal) =>
        _.map callbackList, (item) ->
          if signal.model.signal is item
            callback? signal

    initData: (scope) =>
      @smokeEquip = []
      @waterEquip = []
      @tempHumiEquip = []
      @subEquipment = {}

      scope.tempHumi = {}
      @tempHumi = ["humidity","temperature"]
      @waterAndSmoke = ["trigger-alarm-signal"]
      scope.water = {}
      scope.smoke = {}

    resize: (scope)->

    dispose: (scope)->
      _.mapObject @subEquipment, (val,key) =>
        val?.dispose()

  exports =
    YingmaiEnvironmentDirective: YingmaiEnvironmentDirective