// Generated by IcedCoffeeScript 108.0.12

/*
* File: electricity-consumption-directive
* User: David
* Date: 2019/12/30
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", 'angularGrid', 'gl-datepicker'], function(base, css, view, _, moment, agGrid, gl) {
  var ElectricityConsumptionDirective, exports;
  ElectricityConsumptionDirective = (function(_super) {
    __extends(ElectricityConsumptionDirective, _super);

    function ElectricityConsumptionDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.exportReport = __bind(this.exportReport, this);
      this.setData = __bind(this.setData, this);
      this.getReportData = __bind(this.getReportData, this);
      this.checkFilter = __bind(this.checkFilter, this);
      this.setTime = __bind(this.setTime, this);
      this.getstations = __bind(this.getstations, this);
      this.show = __bind(this.show, this);
      this.id = "electricity-consumption";
      ElectricityConsumptionDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    ElectricityConsumptionDirective.prototype.setScope = function() {};

    ElectricityConsumptionDirective.prototype.setCSS = function() {
      return css;
    };

    ElectricityConsumptionDirective.prototype.setTemplate = function() {
      return view;
    };

    ElectricityConsumptionDirective.prototype.show = function(scope, element, attrs) {
      scope.historicalData = [];
      scope.stations = [];
      scope.checkNews = {
        station: ''
      };
      scope.header = [
        {
          headerName: "分区名称",
          field: 'station'
        }, {
          headerName: "设备名称",
          field: 'equipment'
        }, {
          headerName: "信号名称",
          field: 'signal'
        }, {
          headerName: "单位",
          field: 'unit'
        }, {
          headerName: "信号值",
          field: 'value'
        }, {
          headerName: "差值",
          field: 'diff'
        }, {
          headerName: "最小值",
          field: 'min'
        }, {
          headerName: "最大值",
          field: 'max'
        }, {
          headerName: "采集周期",
          field: 'period'
        }, {
          headerName: "采集模式",
          field: 'mode'
        }, {
          headerName: "采集时间",
          field: 'timestamp'
        }
      ];
      scope.noData = [
        {
          station: "暂无数据",
          equipment: "暂无数据",
          signal: "暂无数据",
          unit: "暂无数据",
          value: "暂无数据",
          diff: "暂无数据",
          min: "暂无数据",
          max: "暂无数据",
          period: "暂无数据",
          mode: "暂无数据",
          timestamp: "暂无数据"
        }
      ];
      this.getstations(scope);
      this.setTime(scope, element);
      this.getReportData(scope);
      this.exportReport(scope, element);
      return this.setData(scope, scope.noData);
    };

    ElectricityConsumptionDirective.prototype.getstations = function(scope) {
      return scope.project.loadStations(null, (function(_this) {
        return function(err, stations) {
          scope.checkNews.station = stations[0].model.station;
          return scope.stations = stations;
        };
      })(this));
    };

    ElectricityConsumptionDirective.prototype.setTime = function(scope, element) {
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

    ElectricityConsumptionDirective.prototype.checkFilter = function(scope) {
      if (moment(scope.query.startTime).isAfter(moment(scope.query.endTime))) {
        M.toast({
          html: '开始时间大于结束时间！'
        });
        return true;
      }
      return false;
    };

    ElectricityConsumptionDirective.prototype.getReportData = function(scope) {
      return scope.getReportData = (function(_this) {
        return function() {
          var filter;
          if (_this.checkFilter(scope)) {
            return;
          }
          scope.historicalData.splice(0, scope.historicalData.length);
          filter = {
            user: _this.$routeParams.user,
            project: _this.$routeParams.project,
            station: scope.checkNews.station,
            equipment: '_station_efficient',
            signal: "power-value",
            period: {
              $gte: moment(scope.query.startTime).format("YYYY-MM-DD"),
              $lt: moment(scope.query.endTime).format("YYYY-MM-DD HH")
            },
            mode: "day"
          };
          return _this.commonService.reportingService.querySignalStatistics({
            filter: filter
          }, function(err, records) {
            var c, currentData, data, s, _i, _j, _len, _len1, _ref;
            if (err || records.length < 1) {
              return _this.setData(scope, scope.noData);
            }
            currentData = (_.values(records))[0].values;
            for (_i = 0, _len = currentData.length; _i < _len; _i++) {
              c = currentData[_i];
              data = {
                station: null,
                equipment: null,
                signal: null,
                unit: null,
                value: null,
                diff: null,
                min: null,
                max: null,
                period: null,
                mode: null,
                timestamp: null
              };
              _ref = scope.stations;
              for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                s = _ref[_j];
                if (scope.checkNews.station === s.model.station) {
                  data.station = s.model.name;
                }
              }
              data.equipment = "站点能耗设备";
              data.signal = "用电量";
              data.unit = "kWh";
              data.value = c.value;
              data.diff = c.diff;
              data.min = c.min;
              data.max = c.max;
              data.period = c.period;
              data.mode = c.mode;
              data.timestamp = c.timestamp;
              scope.historicalData.push(data);
            }
            return _this.setData(scope, scope.historicalData);
          });
        };
      })(this);
    };

    ElectricityConsumptionDirective.prototype.setData = function(scope, data) {
      if (!scope.gridOptions) {
        return;
      }
      scope.historicalData = data;
      return scope.gridOptions.api.setRowData(data);
    };

    ElectricityConsumptionDirective.prototype.exportReport = function(scope, element) {
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

    ElectricityConsumptionDirective.prototype.resize = function(scope) {};

    ElectricityConsumptionDirective.prototype.dispose = function(scope) {};

    return ElectricityConsumptionDirective;

  })(base.BaseDirective);
  return exports = {
    ElectricityConsumptionDirective: ElectricityConsumptionDirective
  };
});
