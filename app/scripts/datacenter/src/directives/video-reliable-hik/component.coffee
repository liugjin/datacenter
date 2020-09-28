###
* File: video-history-directive
* User: region
* Date: 2019/04/10
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class VideoReliableHikDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "video-reliable-hik"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      初始化
      scope.videospng = @getComponentPath('image/video/videos.png')
      scope.videopng = @getComponentPath('image/video/video.png')
      scope.gridStatus = "start" #布局状态
      scope.recordfilename=""
      scope.viewstatus = []
      scope.pageStatus = []
      scope.maskLayer = false
      scope.timedate = moment().format 'YYYY-MM-DD'
      scope.datacenters = []

      #全局保存9宫格
      scope.g_iWndNum = 2
      #全局保存当前选中窗口
      scope.g_iWndIndex = 0
      scope.viewstatus = []

      scope.holewidth= $('#contentdiv').width()
      scope.hoelheight= $('#contentdiv').height()
      scope.OpenFileDlgType = 0
      #当前下载的文件名称
      scope.downloadFileName=""

      # 加载默认站点及站点摄像头
      for station in scope.project.stations.items
        if station.stations.length >0
          scope.datacenters.push(station)
      if scope.datacenters.length > 0
        scope.datacenter = scope.datacenters[0]
      else
        scope.datacenter = scope.project
      scope.selectStation= (station) ->
        loadStationVideos station
        WebVideoCtrl.I_InitPlugin(scope.holewidth,scope.hoelheight, {
          iWndowType: scope.g_iWndNum,
          cbSelWnd: (xmlDoc) =>
            console.log("I_InitPlugin success")
        })
        WebVideoCtrl.I_InsertOBJECTPlugin("divPlugin")
        return true

      # 九宫格功能
      scope.setGridOptions= (rows, cols, setting = false) ->
        scope.gridOptions =
          rows: rows
          cols: cols
          setting: setting
      scope.getvideostate= (videopara)->
        videopara?.loadProperties null, (err, properties) =>
          ippara="192.168.1.1"
          equipType=videopara.model.vendor
          # dahua rtsp://admin:admin123@192.168.10.251/cam/realmonitor?channel=1&subtype=1
          #          http://192.168.10.250/image/loginlogo-dh.jpg?version=2.400
          # hikvision rtsp://admin:admin123@192.168.10.250/h264/ch1/sub/av_stream
          #          http://192.168.10.250/favicon.ico'
          rtspobj = _.find properties, (property) -> property.model.property is "rtsp"
          if rtspobj? &&(equipType =="dahua" || equipType=="hikvision")
            ippara=rtspobj.value.split('rtsp://')?[1].split(':')?[1].split('@')?[1].split('/')?[0]
          else if rtspobj? &&(equipType =="huawei")
#huawei rtsp://192.168.249.221:554/admin:Huawei123/LiveMedia/ch1/Media1
            ippara=rtspobj.value.split('rtsp://')?[1].split(':')?[0]
          else
            console.log videopara.model.name+"rtsp属性错误"
          img = new Image()
          start = new Date().getTime()
          hasFinish = false
          if videopara.model.vendor=="hikvision"
            img.src = 'http://'+ippara+'/favicon.ico'
            img.onload = (successmsg)=>
            if  !hasFinish
              hasFinish = true
              videopara.onlineflag=true
              scope.$applyAsync()
            img.onerror = (errormsg) =>
              if !hasFinish
                hasFinish = true
                videopara.onlineflag=false
                scope.$applyAsync()
          else if videopara.model.vendor=="dahua"
            img.src = 'http://'+ippara+'/image/loginlogo-dh.jpg'
            img.onload = (successmsg)=>
              if  !hasFinish
                hasFinish = true
                videopara.onlineflag=true
                scope.$applyAsync()
            img.onerror = (errormsg) =>
              if !hasFinish
                hasFinish = true
                videopara.onlineflag=false
                scope.$applyAsync()
          else if videopara.model.vendor=="huawei"
#            https://192.168.249.230/resources/default/images/type/login.png
            img.src = 'https://'+ippara+'/resources/default/images/type/login.png'
            if  !hasFinish
              hasFinish = true
              videopara.onlineflag=true
              scope.$applyAsync()

      loadStationVideos= (station, callback, refresh) ->
        mds = []
        station.loadEquipments {project: station.model.project, type:'video'}, null, (err, model)=>
          for sta, i in station.stations
            await sta.loadEquipments {project: station.model.project, type:'video'}, null, defer err, mds[i]
          if !err
            model = model.concat md for md in mds
            scope.videos = model
            for video in scope.videos
              scope.getvideostate video
            scope.setGridOptions 2, 2, true
            for equip in model
              equip.loadCommands null, ()=>
                console.log "先不订阅，在选中具体摄像头时订阅"
              , refresh
              equip.loadSignals null, (err, data) =>
                if data[0]
                  console.log "先不订阅，在选中具体摄像头时订阅"
          callback? err, model
        , refresh

      scope.loadUsers= () ->
        scope.users = scope.project.model.starUsers

      # 判断浏览器，然后加载站点及站点摄像头 加载用户
      if !(! !window.ActiveXObject or 'ActiveXObject' of window)
        @display "请使用IE浏览器查看"
        return
      scope.selectStation(scope.station)
      scope.loadUsers()

      # 搜索过滤摄像头
      scope.searchSubscription?.dispose()
      scope.searchSubscription = @commonService.subscribeEventBus 'search',(msg)=>
        scope.search = msg.message
        scope.$applyAsync()
      scope.filterVideo= (video)=>
        return true if not scope.search or scope.search is ""
        return true if video.model.equipment.indexOf(scope.search)>=0
        return true if video.model.name.indexOf(scope.search)>=0
        return false

      #    选择摄像头 进行摄像头的登录，然后自动开始播放实时视频
      scope.selectVideo= (video, index, playstatus=false) =>
        scope.equipment = video
        scope.viewstatus.push(video) if scope.viewstatus.indexOf(video) ==-1
        rtspstr=""
        #        rtsp= rtsp://admin:admin123@192.168.1.250/h264/ch1/sub/av_stream
        rtspstr=video.getPropertyValue('rtsp')
        if rtspstr =="" ||rtspstr ==null
          M.toast({ html: '请设置摄像头的RTSP属性值！！' },3000)
          return
        somethingstr=rtspstr.split('rtsp://')?[1]
        userstr=somethingstr.split(':')?[0]
        pwdstr=somethingstr.split(':')?[1].split('@')?[0]
        scope.ipstr=somethingstr.split(':')?[1].split('@')?[1].split('/')?[0]

        #              //登录当前设备
        iRet = WebVideoCtrl.I_Login(scope.ipstr, 1, "80", userstr,pwdstr, {
          success:(xmlDoc)=>
            console.log ( " 登录cg！")
            setTimeout(()=>
              scope.getChannelInfo(scope.ipstr)
              scope.clickStartRealPlay(scope.ipstr)
            ,100)

          error:() =>
              console.log ( " 登录失败！")

        })
      scope.clickStartRealPlay= (szIP)->
        scope.oWndInfo = WebVideoCtrl.I_GetWindowStatus(scope.g_iWndIndex)
        if scope.oWndInfo != null
#          // 已经在播放了，先停止
          WebVideoCtrl.I_Stop()

        WebVideoCtrl.I_StartRealPlay(szIP, {
          iStreamType: 2,
          iChannelID: 1,
          bZeroChannel: false
        });
      scope.getChannelInfo= (szIP)->
#        // 模拟通道
        WebVideoCtrl.I_GetAnalogChannelInfo szIP,{
          async: false,
          success:(xmlDoc)->
            console.log("模拟通道 success")
          error:()->
            console.log("模拟通道 error")
        }

#        // 数字通道
        WebVideoCtrl.I_GetDigitalChannelInfo(szIP, {
          async: false,
          success:(xmlDoc) ->
            console.log("数字通道 success")
          error:()->
            console.log("数字通道 error")
        })
#        // 零通道
        WebVideoCtrl.I_GetZeroChannelInfo(szIP, {
          async: false,
          success:(xmlDoc)->
            console.log("零通道 success")
          error:() ->
            console.log("零通道 error")
        });

      #登陆NVR设备
      scope.nvrLogin = (options)->
        scope.channelid=options.channel
        if !options.nvrip
          return
        scope.szip=options.nvrip
        isinstalled=WebVideoCtrl.I_CheckPluginInstall()
        WebVideoCtrl.I_InitPlugin holewidth,hoelheight-100,{
          iWndowType: 2
          cbSelWnd:(xmlDoc)=>
            g_iWndIndex = $(xmlDoc).find("SelectWnd").eq(0).text()
        }
        WebVideoCtrl.I_InsertOBJECTPlugin("divPlugin");

        iRet=WebVideoCtrl.I_Login scope.szip,'1','80',options.nvruser,options.nvrpassword, {
          success: (model) =>
            setTimeout(()=>
              getChannelInfo(scope.szip)
              clickStartPlayback(scope.szip,scope.channelid,moment().format("YYYY-MM-DD")+" 00:00:00",moment().format("YYYY-MM-DD")+" 23:59:59")
            ,100)

          error: (err)=>
            console.log err
        }
        iRet



      scope.changeLayout= (number, refresh) ->
        scope.g_iWndNum = number
        WebVideoCtrl.I_ChangeWndNum scope.g_iWndNum



      scope.actionMessage =(d)->
        scope.nvrLogin d.options
        # 测试中下面12行代码有报错时 导致订阅日期选择无效..
        switch d.type
          when 'I_StartPlayback'
            iRet=WebVideoCtrl.I_Login d.options.nvrip,'1','80',d.options.nvruser,d.options.nvrpassword, {
              success: (model) =>
                setTimeout(()=>
                  getChannelInfo(d.options.nvrip)
                  clickStartPlayback(d.options.nvrip,d.options.channel,moment(d.timeFrom).format("YYYY-MM-DD HH:mm:ss"),moment(d.timeTo).format("YYYY-MM-DD HH:mm:ss"))
                ,100)

              error: (err)=>
                console.log err
            }
            if iRet == -1 ||iRet == "-1"
              clickStartPlayback(d.options.nvrip,d.options.channel,moment(d.timeFrom).format("YYYY-MM-DD HH:mm:ss"),moment(d.timeTo).format("YYYY-MM-DD HH:mm:ss"))



    resize: (scope)->

    dispose: (scope)->
      scope.searchSubscription?.dispose()

  exports =
    VideoReliableHikDirective: VideoReliableHikDirective