###
* File: rotate-showing-model-directive
* User: David
* Date: 2019/03/28
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class RotateShowingModelDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "rotate-showing-model"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      time = if scope.parameters?.time then scope.parameters?.time else 10000
      rotate = if typeof(scope.parameters?.rotate) == "boolean" then scope.parameters?.rotate else false

      scope.setInterval = null

      showingModelList = [
        { element: 'show-object3D', type: 'object3D' },
        { element: 'show-comprehensive', type: 'capacityObject3D', subType: 'ratio-comprehensive' },
        { element: 'show-space', type: 'capacityObject3D', subType: 'ratio-space' },
        { element: 'show-power', type: 'capacityObject3D', subType: 'ratio-power' },
        { element: 'show-cooling', type: 'capacityObject3D', subType: 'ratio-cooling' },
        { element: 'show-ports', type: 'capacityObject3D', subType: 'ratio-ports' },
        { element: 'show-weight', type: 'capacityObject3D', subType: 'ratio-weight' }
      ]

      scope.rotateIndex = 0
      # 切换展示模式
      changeShowingModel = (index) =>
        return console.warn("rotate index is err") if index >= showingModelList.length
        showingModel = showingModelList[index]
        @commonService.publishEventBus("changeShowModel", { type: showingModel.type, subType: showingModel.subType })
        scope.rotateIndex = index

      # 点击事件
      scope.clickShowingModel = (index) =>
        rotateWaitingFlag = true
        changeShowingModel(index)
        element.find('#' + showingModelList[index].element)
      
      # 定时轮转方法
      rotateShowingModel = () =>
        if !_.isNumber(scope.rotateIndex) || scope.rotateIndex >= (showingModelList.length - 1)
          scope.rotateIndex = 0
        else
          scope.rotateIndex += 1
        changeShowingModel(scope.rotateIndex)

      if rotate
        scope.setInterval = setInterval(rotateShowingModel, time)
    
    resize: (scope)->

    dispose: (scope)->
      scope.sub3DStatus?.dispose()
      clearInterval(scope.setInterval) if !_.isNull(scope.setInterval)


  exports =
    RotateShowingModelDirective: RotateShowingModelDirective