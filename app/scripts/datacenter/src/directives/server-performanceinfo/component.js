// Generated by IcedCoffeeScript 108.0.13

/*
* File: server-performanceinfo-directive
* User: David
* Date: 2019/10/12
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], function(base, css, view, _, moment, echarts) {
  var ServerPerformanceinfoDirective, exports;
  ServerPerformanceinfoDirective = (function(_super) {
    __extends(ServerPerformanceinfoDirective, _super);

    function ServerPerformanceinfoDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.createOption = __bind(this.createOption, this);
      this.querydata = __bind(this.querydata, this);
      this.getRealDatas = __bind(this.getRealDatas, this);
      this.show = __bind(this.show, this);
      this.id = "server-performanceinfo";
      ServerPerformanceinfoDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    ServerPerformanceinfoDirective.prototype.setScope = function() {};

    ServerPerformanceinfoDirective.prototype.setCSS = function() {
      return css;
    };

    ServerPerformanceinfoDirective.prototype.setTemplate = function() {
      return view;
    };

    ServerPerformanceinfoDirective.prototype.show = function(scope, element, attrs) {
      var chartLine, stationResult, _ref;
      scope.subscribObjs = {};
      scope.showSignals = [];
      scope.chartDatas = [];
      scope.selectedSig = "";
      scope.selectSignalObj = null;
      scope.chartDataObj = {};
      if ((_ref = scope.echart) != null) {
        _ref.dispose();
      }
      scope.optioninfo = null;
      scope.selectMode = "now";
      chartLine = element.find(".my-chart");
      this.waitingLayout(this.$timeout, chartLine, (function(_this) {
        return function() {
          var _ref1;
          if ((_ref1 = scope.echart) != null) {
            _ref1.dispose();
          }
          scope.echart = echarts.init(chartLine[0]);
          return scope.$watchCollection("chartDatas", function(value) {
            var options;
            if (!value) {
              return;
            }
            options = _this.createOption(value);
            return scope.echart.setOption(options);
          });
        };
      })(this));
      stationResult = _.filter(scope.project.stations.items, function(stationItem) {
        return stationItem.model.station === scope.parameters.station;
      });
      if (stationResult.length > 0) {
        stationResult[0].loadEquipment(scope.parameters.equipment, null, (function(_this) {
          return function(err, equipment) {
            return equipment != null ? equipment.loadSignals(null, function(err, signals) {
              var showSignalItem, signalItem, sortSignals, _i, _j, _len, _len1, _ref1, _results;
              for (_i = 0, _len = signals.length; _i < _len; _i++) {
                signalItem = signals[_i];
                if (signalItem.model.visible) {
                  signalItem.model.value = "--";
                  signalItem.model.station = signalItem.equipment.model.station;
                  signalItem.model.equipment = signalItem.equipment.model.equipment;
                  signalItem.model.unitName = _this.getSignalUnitName(scope, signalItem.model.unit);
                  scope.showSignals.push(signalItem.model);
                }
              }
              sortSignals = _.sortBy(scope.showSignals, function(item) {
                return -item.index;
              });
              scope.showSignals = sortSignals;
              if (scope.showSignals.length > 0) {
                scope.selectedSig = scope.showSignals[0].name;
                scope.selectSignalObj = scope.showSignals[0];
              }
              _ref1 = scope.showSignals;
              _results = [];
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                showSignalItem = _ref1[_j];
                _results.push(_this.getRealDatas(scope, showSignalItem));
              }
              return _results;
            }) : void 0;
          };
        })(this));
      }
      scope.selectSignal = (function(_this) {
        return function(signal) {
          scope.selectedSig = signal.name;
          scope.selectSignalObj = signal;
          if (scope.selectMode === "now") {
            return _this.getRealDatas(scope, signal);
          } else {
            return _this.querydata(scope, scope.selectSignalObj, scope.selectMode);
          }
        };
      })(this);
      return scope.selectStatisticMode = (function(_this) {
        return function(mode) {
          scope.selectMode = mode;
          if (mode === "now") {
            return _this.getRealDatas(scope, scope.selectSignalObj);
          } else {
            return _this.querydata(scope, scope.selectSignalObj, mode);
          }
        };
      })(this);
    };

    ServerPerformanceinfoDirective.prototype.getRealDatas = function(scope, signal) {
      var filter, subId, _ref;
      scope.chartDatas = [];
      scope.signalObjVal = {};
      subId = signal.station + "." + signal.equipment + "." + signal.signal;
      filter = scope.project.getIds();
      filter.station = signal.station;
      filter.equipment = signal.equipment;
      filter.signal = signal.signal;
      if ((_ref = scope.subscribObjs[subId]) != null) {
        _ref.dispose();
      }
      return scope.subscribObjs[subId] = this.commonService.signalLiveSession.subscribeValues(filter, (function(_this) {
        return function(err, d) {
          var tmpSignal, _ref1;
          tmpSignal = _.filter(scope.showSignals, function(signalItme) {
            return signalItme.signal === d.message.signal;
          });
          if (tmpSignal.length > 0) {
            tmpSignal[0].value = d.message.value;
          }
          if (scope.selectMode === "now") {
            if (scope.selectSignalObj.signal === d.message.signal) {
              if (!scope.signalObjVal[scope.selectSignalObj.signal]) {
                scope.signalObjVal[scope.selectSignalObj.signal] = {};
              }
              scope.signalObjVal[scope.selectSignalObj.signal][moment(d.message.timestamp).format("HH:mm")] = (_ref1 = d.message.value) != null ? _ref1.toFixed(2) : void 0;
              scope.chartDatas = [];
              _.mapObject(scope.signalObjVal[scope.selectSignalObj.signal], function(value, key) {
                return scope.chartDatas.push({
                  name: "性能曲线",
                  key: key,
                  value: value
                });
              });
              return scope.$applyAsync();
            }
          }
        };
      })(this), true);
    };

    ServerPerformanceinfoDirective.prototype.querydata = function(scope, signal, mode) {
      var filter;
      scope.chartDatas = [];
      filter = scope.project.getIds();
      filter.station = signal.station;
      filter.equipment = signal.equipment;
      filter.signal = signal.signal;
      if (mode === "day") {
        filter.mode = "hour";
        filter.period = {
          $gte: moment().startOf('day'),
          $lte: moment().endOf('day')
        };
      } else if (mode === "month") {
        filter.mode = "day";
        filter.period = {
          $gte: moment().startOf('month'),
          $lte: moment().endOf('month')
        };
      }
      return this.commonService.reportingService.querySignalStatistics({
        filter: filter
      }, (function(_this) {
        return function(err, records) {
          var currDatas;
          scope.chartDatas = [];
          if (records) {
            if (angular.isObject(records)) {
              currDatas = [];
              _.mapObject(records, function(val, key) {
                var _i, _len, _ref, _results;
                _ref = val.values;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  val = _ref[_i];
                  _results.push(currDatas.push({
                    name: "性能曲线",
                    key: val.period.substr(val.period.length - 2, 2),
                    value: val.avg.toFixed(2)
                  }));
                }
                return _results;
              });
              scope.chartDatas = _.sortBy(currDatas, function(dataItem) {
                return dataItem.key;
              });
            }
          }
          return scope.$applyAsync();
        };
      })(this));
    };

    ServerPerformanceinfoDirective.prototype.createOption = function(chartdatas) {
      var option, xAxisDatas, yAxisDatas;
      xAxisDatas = _.pluck(chartdatas, 'key');
      yAxisDatas = _.pluck(chartdatas, 'value');
      return option = {
        grid: {
          left: "13%",
          right: "13%",
          top: "22%",
          bottom: "10%"
        },
        xAxis: {
          boundaryGap: false,
          data: xAxisDatas,
          axisLine: {
            lineStyle: {
              color: "#A2CAF8"
            }
          },
          splitLine: {
            lineStyle: {
              color: "rgba(0,77,160,1)"
            }
          }
        },
        yAxis: {
          type: 'value',
          axisLine: {
            lineStyle: {
              color: "#A2CAF8"
            }
          },
          splitLine: {
            lineStyle: {
              color: "rgba(0,77,160,1)"
            }
          }
        },
        tooltip: {
          trigger: "axis",
          backgroundColor: "rgba(67,202,255,1)",
          padding: [5, 10],
          textStyle: {
            color: "#e2edf2",
            fontWeight: "bold"
          }
        },
        series: [
          {
            data: yAxisDatas,
            itemStyle: {
              normal: {
                color: '#7DE6C2'
              }
            },
            type: 'line',
            smooth: true,
            lineStyle: {
              normal: {
                color: "rgba(67,202,255,1)"
              }
            },
            areaStyle: {
              normal: {
                color: {
                  type: 'linear',
                  x: 0,
                  y: 0,
                  x2: 0,
                  y2: 1,
                  colorStops: [
                    {
                      offset: 0,
                      color: 'rgba(67,202,255,1)'
                    }, {
                      offset: .5,
                      color: 'rgba(67,202,255,.8)'
                    }, {
                      offset: 1,
                      color: 'rgba(67,202,255,.3)'
                    }
                  ]
                }
              }
            }
          }
        ]
      };
    };

    ServerPerformanceinfoDirective.prototype.getSignalUnitName = function(scope, id) {
      var unitRel;
      unitRel = _.filter(scope.project.dictionary.signaltypes.items, function(unitItem) {
        return unitItem.model.type === id;
      });
      if (unitRel.length > 0) {
        return unitRel[0].model.unit;
      } else {
        return "";
      }
    };

    ServerPerformanceinfoDirective.prototype.resize = function(scope) {};

    ServerPerformanceinfoDirective.prototype.dispose = function(scope) {
      return _.mapObject(scope.subscribObjs, function(val, key) {
        return val != null ? val.dispose() : void 0;
      });
    };

    return ServerPerformanceinfoDirective;

  })(base.BaseDirective);
  return exports = {
    ServerPerformanceinfoDirective: ServerPerformanceinfoDirective
  };
});
