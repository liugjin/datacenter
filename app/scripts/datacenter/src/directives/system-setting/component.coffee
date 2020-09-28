###
* File: system-setting-directive
* User: David
* Date: 2018/11/22
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "json!../../../setting.json"], (base, css, view, _, moment, setting) ->
  class SystemSettingDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "system-setting"
      super $timeout, $window, $compile, $routeParams, commonService
      @$routeParams = $routeParams

      @projectService = commonService.modelEngine.modelManager.getService("project")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.projectObj = {}
      scope.tmpMyProject = @commonService.modelEngine.storage.get("myproject")
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

      scope.saveSetting = ()=>
        scope.projectObj.setting = scope.setting
        scope.projectObj.name = scope.setting.name
        scope.tmpMyProject.name = scope.setting.name
        @projectService.save scope.projectObj,(err,data)=>
          @commonService.modelEngine.storage.set "myproject",scope.tmpMyProject
          @display err, '操作成功！'


    resize: (scope)->

    dispose: (scope)->


  exports =
    SystemSettingDirective: SystemSettingDirective