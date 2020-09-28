###
* File: alarm-setting-directive
* User: David
* Date: 2019/07/04
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "rx"], (base, css, view, _, moment, Rx) ->
  class AlarmSettingDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "alarm-setting"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      #初始化全选按钮  
      scope.user_all_select = false

      subject = new Rx.Subject

      scope.templates = []
      scope.list = []
      scope.events = {}
      scope.foramt = {}
      scope.formatData = {} #通讯状态
      scope.liforamt = []
      scope.sort = {}
      templates = {}
      scope.severities = _.sortBy scope.project.dictionary.eventseverities.items,(item)->item.model.severity
      scope.operatorTypes = [{ operator: null, name: " " }, { operator: "==", name: "==" }, { operator: "!=", name: "!=" }, { operator: ">", name: ">" }, { operator: ">=", name: ">=" }, { operator: "<", name: "<" }, { operator: "<=", name: "<=" }, { operator: "in", name: "in" }, { operator: "out", name: "out" }, { operator: "change", name: "change" }, { operator: "boundary", name: "boundary" }, { operator: "like", name: "like" }]
      scope.checkNews = {severity: 'all',phase: 'all'}
      @getAlarmLevels(scope)
      scope.$watch("checkNews.severity", (data) =>
        num = Number(data)
        if(data == "all")
          num = null
        scope.selectSeverity(num)
      )
      scope.getSeverityName = (severity) ->
        item = _.find scope.severities, (item)->item.model.severity is severity
        item?.model.name

      scope.getCountBySeverity = (severity) ->
        items = _.filter scope.list, (item)->item.severity is severity
        items?.length

      scope.selectSeverity = (severity) ->
        scope.severity = severity

      scope.sortBy = (id) ->
        scope.sort.predicate = id
        scope.sort.reverse = !scope.sort.reverse

      scope.filterEvent = ()=>
        (event) =>
          if scope.severity and event.severity isnt scope.severity
            return false
          text = scope.search?.toLowerCase()
          if not text
            return true
          if event.name.toLowerCase().indexOf(text) >= 0
            return true
          if event.content?.toLowerCase().indexOf(text) >= 0
            return true
          if event.value?.toLowerCase().indexOf(text) >= 0
            return true
          if event.severityName?.toLowerCase().indexOf(text) >= 0
            return true
          return false

      scope.selectTemplateId = (templateId) =>
        scope.selectTemplate(templates[templateId])

      scope.selectTemplate = (template) =>
        return if not template
        scope.user_all_select = false

        scope.severity = null
        scope.list = []
        scope.events = {}
        scope.currentTemplate = template
        if template is "all"
          @loadTemplateIndexEvents scope, 0
        else
          @loadTemplateEvents scope, template

      #点击保存
      scope.saveSetting = () =>
        if scope.list.length < 1
          M.toast({ html: '暂无数据！' })
          return false

        checkedEvtFlag = _.filter( scope.list,(evt)-> evt.checkedFlag )
        if checkedEvtFlag.length < 1
          M.toast({ html: '数据更新成功！' })
          return false
        else
          for saveEvent in checkedEvtFlag
            @saveEvent(scope, saveEvent)



      scope.controller.$rootScope.executing = true
      scope.project.loadEquipmentTemplates null, null, (err, tmps) =>
        tmps = _.filter tmps, (tmp) -> tmp.model.template.substr(0,1) isnt "_"
        n = 0
        _.each tmps, (tmp) =>
          tmp.loadEvents null, (err, evts) =>
            n++
            templates[tmp.model.type+"."+tmp.model.template] = tmp if evts.length > 0
            if n is tmps.length
              stations = @commonService.loadStationChildren scope.station, true
              j = 0
              for station in stations
                station.loadEquipments null, null, (err, equips) =>
                  j++
                  group = _.groupBy equips, (equip)->equip.model.type+"."+equip.model.template
                  keys = _.keys group
                  for key in keys
                    scope.templates.push templates[key] if templates[key] and _.indexOf(scope.templates, templates[key]) is -1
                    scope.selectTemplate templates[key] if @$routeParams.template is key
                  if j is stations.length and not @$routeParams.template
                    setTimeout =>
                      scope.selectTemplate "all"
                    ,10

      #点击告警等级
      scope.editEventSeverity = (event, index) ->
        event.show = true


        setTimeout =>
          $('#event'+index).parent().find("input").click()
        ,20



      #修改单个告警的勾选状态
      scope.user_event_change = (evt)=>
        cs = _.map scope.list,(u)=>
          return !u.checkedFlag

        if _.indexOf(cs, true) < 0
          scope.user_all_select = true
        else
          scope.user_all_select = false

      #勾选全部告警状态
      scope.user_all_change = ()=>
        for evt in scope.list
          evt.checkedFlag = scope.user_all_select

      #监听新告警级别变化
      scope.user_editSer = (evt)=>
        getSeverName = scope.getSeverityName(parseInt(evt.newseverity))

        if evt.severityName != getSeverName 
          evt.checkedFlag = true
        else
          if parseInt(evt.value) != parseInt(evt.newvalue)  or evt.changeAbleFlag != evt.enable 
            evt.checkedFlag = true
          else
            evt.checkedFlag = false

        scope.$applyAsync()

      # 监听告警条件变化
      scope.user_startCond = (evt)=>
        if  evt.startCond != evt.startCondition
          evt.checkedFlag = true
        else
          evt.checkedFlag = false
        scope.$applyAsync()

      #监听新告警阈值变化
      scope.user_newVal = (evt)=>
        subject.onNext(evt)

      subject.debounce(300).subscribe((evt)=>
        getSeverName = scope.getSeverityName(parseInt(evt.newseverity))
        if parseInt(evt.value) != parseInt(evt.newvalue)
          evt.checkedFlag = true
        else
          if evt.changeAbleFlag != evt.enable or evt.severityName != getSeverName
            evt.checkedFlag = true
          else
            evt.checkedFlag = false

        scope.$applyAsync()
      )

      #有效无效切换
      scope.switchEventAble = (evt)->
        getSeverName = scope.getSeverityName(parseInt(evt.newseverity))

        if evt.changeAbleFlag != evt.enable
          evt.checkedFlag = true
        else
          if evt.severityName != getSeverName or parseInt(evt.value) != parseInt(evt.newvalue)
            evt.checkedFlag = true
          else
            evt.checkedFlag = false

        scope.$applyAsync()

    # 获取告警级别
    getAlarmLevels:(scope) =>
      scope.alarmLevels = []
      for alarmLevel in scope.severities
        alarmLevelData = {
          id: alarmLevel.model.severity
          name: alarmLevel.model.name
        }
        scope.alarmLevels.push alarmLevelData

    loadTemplateIndexEvents: (scope, index)->
      return if scope.currentTemplate isnt "all"
      template = scope.templates[index]
      if template
        @loadTemplateEvents scope, template, =>
          setTimeout =>
            @loadTemplateIndexEvents scope, index+1
          ,100

    loadTemplateEvents: (scope, template, callback) ->
      template.loadEvents null, (err, events) =>
        for event in events
          scope.events[event.key] = event
          for rule in event.model.rules
            evt =
              key: event.key
              changeAbleFlag: event.model.enable,
              checkedFlag: false
              enable: event.model.enable
              type: event.model.type
              templateId: event.model.template
              template: template.model.name
              event: event.model.event,
              name: event.model.name,
              rule: rule.name,
              startCond: rule.start.condition.operator,
              startCondition: rule.start.condition.operator,
              content: rule.title,
              value: rule.start.condition.values,
              newvalue: rule.start.condition.values,
              severity: rule.severity,
              severityName: scope.getSeverityName(rule.severity),
              newseverity: rule.severity?.toString()
            scope.list.push evt
        scope.$applyAsync()
        scope.controller.$rootScope.executing = false
        callback?()
            
      template.loadSignals null, (err, signallists) =>
        return if(_.isEmpty(signallists))
        enumerate =[]
        scope.formatData = _.find(signallists, (m) => m.model.dataType == "enum")
        scope.formatData = scope.formatData.model.format
        formatArr = (scope.formatData).split(",") # 解析枚举信号
        _.each(formatArr, (format) =>
          f = format.split(":")
          obj = {
            id: f[0],
            name: f[1]
          }
          enumerate .push(obj)
        )
        for am in signallists
          for li in scope.list
            if am.key == li.key
              li.format = enumerate
              li.dataType = am.model.dataType
                  
    saveEvent: (scope, item) ->
      event = scope.events[item.key]
      event.model.enable = item.enable   #修改event的enable状态
      rule = _.find(event.model.rules, (it)-> it.name is item.rule)   # 修改event的告警规则参数

      rule.severity = parseInt item.newseverity if rule
      rule.start.condition.values = item.newvalue if rule
      rule.start.condition.operator = item.startCondition if rule

      event.save((err, result)->
        if not err
          item.severity = parseInt item.newseverity
          item.value = item.newvalue
          # item.startCond = startCondition
          item.changeAbleFlag = item.enable
          # item.checkedFlag = false #保存成功后 要把所有的checkedFlag 设置为false

          scope.$applyAsync()
      )

    resize: (scope)->

    dispose: (scope)->


  exports =
    AlarmSettingDirective: AlarmSettingDirective