###
* File: report-activeevents-directive
* User: David
* Date: 2019/12/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'angularGrid','gl-datepicker'], (base, css, view, _, moment,agGrid,gl) ->
  class ReportActiveeventsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "report-activeevents"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.historicalData = []
      scope.checkNews = {severity: 'all',phase: 'all'}
      scope.alarmStateArr = [{id:"start",name:"开始告警"},{id:"end",name:"结束告警"},{id:"confirm",name:"确认告警"}]
      scope.header = [
        {headerName:"告警级别", field: 'severityName'},
        {headerName:"告警状态", field: 'phaseName',},
        {headerName:"分区名称", field: 'stationName'},
        {headerName:"设备名称", field: 'equipmentName'}
        {headerName:"告警名称", field: 'eventName'}
        {headerName:"开始值", field: 'startValue'}
        {headerName:"结束值", field: 'endValue'}
        {headerName:"开始时间", field: 'startTime'}
        {headerName:"结束时间", field: 'endTime'}
      ]
      scope.noData = [
        {severityName:"暂无数据",phaseName:"暂无数据",stationName:"暂无数据",equipmentName:"暂无数据",eventName:"暂无数据",startValue:"暂无数据",endValue:"暂无数据",startTime:"暂无数据",endTime:"暂无数据"}
      ]
      @getAlarmLevels(scope)
      @setTime(scope,element)
      @getSelectedDevice(scope)
      @getReportData(scope)
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
    # 获取告警级别
    getAlarmLevels:(scope)=>
      scope.alarmLevels = []
      for alarmLevel in scope.project.typeModels.eventseverities.items
        alarmLevelData = {
          id: alarmLevel.model.severity
          name: alarmLevel.model.name
        }
        scope.alarmLevels.push alarmLevelData
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
        # 信号数据需要手动转换数据，所以先获取数据。
        if scope.parameters.type is "signal"
          loadEquipmentAndSignals scope.selectedEquips
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
    getReportData:(scope)=>
      scope.getReportData = ()=>
        return if @checkFilter(scope)
        filter = scope.project.getIds()
        filter["$or"] = _.map scope.selectedEquips,(equip) =>return if equip.split(".").length>1 then {station:equip.split('.')[0], equipment:equip.split('.')[1]} else {station:equip.split('.')[0]}
        filter.startTime = moment(scope.query.startTime).startOf('day')
        filter.endTime = moment(scope.query.endTime).endOf('day')
        if scope.checkNews.severity != "all" 
          filter.severity = scope.checkNews.severity
        if scope.checkNews.phase !="all"
          filter.phase = scope.checkNews.phase
        data =
          filter: filter
          fields:"severityName phaseName stationName equipmentName eventName startValue endValue startTime endTime"
        @commonService.reportingService.queryEventRecords data, (err, records) =>
          return @setData(scope,scope.noData) if (err or records.length < 1)
          @setData(scope,records)
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
    ReportActiveeventsDirective: ReportActiveeventsDirective