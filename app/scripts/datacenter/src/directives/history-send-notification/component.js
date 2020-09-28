// Generated by IcedCoffeeScript 108.0.13

/*
* File: history-send-notification-directive
* User: David
* Date: 2020/01/02
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var HistorySendNotificationDirective, exports;
  HistorySendNotificationDirective = (function(_super) {
    __extends(HistorySendNotificationDirective, _super);

    function HistorySendNotificationDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "history-send-notification";
      HistorySendNotificationDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.notificationService = this.commonService.modelEngine.modelManager.getService("reporting.records.notification");
    }

    HistorySendNotificationDirective.prototype.setScope = function() {};

    HistorySendNotificationDirective.prototype.setCSS = function() {
      return css;
    };

    HistorySendNotificationDirective.prototype.setTemplate = function() {
      return view;
    };

    HistorySendNotificationDirective.prototype.show = function(scope, element, attrs) {
      var checkMsg, notificationData, phases, priorities, triggerType, _ref;
      scope.paraName = scope.parameters.name;
      triggerType = {
        "console": "控制台",
        "tts": "TTS语音",
        "email": "邮件",
        "wechat": "微信",
        "sms": "短信",
        "cloudsms": "云短信",
        "snmp": "SNMP",
        "command": "控制命令",
        "phone": "电话语音",
        "workflow": "工作流"
      };
      priorities = {
        "0": "一般信息",
        "1": "警告通知",
        "2": "重要通知",
        "3": "紧急通知",
        "-1": "确认通知"
      };
      phases = {
        "start": "开始",
        "completed": "完成",
        "timeout": "超时",
        "error": "错误",
        "cancel": "取消"
      };
      scope.dataNumber = 0;
      scope.countPage = 0;
      scope.headers = [
        {
          headerName: "通知规则",
          field: "notification"
        }, {
          headerName: "接收人",
          field: "receivers"
        }, {
          headerName: "消息标题",
          field: "title"
        }, {
          headerName: "消息内容",
          field: "content"
        }, {
          headerName: "通知优先级",
          field: "priority"
        }, {
          headerName: "通知类型",
          field: "type"
        }, {
          headerName: "通知状态",
          field: "phase"
        }, {
          headerName: "超时",
          field: "timeout"
        }, {
          headerName: "开始时间",
          field: "startTime"
        }, {
          headerName: "结束时间",
          field: "endTime"
        }, {
          headerName: "用户",
          field: "trigger"
        }
      ];
      scope.gardData = [];
      scope.gardAllData = [];
      scope.query = {
        startTime: '',
        endTime: ''
      };
      if ((_ref = scope.timeSubscription) != null) {
        _ref.dispose();
      }
      scope.timeSubscription = this.commonService.subscribeEventBus('time', (function(_this) {
        return function(d) {
          scope.query.startTime = moment(d.message.startTime).startOf('day');
          return scope.query.endTime = moment(d.message.endTime).endOf('day');
        };
      })(this));
      checkMsg = (function(_this) {
        return function(allData, pageNumber) {
          return scope.gardData = (_.chunk(allData, 10))[pageNumber];
        };
      })(this);
      notificationData = (function(_this) {
        return function() {
          var filCation;
          filCation = scope.project.getIds();
          filCation.startTime = (moment(scope.query.startTime).format("YYYY-MM-DD")) + " 00:00";
          filCation.endTime = (moment(scope.query.endTime).format("YYYY-MM-DD")) + " 23:59";
          return _this.notificationService.query(filCation, null, function(err, records) {
            var dataRes, end, start, _ref1;
            dataRes = records.data;
            if (dataRes.length > 0) {
              start = "";
              end = "";
              _.each(dataRes, function(d) {
                var _des, _end, _start;
                _des = _.clone(d);
                _start = _.clone(start);
                _end = _.clone(end);
                _start = d.startTime;
                _end = d.endTime;
                if (!_start || _start === "") {
                  _start = "";
                } else {
                  _start = moment(_des.startTime).format("YYYY-MM-DD HH:mm:ss");
                }
                if (!_end || _end === "") {
                  _end = "";
                } else {
                  _end = moment(_des.endTime).format("YYYY-MM-DD HH:mm:ss");
                }
                return scope.gardAllData.push({
                  notification: _des.notification,
                  receivers: _des.receivers,
                  title: _des.title,
                  content: _des.content,
                  priority: priorities[_des.priority],
                  type: triggerType[_des.type],
                  phase: phases[_des.phase],
                  timeout: _des.timeout,
                  startTime: _start,
                  endTime: _end,
                  trigger: _des.trigger
                });
              });
              scope.dataNumber = scope.gardAllData.length;
              checkMsg(scope.gardAllData, scope.countPage);
              if ((_ref1 = scope.comPageBus) != null) {
                _ref1.dispose();
              }
              return scope.comPageBus = _this.commonService.subscribeEventBus('pageTemplate', function(msg) {
                var message;
                message = msg.message - 1;
                return checkMsg(scope.gardAllData, message);
              });
            } else {
              scope.gardData = [];
              return scope.gardAllData = [];
            }
          }, true);
        };
      })(this);
      this.$timeout((function(_this) {
        return function() {
          return notificationData();
        };
      })(this), 500);
      scope.queryReport = (function(_this) {
        return function() {
          if (moment(scope.query.startTime).isAfter(moment(scope.query.endTime))) {
            M.toast({
              html: '开始时间大于结束时间！'
            });
            return false;
          }
          return notificationData();
        };
      })(this);
      return scope.exportReport = (function(_this) {
        return function(paramTitle) {
          var excel, wb;
          if (scope.gardAllData.length === 0) {
            _this.display(null, "暂无数据！", 1500);
            return false;
          }
          wb = XLSX.utils.book_new();
          excel = XLSX.utils.json_to_sheet(scope.gardAllData);
          XLSX.utils.book_append_sheet(wb, excel, "Sheet1");
          return XLSX.writeFile(wb, paramTitle + "-" + moment().format('YYYYMMDDHHMMSS') + ".xlsx");
        };
      })(this);
    };

    HistorySendNotificationDirective.prototype.resize = function(scope) {};

    HistorySendNotificationDirective.prototype.dispose = function(scope) {};

    return HistorySendNotificationDirective;

  })(base.BaseDirective);
  return exports = {
    HistorySendNotificationDirective: HistorySendNotificationDirective
  };
});
