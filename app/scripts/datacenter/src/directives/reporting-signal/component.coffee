###
* File: reporting-signal-directive
* User: David
* Date: 2019/12/31
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'angularGrid','gl-datepicker'], (base, css, view, _, moment,agGrid,gl) ->
  class ReportingSignalDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "reporting-signal"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.historicalData = []
      scope.stations = []
      scope.header = [
        {headerName:"分区名称", field: 'stationName'},
        {headerName:"设备名称", field: 'equipment'}
        {headerName:"信号", field: 'signal'}
        {headerName:"信号值", field: 'value'}
        {headerName:"采集时间", field: 'sampleTime'}
      ]
      scope.noData = [
        {stationName:"暂无数据",equipment:"暂无数据",signal:"暂无数据",value:"暂无数据",createtime:"暂无数据"}
      ]
      @getstations(scope)
      @setTime(scope,element)
      @getSelectedDevice(scope)
      @getReportData(scope,1,50)
      @exportReport(scope,element)
      @setData(scope,scope.noData)
    #  设置选择时间
    setTime:(scope,element) =>
      scope.query =
        startTime : moment().format("YYYY-MM-DD")
        endTime : moment().format("YYYY-MM-DD")
      setGlDatePicker = (element,value)->
        return if not value
        setTimeout ->
          gl = $(element).glDatePicker({
            dowNames:["日","一","二","三","四","五","六"],
            monthNames:["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"],
            selectedDate: moment(value).toDate()
            onClick:(target,cell,date,data)->
              month = date.getMonth()+1
              if month < 10
                month = "0"+ month
              day = date.getDate()
              if day < 10
                day = "0"+ day
              target.val(date.getFullYear()+"-"+month+"-"+day).trigger("change")
          })
        ,500
      setGlDatePicker($('#start-time-input')[0],scope.query.startTime)
      setGlDatePicker($('#end-time-input')[0],scope.query.startTime)
    # 获取当前项目的所有站点集合
    getstations:(scope)=>
      scope.project.loadStations null, (err, stations)=>
        scope.stations = stations
   # 获取设备树选中的设备
    getSelectedDevice:(scope)=>
     @commonService.subscribeEventBus 'checkEquips',(msg)=>
        scope.selectedEquips = []
        return if not msg?.message.length
        stations = _.filter msg.message, (item)->item.level is "station"
        equipments = _.filter msg.message, (item)->item.level is "equipment" and item.station not in _.pluck(stations, "id")
        stations?.forEach (value)=>
          scope.selectedEquips.push value.id
        equipments?.forEach (value)=>
          scope.selectedEquips.push(value?.station+'.'+value?.id)
    # 校验是否为空
    checkFilter:(scope)=>
      if not scope.selectedEquips or (not scope.selectedEquips.length)
        M.toast({html: '请选择设备！'})
        return true
      if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
        M.toast({html: '开始时间大于结束时间！'})
        return true
      return false
    # 查数据库获取报表数据
    getReportData:(scope,page,pageItems)=>
      scope.getReportData = (a,page,pageItems)=>
        return if @checkFilter(scope)
        filter = scope.project.getIds()
        filter["$or"] = _.map scope.selectedEquips,(equip) =>return if equip.split(".").length>1 then {station:equip.split('.')[0], equipment:equip.split('.')[1]} else {station:equip.split('.')[0]}
        filter.startTime = moment(scope.query.startTime).startOf('day')
        filter.endTime = moment(scope.query.endTime).endOf('day')
        paging =
          page: page
          pageItems: pageItems
        data =
          filter: filter
          fields: null
          paging: paging
        @commonService.reportingService.querySignalRecords data, (err, records,paging2) =>
          for c in records
            for s in scope.stations
              if c.station == s.model.station
                c.stationName = s.model.name
          return @setData(scope,scope.noData) if (err or records.length < 1)
          pCount = paging2?.pageCount or 0
          if pCount <= 6
            paging2?.pages = [1..pCount]
          else if page > 3 and page < pCount-2
            paging2?.pages = [1, page-2, page-1, page, page+1, page+2, pCount]
          else if page <=3
            paging2?.pages = [1, 2, 3, 4, 5, 6, pCount]
          else if page >= pCount-2
            paging2?.pages = [1, pCount-5, pCount-4, pCount-3, pCount-2, pCount-1, pCount]
          scope.pagination = paging2
          @setData(scope,records)
      # 翻页
      scope.queryPage = (page) ->
        paging = scope.pagination
        return if not paging
        if page is 'next'
          page = paging.page + 1
        else if page is 'previous'
          page = paging.page - 1
        return if page > paging.pageCount or page < 1
        @getReportData(scope,page,paging.pageItems)
    # 导出表格填写查询到的内容并设置页面内容
    setData:(scope,data)=>
      return if not scope.gridOptions
      scope.historicalData = data
      scope.gridOptions.api.setRowData data
    # 导出
    exportReport:(scope,element)=>
      scope.gridOptions =
        columnDefs: scope.header
        rowData: null
        enableFilter: true
        enableSorting: true
        enableColResize: true
        overlayNoRowsTemplate: " "
        headerHeight:41
        rowHeight: 61
      new agGrid.Grid element.find("#grid")[0], scope.gridOptions
      scope.exportReport=(name)=>
        return if not scope.gridOptions
        reportName = name + "(" + moment(scope.query.startTime).format("YYYY-MM-DD") + "-" + moment(scope.query.endTime).format("YYYY-MM-DD") + ").csv"
        scope.gridOptions.api.exportDataAsCsv({fileName:reportName, allColumns: true, skipGroups:true})
    resize: (scope)->

    dispose: (scope)->


  exports =
    ReportingSignalDirective: ReportingSignalDirective