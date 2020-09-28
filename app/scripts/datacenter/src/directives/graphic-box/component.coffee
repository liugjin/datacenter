###
* File: graphic-box-directive
* User: David
* Date: 2018/11/16
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "jquery.ui"], (base, css, view, _, moment) ->
  class GraphicBoxDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "graphic-box"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->
      templateId:"="
      noBorderStyle: "="

    setCSS: ->
      css

    applyChange:->
      return ()=>
        scope.$applyAsync()

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      return if not scope.firstload
      if scope.parameters.templateId
        scope.templateId =
          user: @$routeParams.user
          project: @$routeParams.project
          template: scope.parameters.templateId

      initializeView = () => (
        if _.isNull(document.getElementById('#element-placeholder'))
          setTimeout(initializeView, 1000)
          return
        scope.placeholder = $('#element-placeholder')
        scope.placeholder.draggable()

        scope.placeholderSize =
          width: scope.placeholder.width()
          height: scope.placeholder.height()
          width2: scope.placeholder.width() / 2
          height2: scope.placeholder.height() / 2
      )

      initializeGraphicOptions = () => (
        scope.graphicOptions =
          engineOptions:
            parameters: @$routeParams
          renderOptions:
            editable: false
            type: @$routeParams.renderer ? @$rootScope?.renderType ? 'snapsvg'
            uploadUrl: window?.setting?.urls?.uploadUrl
      )

      scope.movePlaceholderToElement = (element) -> (
        return if not element
        # put on element center
        box = element._geometry.node.getBoundingClientRect()
        x = box.left + box.width / 2 - scope.placeholderSize.width / 2
        y = box.top + box.height / 2 - scope.placeholderSize.height / 2
        scope.placeholder.offset
          left: x
          top: y
        return
      )

      scope.applyChange= () =>
        scope.$apply() if not scope.$$phase

      scope.initializePlaceholder = () => (
        template = scope.template
        updatePlaceholder = () =>
          image = template.getPropertyValue 'placeholder-image'
          x = template.getPropertyValue 'placeholder-x', 50
          y = template.getPropertyValue 'placeholder-y', 50
          width = template.getPropertyValue 'placeholder-width', 20
          height = template.getPropertyValue 'placeholder-height', 20
          scope.placeholderMode = mode = template.getPropertyValue 'placeholder-mode', 'dynamic'
          scope.timelineEnable = template.getPropertyValue 'timeline-enable', false

          # update placeholder
          css =
            left: x
            top: y
            width: width
            height: height
          css['background-image'] = if image then "url(#{scope.controller.setting.urls.uploadUrl}/#{image})" else "url(/visualization/res/img/popover.gif)"
          scope.placeholder.css css

          if mode is 'none'
            scope.placeholder.hide()
          else if mode in ['dynamic', 'element']
            scope.placeholder.draggable 'enable'
            scope.placeholder.show()
          else
            scope.placeholder.draggable 'disable'
            scope.placeholder.show()

          # update placeholder size
          scope.placeholderSize =
            x: x
            y: y
            width: width
            height: height
            width2: width / 2
            height2: height / 2

        template.subscribePropertiesValue ['placeholder-image', 'placeholder-x', 'placeholder-y', 'placeholder-width', 'placeholder-height', 'placeholder-mode'], (d) ->
          updatePlaceholder()
        , 100

        updatePlaceholder()
      )

      html = '''
      <div class='box-hexagon'>
        <div class='{{parameters.noBorderStyle?"":"big-box-border-top"}}'></div>
        <div class='{{parameters.noBorderStyle?"":"box-content"}} max-height'>
          <div id="player" ng-dblclick="controller.showPopover($event)">
              <div graphic-player="graphic-player" options="graphicOptions" template-id="templateId"
                   controller="controller" on-template-load="controller.onTemplateLoad()"
                   on-element-changed="controller.onElementChanged()" parameters="parameters"
                   class="graphic-viewer"></div>
              <div id="element-placeholder" ng-show='placeholderMode != "none"'
                 data-activates="placeholder-menu" md-dropdown="md-dropdown" data-hover="false" data-beloworigin="true"
                 title2="信息窗口">
                <div id="element-placeholder-popover" style="width:100%; height:100%;" ng-click2="togglePopover($event)"
                     element-popover="element-popover" data-style="inverse"
                     data-title="{{element.propertyValues.name || controller.element.id}}"
                     element="element" controller="controller" data-trigger="manual" data-placement="auto"
                     data-closeable="true" data-dismissible="false" data-animation="fade"
                     title2="信息展示：在选中项前双击即可弹出信息窗口"></div>
              </div>
          </div>
        </div>
        <div class='{{parameters.noBorderStyle?"":"big-box-border-bottom"}}'></div>
      </div>
      '''

      initializeGraphicOptions()
      initializeView()
      ele = @$compile(html)(scope)
      dom = $(element.find("#graphic")[0])
      dom.empty()
      scope.updateDomState = setTimeout(() =>
        dom.append(ele)
      , 100)

      scope.updateLazy = _.throttle((template) =>
        scope.templateId =
          user: @$routeParams.user
          project: @$routeParams.project
          template: template.templateId
          parameters: template.templateParameters
        # console.log(scope.templateId)
      , 100, { leading: true, trailing: true })

      scope.$watch("parameters", (template) =>
        return if not template.templateId
        scope.updateLazy(template)
        # console.log(template)
      )

    dispose: (scope) -> (
      window.clearTimeout(scope.updateDomState)
    )


  exports =
    GraphicBoxDirective: GraphicBoxDirective