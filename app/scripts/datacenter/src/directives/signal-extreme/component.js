// Generated by IcedCoffeeScript 108.0.13

/*
* File: signal-extreme-directive
* User: David
* Date: 2019/06/21
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var SignalExtremeDirective, exports;
  SignalExtremeDirective = (function(_super) {
    __extends(SignalExtremeDirective, _super);

    function SignalExtremeDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "signal-extreme";
      SignalExtremeDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    SignalExtremeDirective.prototype.setScope = function() {};

    SignalExtremeDirective.prototype.setCSS = function() {
      return css;
    };

    SignalExtremeDirective.prototype.setTemplate = function() {
      return view;
    };

    SignalExtremeDirective.prototype.show = function($scope, element, attrs) {
      var loadEquips, processSignalData, template;
      $scope.subscribeSignals = {};
      template = null;
      $scope.lookSignals = {};
      $scope.lookSignals[$scope.parameters.signals[0]] = {
        signal: null,
        equips: {},
        data: []
      };
      $scope.lookSignals[$scope.parameters.signals[1]] = {
        signal: null,
        equips: {},
        data: []
      };
      $scope.project.loadEquipmentTemplates({
        template: $scope.parameters.template
      }, null, (function(_this) {
        return function(err, templates) {
          if (err || templates.length < 1) {
            return;
          }
          template = templates[0];
          return template.loadSignals(null, function(err, signals) {
            var signal1, signal2, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
            if (err || signals.length < 1) {
              return;
            }
            signal1 = _.find(signals, function(signal) {
              return signal.model.signal === $scope.parameters.signals[0];
            });
            if (signal1) {
              signal1.model.unitName = (_ref = $scope.project) != null ? (_ref1 = _ref.dictionary.signaltypes.getItem(signal1.model.unit)) != null ? (_ref2 = _ref1.model) != null ? _ref2.unit : void 0 : void 0 : void 0;
              $scope.lookSignals[$scope.parameters.signals[0]].signal = signal1;
            }
            signal2 = _.find(signals, function(signal) {
              return signal.model.signal === $scope.parameters.signals[1];
            });
            if (signal2) {
              signal2.model.unitName = (_ref3 = $scope.project) != null ? (_ref4 = _ref3.typeModels.signaltypes.getItem(signal2.model.unit)) != null ? (_ref5 = _ref4.model) != null ? _ref5.unit : void 0 : void 0 : void 0;
              return $scope.lookSignals[$scope.parameters.signals[1]].signal = signal2;
            }
          });
        };
      })(this));
      processSignalData = (function(_this) {
        return function(signal) {
          var _ref, _ref1;
          if ((_ref = $scope.lookSignals[signal.model.signal]) != null) {
            _ref.equips[signal.equipment.key] = {
              name: signal.equipment.model.name,
              value: 0
            };
          }
          if (signal.data.value) {
            if ((_ref1 = $scope.lookSignals[signal.model.signal]) != null) {
              _ref1.equips[signal.equipment.key].value = signal.data.value.toFixed(2);
            }
          }
          return _.mapObject($scope.lookSignals, function(value, key) {
            return value.data = _.sortBy(_.filter(_.values(value.equips), function(ite) {
              return ite.value > 0 && ite.value < 100;
            }), function(item) {
              return item.value;
            });
          });
        };
      })(this);
      loadEquips = (function(_this) {
        return function() {
          var filter;
          filter = {
            user: $scope.station.model.user,
            project: $scope.station.model.project,
            station: $scope.station.model.station,
            type: $scope.parameters.type,
            template: $scope.parameters.template
          };
          return $scope.station.loadEquipments(filter, null, function(err, equipments) {
            return _.each(equipments, function(equip) {
              var _ref;
              if ((_ref = $scope.subscribeSignals[equip.key]) != null) {
                _ref.dispose();
              }
              return $scope.subscribeSignals[equip.key] = _this.commonService.subscribeEquipmentSignalValues(equip, function(signal) {
                if (!signal || !signal.data) {
                  return;
                }
                return processSignalData(signal);
              });
            });
          });
        };
      })(this);
      return loadEquips();
    };

    SignalExtremeDirective.prototype.resize = function($scope) {};

    SignalExtremeDirective.prototype.dispose = function($scope) {
      return _.mapObject($scope.subscribeSignals, (function(_this) {
        return function(value, key) {
          return value.dispose();
        };
      })(this));
    };

    return SignalExtremeDirective;

  })(base.BaseDirective);
  return exports = {
    SignalExtremeDirective: SignalExtremeDirective
  };
});
