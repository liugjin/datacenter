###
* File: dashboard-header1-directive
* User: David
* Date: 2019/05/07
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class DashboardHeader1Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "dashboard-header1"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @publishEventBus 'menuState', {'menu': 'menu'}
      return if not scope.firstload
      scope.title = scope.parameters.title ? scope.project.model.setting.name
      elems = element.find('.dropdown-trigger')
      instances = M.Dropdown.init(elems, {hover:true,container:element.find('#station-select')[0],constrainWidth:false})

      scope.document = document

      scope.selectStation=(station)=>
        return if not station
        scope.controller.$location.search('station='+station.model.station)
        #        scope.station = station
        @commonService.publishEventBus "stationId", {stationId: station.model.station}

      #      scope.selectStation(scope.station)

      # 实时时间
      scope.day = moment().format('YYYY-MM-DD')
      scope.time = moment().format('HH:mm:ss')
      scope.date = moment().format('dddd')

      clearInterval scope.interval
      scope.interval = setInterval(()=>
        scope.day = moment().format('YYYY-MM-DD')
        scope.time = moment().format('HH:mm:ss')
        scope.date = moment().format('dddd')
        if scope.time=="23:59:59"
          window.location.reload()
        scope.$applyAsync()
      ,1000)

    resize: (scope)->

    dispose: (scope)->
      clearInterval scope.interval


  exports =
    DashboardHeader1Directive: DashboardHeader1Directive