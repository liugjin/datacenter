###
* File: single-video-core-directive
* User: David
* Date: 2019/09/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class SingleVideoCoreDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "single-video-core"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.playVideo = (equipment) =>
        return if not equipment or (!scope.firstload and equipment is scope.equipment)
        scope.equipment = equipment
        scope.player?.dispose()
        equipment.loadProperties null, (err, properties) =>
          @$timeout =>
            src = equipment?.getPropertyValue('url') ? equipment?.getPropertyValue('rtsp')
            if src.indexOf("demo") == 0
              @playDemoVideo scope, src
            else if src?.length > 0
              @playInVXGPLAYER scope, src
            else
              @playInCKPLAYER scope
          ,100

      scope.playVideo scope.equipment

      scope.videos = []
      stations = @commonService.loadStationChildren scope.station, true
      for station in stations
        station.loadEquipments {type:"video"}, null, (err, videos) =>
          scope.videos = scope.videos.concat videos

    playDemoVideo: (scope, src) ->
      playerId = "player-"+scope.equipment.model.equipment+scope.date
      $("#"+playerId).append "<video controls='controls' autoplay='autoplay' loop='loop' src='"+@getComponentPath("video/"+src+".mp4")+"' style='height:100%;width:100%'></video>"
      scope.player =
        dispose: ->$("#"+playerId).empty()

    playInCKPLAYER: (scope) ->
      playerId = "player-"+scope.equipment.model.equipment+scope.date
      src = scope.equipment?.getPropertyValue('rtmp') || scope.equipment?.getPropertyValue('http')
      if src == "" || src == undefined
        src = scope.equipment?.getPropertyValue('hls')

      if src == "" || src == undefined
#          如果设备属性里 没有 url rtsp     也没有 rtmp http hls
#          scope.controller.prompt '错误',scope.equipment.model.name+'rtmp或者hls属性为空'
        scope.controller.prompt '错误',scope.equipment.model.name+' rtmp或者hls属性为空'

      videoObject ={
#        //“#”代表容器的ID，“.”或“”代表容器的class
        container: '#'+playerId
        variable: 'player'
#        //该属性必需设置，值等于下面的new chplayer()的对象
        autoplay:true
#        //自动播放
#          live:true
#          html5m3u8:true
#        视频地址
        video:src
      }
      scope.player=new ckplayer(videoObject)

    playInVXGPLAYER :(scope, src) ->
      playerId = "player-"+scope.equipment.model.equipment+scope.date
      #        scope.playerId = playerId
      width =  parseInt $('#'+playerId).width()
      height =  parseInt $('#'+playerId).height()
      try
        vxgplayer(playerId,{
          url: '',
          nmf_path: 'media_player.nmf',
          nmf_src: '/lib/vxgplayer/pnacl/Release/media_player.nmf',
          latency: 300000,
          aspect_ratio_mode: 1,
          autohide: 3,
          controls: true,
          connection_timeout: 5000,
          connection_udp: 0,
          custom_digital_zoom: false

        }).ready(()->
          console.log(' =>ready to player '+playerId,src);
          scope.player = vxgplayer(playerId);
          vxgplayer(playerId).src(src);
          vxgplayer(playerId).size(width,height);
          vxgplayer(playerId).autoreconnect(1);
          vxgplayer(playerId).controls(true);
          vxgplayer(playerId).play();
          vxgplayer(playerId).onError((player)->
            console.log(player.error())
            scope.player.autoreconnect(1)
          )
          vxgplayer(playerId).onBandwidthError((player)->
            console.log(player.error())
            scope.player.autoreconnect(1)
          )
        )
      catch error
        console.log error

    resize: (scope)->
      @$timeout ->
        width = parseInt $('.video').width()
        height = parseInt $('.video').height()
        scope.player?.size width, height
      ,100

    dispose: (scope)->
      scope.player?.dispose()


  exports =
    SingleVideoCoreDirective: SingleVideoCoreDirective