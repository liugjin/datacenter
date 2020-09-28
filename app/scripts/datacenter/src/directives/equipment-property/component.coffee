###
* File: equipment-property-directive
* User: James
* Date: 2019/03/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentPropertyDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-property"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.isMore = false
      scope.info = '更多信息'
      scope.currEquipment = @currEquipment = null

      scope.moreMessage = () ->
        scope.isMore = !scope.isMore
        if scope.isMore
          @info = '隐藏信息'
        else
          @info = '更多信息'

      scope.filterItems = ()->
        (item)->
          if item.model.dataType is "json" or item.model.dataType is "script" or item.model.dataType is "html" or item.model.visible is false
            return false
          if item.model.property is 'equipment-model' or item.model.name is '设备型号'
            return true
          if item.model.property is 'serial-number' or item.model.name is '序列号'
            return true
          if item.model.property is 'asserts-code' or item.model.name is '资产编码'
            return true
          if item.model.property is 'equip-ip' or item.model.name is '设备地址'
            return true
          if item.model.property is 'maintainer' or item.model.name is '维护人'
            return true
          if item.model.property is 'electronic-label' or item.model.name is '电子标签'
            return true
          if item.model.property is 'remark' or item.model.name is '设备高度'
            return true
          if item.model.property is 'equip-ip' or item.model.name is '备注信息'
            return true
          if item.model.property is 'production-time' or item.model.name is '生产日期'
            return true
          if item.model.property is 'buy-date' or item.model.name is '购买日期'
            return true
          if item.model.property is 'install-date' or item.model.name is '安装日期'
            return true
          return false

      scope.filterItems2 = () ->
        (item) ->
          if item.model.dataType is "json" or item.model.dataType is "script" or item.model.dataType is "html" or item.model.visible is false
            return false
          if item.model.property is 'equipment-model' or item.model.name is '设备型号'
            return false
          if item.model.property is 'serial-number' or item.model.name is '序列号'
            return false
          if item.model.property is 'asserts-code' or item.model.name is '资产编码'
            return false
          if item.model.property is 'equip-ip' or item.model.name is '设备地址'
            return false
          if item.model.property is 'maintainer' or item.model.name is '维护人'
            return false
          if item.model.property is 'electronic-label' or item.model.name is '电子标签'
            return false
          if item.model.property is 'remark' or item.model.name is '设备高度'
            return false
          if item.model.property is 'equip-ip' or item.model.name is '备注信息'
            return false
          if item.model.property is 'production-time' or item.model.name is '生产日期'
            return false
          if item.model.property is 'buy-date' or item.model.name is '购买日期'
            return false
          if item.model.property is 'install-date' or item.model.name is '安装日期'
            return false
          return true

      @subEquipProperty?.dispose()
      @subEquipProperty = @commonService.subscribeEventBus 'equipmentId', (d)=>
        if d
          if  d.message.equipmentId.station
            stationResult =  _.filter scope.project.stations.items,(item)->
              return item.model.station ==  d.message.equipmentId.station

            if stationResult.length > 0
              @currStation = stationResult[0]
              filter = scope.project.getIds()
              filter.equipment =  d.message.equipmentId.equipment
              @currStation.loadEquipments filter,null,(err,equipDatas)=>
                if equipDatas
                  equipDatas[0].loadProperties null,(err,prorpertDatas)=>
                    scope.currEquipment = @currEquipment = equipDatas[0]
                    scope.$applyAsync()
    resize: (scope)->

    dispose: (scope)->


  exports =
    EquipmentPropertyDirective: EquipmentPropertyDirective