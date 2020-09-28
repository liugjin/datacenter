###
* File: distribution-manager-directive
* User: bingo
* Date: 2019/05/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DistributionManagerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "distribution-manager"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      $scope.equipments = []
      $scope.selectSignals = []
      preference = null
      if localStorage.getItem 'distribution-manager'
        preference = JSON.parse localStorage.getItem 'distribution-manager'

      $scope.$watch "station", (station) =>
        return if not station
        $scope.equipments = []
        $scope.equipment = null
        $scope.selectSignals = []
        loadDistributionEquips()

      # 加载配电设备
      loadDistributionEquips = () =>
        selectType $scope.parameters.type

      # 加载特定类型的设备
      selectType = (type, callback, refresh) =>
        return if not type
        getStationEquipment = (station, callback) =>
          for sta in station.stations
            getStationEquipment sta, callback
          filter =
            user:  station.model.user
            project: station.model.project
            station: station.model.station
            type: type
          station.loadEquipments filter, null, (err, mods) ->
            callback? mods
          , refresh
        getStationEquipment $scope.station, (equips) =>
          diff = _.difference equips, $scope.equipments
          $scope.equipments = $scope.equipments.concat diff
          $scope.$applyAsync()
          return if not $scope.equipments or $scope.equipments.length < 1
          #console.log($scope.equipments)
          equipments = _.sortBy $scope.equipments, (equip) => equip.model.index
          currentEquip = null
          if preference
            currentEquip = _.find equipments, (equip) => equip.model.station is preference.station and equip.model.equipment is preference.equipment
          if currentEquip
            $scope.selectEquipment currentEquip
          else
            $scope.selectEquipment equipments[equipments.length - 1]

      # 选择设备
      $scope.selectEquipment = (equip) =>
        return if not equip
        preference =
          station: equip.model.station
          equipment: equip.model.equipment
        localStorage.setItem 'distribution-manager', JSON.stringify preference
        selectSignals = []
        $scope.equipment = equip
        $scope.equipment.loadProperties null, (err, properties) =>
          #console.log(properties)
          signalsProperty = _.find properties, (property) => property.model.property is "_signals"
          if signalsProperty
            #console.log(signalsProperty)
            if signalsProperty.value
              _.map (JSON.parse signalsProperty.value), (item) =>
                selectSignals.push item.signal
            $scope.selectSignals = selectSignals
            #console.log($scope.selectSignals)

    resize: ($scope)->

    dispose: ($scope)->


  exports =
    DistributionManagerDirective: DistributionManagerDirective