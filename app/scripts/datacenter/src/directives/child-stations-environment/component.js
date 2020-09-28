// Generated by IcedCoffeeScript 108.0.13

/*
* File: child-stations-environment-directive
* User: David
* Date: 2019/06/02
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var ChildStationsEnvironmentDirective, exports;
  ChildStationsEnvironmentDirective = (function(_super) {
    __extends(ChildStationsEnvironmentDirective, _super);

    function ChildStationsEnvironmentDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "child-stations-environment";
      ChildStationsEnvironmentDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    ChildStationsEnvironmentDirective.prototype.setScope = function() {};

    ChildStationsEnvironmentDirective.prototype.setCSS = function() {
      return css;
    };

    ChildStationsEnvironmentDirective.prototype.setTemplate = function() {
      return view;
    };

    ChildStationsEnvironmentDirective.prototype.show = function(scope, element, attrs) {
      scope.stations = {};
      scope.subscriptions = {};
      scope.templates = {};
      return scope.project.loadEquipmentTemplates({
        type: "environmental"
      }, null, (function(_this) {
        return function(err, templates) {
          var template, _i, _len;
          for (_i = 0, _len = templates.length; _i < _len; _i++) {
            template = templates[_i];
            scope.templates[template.model.type + "." + template.model.template] = template;
          }
          scope.station.stations = _.sortBy(scope.station.stations, function(item) {
            return 10 - item.model.index;
          });
          return _.each(scope.station.stations, function(sta) {
            scope.stations[sta.model.station] = {
              id: sta.model.station,
              name: sta.model.name
            };
            return _this.getStationEnvironment(scope, sta);
          });
        };
      })(this));
    };

    ChildStationsEnvironmentDirective.prototype.getStationEnvironment = function(scope, station) {
      return this.commonService.loadEquipmentsByType(station, "environmental", (function(_this) {
        return function(err, equipments) {
          var leak, leaks, smoke, smokes, th, ths;
          ths = _this.getTemplatesByBase(scope, "environmental.temperature_humidity_template");
          leaks = _this.getTemplatesByBase(scope, "environmental.leak_sensor_template");
          smokes = _this.getTemplatesByBase(scope, "environmental.smoke_template");
          th = _.max(_.filter(equipments, function(equip) {
            var _ref;
            return _ref = equip.model.type + "." + equip.model.template, __indexOf.call(ths, _ref) >= 0;
          }), function(item) {
            return item.model.index;
          });
          leak = _.max(_.filter(equipments, function(equip) {
            var _ref;
            return _ref = equip.model.type + "." + equip.model.template, __indexOf.call(leaks, _ref) >= 0;
          }), function(item) {
            return item.model.index;
          });
          smoke = _.max(_.filter(equipments, function(equip) {
            var _ref;
            return _ref = equip.model.type + "." + equip.model.template, __indexOf.call(smokes, _ref) >= 0;
          }), function(item) {
            return item.model.index;
          });
          _this.subscribeSignalValues(scope, th);
          _this.subscribeSignalValues(scope, leak);
          return _this.subscribeSignalValues(scope, smoke);
        };
      })(this));
    };

    ChildStationsEnvironmentDirective.prototype.getTemplatesByBase = function(scope, base) {
      var result, template, templates, _i, _len;
      result = [base];
      templates = _.filter(scope.templates, function(val, key) {
        return val.model.base === base;
      });
      for (_i = 0, _len = templates.length; _i < _len; _i++) {
        template = templates[_i];
        result = result.concat(this.getTemplatesByBase(scope, template.model.type + "." + template.model.template));
      }
      return result;
    };

    ChildStationsEnvironmentDirective.prototype.subscribeSignalValues = function(scope, equipment) {
      var _ref;
      if (!_.isEmpty(equipment)) {
        if ((_ref = scope.subscriptions[equipment.key]) != null) {
          _ref.dispose();
        }
        return scope.subscriptions[equipment.key] = this.commonService.subscribeEquipmentSignalValues(equipment, (function(_this) {
          return function(signal) {
            var color, unitName, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
            unitName = (_ref1 = (_ref2 = scope.project) != null ? (_ref3 = _ref2.typeModels.signaltypes.getItem(signal.model.unit)) != null ? (_ref4 = _ref3.model) != null ? _ref4.unit : void 0 : void 0 : void 0) != null ? _ref1 : "";
            color = (_ref5 = (_ref6 = scope.project) != null ? (_ref7 = _ref6.typeModels.eventseverities.getItem(signal.data.severity)) != null ? (_ref8 = _ref7.model) != null ? _ref8.color : void 0 : void 0 : void 0) != null ? _ref5 : "";
            return scope.stations[equipment.model.station][signal.model.signal] = {
              value: ((_ref9 = signal.data) != null ? _ref9.formatValue : void 0) + unitName,
              color: color
            };
          };
        })(this));
      }
    };

    ChildStationsEnvironmentDirective.prototype.resize = function(scope) {};

    ChildStationsEnvironmentDirective.prototype.dispose = function(scope) {
      var key, value, _ref, _results;
      _ref = scope.subscriptions;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(value != null ? value.dispose() : void 0);
      }
      return _results;
    };

    return ChildStationsEnvironmentDirective;

  })(base.BaseDirective);
  return exports = {
    ChildStationsEnvironmentDirective: ChildStationsEnvironmentDirective
  };
});
