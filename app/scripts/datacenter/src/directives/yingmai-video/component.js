// Generated by IcedCoffeeScript 108.0.13

/*
* File: yingmai-video-directive
* User: David
* Date: 2019/02/15
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var YingmaiVideoDirective, exports;
  YingmaiVideoDirective = (function(_super) {
    __extends(YingmaiVideoDirective, _super);

    function YingmaiVideoDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "yingmai-video";
      YingmaiVideoDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    YingmaiVideoDirective.prototype.setScope = function() {};

    YingmaiVideoDirective.prototype.setCSS = function() {
      return css;
    };

    YingmaiVideoDirective.prototype.setTemplate = function() {
      return view;
    };

    YingmaiVideoDirective.prototype.show = function($scope, element, attrs) {
      var checkChildren, playInCKPLAYER, playInVXGPLAYER;
      if (!$scope.firstload) {
        return;
      }
      $scope.cardTitle = "视频";
      $scope.subTitle = "Video";
      $scope.$watch('equipment', (function(_this) {
        return function(equipment) {
          if (!equipment) {
            return;
          }
          console.log("----watch equipment-----");
          console.log(equipment);
          if (!equipment) {
            if ($scope.player) {
              $scope.player.dispose();
            }
            return console.log("没有视频设备，不进行播放");
          } else {
            return _this.$timeout(function() {
              var src, _ref, _ref1, _ref2;
              src = (_ref = (_ref1 = $scope.equipment) != null ? _ref1.getPropertyValue('url') : void 0) != null ? _ref : (_ref2 = $scope.equipment) != null ? _ref2.getPropertyValue('rtsp') : void 0;
              if (src !== "" && src !== void 0) {
                console.log("用vxgplaryer播放视频流");
                console.log(src);
                return playInVXGPLAYER(src);
              } else {
                console.log("用ckplayer播放视频流");
                return playInCKPLAYER();
              }
            }, 100);
          }
        };
      })(this));
      $scope.selectVideo = (function(_this) {
        return function(video) {
          return $scope.equipment = video;
        };
      })(this);
      $scope.$watch('station', (function(_this) {
        return function(sta) {
          $scope.videos = [];
          checkChildren(sta);
          return _this.$timeout(function() {
            if ($scope.videos.length) {
              return $scope.selectVideo($scope.videos[0]);
            }
          }, 1000);
        };
      })(this));
      checkChildren = (function(_this) {
        return function(sta) {
          var item, _i, _len, _ref, _results;
          if (sta.stations.length > 0) {
            _ref = sta.stations;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              item = _ref[_i];
              if (item.stations.length > 0) {
                _results.push(checkChildren(item));
              } else {
                _results.push(_this.commonService.loadEquipmentsByTemplate(item, 'video_template', function(err, d) {
                  if (d.length) {
                    _.map(d, function(itemdata) {
                      return itemdata.loadProperties();
                    });
                    return $scope.videos = $scope.videos.concat(d);
                  }
                }));
              }
            }
            return _results;
          } else {
            return _this.commonService.loadEquipmentsByTemplate(sta, 'video_template', function(err, d) {
              if (d.length) {
                _.map(d, function(itemdata) {
                  return itemdata.loadProperties();
                });
                return $scope.videos = $scope.videos.concat(d);
              }
            });
          }
        };
      })(this);
      playInCKPLAYER = function() {
        var player, playerId, src, videoObject, _ref, _ref1, _ref2;
        playerId = "player-" + $scope.equipment.model.equipment;
        src = ((_ref = $scope.equipment) != null ? _ref.getPropertyValue('rtmp') : void 0) || ((_ref1 = $scope.equipment) != null ? _ref1.getPropertyValue('http') : void 0);
        if (src === "" || src === void 0) {
          src = (_ref2 = $scope.equipment) != null ? _ref2.getPropertyValue('hls') : void 0;
        }
        if (src === "" || src === void 0) {
          $scope.controller.prompt('错误', $scope.equipment.model.name + ' rtmp或者hls属性为空');
          console.log('rtmp或者hls属性为空');
        }
        videoObject = {
          container: '#' + playerId,
          variable: 'player',
          autoplay: true,
          video: src
        };
        return player = new ckplayer(videoObject);
      };
      playInVXGPLAYER = function(src) {
        var error, height, playerId, width;
        playerId = "yingmai-player-" + $scope.equipment.model.equipment;
        $scope.playerId = playerId;
        width = parseInt($('#' + playerId).width());
        height = parseInt($('#' + playerId).height());
        try {
          return vxgplayer(playerId, {
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
          }).ready(function() {
            console.log(' =>ready to player ' + playerId, src);
            $scope.player = vxgplayer(playerId);
            vxgplayer(playerId).src(src);
            vxgplayer(playerId).size(width, height);
            vxgplayer(playerId).onError((function(_this) {
              return function(player) {
                console.log(player.error());
                return player.autoreconnect(1);
              };
            })(this));
            vxgplayer(playerId).play();
            return vxgplayer(playerId).autoreconnect(1);
          });
        } catch (_error) {
          error = _error;
          return console.log(error);
        }
      };
      $scope.$watch('testwidth', function(wid) {
        var hei, _ref;
        hei = $scope.testheight;
        return (_ref = $scope.player) != null ? _ref.size(wid, hei) : void 0;
      });
      $scope.resize = (function(_this) {
        return function() {
          return _this.$timeout(function() {
            $scope.testwidth = parseInt($('.video').width());
            return $scope.testheight = parseInt($('.video').height());
          }, 100);
        };
      })(this);
      window.addEventListener('resize', $scope.resize);
      return $scope.hidemodal = function() {
        return $('#yingmai-new-modal').modal('close');
      };
    };

    YingmaiVideoDirective.prototype.resize = function($scope) {};

    YingmaiVideoDirective.prototype.dispose = function($scope) {
      var _ref;
      if ((_ref = $scope.stationSubscribe) != null) {
        _ref.dispose();
      }
      if ($scope.player) {
        $scope.player.dispose();
      }
      return window.removeEventListener('resize', $scope.resize);
    };

    return YingmaiVideoDirective;

  })(base.BaseDirective);
  return exports = {
    YingmaiVideoDirective: YingmaiVideoDirective
  };
});
