###
* File: alarm-link-directive
* User: David
* Date: 2018/11/06
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'lodash', "moment"], (base, css, view, _, moment) ->
  class AlarmLinkDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "alarm-link"

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      element.css("display", "block")
      M.Autocomplete.init(element.find('.autocomplete'),{minLength:0,data:{"等待初始化":null}})
      equipmentsList = {}

      scope.re = {}
      scope.rules = []
      scope.equipments = []
      scope.triggerStates = scope.project.dictionary.eventphases.items

      getEquipments = (callback) ->
        index = 0
        for station in scope.project.stations.items
          station.loadEquipments null, null, (err, equips)->
            scope.equipments = scope.equipments.concat equips
            index++
            callback?() if index is scope.project.stations.items.length

      notification = scope.controller.modelEngine.modelManager.getService "notificationrules"
      queryRules = ->
        scope.rules = []
        notification.query {user: scope.project.model.user, project: scope.project.model.project}, null, (err, rules)->
          _.map rules, (rule)->
            if rule.notification.substr(0,4) is "link"

              triggerDevice = scope.project.model.user+"_"+scope.project.model.project+"_"+rule.events[0].split("/")[0]+"_"+rule.events[0].split("/")[1]
              triggerEquip = scope.project.equipments[triggerDevice]
              if not triggerEquip
                return false
              #BUG:如果没找到设备，为undefined，会在这里异常中止且不报错，原因不明。
              triggerEquip.loadEvents()
              triggerAlarm = rule.events[0].split("/")[2]
              triggerState = if rule.rule.allEventPhases then "all" else rule.rule.eventPhases[0]
              linkDevice = scope.project.model.user+"_"+scope.project.model.project+"_"+rule.title.split("/")[0]+"_"+rule.title.split("/")[1]
              linkEquip = scope.project.equipments[linkDevice]
              linkEquip?.loadCommands()
              linkAction = scope.project.model.user+"."+scope.project.model.project+"."+rule.title.replace(/[/]/g, ".")
#              linkValue = rule.content.split(":")[1]
              scope.rules.push {triggerDevice:triggerDevice, triggerEquip: triggerEquip, triggerAlarm: triggerAlarm, triggerState: triggerState, linkDevice: linkDevice, linkEquip: linkEquip, linkAction: linkAction, content: rule.content, notification: rule.notification}
        , true

      getEquipments =>
        queryRules()

      hideAutocompleteInput=()=>
        element.find('.autocomplete').attr('autocomplete','off')
        setTimeout(()=>
          element.find('.autocomplete').attr('autocomplete','off')
        ,200)


      scope.listSourceEquipments=()->
        scope.re.sourceEquipmentName = ''
        hideAutocompleteInput()
        setTimeout(()=>
            M.Autocomplete.getInstance(element.find('#source-equipment')).open()
          ,100)


      scope.listLinkEquipments=()->
        scope.re.linkEquipmentName = ''
        hideAutocompleteInput()
        setTimeout(()=>
          M.Autocomplete.getInstance(element.find('#link-equipment')).open()
        ,100)

      # 更新数据后需要手动初始化才能正常显示
      initSelect=()=>
        setTimeout(()->
          $('select').formSelect()
          scope.$applyAsync()
        ,100)


      scope.changeSourceEquipments=()->
        scope.re.triggerDevice2 = equipmentsList[scope.re.sourceEquipmentName]?.key

      scope.changeLinkEquipments=()->
        scope.re.linkDevice2 = equipmentsList[scope.re.linkEquipmentName]?.key
        scope.re.linkAction2 = null
        scope.re.cmdModelParameters = []


      scope.$watch "re.triggerDevice2", (eq)->
        scope.triggerAlarms = []
        return if not eq
        equip = _.find scope.equipments, (e)->e.key is eq
        equip?.loadEvents "event name", (err, events)->
          scope.triggerAlarms = events
          initSelect()

      updateLinkActions=(equipKey)->
        equip = _.find scope.equipments, (e)->e.key is equipKey
        equip?.loadCommands null, (err, commands)->
          scope.linkActions = commands

      setCmdModelParameters=()=>
        cmd = _.find scope.linkActions, (e)->e.key is scope.re.linkAction2
        scope.re.cmdModelParameters = _.cloneDeep cmd.model.parameters
        for p in scope.re.cmdModelParameters
          p.value = ''
        arr = scope.re.content?.split(',')
        if arr
          for i in arr
            key = i.split(':')[0]
            value = i.split(':')[1]
            if key and value.length > 0
              for p in scope.re.cmdModelParameters
                if p.key is key
                  switch p.type
                    when 'int'
                      p.value = parseInt(value)

                      break
                    when 'float'
                      p.value = parseFloat(value)
                      break
                    when 'bool'
                      p.value = Boolean(value)
  #                    BUG:转换成数字反而让 ng-selected无法生效
  #                  when 'enum'
  #                    p.value = parseInt(value)
  #                    break
                    else
                      p.value = value
                      break

      scope.$watch "re.linkDevice2", (eq)->
        return if not eq
        updateLinkActions(eq)


      scope.$watch "re.linkAction2", (ac)->
        return if not ac
        setCmdModelParameters()
        initSelect()

#        scope.re.actionType = cmd?.model.parameters[0]?.type
#        scope.re.linkValues = cmd?.model.parameters[0]?.enums
#        scope.re.linkValue = switch scope.re.actionType
#          when "int"
#            parseInt scope.re.linkValue
#          when "float"
#            parseFloat scope.re.linkValue
#          else
#            scope.re.linkValue

#      scope.$watch "re.notification", (notification)->
#        cmd = _.find scope.linkActions, (e)->e.key is scope.re.linkAction
#        scope.re.actionType = cmd?.model.parameters[0]?.type
#        scope.re.linkValues = cmd?.model.parameters[0]?.enums
#        scope.re.linkValue = switch scope.re.actionType
#          when "int"
#            parseInt scope.re.linkValue
#          when "float"
#            parseFloat scope.re.linkValue
#          else
#            scope.re.linkValue

#      scope.displayValue = (rule) ->
#        params = rule.linkEquip.commands.getItem(rule.linkAction)?.model.parameters
#        return if not params
#        ret = ""
#        for param in params
#          ret = ret + "," + if param.enums then (_.find(param.enums, (en)->en.value is parseInt(rule.linkValue))).key else rule.linkValue
#        ret.substr 1

      scope.select = (rule) ->
        scope.re = rule

      updateAutoComplete=()=>
        hideAutocompleteInput()
        equipmentsList2 = {}
        for equip in scope.equipments
          equipmentsList[equip.station.model.name+'-'+equip.model.name] = equip
          equipmentsList2[equip.station.model.name+'-'+equip.model.name] = null

        M.Autocomplete.getInstance(element.find('#source-equipment')).updateData(equipmentsList2)
        M.Autocomplete.getInstance(element.find('#link-equipment')).updateData(equipmentsList2)

      scope.add = ()=>
        scope.re = {}
        scope.linkActions = []
        scope.triggerAlarms = []

        updateAutoComplete()
        initSelect()


      scope.modify=()=>
        updateAutoComplete()

        for equip in scope.equipments
          scope.re.sourceEquipmentName = equip.station.model.name+'-'+equip.model.name if equip.key is scope.re.triggerDevice
          scope.re.linkEquipmentName = equip.station.model.name+'-'+equip.model.name if equip.key is scope.re.linkDevice

        #将rule复制出来，变量全部以2结尾，只有当保存时，才会真正改变
        scope.re.triggerDevice2 = _.cloneDeep scope.re.triggerDevice
        scope.re.linkDevice2 = _.cloneDeep scope.re.linkDevice
        scope.re.triggerAlarm2 = _.cloneDeep scope.re.triggerAlarm
        scope.re.triggerState2 = _.cloneDeep scope.re.triggerState
        scope.re.linkAction2 =  _.cloneDeep scope.re.linkAction
        updateLinkActions(scope.re.linkDevice2)

        setCmdModelParameters()
        initSelect()


      scope.delete = =>
        scope.promptModel=
#          comment:"asdfad"
#          enableComment:true
          title:"请确认删除 告警联动"
          message:"删除告警联动:"+scope.re.linkEquip?.model?.name+' - '+scope.re?.triggerEquip?.model?.name
          confirm:(ok)=>
            if ok
              notification.remove {user:scope.project.model.user, project: scope.project.model.project, notification: scope.re.notification}, (err, n)=>
                @display "删除成功" if not err
                queryRules()
                scope.re = {}

      scope.checkContent=()=>
        if not (scope.re.triggerDevice2 and scope.re.triggerAlarm2 and scope.re.triggerState2 and scope.re.linkDevice2 and scope.re.linkAction2)
          return alert "请输入完整信息"
      scope.save = =>
        if not (scope.re.triggerDevice2 and scope.re.triggerAlarm2 and scope.re.triggerState2 and scope.re.linkDevice2 and scope.re.linkAction2)
          return @display "请输入完整信息555555"
        #将rule复制出来
        scope.re.triggerAlarm = _.cloneDeep scope.re.triggerAlarm2
        scope.re.triggerState = _.cloneDeep scope.re.triggerState2
        scope.re.linkDevice = scope.re.linkDevice2
        scope.re.triggerDevice  = scope.re.triggerDevice2
        scope.re.linkAction =  scope.re.linkAction2

        setParameterContent=()->
          result = ''
          for parameter in scope.re.cmdModelParameters
            result += parameter.key+':'+parameter.value+','
          if result.length > 0
            result = result.substring(0,result.length-1)

          return result

        scope.rule = {
          "enable": true,
          "visible": true,
          "index": 0,
#          "processors": [],
          "users": [ "_all" ],
          "events": [
            scope.re.triggerDevice.split("_")[2]+"/"+scope.re.triggerDevice.split("_")[3]+"/"+scope.re.triggerAlarm
          ],
          "user": scope.project.model.user,
          "project": scope.project.model.project,
          "notification": scope.re.notification ? "link-"+moment().format("YYYYMMDDHHmmss"),
          "name": "告警联动规则-"+moment().format("YYYYMMDDHHmmss"),
          "title": scope.re.linkAction.split(".")[2]+"/"+scope.re.linkAction.split(".")[3]+"/"+scope.re.linkAction.split(".")[4],
          "content": setParameterContent()
          "contentType": "text",
          "priority": 0,
          "type": "command",
          "timeout": 2,
          "phase": "start",
          "delay": 0,
          "repeatPeriod": 0,
          "repeatTimes": 0,
          "rule": {
            "allStations": true,
            "allEquipmentTypes": true,
            "allEquipments": true,
            "allEventTypes": true,
            "allEventSeverities": true,
          },
          "ruleType": "events",
        }
        if scope.re.triggerState is "all"
          scope.rule.rule.allEventPhases = true
        else
          scope.rule.rule.eventPhases = [scope.re.triggerState]
        notification.save scope.rule, (err, model)=>
          @display "保存成功" if not err
          queryRules()
          scope.re = {}


    resize: (scope)->

    dispose: (scope)->


  exports =
    AlarmLinkDirective: AlarmLinkDirective