###
* File: equipment-statistic-directive
* User: David
* Date: 2019/08/03
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentStatisticDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-statistic"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.types = {}
      types = scope.parameters.types ? [{name:"UPS", type:"ups"},{name:"空调", type:"aircondition"}, {name:"传感器", type:"environmental"}]
      stations = @commonService.loadStationChildren scope.station, true
      for type in types
        type.type=type.type.toLowerCase()
        scope.types[type.name] = {type: type.type, count: 0, img: @getTypeImage(type)}
        @getItems scope, stations, type

      scope.getLink = (type) ->
        ret = "#/monitoring/"+scope.project.model.user+"/"+scope.project.model.project+"?type="+type.type
        if type.type is "access"
          ret = "#/door-manager/"+ scope.project.model.user+"/"+scope.project.model.project
        if type.type is "video"
          ret = "#/video/"+ scope.project.model.user+"/"+scope.project.model.project
        ret


    getTypeImage: (type) ->
      ret = @getComponentPath('/images/space.png')
      if type.type in ["ups", "UPS"]
        ret = @getComponentPath('/images/ups.png')
      else if type.type is "aircondition" or type.name.indexOf("空调")>= 0
        ret = @getComponentPath('/images/aircondition.png')
      else if type.type.indexOf("distributor")>=0 or type.name.indexOf("配电")>=0
        ret = @getComponentPath('/images/power-box.png')
      else if type.name.indexOf("电池") >= 0
        ret = @getComponentPath('/images/battery.png')
      ret

    getItems: (scope, stations, type) ->
      for station in stations
        filter = _.omit type, "name"
        station.loadEquipments filter, null, (err, equips) ->
          scope.types[type.name].count += equips.length


    resize: (scope)->

    dispose: (scope)->


  exports =
    EquipmentStatisticDirective: EquipmentStatisticDirective