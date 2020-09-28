###
* File: alarm-number-box-directive
* User: David
* Date: 2019/02/18
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class AlarmNumberBoxDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "alarm-number-box"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

    resize: (scope)->

    dispose: (scope)->


  exports =
    AlarmNumberBoxDirective: AlarmNumberBoxDirective