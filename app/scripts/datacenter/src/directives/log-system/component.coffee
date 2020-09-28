###
* File: report-operations-leon-directive
* User: David
* Date: 2019/08/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class LogSystemDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService,@$http)->
      @id = "log-system"
      super $timeout, $window, $compile, $routeParams, commonService
      @configService = commonService.modelEngine.modelManager.getService("configurations")  #configService方法不行 改用后台接口getConfigurationInfo方法查询数据库

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 系统日志 查询当前用户有权限站点的设备的增删改记录 查询当前用户的登录记录
#      console.log 'scope',scope
      scope.token = scope.controller?.$rootScope?.user?.token
      scope.userLoginTopic = scope.controller?.$rootScope?.user?.user + "/login/" + scope.controller?.$rootScope?.user?.token   #验证查询登录用户的登录记录（如果是admin可以查询所以用户的）
      scope.pageItems = scope.parameters.pageItems || 10
      scope.pageIndex = 0
      scope.actions =[
        {action:'create',actionName:'新建'}
        {action:'update',actionName:'修改'}
        {action:'delete',actionName:'删除'}
      ]
      scope.currentAction = {
        action:'all',
        actionName:'全部操作',
      }
      scope.garddatas = [
        {index:'',type:"暂无数据",user:"用户名",action:"暂无数据",user:"暂无数据",project:"暂无数据",operation:"暂无数据",address:"暂无数据",updatetime:"暂无数据"}
      ]
      scope.header = [
#        {headerName:"序号", field: 'index',width:90},
#        {headerName:"类型", field: 'type',width:90},
        {headerName:"用户名", field: 'user',width:90},
        {headerName:"操作类型", field: 'action',width:90},
#        {headerName:"站点", field: 'station'},
#        {headerName:"设备", field: 'equipment'},
        {headerName:"操作内容", field: 'operation'},
        {headerName:"访问地址", field: 'address'},
        {headerName:"时间", field: 'updatetime'}
      ]
      scope.query =
        startTime:''
        endTime:''
        startTime : moment().subtract(7,"days").startOf('day').format()
        endTime :moment().endOf('day').format()

      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day').format()
        scope.query.endTime = moment(d.message.endTime).endOf('day').format()

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

#      scope.selectAction = (d)->
#        if d is 'all'
#          scope.currentAction = {action:'all',actionName:'全部操作'}
#        else
#          scope.currentAction = d

      scope.checkTime = ()->
        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false

      scope.initData = ()->
        scope.$root.loading = true
        scope.pageIndex = 0
        scope.garddatas = []
        scope.garddatas2 = []

      scope.queryLog = (para)=>
        # 查询数据库configurations报表数据    ["create", "update", "delete"]            点击查询时把表数据清空
        return if scope.checkTime()
        scope.initData()
        if para.action is 'all'
          action = {$in:["create", "update", "delete"]}
        else
          action = para.action
        #        console.log action
#        $.get('getConfigurationInfo',{token: scope.token,startTime:scope.query.startTime,endTime:scope.query.endTime},(data)->
        # 改用rpc 接口方式
        options = {token: scope.token,startTime:scope.query.startTime,endTime:scope.query.endTime}
        @commonService.rpcGet('getConfigurationInfo',options,(err,data)=>
          console.log err if err
          #          console.log 'data:',data
          scope.pageIndex = 1
          records = []
          index = 0
          if data.data.data.length == 0
            scope.garddatas2 = []
            scope.$root.loading = false
            return
          _.map data.data.data,(item)->
            if item.type is 'equipment'
              switch item.action
                when 'create'
                  action2 = '新建设备'
                  type = '设备'
                when 'update'
                  action2 = '修改设备'
                  type = '设备'
                when 'delete'
                  action2 = '删除设备'
                  type = '设备'
              if scope.controller.role.stations
                if (item.topic.split('/')[2] in scope.controller.role.stations) or scope.controller.role.stations?.indexOf('_all')>-1    # 只保留当前登录用户有权限的站点设备增删改记录
                  operation = scope.getStationName(item.topic.split('/')[2]) + "/" + item.message.name
                  records.push {type:type,action:action2,user:item.topic.split('/')[0],project:item.topic.split('/')[1],operation:operation,address:item.message.address || "未知地址",updatetime:item.updatetime}
            else if item.type is 'operation'
              if scope.controller.$rootScope.user.user is 'admin'
                if item.topic.indexOf('login')!=-1   #当前登录用户是admin 显示所有的登录记录
                  type = '登录'
                  action2 = '用户登录'
                  records.push {type:type,action:action2,user:item.topic.split('/')[0],project:'',operation:'用户登录',address:item.message.address,updatetime:item.updatetime}
              else
                if  item.topic is scope.userLoginTopic   # 当前登录用户不是admin 只显示当前登录用户的登录记录
                  type = '登录'
                  action2 = '用户登录'
                  records.push {type:type,action:action2,user:item.topic.split('/')[0],project:'',operation:'用户登录',address:item.message.address,updatetime:item.updatetime}
          records = _.filter records,(record)->
            record.user is scope.project.model.user and record.project is scope.project.model.project || record.type is '登录'
#          console.log records
          sortDataArray = (_.sortBy records,(dataAarrayItem)->
            dataAarrayItem.updatetime = moment(dataAarrayItem.updatetime).format("YYYY-MM-DD HH:mm:ss")
            return dataAarrayItem.updatetime
          ).reverse()
          scope.garddatas = sortDataArray
          scope.garddatas2 = scope.garddatas?.slice(0,scope.pageItems)
          scope.$root.loading = false
          scope.$applyAsync()

        )
      @$timeout ()->
        scope.queryLog scope.currentAction
      ,500

      scope.exportReport= (header,name)=>
        reportName = name+moment().format("YYYYMMDDHHmmss")+".csv"
        @commonService.publishEventBus "export-report", {header:header, name:reportName}

      scope.getStationName = (stationId) ->
        for item in  scope.project.stations.items
          if item.model.station==stationId
            return item.model.name
        return stationId


    resize: (scope)->

    dispose: (scope)->
      scope.timeSubscription?.dispose()

  exports =
    LogSystemDirective: LogSystemDirective