// Generated by IcedCoffeeScript 108.0.12

/*
* File: distribution-manager-directive
* User: bingo
* Date: 2019/05/31
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var DistributionManagerDirective, exports;
  DistributionManagerDirective = (function(_super) {
    __extends(DistributionManagerDirective, _super);

    function DistributionManagerDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "distribution-manager";
      DistributionManagerDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    DistributionManagerDirective.prototype.setScope = function() {};

    DistributionManagerDirective.prototype.setCSS = function() {
      return css;
    };

    DistributionManagerDirective.prototype.setTemplate = function() {
      return view;
    };

    DistributionManagerDirective.prototype.show = function($scope, element, attrs) {
      var loadDistributionEquips, preference, selectType;
      $scope.equipments = [];
      $scope.selectSignals = [];
      preference = null;
      if (localStorage.getItem('distribution-manager')) {
        preference = JSON.parse(localStorage.getItem('distribution-manager'));
      }
      $scope.$watch("station", (function(_this) {
        return function(station) {
          if (!station) {
            return;
          }
          $scope.equipments = [];
          $scope.equipment = null;
          $scope.selectSignals = [];
          return loadDistributionEquips();
        };
      })(this));
      loadDistributionEquips = (function(_this) {
        return function() {
          return selectType($scope.parameters.type);
        };
      })(this);
      selectType = (function(_this) {
        return function(type, callback, refresh) {
          var getStationEquipment;
          if (!type) {
            return;
          }
          getStationEquipment = function(station, callback) {
            var filter, sta, _i, _len, _ref;
            _ref = station.stations;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              sta = _ref[_i];
              getStationEquipment(sta, callback);
            }
            filter = {
              user: station.model.user,
              project: station.model.project,
              station: station.model.station,
              type: type
            };
            return station.loadEquipments(filter, null, function(err, mods) {
              return typeof callback === "function" ? callback(mods) : void 0;
            }, refresh);
          };
          return getStationEquipment($scope.station, function(equips) {
            var currentEquip, diff, equipments;
            diff = _.difference(equips, $scope.equipments);
            $scope.equipments = $scope.equipments.concat(diff);
            $scope.$applyAsync();
            if (!$scope.equipments || $scope.equipments.length < 1) {
              return;
            }
            equipments = _.sortBy($scope.equipments, function(equip) {
              return equip.model.index;
            });
            currentEquip = null;
            if (preference) {
              currentEquip = _.find(equipments, function(equip) {
                return equip.model.station === preference.station && equip.model.equipment === preference.equipment;
              });
            }
            if (currentEquip) {
              return $scope.selectEquipment(currentEquip);
            } else {
              return $scope.selectEquipment(equipments[equipments.length - 1]);
            }
          });
        };
      })(this);
      return $scope.selectEquipment = (function(_this) {
        return function(equip) {
          var selectSignals;
          if (!equip) {
            return;
          }
          preference = {
            station: equip.model.station,
            equipment: equip.model.equipment
          };
          localStorage.setItem('distribution-manager', JSON.stringify(preference));
          selectSignals = [];
          $scope.equipment = equip;
          return $scope.equipment.loadProperties(null, function(err, properties) {
            var signalsProperty;
            signalsProperty = _.find(properties, function(property) {
              return property.model.property === "_signals";
            });
            if (signalsProperty) {
              if (signalsProperty.value) {
                _.map(JSON.parse(signalsProperty.value), function(item) {
                  return selectSignals.push(item.signal);
                });
              }
              return $scope.selectSignals = selectSignals;
            }
          });
        };
      })(this);
    };

    DistributionManagerDirective.prototype.resize = function($scope) {};

    DistributionManagerDirective.prototype.dispose = function($scope) {};

    return DistributionManagerDirective;

  })(base.BaseDirective);
  return exports = {
    DistributionManagerDirective: DistributionManagerDirective
  };
});
