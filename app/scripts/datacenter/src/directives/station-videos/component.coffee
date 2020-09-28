###
* File: station-videos-directive
* User: David
* Date: 2019/09/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationVideosDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-videos"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.videos = []
      scope.nums = [0,1]
      count = scope.parameters.count ? 2
      stations = @commonService.loadStationChildren scope.station, true
      n = 0
      for station in stations
        station.loadEquipments {type:"video"}, null, (err, videos) =>
          n++
          scope.videos = scope.videos.concat videos
          if n is stations.length
            scope.nums = scope.videos.slice 0, count if scope.videos.length

    resize: (scope)->

    dispose: (scope)->


  exports =
    StationVideosDirective: StationVideosDirective