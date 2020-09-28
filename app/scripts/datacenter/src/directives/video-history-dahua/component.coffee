###
* File: video-history-directive
* User: region
* Date: 2019/04/10
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class VideoHistoryDahuaDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "video-history-dahua"
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
      scope.leftblack0 = @getComponentPath('image/video/leftblack0.svg')
      scope.leftblack1 = @getComponentPath('image/video/leftblack1.svg')
      scope.leftblack2 = @getComponentPath('image/video/leftblack2.svg')
      scope.rightblack0 = @getComponentPath('image/video/rightblack0.svg')
      scope.rightblack1 = @getComponentPath('image/video/rightblack1.svg')
      scope.rightblack2 = @getComponentPath('image/video/rightblack2.svg')
      scope.playing = @getComponentPath('image/video/playing.svg')
      scope.pauseing= @getComponentPath('image/video/pauseing.svg')

      scope.gridStatus = "start" #布局状态
      scope.recordfilename=""
      scope.viewstatus = []
      scope.pageStatus = []
      scope.maskLayer = false
      scope.timedate = moment().format 'YYYY-MM-DD'
      scope.datacenters = []

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
          channel: Number(scope.dahuaOptions.channel)
          protocolType: 0
          streamType: 2
          timeFrom:"#{starttime} 00:00:00"
          timeTo:"#{starttime} 23:59:59"
          options: scope.dahuaOptions
        scope.actionMessage(message)


      #    选择摄像头  nvr 拿到操作信息，并执行someoperation
      scope.selectVideo= (video, index, playstatus=false) =>
        scope.equipment = video
        dahuaOptions = optionsArr = {}
        _.map(video.model.properties, (data) ->
          optionsArr[data.id] = data.value
        )
        scope.dahuaOptions = dahuaOptions
        scope.video = video
        starttime = moment(scope.timedate).format 'YYYY-MM-DD'
        message =
          type: 'I_StartPlayback'
          channel:  Number(scope.dahuaOptions.channel)
          protocolType: 0
          streamType: 2
          timeFrom:"#{starttime} 00:00:00"
          timeTo:"#{starttime} 23:59:59"
          options: scope.dahuaOptions
        scope.actionMessage(message)


      #播放视屏
      scope.startPreview= ->
        message =
          type: 'start-preview'
# get the video channel by debugging realtimes video page
          protocolType: 0
          streamType: 2
        #index: @pindex
        scope.startPreview2 message

      #开始历史回放
      scope.startPlayback= (fileName) ->
        scope.recordfilename=fileName
        scope.maskLayer = true
        message =
          type: 'start-playback'
          channel: Number(@dahuaOptions.channel)
          protocolType: 0
          streamType: 2
          fileName:fileName
          options: scope.dahuaOptions

        @commonService.publishEventBus 'record', message
        setTimeout =>
          @commonService.publishEventBus 'record', message
        ,2000

      #停止历史回放
      scope.stopPlayback= ->
        scope.maskLayer = false
        message =
          type: 'stop-playback'
          channel:  Number(scope.dahuaOptions.channel)
          protocolType: 0
          streamType: 2
        scope.stopPlayback2 message


      # -----------------------分割线- 控制条部分------------------------------
      #-1 已登录过, 0退出成功
      iRet = 0
      scope.channelid = 0
      scope.szip = "127.0.0.1"
      scope.mancount = 0
      scope.kuaicount = 0
      #全局保存当前选中窗口 ,可以不用设置这个变量，有窗口参数的接口中，不用传值，开发包会默认使用当前选择窗口
      g_iWndIndex = 0
      scope.holewidth= $('#contentdiv').width()
      scope.hoelheight= $('#contentdiv').height()
      scope.hoelhe2ight2=parseInt(scope.holewidth-61)+'px'
      console.log "-----初始化时间条------"
      timebar=$('#timelineId').timebar
        totalTimeInSecond: 86400
        width: scope.hoelhe2ight2
        height:'98px'
        multiSelect: true
        barClicked: (time)=>
          selectedTime =$('#datevalue').val()+" "+ timebar.formatTime(time)
          clickStartPlayback(scope.channelid,moment(selectedTime).format("YYYY-MM-DD HH:mm:ss"),moment($('#datevalue').val()).format("YYYY-MM-DD")+" 23:59:59")

        pointerClicked: (time)=>
          selectedTime =$('#datevalue').val()+" "+ timebar.formatTime(time)
          clickStartPlayback(scope.channelid,moment(selectedTime).format("YYYY-MM-DD HH:mm:ss"),moment($('#datevalue').val()).format("YYYY-MM-DD")+" 23:59:59")

      #登陆NVR设备
      scope.nvrLogin = (options)->
        if !options.nvrip
          return
        scope.szip=options.nvrip
        scope.channelid=options.channel
        scope.userstr=options.nvruser
        scope.pwdstr=options.nvrpassword

        WebVideoCtrl.insertPluginObject "divPlugin",scope.holewidth,scope.hoelheight-100
        WebVideoCtrl.initPlugin( ()=>
#          设置窗口分割数
          WebVideoCtrl.setSplitNum 1
          #          设置双击可全屏功能
          WebVideoCtrl.enablePreviewDBClickFullSreen true

          WebVideoCtrl.addEventListener "DownloadByTimePos", (eventParam)=>
            scope.pos = eventParam["pos"];
            scope.speed = eventParam["speed"]
            scope.end = eventParam["end"]
            return scope.g_iWndIndex

          WebVideoCtrl.addEventListener "ChnlInfo", (eventParam)=>
            scope.channelNum = eventParam["ChanNum"]
            return scope.g_iWndIndex

          WebVideoCtrl.addEventListener "ReturnWindInfo", (eventParam)=>
            scope.g_iWndIndex = eventParam["winID"]
            return scope.g_iWndIndex

          WebVideoCtrl.addEventListener "NetPlayState",(eventParam)=>
            scope.g_iWndIndex = eventParam["winID"]
            return scope.g_iWndIndex

        )
        # 登录当前设备
        scope.ret = WebVideoCtrl.login scope.szip,37777,scope.userstr,scope.pwdstr,0
        if(scope.ret==0)
          M.toast({ html: 'NVR登录成功' },3000)
          console.log("nvr login successed")
          #        设置回放模式
          WebVideoCtrl.setModuleMode(4)

        else
          M.toast({ html: '摄像头登录失败，errorcode:'+ret },3000)

        return true

      # 播放状态 0:播放ing 1:暂停
      scope.playstatu=0
      #暂停 or 恢复播放  WebVideoCtrl.pausePlayBack()
      scope.resumeorpause = () ->
        if scope.playstatu == 0
          WebVideoCtrl.pausePlayBack()
          $('#imgpaly').attr("src",scope.pauseing)
          scope.playstatu=1
        else
          WebVideoCtrl.resumePlayback()
          $('#imgpaly').attr("src",scope.playing)
          scope.playstatu=0

      #快放
      # 2:慢放*2 3:慢放*1 4:正常 5:快放*1  6:快放*2
      scope.playspeed=4
      scope.clickPlayFastorSlow = (palymode)->
        if palymode ==0
          scope.playspeed--
        else
          scope.playspeed++
        WebVideoCtrl.setPlaySpeed scope.playspeed
        $('#imgman').attr("src",scope.leftblack0) if scope.playspeed==4
        $('#imgman').attr("src",scope.leftblack1) if scope.playspeed==3
        $('#imgman').attr("src",scope.leftblack2) if scope.playspeed==2

        $('#imgkuai').attr("src",scope.rightblack0) if scope.playspeed==4
        $('#imgkuai').attr("src",scope.rightblack1) if scope.playspeed==5
        $('#imgkuai').attr("src",scope.rightblack2) if scope.playspeed==6

      #开始回放
      clickStartPlayback =(channelid,szStartTime,szEndTime)->
        scope.channelid = channelid
        WebVideoCtrl.playBackByTimeEx(0,  Number(channelid),2, szStartTime, szEndTime)


      scope.actionMessage =(d)->
        scope.nvrLogin d.options
        # 测试中下面12行代码有报错时 导致订阅日期选择无效..
        switch d.type
          when 'I_StartPlayback'
            setTimeout(()=>
              clickStartPlayback(d.options.channel,moment(d.timeFrom).format("YYYY-MM-DD HH:mm:ss"),moment(d.timeTo).format("YYYY-MM-DD HH:mm:ss"))
            ,100)



    resize: (scope)->

    dispose: (scope)->
      scope.searchSubscription?.dispose()
      scope.somedayplaybackSubscription?.dispose()


  exports =
    VideoHistoryDahuaDirective: VideoHistoryDahuaDirective