###
* File: pue-directive
* User: David
* Date: 2019/03/05
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class PueDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "pue"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      initData = () =>
        scope.timeChoose = [
          {signal:"pue-value", mode: 'day', name:'日', period: moment().format('YYYY-MM-DD'),max: 8, min: 5, avg: 0}
          {signal:"pue-value",mode: 'month', name:'月', period: moment().format('YYYY-MM'),max: 7, min: 4, avg: 0}
          {signal:"pue-value",mode: 'year', name:'年', period: moment().format('YYYY'),max: 6, min: 3, avg: 0}
        ]

      scope.getMaxAndMin = ($event,opt) =>
        $('.date').removeClass('date-active')
        $($event.target).addClass('date-active')

        queryDataBase scope.station, opt, (value) =>
          scope.pueValue =
            max: value.max
            min: value.min
            avg: value.avg

      queryDataBase = (station, option, callback) =>
        filter =
          user: @$routeParams.user
          project: @$routeParams.project
          station: station.model.station
          equipment: '_station_efficient'
          signal: option.signal
          period: option.period
          mode: option.mode
        @commonService.reportingService.querySignalStatistics {filter:filter}, (err,records) =>
          return if err
          if not _.isEmpty records
            _.mapObject records, (val) =>
              callback? val.values[0]

      @subscribeEventBus 'stationId', (d) =>
        initData()
        @commonService.loadStation d.message.stationId, (err,station) =>
          scope.station = station
#          _.map scope.energyOption, (consumption) =>
#            queryDataBase station,consumption, (value) ->
#              consumption.value = value.value




    resize: (scope)->

    dispose: (scope)->


  exports =
    PueDirective: PueDirective