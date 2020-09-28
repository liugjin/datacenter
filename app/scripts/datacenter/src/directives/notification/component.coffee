`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ["jquery",'../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'angularGrid','gl-datepicker'], ($,base, css, view, _, moment,agGrid,gl) ->
  class NotificationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "notification"
      @equipments = {} #按站点取设备
    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      scope.cates = [
        {
          name: '邮件'
          type: 'email'
          img: 'image/youjian.jpg'
        }
        {
          name: '微信'
          type: 'wechat'
          img:'image/weixin.jpg'
        }
        {
          name: '云短信'
          type: 'cloudsms'
          img: 'image/yunduanxin.jpg'
        }
        {
          name: '电话'
          type: 'phone'
          img: 'image/phone.jpg'
        }
        {
          name: '短信'
          type: 'sms'
          img: 'image/duanxin.jpg'
        }
      ]

      scope.cate = scope.cates[0].type
      scope.equipments = []
      rule = {}
      rule.allEventPhases = true
      rule.allEventTypes = true
      #########################--station--#########################
      stations = _.map scope.project.stations.items,(s) =>
        return {name:s.model.name,station:s.model.station,checked:false}
      scope.stations = stations
      scope.station_all_select = false
      scope.station_all_select_chan = () =>
        if scope.station_all_select
          _.each scope.stations,(u) ->
            u.checked = true
        else
          _.each scope.stations,(u) ->
            u.checked = false
        @setEquipments scope
      scope.station_select_chan = () =>
        cs = _.map scope.stations,(u) ->
          return !u.checked
        if _.indexOf(cs,true) < 0
          scope.station_all_select = true
        else
          scope.station_all_select = false
        @setEquipments scope
      #########################--type--#########################
      types = _.map scope.project.dictionary.equipmenttypes.items,(s) =>
        return {name:s.model.name,type:s.model.type,checked:false}
      scope.types = types
      scope.type_all_select = false
      scope.type_all_select_chan = () =>
        if scope.type_all_select
          _.each scope.types,(u) ->
            u.checked = true
        else
          _.each scope.types,(u) ->
            u.checked = false
      scope.type_select_chan = () =>
        cs = _.map scope.types,(u) ->
          return !u.checked
        if _.indexOf(cs,true) < 0
          scope.type_all_select = true
        else
          scope.type_all_select = false
      #########################--equipment--#########################
      index = 0
      _.each scope.project.stations.items,(s) =>
        @getEquipments s,(equips) =>
          @equipments[s.model.station] = equips
          index++
          @loadRules scope if index is scope.project.stations.items.length
      scope.equipment_all_select = false
      scope.equipment_all_select_chan = () =>
        if scope.equipment_all_select
          _.each scope.equipments,(u) ->
            u.checked = true
        else
          _.each scope.equipments,(u) ->
            u.checked = false
      scope.equipment_select_chan = () =>
        cs = _.map scope.equipments,(u) ->
          return !u.checked
        if _.indexOf(cs,true) < 0
          scope.equipment_all_select = true
        else
          scope.equipment_all_select = false
      #########################--eventSeveritie--#########################
      @geteventSeverities scope,(res) =>
        scope.eventSeverities = res
        scope.eventSeveritie_all_select = false
        scope.eventSeveritie_all_select_chan = () =>
          if scope.eventSeveritie_all_select
            _.each scope.eventSeverities,(u) ->
              u.checked = true
          else
            _.each scope.eventSeverities,(u) ->
              u.checked = false
        scope.eventSeveritie_select_chan = () =>
          cs = _.map scope.eventSeverities,(u) ->
            return !u.checked
          if _.indexOf(cs,true) < 0
            scope.eventSeveritie_all_select = true
          else
            scope.eventSeveritie_all_select = false
      #########################--eventphases--#########################
      @geteventPhases scope,(res) =>
        scope.eventphases = res
        scope.eventphases_all_select = false
        scope.eventphases_all_select_chan = () =>
          if scope.eventphases_all_select
            _.each scope.eventphases,(u) ->
              u.checked = true
          else
            _.each scope.eventphases,(u) ->
              u.checked = false
        scope.eventphases_select_chan = () =>
          cs = _.map scope.eventphases,(u) ->
            return !u.checked
          if _.indexOf(cs,true) < 0
            scope.eventphases_all_select = true
          else
            scope.eventphases_all_select = false
      #########################--user--#########################
      @getRoles scope,(roles) =>
        @getUsers scope,roles,(users) =>
          scope.users = users
          @loadRules scope
          scope.user_all_select = false
          scope.user_all_select_chan = () =>
            if scope.user_all_select
              _.each scope.users,(u) ->
                u.checked = true
            else
              _.each scope.users,(u) ->
                u.checked = false
          scope.user_select_chan = () =>
            cs = _.map scope.users,(u) ->
              return !u.checked
            if _.indexOf(cs,true) < 0
              scope.user_all_select = true
            else
              scope.user_all_select = false

      #######################################################################
      scope.save = () =>
        if scope.user_all_select
          users = ["_all"]
        else
          filterUsers = _.filter scope.users, (item) =>
            return item.checked
          users = _.map filterUsers, (item) =>
            return item.user
        if scope.station_all_select
          rule.allStations = true
        else
          delete rule.allStations
          filterStations = _.filter scope.stations, (item) =>
            return item.checked
          rule.stations = _.map filterStations, (item) =>
            return item.station

        if scope.type_all_select
          rule.allEquipmentTypes = true
        else
          delete rule.allEquipmentTypes
          filterTypes = _.filter scope.types, (item) =>
            return item.checked
          rule.equipmentTypes = _.map filterTypes, (item) =>
            return item.type

        if scope.equipment_all_select
          rule.allEquipments = true
        else
          delete rule.allEquipments
          filterEquipments = _.filter scope.equipments, (item) =>
            return item.checked
          rule.equipments = _.map filterEquipments, (item) =>
            return item.station+'/'+item.equipment

        if scope.eventSeveritie_all_select
          rule.allEventSeverities = true
        else
          delete rule.allEventSeverities
          filtereventSeverities = _.filter scope.eventSeverities, (item) =>
            return item.checked
          rule.eventSeverities = _.map filtereventSeverities, (item) =>
            return item.severity

        if scope.eventphases_all_select
          rule.eventphases_all_select = true
        else
          delete rule.allEventPhases
          filtereventPhases = _.filter scope.eventphases, (item) =>
            return item.checked
          rule.eventPhases = _.map filtereventPhases, (item) =>
            return item.phase

        switch scope.cate
          when 'email'
            name="email-1"
            title="{{equipmentName}}--{{title}}--{{severityName}}--{{phaseName}}"
            contentstr='<!DOCTYPE html>
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
            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">
                <tr>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                        <label style="margin: 0;">告警状态</label>
                    </td>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                        <span style="margin: 0;">{{phaseName}}</span>
                    </td>
                </tr>
                <tr>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                        <label style="margin: 0;">告警等级</label>
                    </td>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                        <span style="margin: 0;">{{severityName}}</span>
                    </td>
                </tr>
                <tr>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                        <label style="margin: 0;">站点名称</label>
                    </td>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                        <span style="margin: 0;">{{stationName}}</span>
                    </td>
                </tr>
                <tr>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                        <label style="margin: 0;">设备名称</label>
                    </td>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                        <span style="margin: 0;">{{equipmentName}}</span>
                    </td>
                </tr>
                <tr>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                        <label style="margin: 0;">事件名称</label>
                    </td>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                        <span style="margin: 0;">{{name}}</span>
                    </td>
                </tr>
                <tr>
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
                </tr>
                <tr>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                        <label style="margin: 0;">开始阀值</label>
                    </td>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                        <span style="margin: 0;">{{startValue}}</span>
                    </td>
                </tr>
                <tr>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf">
                        <label style="margin: 0;">结束阀值</label>
                    </td>
                    <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf">
                        <span style="margin: 0;">{{endValue}}</span>
                    </td>
                </tr>
            </table>
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
            contenttypestr="template"
            break
          when 'sms'
            name="sms-1"
            title="短信告警通知"
            contentstr='//js \n
                      if($event.phase == "start"){
                          return $event.stationName + "--" + $event.equipmentName + "--"  + $event.title;
                      }else if($event.phase == "end"){
                          return $event.stationName + "--" + $event.equipmentName + "--"  + $event.title +  "。恢复正常";
                      }
                    '
            contenttypestr="script"
            break
          when 'wechat'
            name="wechat-1"
            title="{{eventName}}"
            contentstr='{{title}};'
            contenttypestr="template"
            break
          when 'phone'
            name="phone-1"
            title="告警通知"
            contentstr='{{equipmentName}}设备,{{title}}告警,告警开始'
            contenttypestr="template"
            break
          else
            name="cloudsms-1"
            title="云短信告警通知"
            contentstr='{{title}};'
            contenttypestr="template"
            break


        save_api =
          id: 'notificationrules'
          item:
            user:scope.project.model.user
            project:scope.project.model.project
            notification:"notification-#{scope.cate}"
            content: contentstr
            contentType: contenttypestr
            delay: 0
            enable: true
            events: []
            index: 0
            name: name
            phase: "start"
            priority: 0
#            processors: []
            repeatPeriod: 0
            repeatTimes: 0
            rule: rule
            ruleType: "complex"
            timeout: 5
            title:title
            type: scope.cate
            users: users
            visible: true
        @commonService.modelEngine.modelManager.getService(save_api.id).save save_api.item,(e,res) =>
          if res && res._id
            @display "保存告警模板成功",10000

      #改变发件方式
      scope.cates_chan = () =>
        @loadRules scope
#######################################################################
    loadRules: (scope) =>
      scope.user_all_select = false
      scope.station_all_select = false
      scope.type_all_select = false
      scope.equipment_all_select = false
      _.each scope.users,(item) =>
        item.checked = false
      _.each scope.stations,(item) =>
        item.checked = false
      _.each scope.types,(item) =>
        item.checked = false
      _.each scope.equipments,(item) =>
        item.checked = false
      _.each scope.eventSeverities,(item) =>
        item.checked = false
      notificationrules_api =
        id: 'notificationrules'
        query:
          user: scope.project.model.user
          project: scope.project.model.project
          type: scope.cate
      @commonService.modelEngine.modelManager.getService(notificationrules_api.id).query notificationrules_api.query,null,(e,res) =>
        if res?.length == 0 ||res== undefined
        else
          if res[0].users && res[0].rule
            @setRule scope,res[0]
      ,true
    setRule: (scope,res) =>
      if res.users[0]
        if res.users[0] == "_all"
          scope.user_all_select = true
          _.each scope.users,(item) =>
            item.checked = true
        else
          scope.user_all_select = false
          _.each scope.users,(item) =>
            _.each res.users,(u) =>
              if item.user == u
                item.checked = true
      else
        scope.user_all_select = false

      if res.rule.allStations
        scope.station_all_select = true
        _.each scope.stations,(item) =>
          item.checked = true
      else if res.rule.stations
        scope.station_all_select = false
        _.each scope.stations,(item) =>
          _.each res.rule.stations,(i) =>
            if item.station == i
              item.checked = true

      if res.rule.allEquipmentTypes
        scope.type_all_select = true
        _.each scope.types,(item) =>
          item.checked = true
      else if res.rule.equipmentTypes
        scope.type_all_select = false
        _.each scope.types,(item) =>
          _.each res.rule.equipmentTypes,(i) =>
            if item.type == i
              item.checked = true

      @setEquipments scope,()=>
        if res.rule.allEquipments
          scope.equipment_all_select = false
          _.each scope.equipments,(item) =>
            item.checked = true
        else if res.rule.equipments
          scope.equipment_all_select = false
          _.each scope.equipments,(item) =>
            _.each res.rule.equipments,(i) =>
              if i != undefined  && i?
                iistr=i.split('/')[1]
                if item.equipment == iistr
                  item.checked = true

      if res.rule.allEventSeverities
        scope.eventSeveritie_all_select = true
        _.each scope.eventSeverities,(item) =>
          item.checked = true
      else if res.rule.eventSeverities
        scope.eventSeveritie_all_select = false
        _.each scope.eventSeverities,(item) =>
          _.each res.rule.eventSeverities,(i) =>
            if item.severity == i.toString()
              item.checked = true

      if res.rule.allEventPhases
        scope.eventphases_all_select = true
        _.each scope.eventphases,(item) =>
          item.checked = true
      else if res.rule.eventPhases
        scope.eventphases_all_select = false
        _.each scope.eventphases,(item) =>
          _.each res.rule.eventPhases,(i) =>
            if item.phase == i.toString()
              item.checked = true

    getRoles:(scope,callback) ->
      roles_api =
        id: 'roles'
        query:
          user:scope.project.model.user
          project:scope.project.model.project
        field:null
      @commonService.modelEngine.modelManager.getService(roles_api.id).query roles_api.query,roles_api.field,(e,rs) =>
        res = _.map rs,(r) =>
          return r.users
        union = _.union _.flatten res
        callback?union
      ,true
    getUsers:(scope,roles,callback) ->
      if _.indexOf roles,"_all" >= 0
        @commonService.modelEngine.modelManager.getService("users").query null,null,(e,rs) =>
          res = _.map rs,(r) ->
            return {name:r.name,user:r.user,checked:false}
          callback?res
      else
        callback?roles
    getEquipments: (station,callback) ->
      station.loadEquipments null,null,(err, equipments) =>
        equips = _.map equipments,(e) ->
          return {name:e.model.name,equipment:e.model.equipment,checked:false,station:e.model.station}
        callback?equips
      ,true
    geteventSeverities:(scope,callback) ->
      eventSeverities_api =
        id: 'eventseverities'
        query:
          user:scope.project.model.user
          project:scope.project.model.project
        field:null
      @commonService.modelEngine.modelManager.getService(eventSeverities_api.id).query eventSeverities_api.query,eventSeverities_api.query.field,(e,rs) =>
        res = _.map rs,(r) =>
          return {name:r.name,severity:r.severity.toString(),checked:false}
        callback?res
      ,true
    geteventPhases:(scope,callback) ->
      eventSeverities_api =
        id: 'eventphases'
        query:
          user:scope.project.model.user
          project:scope.project.model.project
        field:null
      @commonService.modelEngine.modelManager.getService(eventSeverities_api.id).query eventSeverities_api.query,eventSeverities_api.query.field,(e,rs) =>
        res = _.map rs,(r) =>
          return {name:r.name,phase:r.phase.toString(),checked:false}
        callback?res
      ,true
    setEquipments:(scope,callback) ->
      filterStations = _.filter scope.stations,(s) =>
        return s.checked
      mapStations = _.map filterStations,(s) =>
        return @equipments[s.station] || []
      scope.equipments = _.union _.flatten mapStations #所有选中的站点设备
      callback? scope.equipments
    resize: (scope)->

    dispose: (scope)->

  exports =
  NotificationDirective: NotificationDirective