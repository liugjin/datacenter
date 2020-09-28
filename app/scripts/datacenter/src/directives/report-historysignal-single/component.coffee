###
* File: report-historysignal-single-directive
* User: David
* Date: 2020/02/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportHistorysignalSingleDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "report-historysignal-single"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      第一版本针对一种设备，信号id数组来自传参数，
#      此版针对单个设备 选择设备后 从属性中得到信号列表 选择信号查询此设备此信号报表
      scope.multiflag = null
      scope.view = false
      scope.viewName = "报表"
      scope.reportName = ""
      scope.selectSignals = []
      scope.excelDatas = [] # 要导出的excel数据
      scope.signalShow = false
      scope.selectedPage = 1
      scope.pagination = null
      scope.query = {
        startTime:''
        endTime:''
      }
      # 初始化表头
      initHeaders = () -> (
        scope.headers = [
          {headerName:"序号", field: "index"},
          {headerName:"设备名称", field: "equipmentName"},
          {headerName:"采集时间", field: "sampleTime"}
        ]
      )
      initHeaders()
      scope.showSignal = () => (
        scope.signalShow = true
      )
      scope.garddatas = [
        {index:"暂无数据",stationName:"暂无数据",equipmentName:"暂无数据",signalName:"",unitName:"",value:"",sampleTime:""}
      ]
#      图表数据构造barlinevalue对象 publisheventbusfang传到组件
      scope.barlinevalue = [
#        {name:"能耗信号1", key:'2016-01-01', value:20, type:'line'},
#        {name:"能耗信号1", key:'2016-01-02', value:22, type:'line'},
#        {name:"能耗信号2", key:'2016-01-01', value:40, type:'bar'},
#        {name:"能耗信号2", key:'2016-01-02', value:42, type:'bar'}
      ]
      # 初始化信号状态
      scope.initSignalStatus = () => (
        _.each(scope.signals, (signal, num)->
          if(num == 0)
            signal.checked = true
          else
            signal?.checked = false
        )
        scope.$applyAsync()
      )
      scope.queryPage=(page)->(
        return if page < 1 or page > scope.pagination.pageCount
        scope.selectedPage = page
        scope.queryReport(scope.selectedPage)
      )
      # 切换视图
      scope.switchView = (boolean) =>
        # scope.view = !scope.view
        scope.view = boolean

      scope.selectSignal = (sig)=>
        # 删除多余的信号和未选择的信号
        deleteUnselectSignal = () => (
          scope.selectSignals = _.filter(scope.selectSignals, (selectSignal) ->
            selectSignal.model.signal != sig.model.signal
          )
        )
        if(sig.checked == true)
          scope.selectSignals.push(sig)
          if(scope.selectSignals.length > 3) # 选择的信号大于三个时不查数据
            deleteUnselectSignal()
            sig.checked = false
            @display "选择的信号不能超过3个！"
            return
        else
          deleteUnselectSignal()
        scope.queryReport()

      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

      scope.selectEquipSubscription?.dispose()
      scope.selectEquipSubscription = @commonService.subscribeEventBus 'selectEquip',(msg)=>
        scope.initSignalStatus()
        scope.multiflag = false
        scope.selectedEquips = [msg.message]
        scope.selectedEquips = _.filter scope.selectedEquips,(item)=>
          item.level == 'equipment'
        if scope.parameters.type is "signal"
          scope.reportName = "历史信号记录表"
        loadEquipmentAndSignals scope.selectedEquips,(data)=>
#            如果是单个设备 data(scope.signals)就是此设备的所有信号
          scope.signals[0].checked = true
          scope.selectSignals = [scope.signals[0]]
#          选中设备后自动查询当天的数据
          if scope.selectSignals.length
            scope.queryReport()

      scope.$watch 'barlinevalue',(value)=>
        @commonService.publishEventBus 'barlinevalue',value

      loadEquipmentAndSignals= (equipments,callback)=>
        scope.equipments=[]
        scope.signals = []
#        index = 0
        for equip in equipments
          if equip.level is 'equipment'
            stationId = equip.station
            equipmentId=equip.id
            for station in scope.project.stations.items
              if(station?.model.station is stationId)
                @commonService.loadEquipmentById station,equipmentId,(err,equipment)=>
                  return console.log("err:",err) if err
                  scope.equipments.push(equipment)
                  equipment.loadSignals null, (err, model) =>
#                    江川项目 加载出model里信号有重复，未找到根本原因，暂时用数组去重方式处理
                    return console.log("err:",err) if err
                    finalData = _.uniq model
                    scope.signals = _.filter finalData,(sig)=>
                      sig.model.visible is true
                    callback? true

      checkFilter =()->
        if not scope.selectedEquips or (not scope.selectedEquips.length)
          M.toast({html:'请选择设备'})
          return true
        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false
      # 处理历史数据数据
      processTableData = (allRecords) => (
        tableDatas = [] # 用来储存表格
        excelDatas = [] # 导出excel表格的数据
        sampleTimeArr = [] # 采集时间集合,用来制作时间轴
        lineChartsDatas = [] # 线形图的数据
        selectSignalsName = [] # 选中的信号名集合
        # 整理表头
        initHeaders()
        _.each(scope.selectSignals, (signal) ->
          name = signal.model.name
          field = signal.model.signal
          scope.headers.push({ headerName:name, field: field})
        )
        # 时间轴的制作
        _.each(allRecords, (record)->
          sampleTimeArr.push(record.timestamp)
          record.sampleTime = moment(record.timestamp).format("YYYY-MM-DD HH:mm:ss")
        )
        sampleTimeArr = _.sortBy(sampleTimeArr)
        sampleTimeArr = _.map(sampleTimeArr, (time)->moment(time).format("YYYY-MM-DD HH:mm:ss"))
        sampleTimeArr = _.uniq(sampleTimeArr)
        # 写上序号,设备名称和采集时间
        equipmentName = getEquipmentName(scope.selectSignals[0].station.model.station + "." + scope.selectSignals[0].equipment.model.equipment)
        _.each(sampleTimeArr, (sampleTime,count)->
          tableDatas.push({index: count, sampleTime: sampleTime, equipmentName: equipmentName})
          excelDatas.push({"序号": count,"设备名称": equipmentName, "采集时间": sampleTime})
        )
        # 在表格数据里填上数字
        _.each(tableDatas, (tableData)->
          _.each(allRecords, (record, count)->
            if ( record.sampleTime == tableData.sampleTime )
              #if(record.signal =="_alarms" || record.signal == "_severity")
              if(record.signal =="_alarms" || record.signal == "_severity")
                tableData[record.signal] = record.value
              else
                if record.dataType is 'enum'  # 修复枚举数据类型展示结果带有小数点的问题(ID1002773号BUG)
                  tableData[record.signal] = (record.value) + (record.unitName || "")
                else
                  tableData[record.signal] = (record.value).toFixed(2) + (record.unitName || "")
          )
        )
        # 渲染列表
        scope.garddatas = tableDatas

        # 制作要导出的excel数据
        _.each(excelDatas, (data)->
          _.each(allRecords, (record) ->
            if ( record.sampleTime == data["采集时间"] )
              nowSignale = _.find(scope.selectSignals, (signal)-> record.signal == signal?.model?.signal)
              if(nowSignale)
                signalName = nowSignale.model.name
                if(record.signal =="_alarms" || record.signal == "_severity")
                  data[signalName] = record.value
                  data[signalName + "(图表)"] = record.value # 图表模式取这个数据
                else
                  data[signalName] = (record.value).toFixed(2) + (record.unitName || "")
                  data[signalName + "(图表)"] = (record.value).toFixed(2) # 图表模式取这个数据
          )
        )
        # 得到excel表格
        scope.excelDatas = excelDatas
        # 制作图表
        _.each(scope.selectSignals, (signal)->
          selectSignalsName.push(signal.model.name)
        )
        # 不管它在时间轴上有没有值都填上空白,方便后面填数字
        _.each(selectSignalsName, (selectSignalName)->
          _.each(sampleTimeArr, (sampleTime)->
            lineChartsDatas.push({
                name: selectSignalName,
                key: sampleTime,
                value: "",
                type: "line",
                unitName: ""
            })
          )
        )
        # 在空白的地方填上数字
        _.each(lineChartsDatas, (lineChartsData)->
          _.each(excelDatas, (data)->
            dataName = lineChartsData.name
            dataTime = data["采集时间"]
            if(lineChartsData.key == dataTime && lineChartsData.name == dataName)
              lineChartsData.value = data[dataName + "(图表)"]
          )
        )
        # 图表渲染
        scope.barlinevalue = lineChartsDatas
      )
      scope.queryReport = (page=1,pageItems=scope.parameters.pageItems)=>(
        return if checkFilter()
        selectSignalsLength = scope.selectSignals.length
        # 如果没有选择信号,则让表格为空并且不执行
        if(selectSignalsLength == 0)
          scope.garddatas = []
          scope.excelDatas = []
          scope.$applyAsync()
          return
        filter = scope.project.getIds()
        filter.station = scope.selectedEquips[0].station
        filter.equipment = scope.selectedEquips[0].id
        filter.startTime = scope.query.startTime
        filter.endTime = scope.query.endTime
        filter.signal = { $in: _.map(scope.selectSignals, (s) -> s.model.signal) } 
        if pageItems
          paging = {
            page: page
            pageItems: pageItems
          }
        data = {
          filter: filter
          sorting: { station: 1, equipment:1, timestamp: 1}
          paging: paging
        }
        @commonService.reportingService.querySignalRecords(data,(err,records,paging2) => (
          return console.log('err:',err) if err
          scope.pagination = paging2
          scope.pagination.pages = [1..paging2.pageCount]
          processTableData(records)
        ))
      )

      getEquipmentName=(equipmentId) ->
        tempEquipment = equipmentId.split('.')
        for item in scope.equipments
          if item.model.equipment == tempEquipment[1] && item.model.station == tempEquipment[0]
            return item.model.name
        return equipmentId

      scope.exportReport = (headers,garddatas,name)=>
#        接收一个数组对象导出xlsx表
        if ( scope.excelDatas.length == 0 )
          return @display "暂无数据，无法导出！"
        wb = @$window.XLSX.utils.book_new()
        ws = @$window.XLSX.utils.json_to_sheet(scope.excelDatas)
        @$window.XLSX.utils.book_append_sheet(wb, ws, "Presidents")
        reportName = name+moment().format("YYYYMMDDHHmmss")+".xlsx"
        @$window.XLSX.writeFile(wb, reportName)

    resize: (scope)->

    dispose: (scope)->
      scope.initSignalStatus()
      scope.timeSubscription?.dispose()
      scope.selectEquipSubscription?.dispose()


  exports =
    ReportHistorysignalSingleDirective: ReportHistorysignalSingleDirective