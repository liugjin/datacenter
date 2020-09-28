###
* File: yingmai-video-directive
* User: David
* Date: 2019/02/15
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class YingmaiVideoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "yingmai-video"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      return if not $scope.firstload
      $scope.cardTitle = "视频"
      $scope.subTitle = "Video"

      $scope.$watch 'equipment',(equipment)=>
        return if not equipment
        console.log "----watch equipment-----"
        console.log equipment
        if not equipment
          $scope.player.dispose() if $scope.player
          return console.log("没有视频设备，不进行播放")
        else
          @$timeout ->
            #src = $scope.equipment?.getPropertyValue('url') || $scope.equipment?.getPropertyValue('rtsp') || $scope.equipment?.getPropertyValue('http')
            src = $scope.equipment?.getPropertyValue('url') ? $scope.equipment?.getPropertyValue('rtsp')
            if src !="" &&src !=undefined
              #  如果设备属性里有 url 或者 rtsp
              console.log "用vxgplaryer播放视频流"
              console.log src
              playInVXGPLAYER src
            else
              console.log "用ckplayer播放视频流"
              playInCKPLAYER()
          ,100


      $scope.selectVideo = (video)=>
        # publish equipmentId
        $scope.equipment = video

      # 加载站点内的摄像头
      $scope.$watch 'station',(sta)=>
#        console.log "-----watch station------"
#        console.log sta
        $scope.videos = []
        #根据站点切换 得到站点下的所有灯控模块 放到lightBlocks对象里
        checkChildren(sta)
        @$timeout ()=>
#          console.log "----------videos------------"
#          console.log $scope.videos
          $scope.selectVideo $scope.videos[0] if $scope.videos.length
        ,1000

      checkChildren = (sta)=>
        if sta.stations.length > 0
          for item in sta.stations
            if item.stations.length > 0
              checkChildren(item)
            else
              @commonService.loadEquipmentsByTemplate item,'video_template',(err,d)=>
#                console.log "-----load站点模板视频设备------"
#                console.log d
                if d.length
                  _.map d,(itemdata)=>
                    itemdata.loadProperties()
                  $scope.videos = $scope.videos.concat d
        else
          @commonService.loadEquipmentsByTemplate sta,'video_template',(err,d)=>
#            console.log "-----load站点模板设备------"
#            console.log d
            if d.length
              _.map d,(itemdata)=>
                itemdata.loadProperties()
              $scope.videos = $scope.videos.concat d


      playInCKPLAYER = ->
        playerId = "player-"+$scope.equipment.model.equipment
        src = $scope.equipment?.getPropertyValue('rtmp') || $scope.equipment?.getPropertyValue('http')
        if src == "" || src == undefined
          src = $scope.equipment?.getPropertyValue('hls')

        if src == "" || src == undefined
#          如果设备属性里 没有 url rtsp     也没有 rtmp http hls
#          $scope.controller.prompt '错误',$scope.equipment.model.name+'rtmp或者hls属性为空'
          $scope.controller.prompt '错误',$scope.equipment.model.name+' rtmp或者hls属性为空'
          console.log 'rtmp或者hls属性为空'

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
        player=new ckplayer(videoObject)

      playInVXGPLAYER =(src) ->
        playerId = "yingmai-player-"+$scope.equipment.model.equipment
        $scope.playerId = playerId
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
            $scope.player = vxgplayer(playerId);
            vxgplayer(playerId).src(src);
            vxgplayer(playerId).size(width,height);
            vxgplayer(playerId).onError((player)=>
              console.log(player.error())
              player.autoreconnect(1)
            )
            vxgplayer(playerId).play();
            vxgplayer(playerId).autoreconnect(1);

          )
        catch error
          console.log error

#     窗口缩放 直播窗口自适应容器宽度
      $scope.$watch 'testwidth',(wid)->
        hei = $scope.testheight
        $scope.player?.size(wid,hei)
      $scope.resize=()=>
        @$timeout ->
          $scope.testwidth = parseInt $('.video').width()
          $scope.testheight = parseInt $('.video').height()
        ,100
      window.addEventListener 'resize', $scope.resize


      $scope.hidemodal = ()->
        $('#yingmai-new-modal').modal('close')

    resize: ($scope)->

    dispose: ($scope)->
      $scope.stationSubscribe?.dispose()
      $scope.player.dispose() if $scope.player
      window.removeEventListener 'resize',$scope.resize


  exports =
    YingmaiVideoDirective: YingmaiVideoDirective

