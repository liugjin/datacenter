###
* File: battery-alarm-directive
* User: David
* Date: 2019/12/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class BatteryAlarmDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "battery-alarm"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.headers = [
        {headerName:"站点名称", field: 'stationName'}
        {headerName:"设备名称", field: 'equipName'}
        {headerName:"告警级别", field: 'alarmSeverity'}
        {headerName:"告警名称", field: 'alarmName'}
        {headerName:"开始值", field: 'startVal'}
        {headerName:"结束值", field: 'endVal'}
        {headerName:"总时长", field: 'allTime'}
        {headerName:"开始时间", field: 'startTime'}
        {headerName:"结束时间", field: 'endTime'}
      ]
      
      #分页组件
      scope.gardData = []
      #导出组件
      scope.dervise = []
      
      #总共页数
      scope.pageContainerChange = 0
      #初始化页数
      scope.pageItem = 0

      #需要查询的设备类型
      scope.templateType = scope.parameters.type
      scope.componentName  = scope.parameters.name

      esAllStation = []

      scope.query =
        startTime: ''
        endTime: ''

      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

      if _.isEmpty(scope.parameters) or !scope.parameters.name
        @display null, '请传入需要的值',1500
        return false

      scope.selectEquipSubscription?.dispose()
      scope.selectEquipSubscription = @commonService.subscribeEventBus "checkEquips",(msg)=>
        esAllStation = msg.message

      pageAction = (statics, pageItem)=>
        scope.dervise = statics
        chunkObj = _.chunk(statics, 10)
        scope.gardData = chunkObj[pageItem]

      #查询数据
      queryAlarms = (filterRecord, filStation, pageItem)=>
        staArr = _.uniq (_.map filStation,(fil)=> return fil.station)
        equipArr = _.uniq (_.map filStation,(fil)=> return fil.id)

        scope.gardData = []
        scope.dervise = []

        @commonService.reportingService.queryEventRecords { filter:filterRecord, paging: null, sorting: null },(err, records)=>
          if records.length > 0
            tempRecords = _.filter records,(res)=> res.equipmentType is scope.templateType
            return if tempRecords.length is 0
            eqSta = _.filter (_.filter tempRecords,(sta)=>
              sta.station in staArr),(eq)=>
                eq.equipment in equipArr

            scope.pageContainerChange = eqSta.length

            estStart = ''
            estEnd = ''
            callTime = ''
            tempStatics = []

            _.each eqSta,(est)=>
              _eStart = _.clone(estStart)
              _eEnd = _.clone(estEnd)
              _est = _.clone(est)
              _callTime = _.clone(callTime)

              _eStart = est.startTime
              _eEnd = est.endTime

              if !_eEnd
                _eEnd = ''
                _callTime = ''
              else
                _eEnd = moment(_eEnd).format('YYYY-MM-DD HH:mm:ss')
                _callTime = @calTimes(moment(_est.endTime,"YYYY-MM-DD HH:mm:ss").diff moment(_est.startTime, 'YYYY-MM-DD HH:mm:ss'), 'seconds')

              tempStatics.push({
                stationName: _est.stationName
                equipName: _est.equipmentName
                alarmSeverity: _est.severityName
                alarmName: _est.eventName
                startVal: _est.startValue
                endVal: _est.endValue || ''
                allTime: _callTime
                startTime: moment(_eStart).format('YYYY-MM-DD HH:mm:ss')
                endTime: _eEnd
              })
            pageAction(tempStatics, pageItem)

            #切换底部页数
            scope.comPageBus?.dispose()
            scope.comPageBus = @commonService.subscribeEventBus 'pageTemplate',(msg)=>
              message = msg.message - 1
              pageAction(tempStatics,  message)
          else
            scope.gardData = []
            scope.dervise = []
            scope.pageContainerChange = 0

      checkFilter= ()=>
        if not esAllStation or (not esAllStation.length)
          M.toast({html: '请选择设备！'})
          return true

        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false

      #查询
      scope.queryReport = ()=>
        return if checkFilter()
        filStation = _.filter esAllStation, (item)->item.level isnt "station"
        filterRecord = scope.project.getIds()

        filterRecord.startTime = moment(scope.query.startTime).format("YYYY-MM-DD") + " 00:00"
        filterRecord.endTime = moment(scope.query.endTime).format("YYYY-MM-DD") + " 23:59"

        queryAlarms(filterRecord, filStation, scope.pageItem)

      #导出
      scope.exportReport = (title)=>
        if scope.dervise.length is 0
          @display null, '暂无数据', 1500
          return false

        wb = XLSX.utils.book_new();
        excel = XLSX.utils.json_to_sheet(scope.dervise)
        XLSX.utils.book_append_sheet(wb, excel, "Sheet1")
        XLSX.writeFile(wb, title + "-" + moment().format('YYYYMMDDHHMMSS') + ".xlsx")


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
      scope.selectEquipSubscription?.dispose()
      scope.comPageBus?.dispose()

  exports =
    BatteryAlarmDirective: BatteryAlarmDirective