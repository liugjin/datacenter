// Generated by IcedCoffeeScript 108.0.13

/*
* File: alarm-query-hmu2500-directive
* User: David
* Date: 2020/05/06
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "angularGrid"], function(base, css, view, _, moment, agGrid) {
  var AlarmQueryHmu2500Directive, exports;
  AlarmQueryHmu2500Directive = (function(_super) {
    __extends(AlarmQueryHmu2500Directive, _super);

    function AlarmQueryHmu2500Directive($timeout, $window, $compile, $routeParams, commonService) {
      this.dispose = __bind(this.dispose, this);
      this.createGridTable = __bind(this.createGridTable, this);
      this.getNewestEvents = __bind(this.getNewestEvents, this);
      this.show = __bind(this.show, this);
      this.id = "alarm-query-hmu2500";
      AlarmQueryHmu2500Directive.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.chartDataItems = [];
    }

    AlarmQueryHmu2500Directive.prototype.setScope = function() {};

    AlarmQueryHmu2500Directive.prototype.setCSS = function() {
      return css;
    };

    AlarmQueryHmu2500Directive.prototype.setTemplate = function() {
      return view;
    };

    AlarmQueryHmu2500Directive.prototype.show = function(scope, element, attrs) {
      var checkFilter, _ref, _ref1;
      if ((_ref = this.equipSubscription) != null) {
        _ref.dispose();
      }
      this.equipSubscription = this.subscribeEventBus('selectEquip', (function(_this) {
        return function(d) {
          _this.checkStations = d.message;
          return scope.queryAlarm();
        };
      })(this));
      if ((_ref1 = this.timeSubscription) != null) {
        _ref1.dispose();
      }
      this.timeSubscription = this.commonService.subscribeEventBus('time', (function(_this) {
        return function(d) {
          return _this.queryTime = d.message;
        };
      })(this));
      scope.header = [
        {
          headerName: "序号",
          field: "orderNo",
          width: 60,
          cellStyle: {
            textAlign: "center"
          }
        }, {
          headerName: "告警等级",
          field: "severity",
          width: 60,
          cellStyle: {
            textAlign: "center"
          }
        }, {
          headerName: "设备名称",
          field: "equipmentName",
          width: 90,
          cellStyle: {
            textAlign: "center"
          }
        }, {
          headerName: "告警名称",
          field: "title",
          width: 60,
          cellStyle: {
            textAlign: "center"
          }
        }, {
          headerName: "开始值",
          field: "startValue",
          width: 80,
          cellStyle: {
            textAlign: "center"
          }
        }, {
          headerName: "开始时间",
          field: "startTime",
          width: 80,
          cellStyle: {
            textAlign: "center"
          }
        }, {
          headerName: "结束值",
          field: "endValue",
          width: 80,
          cellStyle: {
            textAlign: "center"
          }
        }, {
          headerName: "结束时间",
          field: "endTime",
          width: 80,
          cellStyle: {
            textAlign: "center"
          }
        }, {
          headerName: "持续时长",
          field: "continuedTime",
          width: 80,
          cellStyle: {
            textAlign: "center"
          }
        }
      ];
      scope.selectType = (function(_this) {
        return function(type) {
          var _ref2;
          scope.eventsType = type;
          _this.events = [];
          if (type === 'new') {
            return _this.getNewestEvents(function() {
              return _this.createGridTable(scope, _this.events, element, type);
            });
          } else {
            if ((_ref2 = _this.subProject) != null) {
              _ref2.dispose();
            }
            return _this.createGridTable(scope, _this.chartDataItems, element, type);
          }
        };
      })(this);
      scope.selectType('history');
      checkFilter = (function(_this) {
        return function() {
          if (!_this.checkStations) {
            M.toast({
              html: '请选择设备或站点！'
            });
            return true;
          }
          if (moment(_this.queryTime.startTime).isAfter(moment(_this.queryTime.endTime))) {
            M.toast({
              html: '开始时间大于结束时间！'
            });
            return true;
          }
          return false;
        };
      })(this);
      scope.queryAlarm = (function(_this) {
        return function(page, pageItems) {
          var data, filter, paging;
          if (page == null) {
            page = 1;
          }
          if (pageItems == null) {
            pageItems = scope.parameters.pageItems;
          }
          if (checkFilter()) {
            return;
          }
          _this.chartDataItems = [];
          filter = _this.project.getIds();
          filter.startTime = moment(_this.queryTime.startTime).startOf('day');
          filter.endTime = moment(_this.queryTime.endTime).endOf('day');
          if (_this.checkStations.level === "station") {
            filter.station = _this.checkStations.id;
          } else if (_this.checkStations.level === "equipment") {
            filter.station = _this.checkStations.station;
            filter.equipment = _this.checkStations.id;
          }
          paging = {};
          if (pageItems) {
            paging.page = page;
            paging.pageItems = pageItems;
          }
          data = {
            filter: filter,
            fields: null,
            paging: paging,
            sorting: {
              station: 1,
              equipment: 1,
              startTime: -1
            }
          };
          scope.pagination = paging;
          return _this.commonService.reportingService.queryEventRecords(data, function(err, records, paging2) {
            var chartDataItem, count, nowTime, pCount, _i, _j, _len, _ref2, _results;
            nowTime = moment(new Date()).format("YYYY-MM-DD HH:mm:ss");
            if (records) {
              pCount = (paging2 != null ? paging2.pageCount : void 0) || 0;
              if (pCount <= 6) {
                if (paging2 != null) {
                  paging2.pages = (function() {
                    _results = [];
                    for (var _i = 1; 1 <= pCount ? _i <= pCount : _i >= pCount; 1 <= pCount ? _i++ : _i--){ _results.push(_i); }
                    return _results;
                  }).apply(this);
                }
              } else if (page > 3 && page < pCount - 2) {
                if (paging2 != null) {
                  paging2.pages = [1, page - 2, page - 1, page, page + 1, page + 2, pCount];
                }
              } else if (page <= 3) {
                if (paging2 != null) {
                  paging2.pages = [1, 2, 3, 4, 5, 6, pCount];
                }
              } else if (page >= pCount - 2) {
                if (paging2 != null) {
                  paging2.pages = [1, pCount - 5, pCount - 4, pCount - 3, pCount - 2, pCount - 1, pCount];
                }
              }
              scope.pagination = paging2;
              _.map(records, function(rec) {
                rec.startTime = moment(rec.startTime).format("YYYY-MM-DD HH:mm:ss");
                rec.status = _this.getPhase(rec.phaseName);
                if (!_.isEmpty(rec.endTime)) {
                  rec.endTime = moment(rec.endTime).format("YYYY-MM-DD HH:mm:ss");
                  return rec.continuedTime = _this.calTimes(moment(rec.endTime).diff(moment(moment(rec.startTime).format("YYYY-MM-DD HH:mm:ss"), 'YYYY-MM-DD HH:mm:ss'), 'seconds'));
                } else {
                  return rec.continuedTime = _this.calTimes(moment(nowTime).diff(moment(moment(rec.startTime).format("YYYY-MM-DD HH:mm:ss"), 'YYYY-MM-DD HH:mm:ss'), 'seconds'));
                }
              });
              _this.chartDataItems = _.sortBy(records, function(recItem) {
                return -recItem.station + recItem.equipment + recItem.event + recItem.startTime;
              });
              count = 0;
              _ref2 = _this.chartDataItems;
              for (_j = 0, _len = _ref2.length; _j < _len; _j++) {
                chartDataItem = _ref2[_j];
                count++;
                chartDataItem.orderNo = count;
              }
              return _this.createGridTable(scope, _this.chartDataItems, element, 'history');
            } else {
              _this.chartDataItems = [];
              return _this.createGridTable(scope, _this.chartDataItems, element, 'history');
            }
          });
        };
      })(this);
      scope.queryPage = (function(_this) {
        return function(page) {
          var paging;
          paging = scope.pagination;
          if (!paging) {
            return;
          }
          if (page === 'next') {
            page = paging.page + 1;
          } else if (page === 'previous') {
            page = paging.page - 1;
          }
          if (page > paging.pageCount || page < 1) {
            return;
          }
          return scope.queryAlarm(page, paging.pageItems);
        };
      })(this);
      return scope.exportReport = (function(_this) {
        return function(header, name) {
          var reportName;
          if (!scope.gridOptions) {
            return;
          }
          reportName = name + moment().format("YYYYMMDDHHmmss") + ".csv";
          return scope.gridOptions.api.exportDataAsCsv({
            fileName: reportName,
            allColumns: true,
            skipGroups: true
          });
        };
      })(this);
    };

    AlarmQueryHmu2500Directive.prototype.getPhase = function(phase) {
      if ((phase === "completed") || (phase === "end") || (phase === "complete")) {
        return "已结束";
      } else if (phase === "start") {
        return "开始";
      } else if ((phase === "confirm") || (phase === "confirmed")) {
        return "已确认";
      } else {
        return phase;
      }
    };

    AlarmQueryHmu2500Directive.prototype.getNewestEvents = function(callback) {
      var activeEventObjs, filter, _ref;
      activeEventObjs = {};
      filter = {
        user: this.project.model.user,
        project: this.project.model.project
      };
      if ((_ref = this.subProject) != null) {
        _ref.dispose();
      }
      return this.subProject = this.commonService.eventLiveSession.subscribeValues(filter, (function(_this) {
        return function(err, d) {
          var endTime, eventId, msg, orderflag, tmpStatus, tmpevents;
          if (!d) {
            return;
          }
          msg = d.message;
          eventId = msg.station + "." + msg.equipment + "." + msg.event;
          endTime = moment().format("YYYY-MM-DD HH:mm:ss");
          if (!_.isEmpty(msg.endTime)) {
            endTime = moment(msg.endTime).format("YYYY-MM-DD HH:mm:ss");
          }
          orderflag = "";
          tmpStatus = "";
          if (_.isEmpty(msg.confirmTime)) {
            tmpStatus += '未确认';
            if (msg.phase === 'end' || msg.phase === 'completed') {
              tmpStatus += ',已结束';
              orderflag = "B" + moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss").toString();
            } else {
              tmpStatus += ',未结束';
              orderflag = "D" + moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss").toString();
            }
            activeEventObjs[eventId] = {
              stationName: msg.stationName,
              equipmentName: msg.equipmentName,
              startTime: moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss"),
              status: tmpStatus,
              continuedTime: _this.calTimes(moment(endTime).diff(moment(moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss"), 'YYYY-MM-DD HH:mm:ss'), 'seconds')),
              title: msg.title,
              orderflag: orderflag
            };
          } else {
            tmpStatus += '已确认';
            if (msg.phase === 'end' || msg.phase === 'completed') {
              tmpStatus += ',已结束';
              orderflag = "A" + moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss").toString();
              delete activeEventObjs[eventId];
            } else {
              tmpStatus += ',未结束';
              orderflag = "C" + moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss").toString();
              activeEventObjs[eventId] = {
                stationName: msg.stationName,
                equipmentName: msg.equipmentName,
                startTime: moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss"),
                status: tmpStatus,
                continuedTime: _this.calTimes(moment(endTime).diff(moment(moment(msg.startTime).format("YYYY-MM-DD HH:mm:ss"), 'YYYY-MM-DD HH:mm:ss'), 'seconds')),
                title: msg.title,
                orderflag: orderflag
              };
            }
          }
          tmpevents = [];
          _.mapObject(activeEventObjs, function(val, key) {
            return tmpevents.push(val);
          });
          _this.events = _.sortBy(tmpevents, function(evtItem) {
            return evtItem.orderflag;
          });
          return typeof callback === "function" ? callback() : void 0;
        };
      })(this));
    };

    AlarmQueryHmu2500Directive.prototype.createGridTable = function(scope, data, element, type) {
      var _ref;
      scope.gridOptions = {
        columnDefs: [
          {
            headerName: "序号",
            field: "orderNo",
            width: 30,
            cellStyle: {
              textAlign: "center"
            }
          }, {
            headerName: "告警等级",
            field: "severity",
            width: 50,
            cellStyle: {
              textAlign: "center"
            },
            cellRenderer: (function(_this) {
              return function(params) {
                var imageElement, resultElement, severityName;
                severityName = _this.getSeverityName(scope, params.value);
                resultElement = document.createElement("span");
                resultElement.style.color = _this.getSeverityColor(scope, params.value);
                imageElement = document.createElement("img");
                imageElement.src = _this.getComponentPath("icons/" + params.value + ".svg");
                imageElement["class"] = "icon";
                imageElement.style.width = 14 + 'px';
                imageElement.style.height = 14 + 'px';
                imageElement.style.margin = (-3) + 'px ' + 0 + 'px ' + 0 + 'px ' + 0 + 'px ';
                imageElement.title = severityName;
                resultElement.appendChild(imageElement);
                resultElement.appendChild(document.createTextNode("  " + severityName));
                return resultElement;
              };
            })(this)
          }, {
            headerName: "设备名称",
            field: "equipmentName",
            width: 90,
            cellStyle: {
              textAlign: "center"
            }
          }, {
            headerName: "告警名称",
            field: "title",
            width: 120,
            cellStyle: {
              textAlign: "center"
            }
          }, {
            headerName: "开始值",
            field: "startValue",
            width: 60,
            cellStyle: {
              textAlign: "center"
            }
          }, {
            headerName: "开始时间",
            field: "startTime",
            width: 80,
            cellStyle: {
              textAlign: "center"
            }
          }, {
            headerName: "结束值",
            field: "endValue",
            width: 60,
            cellStyle: {
              textAlign: "center"
            }
          }, {
            headerName: "结束时间",
            field: "endTime",
            width: 80,
            cellStyle: {
              textAlign: "center"
            }
          }, {
            headerName: "持续时长",
            field: "continuedTime",
            width: 80,
            cellStyle: {
              textAlign: "center"
            }
          }
        ],
        rowData: null,
        enableFilter: false,
        enableSorting: true,
        enableColResize: true,
        overlayNoRowsTemplate: "无数据",
        headerHeight: 41,
        rowHeight: 61
      };
      if ((_ref = this.agrid) != null) {
        _ref.destroy();
      }
      this.agrid = new agGrid.Grid(element.find("#" + type)[0], scope.gridOptions);
      scope.gridOptions.api.sizeColumnsToFit();
      return scope.gridOptions.api.setRowData(data);
    };

    AlarmQueryHmu2500Directive.prototype.calTimes = function(refTime) {
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

    AlarmQueryHmu2500Directive.prototype.getSeverityName = function(scope, severity) {
      var severityObj;
      severityObj = _.find(scope.project.dictionary.eventseverities.items, function(item) {
        return item.model.severity === severity;
      });
      if (severityObj) {
        return severityObj.model.name;
      } else {
        return severity;
      }
    };

    AlarmQueryHmu2500Directive.prototype.getSeverityColor = function(scope, severity) {
      var severityObj;
      severityObj = _.find(scope.project.dictionary.eventseverities.items, function(item) {
        return item.model.severity === severity;
      });
      if (severityObj) {
        return severityObj.model.color;
      } else {
        return "white";
      }
    };

    AlarmQueryHmu2500Directive.prototype.resize = function(scope) {};

    AlarmQueryHmu2500Directive.prototype.dispose = function(scope) {
      var _ref, _ref1, _ref2;
      if ((_ref = this.subProject) != null) {
        _ref.dispose();
      }
      if ((_ref1 = this.equipSubscription) != null) {
        _ref1.dispose();
      }
      return (_ref2 = this.timeSubscription) != null ? _ref2.dispose() : void 0;
    };

    return AlarmQueryHmu2500Directive;

  })(base.BaseDirective);
  return exports = {
    AlarmQueryHmu2500Directive: AlarmQueryHmu2500Directive
  };
});
