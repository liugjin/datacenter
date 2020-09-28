# sheen 2017-10-10
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.web', 'clc.foundation',
  'clc.foundation.data/app/models/configuration/equipments-model',
  'clc.foundation.data/app/models/monitoring/signal-values-model',
  'clc.foundation.data/app/models/monitoring/command-values-model',
  'clc.foundation.data/app/models/system/configurations-model',
#  'clc.foundataion.web/app/src/role-model-service'
  '../../services/datacenter/service-manager',
  '../../../index-setting.json',
  'moment/moment','underscore'], (web, service, equipment, signal, command,configurations, sm, setting, moment, _) ->
  class BusinessController extends web.AuthController
    constructor: ->
      super
      @equip = new equipment.EquipmentsModel
      @signal = new signal.SignalValuesModel
      @command = new command.CommandValuesModel
      @configurations = new configurations.ConfigurationsModel
#      @roleService = sm.getService 'role'
      options = {}
      options.setting = sm.getService("register").getSetting()
      options.configurationService = sm.getService "configuration"
      options.mqtt = setting.mqtt
#      @roleService = new web.RoleModelService options
#      @roleService.start()
      @mqttService = new service.MqttService setting
      @mqttService.start()
      @doorstatusflag = {}
      @doorstatussubscription = {}
      @dooropencommandvaluesphase = {}
      @dooropencommandvaluesscription = {}
      @doorStatus = {}
#      @plog = service.utility
#      @plog.setLogger("/log/interface.log")

    tokenCheck:(token, callback)->
      console.log token
      @roleService.getTokenRole token,{user:setting.myproject.user,project:setting.myproject.project},(err,data)=>
#        console.log data
        return @renderData err,{result:0} if err
        callback?()

    renderData: (err, data) ->
      data ?= {}
      data._err = err if err
      @res.json data

    getConfigurationInfo: ->
      params = @req.query
      console.log params
#      @plog.log "调获取configurations数据库表接口"
#      @tokenCheck params.token, =>
#        @equip.query {user:setting.myproject.user,project:setting.myproject.project,type:'cabinet',equipment:params.cabinet},null,(err,cabinets)=>
      @configurations.query {type:params.type,action:params.action},null,(err,equipments)=>
        console.log err if err
        if equipments.length
          return @renderData null,{result:1,data:equipments}
        else @renderData '无数据',{result:0}

  exports =
    BusinessController: BusinessController
