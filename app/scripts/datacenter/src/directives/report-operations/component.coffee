###
* File: report-operations-leon-directive
* User: David
* Date: 2019/08/20
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportOperationsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService,@$http)->
      @id = "report-operations"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.token = scope.controller?.$rootScope?.user?.token
#      scope.token = '7573d950-1e34-11e9-bebf-d13e538ab552'
      scope.pageItems = scope.parameters.pageItems || 10
      scope.pageIndex = 0
      scope.actions =[
        {action:'create',actionName:'新建'}
        {action:'update',actionName:'修改'}
        {action:'delete',actionName:'删除'}
      ]
      scope.currentAction = {action:'all',actionName:'全部操作'}
      scope.garddatas = [
        {index:'',type:"暂无数据",action:"暂无数据",user:"暂无数据",project:"暂无数据",station:"暂无数据",equipment:"暂无数据",updatetime:"暂无数据"}
      ]
      scope.header = [
#        {headerName:"序号", field: 'index',width:90},
        {headerName:"类型", field: 'type',width:90},
        {headerName:"操作", field: 'action',width:90},
        {headerName:"站点", field: 'station'},
        {headerName:"设备", field: 'equipment'},
        {headerName:"时间", field: 'updatetime'}
      ]
      scope.query =
        startTime:''
        endTime:''

      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

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

      scope.selectAction = (d)->
        if d is 'all'
          scope.currentAction = {action:'all',actionName:'全部操作'}
        else
          scope.currentAction = d
      #        scope.queryLog scope.currentAction

      scope.queryLog = (para)->
# 查询数据库configurations报表数据    ["create", "update", "delete"]
        if para.action is 'all'
          action = {$in:["create", "update", "delete"]}
        else
          action = para.action
        #        console.log action
        $.get('getConfigurationInfo',{token: scope.token,type:'equipment',action:action},(data)->
#          console.log data.data
          scope.pageIndex = 1
          records = []
          index = 0
          _.map data.data,(item)->
            switch item.action
              when 'create'
                action2 = '新建'
              when 'update'
                action2 = '修改'
              when 'delete'
                action2 = '删除'
            if item.type is 'equipment'
              type = '设备'
            records.push {type:type,action:action2,user:item.topic.split('/')[0],project:item.topic.split('/')[1],station:scope.getStationName(item.topic.split('/')[2]),equipment:item.message.name,updatetime:item.message.updatetime} if moment(item.message.updatetime).isBetween(scope.query.startTime,scope.query.endTime)
          records = _.filter records,(record)->
            record.user is scope.project.model.user and record.project is scope.project.model.project
          # console.log(records)
          sortDataArray = (_.sortBy records,(dataAarrayItem)->
            dataAarrayItem.updatetime = moment(dataAarrayItem.updatetime).format("YYYY-MM-DD HH:mm:ss")
            return dataAarrayItem.updatetime
          ).reverse()
          scope.garddatas = sortDataArray
          scope.garddatas2 = scope.garddatas?.slice(0,scope.pageItems)
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
    ReportOperationsDirective: ReportOperationsDirective