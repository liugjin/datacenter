// Generated by IcedCoffeeScript 108.0.12

/*
* File: energy-management-directive
* User: David
* Date: 2019/02/21
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], function(base, css, view, _, moment, echarts) {
  var EnergyManagementDirective, exports;
  EnergyManagementDirective = (function(_super) {
    __extends(EnergyManagementDirective, _super);

    function EnergyManagementDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "energy-management";
      EnergyManagementDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    EnergyManagementDirective.prototype.setScope = function() {};

    EnergyManagementDirective.prototype.setCSS = function() {
      return css;
    };

    EnergyManagementDirective.prototype.setTemplate = function() {
      return view;
    };

    EnergyManagementDirective.prototype.show = function(scope, element, attrs) {
      var createChartOption, initData;
      initData = (function(_this) {
        return function() {
          var chartelement, options, _ref;
          scope.showSignal = [
            {
              id: 'office',
              name: '办公能耗',
              signal: 'power-office-value',
              value: 0
            }, {
              id: 'it',
              name: 'IT能耗',
              signal: 'power-it-value',
              value: 0
            }, {
              id: 'other',
              name: '制冷和其他能耗',
              value: 0
            }, {
              id: 'total',
              name: '总能耗',
              signal: 'power-facility-value',
              value: 0
            }
          ];
          scope.chartSignal = [
            {
              id: 'office',
              name: '办公能耗',
              signal: 'power-office-value',
              value: 0,
              itemStyle: {
                normal: {
                  color: "#43caff"
                }
              }
            }, {
              id: 'it',
              name: 'IT能耗',
              signal: 'power-it-value',
              value: 0,
              itemStyle: {
                normal: {
                  color: "#1d94ff"
                }
              }
            }, {
              id: 'other',
              name: '制冷和其他能耗',
              value: 0,
              itemStyle: {
                normal: {
                  color: "#bbd7f2"
                }
              }
            }
          ];
          scope.mychart = null;
          chartelement = element.find('.ratio-pie');
          scope.mychart = echarts.init(chartelement[0]);
          if ((_ref = scope.mychart) != null) {
            _ref.clear();
          }
          options = createChartOption(scope.chartSignal);
          return scope.mychart.setOption(options);
        };
      })(this);
      createChartOption = (function(_this) {
        return function(getData) {
          var option;
          option = {
            tooltip: {
              trigger: 'item',
              formatter: "{a} <br/>{b}: {c} ({d}%)"
            },
            series: [
              {
                name: '',
                type: 'pie',
                radius: ['45%', '60%'],
                data: getData,
                labelLine: {
                  normal: {
                    lineStyle: {
                      type: "dashed"
                    }
                  }
                },
                itemStyle: {
                  emphasis: {
                    shadowBlur: 10,
                    shadowOffsetX: 0,
                    shadowColor: 'rgba(0, 0, 0, 0.5)'
                  }
                }
              }
            ]
          };
          return option;
        };
      })(this);
      initData();
      return this.getEquipment(scope, "_station_efficient", (function(_this) {
        return function() {
          var _ref;
          if ((_ref = scope.subSignal) != null) {
            _ref.dispose();
          }
          return scope.subSignal = _this.commonService.subscribeEquipmentSignalValues(scope.equipment, function(sig) {
            var it, office, options, other, other1, total, _ref1, _ref2;
            if ((_ref1 = sig.model.signal) !== "power-office-value" && _ref1 !== "power-it-value" && _ref1 !== "power-facility-value") {
              return;
            }
            _.map(scope.showSignal, function(signal) {
              if (sig.model.signal === signal.signal) {
                return signal['value'] = sig.data.formatValue;
              }
            });
            total = _.find(scope.showSignal, function(sig) {
              return sig.id === "total";
            });
            it = _.find(scope.showSignal, function(sig) {
              return sig.id === "it";
            });
            office = _.find(scope.showSignal, function(sig) {
              return sig.id === "office";
            });
            other = _.find(scope.showSignal, function(sig) {
              return sig.id === "other";
            });
            other.value = parseFloat(total.value) - parseFloat(it.value) - parseFloat(office.value);
            _.map(scope.chartSignal, function(signal1) {
              if (sig.model.signal === signal1.signal) {
                return signal1['value'] = sig.data.formatValue;
              }
            });
            other1 = _.find(scope.chartSignal, function(sig) {
              return sig.id === "other";
            });
            other1.value = other.value;
            if ((_ref2 = scope.mychart) != null) {
              _ref2.clear();
            }
            options = createChartOption(scope.chartSignal);
            return scope.mychart.setOption(options);
          });
        };
      })(this));
    };

    EnergyManagementDirective.prototype.resize = function(scope) {
      var _ref;
      return (_ref = scope.mychart) != null ? _ref.resize() : void 0;
    };

    EnergyManagementDirective.prototype.dispose = function(scope) {
      var _ref;
      if ((_ref = scope.subSignal) != null) {
        _ref.dispose();
      }
      return scope.subSignal = null;
    };

    return EnergyManagementDirective;

  })(base.BaseDirective);
  return exports = {
    EnergyManagementDirective: EnergyManagementDirective
  };
});
