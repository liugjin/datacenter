###
* File: single-video-directive
* User: David
* Date: 2019/02/22
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['jquery','../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], ($,base, css, view, _, moment) ->
  class SingleVideoDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "single-video"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      $scope.errorNum=0
      $scope.player.dispose() if $scope.player
      $scope.$watch 'equipment',(equip)=>
        if not equip or not equip.model
          $scope.player.dispose() if $scope.player
          return
        #        console.log(equip)
        @$timeout ->
          #src = $scope.equipment?.getPropertyValue('url') || $scope.equipment?.getPropertyValue('rtsp') || $scope.equipment?.getPropertyValue('http')
          src = equip?.getPropertyValue('url') || equip?.getPropertyValue('rtsp')
          if src !="" &&src !=undefined
#            如果设备属性里有 url 或者 rtsp
#            console.log "用vxgplaryer播放视频流"
            playInVXGPLAYER src,equip
          else
#            console.log "用ckplayer播放视频流"
            playInCKPLAYER()
        ,100

      playInCKPLAYER = ->
        playerId = "player-"+$scope.equipment.model.equipment
        src = $scope.equipment?.getPropertyValue('rtmp') || $scope.equipment?.getPropertyValue('http')
        if src == "" || src == undefined
          src = $scope.equipment?.getPropertyValue('hls')

        if src == "" || src == undefined
#          如果设备属性里 没有 url rtsp     也没有 rtmp http hls
#          $scope.controller.prompt '错误',$scope.equipment.model.name+'rtmp或者hls属性为空'
#          $scope.controller.prompt '错误',$scope.equipment.model.name+' rtmp或者hls属性为空'
          @prompt '错误',$scope.equipment.model.name+' rtmp或者hls属性为空'
        #          console.log 'rtmp或者hls属性为空'

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

      playInVXGPLAYER =(src,equip) =>
        playerId = "player-"+equip.model.equipment
        $scope.playerId = playerId
        width =  parseInt $('#'+playerId).width()
        height =  parseInt $('#'+playerId).height()
        $scope.$applyAsync()
        try
          $scope.player = vxgplayer(playerId,{
            url: '',
            nmf_path: 'media_player.nmf',
            nmf_src: '/lib/vxgplayer/pnacl/Release/media_player.nmf',
            latency: 300,
            aspect_ratio_mode: 1,
            autohide: 3,
            controls: true,
            connection_timeout: 50000,
            connection_udp: 0,
            custom_digital_zoom: false

          }).ready(()->
            console.log(' =>ready to player '+playerId,src);
            $scope.player = vxgplayer(playerId);
            vxgplayer(playerId).src(src);
            vxgplayer(playerId).size(width,height);
            vxgplayer(playerId).autoreconnect(1);
            vxgplayer(playerId).controls(true);
            #            vxgplayer(playerId).debug(true)
            vxgplayer(playerId).play();
            if !$scope.controller?.errorvxgobj?.includes(vxgplayer(playerId)) && $scope.controller?.errorvxgobj
              $scope.controller.errorvxgobj?.push(vxgplayer(playerId)) 

            vxgplayer(playerId).onError((player)=>
              console.log(player.error()+'-'+$scope.errorNum++)
              if $scope.controller.errorvxgobj
                for itemobj in $scope.controller.errorvxgobj
                  itemobj.autoreconnect(1)
#              vxgplayer(playerId).autoreconnect(1)
            )
            vxgplayer(playerId).onBandwidthError((player)=>
              console.log(player.error()+'-'+$scope.errorNum++)
              if $scope.controller.errorvxgobj
                for itemobj in $scope.controller.errorvxgobj
                  itemobj.autoreconnect(1)
            )

          )

        catch error
          console.log error

      reconnectalways =(pid) ->


      $scope.$watch "controller.$rootScope.flag", (flag)=>
#        console.log "-----watch flag----"
#        console.log flag
        if $scope.player
          @$timeout ->
            width =  parseInt element.width()
            height =  parseInt element.height()
            $scope.player.size(width,height)
          ,100

    resize: ($scope)->
      win = angular.element $scope.controller.$window
      win.bind 'resize', ()=>
        @$timeout ->
          $('.vxgplayer').css("width","100%")
        ,500

    dispose: ($scope)->
      $scope.player?.dispose()


  exports =
    SingleVideoDirective: SingleVideoDirective
