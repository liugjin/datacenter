`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.web', 'iced-coffee-script', 'adm-zip', '../../../index-setting', 'path', 'fs', 'urllib','underscore', 'child_process'], (base, iced, zip, setting, path, fs,urllib, _, process) ->
  iced = iced.iced if iced.iced
  class ConfigurationSetuoService extends base.MqttService
    constructor: (options) ->
      super options

    # 设备库安装
    uploadElement:(file,callback)->
      options = file.options
      zp = new zip file.path
      zipEntries = zp.getEntries()
      _.each zipEntries, (zipEntry) =>
        if(zipEntry.entryName == "project-admin.zip")
          await @handleConfigure zipEntry,options,false,false,true,false,defer()
        else if(zipEntry.entryName == "elements.zip")
          await @handleElements zipEntry,options,defer()
        else if(zipEntry.entryName == "graphic-templates-admin.zip")
          await @handleGraphicsData zipEntry,options,defer()
      callback? null, "ok"


    # 配置恢复
    configurationRecovery:(file,callback)->
      options = file.options
      zp = new zip file.path
      zipEntries = zp.getEntries()
      _.each zipEntries, (zipEntry) =>
        if(zipEntry.entryName=="project-admin.zip")
          await @handleConfigure zipEntry,options,true,true,true,defer()
        else if(zipEntry.entryName=="elements.zip")
          await @handleElements zipEntry,options,defer()
        else if(zipEntry.entryName=="graphic-templates-admin.zip")
          await @handleGraphicsData zipEntry,options,defer()
        else if(zipEntry.entryName == "monitoring-units.zip")
          await @setCollectionConfiguration zipEntry,options,defer()
      callback? null, "ok"
      

    # 处理配置 
      #zipEntry 需要处理的文件
      #options  参数
      #ifProject 是否处理项目 true 处理 false 不处理
      #ifDataDictionary 是否处理数据字典 true 处理 false 不处理
      #ifDeviceTemplate 是否处理设备模板 true 处理 false 不处理
      #ifSiteEquipment  是否处理站点设备 true 处理 false 不处理
    handleConfigure:(zipEntry,options,ifProject,ifDataDictionary,ifDeviceTemplate,ifSiteEquipment,callback)=>
      zp = new zip zipEntry.getData()
      zipEntries = zp.getEntries()
      _.each zipEntries, (zipEntry) =>
        if(zipEntry.name.indexOf(".json") != -1 and zipEntry.name)
          plugins = JSON.parse zipEntry.getData().toString('utf8')
          await @handleConfigureData plugins.data,options,ifProject,ifDataDictionary,ifDeviceTemplate,ifSiteEquipment,defer()
        if(zipEntry.name.indexOf(".json") == -1 and zipEntry.name)
          await @uploadResource options,zipEntry,defer()
      callback?()

    # 处理设备模板
    handleElements:(zipEntry,options,callback)=>
      zp = new zip zipEntry.getData()
      @elementPath = "/root/apps/app/aggregation/element-lib/"
      #@elementPath = "E:/platform/node_modules/clc.mu.web/node_modules/clc.mu/cfg/custom-elements/"
      zp.extractEntryTo("elements/",@elementPath,false,true)
      callback?()

    # 处理组态
    handleGraphicsData:(zipEntry,options,callback)=>
      zp = new zip zipEntry.getData()
      zipEntries = zp.getEntries()
      _.each zipEntries, (zipEntry) =>
        if(zipEntry.name.indexOf(".json") == -1 and zipEntry.name)
          await @uploadResource options,zipEntry,defer()
        if(zipEntry.name.indexOf(".json") != -1 and zipEntry.name)
          await @uploadGraphicConfigure options,zipEntry,defer()
      callback?()

    # 处理采集配置文件
    setCollectionConfiguration:(zipEntry,options,callback)=>
      zp = new zip zipEntry.getData()
      @muPath = "/root/apps/app/aggregation/"
      #@muPath = "E:/platform/node_modules/clc.mu.web/node_modules/clc.mu/"
      zp.extractEntryTo("monitoring-units/",@muPath,false,true)
      callback?()
    # 处理配置数据
    handleConfigureData:(datas,options,ifProject,ifDataDictionary,ifDeviceTemplate,ifSiteEquipment,callback)=>
      dataDictionary = ["datatypes","signaltypes","eventtypes","porttypes","stationtypes","connectiontypes","units","eventseverities","eventphases","vendors","roles","capacities"]
      deviceTemplate = ["equipmenttypes","equipmenttemplates","equipmentproperties","equipmentevents","equipmentcommands","equipmentports","equipmentsignals"]
      siteEquipment = ["stations","equipments"]
      for typeKey of datas
        await @backupsProject options,datas,typeKey, defer(callbackData) if typeKey is "project" and ifProject
        await @backupsDataDictionary options,datas,typeKey, defer() if typeKey in dataDictionary and ifDataDictionary
        await @backupsDeviceTemplate options,datas,typeKey, defer() if typeKey in deviceTemplate and ifDeviceTemplate
        await @backupsSiteEquipment options,datas,typeKey, defer() if typeKey in siteEquipment and ifSiteEquipment
      callback?()

    # 配置数据备份项目配置
    backupsProject:(options,datas,typeKey,callback)=>
      if(typeKey == "project")
        url = options.ip+"/model/clc/api/v1/projects/"+options.user+"/"+datas[typeKey].project
        datas[typeKey].token = options.token
        option = {
          method:'POST'
          headers: {
            'Content-Type': 'application/json'
          },
          data: datas[typeKey]
        }
        urllib.request(url,option,(err, data, res)=>
          callback? data
        )

    # 配置数据备份数据字典
    backupsDataDictionary:(options,datas,typeKey,callback)=>
      typeDataArr = ["datatypes","signaltypes","eventtypes","porttypes","stationtypes","connectiontypes"]
      if(typeKey in typeDataArr)
        await @httpData options,datas[typeKey],typeKey,"type",defer(callbackData)
      if(typeKey == "units")
        await @httpData options,datas[typeKey],typeKey,"unit",defer(callbackData)
      if(typeKey =="eventseverities")
        await @httpData options,datas[typeKey],typeKey,"severity",defer(callbackData)
      if(typeKey =="eventphases")
        await @httpData options,datas[typeKey],typeKey,"phase",defer(callbackData)
      if(typeKey =="vendors")
        await @httpData options,datas[typeKey],typeKey,"vendor", defer(callbackData)
      if(typeKey =="roles")
        await @httpData options,datas[typeKey],typeKey,"role",defer(callbackData)
      if(typeKey =="capacities")
        await @httpData options,datas[typeKey],typeKey,"capacity",defer(callbackData)
      callback?()

    #配置数据备份设备模板
    backupsDeviceTemplate:(options,datas,typeKey,callback)=>
      typeDataArr = ["equipmenttypes","equipmenttemplates","equipmentproperties","equipmentsignals","equipmentevents","equipmentcommands","equipmentports","equipmentpoints","equipmentlogics"]
      if(typeKey in typeDataArr and datas[typeKey].length>0)
        await @httpData options,datas[typeKey],typeKey,"type",defer(callbackData)
      callback?()

    #配置数据备份站点设备
    backupsSiteEquipment:(options,datas,typeKey,callback)=>
      typeDataArr = ["stations","equipments"]
      if(typeKey in typeDataArr)
        await @httpData options,datas[typeKey],typeKey,"station",defer(callbackData)
      callback?()

    #配置数据的http请求
    httpData:(options,datasArr,typeKey,typeID,callback)=>
      _.each datasArr, (dataObj) =>
        delete dataObj.user
        delete dataObj.project
        delete dataObj._index
        delete dataObj.createtime
        delete dataObj.updatetime
        delete dataObj._id
        dataObj.token = options.token
        url ="#{options.ip}/model/clc/api/v1/#{typeKey}/#{options.user}/#{options.project}/#{dataObj[typeID]}"
        if(typeKey == "equipmenttemplates" and dataObj.template)
          url+="/#{dataObj.template}"
        if(typeKey == "equipmentproperties" and dataObj.property)
          url+="/#{dataObj.template}/#{dataObj.property}"
        if(typeKey == "equipmentsignals" and dataObj.signal)
          url+="/#{dataObj.template}/#{dataObj.signal}"
        if(typeKey == "equipmentevents" and dataObj.event)
          url+="/#{dataObj.template}/#{dataObj.event}"
        if(typeKey == "equipmentcommands" and dataObj.command)
          url+="/#{dataObj.template}/#{dataObj.command}"
        if(typeKey == "equipmentports" and dataObj.port)
          url+="/#{dataObj.template}/#{dataObj.port}"
        if(typeKey == "equipmentpoints" and dataObj.point)
          url+="/#{dataObj.template}/#{dataObj.point}"
        if(typeKey == "equipmentlogics" and dataObj.logic)
          url+="/#{dataObj.template}/#{dataObj.logic}"
        if(typeKey == "equipments" and dataObj.equipment)
          url+="/#{dataObj.equipment}"
        option = {
          method:'POST'
          headers: {
            'Content-Type': 'application/json'
          },
          data: dataObj
        }
        urllib.request(url,option,(err, data, res)=>
          # console.log("data",data.toString())
          callback? data
        )


    # 对组态数据进行处理
    uploadGraphicConfigure:(options,zipEntry,callback)=>
      plugins = JSON.parse zipEntry.getData().toString('utf8')
      svgType = ["svg-template","svg-frame","svg-rect","snapsvg","base","svg-text","svg-image","svg-group","text-box-graphic"]
      references = plugins._references
      th = plugins
      th.files = []
      @recursionFiles(th.elements,th.files)
      delete th._references
      delete th.project
      delete th._selected
      for typeData of references
        if(typeData in svgType)
          th.files.push(references[typeData].image)
          await @graphicDeleteHttp options,typeData,"graphictypes",defer(typeData,callbackData)
          await @graphicPostHttp options,references,typeData,"graphictypes",true,defer(callbackData)
      if(th)
        await @graphicDeleteHttp options,th.template,"graphictemplates",defer(typeData,callbackData)
        await @graphicPostHttp options,th,th.template,"graphictemplates",false,defer(callbackData)
      callback?()

    # 递归处理组态files属性
    recursionFiles:(elements,files)=>
      if(elements and elements.length >0)
        _.each elements, (element) =>
          @recursionFiles(element.elements,files)
          if(element.propertyValues.src)
            files.push(element.propertyValues.src.split("?")[0])

    # 组态删除数据http请求
    graphicDeleteHttp:(options,typeData,graphicType,callback)=>
      url = "#{options.ip}/model/clc/api/v1/#{graphicType}/#{options.user}/#{options.project}/#{typeData}?token=#{options.token}"
      option = {
        method:'DELETE'
        headers: {
          'Content-Type': 'application/json'
        },
        data:{
          token:options.token
        }
      }
      urllib.request(url,option,(err, data, res)=>
        callback? typeData,data
      )

    # 删除除完原有的组态在post http请求
    graphicPostHttp:(options,fieldData,typeData,graphicType,isfor,callback)=>
      if(isfor)
        fieldData[typeData].token = options.token
        modata = fieldData[typeData]
      else
        fieldData.token = options.token
        modata = fieldData
      delete modata._id
      delete modata._index
      delete modata.user
      url = "#{options.ip}/model/clc/api/v1/#{graphicType}/#{options.user}/#{options.project}/#{typeData}"
      option = {
        method:'POST'
        headers: {
          'Content-Type': 'application/json'
        },
        data:modata
      }
      urllib.request(url,option,(err, data, res)=>
        callback? data
      )

     # 上传文件到Resource http请求
    uploadResource:(options,zipEntry,callback)=>
      if(zipEntry.name)
        url = "#{options.ip}/resource/upload/img/public/#{zipEntry.name}?author=#{options.user}&filename=#{zipEntry.name}&project=#{options.project}&token=#{options.token}&user=#{options.user}"
        option = {
          method:'POST'
          files:zipEntry.getData()
          data:{
            author: options.user
            filename: zipEntry.name
            project: options.project
            token: options.token
            user: options.user
          }
        }
        urllib.request(url,option,(err, data, res)=>
          callback? data
        )


  exports =
    ConfigurationSetuoService: ConfigurationSetuoService