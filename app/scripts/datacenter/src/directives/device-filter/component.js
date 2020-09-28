// Generated by IcedCoffeeScript 108.0.13

/*
* File: device-filter-directive
* User: David
* Date: 2019/04/25
* Desc:
 */
var __iced_k, __iced_k_noop,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

__iced_k = __iced_k_noop = function() {};

if (typeof define !== 'function') { var define = require('amdefine')(module) };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var DeviceFilterDirective, exports;
  DeviceFilterDirective = (function(_super) {
    __extends(DeviceFilterDirective, _super);

    function DeviceFilterDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.getAllStations = __bind(this.getAllStations, this);
      this.show = __bind(this.show, this);
      this.id = "device-filter";
      DeviceFilterDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.allInventoryStations = [];
    }

    DeviceFilterDirective.prototype.setScope = function() {};

    DeviceFilterDirective.prototype.setCSS = function() {
      return css;
    };

    DeviceFilterDirective.prototype.setTemplate = function() {
      return view;
    };

    DeviceFilterDirective.prototype.show = function(scope, element, attrs) {
      var allStations, getEquipNumber, getStationEquipTypes, loadAllUsers, loadChildSta, loadEquipType, loadEquipsByAdd, loadStatisticByEquipmentTypes, processTypes, selectStation, selectType, setEquipmentData, settingEquipSampleUnits, sortList;
      element.css("display", "block");
      allStations = [];
      scope.equipTypeLists = [];
      scope.setting = setting;
      scope.currentType = null;
      scope.view = false;
      scope.detail = false;
      scope.edit = false;
      scope.add = false;
      scope.equipSubscription = {};
      scope.viewName = '视图';
      scope.pageIndex = 1;
      scope.pageItems = 8;
      scope.addImg = this.getComponentPath('image/add.svg');
      scope.viewImg = this.getComponentPath('image/view.svg');
      scope.backImg = this.getComponentPath('image/back.svg');
      scope.detailBlueImg = this.getComponentPath('image/detail-blue.svg');
      scope.editBlueImg = this.getComponentPath('image/edit-blue.svg');
      scope.saveImg = this.getComponentPath('image/save-blue.svg');
      scope.detailGreenImg = this.getComponentPath('image/detail-green.svg');
      scope.editGreenImg = this.getComponentPath('image/edit-green.svg');
      scope.deleteGreenImg = this.getComponentPath('image/delete-green.svg');
      sortList = _.map(_.sortBy(_.filter(scope.project.dictionary.equipmenttypes.items, function(d) {
        return _.has(d.model, "visible") && d.model.visible;
      }), function(m) {
        return m.index;
      }), function(n) {
        return {
          key: n.key,
          img: n.image
        };
      });
      scope.project.loadEquipmentTemplates({}, 'user project type vendor template name base index image');
      scope.project.loadStations(null, (function(_this) {
        return function(err, stations) {
          var dataCenters;
          dataCenters = _.filter(stations, function(sta) {
            return (sta.model.parent === null || sta.model.parent === "") && sta.model.station.charAt(0) !== "_";
          });
          scope.datacenters = dataCenters;
          scope.stations = dataCenters;
          scope.station = dataCenters[0];
          return scope.parents = [];
        };
      })(this));
      scope.selectChild = (function(_this) {
        return function(station) {
          scope.stations = scope.station.stations;
          scope.parents.push(scope.station);
          return scope.station = station;
        };
      })(this);
      scope.selectParent = (function(_this) {
        return function(station) {
          var index, _ref, _ref1;
          index = scope.parents.indexOf(station);
          scope.parents.splice(index, scope.parents.length - index);
          scope.station = station;
          return scope.stations = (_ref = (_ref1 = station.parentStation) != null ? _ref1.stations : void 0) != null ? _ref : scope.datacenters;
        };
      })(this);
      loadAllUsers = (function(_this) {
        return function() {
          var fields, filter, userService;
          userService = _this.commonService.modelEngine.modelManager.getService('users');
          filter = {};
          fields = null;
          return userService.query(filter, fields, function(err, data) {
            if (!err) {
              return scope.userMsg = data;
            }
          });
        };
      })(this);
      loadChildSta = (function(_this) {
        return function(sta, allStations) {
          var getSta, _list;
          _list = [];
          getSta = function(id) {
            var current;
            current = _.find(allStations, function(d) {
              return d.station === id;
            });
            _list.push(id);
            if (current.child.length !== 0) {
              return _.map(current.child, function(d) {
                return getSta(d);
              });
            }
          };
          getSta(sta.station);
          return _list;
        };
      })(this);
      loadEquipType = function(sta, allData) {
        return _.map(_.groupBy(_.filter(allData, (function(_this) {
          return function(d) {
            return sta.child.indexOf(d.station) !== -1;
          };
        })(this)), function(m) {
          return m.type;
        }), function(n) {
          var x, _i, _ref;
          if (n.length > 1) {
            for (x = _i = 1, _ref = n.length - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; x = 1 <= _ref ? ++_i : --_i) {
              n[0].count += n[x].count;
            }
          }
          return {
            type: n[0].type,
            name: n[0].name,
            count: n[0].count
          };
        });
      };
      loadStatisticByEquipmentTypes = (function(_this) {
        return function() {
          return getStationEquipTypes(function(equips, equipData) {
            var arr, _item;
            arr = equips;
            allStations = _.sortBy(_.map(arr, function(d) {
              d.statistic = loadEquipType(d, equipData);
              return d;
            }), function(m) {
              return arr.length - m.child.length;
            });
            if (_.has(_this.$routeParams, "station")) {
              _item = _.find(allStations, function(d) {
                return d.station === _this.$routeParams.station;
              });
              selectStation(_item.station);
              return processTypes(_.map(_item.statistic, function(d) {
                return d;
              }), true);
            } else {
              selectStation(allStations[0].station);
              return processTypes(_.map(allStations[0].statistic, function(d) {
                return d;
              }), true);
            }
          });
        };
      })(this);
      getStationEquipTypes = (function(_this) {
        return function(callback) {
          var allEquipModels, allInventoryStationsCount, allInventoryStationsLen, allTypeCount, stationObj, _i, _len, _ref, _results;
          _this.allInventoryStations = [];
          _this.getAllStations(scope, scope.station.model.station);
          allInventoryStationsLen = _this.allInventoryStations.length;
          allInventoryStationsCount = 0;
          allEquipModels = [];
          allTypeCount = [];
          _ref = _this.allInventoryStations;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            stationObj = _ref[_i];
            _results.push(stationObj.loadStatisticByEquipmentTypes(function(err, mod) {
              var x, _j, _len1, _ref1;
              if (mod) {
                _ref1 = _this.allInventoryStations;
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  x = _ref1[_j];
                  if (x.model.station === mod.station) {
                    allEquipModels.push({
                      station: mod.station,
                      child: _.has(x, "stations") ? _.map(x.stations, function(d) {
                        return d.model.station;
                      }).concat([mod.station]) : [mod.station]
                    });
                    break;
                  }
                }
                _.map(mod.statistic, function(d) {
                  if (d.count !== 0 && d.type !== "_station_management") {
                    return allTypeCount.push({
                      type: d.type,
                      name: d.name,
                      count: d.count,
                      station: mod.station
                    });
                  }
                });
                allInventoryStationsCount++;
                if (allInventoryStationsCount === allInventoryStationsLen) {
                  return callback(allEquipModels, allTypeCount);
                }
              }
            }, true));
          }
          return _results;
        };
      })(this);
      loadStatisticByEquipmentTypes();
      processTypes = (function(_this) {
        return function(data, refresh) {
          var _item;
          if (!data || data.length === 0) {
            return;
          }
          _.map(data, function(type) {
            var currentType;
            currentType = _.find(scope.project.dictionary.equipmenttypes.items, function(item) {
              return item.model.type === type.type;
            });
            if (currentType.model.image) {
              return type.image = currentType.model.image;
            }
          });
          if (_.has(_this.$routeParams, "equipmentType")) {
            _item = _.find(data, function(d) {
              return d.type === _this.$routeParams.equipmentType;
            });
            scope.currentType = _item ? _item : data[0];
          } else {
            scope.currentType = data[0];
          }
          return selectType(scope.currentType.type, null, refresh);
        };
      })(this);
      selectStation = (function(_this) {
        return function(stationId) {
          var _sta;
          scope.station = _.find(_this.allInventoryStations, function(d) {
            return d.model.station === stationId;
          });
          scope.detail = false;
          scope.edit = false;
          scope.add = false;
          scope.currentType = null;
          scope.childStations = [];
          _sta = _.find(allStations, function(d) {
            return d.station === stationId;
          });
          if (_sta.statistic.length === 0) {
            scope.equipTypeLists = [];
            scope.equipments = [];
            return scope.$applyAsync();
          } else {
            scope.equipTypeLists = _.sortBy(_sta.statistic, function(m) {
              return _.indexOf(sortList, function(x) {
                return x.key === m.type;
              });
            });
            processTypes(scope.equipTypeLists, true);
            return loadAllUsers();
          }
        };
      })(this);
      selectType = (function(_this) {
        return function(type, callback, refresh) {
          var getStationEquipment, mods, processEquipinfos;
          if (!type) {
            return;
          }
          mods = [];
          getStationEquipment = function(station, callback) {
            var err, mod, sta, ___iced_passed_deferral, __iced_deferrals, __iced_k, _i, _len, _ref;
            __iced_k = __iced_k_noop;
            ___iced_passed_deferral = iced.findDeferral(arguments);
            _ref = station.stations;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              sta = _ref[_i];
              getStationEquipment(sta);
            }
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "F:\\clc.datacenter\\app\\scripts\\datacenter\\src\\directives\\device-filter\\component.coffee"
              });
              _this.commonService.loadEquipmentsByType(station, type, __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    err = arguments[0];
                    return mod = arguments[1];
                  };
                })(),
                lineno: 185
              }), refresh);
              __iced_deferrals._fulfill();
            })(function() {
              mods = mods.concat(mod);
              return typeof callback === "function" ? callback(mods) : void 0;
            });
          };
          processEquipinfos = function(equips, callback) {
            var equip, equipCount, tmpLen, _i, _len, _ref, _ref1, _ref2, _ref3, _results;
            tmpLen = equips.length;
            equipCount = 0;
            _results = [];
            for (_i = 0, _len = equips.length; _i < _len; _i++) {
              equip = equips[_i];
              equip.loadProperties();
              equip.model.typeName = (_ref = _.find(scope.project.dictionary.equipmenttypes.items, function(type) {
                return type.key === equip.model.type;
              })) != null ? _ref.model.name : void 0;
              equip.model.templateName = (_ref1 = _.find(scope.project.equipmentTemplates.items, function(template) {
                return template.model.type === equip.model.type && template.model.template === equip.model.template;
              })) != null ? _ref1.model.name : void 0;
              equip.model.vendorName = (_ref2 = _.find(scope.project.dictionary.vendors.items, function(vendor) {
                return vendor.key === equip.model.vendor;
              })) != null ? _ref2.model.name : void 0;
              equip.model.stationName = (_ref3 = _.find(scope.project.stations.items, function(station) {
                return station.model.station === equip.model.station;
              })) != null ? _ref3.model.name : void 0;
              _results.push(equip.loadEquipmentTemplate(null, function(err, refTemplate) {
                equipCount++;
                if (equipCount === tmpLen) {
                  return typeof callback === "function" ? callback(equips) : void 0;
                }
              }));
            }
            return _results;
          };
          return getStationEquipment(scope.station, function(equips) {
            return processEquipinfos(equips, function(equipdatas) {
              scope.equipments = equipdatas;
              scope.$applyAsync();
              return _.map(scope.equipments, function(x) {
                return x.loadSignals(null, function(err, signals) {
                  var d, _i, _len, _ref, _ref1, _results;
                  _ref = ["alarms", "communication-status"];
                  _results = [];
                  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                    d = _ref[_i];
                    if ((_ref1 = scope.equipSubscription[x.key + "-" + d]) != null) {
                      _ref1.dispose();
                    }
                    _results.push(scope.equipSubscription[x.key + "-" + d] = _this.commonService.subscribeSignalValue(_.find(signals, function(m) {
                      return m.model.signal === d;
                    }), function(signal) {
                      if (signal.model.signal === "alarms") {
                        return signal.data.format = signal.data.value > 0 ? "告警" : "正常";
                      } else {
                        return signal.data.format = signal.data.value > -1 ? "在线" : "离线";
                      }
                    }));
                  }
                  return _results;
                });
              });
            });
          });
        };
      })(this);
      scope.selectEquipType = (function(_this) {
        return function(type) {
          scope.pageIndex = 1;
          scope.detail = false;
          scope.edit = false;
          scope.currentType = type;
          return selectType(scope.currentType.type, null, false);
        };
      })(this);
      scope.selectEquip = (function(_this) {
        return function(equipment) {
          scope.equipment = equipment;
          return setEquipmentData();
        };
      })(this);
      setEquipmentData = (function(_this) {
        return function() {
          return _.map(scope.equipment.properties.items, function(item) {
            var install, life, lt, statusArr, _i, _len;
            if (item.model.property === 'status') {
              scope.equipment.model.status = item.value;
              statusArr = item.model.format.split(',');
              for (_i = 0, _len = statusArr.length; _i < _len; _i++) {
                lt = statusArr[_i];
                if (lt.split(":")[0] === item.value || lt.split(":")[1] === item.value) {
                  scope.equipment.model.statusName = lt.split(":")[1];
                  item.model.value = lt.split(":")[1];
                }
              }
            }
            if (item.model.property === 'install-date') {
              life = _.find(scope.equipment.properties.items, function(item) {
                return item.model.property === 'life';
              });
              scope.equipment.model.remainDate = life.value - moment().diff(item.value, 'months');
            }
            if (item.model.property === 'guarantee-month') {
              if (item.value) {
                install = _.find(scope.equipment.properties.items, function(item) {
                  return item.model.property === 'install-date';
                });
                scope.equipment.model.repairDate = item.value - moment().diff(install.value, 'months') % item.value;
              } else {
                scope.equipment.model.repairDate = 0;
              }
            }
            if (_.isNaN(scope.equipment.model.remainDate)) {
              scope.equipment.model.remainDate = '-';
            }
            if (_.isNaN(scope.equipment.model.repairDate)) {
              return scope.equipment.model.repairDate = '-';
            }
          });
        };
      })(this);
      scope.switchView = (function(_this) {
        return function() {
          scope.view = !scope.view;
          scope.pageIndex = 1;
          if (scope.view) {
            scope.pageItems = 12;
            return scope.viewName = '表格';
          } else {
            scope.pageItems = 8;
            return scope.viewName = '视图';
          }
        };
      })(this);
      scope.selectPage = (function(_this) {
        return function(page) {
          return scope.pageIndex = page;
        };
      })(this);
      scope.backList = (function(_this) {
        return function() {
          scope.detail = false;
          scope.edit = false;
          return scope.add = false;
        };
      })(this);
      scope.saveEquipment = (function(_this) {
        return function() {
          return scope.equipment.save(function(err, model) {
            return loadStatisticByEquipmentTypes();
          });
        };
      })(this);
      scope.addEquipment = (function(_this) {
        return function() {
          scope.add = true;
          scope.edit = true;
          return scope.equipment = scope.station.createEquipment(null);
        };
      })(this);
      scope.equipTypeChange = (function(_this) {
        return function() {
          return selectType(scope.equipment.model.type, null, false);
        };
      })(this);
      scope.settingEquipId = (function(_this) {
        return function() {
          var equipmentTemplate, name, template;
          template = scope.equipment.model.template;
          equipmentTemplate = _.find(scope.project.equipmentTemplates.items, function(item) {
            return item.model.template === template;
          });
          if (equipmentTemplate != null) {
            equipmentTemplate.loadProperties(null, function(err, result) {
              _.each(result, function(item) {
                if (item.model.dataType === 'date' || item.model.dataType === 'time' || item.model.dataType === 'datetime') {
                  item.model.value = moment(item.model.value).toDate();
                }
                return item.value = item.model.value;
              });
              return scope.equipment._properties = result;
            });
          }
          scope.equipment._sampleUnits = equipmentTemplate != null ? equipmentTemplate.model.sampleUnits : void 0;
          name = equipmentTemplate != null ? equipmentTemplate.model.name.replace(/模板/, '') : void 0;
          return loadEquipsByAdd(function(num) {
            var equipID, equipName;
            equipID = scope.equipment.model.type + '-' + scope.equipment.model.template + '-' + num;
            equipName = name + '-' + num;
            scope.equipment.model.equipment = equipID;
            scope.equipment.model.name = equipName;
            return settingEquipSampleUnits();
          });
        };
      })(this);
      loadEquipsByAdd = (function(_this) {
        return function(callback) {
          var filter;
          filter = {
            user: scope.equipment.model.user,
            project: scope.equipment.model.project,
            station: scope.equipment.model.station,
            type: scope.equipment.model.type,
            template: scope.equipment.model.template
          };
          return scope.station.loadEquipments(filter, null, function(err, equips) {
            if (err) {
              return;
            }
            return typeof callback === "function" ? callback(getEquipNumber(equips)) : void 0;
          });
        };
      })(this);
      getEquipNumber = (function(_this) {
        return function(equips) {
          var i, result;
          i = 0;
          _.map(equips, function(equip) {
            var arr, num, str;
            arr = equip.model.name.split('-');
            str = arr[arr.length - 1];
            num = str.replace(/[^0-9]/ig, "");
            if ((num - i) > 0) {
              return i = num;
            }
          });
          i++;
          result = i;
          return result;
        };
      })(this);
      settingEquipSampleUnits = (function(_this) {
        return function() {
          var mu, su;
          mu = 'mu-' + scope.equipment.model.user + '.' + scope.equipment.model.project + '.' + scope.equipment.model.station;
          su = 'su-' + scope.equipment.model.equipment;
          scope.equipment.model.sampleUnits = [];
          _.each(scope.equipment._sampleUnits, function(sampleUnits) {
            var sample;
            sampleUnits.value = mu + '/' + su;
            sample = {};
            sample.id = sampleUnits.id;
            sample.value = mu + '/' + su;
            scope.equipment.model.sampleUnits.push(sample);
            return scope.equipment.sampleUnits[sampleUnits.id] = sampleUnits;
          });
        };
      })(this);
      scope.saveEquipmentGroups = (function(_this) {
        return function() {
          scope.add = false;
          scope.edit = false;
          scope.detail = false;
          scope.currentType = _.find(scope.equipTypeLists, function(type) {
            return type.type === scope.equipment.model.type;
          });
          return scope.saveEquipment();
        };
      })(this);
      scope.deleteEquip = (function(_this) {
        return function(equip) {
          var message, title;
          scope.equipment = equip;
          title = "删除设备确认: " + scope.project.model.name + "/" + scope.station.model.name + "/" + scope.equipment.model.name;
          message = "请确认是否删除设备: " + scope.project.model.name + "/" + scope.station.model.name + "/" + scope.equipment.model.name + "？删除后设备和数据将从系统中移除不可恢复！";
          return scope.prompt(title, message, function(ok) {
            if (!ok) {
              return;
            }
            return scope.equipment.remove(function(err, model) {
              return loadStatisticByEquipmentTypes();
            });
          });
        };
      })(this);
      scope.editData = (function(_this) {
        return function(equipment) {
          scope.edit = true;
          if (equipment) {
            scope.equipment = equipment;
          }
          return setEquipmentData();
        };
      })(this);
      scope.saveValue = (function(_this) {
        return function(value) {
          return scope.oldValue = value;
        };
      })(this);
      scope.checkValue = (function(_this) {
        return function(value) {
          if (scope.oldValue === value) {

          } else {
            return scope.saveEquipment();
          }
        };
      })(this);
      scope.$watch('equipment.model.image', (function(_this) {
        return function() {
          if (scope.edit && !scope.add) {
            return scope.saveEquipment();
          }
        };
      })(this));
      scope.stationCheck = (function(_this) {
        return function() {
          if (scope.equipment.model.station) {
            return scope.saveEquipment();
          }
        };
      })(this);
      scope.lookData = (function(_this) {
        return function(equipment) {
          var _ref;
          scope.edit = false;
          scope.detail = true;
          if (equipment) {
            scope.equipment = equipment;
          }
          if ((_ref = _this.publishEquipInstance) != null) {
            _ref.dispose();
          }
          _this.publishEquipInstance = _this.commonService.publishEventBus('equipmentId', {
            equipmentId: {
              station: equipment.model.station,
              equipment: equipment.model.equipment
            }
          });
          return setEquipmentData();
        };
      })(this);
      scope.filterTypes = (function(_this) {
        return function() {
          return function(type) {
            return type.count;
          };
        };
      })(this);
      scope.filterEquipment = (function(_this) {
        return function() {
          return function(equipment) {
            var text, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
            if (equipment.model.template === 'card-sender' || equipment.model.template === 'card_template' || equipment.model.template === 'people_template') {
              return false;
            }
            text = (_ref = scope.searchLists) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = equipment.model.equipment) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = equipment.model.name) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref3 = equipment.model.tag) != null ? _ref3.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref4 = equipment.model.typeName) != null ? _ref4.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref5 = equipment.model.stationName) != null ? _ref5.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref6 = equipment.model.vendorName) != null ? _ref6.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            return false;
          };
        };
      })(this);
      scope.filterEquipmentItem = (function(_this) {
        return function() {
          var items, pageCount, result, _i, _results;
          if (!scope.equipments) {
            return;
          }
          items = [];
          items = _.filter(scope.equipments, function(equipment) {
            var text, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
            text = (_ref = scope.searchLists) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = equipment.model.equipment) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = equipment.model.name) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref3 = equipment.model.tag) != null ? _ref3.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref4 = equipment.model.typeName) != null ? _ref4.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref5 = equipment.model.stationName) != null ? _ref5.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref6 = equipment.model.vendorName) != null ? _ref6.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            return false;
          });
          pageCount = Math.ceil(items.length / scope.pageItems);
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
      scope.limitToEquipment = (function(_this) {
        return function() {
          var aa, result;
          if (scope.filterEquipmentItem() && scope.filterEquipmentItem().pageCount === scope.pageIndex) {
            aa = scope.filterEquipmentItem().items % scope.pageItems;
            result = -(aa === 0 ? scope.pageItems : aa);
          } else {
            result = -scope.pageItems;
          }
          return result;
        };
      })(this);
      scope.filterProperties = function() {
        return (function(_this) {
          return function(item) {
            var text, _ref, _ref1, _ref2;
            if (item.model.dataType === "json" || item.model.dataType === "script" || item.model.dataType === "html" || item.model.dataType === "image" || item.model.visible === false) {
              return false;
            }
            text = (_ref = scope.searchDetail) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = item.model.name) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = item.model.property) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            return false;
          };
        })(this);
      };
      scope.filterEditItems1 = (function(_this) {
        return function() {
          return function(item) {
            if (item.model.dataType === "json" || item.model.dataType === "script" || item.model.dataType === "html" || item.model.visible === false) {
              return false;
            }
            if (item.model.property === 'production-time' || item.model.name === '生产日期') {
              return true;
            }
            if (item.model.property === 'buy-date' || item.model.name === '购买日期') {
              return true;
            }
            if (item.model.property === 'install-date' || item.model.name === '安装日期') {
              return true;
            }
            return false;
          };
        };
      })(this);
      scope.filterEditItems2 = (function(_this) {
        return function() {
          return function(item) {
            var text, _ref, _ref1, _ref2;
            if (item.model.dataType === "json" || item.model.dataType === "script" || item.model.dataType === "html" || item.model.visible === false) {
              return false;
            }
            if (item.model.property === 'production-time' || item.model.name === '生产日期') {
              return false;
            }
            if (item.model.property === 'buy-date' || item.model.name === '购买日期') {
              return false;
            }
            if (item.model.property === 'install-date' || item.model.name === '安装日期') {
              return false;
            }
            text = (_ref = scope.searchEdit) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = item.model.name) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = item.model.property) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            return false;
          };
        };
      })(this);
      scope.filterEquipmentTemplate = (function(_this) {
        return function() {
          return function(template) {
            var model;
            if (!scope.equipment) {
              return false;
            }
            model = scope.equipment.model;
            return template.model.type === model.type && template.model.vendor === model.vendor;
          };
        };
      })(this);
      return scope.subscribeTreeClick = this.commonService.subscribeEventBus("selectStation", (function(_this) {
        return function(msg) {
          return selectStation(msg.message.id);
        };
      })(this));
    };

    DeviceFilterDirective.prototype.getAllStations = function(refScope, refStation) {
      var childStations, childStationsItem, stationResult, stationResultItem, _i, _j, _len, _len1;
      stationResult = _.filter(refScope.project.stations.items, function(stationItem) {
        return stationItem.model.station === refStation;
      });
      for (_i = 0, _len = stationResult.length; _i < _len; _i++) {
        stationResultItem = stationResult[_i];
        childStations = _.filter(refScope.project.stations.items, function(stationItem) {
          return stationItem.model.parent === refStation;
        });
        this.allInventoryStations.push(stationResultItem);
        if (!childStations) {
          return;
        }
        for (_j = 0, _len1 = childStations.length; _j < _len1; _j++) {
          childStationsItem = childStations[_j];
          this.getAllStations(refScope, childStationsItem.model.station);
        }
      }
    };

    DeviceFilterDirective.prototype.resize = function(scope) {};

    DeviceFilterDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.subscribeTreeClick) != null ? _ref.dispose() : void 0;
    };

    return DeviceFilterDirective;

  })(base.BaseDirective);
  return exports = {
    DeviceFilterDirective: DeviceFilterDirective
  };
});