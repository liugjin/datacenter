###
* File: signal-extreme-directive
* User: David
* Date: 2019/06/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class SignalExtremeDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "signal-extreme"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      $scope.subscribeSignals = {}
      template = null
      $scope.lookSignals = {}
      $scope.lookSignals[$scope.parameters.signals[0]] =
        signal: null
        equips: {}
        data: []
      $scope.lookSignals[$scope.parameters.signals[1]] =
        signal: null
        equips: {}
        data: []
      # 加载模板
      $scope.project.loadEquipmentTemplates { template: $scope.parameters.template }, null, (err, templates) =>
        return if err or templates.length < 1
        #console.log(templates)
        template = templates[0]
        template.loadSignals null, (err, signals) =>
          #console.log signals
          return if err or signals.length < 1
          signal1 = _.find signals, (signal) => signal.model.signal is $scope.parameters.signals[0]
          if signal1
            signal1.model.unitName = $scope.project?.dictionary.signaltypes.getItem(signal1.model.unit)?.model?.unit
            $scope.lookSignals[$scope.parameters.signals[0]].signal = signal1
          signal2 = _.find signals, (signal) => signal.model.signal is $scope.parameters.signals[1]
          if signal2
            signal2.model.unitName = $scope.project?.typeModels.signaltypes.getItem(signal2.model.unit)?.model?.unit
            $scope.lookSignals[$scope.parameters.signals[1]].signal = signal2
          #console.log($scope.lookSignals)

      # 处理数据
      processSignalData = (signal) =>
        $scope.lookSignals[signal.model.signal]?.equips[signal.equipment.key] =
          name: signal.equipment.model.name
          value: 0
        if signal.data.value #and signal.data.value > 0 and signal.data.value < 100
          $scope.lookSignals[signal.model.signal]?.equips[signal.equipment.key].value = signal.data.value.toFixed(2)
#        else
#          $scope.lookSignals[signal.model.signal]?.equips[signal.equipment.key].value = 0
        _.mapObject $scope.lookSignals, (value, key) =>
          value.data = _.sortBy (_.filter (_.values value.equips), (ite) => ite.value > 0 and ite.value < 100), (item) => item.value
        #console.log($scope.lookSignals)

      # 加载设备
      loadEquips = () =>
        filter =
          user: $scope.station.model.user
          project: $scope.station.model.project
          station: $scope.station.model.station
          type: $scope.parameters.type
          template: $scope.parameters.template
        $scope.station.loadEquipments filter, null, (err, equipments) =>
          #console.log(equipments)
          _.each equipments, (equip) =>
            $scope.subscribeSignals[equip.key]?.dispose()
            $scope.subscribeSignals[equip.key] = @commonService.subscribeEquipmentSignalValues equip, (signal) =>
              #console.log(signal)
              return if not signal or not signal.data
              processSignalData(signal)

      loadEquips()

    resize: ($scope)->

    dispose: ($scope)->
      _.mapObject $scope.subscribeSignals, (value, key) =>
        value.dispose()

  exports =
    SignalExtremeDirective: SignalExtremeDirective