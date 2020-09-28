###
* File: notice-tip2-directive
* User: David
* Date: 2019/12/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class NoticeTip2Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "notice-tip2"
      super $timeout, $window, $compile, $routeParams, commonService
      @projectService = commonService.modelEngine.modelManager.getService("project")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      init= () => (
        filter = {}
        filter.user = @$routeParams.user
        filter.project = @$routeParams.project

        @projectService.query(filter, null, (err, datas) =>
          if datas
            scope.text = datas.setting.desc
            scope.$applyAsync()
        )
      )

      if !scope.text
        init()

    resize: (scope)->

    dispose: (scope)->


  exports =
    NoticeTip2Directive: NoticeTip2Directive