###
* File: video-history-directive
* User: region
* Date: 2019/04/10
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class VideoHistoryDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "video-history"
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
      scope.leftblack0 = @getComponentPath('image/video/leftblack0.svg')
      scope.leftblack1 = @getComponentPath('image/video/leftblack1.svg')
      scope.leftblack2 = @getComponentPath('image/video/leftblack2.svg')
      scope.rightblack0 = @getComponentPath('image/video/rightblack0.svg')
      scope.rightblack1 = @getComponentPath('image/video/rightblack1.svg')
      scope.rightblack2 = @getComponentPath('image/video/rightblack2.svg')
      scope.playing = @getComponentPath('image/video/playing.svg')
      scope.pauseing= @getComponentPath('image/video/pauseing.svg')

#      -----原回放controller中的内容----

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
        return true

      # 九宫格功能
      scope.setGridOptions= (rows, cols, setting = false) ->
        scope.gridOptions =
          rows: rows
          cols: cols
          setting: setting

      loadStationVideos= (station, callback, refresh) ->
        mds = []
        station.loadEquipments {project: station.model.project, type:'video'}, null, (err, model)=>
          for sta, i in station.stations
            await sta.loadEquipments {project: station.model.project, type:'video'}, null, defer err, mds[i]
          if !err
            model = model.concat md for md in mds
            scope.videos = model

            scope.setGridOptions 1, 1, true
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

#      订阅选择日期执行someoperation
      scope.somedayplaybackSubscription?.dispose()
      scope.somedayplaybackSubscription = @commonService.subscribeEventBus 'somedayplayback', (d) =>
        if scope.equipment is undefined or scope.equipment is null or scope.equipment is ""
          @display "请先选择设备"
          return
        if !(! !window.ActiveXObject or 'ActiveXObject' of window)
          @display "请使用IE浏览器查看"
          return
        starttime = moment(d.message.timedate).format 'YYYY-MM-DD'
        if starttime > moment().format 'YYYY-MM-DD'
          alert("历史视频不支持超过当前系统日期");
          return
        message =
          type: 'I_StartPlayback'
          channel: Number(scope.hikOptions.channel)
          protocolType: 0
          streamType: 0
          timeFrom:"#{starttime} 00:00:00"
          timeTo:"#{starttime} 23:59:59"
          options: scope.hikOptions
        scope.actionMessage(message)


#    选择摄像头  nvr 拿到操作信息，并执行someoperation
      scope.selectVideo= (video, index, playstatus=false) =>
        scope.equipment = video
        hikOptions = optionsArr = {}
        _.map(video.model.properties, (data) ->
          optionsArr[data.id] = data.value
        )
        scope.hikOptions = hikOptions
        if !video.signals.items[0].data.value
          scope.play = video.model.template
        if !playstatus
          scope.play = "video_template"
        scope.video = video
        hikOptions = optionsArr = {}
        hikOptions["play"] = scope.play
        if scope.play is 'video_template'
          _.map(video.model.properties, (data) ->
            optionsArr[data.id] = data.value
          )
          hikOptions["name"] = video.model.name
        starttime = moment(scope.timedate).format 'YYYY-MM-DD'

        message =
          type: 'I_StartPlayback'
          channel:  Number(scope.hikOptions.channel)
          protocolType: 0
          streamType: 0
          timeFrom:"#{starttime} 00:00:00"
          timeTo:"#{starttime} 23:59:59"
          options: scope.hikOptions
        scope.actionMessage(message)


  #播放视屏
      scope.startPreview= ->
        message =
          type: 'start-preview'
  # get the video channel by debugging realtimes video page
          protocolType: 0
          streamType: 0
        #index: @pindex
        scope.startPreview2 message

      #开始历史回放
      scope.startPlayback= (fileName) ->
        scope.recordfilename=fileName
        scope.maskLayer = true
        message =
          type: 'start-playback'
          channel: Number(@hikOptions.channel)
          protocolType: 0
          streamType: 0
          fileName:fileName
          options: scope.hikOptions

        @commonService.publishEventBus 'record', message
        setTimeout =>
          @commonService.publishEventBus 'record', message
        ,2000

      #停止历史回放
      scope.stopPlayback= ->
        scope.maskLayer = false
        message =
          type: 'stop-playback'
          channel:  Number(scope.hikOptions.channel)
          protocolType: 0
          streamType: 0
        scope.stopPlayback2 message


#        -----------------------分割线- 播放器部分 ------------------------------
      LOGIN_ERROR = -1
      scope.instance = element.find('.hik-video-instance')[0]?.object
#      scope.video = null
      scope.options = null
      scope.login= () ->
        scope.loginState = scope.instance.Login scope.options.ip, scope.options.port, scope.options.user, scope.options.password

      scope.ensureLogined= ->
        if scope.loginState is LOGIN_ERROR
          scope.login()

      scope.startPreview2= (params) =>
        scope.ensureLogined()
        if scope.instance.StartRealPlay scope.options.channel, params.protocolType, params.streamType
          scope.playing = true

      scope.stopPreview2= (params) ->
        if scope.playing
          if scope.instance.StopRealPlay()
            scope.playing = false

      scope.startPlayback2= (params) ->
        scope.ensureLogined()
        scope.instance.StopRealPlay()

        scope.instance.SetPlayWndType 0
        scope.instance.PlayBackByName params.fileName

      scope.stopPlayback2= (params) ->
        scope.instance.StopPlayBack()

      scope.ptzCtrlstop2= (params) =>
        if scope.playing
          scope.instance.PTZCtrlStop 10, scope.speed

      scope.ptzCtrlstart2= (params) =>
        if scope.playing
          scope.instance.PTZCtrlStop 10, scope.speed
          scope.instance.PTZCtrlStart params.commandcode, scope.speed

      scope.snapshot2= (params) =>
        if scope.playing
          scope.instance.JPEGCapturePicture scope.options.channel+1,2,0,"#{params.pictruepath}/#{params.dirname}",1

      scope.getrecordFiles= (params, callback) ->
  #    getrecordFiles: (options) ->
        recordFiles = scope.instance.SearchRemoteRecordFile scope.options.channel,0,params.timeFrom,params.timeTo,false,false,""
        console.log recordFiles
        callback recordFiles

      scope.createVideo = ->
        instance = element.find('.hik-video-instance')[0]?.object
        return if not instance

        video = new hv.HikVideo scope.options, instance
        video.login()
        video


# -----------------------分割线- 控制条部分------------------------------
#-1 已登录过, 0退出成功
      iRet = 0
      scope.channelid = 0
      scope.szip = "127.0.0.1"
      scope.mancount = 0
      scope.kuaicount = 0
      #全局保存当前选中窗口 ,可以不用设置这个变量，有窗口参数的接口中，不用传值，开发包会默认使用当前选择窗口
      g_iWndIndex = 0
      holewidth= $('#contentdiv').width()
      hoelheight= $('#contentdiv').height()
      hoelhe2ight2=parseInt(holewidth-61)+'px'
      console.log "-----初始化时间条------"
      timebar=$('#timelineId').timebar
        totalTimeInSecond: 86400
        width: hoelhe2ight2
        height:'98px'
        multiSelect: true
        barClicked: (time)=>
          selectedTime =$('#datevalue').val()+" "+ timebar.formatTime(time)
          clickStartPlayback(scope.szip,scope.channelid,moment(selectedTime).format("YYYY-MM-DD HH:mm:ss"),moment($('#datevalue').val()).format("YYYY-MM-DD")+" 23:59:59")

        pointerClicked: (time)=>
          selectedTime =$('#datevalue').val()+" "+ timebar.formatTime(time)
          clickStartPlayback(scope.szip,scope.channelid,moment(selectedTime).format("YYYY-MM-DD HH:mm:ss"),moment($('#datevalue').val()).format("YYYY-MM-DD")+" 23:59:59")

      #登陆NVR设备
      scope.nvrLogin = (options)->
        scope.channelid=options.channel
        if !options.nvrip
          return
        scope.szip=options.nvrip
        isinstalled=WebVideoCtrl.I_CheckPluginInstall()
        WebVideoCtrl.I_InitPlugin holewidth,hoelheight-100,{
          iWndowType: 1
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

      #获取3个 通道
      getChannelInfo = (nvrip)->
        #模拟通道
        WebVideoCtrl.I_GetAnalogChannelInfo nvrip,{
          async: false
          success:(model)=>

            oChannels = $(model).find("VideoInputChannel")
            nAnalogChannel = oChannels.length
          error:(err)=>
            console.log 'I_GetAnalogChannelInfoIP error'+err
        }

        #数字通道
        WebVideoCtrl.I_GetDigitalChannelInfo nvrip,{
          async: false
          success:(model)=>

            oChannels = $(model).find("InputProxyChannelStatus")

          error:(err)=>
            console.log 'I_GetDigitalChannelInfo error'+err
        }
        #零通道
        WebVideoCtrl.I_GetZeroChannelInfo nvrip,{
          async: false
          success:(model)=>

            oChannels = $(model).find("ZeroVideoChannel")

          error:(err)=>
            console.log 'I_GetZeroChannelInfo error'+err
        }

      #暂停 or 恢复播放
      scope.resumeorpause = () ->
        oWndInfo = WebVideoCtrl.I_GetWindowStatus 0
        if oWndInfo != null
          imgmodel=$('#imgpaly').attr 'src'
          if (imgmodel.indexOf 'playing') >0
            iRet = WebVideoCtrl.I_Pause()
            $('#imgpaly').attr("src",scope.pauseing)
          else
            iRet = WebVideoCtrl.I_Resume()
            $('#imgpaly').attr("src",scope.playing)
        else
          @prompt '提示','请先选择摄像头'
      #开始回放
      clickStartPlayback =(szip,channelid,szStartTime,szEndTime)->
        scope.channelid = channelid
        scope.szip = szip
        oWndInfo = WebVideoCtrl.I_GetWindowStatus 0
        bZeroChannel = false
        szInfo = ""
        bChecked = false
        iRet = -1
        #已经在播放了，先停止
        if oWndInfo != null
          WebVideoCtrl.I_Stop()

        iRet= WebVideoCtrl.I_StartPlayback szip,{
          iChannelID:channelid
          szStartTime:szStartTime
          szEndTime:szEndTime
        }
      #慢放
      scope.clickPlaySlow = ()->
        oWndInfo = WebVideoCtrl.I_GetWindowStatus g_iWndIndex
        if oWndInfo != null
          iRet = WebVideoCtrl.I_PlaySlow()
          if iRet == 0
            scope.mancount += 1 if scope.mancount < 3 and scope.kuaicount == 0
            scope.kuaicount -= 1 if scope.kuaicount > 0
            if scope.kuaicount==0
              $('#imgman').attr("src",scope.leftblack0) if scope.mancount==0
              $('#imgman').attr("src",scope.leftblack1) if scope.mancount==1
              $('#imgman').attr("src",scope.leftblack2) if scope.mancount==2
            if scope.mancount==0
              $('#imgkuai').attr("src",scope.rightblack0) if scope.kuaicount==0
              $('#imgkuai').attr("src",scope.rightblack1) if scope.kuaicount==1
              $('#imgkuai').attr("src",scope.rightblack2) if scope.kuaicount==2

          else
            @prompt '提示','慢放失败'
        else
          @prompt '提示','请先选择摄像头'

      #快放
      scope.clickPlayFast = ()->
        oWndInfo = WebVideoCtrl.I_GetWindowStatus g_iWndIndex
        if oWndInfo != null
          iRet = WebVideoCtrl.I_PlayFast()
          if iRet == 0
            scope.kuaicount +=1 if scope.kuaicount < 3 and scope.mancount == 0
            scope.mancount -= 1 if scope.mancount > 0

            if scope.kuaicount==0
              $('#imgman').attr("src",scope.leftblack0) if scope.mancount==0
              $('#imgman').attr("src",scope.leftblack1) if scope.mancount==1
              $('#imgman').attr("src",scope.leftblack2) if scope.mancount==2
            if scope.mancount==0
              $('#imgkuai').attr("src",scope.rightblack0) if scope.kuaicount==0
              $('#imgkuai').attr("src",scope.rightblack1) if scope.kuaicount==1
              $('#imgkuai').attr("src",scope.rightblack2) if scope.kuaicount==2

          else
            @prompt '提示','快放失败'
        else
          @prompt '提示','请先选择摄像头'

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
      scope.somedayplaybackSubscription?.dispose()


  exports =
    VideoHistoryDirective: VideoHistoryDirective