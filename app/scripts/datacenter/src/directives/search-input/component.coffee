###
* File: search-input-directive
* User: David
* Date: 2018/11/05
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class SearchInputDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "search-input"

    setScope: ->
      placeholder:'@'
    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>

      scope.$watch "search",(search)=>
        @commonService.publishEventBus 'search',search

    dispose: (scope)->


  exports =
    SearchInputDirective: SearchInputDirective