###
* File: batch-configuration-directive
* User: David
* Date: 2020/05/07
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","jszip2"], (base, css, view, _, moment,zip) ->
  class BatchConfigurationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "batch-configuration"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @ip = @$window.origin
      @templates = []
      @user = scope.project.model.user
      @project = scope.project.model.project
      @setting = scope.setting
      @dictionaryTypes = ["datatypes", "signaltypes", "eventtypes", "porttypes", "stationtypes", "units", "eventseverities", "eventphases", "vendors", "roles", "connectiontypes", "capacities"]
      @modelTypes = ["equipmenttemplates", "equipmentproperties", "equipmentsignals", "equipmentevents", "equipmentcommands", "equipmentports"]
      @siteEquipment = ["stations","equipments"]
      @referenceFileKeys = ["image","src","audio", "video", "file", "attachment","d3"]
      # 获取设备模板
      scope.project.loadEquipmentTemplates null, null, (err, tmps) =>
        @templates = tmps
      ,true

      # 获取设备库
      @commonService.rpcGet "muSetting", null, (err,data)=>
        @mu = data?.data?.mu
        @elements = data?.data?.elements
        console.log("@mu",@mu)
        console.log("321",@elements)



      # 备份
      scope.download=(callback)=>
        @totalFile = new zip
        @selectTemplates = []
        @selectTypes = []
        _.each @templates, (template) =>
          @selectTemplates.push template.model.template
        _.each @templates, (template) =>
          @selectTypes.push template.model.type if @selectTypes.indexOf(template.model.type) is -1
        await @downloadElements defer()
        await @downloadMonitoring defer()
        await @downloadGraphics defer()
        await @loadConfiguration defer err, data
        project = data.project
        info =
          from: {user: @user, project: @project}
          to: {}
          timestamp: (new Date()).toISOString()
          data: data
        file = new zip
        name = project.user+"-"+project.project+".json"
        infos = JSON.stringify info, null, 2
        file.folder("project").file name, infos
        await @downloadAndZipFilesByJson data, file, defer()
        await file.generateAsync({type: "blob"}).then defer(content)
        zname = "project"+"-"+project.user+".zip"
        # @downloadBlobFile content, zname
        @totalFile.file zname, content
        console.log("data",data)
        await @totalFile.generateAsync({type: "blob"}).then defer(tent)
        name = "configuration-"+project.project+"-"+project.user+".zip"
        @downloadBlobFile tent, name
        callback? err, data

      # 选择备份文件
      scope.file= () =>
        scope.fileNameStr = ""
        input = element.find('input[type="file"]')
        input.click()
        input.click(()=>
          input.val('');
        );
        input.on('change', (evt)=>
          file = input[0]?.files?[0]
          scope.fileNameStr = file.name
          evt.target.value = null
          scope.zp = new FormData
          scope.zp.append "file", file
          scope.$applyAsync()
        );

      # 确认上传
      scope.confirmSha =()=>
        console.log("scope.controller",scope.controller)
        url = scope.controller.$location.$$absUrl.substr(0, scope.controller.$location.$$absUrl.indexOf("#"))+"rpc/configurationRecovery"
        params =
          token: scope.controller.$rootScope.user.token
          parameters:
            token: scope.controller.$rootScope.user.token
            project: @project
            user: @user
            ip: @ip
        @commonService.uploadService.$http({method: 'POST', url: url, data: scope.zp, params: params,headers: {'Content-Type': undefined}}).then (res)=>
          if res.data?.data is "ok"
            @display "上传成功"
          else
            @display "上传失败"

    
    loadConfiguration: (callback) ->
      result = {}
      getback = (key, err, data, flag) ->
        return callback err if err
        result[key] = if flag or data instanceof Array then data else [data]

      await @loadData "project", defer(err, project)
      getback "project", err, project, true

      
      for item in @dictionaryTypes
        await @loadData item, defer(err, data)
        getback item, err, data

      types = @selectTypes.join()
      await @loadData "equipmenttypes", defer(err, data), null, {type: types}
      getback "equipmenttypes", err, data

      templates = @selectTemplates.join()
      for item in @modelTypes
        await @loadData item, defer(err, data), null, {template: templates}
        getback item, err, data

      for item in @siteEquipment
        await @loadData item, defer(err, data),null,null
        getback item, err, data
      callback? null, result




    
    loadData: (serviceId, callback, field, filter = {}) =>
      service = @commonService.modelEngine.modelManager.getService serviceId
      filter.user ?= @user
      filter.project ?= @project
      service.query filter, field, (err, data) =>
        callback? err, data
    
    downloadAndZipFilesByJson: (data, zp, callback) =>
      images = []
      for item in @referenceFileKeys
        folder = zp.folder item
        files = @findJsonValuesByKey data, item
        for key ,file of files
          images.push {file: file, folder: folder}
        files = @findJsonValuesByProperty data, item, "property", "value"
        for key ,file of files
          images.push {file: file, folder: folder}
      for image in images
        file = @setting.urls.uploadUrl+"/"+image.file
        await @downloadFileAsync file, defer err, doc
        if not err and doc
          name = image.file.split("?")[0]
          image.folder.file(name, doc)
      callback?()

    # 下载组态
    downloadGraphics:(callback) =>
      @graphics = []
      @infos = []
      _.each @templates, (template) =>
        @graphics.push template.model.graphic if template.model.graphic
      return if @graphics.length is 0
      file = new zip
      folder = file.folder("template")
      for graphic in @graphics
        await @loadData "graphictemplates", defer(err, data), null, {template: graphic}
        @infos.push data
        name = "graphic-template-"+data.user+"."+data.project+"-"+graphic+".json"
        info = JSON.stringify data, null, 2
        folder.file name, info
      await @downloadAndZipFilesByJson @infos, file, defer()
      await file.generateAsync({type: "blob"}).then defer(content)
      zname = "graphic-templates-"+data.user+".zip"
      # @downloadBlobFile content, zname
      @totalFile.file zname, content
      callback?()

    downloadJsonFiles: (file, callback) ->
      jsons = []
      _.each @templates, (template) =>
        data = template.model.symbol ? template.model.desc
        jsons = jsons.concat data if data and data.length
      for json in jsons
        _.mapObject @elements, (ele)=>
          if ele.id == json
            infos = JSON.stringify ele, null, 2
            name = json+".json"
            file.folder("elements").file name, infos
      callback?()

    # 下载设备库
    downloadElements:(callback) =>
      file = new zip()
      await @downloadJsonFiles file, defer()
      await file.generateAsync({type: "blob"}).then defer(content)
      zname = "elements.zip"
      # @downloadBlobFile content, zname
      @totalFile.file zname, content
      callback?()

    # 下载monitoring-units.json
    downloadMonitoring:(callback)=>
      file = new zip
      name = "monitoring-units.json"
      infos = JSON.stringify @mu, null, 2
      file.folder("monitoring-units").file name, infos
      await file.generateAsync({type: "blob"}).then defer(content)
      zname = "monitoring-units.zip"
      @totalFile.file zname, content
      callback?()
    
    downloadMakeupZip:(content)=>
      console.log("content",content)

    
    downloadFileAsync: (file, callback) ->
      xhr = new XMLHttpRequest
      xhr.open 'GET', file
      xhr.responseType = "blob"
      xhr.onload = ->
        err = if this.status == 200 then null else this.status
        callback err, xhr.response
      xhr.send()

    findJsonValuesByKey: (json, key) ->
      result = {}
      return result if not json

      if json instanceof Array
        for j in json
          r2 = @findJsonValuesByKey j, key
          for k, v of r2
            result[v] = v
      else if typeof json is 'object'
        for k, v of json
          if ((key instanceof Array) and k in key) or  k is key
            if typeof v is 'string'
              result[v] = v
            else if typeof v is 'object'
              r2 = @findJsonValuesByKey v, key
              for k2, v2 of r2
                result[v2] = v2
          else
            r2 = @findJsonValuesByKey v, key
            for k2, v2 of r2
              result[v2] = v2

      result
    
    findJsonValuesByProperty: (json, type, propertyKey = 'property', valueKey = 'value') ->
      result = {}
      return result if not json

      if json instanceof Array
        for j in json
          r2 = @findJsonValuesByProperty j, type, propertyKey, valueKey
          for k, v of r2
            result[v] = v
      else if typeof json is 'object'
        for k, v of json
          if k is propertyKey and (((type instanceof Array) and v in type) or v is type)
            val = json[valueKey]

            if typeof val is 'string'
              result[val] = val
            else if typeof val is 'object'
              r2 = @findJsonValuesByProperty val, type, propertyKey, valueKey
              for k2, v2 of r2
                result[v2] = v2
          else
            r2 = @findJsonValuesByProperty v, type, propertyKey, valueKey
            for k2, v2 of r2
              result[v2] = v2
      result
    
    downloadBlobFile: (blob, filename) ->
      e = document.createEvent('MouseEvents')
      a = document.createElement('a')
      a.download = filename
      a.href = window.URL.createObjectURL(blob)
      a.dataset.downloadurl = [
        a.download
        a.href
      ].join(':')
      e.initEvent 'click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null
      a.dispatchEvent e
      return


    resize: (scope)->

    dispose: (scope)->


  exports =
    BatchConfigurationDirective: BatchConfigurationDirective