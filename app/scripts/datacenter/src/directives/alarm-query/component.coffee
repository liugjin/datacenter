###
* File: alarm-query-directive
* User: David
* Date: 2019/05/14
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "angularGrid"], (base, css, view, _, moment, agGrid) ->
  class AlarmQueryDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService,$translate)->
      @id = "alarm-query"
      super $timeout, $window, $compile, $routeParams, commonService,$translate
      @chartDataItems = []

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @equipSubscription?.dispose()
      @equipSubscription = @subscribeEventBus 'checkStations', (d) =>
        @checkStations = d.message

      @timeSubscription?.dispose()
      @timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        @queryTime = d.message

      scope.header = [
        {headerName:"站点名称", field: "stationName",width:90,cellStyle: {textAlign: "center"}}
        {headerName:"设备名称", field: "equipmentName",width:90,cellStyle: {textAlign: "center"}}
        {headerName:"开始时间", field:"startTime",width:80,cellStyle: {textAlign: "center"}}
        {headerName:"结束时间", field:"endTime",width:80,cellStyle: {textAlign: "center"}}
        {headerName:"状态", field:"status",width:60,cellStyle: {textAlign: "center"}}
        {headerName:"持续时长", field:"continuedTime",width:80,cellStyle: {textAlign: "center"}}
        {headerName:"描述",field: "title",cellStyle: {textAlign: "center"}}
      ]

      scope.selectType = (type) =>
        scope.eventsType = type
        @events = []
        if type is 'new'
          @getNewestEvents () =>
            @createGridTable scope,@events, element, type
        else
          @subProject?.dispose()
          @createGridTable scope,@chartDataItems, element, type

      scope.selectType 'new'
      checkFilter =()=>
        if not @checkStations
          M.toast({html:'请选择设备或站点'})
          return true
        if moment(@queryTime.startTime).isAfter moment(@queryTime.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false
      scope.queryAlarm =  (page= 1 ,pageItems = 2000)=>
        checkStations = []
        return if checkFilter()

        _.map @checkStations, (station) -> checkStations.push station.id

        @chartDataItems = []
        filter = @project.getIds()
        filter["$or"] = _.map checkStations,(equip) ->return {station:equip.split('.')[0], equipment:equip.split('.')[1]}
        filter["$or"] = _.map checkStations,(equip) ->return {station:equip.split('.')[0]}
        filter.startTime = moment(@queryTime.startTime).startOf('day')
        filter.endTime = moment(@queryTime.endTime).endOf('day')

        paging =
          page: page
          pageItems: pageItems

        data =
          filter: filter
          fields: null
          paging: paging
          sorting: {station:1,equipment:1,startTime: -1}

        scope.pagination = paging
        @commonService.reportingService.queryEventRecords data, (err, records, paging2) =>
          if records
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
            _.map(records,(rec)=>
              rec.startTime = moment(rec.startTime).format("YYYY-MM-DD HH:mm:ss")
              rec.status = @getPhase rec.phaseName
              if !_.isEmpty rec.endTime
                rec.endTime = moment(rec.endTime).format("YYYY-MM-DD HH:mm:ss")
                rec.continuedTime = @calTimes(moment(rec.endTime).diff moment(moment(rec.startTime).format("YYYY-MM-DD HH:mm:ss")  , 'YYYY-MM-DD HH:mm:ss'), 'seconds')
            )
            @chartDataItems = _.sortBy records,(recItem)->
              return -recItem.station+recItem.equipment+recItem.event+recItem.startTime
            @createGridTable scope,@chartDataItems, element, 'history'

      scope.queryPage=(page) =>
        paging = scope.pagination
        return if not paging

        if page is 'next'
          page = paging.page + 1
        else if page is 'previous'
          page = paging.page - 1

        return if page > paging.pageCount or page < 1

        scope.queryAlarm page, paging.pageItems

      scope.exportReport = (header,name)=>
        return if not scope.gridOptions
        reportName = name+moment().format("YYYYMMDDHHmmss")+".csv"
        scope.gridOptions.api.exportDataAsCsv({fileName:reportName, allColumns: true, skipGroups:true})

    getPhase:(phase)->
      if (phase is "completed") || (phase is "end") || (phase is "complete")
        return "已结束"
      else if (phase is "start")
        return "开始"
      else if (phase is "confirm") ||  (phase is "confirmed")
        return "已确认"
      else
        return phase
    getNewestEvents: (callback) =>
      activeEventObjs = {}
      filter =
        user: @project.model.user
        project: @project.model.project
      @subProject?.dispose()
      @subProject = @commonService.eventLiveSession.subscribeValues filter, (err,d) =>
        return if not d
        msg = d.message
        eventId = msg.station + "." + msg.equipment + "." + msg.event
        endTime = moment().format("YYYY-MM-DD HH:mm:ss")
        if !_.isEmpty msg.endTime
          endTime = moment(msg.endTime).format("YYYY-MM-DD HH:mm:ss")
        orderflag = ""
        tmpStatus = ""
        if _.isEmpty msg.confirmTime
          tmpStatus += '未确认'
          if msg.phase is 'end' or msg.phase is 'completed'
            tmpStatus += ',已结束'
            orderflag = "B" + moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss").toString()
          else
            tmpStatus += ',未结束'
            orderflag = "D" + moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss").toString()
          activeEventObjs[eventId] = {
            stationName: msg.stationName
            equipmentName: msg.equipmentName
            startTime: moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss")

            status: tmpStatus
            continuedTime: @calTimes(moment(endTime).diff moment(moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss")  , 'YYYY-MM-DD HH:mm:ss'), 'seconds')
            title: msg.title
            orderflag:orderflag
          }
        else
          tmpStatus += '已确认'
          if msg.phase is 'end' or msg.phase is 'completed'
            tmpStatus += ',已结束'
            orderflag = "A" + moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss").toString()
            delete activeEventObjs[eventId]
          else
            tmpStatus += ',未结束'
            orderflag = "C" + moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss").toString()
            activeEventObjs[eventId] = {
              stationName: msg.stationName
              equipmentName: msg.equipmentName
              startTime: moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss")
              status: tmpStatus
              continuedTime: @calTimes(moment(endTime).diff moment(moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss")  , 'YYYY-MM-DD HH:mm:ss'), 'seconds')
              title: msg.title
              orderflag:orderflag
            }

        tmpevents = []
        _.mapObject activeEventObjs,(val,key)=>
          tmpevents.push val

        @events = _.sortBy tmpevents,(evtItem)->
          return evtItem.orderflag

        callback?()

    createGridTable: (scope,data, element, type) =>
      scope.gridOptions =
        columnDefs: [
          {headerName:"站点名称", field: "stationName",width:90,cellStyle: {textAlign: "center"}}
          {headerName:"设备名称", field: "equipmentName",width:90,cellStyle: {textAlign: "center"}}
          {headerName:"开始时间", field:"startTime",width:80,cellStyle: {textAlign: "center"}}
          {headerName:"结束时间", field:"endTime",width:80,cellStyle: {textAlign: "center"}}
          {headerName:"状态", field:"status",width:60,cellStyle: {textAlign: "center"}}
          {headerName:"持续时长", field:"continuedTime",width:80,cellStyle: {textAlign: "center"}}
          {headerName:"描述",field: "title",cellStyle: {textAlign: "center"}}
        ]
        rowData: null
        enableFilter: true
        enableSorting: true
        enableColResize: true
        overlayNoRowsTemplate: "无数据"
        headerHeight:41
        rowHeight: 61

      @agrid?.destroy()
      @agrid = new agGrid.Grid element.find("##{type}")[0], scope.gridOptions
      scope.gridOptions.api.sizeColumnsToFit()
      scope.gridOptions.api.setRowData data

    #持续时间计算
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

    resize: (scope)->

    dispose: (scope) =>
      @subProject?.dispose()
      @equipSubscription?.dispose()
      @timeSubscription?.dispose()

  exports =
    AlarmQueryDirective: AlarmQueryDirective