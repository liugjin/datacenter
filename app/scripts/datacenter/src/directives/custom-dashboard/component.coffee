###
* File: custom-dashboard-directive
* User: David
* Date: 2019/05/06
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "json!./layout.json"], (base, css, view, _, moment, layout) ->
  class CustomDashboardDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "custom-dashboard"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      try
        config = JSON.parse scope.project.model.layout
      catch
        config = {}
      key = scope.controller.$location.$$path.split("/")[1]
      configuration = config[key] ? layout[key]
      html = @getChildrenHTML scope, configuration
      ele = @$compile(html)(scope)
      element.empty()
      element.append(ele)

      key = scope.project.model.user+"."+scope.project.model.project+".stationId"
      localStorage.setItem key, scope.station.model.station

      scope.topicSubscription?.dispose()
      scope.topicSubscription = @commonService.subscribeEventBus "stationId", (msg) ->
        key = scope.project.model.user+"."+scope.project.model.project+".stationId"
        localStorage.setItem key, msg.message.stationId

    getChildrenHTML: (scope, children)->
      html = ""
      return html if not children
      for div in children
        html += "<" + (div.component ? div.tag ? "div")
        if div.component
          key = scope.project.model.user+"."+scope.project.model.project+".stationId"
          if localStorage.getItem(key) and div.parameters._mode isnt "'fixed'" and not @$routeParams.station
            div.parameters["station"] = "'"+localStorage.getItem(key)+"'"
            scope.station = _.find scope.project.stations.items, (item)->item.model.station is localStorage.getItem(key)
          parameters = JSON.stringify(div.parameters ? {}).replace /"/g, ""
          html += " controller='controller' parameters=\""+ parameters+"\""
        html += " class='"+div.class+"'" if div.class
        html += " style='"+div.style+"'" if div.style
        html += ">"
        html += @getChildrenHTML scope, div.children if div.children
        html += "</"+ (div.component ? div.tag ? "div")+ ">"
      html

    resize: (scope)->

    dispose: (scope)->
      scope.topicSubscription?.dispose()


  exports =
    CustomDashboardDirective: CustomDashboardDirective