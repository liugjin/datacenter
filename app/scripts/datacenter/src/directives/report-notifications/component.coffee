###
* File: report-notifications-directive
* User: David
* Date: 2019/11/15
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportNotificationsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "report-notifications"
      super $timeout, $window, $compile, $routeParams, commonService
      @logonUser = commonService.$rootScope.user

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      # 查告警通知记录报表， 按开始时间 结束时间 通知类型 接收通知人(电话或邮件) 过滤。   要得到所有用户信息用户信息里有用户邮箱和用户电话。
      scope.token = scope.controller?.$rootScope?.user?.token || setting.adminToken || '0b6703d0-d873-11e9-ab4f-c5a3318c0787'
#      scope.token = setting.adminToken || '0b6703d0-d873-11e9-ab4f-c5a3318c0787'
      # scope.pageItems = scope.parameters.pageItems || 12

      #设置分页数量
      if scope.parameters.pageItems
        if scope.parameters.pageItems > 12
          scope.pageItems = 12
        else
          scope.pageItems = scope.parameters.pageItems
      else
        scope.parameters.pageItems = 12


      scope.types = [
        {name: '邮件',type: 'email'}
        {name: '微信',type: 'wechat'}
        {name: '短信',type: 'sms'}
        {name: '云短信',type: 'cloudsms'}
        {name: '电话',type: 'phone'}
        {name: '语音',type: 'tts'}
      ]
      scope.msgStatus = [
        {id:"completed",name:"已完成",checked:true}
        {id:"error",name:"错误",checked:true}
        {id:"timeout",name:"超时",checked:true}
        ]
      scope.allTypes = []
      scope.selectedTypes = []
      scope.selectedPhases = ["completed","error","timeout"]
      scope.allUsers = []
      scope.selectedUsers = []
      scope.header = [
        {headerName:"通知类型", field: 'typeName',width:90},
        {headerName:"通知人", field: 'receivers'},
        {headerName:"通知人名", field: 'receiverNames'},
        {headerName:"开始时间", field: 'startTime'},
        {headerName:"结束时间", field: 'endTime'},
        {headerName:"通知状态", field: 'phase'}
      ]
      scope.garddatas = [
        {typeName:"暂无数据",receivers:"暂无数据",operation:"暂无数据",address:"暂无数据",timestamp:"暂无数据"}
      ]
      scope.query =
        startTime : moment().format("YYYY-MM-DD")
        endTime : moment().format("YYYY-MM-DD")
      scope.checkAdmin = ()=>
        if @logonUser.user != 'admin'
          @display "请使用超级管理员访问"
          return


      # 按接收人过滤
      (scope.queryUsers=()=>
        url = 'http://'+ @$window.location.host + "/model/clc/api/v1/users"
        $.get(url,{token:scope.token},(data)->           #非admin用户会报未授权项目（userService方式查是一样）
          scope.users = data
          for item in scope.users
            signalData = {
              id: item.user
              name: item.name
              checked: true
            }
            scope.allUsers.push signalData
            scope.selectedUsers.push item.user
        )
      )()

      scope.getUserName = (type,info)=>
        switch type
          when 'phone'
            for item in scope.users
              if item.phone == info
                return item.name
          when 'wechat'
            for item in scope.users
              if item.openid == info
                return item.name
          when 'email'
            for item in scope.users
              if item.email == info
                return item.name
          when 'userid'
            for item in scope.users
              if item.user == info
                return item.name
        return info

      scope.getTypeName = (type)->
        for item in scope.types
          if item.type == type
            return item.name
        return type

      scope.getPhaseName = (phase)->
        for item in scope.msgStatus
          if item.id == phase
            return item.name
        return phase

      scope.getReceiverNames = (type,receivers)=>
        return [] if (receivers is undefined || receivers.length <= 0)
        receiverNames = []
        if type in ['sms','cloudsms','phone']
            for item in receivers
              receiverNames.push scope.getUserName('phone',item) if (scope.getUserName('phone',item)).length>0
            return receiverNames
        else if type in ['command']
          for item in receivers
            receiverNames.push scope.getUserName('userid',item) if (scope.getUserName('userid',item)).length>0
          return receiverNames
        else if type is 'wechat'
          for item in receivers
            receiverNames.push scope.getUserName('wechat',item) if (scope.getUserName('phone',item)).length>0
          return receiverNames
        else if type is 'email'
          for item in receivers
            receiverNames.push scope.getUserName('email',item) if (scope.getUserName('phone',item)).length>0
          return receiverNames
        else
          return receiverNames

      # 按类型过滤
      url = 'http://'+ @$window.location.host + "/model/clc/api/v1/notificationrules/#{@$routeParams.user}/#{@$routeParams.project}" + "?token=" + @commonService.$rootScope.user.token
      @commonService.modelEngine.modelManager.$http.get(url).then (data) =>
#        console.info data
        for item in data.data
          iname = scope.getTypeName(item.type)
          if iname == 'command'
            iname = '内置短信'
          signalData = {
            id: item.type
            name: iname
            checked: true
          }
          if item.type not in scope.selectedTypes
            scope.selectedTypes.push item.type
            scope.allTypes.push signalData



      @timeSubscribe?.dispose()
      @timeSubscribe = @commonService.subscribeEventBus 'time',(d)=>
        scope.query.startTime = moment(d.message.startTime).startOf('day')
        scope.query.endTime = moment(d.message.endTime).endOf('day')

      scope.dropSubscribe?.dispose()
      scope.dropSubscribe = @subscribeEventBus "drop-down-select", (d) =>
        msg = d.message
        if msg.origin is "type"
          scope.selectedTypes = msg.selected
        else if msg.origin is "user"
          scope.selectedUsers = msg.selected
        else if msg.origin is "phase"
          scope.selectedPhases = msg.selected
      scope.checkFilter=() ->
        if scope.selectedTypes.length == 0
          M.toast({html: '通知类型不能为空！'})
          return true

        if scope.selectedPhases.length == 0
          M.toast({html: '通知状态不能为空！'})
          return true

        if moment(scope.query.startTime).isAfter moment(scope.query.endTime)
          M.toast({html: '开始时间大于结束时间！'})
          return true
        return false

      scope.exportReport=(header,name)=>
        reportName = name + "(" + moment(scope.query.startTime).format("YYYY-MM-DD") + "-" + moment(scope.query.endTime).format("YYYY-MM-DD") + ").csv"
        @commonService.publishEventBus "export-report", {header:header, name:reportName}

      scope.getReportData = (page= 1 ,pageItems = scope.pageItems)=>
        scope.checkAdmin()
        return if scope.checkFilter()

        filter = scope.project.getIds()
        filter["$or"] = _.map scope.selectedTypes,(type) -> return {type:type}
        if scope.selectedPhases.length > 0
          filter.phase = {$in:scope.selectedPhases}

#        filter.receivers = receivers if receivers != 'all'
        filter.startTime = moment(scope.query.startTime).startOf('day')
        filter.endTime = moment(scope.query.endTime).endOf('day')
        paging =
          page: page
          pageItems: pageItems
        data =
          filter: filter
          fields: null
          paging: paging
          sorting: {
            startTime: -1
          }
          token: scope.token
        @commonService.reportingService.queryRecords "reporting.records.notification",data, (err, records, paging2) =>
          # 非admin用户访问 报未授权项目
          return console.log('err:',err) if err

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

          records2 = _.map records,(item)=>
            iname = scope.getTypeName(item.type)
            if iname == 'command'
              iname = '内置短信'
            _.extend item,{startTime:moment(item.startTime).format("YYYY-MM-DD HH:mm:ss"),endTime:moment(item.endTime).format("YYYY-MM-DD HH:mm:ss"),typeName:iname,phase:scope.getPhaseName(item.phase),receiverNames:scope.getReceiverNames(item.type,item.receivers)||''}
          sortDataArray = (_.sortBy records2,'startTime'
          ).reverse()
          scope.garddatas = sortDataArray


      scope.queryPage=(page) =>
        paging = scope.pagination
        return if not paging

        if page is 'next'
          page = paging.page + 1
        else if page is 'previous'
          page = paging.page - 1

        return if page > paging.pageCount or page < 1

        scope.getReportData page, paging.pageItems

      @$timeout ()->
        scope.getReportData()
      ,1000


    resize: (scope)->

    dispose: (scope)->
      scope.dropSubscribe?.dispose()
      @timeSubscribe?.dispose()

  exports =
    ReportNotificationsDirective: ReportNotificationsDirective