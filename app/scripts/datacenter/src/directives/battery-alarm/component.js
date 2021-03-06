// Generated by IcedCoffeeScript 108.0.12

/*
* File: battery-alarm-directive
* User: David
* Date: 2019/12/26
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var BatteryAlarmDirective, exports;
  BatteryAlarmDirective = (function(_super) {
    __extends(BatteryAlarmDirective, _super);

    function BatteryAlarmDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "battery-alarm";
      BatteryAlarmDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    BatteryAlarmDirective.prototype.setScope = function() {};

    BatteryAlarmDirective.prototype.setCSS = function() {
      return css;
    };

    BatteryAlarmDirective.prototype.setTemplate = function() {
      return view;
    };

    BatteryAlarmDirective.prototype.show = function(scope, element, attrs) {
      var checkFilter, esAllStation, pageAction, queryAlarms, _ref, _ref1;
      scope.headers = [
        {
          headerName: "站点名称",
          field: 'stationName'
        }, {
          headerName: "设备名称",
          field: 'equipName'
        }, {
          headerName: "告警级别",
          field: 'alarmSeverity'
        }, {
          headerName: "告警名称",
          field: 'alarmName'
        }, {
          headerName: "开始值",
          field: 'startVal'
        }, {
          headerName: "结束值",
          field: 'endVal'
        }, {
          headerName: "总时长",
          field: 'allTime'
        }, {
          headerName: "开始时间",
          field: 'startTime'
        }, {
          headerName: "结束时间",
          field: 'endTime'
        }
      ];
      scope.gardData = [];
      scope.dervise = [];
      scope.pageContainerChange = 0;
      scope.pageItem = 0;
      scope.templateType = scope.parameters.type;
      scope.componentName = scope.parameters.name;
      esAllStation = [];
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
      if (_.isEmpty(scope.parameters) || !scope.parameters.name) {
        this.display(null, '请传入需要的值', 1500);
        return false;
      }
      if ((_ref1 = scope.selectEquipSubscription) != null) {
        _ref1.dispose();
      }
      scope.selectEquipSubscription = this.commonService.subscribeEventBus("checkEquips", (function(_this) {
        return function(msg) {
          return esAllStation = msg.message;
        };
      })(this));
      pageAction = (function(_this) {
        return function(statics, pageItem) {
          var chunkObj;
          scope.dervise = statics;
          chunkObj = _.chunk(statics, 10);
          return scope.gardData = chunkObj[pageItem];
        };
      })(this);
      queryAlarms = (function(_this) {
        return function(filterRecord, filStation, pageItem) {
          var equipArr, staArr;
          staArr = _.uniq(_.map(filStation, function(fil) {
            return fil.station;
          }));
          equipArr = _.uniq(_.map(filStation, function(fil) {
            return fil.id;
          }));
          scope.gardData = [];
          scope.dervise = [];
          return _this.commonService.reportingService.queryEventRecords({
            filter: filterRecord,
            paging: null,
            sorting: null
          }, function(err, records) {
            var callTime, eqSta, estEnd, estStart, tempRecords, tempStatics, _ref2;
            if (records.length > 0) {
              tempRecords = _.filter(records, function(res) {
                return res.equipmentType === scope.templateType;
              });
              if (tempRecords.length === 0) {
                return;
              }
              eqSta = _.filter(_.filter(tempRecords, function(sta) {
                var _ref2;
                return _ref2 = sta.station, __indexOf.call(staArr, _ref2) >= 0;
              }), function(eq) {
                var _ref2;
                return _ref2 = eq.equipment, __indexOf.call(equipArr, _ref2) >= 0;
              });
              scope.pageContainerChange = eqSta.length;
              estStart = '';
              estEnd = '';
              callTime = '';
              tempStatics = [];
              _.each(eqSta, function(est) {
                var _callTime, _eEnd, _eStart, _est;
                _eStart = _.clone(estStart);
                _eEnd = _.clone(estEnd);
                _est = _.clone(est);
                _callTime = _.clone(callTime);
                _eStart = est.startTime;
                _eEnd = est.endTime;
                if (!_eEnd) {
                  _eEnd = '';
                  _callTime = '';
                } else {
                  _eEnd = moment(_eEnd).format('YYYY-MM-DD HH:mm:ss');
                  _callTime = _this.calTimes(moment(_est.endTime, "YYYY-MM-DD HH:mm:ss").diff(moment(_est.startTime, 'YYYY-MM-DD HH:mm:ss'), 'seconds'));
                }
                return tempStatics.push({
                  stationName: _est.stationName,
                  equipName: _est.equipmentName,
                  alarmSeverity: _est.severityName,
                  alarmName: _est.eventName,
                  startVal: _est.startValue,
                  endVal: _est.endValue || '',
                  allTime: _callTime,
                  startTime: moment(_eStart).format('YYYY-MM-DD HH:mm:ss'),
                  endTime: _eEnd
                });
              });
              pageAction(tempStatics, pageItem);
              if ((_ref2 = scope.comPageBus) != null) {
                _ref2.dispose();
              }
              return scope.comPageBus = _this.commonService.subscribeEventBus('pageTemplate', function(msg) {
                var message;
                message = msg.message - 1;
                return pageAction(tempStatics, message);
              });
            } else {
              scope.gardData = [];
              scope.dervise = [];
              return scope.pageContainerChange = 0;
            }
          });
        };
      })(this);
      checkFilter = (function(_this) {
        return function() {
          if (!esAllStation || (!esAllStation.length)) {
            M.toast({
              html: '请选择设备！'
            });
            return true;
          }
          if (moment(scope.query.startTime).isAfter(moment(scope.query.endTime))) {
            M.toast({
              html: '开始时间大于结束时间！'
            });
            return true;
          }
          return false;
        };
      })(this);
      scope.queryReport = (function(_this) {
        return function() {
          var filStation, filterRecord;
          if (checkFilter()) {
            return;
          }
          filStation = _.filter(esAllStation, function(item) {
            return item.level !== "station";
          });
          filterRecord = scope.project.getIds();
          filterRecord.startTime = moment(scope.query.startTime).format("YYYY-MM-DD") + " 00:00";
          filterRecord.endTime = moment(scope.query.endTime).format("YYYY-MM-DD") + " 23:59";
          return queryAlarms(filterRecord, filStation, scope.pageItem);
        };
      })(this);
      return scope.exportReport = (function(_this) {
        return function(title) {
          var excel, wb;
          if (scope.dervise.length === 0) {
            _this.display(null, '暂无数据', 1500);
            return false;
          }
          wb = XLSX.utils.book_new();
          excel = XLSX.utils.json_to_sheet(scope.dervise);
          XLSX.utils.book_append_sheet(wb, excel, "Sheet1");
          return XLSX.writeFile(wb, title + "-" + moment().format('YYYYMMDDHHMMSS') + ".xlsx");
        };
      })(this);
    };

    BatteryAlarmDirective.prototype.calTimes = function(refTime) {
      var days, daysY, hours, hoursY, minY, mins, sTime;
      sTime = "";
      days = Math.floor(refTime / 86400);
      daysY = refTime % 86400;
      hours = Math.floor(daysY / 3600);
      hoursY = daysY % 3600;
      mins = Math.floor(hoursY / 60);
      minY = hoursY % 60;
      if (days > 0) {
        sTime = sTime + days + "天 ";
      } else {
        sTime = "0天 ";
      }
      if (hours > 0) {
        sTime = sTime + hours + "时 ";
      } else {
        sTime = sTime + "0时 ";
      }
      if (mins > 0) {
        sTime = sTime + mins + "分 ";
      } else {
        sTime = sTime + "0分 ";
      }
      if (minY > 0) {
        sTime = sTime + minY + "秒";
      } else {
        sTime = sTime + "0秒";
      }
      return sTime;
    };

    BatteryAlarmDirective.prototype.resize = function(scope) {};

    BatteryAlarmDirective.prototype.dispose = function(scope) {
      var _ref, _ref1, _ref2;
      if ((_ref = scope.timeSubscription) != null) {
        _ref.dispose();
      }
      if ((_ref1 = scope.selectEquipSubscription) != null) {
        _ref1.dispose();
      }
      return (_ref2 = scope.comPageBus) != null ? _ref2.dispose() : void 0;
    };

    return BatteryAlarmDirective;

  })(base.BaseDirective);
  return exports = {
    BatteryAlarmDirective: BatteryAlarmDirective
  };
});
