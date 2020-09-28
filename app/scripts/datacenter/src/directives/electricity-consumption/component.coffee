###
* File: electricity-consumption-directive
* User: David
* Date: 2019/12/30
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'angularGrid','gl-datepicker'], (base, css, view, _, moment,agGrid,gl) ->
  class ElectricityConsumptionDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "electricity-consumption"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.historicalData = []
      scope.stations = []
      scope.checkNews = { station: ''}
      scope.header = [
        {headerName:"分区名称", field: 'station'},
        {headerName:"设备名称", field: 'equipment'},
        {headerName:"信号名称", field: 'signal'},
        {headerName:"单位", field: 'unit'},
        {headerName:"信号值",field: 'value'},
        {headerName:"差值", field: 'diff'}
        {headerName:"最小值", field: 'min'}
        {headerName:"最大值", field: 'max'}
        {headerName:"采集周期", field: 'period'}
        {headerName:"采集模式", field: 'mode'}
        {headerName:"采集时间", field: 'timestamp'}
      ]
      scope.noData = [
        {station:"暂无数据",equipment:"暂无数据",signal:"暂无数据",unit:"暂无数据",value:"暂无数据",diff:"暂无数据",min:"暂无数据",max:"暂无数据",period:"暂无数据",mode:"暂无数据",timestamp:"暂无数据"}
      ]
      @getstations(scope)
      @setTime(scope,element)
      @getReportData(scope)
      @exportReport(scope,element)
      @setData(scope,scope.noData)
    # 获取当前项目的所有站点集合
    getstations:(scope)=>
      scope.project.loadStations null, (err, stations)=>
        scope.checkNews.station = stations[0].model.station
        scope.stations = stations
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

    # 校验是否为空
    checkFilter:(scope)=>
      if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
        M.toast({html: '开始时间大于结束时间！'})
        return true
      return false

    # 查数据库获取报表数据
    getReportData:(scope)=>
      scope.getReportData = ()=>
        return if @checkFilter(scope)
        scope.historicalData.splice(0,scope.historicalData.length)
        filter =
          user: @$routeParams.user
          project: @$routeParams.project
          station: scope.checkNews.station
          equipment: '_station_efficient'
          signal: "power-value"
          period: {$gte:moment(scope.query.startTime).format("YYYY-MM-DD"), $lt:moment(scope.query.endTime).format("YYYY-MM-DD HH")}
          mode: "day"
        @commonService.reportingService.querySignalStatistics {filter:filter}, (err, records) =>
          return @setData(scope,scope.noData) if (err or records.length < 1)
          currentData = (_.values records)[0].values
          for c in currentData
            data = { station: null,equipment:null,signal:null,unit:null,value:null,diff:null,min:null,max:null,period:null,mode:null,timestamp:null}
            for s in scope.stations
              if scope.checkNews.station == s.model.station
                data.station = s.model.name
            data.equipment = "站点能耗设备"
            data.signal = "用电量"
            data.unit = "kWh"
            data.value = c.value
            data.diff = c.diff
            data.min = c.min
            data.max = c.max
            data.period = c.period
            data.mode = c.mode
            data.timestamp = c.timestamp
            scope.historicalData.push(data)
          @setData(scope,scope.historicalData)
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
    ElectricityConsumptionDirective: ElectricityConsumptionDirective