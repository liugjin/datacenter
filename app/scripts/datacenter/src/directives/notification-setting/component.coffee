###
* File: notification-setting-directive
* User: David
* Date: 2020/05/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class NotificationSettingDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "notification-setting"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.categories = [
        {
          name: '邮件'
          type: 'email'
          checked: false
          imgUrl: "#{@getComponentPath('images/yonghu.svg')}"
        }
        {
          name: '内置短信'
          type: 'command'
          checked: false
          imgUrl: "#{@getComponentPath('images/duanxin.svg')}"
        }
        {
          name: '短信猫'
          type: 'sms'
          checked: false
          imgUrl: "#{@getComponentPath('images/duanxin-duanxinmao.svg')}"
        }
      ]
      scope.formats = [
        {name: "设备名称", id: "equipment", checked: true,disabled: true}
        {name: "告警描述", id: "event", checked: true,disabled: true}
        {name: "告警状态", id: "phase", checked: true,disabled: true}
        {name: "告警时间", id: "startTime", checked: true,disabled: false}
        {name: "告警级别", id: "severity", checked: true,disabled: false}
        {name: "机房名称", id: "station", checked: true,disabled: false}
      ]
      scope.innerSms = false

      scope.cate = scope.categories[0].type
      @subscribeNotificationSetting scope
      @getUsers scope
      @loadRules scope
      
      scope.equips = []
      scope.stations = _.map scope.project.stations.nitems, (item) =>
        item.loadEquipments null, null, (err, equips) =>
          scope.equips = scope.equips.concat equips
          scope.smsDevice = _.find scope.equips, (item)->item.model.type is "_SMS"
          console.log("scope.smsDevice",scope.smsDevice)
        return {id: item.model.station, name: item.model.name, checked: false}

      scope.types = _.map scope.project.dictionary.equipmenttypes.items,(item) =>
        return {id: item.model.type, name:item.model.name, checked: false}
          
      scope.severities = _.map scope.project.dictionary.eventseverities.items,(item) =>
        return {id: item.model.severity, name:item.model.name, checked: false}

      scope.phases = _.map scope.project.dictionary.eventphases.items, (item) =>
        return {id: item.model.phase, name: item.model.name, checked: false}

      scope.selectAll = (type, flag) =>
        @setItemChecked scope[type], null, scope[flag]

      scope.checkAll = (item, type, flag)=>
        if item.checked is false
          scope[flag] = false
        else if not (_.find scope[type], (it)->it.checked is false)
          scope[flag] = true

      #改变发件方式
      scope.cates_chan = (type) =>
        scope.cate = type
        @getUsers scope
        @loadRules scope


      # 保存并设置规则
      scope.save = =>
        rule = {allStations:true,allEquipments: true,allEventTypes: true}
#        if scope.allStations
#          rule.allStations = true
#        else
#          rule.stations = _.pluck _.filter(scope.stations, (item)->item.checked), "id"
        if scope.allTypes
          rule.allEquipmentTypes = true
        else
          rule.equipmentTypes = _.pluck _.filter(scope.types, (item)->item.checked), "id"
          rule.equipmentTypes.push("Facility","_SMS","_station_management")
#        if scope.allEquipments
#          rule.allEquipments = true
#        else
#          rule.equipments = _.pluck _.filter(scope.equipments, (item)->item.checked), "id"

        if scope.allSeverities
          rule.allEventSeverities = true
        else
          rule.eventSeverities = _.pluck _.filter(scope.severities, (item)->item.checked), "id"

        if scope.allPhases
          rule.allEventPhases = true
        else
          rule.eventPhases = _.pluck _.filter(scope.phases, (item)->item.checked), "id"

        if scope.allUsers
          users = ["_all"]
        else
          users = _.pluck _.filter(scope.users, (item)->item.checked), "id"
        
        @removeRules scope, =>
          @createRule scope,rule, users, =>
            @display "保存成功"

      #保存邮件服务器配置
      scope.saveMail = =>
        scope.mail.enable = true
        scope.mail.options.port = parseInt scope.mail.options.port
        return @display "后台配置服务未启动" if not scope.config
        scope.config.version = @increaseVersion scope.config.version
        @publishNotificationSetting scope, scope.config
        @display "保存成功"

      #保存短信配置
      scope.saveSMS = =>
        scope.sms.enable = true
        scope.sms.options.baudRate = parseInt scope.sms.options.baudRate
        return @display "后台配置服务未启动" if not scope.config
        @publishNotificationSetting scope, scope.config
        @display "保存成功"

      #保存测试
      scope.test = (address, type) =>
        return @display "请输入收件邮箱地址" if type is "email"  and not address
        return @display "请输入手机号码" if type in ["sms", "phone"]  and not address
        type = "command" if type is "sms" and scope.innerSms
        data =
          notification:
            user: scope.project.model.user
            project: scope.project.model.project
            type: type
            trigger: "user"
            receivers: address
            timeout: 2000
            notification: "test-notification"
            title: if scope.innerSms then scope.smsDevice?.model.station+"/"+scope.smsDevice?.model.equipment+"/SMS-comand" else "信息发送测试"
            content: if scope.innerSms then {phone: address, msg:"这是一条测试消息"} else "这是一条测试消息"
            phase: "start"
            priority: 0
        service = @commonService.modelEngine.modelManager.getService "notifications"
        url = service.url.substr(0, service.url.indexOf("/:user"))
        service.postData url, data, (err, data) =>
          @display "发送失败" if err or data?.phase is "error"
          @display "发送超时" if data?.phase is "timeout"
          @display "发送成功" if data?.phase is "completed"

    increaseVersion: (version) ->
      nums = version.split(".")
      nums[nums.length-1] = parseInt(nums[nums.length-1]) + 1
      nums.join(".")

    # 获取用户
    getUsers: (scope) ->
      users = @commonService.modelEngine.modelManager.getService "users"
      users.get null, (err, users) =>
        scope.users = _.map users, (item) ->
          return {id: item.user, name: item.name, checked: false, phone: item.phone}

    # 设置复选框是否选中
    setItemChecked: (items ,value, flag) ->
      for item in items
        item.checked = if flag then true else false
        item.checked = true if flag or _.find value, (it)->it is item.id

    # 获取规则
    loadRules: (scope) =>
      scope.service = @commonService.modelEngine.modelManager.getService "notificationrules"
      scope.service.query {user: scope.project.model.user, project: scope.project.model.project,type:scope.cate},null, (err, rules) =>
        scope.rules = rules
        if (rules and rules.length > 0)
          rule = rules[0].rule
          scope.allStations = if rule.allStation then true else false
          @setItemChecked(scope.stations, rule.stations, rule.allStations)

          scope.allTypes = if rule.allEquipmentTypes then true else false
          @setItemChecked(scope.types, rule.equipmentTypes, rule.allEquipmentTypes)

#          scope.allEquipments = if rule.allEquipments then true else false
#          @setItemChecked scope.equipments, rule.equipments, rule.allEquipments

          scope.allSeverities = if rule.allEventSeverities then true else false
          @setItemChecked(scope.severities, rule.eventSeverities, rule.allEventSeverities)

          scope.allPhases = if rule.allEventPhases then true else false
          @setItemChecked(scope.phases, rule.eventPhases, rule.allEventPhases)

          scope.allUsers = if rules[0].users[0] is "_all" then true else false
          @setItemChecked(scope.users, rules[0].users, scope.allUsers)

          @setItemChecked(scope.formats, JSON.parse(rules[0].desc) if rules[0].desc)
        else
          scope.allStations = false
          @setItemChecked scope.stations, null, null
          scope.allTypes = false
          @setItemChecked(scope.types, null, null)
          scope.allSeverities = false
          @setItemChecked(scope.severities, null,null)
          scope.allPhases = false
          @setItemChecked(scope.phases, null, null)
          scope.allUsers = false
          @setItemChecked(scope.users, null, null)
          if(scope.cate =="email")
            formats = ["equipment","event","startTime","severity","station","phase"]
          if(scope.cate =="command" or scope.cate =="sms")
            formats = ["equipment","event","phase"]
          @setItemChecked(scope.formats, formats)
      ,true


    # 去除规则
    removeRules: (scope, callback) ->
      length = scope.rules.length
      return callback?() if length is 0
      i = 0
      for item in scope.rules
        scope.service.remove item, (err, rules) =>
          i++
          callback?() if i is length

    # 创建规则
    createRule: (scope, ru, users, callback) ->
      content = @getContent(scope, scope.cate)
      rule =
        user:scope.project.model.user
        project:scope.project.model.project
        notification:"notification-#{scope.cate}"
        content: content.content
        contentType: content.contentType
        delay: 0
        enable: true
        events: []
        index: 0
        name: scope.cate
        phase: "start"
        priority: 0
        repeatPeriod: 0
        repeatTimes: 0
        rule: ru
        ruleType: "complex"
        timeout: 60
        title:content.title
        type: scope.cate
        users: users
        visible: true
        desc: JSON.stringify(_.pluck _.filter(scope.formats, (item)->item.checked), "id")
      scope.service.save rule, (err, data) =>
        callback? err

    # 获取内容
    getContent: (scope, type) ->
      result = {}
      switch type 
        when "email"
          result.title = "{{equipmentName}}-{{title}}-{{severityName}}-{{phaseName}}"
          result.content = @getEmailContent scope
          result.contentType = "template"
        when "sms", "phone"
          result.title = ""
          result.content = @getSMSContent scope
          result.contentType = "script"
        when "command"
          result.title = scope.smsDevice?.model.station+"/"+scope.smsDevice?.model.equipment+"/SMS-comand"
          result.content = @getCommandContent scope
          result.contentType = "script"
      return result


    #获取电子邮件的内容
    getEmailContent: (scope) ->
      str =  '<!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>告警通知</title>
            <meta name="viewport" content="width=device-width, initial-scale=1">
        </head>
        <body style="background-color: #e9ecef;">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td align="center" bgcolor="#e9ecef">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">
                        <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 36px 24px 0; font-family: \'Microsoft Yahei\', Arial; border-top: 3px solid #d4dadf;">
                                <h1 style="margin: 0; font-size: 32px; font-weight: 700; letter-spacing: -1px; line-height: 48px;">{{title}}</h1>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td align="center" bgcolor="#e9ecef">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">'
      if scope.formats[2].checked
        str = str + '  <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                                <label style="margin: 0;">告警状态</label>
                            </td>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                                <span style="margin: 0;">{{phaseName}}</span>
                            </td>
                        </tr>'
      if scope.formats[4].checked  
        str = str + '   <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                                <label style="margin: 0;">告警等级</label>
                            </td>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                                <span style="margin: 0;">{{severityName}}</span>
                            </td>
                        </tr>'
      if scope.formats[5].checked
        str = str + '   <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                                <label style="margin: 0;">机房名称</label>
                            </td>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                                <span style="margin: 0;">{{stationName}}</span>
                            </td>
                        </tr>'
      if scope.formats[0].checked
        str = str + '   <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                                <label style="margin: 0;">设备名称</label>
                            </td>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                                <span style="margin: 0;">{{equipmentName}}</span>
                            </td>
                        </tr>'
      if scope.formats[1].checked
        str = str + '   <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                                <label style="margin: 0;">事件名称</label>
                            </td>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                                <span style="margin: 0;">{{eventName}}</span>
                            </td>
                        </tr>'
      if scope.formats[3].checked
        str = str + '   <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                                <label style="margin: 0;">开始时间</label>
                            </td>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                                <span style="margin: 0;">{{startTimeDisplay}}</span>
                            </td>
                        </tr>
                        <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                                <label style="margin: 0;">结束时间</label>
                            </td>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                                <span style="margin: 0;">{{endTimeDisplay}}</span>
                            </td>
                        </tr>
                        <tr>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                                <label style="margin: 0;">确认时间</label>
                            </td>
                            <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                                <span style="margin: 0;">{{confirmTimeDisplay}}</span>
                            </td>
                        </tr>'
      str = str + ' </table>
                </td>
            </tr>
            <tr>
                <td align="center" bgcolor="#e9ecef" style="padding: 24px;">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">
                        <tr>
                            <td align="center" bgcolor="#e9ecef" style="padding: 12px 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 14px; line-height: 20px; color: #666;">
                                <p style="margin: 0;">海鸥工业物联网云平台-2019</p>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        </body>
        </html>'
      return str

    getSMSContent: (scope) ->
      content = '//js \n var str='
      # if scope.formats[5].checked
      #   content += '$event.stationName+"--"+'
      if scope.formats[0].checked
        content += '$event.equipmentName'
      if scope.formats[1].checked
        content += '+"--"+$event.title'
      if scope.formats[4].checked
        content += '+"--"+$event.severityName'
      if scope.formats[2].checked
        content += '+"--"+($event.phase=="start"?"告警开始":($event.phase=="confirm"?"告警确认":"告警结束"))'
      content +='; return str'
      

    getCommandContent: (scope) ->
      phones = ""
      _.each scope.users, (item) ->
        phones += "," + item.phone if item.checked
      content = '//js \n var str='
      # if scope.formats[5].checked
      #   content += '$event.stationName+"|"+'
      if scope.formats[0].checked
        content += '$event.equipmentName'
      if scope.formats[1].checked
        content += '+"|"+$event.title'
      if scope.formats[4].checked
        content += '+"|"+$event.severityName'
      if scope.formats[2].checked
        content += '+"|"+($event.phase=="start"?"告警开始":($event.phase=="confirm"?"告警确认":"告警结束"))'
      content +="; return {phone:\'\""+ phones.substr(1) + "\"\', msg: str}"


  
    # 订阅通知设置
    subscribeNotificationSetting: (scope)->
      # topic = "settings/notification-clients/+"
      topic = "settings/notification-clients/notification-client"
      @commonService.subscribe topic, (err, data) ->
        return if err or not data?.message
        scope.config = data.message
        scope.mail = _.find scope.config.services["notification-client"].processors, (item)-> item.type is "email"
        scope.sms = _.find scope.config.services["notification-client"].processors, (item)-> item.type is "sms"
    #发布设置
    publishNotificationSetting: (scope, config) ->
      a = Number(config.version.split(".")[0])
      b = Number(config.version.split(".")[1])
      c = Number(config.version.split(".")[2])
      c++
      config.version = "#{a}.#{b}.#{c}"
      # topic = "settings/notification-clients/#{config.id}"
      topic = "settings/notification-clients/notification-client"
      @commonService.liveService.publish topic, config

    resize: (scope)->

    dispose: (scope)->


  exports =
    NotificationSettingDirective: NotificationSettingDirective