###
* File: system-info-directive
* User: David
* Date: 2020/05/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","json!../../../setting.json"], (base, css, view, _, moment,setting) ->
  class SystemInfoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "system-info"
      super $timeout, $window, $compile, $routeParams, commonService
      @$routeParams = $routeParams

      @projectService = commonService.modelEngine.modelManager.getService("project")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.versionInformation = []
      scope.projectObj = {}
      scope.disPublish?.dispose()
      scope.fileNameStr = ""
      scope.upgrade = false
      scope.tmpMyProject = @commonService.modelEngine.storage.get("myproject")
      scope.warnNotice = @commonService.modelEngine.storage.set("warn-notice")

      querySetting = (settingObj)=>
        scope.warnNotice = {
          "defaultFlag": settingObj.defaultFlag
        }  
      
        @commonService.modelEngine.storage.set "warn-notice",scope.warnNotice
      
        @commonService.publishEventBus "warnNotice", settingObj

      filter = {}
      filter.user = @$routeParams.user
      filter.project = @$routeParams.project
      @projectService.query filter,null,(err,datas)=>
        if datas
          datas.setting.menus ?= setting.menus
          scope.projectObj = datas
          if _.isEmpty(scope.projectObj.setting) or scope.projectObj.private
            scope.setting = setting
          else
            scope.setting = scope.projectObj.setting

          # if datas.setting.defaultFlag == null || datas.setting.defaultFlag == undefined || datas.setting.defaultFlag == "undefined" 
          #   scope.setting.defaultFlag = false
          # else
          #   scope.setting.defaultFlag = datas.setting.defaultFlag
          querySetting( scope.setting )    

          # scope.disPublish = @commonService.subscribeEventBus "noticeFlag",(msg)=>
          #   scope.setting.defaultFlag = msg.message
            
          #   scope.saveSetting()

      # scope.switchEvent = (set)=>
      #   scope.setting.defaultFlag = set

      scope.saveSetting = ()=>
        scope.projectObj.setting = scope.setting
        scope.projectObj.name = scope.setting.name
        scope.tmpMyProject.name = scope.setting.name

        @projectService.save scope.projectObj,(err,data)=>
          querySetting( data.setting )
          @commonService.modelEngine.storage.set "myproject",scope.tmpMyProject
          M.toast({html: "操作成功！"})
          if !@$routeParams.changeSetting   # header组件里logo是watch  @$routeParams对象变化来取的数据，这里点保存时更新@$routeParams对象让header里的logo更新数据。
            @$routeParams.changeSetting = true
          else
            @$routeParams.changeSetting = !@$routeParams.changeSetting

      
      @commonService.rpcGet "getSystemInfo", null, (err,data)=>
        scope.versionInformation = data?.data
       # 升级
      scope.file= () =>
        scope.fileNameStr = ""
        input = element.find('#upload')
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

      scope.confirmSha =()=>
        console.log("点击")
        if(scope.fileNameStr !="")
          url = scope.controller.$location.$$absUrl.substr(0, scope.controller.$location.$$absUrl.indexOf("#"))+"rpc/upgrade"
          scope.upgrade = true
          params =
            token: scope.controller.$rootScope.user.token
          @commonService.uploadService.$http({method: 'POST', url: url, data: scope.zp, params: params,headers: {'Content-Type': undefined}}).then (res)=>
            if res.data?.data is "ok"
              @display "升级成功,请刷新页面"
              scope.upgrade = false
            else
              @display "升级失败"
              scope.upgrade = false
        else
          @display "请选择升级包"

        
        
    resize: (scope)->

    dispose: (scope)->
      scope.disPublish?.dispose()

  exports =
    SystemInfoDirective: SystemInfoDirective