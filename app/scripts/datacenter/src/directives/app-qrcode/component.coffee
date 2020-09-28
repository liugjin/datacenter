###
* File: app-qrcode-directive
* User: David
* Date: 2019/07/13
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "qrcode"], (base, css, view, _, moment, qrcode) ->
  class AppQrcodeDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "app-qrcode"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      code = element.find(".qrcode")[0]
      @qrcode = new qrcode code,
        text: scope.parameters.url ? scope.controller.$location.$$absUrl
        width: 200
        height: 200
        margin: 10

    resize: (scope)->

    dispose: (scope)->


  exports =
    AppQrcodeDirective: AppQrcodeDirective