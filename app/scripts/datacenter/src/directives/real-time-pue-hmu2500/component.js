// Generated by IcedCoffeeScript 108.0.13

/*
* File: real-time-pue-hmu2500-directive
* User: David
* Date: 2020/05/07
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], function(base, css, view, _, moment, echarts) {
  var RealTimePueHmu2500Directive, exports;
  RealTimePueHmu2500Directive = (function(_super) {
    __extends(RealTimePueHmu2500Directive, _super);

    function RealTimePueHmu2500Directive($timeout, $window, $compile, $routeParams, commonService) {
      this.createLineCharts = __bind(this.createLineCharts, this);
      this.getPueSignal = __bind(this.getPueSignal, this);
      this.getPueEquipmentSignal = __bind(this.getPueEquipmentSignal, this);
      this.show = __bind(this.show, this);
      this.id = "real-time-pue-hmu2500";
      RealTimePueHmu2500Directive.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    RealTimePueHmu2500Directive.prototype.setScope = function() {};

    RealTimePueHmu2500Directive.prototype.setCSS = function() {
      return css;
    };

    RealTimePueHmu2500Directive.prototype.setTemplate = function() {
      return view;
    };

    RealTimePueHmu2500Directive.prototype.show = function(scope, element, attrs) {
      this.formulaAll = "";
      this.formulaIT = "";
      scope.variablesCount = 0;
      scope.variablesAll = [];
      scope.variablesIT = [];
      scope.pueSignal = {};
      scope.pueEquips = [];
      scope.xData = [];
      this.getPueEquipmentSignal(scope);
      this.getPueSignal(scope, (function(_this) {
        return function() {
          var _ref;
          _this.commonService.querySignalHistoryData(scope.signal, moment().startOf("day"), moment().endOf("day"), function(err, records, pageInfo) {
            var record, _i, _len, _ref;
            for (_i = 0, _len = records.length; _i < _len; _i++) {
              record = records[_i];
              scope.xData.push({
                value: [record.timestamp, (_ref = record.value) != null ? _ref.toFixed(2) : void 0]
              });
            }
            return _this.createLineCharts(scope, element);
          });
          if ((_ref = scope.equipSubscriptionrealpue) != null) {
            _ref.dispose();
          }
          return scope.equipSubscriptionrealpue = _this.commonService.subscribeSignalValue(scope.signal, function(sig) {
            var _ref1, _ref2;
            if (sig.data.timestamp) {
              scope.option.series[0].data.push({
                value: [sig.data.timestamp, (_ref1 = sig.data.value) != null ? _ref1.toFixed(2) : void 0]
              });
            }
            return (_ref2 = scope.echart) != null ? _ref2.setOption(scope.option) : void 0;
          });
        };
      })(this));
      scope.selectEquipment = (function(_this) {
        return function(variable) {
          var variableStation, variableValueArr;
          variableValueArr = variable.value.split("/");
          variableStation = variableValueArr[0];
          variable.equipmentInfo = _.find(scope.pueEquips, function(equip) {
            return equip.model.equipment === variable.equipment;
          });
          variable.signal = variable.equipmentInfo.signals.items[0].model.signal;
          variable.value = "" + variableStation + "/" + variable.equipment + "/" + variable.signal;
          return scope.selectRefresh++;
        };
      })(this);
      scope.slelectSignal = (function(_this) {
        return function(variable) {
          var variableEquipment, variableStation, variableValueArr;
          variableValueArr = variable.value.split("/");
          variableStation = variableValueArr[0];
          variableEquipment = variableValueArr[1];
          return variable.value = "" + variableStation + "/" + variableEquipment + "/" + variable.signal;
        };
      })(this);
      scope.deleteVariable = (function(_this) {
        return function(variable, type) {
          if (type === "all") {
            return scope.variablesAll = _.reject(scope.variablesAll, function(item) {
              return item.key === variable.key;
            });
          } else if (type === "IT") {
            return scope.variablesIT = _.reject(scope.variablesIT, function(item) {
              return item.key === variable.key;
            });
          }
        };
      })(this);
      scope.addVariable = (function(_this) {
        return function(type) {
          var firstPueEquipment, firstPueEquipmentSignal, isKeyRepeat, variable, variableKey;
          isKeyRepeat = function(variableKey) {
            var changeVariableKey, hasAll, hasIT;
            changeVariableKey = variableKey;
            hasAll = _.find(scope.variablesAll, function(item) {
              return item.key === variableKey;
            });
            hasIT = _.find(scope.variablesIT, function(item) {
              return item.key === variableKey;
            });
            if (!_.isEmpty(hasAll) || !_.isEmpty(hasIT)) {
              scope.variablesCount++;
              changeVariableKey = "v" + scope.variablesCount;
              return isKeyRepeat(changeVariableKey);
            } else {
              return changeVariableKey;
            }
          };
          variableKey = "v" + scope.variablesCount;
          variableKey = isKeyRepeat(variableKey);
          firstPueEquipment = scope.pueEquips[0];
          firstPueEquipmentSignal = scope.pueEquips[0].signals.items[0];
          variable = {
            equipment: firstPueEquipment.model.equipment,
            equipmentInfo: firstPueEquipment,
            key: variableKey,
            signal: firstPueEquipmentSignal.model.signal,
            symbol: "+",
            type: "signal-value",
            value: "" + firstPueEquipment.station.model.station + "/" + firstPueEquipment.model.equipment + "/" + firstPueEquipmentSignal.model.signal
          };
          if (type === "all") {
            return scope.variablesAll.push(variable);
          } else if (type === "IT") {
            return scope.variablesIT.push(variable);
          }
        };
      })(this);
      return scope.saveVariable = (function(_this) {
        return function(type, variables) {
          var isCommonObj, isHasCommonObj, newFormula, newVariables, variable, _i, _len;
          if (_.isEmpty(variables)) {
            return _this.display("总体能耗和IT能耗均不能为空");
          }
          isHasCommonObj = function(arr, key, val) {
            var repeatVariable, variable, _i, _len;
            repeatVariable = [];
            for (_i = 0, _len = arr.length; _i < _len; _i++) {
              variable = arr[_i];
              if (variable[key] === val) {
                repeatVariable.push(variable);
              }
            }
            if (repeatVariable.length >= 2) {
              return repeatVariable;
            }
          };
          for (_i = 0, _len = variables.length; _i < _len; _i++) {
            variable = variables[_i];
            isCommonObj = isHasCommonObj(variables, "value", variable.value);
            if (!_.isEmpty(isCommonObj)) {
              return _this.display("保存的项目中不能有重复的项");
            }
          }
          newFormula = "(";
          _.each(variables, function(item, num) {
            if (num === 0 && item.symbol === "+") {
              return newFormula = newFormula + item.key;
            } else {
              return newFormula = newFormula + item.symbol + item.key;
            }
          });
          newFormula = newFormula + ")";
          if (type === "all") {
            scope.pueSignal.model.expression.formula = "" + newFormula + "/" + _this.formulaIT;
          } else if (type === "IT") {
            scope.pueSignal.model.expression.formula = "" + _this.formulaAll + "/" + newFormula;
          }
          newVariables = [];
          newVariables = newVariables.concat(scope.variablesAll);
          newVariables = newVariables.concat(scope.variablesIT);
          scope.pueSignal.model.expression.variables = _.map(newVariables, function(item) {
            return {
              type: item.type,
              value: item.value,
              key: item.key
            };
          });
          return scope.pueSignal.save();
        };
      })(this);
    };

    RealTimePueHmu2500Directive.prototype.getPueEquipmentSignal = function(scope) {
      var getStationEfficientPue;
      getStationEfficientPue = (function(_this) {
        return function(_station_efficient) {
          return _station_efficient.loadSignals(null, function(err, signals) {
            var formula, formulaArr, variables;
            scope.pueSignal = _.find(signals, function(signal) {
              return signal.model.signal === "pue-value";
            });
            formula = scope.pueSignal.model.expression.formula;
            variables = scope.pueSignal.model.expression.variables;
            formulaArr = formula.split("/");
            _this.formulaAll = formulaArr[0];
            _this.formulaIT = formulaArr[1];
            return _.each(variables, function(variable) {
              var _hasAll, _hasIT, _symbol, _variableArr;
              _variableArr = variable.value.split("/");
              variable.equipment = _variableArr[1];
              variable.signal = _variableArr[2];
              _hasAll = _this.formulaAll.indexOf(variable.key);
              _hasIT = _this.formulaIT.indexOf(variable.key);
              _symbol = _this.formulaAll[_hasAll - 1] || _this.formulaIT[_hasIT - 1];
              variable.equipmentInfo = _.find(scope.pueEquips, function(equip) {
                return equip.model.equipment === variable.equipment;
              });
              if (_symbol === "(" || _symbol === "+") {
                variable.symbol = "+";
              } else {
                variable.symbol = "-";
              }
              if (_hasAll !== -1) {
                return scope.variablesAll.push(variable);
              } else if (_hasIT !== -1) {
                return scope.variablesIT.push(variable);
              }
            });
          });
        };
      })(this);
      return scope.station.loadEquipments({}, null, (function(_this) {
        return function(err, equips) {
          var pueEquipsLength, _station_efficient;
          scope.pueEquips = _.filter(equips, function(equip) {
            return equip.model.type === "pdu" || equip.model.type === "ups" || equip.model.type === "low_voltage_distribution" || equip.model.type === "meter";
          });
          pueEquipsLength = scope.pueEquips.length;
          _station_efficient = _.find(equips, function(equip) {
            return equip.model.equipment === "_station_efficient";
          });
          return _.each(scope.pueEquips, function(equip) {
            return equip.loadSignals(null, function(err, signals) {
              pueEquipsLength--;
              equip.signals.items = _.filter(equip.signals.items, function(item) {
                return item.model.unit === "active-power";
              });
              if (pueEquipsLength === 0) {
                return getStationEfficientPue(_station_efficient);
              }
            });
          });
        };
      })(this));
    };

    RealTimePueHmu2500Directive.prototype.getPueSignal = function(scope, callback) {
      return this.commonService.loadEquipmentById(scope.station, "_station_efficient", (function(_this) {
        return function(err, equip) {
          return equip != null ? equip.loadSignals(null, function(err, sigs) {
            scope.signal = _.find(sigs, function(sig) {
              return sig.model.signal === "pue-value";
            });
            return typeof callback === "function" ? callback() : void 0;
          }) : void 0;
        };
      })(this));
    };

    RealTimePueHmu2500Directive.prototype.createLineCharts = function(scope, element) {
      var line, _ref, _ref1;
      line = element.find(".signal-line");
      if ((_ref = scope.echart) != null) {
        _ref.dispose();
      }
      scope.option = {
        xAxis: {
          type: 'time',
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
          trigger: "axis"
        },
        series: [
          {
            data: scope.xData,
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
                  x: 1,
                  y: 1,
                  x2: 1,
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
      scope.echart = echarts.init(line[0]);
      return (_ref1 = scope.echart) != null ? _ref1.setOption(scope.option) : void 0;
    };

    RealTimePueHmu2500Directive.prototype.resize = function(scope) {
      var _ref;
      return (_ref = scope.echart) != null ? _ref.resize() : void 0;
    };

    RealTimePueHmu2500Directive.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.equipSubscriptionrealpue) != null ? _ref.dispose() : void 0;
    };

    return RealTimePueHmu2500Directive;

  })(base.BaseDirective);
  return exports = {
    RealTimePueHmu2500Directive: RealTimePueHmu2500Directive
  };
});