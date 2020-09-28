###
* File: ups-manager-directive
* User: bingo
* Date: 2019/06/03
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class UpsManagerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "ups-manager"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      template = null
      $scope.colorGroup = ["#f1ba15", "#15f0ed", "#30b1ff"]
      $scope.subscribe = {}
      $scope.selectGroup = {}
      $scope.equipments = []
      equipments = []
      $scope.selectEquips = []
      # 加载模板
      $scope.project.loadEquipmentTemplates {template: $scope.parameters.template}, null, (err, templates) =>
        return if err or templates.length < 1
        #console.log(templates)
        template = templates[0]
        template.loadSignals null, (err, signals) =>
            #console.log signals
            return if err or signals.length < 1
            groupSignals = _.groupBy signals, (signal) => signal.model.group
            #console.log(groupSignals)
            $scope.selectGroup[$scope.parameters.group[0]] = groupSignals[$scope.parameters.group[0]]
            $scope.selectGroup[$scope.parameters.group[1]] = groupSignals[$scope.parameters.group[1]]
            #console.log $scope.selectGroup

      $scope.$watch "selectEquips", (selectEquips) =>
        return if not selectEquips or selectEquips.length < 1
        _.each $scope.selectEquips, (equip) => equip.isSelect = true

      # 加载设备
      loadEquips = () =>
        getStationEquipment = (station, callback) =>
          for sta in station.stations
            getStationEquipment sta, callback
          filter =
            user:  station.model.user
            project: station.model.project
            station: station.model.station
            type: $scope.parameters.type
            #template: $scope.parameters.template
          station.loadEquipments filter, null, (err, mods) ->
            callback? mods
          , false
        getStationEquipment $scope.station, (equips)=>
          diff = _.difference equips, equipments
          equipments = equipments.concat diff
          $scope.$applyAsync()
          return if not equipments or equipments.length < 1
          #console.log(equipments)
          _.each equipments, (equip) =>
            equip.isSelect = false
            equip.loadEquipmentTemplate null, (err, template) =>
              return if err
              # if template.model.template is $scope.parameters.template or template.base?.model.template is $scope.parameters.template
              #   console.log("equip",equip)
              if not _.contains $scope.equipments, equip
                $scope.equipments.push equip
                if $scope.selectEquips.length < 2
                  equip.isSelect = true
                  $scope.selectEquips.push equip
                changeSelectEquips()

      # 选择设备
      $scope.selectEquipment = (equipment) =>
        return if not equipment
        equipment.isSelect = !equipment.isSelect
        if equipment.isSelect
          $scope.selectEquips.push equipment
        else
          $scope.selectEquips.splice $scope.selectEquips.indexOf(equipment), 1
        if $scope.selectEquips.length > 2
          equipment.isSelect = !equipment.isSelect
          $scope.selectEquips.splice $scope.selectEquips.indexOf(equipment), 1
          @display "最多只能选两个设备"
          return
        #console.log($scope.selectEquips)
        changeSelectEquips()

      # 选择设备变化之后的处理
      changeSelectEquips = () =>
        _.each $scope.selectEquips, (equip) => equip.isSelect = true
        $scope.equipment = $scope.selectEquips[0]
        _.map $scope.selectEquips, (equip) =>
          $scope.subscribe[equip.key]?.dispose()
          $scope.subscribe[equip.key] = @commonService.subscribeEquipmentSignalValues equip, (signal) =>
            #console.log(signal)
            return if not signal or not signal.data.value
            signal.data.unitName = $scope.project?.typeModels.signaltypes.getItem(signal.data.unit)?.model?.unit.toUpperCase()

      # 选择设备
      $scope.selectEquip = (equipment) =>
        $scope.equipment = equipment

      loadEquips()

    resize: ($scope)->

    dispose: ($scope)->
      _.mapObject $scope.subscribe, (value, key) =>
        value?.dispose()

  exports =
    UpsManagerDirective: UpsManagerDirective