###
* File: one-file-uploader-directive
* User: David
* Date: 2019/11/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class OneFileUploaderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "one-file-uploader"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
#      model: '='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.uploadUrl = setting.urls.uploadUrl
      scope.file = null
      scope.handle = false

      publish = =>
        @publishEventBus "file", scope.file
        scope.$applyAsync()

      input = element.find("input[type='file']")

      scope.addFile = ->
        input.click()

      if scope.firstload
        input.bind("change", (evt) =>
          file = input[0]?.files?[0]
          return if not file
          @commonService.uploadService.upload(file, null, scope.uploadUrl + "/" + file.name, (err, resource) =>
            return @display("上传失败!!", 500) if err
            scope.file = { name: resource.name, path: resource.path, type: file.type }
            publish()
          )
        )

      scope.$watch("parameters.handle", (handle) =>
        if typeof(handle) == "boolean" && handle
          scope.handle = true
          scope.file = null
        else if typeof(handle) == "boolean" && !handle
          scope.handle = false
      )

    resize: (scope)->

    dispose: (scope)->


  exports =
    OneFileUploaderDirective: OneFileUploaderDirective