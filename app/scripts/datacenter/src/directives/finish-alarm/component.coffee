###
* File: finish-alarm-directive
* User: David
* Date: 2020/01/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class FinishAlarmDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "finish-alarm"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      #查询告警记录： reportingService.queryEventRecords
      scope.paraName = scope.parameters.name
      paramsType = (scope.parameters.type).split(" ")

      scope.headers = [
        {headerName:"告警级别", field: "alarmRank"},
        {headerName:"站点名称", field: "stationName"},
        {headerName:"设备名称", field: "equipName"},
        {headerName:"告警名称", field: "alarmName"},
        {headerName:"开始值", field: "startVal"},
        {headerName:"结束值", field: "endVal"},
        {headerName:"开始时间", field: "startTime"}
        {headerName:"结束时间", field: "endTime"}
        {headerName:"持续时间", field: "sustain"}
      ]
      scope.gardAllData = [] #导出使用
      scope.gardData = [] #传入使用

      scope.allPageCount = 0 #查询出来的总数
      scope.thePageNumber = 0 #初始化页数



      esAllStation = []
      scope.query =
        startTime:''
        endTime:''

      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')


      scope.selectEquipSubscription?.dispose()
      scope.selectEquipSubscription = @commonService.subscribeEventBus "checkEquips",(msg)=>
        esAllStation = msg.message

      checkFilter= ()=>
        if not esAllStation or (not esAllStation.length)
          M.toast({html: '请选择设备！'})
          return true

        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false

      checkMsg = (allData, pageNumber)=>
        scope.gardData = (_.chunk(allData, 10))[pageNumber]

      #查询
      scope.queryReport = ()=>
        return if checkFilter()
        levEquip = _.uniq (_.map (_.filter esAllStation,(ef)=> ef.level isnt "station"),(mf)=> return mf.id)
        levSta = _.uniq (_.map (_.filter esAllStation,(ef)=> ef.level isnt "station"),(mf)=> return mf.station)

        filterGetPro = {
          user: scope.project.model.user
          project: scope.project.model.project
          station: { $in: levSta }
          startTime: (moment(scope.query.startTime).format("YYYY-MM-DD")) + " 00:00"
          endTime: (moment(scope.query.endTime).format("YYYY-MM-DD"))+ " 23:59"
          phase: { $in: paramsType }
        }

        dataFilter = {
          filter: filterGetPro
          paging: null
          sorting: null
        }

        eStart = ""
        eEnd = ""
        eCall = ""

        @commonService.reportingService.queryEventRecords dataFilter, (err, records) =>
          if records
            levCords = _.filter records,(res)=> res.equipment in levEquip

            _.each levCords,(lev)=>
              _eStart = _.clone(eStart)
              _eEnd = _.clone(eEnd)
              _est = _.clone(lev)
              _eCall = _.clone(eCall)

              _eStart = lev.startTime
              _eEnd = lev.endTime

              if !_eEnd
                _eEnd = ""
                _eCall = ""
              else
                _eEnd = moment(_eEnd).format("YYYY-MM-DD HH:mm:ss")
                _callTime = @calTimes(moment(_est.endTime,"YYYY-MM-DD HH:mm:ss").diff moment(_est.startTime, 'YYYY-MM-DD HH:mm:ss'), 'seconds')

              scope.gardAllData.push({ #gardAllData gardData
                alarmRank: _est.severityName
                stationName: _est.stationName
                equipName: _est.equipmentName
                alarmName: _est.title
                startVal: _est.startValue || ""
                endVal: _est.endValue || ""
                startTime: moment(_eStart).format("YYYY-MM-DD HH:mm:ss")
                endTime: _eEnd
                sustain: _callTime
              })

            scope.allPageCount = scope.gardAllData.length

            checkMsg(scope.gardAllData, scope.thePageNumber)

            #切换底部页数
            scope.comPageBus?.dispose()
            scope.comPageBus = @commonService.subscribeEventBus 'pageTemplate',(msg)=>
              message = msg.message - 1
              checkMsg(scope.gardAllData, message)
          else
            scope.gardData = []
            scope.gardAllData = []

      #导出
      scope.exportReport = (paramTitle)=>
        if scope.gardAllData.length == 0
          @display null, '暂无数据', 1500
          return false

        wb = XLSX.utils.book_new();
        excel = XLSX.utils.json_to_sheet(scope.gardAllData)
        XLSX.utils.book_append_sheet(wb, excel, "Sheet1")
        XLSX.writeFile(wb, paramTitle + "-" + moment().format('YYYYMMDDHHMMSS') + ".xlsx")

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

    dispose: (scope)->
      scope.timeSubscription?.dispose()


  exports =
    FinishAlarmDirective: FinishAlarmDirective