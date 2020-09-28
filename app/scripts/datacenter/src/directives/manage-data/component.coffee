###
* File: manage-data-directive
* User: David
* Date: 2020/05/18
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ManageDataDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "manage-data"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @equipmentsignalsService = @commonService.modelEngine.modelManager.getService('equipmentsignals')
      @project = scope.project.model.project
      @user = scope.project.model.user
      scope.storeModel = ""
      scope.ftpInfo = {
        host: "",
        port: "",
        user: "",
        password: ""
      }
      @init(scope)
      # 修改数据储存策略
      scope.confitmRadioMethod = () => (
        postObj = {
          model: scope.storeModel
          project: @project,
          user: @user
        }
        @commonService.rpcPost("changeStoreMode", postObj, (err, res)=>
          if(res.parameters.model == "1800000")
            @display("数据储存策略已修改成精细模式")
          else if(res.parameters.model == "14400000")
            @display("数据储存策略已修改成均衡模式")
          else if(res.parameters.model == "28800000")
            @display("数据存储策略已修改成长时模式")
          else
            @display(res.data.msg)
        )
      )
      # 修改储存信息
      scope.changeStoreInfo = () => (
        return @display("必填项不能为空") if(_.isEmpty(scope.ftpInfo.host) || _.isEmpty(scope.ftpInfo.user) || _.isEmpty(scope.ftpInfo.password) )
        return @display("端口的格式应该是数字") if(!isNaN(scope.ftpInfo.host))
        postObj = {
          project: @project,
          user: @user,
          address: scope.ftpInfo
        }
        @commonService.rpcPost("changeStoreInfo", postObj, (err, res)=>
          if(res.data.status == true)
            @display("已成功修改备份地址")
          else
            @display("请输入正确的备份地址")
        )
      )
    # 初始化执行
    init: (scope) => (
      # 查询当前的数据储存策略
      @commonService.rpcGet("getStoreMode", null, (err,res)=>
        scope.storeModel = res.data.storeMode
        scope.ftpInfo = {
          host: res.data.host,
          port: res.data.port,
          user: res.data.user,
          password: res.data.password
        }
      )
    )
    resize: (scope)->

    dispose: (scope)->


  exports =
    ManageDataDirective: ManageDataDirective