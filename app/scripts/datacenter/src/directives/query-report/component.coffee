###
* File: query-report-directive
* User: David
* Date: 2018/11/12
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ["jquery",'../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'angularGrid','gl-datepicker'], ($,base, css, view, _, moment,agGrid,gl) ->
  class QueryReportDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "query-report"
      @$timeout = $timeout

    setScope: ->
      type:"@"

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      window.debugR = scope
      scope.selectedEquips = []
      scope.query =
        startTime : moment().format("YYYY-MM-DD")
        endTime : moment().format("YYYY-MM-DD")

      dataArray = [
        {stationName:"暂无数据",equipmentName:"暂无数据"}
      ]

      switch scope.parameters.type
        when 'alarm'
          scope.header = [
            {headerName: "告警级别", field: "severityName"},
            {headerName: "站点名称", field: "stationName"},
            {headerName: "设备名称", field: "equipmentName"},
            {headerName: "告警名称", field: "title"}
            {headerName: "开始值", field: "startValue"}
            {headerName: "结束值", field: "endValue"}
            {headerName: "总时长", field: "continuedTime"}
            {headerName: "开始时间", field: "startTime"}
            {headerName: "结束时间", field: "endTime"}
          ]
        when 'signal'
          scope.header = [
            {headerName:"站点名称", field: 'stationName'},
            {headerName:"设备名称", field: 'equipmentName'},
            {headerName:"信号",     field: 'signalName'},
            {headerName:"信号值", field: 'value'},
            {headerName:"单位", field: 'unitName'},
            {headerName:"采集时间", field: 'sampleTime'}
          ]
        else
          scope.header = [
            {headerName:"站点", field: 'stationName'},
            {headerName:"设备", field: 'equipmentName'}
          ]

      loadEquipmentAndSignals=(equipments)=>
        scope.equipments=[]
        scope.signals = []
        for equip in equipments
          stationId = equip.split('.')[0]
          equipmentId=equip.split('.')[1]
          for station in scope.project.stations.items
            if(station?.model.station is stationId)
              @commonService.loadEquipmentById station,equipmentId,(err,equipment)=>
                return console.log("err:",err) if err
                scope.equipments.push(equipment)
                equipment.loadSignals null, (err, model) =>
                  return console.log("err:",err) if err
                  for signal in model
                    scope.signals.push signal

      createGridOptions = (header) ->
        gridOptions =
          columnDefs: header
          rowData: null
          enableFilter: true
          enableSorting: true
          enableColResize: true
          overlayNoRowsTemplate: " "
          headerHeight:41
          rowHeight: 61

      setHeader = (header) ->
        return if not header or not gridOptions
        scope.header = header
#        gridOptions.api.setColumnDefs header
#        gridOptions.api.sizeColumnsToFit() if header?.length <= 7
      setData = (data)->
        return if not gridOptions
        scope.data = data
#        gridOptions.api.setRowData data

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
#        $(element).val(moment(value).format("YYYY-MM-DD"))

      #注意格式，["shenzhen.inverter","shenzhen.inverter-0"]

      checkFilter=() ->
        if not scope.selectedEquips or (not scope.selectedEquips.length)
          M.toast({html: '请选择设备！'})
          return true

        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false

      scope.exportReport=(name)->
        return if not gridOptions
        reportName = name+moment().format("YYYYMMDDHHmmss")+".csv"
        gridOptions.api.exportDataAsCsv({fileName:reportName, allColumns: true, skipGroups:true})

      queryAlarms =(page= 1 ,pageItems = 50)=>
        return if checkFilter()
        filter = scope.project.getIds()
        filter["$or"] = _.map scope.selectedEquips,(equip) ->return if equip.split(".").length>1 then {station:equip.split('.')[0], equipment:equip.split('.')[1]} else {station:equip.split('.')[0]}
        filter.startTime = moment(scope.query.startTime).startOf('day')
        filter.endTime = moment(scope.query.endTime).endOf('day')
        paging =
          page: page
          pageItems: pageItems
        data =
          filter: filter
          fields: null
          paging: paging

        @commonService.reportingService.queryEventRecords data, (err, records, paging2) =>
#          return console.log('err:',err) if err
          return setData(null) if (err or records.length < 1)
          #          console.log records
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

          tmprecords = _.map records, (record) =>
            if _.isEmpty record.endTime
              record.continuedTime = @calTimes(moment().diff moment(record.startTime, 'YYYY-MM-DD HH:mm:ss'), 'seconds')
              record.startTime = moment(record.startTime).format('YYYY-MM-DD HH:mm:ss')
            else
              record.continuedTime = @calTimes(moment(record.endTime,"YYYY-MM-DD HH:mm:ss").diff moment(record.startTime, 'YYYY-MM-DD HH:mm:ss'), 'seconds')
              record.startTime = moment(record.startTime).format('YYYY-MM-DD HH:mm:ss')
              record.endTime = moment(record.endTime).format('YYYY-MM-DD HH:mm:ss')
            record
#          records = _.map records,(record)=>
#            record = _.extend record,{startTime: moment(record.startTime).format('YYYY-MM-DD hh:mm:ss'),endTime: moment(record.endTime).format('YYYY-MM-DD hh:mm:ss')}

          dataArray = tmprecords
          setData( dataArray)


      querySignal = (page= 1 ,pageItems = 50)=>
        return if checkFilter()

        filter = scope.project.getIds()
        filter["$or"] = _.map scope.selectedEquips,(equip) ->return if equip.split(".").length>1 then {station:equip.split('.')[0], equipment:equip.split('.')[1]} else {station:equip.split('.')[0]}
        filter.startTime = moment(scope.query.startTime).startOf('day')
        filter.endTime = moment(scope.query.endTime).endOf('day')
        paging =
          page: page
          pageItems: pageItems
        data =
          filter: filter
          fields: null
          paging: paging
        @commonService.reportingService.querySignalRecords data, (err, records, paging2) =>
#          return console.log('err:',err) if err
          return setData(null) if (err or records.length < 1)
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
          formatData(dataArray)
          setData( dataArray)

      scope.queryPage = (page) ->
        paging = scope.pagination
        return if not paging

        if page is 'next'
          page = paging.page + 1
        else if page is 'previous'
          page = paging.page - 1

        return if page > paging.pageCount or page < 1
        if scope.parameters.type == 'signal'
          querySignal page, paging.pageItems
        else if scope.parameters.type == 'alarm'
          queryAlarms page, paging.pageItems
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

      scope.queryReport=(type)->
        switch type
          when "alarm"
            queryAlarms()
          when "signal"
            querySignal()
          else
            console.log("err:query type is error. ",type)

      getUnit=(unitid)->
        return '' if not unitid
        for item in scope.project.dictionary?.signaltypes.items
          unitItem = item.model
          if unitItem.type == unitid
            return unitItem.unit
        return unitid

      formatData=(records=[]) ->
        finalData = []
        finalData = _.map records, (record) =>
          _.extend record, {unitName: getUnit(record.unit),stationName:getStationName(record.station),equipmentName:getEquipmentName(record.station+"."+record.equipment),value:record.value?.toFixed(2),signalName:getSignalName(record.signal),sampleTime:moment(record.timestamp).format("YYYY-MM-DD HH:mm:ss")}

        return finalData

      gridOptions = createGridOptions scope.header
#      new agGrid.Grid element.find("#grid")[0], gridOptions
      setHeader(scope.header)
      setData(dataArray)
      setGlDatePicker($('#start-time-input')[0],scope.query.startTime)
      setGlDatePicker($('#end-time-input')[0],scope.query.startTime)

      #注意selectedEquips格式，是“站点.设备”的数组：["shenzhen.inverter","shenzhen.inverter-0"]
      @commonService.subscribeEventBus 'checkEquips',(msg)=>
#        scope.selectedEquips = msg.message
        # device-tree 的接口与旧的不一样，这里转换成旧格式以兼容旧代码
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

    calTimes:(refTime)->
      sTime = ""
      days = Math.floor(refTime/86400)
      daysY = refTime%86400
      hours = Math.floor(daysY/3600)
      hoursY = daysY%3600
      mins = Math.floor(hoursY/60)
      minY = hoursY%60
      if days > 0
        sTime = sTime + days + "天 "
      else
        sTime = "0天 "

      if hours > 0
        sTime = sTime + hours + "时 "
      else
        sTime = sTime + "0时 "

      if mins > 0
        sTime = sTime + mins + "分 "
      else
        sTime = sTime + "0分 "

      if minY > 0
        sTime = sTime + minY + "秒"
      else
        sTime = sTime + "0秒"
      return sTime

    resize: ()->
      gridOptions?.api.refreshView()

    dispose: (scope)->


  exports =
    QueryReportDirective: QueryReportDirective