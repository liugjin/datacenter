###
* File: video-list-directive
* User: David
* Date: 2019/02/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['jquery','../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], ($,base, css, view, _, moment) ->
  class VideoListDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "video-list"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
#      console.log scope
      scope.vxgplayerpath = @getComponentPath('res/vxgplayer.zip')
      scope.videospng = @getComponentPath('image/video/videos.png')
      scope.videopng = @getComponentPath('image/video/videos.png')
      scope.videopngselect = @getComponentPath('image/video/select.png')
      scope.downgif = @getComponentPath('image/down.gif')

      scope.flag = 0
      scope.number = 2
      scope.nums = []
      scope.status = {}
      scope.playing = false
      scope.istextlistpage = true
      scope.videocommands=[]
      scope.rtspprefix = 'rtsp://admin:admin123@'
      videoTemplates = null
      scope.project.loadEquipmentTemplates {type: "video"}, 'user project type vendor template name base index image', (err, templates) =>
        return if err or templates.length < 0
        videoTemplates = templates
      scope.videotemplates = [{id:"video_template",name:"普通摄像头"},{id:"ipvideo_template",name:"云摄像头"},{id:"ckvideo_template",name:"萤石摄像头"}]
      scope.datacenters = []
      for station in scope.project.stations.items
        if station.model.station.charAt(0) isnt "_" && _.isEmpty station.model.parent
          scope.datacenters.push(station)
      scope.datacenter = scope.datacenters[0]


      executeCommand= (vedioObj)=>
        cmd = _.find vedioObj.commands.items, (ps)->ps.model?.command is "switch"
        commnad = cmd
        if commnad != undefined && @commnad != ""
          cmd.model.parameters[0].value = 1
          executeCommand2 cmd
          filter =
            user: scope.station.model.user
            project: scope.station.model.project
            station: scope.station.model.station
            equipment: vedioObj.model.equipment
            command: cmd.model.command

          scope.rtmpSubscription?.dispose()
          scope.rtmpSubscription = @commonService.commandLiveSession.subscribeValues filter, (err, d) =>
            title = "发送开启摄像头推流命令"
            if d.message.phase is "complete"
              title = "操作成功"
            else if d.message.phase is "error"
              title = "操作失败"
            else if d.message.phase is 'timeout'
              title = "操作超时"
            console.log title
        else
          console.log "缺少 switch 控制命令"
          return

      executeCommand2= (command, comment) =>
        model = command.model
        parameters = command.getParameterValues()

        data = command.getIds()
        #      data._id = model._id
        data.priority = model.priority
        data.phase = 'executing'
        data.parameters = parameters
        data.startTime = new Date
        data.endTime = null
        data.result = null
        data.trigger = 'user'
        data.operator = scope.project.model.user
        data.operatorName = scope.project.model.userName
        data.comment = comment ? model.comment

        @commonService.commandLiveSession.executeCommand data

      scope.changeLayout= (number, refresh) ->
        scope.number = number
        length = scope.nums.length
        if refresh
          scope.nums = []
          length = 0
        tolen = number*number
        if length < tolen
          scope.nums.push i for i in [length..tolen-1]
        else
          scope.nums.splice tolen, length-tolen
        scope.controller.$rootScope.flag = !scope.controller.$rootScope.flag

      scope.selectDatacenter= (datacenter) ->
        return false if scope.datacenter is datacenter
        scope.datacenter = datacenter
        scope.selectStation datacenter
        return true


      scope.videoState?.dispose()
      filter1 = scope.project.getIds()
      filter1.station = "+"
#      filter1.equipmentType = "video"
      filter1.equipment = "+"
      filter1.signal = "communication-status"
      scope.videoState = @commonService.signalLiveSession.subscribeValues filter1, (err, d)=>
        scope.status[d.message.station+"."+d.message.equipment] = d.message.value

      scope.selectStation= (station, refresh) ->
        scope.station = station
#        return false if not super station
        loadStationVideos station, =>
#          console.log scope
          scope.changeLayout scope.number, true
        ,refresh
        return true

      loadStationVideos= (station = scope.station, callback, refresh) ->
        mds = []
        station.loadEquipments {project: station.model.project, type:'video'}, null, (err, models)=>
          for sta, i in station.stations
            await sta.loadEquipments {project: station.model.project, type:'video'}, null, defer err, mds[i]
          if !err
            models = models.concat md for md in mds
            scope.videos = models

#            for video in scope.videos
#              scope.getvideostate video
          callback?()
#
        ,refresh

      scope.changeLayout scope.number
      scope.selectStation scope.station


      scope.playVideo= (video)->
  #      只有 设备模板类型是 "video_template 云视频监控" 才需要开启推流服务
        if video !=undefined && video !=""
          if video.model.template =="video_template"
            console.log "设备模板为video_template 执行推流控制"
#            executeCommand video
          index = scope.nums.indexOf video
          scope.equipment=video
          if index >= 0 and index != scope.flag
            scope.nums[index] = index
            scope.playing = false if _.every scope.nums, (num)->isNaN(num) is false
          else
            scope.playing=true
            scope.nums[scope.flag]=video

      scope.setWindow= (index)->
        scope.flag = index

      scope.playAll= ->
#        console.log "---播放所有----"
#        console.log scope
        return if scope.playing is true
        scope.playing = true
        for num, index in scope.nums
          scope.nums[index] = scope.videos[index] if scope.videos[index]
          scope.$applyAsync()

      scope.stopAll= ->
#        console.log "---停止所有-----"
#        console.log scope
        return if scope.playing is false
        scope.playing = false
        for num, index in scope.nums
          scope.nums[index] = index

      scope.operation= (oid)->
        video = scope.nums[scope.flag]
        if isNaN video
          video.loadCommands null, (err, cmds)=>
            cmd = _.find cmds, (cd)->cd.model.command is oid
            if cmd
              executeCommand2 cmd
              subscribeOperationResult cmd
            else
              @display "摄像头不支持该操作"
#              M.toast({html:'摄像头不支持该操作'})
        else
          @display "请选定摄像头"
#          M.toast({html:'请选定摄像头'})

      subscribeOperationResult: (cmd)->
        filter =
          user: cmd.model.user
          project: cmd.model.project
          station: cmd.model.station
          equipment: cmd.model.equipment
        scope.oneSubscription?.dispose()
        scope.oneSubscription = @commandLiveSession.subscribeValues filter, (err, d) =>
          return if not d
          @display "控制失败" if d.message.phase is "error"
          @display "控制超时" if d.message.phase is "timeout"
#          M.toast({html:'控制失败'}) if d.message.phase is "error"
#          M.toast({html:'控制超时'}) if d.message.phase is "timeout"

      scope.filterVideo= (video)=>
        return true if not scope.search or scope.search is ""
        return true if video.model.equipment.indexOf(scope.search)>=0
        return true if video.model.name.indexOf(scope.search)>=0
        return false

      clearVideo= ->
        scope.video = null


      scope.selectTemplate= ()->
        scope.video.model.vendor = (_.find videoTemplates, (template) => template.model.template is scope.video.model.template)?.model.vendor
        if scope.operateFlag == 1
          switch scope.video.model.template
            when 'video_template'
              scope.video.model?.address = scope.rtspprefix + scope.video.model.rtspip
            when  'ipvideo_template'
              scope.video.model?.address = 'rtmp://lab.huayuan-iot.com:9641/live/9H200A1700017_camera1'
            when 'ckvideo_template'
              scope.video.model?.address = 'http://vshare.ys7.com:80/hcnp/472637161_1_1_1_0_www.ys7.com_6500.m3u8'
        else
          #scope.video.model.address = scope.video.model.rtspip if scope.video.model.template is "video_template"
          if scope.video.model.template is "video_template"
            scope.video.model.address = scope.video.getPropertyValue "rtsp"
            scope.video.model.rtspip = scope.video.model.address?.split('@')[1]
          scope.video.model.address = scope.video.getPropertyValue "http" if scope.video.model.template is "ckvideo_template"
          scope.video.model.address = scope.video.getPropertyValue "rtmp" if scope.video.model.template is "ipvideo_template"
          return 0

      scope.createVideo= ->
#        operateFlag 1为新增摄像头 2为编辑摄像头
        scope.operateFlag = 1
        model =
          type: "video"
          enable: true
        clearVideo()
        scope.video = scope.station.createEquipment model
#        新增时 默认设置为rtsp模板（video_template）
        scope.video.model?.template = 'video_template'
        scope.video.model.rtspip = '192.168.50.50'
        scope.video.model?.address = scope.rtspprefix + scope.video.model.rtspip
        scope.equipment = scope.video
        scope.video

      scope.editVideo= ->
        scope.operateFlag = 2
        scope.video = scope.nums[scope.flag]
        scope.video.loadProperties null, (err, properties) =>
          if scope.video.model.template is "video_template"
            scope.video.model.address = scope.video.getPropertyValue "rtsp"
            scope.video.model.rtspip = scope.video.model.address?.split('@')[1]
          scope.video.model.address = scope.video.getPropertyValue "http" if scope.video.model.template is "ckvideo_template"
          scope.video.model.address = scope.video.getPropertyValue "rtmp" if scope.video.model.template is "ipvideo_template"

      scope.$watch 'video.model.rtspip',(data)->
#        在编辑摄像头时 修改了rtsp摄像头的ip的情况下自动同步修改其address
        return if not data
        scope.video.model.address = scope.rtspprefix + data

      scope.openIE= ()=>
        urlstr = "http://"+scope.controller?.$location?.$$host+":"+scope.controller?.$location?.$$port+'/'+scope.controller?.project.type+"/#/video_histroy_list/"+scope.project?.model?.user+"/"+scope.project?.model?.project+"?token="+scope.controller?.$rootScope?.user?.token
        if !(! !window.ActiveXObject or 'ActiveXObject' of window)
          window.location.href = "openIE:" + urlstr
        else
          window.location.href =urlstr
      scope.openHighReliable= ()=>
        if scope.videos.length == 0
          M.toast({html:"没有找到摄像头！", displayLength:3500} )
          return
        urlstr = "http://"+scope.controller?.$location?.$$host+":"+scope.controller?.$location?.$$port+'/'+scope.controller?.project.type+"/#/video_reliable_list/"+scope.project?.model?.user+"/"+scope.project?.model?.project+"?token="+scope.controller?.$rootScope?.user?.token
        if !(! !window.ActiveXObject or 'ActiveXObject' of window)
          window.location.href = "openIE:" + urlstr
        else
          window.location.href =urlstr

      scope.saveVideo= ->
        if !scope.video.model.equipment
          M.toast({html:"请输入设备ID！", displayLength:1500} )
          return
        if !scope.video.model.name
          M.toast({html:"请输入设备名称！", displayLength:1500} )
          return
        if !scope.video.model.rtspip
          M.toast({html:"请输入设备IP！", displayLength:1500} )
          return
        scope.video.loadProperties null, (err, data)=>
          return if err or data.length < 1
          scope.video.setPropertyValue('rtsp', scope.video.model.address) if scope.video.model.template is "video_template"
          scope.video.setPropertyValue('http', scope.video.model.address) if scope.video.model.template is "ckvideo_template"
          scope.video.setPropertyValue('rtmp', scope.video.model.address) if scope.video.model.template is "ipvideo_template"
#          @saveEquipment (err, model) =>
          scope.equipment.save (err, model) =>
            scope.operateFlag = 0
            $("#video-modal").modal 'close'
            #@loadStationVideos @station, null, true
            index = _.find scope.videos, (vd)=>vd.key is scope.video.key
            scope.videos.splice index, 1 if index
            scope.videos.push scope.video
          , scope.video
        , true

      scope.removeVideo= ->
        @prompt "确认删除", "是否确认删除该视频设备？", (ok)=>
          return if not ok
          scope.video.remove (err, model)=>
            $("#video-modal").modal 'close'
            vd = _.find scope.videos, (vd)=>vd.key is model[0].user+"_"+model[0].project+"_"+model[0].station+"_"+model[0].equipment
            scope.videos.splice _.indexOf(scope.videos, vd), 1 if vd
            scope.nums[scope.flag] = null

      scope.screenShot= ()=>
        currentVideo = scope.nums[scope.flag]
        #console.log currentVideo
        if _.isNumber currentVideo
          return
        currentVideo.loadSignals null,(err, signals)=>
          imageScreenShot = _.find signals, (signal)=>signal.model.signal is 'imageName'
          #console.log imageScreenShot
          model = currentVideo.model
          filter =
            user: model.user
            project: model.project
            station: model.station
            equipment: model.equipment
            signal: imageScreenShot.model.signal

          scope.signalSubscription?.dispose()
          scope.signalSubscription = @signalLiveSession.subscribeValues filter, (err, d) =>
  #console.log d
            return if not d
            signal = scope.project.getSignalByTopic d.topic
            if signal
              signal.setValue d.message
            if d.message.signal is 'imageName'
              scope.imagePath = d.message.value
        currentVideo.loadCommands null, (err, commands) =>
          screenShot = _.find commands, (command)=>command.model.command is 'screen-shot'
          #console.log screenShot
          executeCommand2 screenShot

      scope.searchSubscription = @commonService.subscribeEventBus 'search',(msg)=>
        scope.search = msg.message
        scope.$applyAsync()

    resize: (scope)->

    dispose: (scope)->
      scope.searchSubscription?.dispose()
      scope.videoState?.dispose()

  exports =
    VideoListDirective: VideoListDirective