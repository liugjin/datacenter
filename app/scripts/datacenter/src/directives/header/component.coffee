###
* File: header-directive
* User: David
* Date: 2019/03/08
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", 'pushjs'], (base, css, view, _, moment, Push) ->
  class HeaderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "header"
      super $timeout, $window, $compile, $routeParams, commonService
      @$routeParams = $routeParams

      @projectService = commonService.modelEngine.modelManager.getService("project")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    link: (scope, element, attrs) =>
      scope.closealarmtime=""
      scope.ismute=true
      scope.voiceimg = @getComponentPath('image/voice.svg')
      scope.muteimg = @getComponentPath('image/mute.svg')

      scope.setting = setting
      scope.params = @$routeParams
      scope.$watch '$root.user', (root) =>
        try
          scope.rootUser = root.user
        catch err

        scope.switchLanguage = (s) =>
          scope.$parent.mvm.switchLanguage s

        scope.logout = =>
          scope.$parent.mvm.logout()
          
      scope.getEventColor = (severity) =>
        color = scope.$root.project?.dictionary?.eventseverities?.getItem(severity)?.model.color

      scope.eventShowObj = {}

      calTimes = (refTime) ->
        return "实时告警" if refTime == 0
        sTime = ""
        days = Math.floor(refTime / 86400)
        daysY = refTime % 86400
        hours = Math.floor(daysY / 3600)
        hoursY = daysY % 3600
        mins = Math.floor(hoursY / 60)
        minY = hoursY % 60
        if days > 0
          sTime = sTime + days + "天 "
        else
          sTime = "0天 "

        if hours > 0
          sTime = sTime + hours + "时 "
        else
          sTime = sTime + "0时 "

        if mins > 0
          sTime = sTime + mins + "分 "
        else
          sTime = sTime + "0分 "

        if minY > 0
          sTime = sTime + minY + "秒"
        else
          sTime = sTime + "0秒"
        return sTime

      scope.message = []
      notifyElement = $(element).find(".notify")[0]
      $($(element[0].parentNode)[0]).bind 'click', ()=>
        if scope.ismute
          scope.ismute=false
        return true
      showNotcify = (event, key) =>
        return if !((scope.closealarmtime=="") or(moment(event.startTime)>scope.closealarmtime))
        if scope.message.length == 0
          scope.eventShowObj[key] = event
          start = if event.startValue then (event.startValue +  ' ~ ') else "-- ~ " 
          end = if (event.endValue and typeof(event.endValue) != "undefined") then event.endValue else "--"
          endTime = if (event.endTime and typeof(event.endTime) != "undefined") then moment(event.endTime).format('YYYY-MM-DD HH:MM:SS') else "--"
          message = [ 
            null,
            "[ " + event.stationName + "/" + event.equipmentName + "/" + event.title + " ]",
            "开始时间：  " + moment(event.startTime).format('YYYY-MM-DD HH:MM:SS'),
            "结束时间：  " + endTime,
            "持续时长：  " + calTimes(moment().unix() - moment(event.startTime).unix())
            "告警值域：  " + start +  end
          ]
          try
            scope.speechstr=event.stationName + "/" + event.equipmentName + "/" + event.title
            to_speak = new SpeechSynthesisUtterance()
            to_speak.text=scope.speechstr
            to_speak.lang="zh"
            to_speak.rate=0.8
            window.speechSynthesis.speak(to_speak)
          catch
            console.log "errot:window.speechSynthesis.speak"

          $(notifyElement).show()

          fun = setTimeout(() =>
            $(notifyElement).hide()
            scope.message = []
          , 5000)
          message[0] = fun
          scope.message = message
        else
          setTimeout(() =>
            showNotcify(event, key)
          , 1000);

      scope.setvoice=()=>
        if scope.ismute
          scope.ismute=false
        return true

      scope.close = () =>
        window.speechSynthesis.cancel()
        scope.message = []
        $(notifyElement).hide()
        scope.closealarmtime=moment()


      notifyEvent = (event) ->
        # 增加事件类型判断
        if event.phase isnt 'completed' and !event.endTime
          key = "#{event.station}:#{event.equipment}:#{event.event}"
          # 增加时间先后判断
          if (_.has(scope.eventShowObj, key) and (moment(scope.eventShowObj[key].startTime).unix() - moment(event.startTime).unix() < 0)) or !_.has(scope.eventShowObj, key)
            showNotcify(event, key);

      eventStatisticFun = (event) =>
        key = "#{event.user}.#{event.project}.#{event.station}.#{event.equipment}.#{event.event}.#{event.severity}.#{event.startTime}"
        if scope.statisticsEvents.hasOwnProperty key
          if event.endTime and not scope.statisticsEvents[key].endTime
            scope.eventStatistic.activeEvents--
            scope.eventStatistic.eventSeverity.splice scope.eventStatistic.eventSeverity.indexOf(event.severity), 1
            scope.statisticsEvents[key] = event
          if event.phase is 'completed' and not (scope.statisticsEvents[key].phase is 'completed')
            scope.eventStatistic.totalEvents--
            delete scope.statisticsEvents[key]
        else if not (event.phase is 'completed')
          scope.statisticsEvents[key] = event
          if not event.endTime
            scope.eventStatistic.activeEvents++
            scope.eventStatistic.eventSeverity.push event.severity
          scope.eventStatistic.totalEvents++
        scope.eventStatistic.severity = _.max scope.eventStatistic.eventSeverity

      project = null
      scope.$watch 'params', (params) =>
        if scope.project
          scope.logo = scope.project.model.setting?.logo
        if params.project
          return if project is params.project
          @getProject scope, =>
            scope.logo = scope.project.model.setting?.logo
          project = params.project
        
        scope.statisticsEvents = {}
        scope.eventStatistic = {activeEvents:0,totalEvents:0,severity:0,eventSeverity:[]}

        projectIds =
          user: params.user
          project: params.project
        if projectIds.user
          @statisticSubscription?.dispose()
          @statisticSubscription = @commonService.eventLiveSession.subscribeValues projectIds, (err,d) =>
            if d.message
              eventStatisticFun d.message
              notifyEvent d.message

      ,true

    resize: (scope)->

    dispose: (scope)->
      @statisticSubscription?.dispose()

  exports =
    HeaderDirective: HeaderDirective