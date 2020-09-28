###
* File: datacenter-service
* User: Pu
* Date: 2018/9/1
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.web',
  'clc.foundation.data/app/models/system/configurations-model',
  'iced-coffee-script',
  'adm-zip',
  '../../../index-setting',
  'path',
  'fs',
  'urllib',
  'underscore',
  'child_process',
  "moment"], (base,configurations, iced, zip, setting, path, fs,urllib, _, process,moment) ->
  iced = iced.iced if iced.iced

  class DatacenterService extends base.RpcService
    constructor: (options) ->
      super options
      sm = require("./service-manager")
      @systemInfoService = sm.getService("SystemInfoService")
      @configurationSetuoService = sm.getService("ConfigurationSetuoService")
      @TimeManageService = sm.getService "TimeManageService"
      @BackupInfoService = sm.getService "BackupInfo"
      @GetVersionService = sm.getService "GetVersionService"

      @configurations = new configurations.ConfigurationsModel

    initializeProcedures: ->
      @registerProcedure [
        'echo',
        'upload',
        "uploadElement",
        "configurationRecovery",
        "ipSetting",
        "muSetting",
        "getSystemInfo",
        "upgrade",
        "changeStoreMode",
        "getStoreMode",
        "changeStoreInfo",
        "getVersionInfo",
        "getServiceTime",
        "changeServiceTime",
        "getNTPIP",
        "saveNTPIP",
        "getConfigurationInfo"
      ]

    # you can define any methods for rpc
    echo: (options,callback) ->
      time = options.parameters.time + " -- server: #{new Date().toISOString()}"
      result =
        time: time

      callback? null, result

    upload: (file, callback) ->
#      file = Buffer.from options.parameters.file, "base64"
      zp = new zip file.path
#      entries = zp.getEntries()
      text = zp.readAsText("component.json")
      js = zp.readAsText("component.js")
      result = "error"
      if text and js
        component = JSON.parse text
        if component.id and component.version and js.indexOf("BaseDirective")>0
          result = "ok"
          src = path.join __dirname, "../../scripts/", setting.id, "/src/"
          main = fs.readFileSync src+"main.js"
          plugins = JSON.parse fs.readFileSync src+"directives/plugins.json"
          if main.indexOf("directives/"+component.id+"/component") < 0
            plugin = _.find plugins, (item)->item.id is component.id
            if not plugin
              plugins.push {id: component.id}
              fs.writeFileSync src+"directives/plugins.json", JSON.stringify plugins
          zp.extractAllTo src+"directives/"+component.id, true
      callback null, result
    
    # 升级
    upgrade:(file,callback)->
      console.log("file",file)
      if(file.originalFilename)
        fileName = file.originalFilename.split(".zip")[0]
      else if(file.originalname)
        fileName = file.originalname.split(".zip")[0]
      else
        fileName = "clc.datacenter"
      console.log("fileName",fileName)
      zp = new zip file.path
      src = path.join __dirname, "../../../../"
      zp.extractAllTo src, true
      pageFilePackage = JSON.parse(fs.readFileSync("#{src}/#{fileName}/package.json"))
      if(!fs.existsSync("#{src}/version-info-log.json"))
        fs.writeFileSync("#{src}/version-info-log.json",JSON.stringify([]))
      pageFilelog = JSON.parse(fs.readFileSync("#{src}/version-info-log.json"))
      data = {"version":pageFilePackage.version,"updateTime": moment(new Date(new Date().getTime() + 28800000)).format("YYYY-MM-DD HH:mm")}
      pageFilelog.push(data)
      infos = JSON.stringify pageFilelog, null, 2
      fs.writeFileSync("#{src}/version-info-log.json", infos)
      console.log("脚本指令","sh /root/huayuan/#{fileName}.sh")
      process.spawn "sh", ["/root/huayuan/#{fileName}.sh"]
      callback? null, "ok"
    
    # 安装设备库
    uploadElement:(file,callback)->
      @configurationSetuoService.uploadElement(file,callback)
    # 数据恢复
    configurationRecovery:(file,callback)->
      @configurationSetuoService.configurationRecovery(file,callback)

    ipSetting: (options, callback) ->
      if options.action is "get"
        defaultData =
          type: 'static'
          ip: '127.0.0.1'
          mask: '255.255.255.0'
          gateway: '192.168.0.1'
          dns: ''
          hostName: ''
        @networkPath = "/etc/network/interfaces"
        #@networkPath = "E:/root/network/interfaces"
        @netHostNamePath = "/etc/hostname"
        #@netHostNamePath = "E:/root/hostname"
        if fs.existsSync @netHostNamePath
          @hostName = (fs.readFileSync @netHostNamePath).toString()
        if fs.existsSync @networkPath
          @file = (fs.readFileSync @networkPath).toString()
          @network = @file.split(/[\n\r]/)
          @data =
            type: @operateText @network, "iface eth0 inet"
            ip: @operateText @network, "address"
            mask: @operateText @network, "netmask"
            gateway: @operateText @network, "gateway"
            dns: @operateText @network, "dns-nameserver"
            hostName: @hostName
        callback? null, @data ? defaultData


      else if options.action is "post"
        setting = options.parameters
        @operateText @network, "iface eth0 inet", setting.type if setting.type
        @operateText @network, "address", setting.ip if setting.ip
        @operateText @network, "netmask", setting.mask if setting.mask
        @operateText @network, "gateway", setting.gateway if setting.gateway
        @operateText @network, "dns-nameserver", setting.dns if setting.dns
        # @operateText @hostName, "hostName", setting.hostName if setting.hostName
        fs.writeFileSync @networkPath, @file if fs.existsSync @networkPath
        fs.writeFileSync @netHostNamePath, setting.hostName if fs.existsSync @netHostNamePath
        if setting.type is "static"
          process.exec "ifconfig eth0 "+setting.ip+" netmask "+setting.mask if setting.ip isnt @data.ip or setting.mask isnt @data.mask
          process.exec "route add default gw "+setting.gateway if setting.gateway and setting.gateway isnt @data.gateway
          process.exec "hostnamectl set-hostname "+setting.hostName if setting.hostName and setting.hostName isnt @data.hostName
        callback null, "ok"

    operateText: (arr, key, value) ->
      item = _.find arr, (it)->it.indexOf(key)>=0
      return null if not item
      keys = item.trim().split " "
      if not value?
        return keys[keys.length-1]
      else
        keys[keys.length-1] = value
        news = keys.join " "
        @file = @file.replace item, news

    muSetting: (options, callback) ->
      if options.action is "get"
        @muPath = "/root/apps/app/aggregation/monitoring-units.json"
        #@muPath = "E:/platform/node_modules/clc.mu.web/node_modules/clc.mu/monitoring-units.json"
        @elementPath = "/root/apps/app/aggregation/element-lib/"
        #@elementPath = "E:/platform/node_modules/clc.mu.web/node_modules/clc.mu/cfg/custom-elements/"
        if fs.existsSync @muPath
          @muInfo = JSON.parse (fs.readFileSync @muPath).toString()
          console.log("@muInfo",@muInfo)
          @elements = {}
          for element in fs.readdirSync @elementPath
            @elements[element.split(".")[0]] = JSON.parse (fs.readFileSync @elementPath+element).toString()
          callback? null, {mu: @muInfo, elements: @elements}
      else if options.action is "post"
        mu = options.parameters
        fs.writeFileSync @muPath, JSON.stringify mu if fs.existsSync @muPath
        process.exec "pm2 restart start_aggregation"
        callback? null, "ok"

    getSystemInfo: (options, callback) => (
      @systemInfoService.run(callback)
    )
    # 修改储存策略
    changeStoreMode: (options, callback) => (
      @BackupInfoService.changeStoreMode(options, callback)
    )
    # 获取储存策略和数据备份
    getStoreMode: (options, callback) => (
      # @GetStoreModelService.run(callback)
      @BackupInfoService.getStoreMode(callback)
    )
    # 修改储存信息
    changeStoreInfo: (options, callback) => (
      @BackupInfoService.changeStoreInfo(options, callback)
    )
    # 获取版本信息
    getVersionInfo: (options, callback) => (
      @GetVersionService.getVersion(callback)
    )
    # 获取服务器时间
    getServiceTime: (options, callback) => (
      @TimeManageService.getServiceTime(callback)
    )
    # 修改服务器时间
    changeServiceTime: (options, callback) => (
      @TimeManageService.changeServiceTime(options, callback)
    )
    getNTPIP: (options, callback) => (
      @TimeManageService.getNTPIP(callback)
    )
    # 保存saveNTP服务器的IP
    saveNTPIP: (options, callback) => (
      @TimeManageService.saveNTPIP(options, callback)
    )
    
    # 查询数据库configurations表数据
    getConfigurationInfo: (options,callback) ->
      startTime = options.parameters.startTime
      endTime = options.parameters.endTime
      @configurations.find {updatetime:{"$gte":startTime,"$lt":endTime}},null,(err,datas)=>
        console.log err if err
        #        console.log 'datas:', datas
        console.log datas.length
        result = {}
        if datas.length
          result = {result:1,data:datas}
        else result = {result:0}

        callback? null, result
  exports =
    DatacenterService: DatacenterService
