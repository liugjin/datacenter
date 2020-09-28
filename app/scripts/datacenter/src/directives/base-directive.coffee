###
* File: base-directive
* User: David
* Date: 2018-07-10
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['underscore', "materialize-css"], (_, M) ->
  class BaseDirective
    constructor: (@$timeout, @$window, @$compile, @$routeParams, @commonService)->
      @restrict = "EA"
      @scope =
        controller: '='
        parameters: '='
      @scope.parameters = _.extend @scope.parameters, @setScope()
      @template = "<style>"+@parseCSS(@setCSS())+"</style>"+@setTemplate()+@defaultTemplate()
      @templateUrl = if @template then null else @setTemplateUrl()
      @id = "" if not @id

    defaultTemplate: ->
      """
      <style>
        ##{@id}-prompt-modal.modal.open {
          border-radius: 5px;
          border: 1px solid #3573b6;
        }
        ##{@id}-prompt-modal .modal-content input {
          text-indent: 15px;
        }
        ##{@id}-prompt-modal .modal-footer {
          background-color: #0D2564 !important;
          font-size: 14px;
        }
        ##{@id}-prompt-modal .modal-content {
          background-color: #061239;
        }
        ##{@id}-prompt-modal .modal-content .p-color{
          color:#AAC6DF
        }
        ##{@id}-prompt-modal .modal-footer .modal-cancel .material-icons, ##{@id}-prompt-modal .modal-footer .modal-confirm .material-icons {
          margin-right: 5px;
        }
        ##{@id}-prompt-modal .modal-footer .modal-confirm, ##{@id}-prompt-modal .modal-footer .modal-cancel {
          width: 116px;
          height: 100%;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        ##{@id}-prompt-modal .modal-footer .modal-confirm {
          background-color: rgba(75, 165, 248, 0.4);
        }

      </style>
      <div id=\""""+@id+"""-prompt-modal" class="modal" md-modal>
        <div class="modal-content">
            <h5> {{modal.title}} </h5>
            <p class="p-color"> {{modal.message}} </p>
            <input type='text' ng-model='modal.comment' ng-show='modal.enableComment'/>
        </div>
        <div class="modal-footer">
          <div ng-click="modal.confirm(true)" class="modal-confirm modal-action right modal-close">
            <i class="material-icons">done</i>
            <span>确认</span>
          </div>
          <div ng-click="modal.confirm(false)" class="modal-cancel modal-action right modal-close">
              <i class="material-icons">close</i>
              <span>取消</span>
          </div>
        </div>
      </div>
      """

    parseCSS: (css) ->
      ret = css.replace /~([^~]+)~/g, (str)=>
        path = str.substr(1, str.length-2)
        return @getComponentPath path
      ret

    checkParams: (params) ->
      return true if not params
      for key, value of params
        return true if not value?
      return false

    link: (scope, element, attrs) ->
      scope.date = (new Date()).getTime()
      scope.firstload = true
      scope.setting = setting
      @getProject scope
      scope.$watch "project", (project) =>
        return if not project?
        scope.$watch "parameters", (params)=>
          return if @checkParams params
          @getStation scope, params.station ? @$routeParams.station, =>
            @getEquipment scope, params.equipment ? @$routeParams.equipment, =>
              scope.callbacknum = 0
              @getSignal scope, params.signal, =>
                @setLink scope, element, attrs
              @getEvent scope, params.event, =>
                @setLink scope, element, attrs
              @getCommand scope, params.command, =>
                @setLink scope, element, attrs
              @getProperty scope, params.property, =>
                @setLink scope, element, attrs
        , true

      scope.stationEventBus?.dispose()
      scope.stationEventBus = @subscribeEventBus "stationId", (msg)=>
        return if scope.station?.model.station is msg.message.stationId
        scope.parameters.station = msg.message.stationId if scope.parameters._mode isnt "fixed"

      win = angular.element @$window
      resize = => @resize scope
      win.bind 'resize', resize

      scope.$on '$destroy', =>
        win.unbind 'resize', resize
        scope.signalSubscription?.dispose()
        scope.commandSubscription?.dispose()
        scope.stationEventBus?.dispose()
        @dispose scope

      scope.getComponentPath = (path) =>
        @getComponentPath path

      scope.fullscreen = (ele) =>
        @fullscreen ele

      scope.prompt = (title, message, callback, enableComment, comment) =>
        scope.modal =
          title: title
          message: message
          enableComment: enableComment
          comment: comment

          confirm: (ok) ->
            callback? ok, scope.modal.comment
        scope.$applyAsync()

        $('#'+@id+'-prompt-modal').modal('open')

      scope.goto = (path, immediately) ->
        scope.controller.$location.url path
        scope.$applyAsync() if immediately

    getProject: (scope, callback, refresh)->
      filter =
        user: @$routeParams.user
        project: @$routeParams.project
      fields = null
      @commonService.loadProject filter, fields, (err, project) =>
        if not err
          project.loadStations null, (err, stations) =>
            scope.project = @project = project
            scope.project?.stations?.nitems = _.filter stations, (sta)->sta.model.station.substr(0,1)!= "_"
            #            scope.station = _.find stations, (sta)->sta.model.station.substr(0,1)!="_" and _.isEmpty sta.model.parent
            callback?()
      ,refresh

    getStation: (scope, id, callback, refresh) ->
      if not id
        scope.station = _.max (_.filter scope.project.stations?.nitems, (sta)->_.isEmpty sta.model.parent), (item)->(item.model.index ? 0)
        return callback?()
      @project?.loadStations null, (err, stations) =>
        if not err
          scope.station = _.find stations, (sta)->sta.model.station is id
          callback?()
      , refresh

    getEquipment: (scope, id, callback, refresh) ->
      return callback?() if not id
      scope.station?.loadEquipment id, null, (err, equip) =>
        if not err and equip
          scope.equipment = equip
          callback?()
      ,refresh

    getSignal: (scope, id, callback, refresh) ->
      return callback?() if not id
      refresh = true if scope.equipment?.signals.items.length is 0
      scope.equipment?.loadSignals null, (err, signals) =>
        if not err
          scope.signal = _.find signals, (sig)->sig.model.signal is id
          scope.signalSubscription?.dispose()
          scope.signalSubscription = @commonService.subscribeSignalValue scope.signal
          callback?()
      ,refresh

    getEvent: (scope, id, callback, refresh) ->
      return callback?() if not id
      scope.equipment?.loadEvents null, (err, events) =>
        if not err
          scope.event = _.find events, (evt)->evt.model.event is id
          callback?()
      ,refresh

    getCommand: (scope, id, callback, refresh) ->
      return callback?() if not id
      scope.equipment?.loadCommands null, (err, commands) =>
        if not err
          scope.command = _.find commands, (cmd)->cmd.model.command is id
          callback?()
      ,refresh

    getProperty: (scope, id, callback, refresh) ->
      return callback?() if not id
      scope.equipment?.loadProperties null, (err, properties) =>
        if not err
          scope.property = _.find properties, (sig)->sig.model.property is id
          callback?()
      ,refresh

    getComponentPath: (path)->
      scripts = document.getElementsByTagName("script")
      script = _.find scripts, (sp)=>sp.src.indexOf("/"+@id)>0 and sp.src.indexOf("/component.js")>0
      script?.src+"/../"+path

    getHostType: ()->
      userAgent = navigator.userAgent
      Agents =  ["Android", "iPhone","SymbianOS", "Windows Phone","iPad", "iPod"]
      system = 'PC'
      for os in Agents
        if userAgent.indexOf(os) > 0
          system = os
          break
      return system

    display: (err, info, period) ->
      delay = period || 2000
      message = @formatErrorInfo err, info
      M.toast {html: message, displayLength:delay} if message

    formatErrorInfo: (err, info) ->
      if err
        if typeof err is 'object'
          result = JSON.stringify err
        else
          result = err
        console.log result
      else
        result = info
      result

    waitingLayout: ($timeout, element, callback) =>
      $timeout =>
        if element.width() <= 100
          @waitingLayout $timeout, element, callback
        else
          callback()
      , 200

    subscribeEventBus: (topic, callback, throttle) ->
      @commonService.subscribeEventBus topic, callback, throttle

    publishEventBus: (topic, message) ->
      @commonService.publishEventBus topic, message

    executeCommand: (scope, command) ->
      @commonService.executeCommand command
      @commonService.$rootScope.executing = true
      scope.noresponse = setTimeout =>
        @commonService.$rootScope.executing = false
        @commonService.$rootScope.$applyAsync()
        @display "操作无响应"
      ,6000
      setTimeout =>
        scope.commandSubscription?.dispose()
        scope.commandSubscription = @commonService.subscribeCommandValue command, (cmd) =>
          return if cmd.data.phase is "executing"
          @commonService.$rootScope.executing = false
          clearTimeout scope.noresponse
          @display "操作成功" if cmd.data.phase is "complete"
          @display "操作失败" if cmd.data.phase is "error"
          @display "操作超时" if cmd.data.phase is "timeout"
      ,100

    fullscreen: (element) ->
      if not element
        element = "#container"

      if typeof element is 'string'
        el = angular.element element
        element = el[0]

      exit = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement

      if exit
        if document.exitFullscreen
          document.exitFullscreen()
        else if document.webkitExitFullscreen
          document.webkitExitFullscreen Element.ALLOW_KEYBOARD_INPUT
        else if document.mozExitFullScreen
          document.mozExitFullScreen()
        else if document.msExitFullscreen
          document.msExitFullscreen()
      else
        if element.requestFullscreen
          element.requestFullscreen()
        else if element.webkitRequestFullscreen
          element.webkitRequestFullscreen Element.ALLOW_KEYBOARD_INPUT
        else if element.mozRequestFullScreen
          element.mozRequestFullScreen()
        else if element.msRequestFullscreen
          element.msRequestFullscreen()

    setScope: ->

    setCSS: ->

    setTemplate: ->

    setTemplateUrl: ->

    setLink: (scope, element, attrs)->
      scope.callbacknum++
      if scope.callbacknum is 4
        @show? scope, element, attrs
        scope.firstload = false

    resize: (scope)->

    dispose: (scope)->

  exports =
    BaseDirective: BaseDirective