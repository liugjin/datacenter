###
* File: safe-operation-days-directive
* User: David
* Date: 2019/02/19
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class SafeOperationDaysDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "safe-operation-days"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.station=scope.project.stations.items[0]
      scope?.station.loadEquipment "_station_management", null, (err, equipment) =>
        equipment?.loadProperties null, (err, properties) =>
          safetimestr = _.find properties, (property) -> property.model.property is "safe-time"
          scope.value = moment().diff(safetimestr?.model.value, "days").toString()
      scope.value=100 if !scope.value

    resize: (scope)->

    dispose: (scope)->


  exports =
    SafeOperationDaysDirective: SafeOperationDaysDirective