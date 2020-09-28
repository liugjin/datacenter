###
* File: ip-setting-directive
* User: David
* Date: 2020/03/18
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class IpSettingDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "ip-setting"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.num = 0
      scope.strURL = ""
      scope.isStart = false
      scope.pingDatas = []
      url = scope.controller.$location.$$absUrl.substr(0, scope.controller.$location.$$absUrl.indexOf("#"))+"rpc/ipSetting"
      params =
        token: scope.controller.$rootScope.user.token
      @commonService.uploadService.$http({method: 'GET', url: url, params: params}).then (res)=>
        scope.setting = res.data?.data
      scope.saveSetting = ()=>
        data =
          parameters: scope.setting
        @commonService.uploadService.$http({method: 'POST', url: url, data: data, params: params}).then (res)=>
          @display "保存失败" if res._err or not res.data?.data
          @display "保存成功" if res.data?.data is "ok"


      @commonService.signalLiveSession.subscribe "ping-callback",(err,d)=>
        if(d)
          scope.num++
          scope.pingDatas.push(pingData:d.message.str)
          console.log("scope.num",scope.num)
          if(scope.num == 1)
            scope.pingDatas.splice(0,scope.pingDatas.length)
          console.log("scope.pingDatas",scope.pingDatas)

      scope.pingClick=(isStart)=>
          @start(scope,isStart)
    
    # 开始
    start:(scope,isStart)=>
      if(scope.strURL == "")
        return @display "测试目标IP不能为空"
      else
        scope.parameter = {
          ip: scope.strURL
          state: isStart
          number:""
        }
        if(isStart)
          scope.pingDatas.splice(0,scope.pingDatas.length)
        @commonService.commandLiveSession.publish "ping-network",scope.parameter,{qos:0,retain:false}
    resize: (scope)->

    dispose: (scope)->


  exports =
    IpSettingDirective: IpSettingDirective