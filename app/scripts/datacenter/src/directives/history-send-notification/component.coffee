###
* File: history-send-notification-directive
* User: David
* Date: 2020/01/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class HistorySendNotificationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "history-send-notification"
      super $timeout, $window, $compile, $routeParams, commonService
      @notificationService = @commonService.modelEngine.modelManager.getService("reporting.records.notification")


    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.paraName = scope.parameters.name

      #通知类型
      triggerType = {
        "console": "控制台", "tts": "TTS语音", "email": "邮件", "wechat": "微信",  "sms": "短信", "cloudsms": "云短信"
        "snmp": "SNMP", "command": "控制命令", "phone": "电话语音", "workflow": "工作流"
      }

      #通知优先级
      priorities = { "0": "一般信息", "1": "警告通知",  "2": "重要通知", "3": "紧急通知", "-1": "确认通知"  }

      #通知状态
      phases = { "start": "开始", "completed": "完成", "timeout": "超时", "error": "错误", "cancel": "取消" }


      scope.dataNumber = 0 #查询出的总数量
      scope.countPage = 0 #初始化页数


      scope.headers = [
        {headerName: "通知规则", field: "notification"}
        {headerName: "接收人", field: "receivers"}
        {headerName: "消息标题", field: "title"}
        {headerName: "消息内容", field: "content"}
        {headerName: "通知优先级", field: "priority"}
        {headerName: "通知类型", field: "type"}
        {headerName: "通知状态", field: "phase"}
        {headerName: "超时", field: "timeout"}
        {headerName: "开始时间", field: "startTime"}
        {headerName: "结束时间", field: "endTime"}
        {headerName: "用户", field: "trigger"}
      ]

      scope.gardData = []
      scope.gardAllData = []

      scope.query =
        startTime:''
        endTime:''

      scope.timeSubscription?.dispose()
      scope.timeSubscription = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')


      checkMsg = (allData, pageNumber)=>
        scope.gardData = (_.chunk(allData, 10))[pageNumber]


      notificationData = ()=>
        filCation = scope.project.getIds()
        filCation.startTime = (moment(scope.query.startTime).format("YYYY-MM-DD")) + " 00:00"
        filCation.endTime = (moment(scope.query.endTime).format("YYYY-MM-DD"))+ " 23:59"

        @notificationService.query(filCation, null, (err, records)=>
          dataRes = records.data

          if dataRes.length > 0
            start = ""
            end = ""

            _.each dataRes,(d)=>
              _des = _.clone(d)

              _start = _.clone(start)
              _end = _.clone(end)

              _start = d.startTime
              _end = d.endTime

              if !_start or _start == ""
                _start = ""
              else
                _start = moment(_des.startTime).format("YYYY-MM-DD HH:mm:ss")

              if !_end or _end == ""
                _end = ""
              else
                _end = moment(_des.endTime).format("YYYY-MM-DD HH:mm:ss")

              scope.gardAllData.push({
                notification: _des.notification
                receivers: _des.receivers
                title: _des.title
                content: _des.content
                priority: priorities[_des.priority]
                type: triggerType[_des.type]
                phase: phases[_des.phase]
                timeout: _des.timeout
                startTime: _start
                endTime: _end
                trigger: _des.trigger
              })

            scope.dataNumber = scope.gardAllData.length

            checkMsg(scope.gardAllData, scope.countPage)

            scope.comPageBus?.dispose()
            scope.comPageBus = @commonService.subscribeEventBus 'pageTemplate',(msg)=>
              message = msg.message - 1
              checkMsg(scope.gardAllData, message)

          else
            scope.gardData = []
            scope.gardAllData = []
        ,true)

      @$timeout =>
        notificationData()
      ,500

      #查询
      scope.queryReport = ()=>
        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return false

        notificationData()


      #导出
      scope.exportReport = (paramTitle)=>
        if scope.gardAllData.length is 0
          @display null, "暂无数据！", 1500
          return false

        wb = XLSX.utils.book_new();
        excel = XLSX.utils.json_to_sheet(scope.gardAllData)
        XLSX.utils.book_append_sheet(wb, excel, "Sheet1")
        XLSX.writeFile(wb, paramTitle + "-" + moment().format('YYYYMMDDHHMMSS') + ".xlsx")


    resize: (scope)->

    dispose: (scope)->


  exports =
    HistorySendNotificationDirective: HistorySendNotificationDirective