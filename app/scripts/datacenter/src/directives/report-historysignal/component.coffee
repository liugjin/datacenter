###
* File: report-historysignal-directive
* User: David
* Date: 2019/01/03
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportHistorysignalDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "report-historysignal"
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
      scope.viewName = "报表11"
      scope.reportName = ""
#      scope.selectSignals = [{signal:'test',signalName:'信号列表'}]
      scope.selectSignals = []
      scope.query =
        startTime:''
        endTime:''
      scope.headers = [
        {headerName:"序号", field: "index"},
        {headerName:"项目名称", field: "stationName"},
        {headerName:"设备名称", field: "equipmentName"},
        {headerName:"数据名称",     field: "signalName"},
        {headerName:"数据值", field: "value"},
        {headerName:"单位", field: "unitName"},
        {headerName:"采集时间", field: "sampleTime"}
      ]
      scope.garddatas = [
        {index:"暂无数据",stationName:"暂无数据",equipmentName:"暂无数据",signalName:"",unitName:"",value:"",sampleTime:""}
      ]
#      图表数据构造barlinevalue对象 publisheventbusfang传到组件
      scope.barlinevalue = [
        {name:"能耗信号1", key:'2016-01-01', value:20, type:'line'},
        {name:"能耗信号1", key:'2016-01-02', value:22, type:'line'},
        {name:"能耗信号3", key:'2016-01-01', value:40, type:'bar'},
        {name:"能耗信号34", key:'2016-01-02', value:42, type:'bar'}
      ]


      # 切换视图
      scope.switchView = () =>
        scope.view = !scope.view
        if scope.view
          scope.viewName = '图表'
        else
          scope.viewName = '报表'

      scope.selectSignal = (sig)->
        scope.selectSignals = [sig]
        scope.queryReport()
        $('#mysigs').hide()

      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

      scope.selectEquipSubscription?.dispose()
      scope.selectEquipSubscription = @commonService.subscribeEventBus 'selectEquip',(msg)=>
        scope.multiflag = false
        scope.selectedEquips = [msg.message]
        scope.selectedEquips = _.filter scope.selectedEquips,(item)=>
          item.level == 'equipment'
        if scope.parameters.type is "signal"
          scope.reportName = "历史信号记录表"
        loadEquipmentAndSignals scope.selectedEquips,(data)=>
#            如果是单个设备 data(scope.signals)就是此设备的所有信号
          scope.selectSignals = [scope.signals[0]]
#          选中设备后自动查询当天的数据
          if scope.selectSignals.length
            scope.queryReport()

#      scope.$watch 'property', (property)=>
#        scope.signals = []
#        scope.selectSignals = []
#        return if not property
#        _signals = JSON.parse(property.value)
#        mysignals = []
#        for s in _signals
#          item = _.find scope.equipment.signals.items, (item) -> item.model.signal is s.signal
#          scope.signals.push item if item
#        if not (scope.selectSignals.length)
#          scope.selectSignals = [scope.signals[0]]

      scope.$watch 'barlinevalue',(value)=>
        @commonService.publishEventBus 'barlinevalue',value

      loadEquipmentAndSignals= (equipments,callback)=>
        scope.equipments=[]
        scope.signals = []
#        index = 0
#        这里equipments 的length只能为1
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
                      sig.model.visible is true and sig.model.dataType in ['float','int','enum']
#                    for modelItem in model
#                      scope.signals.push modelItem
                    callback? true
#                    @getProperty scope,"_signals",()=>
#                      console.log "获取到设备属性,watch property得到信号列表"
#          index += 1
#          if index == equipments.length
#            setTimeout ()->
#              callback? scope.signals
#            ,500

      checkFilter =()->
        if not scope.selectedEquips or (not scope.selectedEquips.length)
          M.toast({html:'请选择设备'})
          return true
        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false

      # 过滤信号
      scope.filterSig = ()=>
        (equipment) =>
          if equipment.model.dataType in ["int","float","enum","string"]
            return true
          return false

      scope.queryReport = (page=1,pageItems=scope.parameters.pageItems)=>
        return if checkFilter()
        if scope.selectSignals[0]
          filter ={}
          filter["$or"] = _.map scope.selectedEquips,(equip) -> return {station:equip.station,equipment:equip.id}
          filter.startTime = scope.query.startTime
          filter.endTime = scope.query.endTime
          filter.user = scope.selectSignals[0].model.user
          filter.project = scope.selectSignals[0].model.project
          filter.signal = scope.selectSignals[0].model.signal
          # filter.mode= {"$nin":["communication","event"]}
          paging =
            page: page
            pageItems: pageItems
          data =
            filter: filter
#            paging: paging
            sorting: {station:1,equipment:1,timestamp:1}
          @commonService.reportingService.querySignalRecords data,(err,records,paging2) =>
            return console.log('err:',err) if err
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
            dataArray = records
            if !dataArray.length
              scope.barlinevalue = []
              scope.garddatas = []

            else
              if dataArray[0].dataType in ['int','float','enum']
                formatData dataArray,(d)=>
                  #得到格式化报表数据和图表数据
                  scope.garddatas = d
                  scope.barlinevalue = _.map scope.garddatas,(item)->
                    return item2 = {name: item.signalName,key: item.sampleTime,value: item.value,type: scope.parameters?.chartType||'line',unitName:item.unitName||""}
                  scope.barlinevalue = _.sortBy(scope.barlinevalue,'key')
                  scope.yname = scope.barlinevalue[0].unitName
              else
                @display('此报表仅支持数字数据信号查询！',500)

      formatData=(records,callback) ->
        finalData = null
        index = 0
        finalData = _.map records, (record) =>
          _.extend record, {index:index+1,unitName: getUnit(record.unit),stationName:getStationName(record.station),equipmentName:getEquipmentName(record.station+"."+record.equipment),value:record.value?.toFixed(2),signalName:getSignalName(record.signal),sampleTime:moment(record.timestamp).format("YYYY-MM-DD HH:mm:ss")}
          index++
          if index == records.length
            callback? records

      scope.queryPage = (page) ->
        paging = scope.pagination
        return if not paging

        if page is 'next'
          page = paging.page + 1
        else if page is 'previous'
          page = paging.page - 1

        return if page > paging.pageCount or page < 1
        if scope.parameters.type == 'signal'
          scope.queryReport page, paging.pageItems
        else if scope.parameters.type == 'alarm'
          scope.queryAlarms page, paging.pageItems
        else
          alert 'err'

      getStationName=(stationId) ->
        for item in  scope.project.stations.items
          if item.model.station==stationId
            return item.model.name
        return stationId

      getEquipmentName=(equipmentId) ->
        tempEquipment = equipmentId.split('.')
        for item in scope.equipments
          if item.model.equipment == tempEquipment[1] && item.model.station == tempEquipment[0]
            return item.model.name
        return equipmentId

      getSignalName=(signalId) ->
        for item in scope.signals
          if item.model.signal == signalId
            return item.model.name
        return signalId

      getUnit=(unitid)->
        return '' if not unitid
        for item in scope.project.dictionary?.signaltypes.items
          unitItem = item.model
          if unitItem.type == unitid
            return unitItem.unit
        return unitid

#      scope.exportReport= (header,name)=>
#        reportName = name+moment().format("YYYYMMDDHHmmss")+".csv"
#        @commonService.publishEventBus "export-report", {header:header, name:reportName}
      scope.exportReport = (header,garddatas,name)=>
#        接收一个数组对象导出xlsx表
        if garddatas[0].stationName == '暂无数据'
          return @display "暂无数据，无法导出！"
        data2 = _.map garddatas,(item)->
          return {"项目名称":item.stationName,"设备名称":item.equipmentName,"数据名称":item.signalName,"数据值":item.value,"单位":item.unitName,"采集时间":item.sampleTime}
#        console.log data2
        data = data2
        ws = XLSX.utils.json_to_sheet(data)
        wb = XLSX.utils.book_new()
        XLSX.utils.book_append_sheet(wb, ws, "Presidents")
        #      XLSX.writeFile(wb, "sheetjs.xlsx")
        reportName = name+moment().format("YYYYMMDDHHmmss")+".xlsx"
        XLSX.writeFile(wb, reportName)




    resize: (scope)->

    dispose: (scope)->
      scope.timeSubscription?.dispose()
      scope.selectEquipSubscription?.dispose()
#      scope.checkEquipsSubscription?.dispose()

  exports =
    ReportHistorysignalDirective: ReportHistorysignalDirective