// Generated by IcedCoffeeScript 108.0.13

/*
* File: report-activeevents-directive
* User: David
* Date: 2019/12/27
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", 'angularGrid', 'gl-datepicker'], function(base, css, view, _, moment, agGrid, gl) {
  var ReportActiveeventsDirective, exports;
  ReportActiveeventsDirective = (function(_super) {
    __extends(ReportActiveeventsDirective, _super);

    function ReportActiveeventsDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.exportReport = __bind(this.exportReport, this);
      this.setData = __bind(this.setData, this);
      this.getReportData = __bind(this.getReportData, this);
      this.checkFilter = __bind(this.checkFilter, this);
      this.getSelectedDevice = __bind(this.getSelectedDevice, this);
      this.getAlarmLevels = __bind(this.getAlarmLevels, this);
      this.setTime = __bind(this.setTime, this);
      this.show = __bind(this.show, this);
      this.id = "report-activeevents";
      ReportActiveeventsDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    ReportActiveeventsDirective.prototype.setScope = function() {};

    ReportActiveeventsDirective.prototype.setCSS = function() {
      return css;
    };

    ReportActiveeventsDirective.prototype.setTemplate = function() {
      return view;
    };

    ReportActiveeventsDirective.prototype.show = function(scope, element, attrs) {
      scope.historicalData = [];
      scope.checkNews = {
        severity: 'all',
        phase: 'all'
      };
      scope.alarmStateArr = [
        {
          id: "start",
          name: "开始告警"
        }, {
          id: "end",
          name: "结束告警"
        }, {
          id: "confirm",
          name: "确认告警"
        }
      ];
      scope.header = [
        {
          headerName: "告警级别",
          field: 'severityName'
        }, {
          headerName: "告警状态",
          field: 'phaseName'
        }, {
          headerName: "分区名称",
          field: 'stationName'
        }, {
          headerName: "设备名称",
          field: 'equipmentName'
        }, {
          headerName: "告警名称",
          field: 'eventName'
        }, {
          headerName: "开始值",
          field: 'startValue'
        }, {
          headerName: "结束值",
          field: 'endValue'
        }, {
          headerName: "开始时间",
          field: 'startTime'
        }, {
          headerName: "结束时间",
          field: 'endTime'
        }
      ];
      scope.noData = [
        {
          severityName: "暂无数据",
          phaseName: "暂无数据",
          stationName: "暂无数据",
          equipmentName: "暂无数据",
          eventName: "暂无数据",
          startValue: "暂无数据",
          endValue: "暂无数据",
          startTime: "暂无数据",
          endTime: "暂无数据"
        }
      ];
      this.getAlarmLevels(scope);
      this.setTime(scope, element);
      this.getSelectedDevice(scope);
      this.getReportData(scope);
      this.exportReport(scope, element);
      return this.setData(scope, scope.noData);
    };

    ReportActiveeventsDirective.prototype.setTime = function(scope, element) {
      var setGlDatePicker;
      scope.query = {
        startTime: moment().format("YYYY-MM-DD"),
        endTime: moment().format("YYYY-MM-DD")
      };
      setGlDatePicker = function(element, value) {
        if (!value) {
          return;
        }
        return setTimeout(function() {
          return gl = $(element).glDatePicker({
            dowNames: ["日", "一", "二", "三", "四", "五", "六"],
            monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
            selectedDate: moment(value).toDate(),
            onClick: function(target, cell, date, data) {
              var day, month;
              month = date.getMonth() + 1;
              if (month < 10) {
                month = "0" + month;
              }
              day = date.getDate();
              if (day < 10) {
                day = "0" + day;
              }
              return target.val(date.getFullYear() + "-" + month + "-" + day).trigger("change");
            }
          });
        }, 500);
      };
      setGlDatePicker($('#start-time-input')[0], scope.query.startTime);
      return setGlDatePicker($('#end-time-input')[0], scope.query.startTime);
    };

    ReportActiveeventsDirective.prototype.getAlarmLevels = function(scope) {
      var alarmLevel, alarmLevelData, _i, _len, _ref, _results;
      scope.alarmLevels = [];
      _ref = scope.project.typeModels.eventseverities.items;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        alarmLevel = _ref[_i];
        alarmLevelData = {
          id: alarmLevel.model.severity,
          name: alarmLevel.model.name
        };
        _results.push(scope.alarmLevels.push(alarmLevelData));
      }
      return _results;
    };

    ReportActiveeventsDirective.prototype.getSelectedDevice = function(scope) {
      return this.commonService.subscribeEventBus('checkEquips', (function(_this) {
        return function(msg) {
          var equipments, stations;
          scope.selectedEquips = [];
          if (!(msg != null ? msg.message.length : void 0)) {
            return;
          }
          stations = _.filter(msg.message, function(item) {
            return item.level === "station";
          });
          equipments = _.filter(msg.message, function(item) {
            var _ref;
            return item.level === "equipment" && (_ref = item.station, __indexOf.call(_.pluck(stations, "id"), _ref) < 0);
          });
          if (stations != null) {
            stations.forEach(function(value) {
              return scope.selectedEquips.push(value.id);
            });
          }
          if (equipments != null) {
            equipments.forEach(function(value) {
              return scope.selectedEquips.push((value != null ? value.station : void 0) + '.' + (value != null ? value.id : void 0));
            });
          }
          if (scope.parameters.type === "signal") {
            return loadEquipmentAndSignals(scope.selectedEquips);
          }
        };
      })(this));
    };

    ReportActiveeventsDirective.prototype.checkFilter = function(scope) {
      if (!scope.selectedEquips || (!scope.selectedEquips.length)) {
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

    ReportActiveeventsDirective.prototype.getReportData = function(scope) {
      return scope.getReportData = (function(_this) {
        return function() {
          var data, filter;
          if (_this.checkFilter(scope)) {
            return;
          }
          filter = scope.project.getIds();
          filter["$or"] = _.map(scope.selectedEquips, function(equip) {
            if (equip.split(".").length > 1) {
              return {
                station: equip.split('.')[0],
                equipment: equip.split('.')[1]
              };
            } else {
              return {
                station: equip.split('.')[0]
              };
            }
          });
          filter.startTime = moment(scope.query.startTime).startOf('day');
          filter.endTime = moment(scope.query.endTime).endOf('day');
          if (scope.checkNews.severity !== "all") {
            filter.severity = scope.checkNews.severity;
          }
          if (scope.checkNews.phase !== "all") {
            filter.phase = scope.checkNews.phase;
          }
          data = {
            filter: filter,
            fields: "severityName phaseName stationName equipmentName eventName startValue endValue startTime endTime"
          };
          return _this.commonService.reportingService.queryEventRecords(data, function(err, records) {
            if (err || records.length < 1) {
              return _this.setData(scope, scope.noData);
            }
            return _this.setData(scope, records);
          });
        };
      })(this);
    };

    ReportActiveeventsDirective.prototype.setData = function(scope, data) {
      if (!scope.gridOptions) {
        return;
      }
      scope.historicalData = data;
      return scope.gridOptions.api.setRowData(data);
    };

    ReportActiveeventsDirective.prototype.exportReport = function(scope, element) {
      scope.gridOptions = {
        columnDefs: scope.header,
        rowData: null,
        enableFilter: true,
        enableSorting: true,
        enableColResize: true,
        overlayNoRowsTemplate: " ",
        headerHeight: 41,
        rowHeight: 61
      };
      new agGrid.Grid(element.find("#grid")[0], scope.gridOptions);
      return scope.exportReport = (function(_this) {
        return function(name) {
          var reportName;
          if (!scope.gridOptions) {
            return;
          }
          reportName = name + "(" + moment(scope.query.startTime).format("YYYY-MM-DD") + "-" + moment(scope.query.endTime).format("YYYY-MM-DD") + ").csv";
          return scope.gridOptions.api.exportDataAsCsv({
            fileName: reportName,
            allColumns: true,
            skipGroups: true
          });
        };
      })(this);
    };

    ReportActiveeventsDirective.prototype.resize = function(scope) {};

    ReportActiveeventsDirective.prototype.dispose = function(scope) {};

    return ReportActiveeventsDirective;

  })(base.BaseDirective);
  return exports = {
    ReportActiveeventsDirective: ReportActiveeventsDirective
  };
});
