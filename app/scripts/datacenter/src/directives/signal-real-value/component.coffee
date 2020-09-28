###
* File: signal-real-value-directive
* User: David
* Date: 2019/06/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class SignalRealValueDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "signal-real-value"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      title: '='

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

    resize: (scope)->

    dispose: (scope)->


  exports =
    SignalRealValueDirective: SignalRealValueDirective