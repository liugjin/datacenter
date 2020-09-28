###
* File: micromodule-dashboard-directive
* User: David
* Date: 2019/01/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class MicromoduleDashboardDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "micromodule-dashboard"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      title: '='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      window.debugR = scope
      scope.title = scope.parameters.title ? scope.project.model.setting.name

      elems = element.find('.dropdown-trigger')
      instances = M.Dropdown.init(elems, {hover:true,container:element.find('#station-select')[0],constrainWidth:false})

      scope.document = document
#      scope.fullScreen=()=>
#        if document.webkitIsFullScreen
#          document.webkitExitFullscreen()
#          scope.fullScreenFlag=false
#        else
#          document.getElementsByTagName("micromodule-dashboard")[0].webkitRequestFullScreen()
#          scope.fullScreenFlag=true

      subscribePueValue=()=>
# subscribe pue value
        efficientFilter =
          user: scope.project.model.user
          project: scope.project.model.project
          station: scope.station.model.station
          equipment: '_station_efficient'
          signal: 'pue-value'
        scope.efficientStatusSubscription?.dispose()
        scope.efficientStatusSubscription = @commonService.signalLiveSession.subscribeValues efficientFilter, (err, d) =>
          if d.message.signal == 'pue-value'
            scope.pue = d.message.value?.toFixed(2)
      #            console.log("pue:",scope.pue)

      # 告警统计
      scope.severityMap = {}
      topicList = {}
      subscribeArray=[]

      disposeSubscribe=()->
        for i in subscribeArray
          i?.dispose()
      scope.disposeSubscribe = disposeSubscribe

      processEvent = (event)->
        return if not event

        key = "#{event.user}.#{event.project}.#{event.station}.#{event.equipment}.#{event.event}.#{event.severity}.#{event.startTime}"
        if not topicList[key]
          topicList[key] = event
          if not topicList[key].endTime
            if not scope.severityMap[event.severity]
              scope.severityMap[event.severity] = 1
            else
              scope.severityMap[event.severity] += 1
        else if topicList[key] and not topicList[key].endTime and event.endTime
          topicList[key] = event
          scope.severityMap[event.severity] -= 1

      SubscribeStationEvent=()=>
        disposeSubscribe()
        user=scope.project.model.user
        project=scope.project.model.project
        if scope.station?.stations?.length > 0
          for station in scope.station?.stations
            filter =
              user: user
              project: project
              station: station.model.station
            subscribe = @commonService.eventLiveSession.subscribeValues filter, (err, d) =>
              processEvent d.message
            subscribeArray.push(subscribe)
        else
          filter =
            user: user
            project: project
            station: scope.station?.model.station
          subscribe = @commonService.eventLiveSession.subscribeValues filter, (err, d) =>
            processEvent d.message
          subscribeArray.push(subscribe)

      # 选择站点
      scope.selectStation=(station)=>
        return if not station
        scope.controller.$location.search('station='+station.model.station)
        scope.severityMap = {}
        topicList = {}
        subscribeArray=[]
        scope.rotateIndex = 0
        rotateWaitingFlag =true

        scope.station = station
        #        scope.stationId = station.model.station
        if station.model.d3
          scope.scene = "/resource/upload/img/public/"+station.model.d3
        else
          #ng-show 使用了这个值，过早设置不显示，会导致无法生成有高宽的canvas。
          setTimeout(()=>
            scope.scene = ""
          ,200)

        subscribePueValue()
        SubscribeStationEvent()

      scope.selectStation(scope.station)

      # 实时时间
      scope.day = moment().format('YYYY-MM-DD')
      scope.time = moment().format('h:mm:ss')
      scope.date = moment().format('dddd')
      scope.interval = setInterval(()=>
        scope.day = moment().format('YYYY-MM-DD')
        scope.time = moment().format('h:mm:ss')
        scope.date = moment().format('dddd')
        scope.$applyAsync()
      ,1000)

      scope.showVideo=(flag)=>
        if flag
          scope.videos=[scope.equipment]
        else
          scope.videos=[]

      scope.subscribeRoom3dSelectedEquipment?.dispose()
      scope.subscribeRoom3dSelectedEquipment=@commonService.subscribeEventBus("room-3d-select-equipment",(m)=>
        # console.log("subscribeRoom3dSelectedEquipment",m)
        if(m?.message?.equipment?.model.type is "video")
          equip = m?.message?.equipment
          scope.equipment = equip;
          scope.showVideo(true);
      )

    resize: (scope)->

    dispose: (scope)->
      clearInterval(scope.interval)
      scope.efficientStatusSubscription?.dispose()
      scope.disposeSubscribe()
      scope.subscribeRoom3dSelectedEquipment?.dispose()


  exports =
    MicromoduleDashboardDirective: MicromoduleDashboardDirective