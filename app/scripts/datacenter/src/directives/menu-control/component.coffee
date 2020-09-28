###
* File: menu-control-directive
* User: David
* Date: 2018/11/29
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class MenuControlDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "menu-control"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    link: (scope, element, attrs) =>
      scope.menuControl=() =>
        @publishEventBus 'menuState', {'menu': 'menu'}
        @$timeout ->
          $(window).resize()

    resize: (scope)->

    dispose: (scope)->


  exports =
    MenuControlDirective: MenuControlDirective