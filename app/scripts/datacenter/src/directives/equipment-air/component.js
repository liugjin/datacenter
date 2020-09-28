// Generated by IcedCoffeeScript 108.0.12

/*
* File: equipment-air-directive
* User: David
* Date: 2019/12/04
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var EquipmentAirDirective, exports;
  EquipmentAirDirective = (function(_super) {
    __extends(EquipmentAirDirective, _super);

    function EquipmentAirDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "equipment-air";
      EquipmentAirDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    EquipmentAirDirective.prototype.setScope = function() {};

    EquipmentAirDirective.prototype.setCSS = function() {
      return css;
    };

    EquipmentAirDirective.prototype.setTemplate = function() {
      return view;
    };

    EquipmentAirDirective.prototype.show = function(scope, element, attrs) {
      var init;
      scope.selectEquipment = (function(_this) {
        return function(equip) {
          var filter, _ref;
          if (equip.model.equipment) {
            filter = {
              project: equip.model.project,
              user: equip.model.user,
              station: equip.model.station,
              equipment: equip.model.equipment,
              signal: "communication-status"
            };
            scope.theAirStatu.equipStatu = "--";
            scope.theAirStatu.equipName = equip.model.name;
            if ((_ref = scope.subscribeStation) != null) {
              _ref.dispose();
            }
            return scope.subscribeStation = _this.commonService.signalLiveSession.subscribeValues(filter, function(err, signal) {
              if (signal.message) {
                if (signal.message.value === 0) {
                  scope.colorChange = false;
                  return scope.theAirStatu.equipStatu = "正常";
                } else {
                  scope.colorChange = true;
                  return scope.theAirStatu.equipStatu = "断开";
                }
              }
            });
          } else {
            scope.theAirStatu.equipName = "无空调设备";
            return scope.theAirStatu.equipStatu = "--";
          }
        };
      })(this);
      init = (function(_this) {
        return function() {
          var stationsNum;
          scope.theAirStatu = {
            equipName: "",
            equipStatu: ""
          };
          scope.equipments = [];
          scope.colorChange = false;
          scope.stations = _.each(scope.project.stations.nitems, function(n) {
            return n.model.station;
          });
          stationsNum = scope.project.stations.items.length;
          return _.each(scope.stations, function(station) {
            return station != null ? station.loadEquipments({
              type: "aircondition"
            }, null, function(err, equips) {
              stationsNum--;
              scope.equipments = scope.equipments.concat(equips);
              if (stationsNum === 0) {
                return scope.selectEquipment(scope.equipments[0]);
              }
            }, true) : void 0;
          });
        };
      })(this);
      return init();
    };

    EquipmentAirDirective.prototype.resize = function(scope) {};

    EquipmentAirDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.subscribeStation) != null ? _ref.dispose() : void 0;
    };

    return EquipmentAirDirective;

  })(base.BaseDirective);
  return exports = {
    EquipmentAirDirective: EquipmentAirDirective
  };
});
