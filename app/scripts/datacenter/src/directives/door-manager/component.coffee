###
* File: door-manager-directive
* User: bingo
* Date: 2019/03/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DoorManagerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "door-manager"
      super $timeout, $window, $compile, $routeParams, commonService
      @allAcesses = []

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      @allAcesses = []
      element.css("display", "block")
      $scope.setting = setting
      $scope.accessStation = null
      @initEquipments $scope,(retFlag)=>
        if _.has(@$routeParams, "station")
          $scope.accessStation = @$routeParams.station
        else if @allAcesses.length > 0
          $scope.accessStation = @allAcesses[0].model.station
        $scope.subBus?.dispose()
        $scope.subBus = @subscribeEventBus 'stationId', (d) =>
          if _.isEmpty $scope.accessStation
            $scope.accessStation = d.message.stationId
          @commonService.loadStation d.message.stationId, (err,station) =>
            $scope.station = station

    resize: ($scope)->

    dispose: ($scope)->
      $scope.subBus?.dispose()
    initEquipments:(scope,callback)=>
      stationCount = 0
      stationLen = scope.project.stations.items.length
      for stationItem in scope.project.stations.items
        filter = stationItem.getIds()
        filter.type = "access"
        stationItem.loadEquipments filter,null,(err,equips)=>
          for equip in equips
            @allAcesses.push equip
          stationCount++
          if stationCount == stationLen
            callback? true
  exports =
    DoorManagerDirective: DoorManagerDirective