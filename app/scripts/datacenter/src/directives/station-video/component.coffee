###
* File: station-video-directive
* User: David
* Date: 2019/08/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class StationVideoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "station-video"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.videoImg=@getComponentPath("images/1.mp4")
      scope.playVideo = (equipment) =>
        return if equipment is scope.equipment
        scope.equipment = equipment
        scope.player?.dispose()
        equipment.loadProperties null, (err, properties) =>
          @$timeout =>
            src = equipment?.getPropertyValue('url') ? equipment?.getPropertyValue('rtsp')
            if src !="" &&src != undefined
              @playInVXGPLAYER scope, src
            else
              @playInCKPLAYER scope
          ,100

      #      scope.hideModal = ()->
      #        $('#tip-modal').modal('close')

      scope.videos = []
      stations = @commonService.loadStationChildren scope.station, true
      n = 0
      if stations?
        for station in stations
          station.loadEquipments {type:"video"}, null, (err, videos) =>
            n++
            scope.videos = scope.videos.concat videos
            if n is stations.length
              equipment = _.max scope.videos, (equip)->equip.model.index
              scope.playVideo equipment

    playInCKPLAYER: (scope) ->
      playerId = "player-"+scope.equipment.model.equipment
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
      playerId = "player"
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
          vxgplayer(playerId).onError((player)=>
            console.log(player.error())
            vxgplayer(playerId).autoreconnect(1)
          )
          vxgplayer(playerId).play();
        )
      catch error
        console.log error
        $(".vxgplayer-unsupport").remove()
        $("#player").append( "<video muted='muted' autoplay='autoplay' loop='loop' src='"+scope.videoImg+"' style='height:"+height+"px;width:"+width+"px'></video>")
#          $('#tip-modal').modal('open')
#          setTimeout ()->
#            $('.modal-overlay').css({"opacity":"0.7"})
#            $('#tip-modal').css({"top":"260px","background-color":"rgb(26, 69, 162,0.4)","visibility":"visible"})
#          ,500

    resize: (scope)->
      @$timeout ->
        width = parseInt $('.video').width()
        height = parseInt $('.video').height()
        scope.player?.size width, height
      ,100

    dispose: (scope)->
      scope.player?.dispose()


  exports =
    StationVideoDirective: StationVideoDirective