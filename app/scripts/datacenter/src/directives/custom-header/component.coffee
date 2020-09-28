###
* File: custom-header-directive
* User: David
* Date: 2019/02/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class CustomHeaderDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "custom-header"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      name: '='
      subtitle: '='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.parameters.name = scope.parameters.name ? scope.project.model.setting.name ? "实时监控平台"
      scope.fullscreen = =>
        if document.webkitIsFullScreen
          document.webkitExitFullscreen()
        else
          $('#container').addClass("full-screen")
          document.getElementById("container").webkitRequestFullScreen()

    resize: (scope)->

    dispose: (scope)->


  exports =
    CustomHeaderDirective: CustomHeaderDirective