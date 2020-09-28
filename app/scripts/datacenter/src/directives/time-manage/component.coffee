###
* File: time-manage-directive
* User: David
* Date: 2020/05/29
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class TimeManageDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "time-manage"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.webTime = "" # 本地时间(前端页面时间)
      scope.serviceTime = "" # 服务器时间(后端时间)
      @swtichWebTime = "" # 服务端时间,用来转化时间
      @switchServiceTime = "" # 前端时间,用来转化时间
      scope.crearWebTime = null
      @timeFormat = "YYYY年MM月DD日 HH:mm:ss"
      @init(scope)
      # 同步时间
      scope.syncTime = () => (
        # 点击时间同步后 停止定时器的界面更新 等服务器完成同步并拿到服务器时间数据后再更新显示
        clearInterval(scope.crearWebTime)
        scope.crearWebTime = null
        @commonService.rpcPost("changeServiceTime", {time: moment(@swtichWebTime).format("YYYY-MM-DD HH:mm:ss")}, (err, res)=>
          @showServiceTime(err, res, scope)
        )
      )
      # 保存为NTP服务器的时间
      scope.saveNTPIP = () => (
        # 点击保存后 停止定时器的界面更新  等拿到 服务器时间同步为给定地址的时间 后再更新显示
        clearInterval(scope.crearWebTime)
        scope.crearWebTime = null
        return @display("NTP IP 地址不能为空") if(_.isEmpty(scope.ntpip))
        patt = /^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$/
        result = scope.ntpip.match(patt)
        if(result)
          @commonService.rpcPost("saveNTPIP", { ip: scope.ntpip }, (err, res)=>
            console.log('res',res)
            @showServiceTime(err, res, scope)
          )
        else
          @display("请输入正确的NTP地址")
      )
    # 修改服务端显示的时间
    showServiceTime: (err, res, scope) => (
      return @display(err) if err
      @switchServiceTime = res.data.time
      scope.serviceTime = moment(res.data.time).format(@timeFormat)
      @display("操作成功")
      # 持续刷新时间
      scope.crearWebTime = setInterval(()=>
        scope.webTime = moment(new Date()).format(@timeFormat)
        @switchServiceTime = moment(@switchServiceTime).add(1, "second")
        @swtichWebTime = moment(new Date())
        scope.serviceTime = moment(@switchServiceTime).format(@timeFormat)
        scope.$applyAsync()
      , 1000)
    )
    # 初始化执行
    init: (scope) => (
      scope.webTime = moment(new Date()).format(@timeFormat)
      @commonService.rpcGet("getServiceTime", null, (err, res)=>
        @switchServiceTime = res.data.time
        scope.serviceTime = moment(res.data.time).format(@timeFormat)
      )
      # 持续刷新时间
      scope.crearWebTime = setInterval(()=>
        scope.webTime = moment(new Date()).format(@timeFormat)
        @switchServiceTime = moment(@switchServiceTime).add(1, "second")
        @swtichWebTime = moment(new Date())
        scope.serviceTime = moment(@switchServiceTime).format(@timeFormat)
        scope.$applyAsync()
      , 1000)

      # 获取服务器上的ntpip信息
      @commonService.rpcGet("getNTPIP", null, (err, res)=>
        console.log("res",res)
        return console.log err if err
        if res.data[0]?.ntpIP
          scope.ntpip = res.data[0].ntpIP
      )
    )

    resize: (scope)->

    dispose: (scope)->
      clearInterval(scope.crearWebTime?)


  exports =
    TimeManageDirective: TimeManageDirective