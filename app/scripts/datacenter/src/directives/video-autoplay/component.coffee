###
* File: video-autoplay-directive
* User: David
* Date: 2020/03/02
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['jquery','../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], ($,base, css, view, _, moment) ->
  class VideoAutoplayDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "video-autoplay"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      $('.fullscreen').hide()
      $scope.player.dispose() if $scope.player
      $scope.$watch 'equipment',(equip)=>
        if not equip or not equip.model
          $scope.player.dispose() if $scope.player
          return
        @$timeout ->
          src = equip?.getPropertyValue('url') || equip?.getPropertyValue('rtsp')
          if src !="" &&src !=undefined
#            如果设备属性里有 url 或者 rtsp
            playInVXGPLAYER src,equip
          else
            playInCKPLAYER()
        ,100
      playInVXGPLAYER =(src,equip) =>
        player1Id= "player1-"+equip.model.equipment
        playerId = "player-"+equip.model.equipment
        $scope.playerId = playerId
        width =  parseInt $('#'+player1Id).width()
        height =  parseInt $('#'+player1Id).height()
#        $scope.$applyAsync()
        try
          $scope.player = vxgplayer(playerId,{
            url: '',
            nmf_path: 'media_player.nmf',
            nmf_src: '/lib/vxgplayer/pnacl/Release/media_player.nmf',
            latency:300,
            aspect_ratio_mode: 1,
            autohide: 3,
            controls: true,
            connection_timeout: 50000,
            connection_udp: 0,
            custom_digital_zoom: false

          }).ready(()->
            console.log(' =>ready to player '+playerId,src);
            $scope.player = vxgplayer(playerId);
            vxgplayer(playerId).size(width,height);
            vxgplayer(playerId).src(src);
            vxgplayer(playerId).autoreconnect(1);
            vxgplayer(playerId).controls(true);
            #            vxgplayer(playerId).debug(true)
            vxgplayer(playerId).play();
            if !$scope.controller?.errorvxgobj?.includes(vxgplayer(playerId)) && $scope.controller?.errorvxgobj
              $scope.controller.errorvxgobj?.push(vxgplayer(playerId))

            vxgplayer(playerId).onError((player)=>
              $scope.player.size(width,height);
              console.log(player.error())
              if $scope.controller.errorvxgobj
                for itemobj in $scope.controller.errorvxgobj
                  itemobj.autoreconnect(1)
            )
            vxgplayer(playerId).onBandwidthError((player)=>
              $scope.player.size(width,height);
              console.log(player.error())
              if $scope.controller.errorvxgobj
                for itemobj in $scope.controller.errorvxgobj
                  itemobj.autoreconnect(1)
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
    VideoAutoplayDirective: VideoAutoplayDirective