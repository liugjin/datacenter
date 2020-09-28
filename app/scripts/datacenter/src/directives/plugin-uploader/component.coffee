###
* File: plugin-uploader-directive
* User: David
* Date: 2019/12/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class PluginUploaderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "plugin-uploader"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    link: (scope, element, attrs) =>
      input = element.find('input[type="file"]')

      input.bind 'change', (evt) =>
        file = input[0]?.files?[0]
        evt.target.value = null
        zp = new FormData
        zp.append "file", file
        url = scope.controller.$location.$$absUrl.substr(0, scope.controller.$location.$$absUrl.indexOf("#"))+"rpc/upload"
        params =
          token: scope.controller.$rootScope.user.token
        @commonService.uploadService.$http({method: 'POST', url: url, data: zp, params: params, headers: {'Content-Type': undefined}}).then (res)=>
          if res.data?.data is "ok"
            @display "上传成功"
          else
            @display "上传失败"

    resize: (scope)->

    dispose: (scope)->


  exports =
    PluginUploaderDirective: PluginUploaderDirective