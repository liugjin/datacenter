###
* File: report-users-directive
* User: David
* Date: 2019/11/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportUsersDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "report-users"
      super $timeout, $window, $compile, $routeParams, commonService
      @logonUser = commonService.$rootScope.user

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.token = scope.controller?.$rootScope?.user?.token || setting.adminToken || '0b6703d0-d873-11e9-ab4f-c5a3318c0787'
#      scope.token = setting.adminToken || '0b6703d0-d873-11e9-ab4f-c5a3318c0787'          #用普通登录用户得不到users数据，使用admin的token查数据库
      scope.header = [
        {headerName:"用户", field: 'user',width:90},
        {headerName:"用户名", field: 'name'},
        {headerName:"电话", field: 'phone'},
        {headerName:"邮件", field: 'email'},
        {headerName:"创建时间", field: 'createtime'},
      ]
      scope.garddatas = [
        {user:"暂无数据",name:"暂无数据",phone:"暂无数据",email:"暂无数据",createtime:"暂无数据"}
      ]
      scope.pageItems = scope.parameters.pageItems || 12
      scope.searchFlag = false   #按id或者名称搜索标记

      # 按用户或用户名查询
      scope.searchSubscrbe = @commonService.subscribeEventBus 'search',(d)=>
        console.log d  # 根据d过滤数据
        text = d.message
        if !d.message   # 展示所有数据
          scope.searchFlag = false
          scope.garddatas2 = scope.garddatas
#          scope.processData()
        else     # 展示过滤后的数据
          scope.searchFlag = true
          _data = []
          for item in scope.garddatas
            if item.user.toLowerCase().indexOf(text) >= 0 || item.name.toLowerCase().indexOf(text) >= 0
              _data.push item
          scope.garddatas2 = _data


      scope.checkAdmin = ()=>
        if @logonUser.user != 'admin'
          @display "请使用超级管理员访问"
          return

      # 查询数据库users表
      (scope.queryUsers=()=>
        scope.checkAdmin()
        url = 'http://'+ @$window.location.host + "/model/clc/api/v1/users"
        $.get(url,{token:scope.token},(data)->
          console.log data._err if data._err
          scope.users = data
          sortDataArray = (_.sortBy scope.users,(dataAarrayItem)->
            dataAarrayItem.createtime = moment(dataAarrayItem.createtime).format("YYYY-MM-DD HH:mm:ss")
            return dataAarrayItem.createtime
          ).reverse()
          scope.garddatas = sortDataArray
          scope.pageIndex = 1
        )
      )()

      #     分页相关设置
      scope.filterEquipmentItem = ()=>
        return if not scope.garddatas
        items = []
        items = _.filter scope.garddatas, (equipment) =>
          if 3>2
            return true
          return false
        pageCount = Math.ceil(items.length / scope.pageItems)
        result = {page:1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      scope.selectPage = (page)=>
        scope.pageIndex = page

      scope.$watch 'pageIndex',(index)->
        startindex = scope.pageItems*(index-1)
        scope.garddatas2 = scope.garddatas?.slice(startindex,startindex+scope.pageItems)

      scope.exportReport=(header,name)=>
        reportName = name + "(" + moment().format("YYYY-MM-DD") + ").csv"
        @commonService.publishEventBus "export-report", {header:header, name:reportName}

    resize: (scope)->

    dispose: (scope)->


  exports =
    ReportUsersDirective: ReportUsersDirective