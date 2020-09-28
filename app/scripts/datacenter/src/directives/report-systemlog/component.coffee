###
* File: report-operations-directive
* User: David
* Date: 2019/01/05
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportSystemlogDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "report-systemlog"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.query =
        startTime : moment().format("YYYY-MM-DD")
        endTime : moment().format("YYYY-MM-DD")

      scope.garddatas = [
        {user:"暂无数据",type:"暂无数据",operation:"暂无数据",address:"暂无数据",timestamp:"暂无数据"}
      ]

      scope.header = [
        {headerName:"用户ID", field: 'user',width:90},
        {headerName:"类型", field: 'type',width:90},
        {headerName:"操作", field: 'operation'},
        {headerName:"访问地址", field: 'address'},
        {headerName:"开始时间", field: 'timestamp'}
      ]


      checkFilter=() ->
        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false

      scope.exportReport=(header,name)=>
        reportName = name + "(" + moment(scope.query.startTime).format("YYYY-MM-DD") + "-" + moment(scope.query.endTime).format("YYYY-MM-DD") + ").csv"
        @commonService.publishEventBus "export-report", {header:header, name:reportName}

      @timeSubscribe?.dispose()
      @timeSubscribe = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

      scope.getReportData = (page= 1 ,pageItems = 12)=>
        return if checkFilter()

        filter = {}
        filter.startTime = moment(scope.query.startTime).startOf('day')
        filter.endTime = moment(scope.query.endTime).endOf('day')
        paging =
          page: page
          pageItems: pageItems
        data =
          filter: filter
          fields: null
          paging: paging
          sorting: {
            timestamp: -1
          }

        @commonService.reportingService.queryRecords "reporting.operationrecords",data, (err, records, paging2) =>
          return console.log('err:',err) if err
          pCount = paging2.pageCount
          if pCount <= 6
            paging2?.pages = [1..pCount]
          else if page > 3 and page < pCount-2
            paging2?.pages = [1,page-2,page-1,page,page+1,page+2,pCount]
          else if page <=3
            paging2?.pages = [1,2,3,4,5,6,pCount]
          else if page >= pCount-2
            paging2?.pages = [1,pCount-5,pCount-4,pCount-3,pCount-2,pCount-1,pCount]
          scope.pagination = paging2

          sortDataArray = (_.sortBy records,(dataAarrayItem)->
            dataAarrayItem.timestamp = moment(dataAarrayItem.timestamp).format("YYYY-MM-DD HH:mm:ss")
            return dataAarrayItem.timestamp
          ).reverse()
          scope.garddatas = sortDataArray


      scope.queryPage=(page) =>
        paging = scope.pagination
        return if not paging

        if page is 'next'
          page = paging.page + 1
        else if page is 'previous'
          page = paging.page - 1

        return if page > paging.pageCount or page < 1

        scope.getReportData page, paging.pageItems


    resize: (scope)->

    dispose: (scope)->
      @timeSubscribe?.dispose()


  exports =
    ReportSystemlogDirective: ReportSystemlogDirective