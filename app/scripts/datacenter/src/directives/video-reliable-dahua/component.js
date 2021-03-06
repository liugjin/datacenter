// Generated by IcedCoffeeScript 108.0.13

/*
* File: video-history-directive
* User: region
* Date: 2019/04/10
* Desc:
 */
var __iced_k, __iced_k_noop,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

__iced_k = __iced_k_noop = function() {};

if (typeof define !== 'function') { var define = require('amdefine')(module) };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var VideoReliableDahuaDirective, exports;
  VideoReliableDahuaDirective = (function(_super) {
    __extends(VideoReliableDahuaDirective, _super);

    function VideoReliableDahuaDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "video-reliable-dahua";
      VideoReliableDahuaDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    VideoReliableDahuaDirective.prototype.setScope = function() {};

    VideoReliableDahuaDirective.prototype.setCSS = function() {
      return css;
    };

    VideoReliableDahuaDirective.prototype.setTemplate = function() {
      return view;
    };

    VideoReliableDahuaDirective.prototype.show = function(scope, element, attrs) {
      var loadStationVideos, station, _i, _len, _ref, _ref1;
      scope.videospng = this.getComponentPath('image/video/videos.png');
      scope.videopng = this.getComponentPath('image/video/video.png');
      scope.gridStatus = "start";
      scope.recordfilename = "";
      scope.viewstatus = [];
      scope.pageStatus = [];
      scope.maskLayer = false;
      scope.timedate = moment().format('YYYY-MM-DD');
      scope.datacenters = [];
      scope.g_iWndNum = 4;
      scope.g_iWndIndex = 0;
      scope.viewstatus = [];
      scope.holewidth = $('#contentdiv').width();
      scope.hoelheight = $('#contentdiv').height();
      scope.OpenFileDlgType = 0;
      scope.downloadFileName = "";
      _ref = scope.project.stations.items;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        station = _ref[_i];
        if (station.stations.length > 0) {
          scope.datacenters.push(station);
        }
      }
      if (scope.datacenters.length > 0) {
        scope.datacenter = scope.datacenters[0];
      } else {
        scope.datacenter = scope.project;
      }
      scope.selectStation = function(station) {
        loadStationVideos(station);
        WebVideoCtrl.insertPluginObject("divPlugin", scope.holewidth, scope.hoelheight);
        WebVideoCtrl.initPlugin((function(_this) {
          return function() {
            WebVideoCtrl.setSplitNum(scope.g_iWndNum);
            WebVideoCtrl.enablePreviewDBClickFullSreen(true);
            WebVideoCtrl.addEventListener("DownloadByTimePos", function(eventParam) {
              scope.pos = eventParam["pos"];
              scope.speed = eventParam["speed"];
              scope.end = eventParam["end"];
              return scope.g_iWndIndex;
            });
            WebVideoCtrl.addEventListener("ChnlInfo", function(eventParam) {
              scope.channelNum = eventParam["ChanNum"];
              return scope.g_iWndIndex;
            });
            WebVideoCtrl.addEventListener("ReturnWindInfo", function(eventParam) {
              scope.g_iWndIndex = eventParam["winID"];
              return scope.g_iWndIndex;
            });
            return WebVideoCtrl.addEventListener("NetPlayState", function(eventParam) {
              scope.g_iWndIndex = eventParam["winID"];
              return scope.g_iWndIndex;
            });
          };
        })(this));
        return true;
      };
      scope.setGridOptions = function(rows, cols, setting) {
        if (setting == null) {
          setting = false;
        }
        return scope.gridOptions = {
          rows: rows,
          cols: cols,
          setting: setting
        };
      };
      scope.getvideostate = function(videopara) {
        return videopara != null ? videopara.loadProperties(null, (function(_this) {
          return function(err, properties) {
            var equipType, hasFinish, img, ippara, rtspobj, start, _ref1, _ref2, _ref3, _ref4;
            ippara = "192.168.1.1";
            equipType = videopara.model.vendor;
            rtspobj = _.find(properties, function(property) {
              return property.model.property === "rtsp";
            });
            if (rtspobj != null) {
              ippara = (_ref1 = rtspobj.value.split('rtsp://')) != null ? (_ref2 = _ref1[1].split(':')) != null ? (_ref3 = _ref2[1].split('@')) != null ? (_ref4 = _ref3[1].split('/')) != null ? _ref4[0] : void 0 : void 0 : void 0 : void 0;
            } else {
              console.log(videopara.model.name + "rtsp属性错误");
            }
            img = new Image();
            start = new Date().getTime();
            hasFinish = false;
            if (videopara.model.vendor === "hikvision") {
              img.src = 'http://' + ippara + '/favicon.ico';
            } else if (videopara.model.vendor === "dahua") {
              img.src = 'http://' + ippara + '/image/loginlogo-dh.jpg';
            }
            img.onload = function(successmsg) {
              if (!hasFinish) {
                hasFinish = true;
                videopara.onlineflag = true;
                return scope.$applyAsync();
              }
            };
            return img.onerror = function(errormsg) {
              if (!hasFinish) {
                hasFinish = true;
                videopara.onlineflag = false;
                return scope.$applyAsync();
              }
            };
          };
        })(this)) : void 0;
      };
      loadStationVideos = function(station, callback, refresh) {
        var mds;
        mds = [];
        return station.loadEquipments({
          project: station.model.project,
          type: 'video'
        }, null, (function(_this) {
          return function(err, model) {
            var equip, i, md, sta, video, ___iced_passed_deferral, __iced_deferrals, __iced_k;
            __iced_k = __iced_k_noop;
            ___iced_passed_deferral = iced.findDeferral(arguments);
            (function(__iced_k) {
              var _j, _len1, _ref1, _results, _while;
              _ref1 = station.stations;
              _len1 = _ref1.length;
              i = 0;
              _while = function(__iced_k) {
                var _break, _continue, _next;
                _break = __iced_k;
                _continue = function() {
                  return iced.trampoline(function() {
                    ++i;
                    return _while(__iced_k);
                  });
                };
                _next = _continue;
                if (!(i < _len1)) {
                  return _break();
                } else {
                  sta = _ref1[i];
                  (function(__iced_k) {
                    __iced_deferrals = new iced.Deferrals(__iced_k, {
                      parent: ___iced_passed_deferral,
                      filename: "F:\\clc.datacenter\\app\\scripts\\datacenter\\src\\directives\\video-reliable-dahua\\component.coffee"
                    });
                    sta.loadEquipments({
                      project: station.model.project,
                      type: 'video'
                    }, null, __iced_deferrals.defer({
                      assign_fn: (function(__slot_1, __slot_2) {
                        return function() {
                          err = arguments[0];
                          return __slot_1[__slot_2] = arguments[1];
                        };
                      })(mds, i),
                      lineno: 128
                    }));
                    __iced_deferrals._fulfill();
                  })(_next);
                }
              };
              _while(__iced_k);
            })(function() {
              var _j, _k, _l, _len1, _len2, _len3, _ref1;
              if (!err) {
                for (_j = 0, _len1 = mds.length; _j < _len1; _j++) {
                  md = mds[_j];
                  model = model.concat(md);
                }
                scope.videos = model;
                _ref1 = scope.videos;
                for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                  video = _ref1[_k];
                  scope.getvideostate(video);
                }
                scope.setGridOptions(2, 2, true);
                for (_l = 0, _len3 = model.length; _l < _len3; _l++) {
                  equip = model[_l];
                  equip.loadCommands(null, function() {
                    return console.log("先不订阅，在选中具体摄像头时订阅");
                  }, refresh);
                  equip.loadSignals(null, function(err, data) {
                    if (data[0]) {
                      return console.log("先不订阅，在选中具体摄像头时订阅");
                    }
                  });
                }
              }
              return typeof callback === "function" ? callback(err, model) : void 0;
            });
          };
        })(this), refresh);
      };
      scope.loadUsers = function() {
        return scope.users = scope.project.model.starUsers;
      };
      if (!(!!window.ActiveXObject || 'ActiveXObject' in window)) {
        this.display("请使用IE浏览器查看");
        return;
      }
      scope.selectStation(scope.station);
      scope.loadUsers();
      if ((_ref1 = scope.searchSubscription) != null) {
        _ref1.dispose();
      }
      scope.searchSubscription = this.commonService.subscribeEventBus('search', (function(_this) {
        return function(msg) {
          scope.search = msg.message;
          return scope.$applyAsync();
        };
      })(this));
      scope.filterVideo = (function(_this) {
        return function(video) {
          if (!scope.search || scope.search === "") {
            return true;
          }
          if (video.model.equipment.indexOf(scope.search) >= 0) {
            return true;
          }
          if (video.model.name.indexOf(scope.search) >= 0) {
            return true;
          }
          return false;
        };
      })(this);
      scope.selectVideo = (function(_this) {
        return function(video, index, playstatus) {
          var ipstr, pwdstr, rtspstr, somethingstr, userstr, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
          if (playstatus == null) {
            playstatus = false;
          }
          scope.equipment = video;
          if (scope.viewstatus.indexOf(video) === -1) {
            scope.viewstatus.push(video);
          }
          rtspstr = "";
          rtspstr = video.getPropertyValue('rtsp');
          if (rtspstr === "" || rtspstr === null) {
            M.toast({
              html: '请设置摄像头的RTSP属性值！！'
            }, 3000);
            return;
          }
          somethingstr = (_ref2 = rtspstr.split('rtsp://')) != null ? _ref2[1] : void 0;
          userstr = (_ref3 = somethingstr.split(':')) != null ? _ref3[0] : void 0;
          pwdstr = (_ref4 = somethingstr.split(':')) != null ? (_ref5 = _ref4[1].split('@')) != null ? _ref5[0] : void 0 : void 0;
          ipstr = (_ref6 = somethingstr.split(':')) != null ? (_ref7 = _ref6[1].split('@')) != null ? (_ref8 = _ref7[1].split('/')) != null ? _ref8[0] : void 0 : void 0 : void 0;
          scope.ret = WebVideoCtrl.login(ipstr, 37777, userstr, pwdstr, 0);
          if (scope.ret === 0) {
            console.log("login successed");
            return WebVideoCtrl.connectRealVideoEx(0, 2, scope.g_iWndIndex);
          } else {
            return M.toast({
              html: '摄像头登录失败，errorcode:' + ret
            }, 3000);
          }
        };
      })(this);
      scope.nvrLogin = function(options) {
        var iRet, isinstalled;
        scope.channelid = options.channel;
        if (!options.nvrip) {
          return;
        }
        scope.szip = options.nvrip;
        isinstalled = WebVideoCtrl.I_CheckPluginInstall();
        WebVideoCtrl.I_InitPlugin(holewidth, hoelheight - 100, {
          iWndowType: 2,
          cbSelWnd: (function(_this) {
            return function(xmlDoc) {
              var g_iWndIndex;
              return g_iWndIndex = $(xmlDoc).find("SelectWnd").eq(0).text();
            };
          })(this)
        });
        WebVideoCtrl.I_InsertOBJECTPlugin("divPlugin");
        iRet = WebVideoCtrl.I_Login(scope.szip, '1', '80', options.nvruser, options.nvrpassword, {
          success: (function(_this) {
            return function(model) {
              return setTimeout(function() {
                getChannelInfo(scope.szip);
                return clickStartPlayback(scope.szip, scope.channelid, moment().format("YYYY-MM-DD") + " 00:00:00", moment().format("YYYY-MM-DD") + " 23:59:59");
              }, 100);
            };
          })(this),
          error: (function(_this) {
            return function(err) {
              return console.log(err);
            };
          })(this)
        });
        return iRet;
      };
      scope.changeLayout = function(number, refresh) {
        scope.g_iWndNum = number;
        return WebVideoCtrl.setSplitNum(scope.g_iWndNum);
      };
      return scope.actionMessage = function(d) {
        var iRet;
        scope.nvrLogin(d.options);
        switch (d.type) {
          case 'I_StartPlayback':
            iRet = WebVideoCtrl.I_Login(d.options.nvrip, '1', '80', d.options.nvruser, d.options.nvrpassword, {
              success: (function(_this) {
                return function(model) {
                  return setTimeout(function() {
                    getChannelInfo(d.options.nvrip);
                    return clickStartPlayback(d.options.nvrip, d.options.channel, moment(d.timeFrom).format("YYYY-MM-DD HH:mm:ss"), moment(d.timeTo).format("YYYY-MM-DD HH:mm:ss"));
                  }, 100);
                };
              })(this),
              error: (function(_this) {
                return function(err) {
                  return console.log(err);
                };
              })(this)
            });
            if (iRet === -1 || iRet === "-1") {
              return clickStartPlayback(d.options.nvrip, d.options.channel, moment(d.timeFrom).format("YYYY-MM-DD HH:mm:ss"), moment(d.timeTo).format("YYYY-MM-DD HH:mm:ss"));
            }
        }
      };
    };

    VideoReliableDahuaDirective.prototype.resize = function(scope) {};

    VideoReliableDahuaDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.searchSubscription) != null ? _ref.dispose() : void 0;
    };

    return VideoReliableDahuaDirective;

  })(base.BaseDirective);
  return exports = {
    VideoReliableDahuaDirective: VideoReliableDahuaDirective
  };
});
