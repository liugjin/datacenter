// Generated by IcedCoffeeScript 108.0.12

/*
* File: credit-records-directive
* User: bingo
* Date: 2019/03/28
* Desc:
 */
var __iced_k, __iced_k_noop,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

__iced_k = __iced_k_noop = function() {};

if (typeof define !== 'function') { var define = require('amdefine')(module) };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var CreditRecordsDirective, exports;
  CreditRecordsDirective = (function(_super) {
    __extends(CreditRecordsDirective, _super);

    function CreditRecordsDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "credit-records";
      CreditRecordsDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    CreditRecordsDirective.prototype.setScope = function() {};

    CreditRecordsDirective.prototype.setCSS = function() {
      return css;
    };

    CreditRecordsDirective.prototype.setTemplate = function() {
      return view;
    };

    CreditRecordsDirective.prototype.show = function($scope, element, attrs) {
      var doorEquip, getCardOwner, getOpenDoorResult, loadEquipmentsByType, openDoorResults, queryCreditSignal, simpleData, _ref, _ref1;
      if (!$scope.firstload) {
        return;
      }
      element.css("display", "block");
      $scope.setting = setting;
      openDoorResults = [
        {
          result: 1,
          name: '开门成功'
        }, {
          result: 2,
          name: '无效的用户卡刷卡'
        }, {
          result: 3,
          name: '用户卡的有效期已过'
        }, {
          result: 4,
          name: '当前时间用户卡无进入权限'
        }
      ];
      $scope.pageIndex = 1;
      $scope.pageItems = 7;
      $scope.equipments = null;
      $scope.subBus = {};
      doorEquip = [];
      $scope.peopleEquip = [];
      $scope.cardEquip = [];
      $scope.project.loadStations(null, (function(_this) {
        return function(err, stations) {
          if (err || stations.length < 1) {
            return;
          }
          return $scope.stations = stations;
        };
      })(this));
      if ((_ref = $scope.subBus["stationId"]) != null) {
        _ref.dispose();
      }
      $scope.subBus["stationId"] = this.subscribeEventBus('stationId', (function(_this) {
        return function(d) {
          return _this.commonService.loadStation(d.message.stationId, function(err, station) {
            return $scope.station = station;
          });
        };
      })(this));
      if ((_ref1 = $scope.subBus["equipDoorId"]) != null) {
        _ref1.dispose();
      }
      $scope.subBus["equipDoorId"] = this.subscribeEventBus('equipDoorId', (function(_this) {
        return function(d) {
          return $scope.search = d.message.equipDoorId;
        };
      })(this));
      $scope.$watch("station", (function(_this) {
        return function(station) {
          if (!station) {
            return;
          }
          return loadEquipmentsByType(function() {
            return queryCreditSignal();
          });
        };
      })(this));
      loadEquipmentsByType = (function(_this) {
        return function(callback) {
          var getStationEquipment, mods;
          $scope.equipments = null;
          doorEquip = [];
          mods = [];
          getStationEquipment = function(station, callback) {
            var err, mod, sta, ___iced_passed_deferral, __iced_deferrals, __iced_k, _i, _len, _ref2;
            __iced_k = __iced_k_noop;
            ___iced_passed_deferral = iced.findDeferral(arguments);
            _ref2 = station.stations;
            for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
              sta = _ref2[_i];
              getStationEquipment(sta);
            }
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "C:\\ahuayuaniot\\codeET\\clc.datacenter\\app\\scripts\\datacenter\\src\\directives\\credit-records\\component.coffee"
              });
              _this.commonService.loadEquipmentsByType(station, "access", __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    err = arguments[0];
                    return mod = arguments[1];
                  };
                })(),
                lineno: 67
              }), false);
              __iced_deferrals._fulfill();
            })(function() {
              mods = mods.concat(mod);
              return typeof callback === "function" ? callback(mods) : void 0;
            });
          };
          return getStationEquipment($scope.station, function(equips) {
            var n;
            $scope.equipments = equips;
            if (equips.length === 0) {
              return typeof callback === "function" ? callback() : void 0;
            }
            n = 0;
            return _.each(equips, function(equip) {
              return equip.loadProperties(null, function(err, properties) {
                n++;
                if (equip.model.template.indexOf("door_") >= 0) {
                  doorEquip.push(equip);
                }
                if (equip.model.template.indexOf("people_") >= 0) {
                  $scope.peopleEquip.push(equip);
                }
                if (equip.model.template.indexOf("card_") >= 0) {
                  $scope.cardEquip.push(equip);
                }
                if (n === equips.length) {
                  return typeof callback === "function" ? callback() : void 0;
                }
              });
            });
          });
        };
      })(this);
      queryCreditSignal = (function(_this) {
        return function() {
          var data, filter;
          $scope.creditRecords = null;
          $scope.currentCreditInfo = null;
          filter = $scope.station.getIds();
          filter.station = {
            $in: _.map(_this.commonService.loadStationChildren($scope.station, true), function(sta) {
              return sta.model.station;
            })
          };
          filter.signal = "credit-card-info";
          filter.mode = "threshold";
          filter.startTime = moment().startOf('month').subtract(7, 'months');
          data = {
            filter: filter,
            fields: null
          };
          return _this.commonService.reportingService.querySignalRecords(data, function(err, records) {
            var filterRecords;
            if (err || records.length < 1) {
              return;
            }
            filterRecords = [];
            _.map(records, function(record) {
              var currentDoor, e;
              try {
                if (typeof record.value === "string") {
                  record.value = JSON.parse(record.value);
                }
                currentDoor = _.find(doorEquip, function(equip) {
                  return equip.model.equipment === record.equipment;
                });
                if (currentDoor && currentDoor.getPropertyValue("door-id") === record.value.door) {
                  if (!(_.contains(filterRecords, record))) {
                    return filterRecords.push(record);
                  }
                }
              } catch (_error) {
                e = _error;
                return console.log(e);
              }
            });
            return simpleData(filterRecords);
          });
        };
      })(this);
      getOpenDoorResult = (function(_this) {
        return function(result) {
          var openDoorName, openDoorResult;
          openDoorResult = _.find(openDoorResults, function(item) {
            return item.result === result;
          });
          if (openDoorResult) {
            openDoorName = openDoorResult.name;
          } else {
            openDoorName = '未知';
          }
          return openDoorName;
        };
      })(this);
      getCardOwner = function(cardNo) {
        var equip, equipName, userEquip, userId;
        equipName = '未知';
        if ((cardNo != null) && cardNo > 0) {
          equip = _.find($scope.cardEquip, (function(_this) {
            return function(equip) {
              return equip.model.equipment === cardNo.toString();
            };
          })(this));
          if (equip) {
            userId = equip.getPropertyValue('card-owner');
            userEquip = _.find($scope.peopleEquip, (function(_this) {
              return function(equip) {
                return equip.model.equipment.toString() === userId;
              };
            })(this));
            if (userEquip) {
              equipName = userEquip.model.name;
            }
          }
        }
        return equipName;
      };
      simpleData = (function(_this) {
        return function(records) {
          var dataRecords;
          if (records.length < 1) {
            return;
          }
          dataRecords = [];
          _.map(records, function(data) {
            var ownerobj, usernamestr, _ref2, _ref3;
            usernamestr = getCardOwner(data.value.cardNo);
            usernamestr = data.value.userName;
            if (usernamestr === "" || usernamestr === void 0) {
              if (data.value.cardNo === 0) {
                ownerobj = _.find($scope.userMsg, function(userobj) {
                  return userobj.user === data.value.operator;
                });
                usernamestr = ownerobj != null ? ownerobj.name : void 0;
              } else {
                usernamestr = getCardOwner(data.value.cardNo);
              }
            }
            return dataRecords.push({
              station: data.station,
              equipment: data.equipment,
              signal: data.signal,
              cardNo: data.value.cardNo,
              cardOwner: usernamestr,
              result: getOpenDoorResult(data.value.result),
              timestamp: moment(data.timestamp).format("YYYY-MM-DD HH:mm:ss"),
              stationName: ((_ref2 = _.find($scope.stations, function(station) {
                return data.station === station.model.station;
              })) != null ? _ref2.model.name : void 0) || "",
              equipmentName: ((_ref3 = _.find($scope.equipments, function(equip) {
                return (data.equipment === equip.model.equipment) && (data.station === equip.model.station);
              })) != null ? _ref3.model.name : void 0) || ""
            });
          });
          $scope.creditRecords = (_.sortBy(dataRecords, function(record) {
            return record.timestamp;
          })).reverse();
          return $scope.currentCreditInfo = $scope.creditRecords[0];
        };
      })(this);
      $scope.selectPage = (function(_this) {
        return function(page) {
          return $scope.pageIndex = page;
        };
      })(this);
      $scope.filterEquipmentItem = (function(_this) {
        return function() {
          var items, pageCount, result, _i, _results;
          if (!$scope.creditRecords) {
            return;
          }
          items = [];
          items = _.filter($scope.creditRecords, function(record) {
            var text, _ref2;
            text = (_ref2 = $scope.search) != null ? _ref2.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (record.equipment.toLowerCase().indexOf(text) >= 0) {
              return true;
            }
            return false;
          });
          pageCount = Math.ceil(items.length / $scope.pageItems);
          result = {
            page: 1,
            pageCount: pageCount,
            pages: (function() {
              _results = [];
              for (var _i = 1; 1 <= pageCount ? _i <= pageCount : _i >= pageCount; 1 <= pageCount ? _i++ : _i--){ _results.push(_i); }
              return _results;
            }).apply(this),
            items: items.length
          };
          return result;
        };
      })(this);
      $scope.limitToEquipment = (function(_this) {
        return function() {
          var aa, result;
          if ($scope.filterEquipmentItem() && $scope.filterEquipmentItem().pageCount === $scope.pageIndex) {
            aa = $scope.filterEquipmentItem().items % $scope.pageItems;
            result = -(aa === 0 ? $scope.pageItems : aa);
          } else {
            result = -$scope.pageItems;
          }
          return result;
        };
      })(this);
      return $scope.filterRecord = (function(_this) {
        return function() {
          return function(record) {
            var text, _ref2;
            text = (_ref2 = $scope.search) != null ? _ref2.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (record.equipment.toLowerCase().indexOf(text) >= 0) {
              return true;
            }
            return false;
          };
        };
      })(this);
    };

    CreditRecordsDirective.prototype.resize = function($scope) {};

    CreditRecordsDirective.prototype.dispose = function($scope) {
      return _.map($scope.subBus, (function(_this) {
        return function(value, key) {
          return value != null ? value.dispose() : void 0;
        };
      })(this));
    };

    return CreditRecordsDirective;

  })(base.BaseDirective);
  return exports = {
    CreditRecordsDirective: CreditRecordsDirective
  };
});
