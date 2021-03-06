// Generated by IcedCoffeeScript 108.0.12

/*
* File: asset-detail-directive
* User: David
* Date: 2019/10/24
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var AssetDetailDirective, exports;
  AssetDetailDirective = (function(_super) {
    __extends(AssetDetailDirective, _super);

    function AssetDetailDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.getAllStations = __bind(this.getAllStations, this);
      this.show = __bind(this.show, this);
      this.id = "asset-detail";
      AssetDetailDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    AssetDetailDirective.prototype.setScope = function() {};

    AssetDetailDirective.prototype.setCSS = function() {
      return css;
    };

    AssetDetailDirective.prototype.setTemplate = function() {
      return view;
    };

    AssetDetailDirective.prototype.show = function(scope, element, attrs) {
      var addPortStatus, getDeviceWorkOrder, getStationEquipTypes, getWorkFlowRecord, init, loadAllUsers, loadStatisticByEquipmentTypes, processTypes, selectType, setEquipmentData;
      scope.slecetLinkDevice = (function(_this) {
        return function(deviceId) {
          scope.linkDeviceId = deviceId;
          return scope.deviceStation.loadEquipment(scope.linkDeviceId, null, function(err, linkEquip) {
            scope.linkDeviceInfo = linkEquip;
            return scope.linkDeviceInfo.loadPorts(null, (function(_this) {
              return function(err, ports) {
                return scope.selectRefresh++;
              };
            })(this));
          });
        };
      })(this);
      scope.slecetLinkPort = (function(_this) {
        return function(portId) {
          scope.linkDevicePortId = portId;
          scope.linkDeviceName = scope.linkDeviceInfo.model.name;
          return _.each(scope.linkDeviceInfo.ports.items, function(item) {
            if (scope.linkDevicePortId === item.model.port) {
              scope.linkDevicePortName = item.model.name;
              return scope.linkDevicePortType = item.model.portType;
            }
          });
        };
      })(this);
      scope.editData = (function(_this) {
        return function(equipment) {
          scope.detailShow = false;
          scope.editShow = true;
          if (equipment) {
            scope.equipment = equipment;
          }
          return setEquipmentData();
        };
      })(this);
      scope.popoutOperate = (function(_this) {
        return function(type) {
          scope.popoutShow = true;
          scope.popoutLeftWidth = "100%";
          scope.popoutTypeShow = type;
          if (type === "port") {
            scope.popoutTitle = "端口列表信息";
            return scope.equipment.loadPorts(null, function(err, ports) {
              return scope.selectRefresh++;
            });
          } else if (type === "repair") {
            return scope.popoutTitle = "设备维修记录";
          } else if (type === "ops") {
            return scope.popoutTitle = "设备运维信息";
          }
        };
      })(this);
      scope.closePopout = (function(_this) {
        return function() {
          scope.popoutShow = false;
          scope.operateShow = false;
          return scope.popoutLeftWidth = "100%";
        };
      })(this);
      scope.showOperate = (function(_this) {
        return function(port) {
          scope.linkDeviceInfo = {};
          scope.linkDevicePortId = "";
          scope.linkDevicePortType = "";
          scope.selectRefresh++;
          scope.operateShow = true;
          scope.popoutLeftWidth = "70%";
          return scope.devicePortInfo = port;
        };
      })(this);
      scope.cancelOperate = (function(_this) {
        return function() {
          scope.operateShow = false;
          return scope.popoutLeftWidth = "100%";
        };
      })(this);
      scope.confirmOperate = (function(_this) {
        return function() {
          var LinkPortName, changeOrAdd, equipmentId, equipmentName, linkEquipmentId, linkEquipmentName, linkPortId, linkPortType, portId, portName, portType, stationId;
          if (scope.linkDeviceId && scope.linkDevicePortId) {
            stationId = scope.deviceStation.model.station;
            portId = scope.devicePortInfo.model.port;
            portType = scope.devicePortInfo.model.portType;
            linkPortId = scope.linkDevicePortId;
            linkPortType = scope.linkDevicePortType;
            portName = scope.devicePortInfo.model.name;
            LinkPortName = scope.linkDevicePortName;
            equipmentName = scope.equipment.model.name;
            linkEquipmentName = scope.linkDeviceName;
            equipmentId = scope.equipment.model.equipment;
            linkEquipmentId = scope.linkDeviceId;
            changeOrAdd = _.some(scope.equipment.model.ports, function(item) {
              return item.id === portId;
            });
            if (changeOrAdd) {
              _.each(scope.equipment.model.ports, function(item) {
                if (item.id === portId) {
                  return item.port = {
                    station: stationId,
                    equipment: linkEquipmentId,
                    port: linkPortId,
                    portType: linkPortType,
                    portName: LinkPortName,
                    equipmentName: linkEquipmentName
                  };
                }
              });
              _.each(scope.linkDeviceInfo.model.ports, function(item) {
                if (item.id === linkPortId) {
                  return item.port = {
                    station: stationId,
                    equipment: equipmentId,
                    port: portId,
                    portType: portType,
                    portName: portName,
                    equipmentName: equipmentName
                  };
                }
              });
            } else {
              scope.equipment.model.ports.push({
                id: portId,
                portType: portType,
                port: {
                  station: stationId,
                  equipment: linkEquipmentId,
                  port: linkPortId,
                  portType: linkPortType,
                  portName: LinkPortName,
                  equipmentName: linkEquipmentName
                }
              });
              scope.linkDeviceInfo.model.ports.push({
                id: linkPortId,
                portType: linkPortType,
                port: {
                  station: stationId,
                  equipment: equipmentId,
                  port: portId,
                  portType: portType,
                  portName: portName,
                  equipmentName: equipmentName
                }
              });
            }
            scope.equipment.save(function(err, res) {
              return addPortStatus();
            });
            return scope.linkDeviceInfo.save();
          }
        };
      })(this);
      scope.goAnchor = (function(_this) {
        return function(type) {
          scope.anchor = type;
          return element.find(".asset-detail-list [anchor=" + type + "]").focus();
        };
      })(this);
      scope.saveValue = (function(_this) {
        return function(value) {
          return scope.oldValue = value;
        };
      })(this);
      scope.checkValue = (function(_this) {
        return function(item) {
          if (scope.oldValue === item.value || scope.oldValue === item) {

          } else {
            return scope.saveEquipment(item);
          }
        };
      })(this);
      scope.stationCheck = (function(_this) {
        return function() {
          if (scope.equipment.model.station) {
            return scope.saveEquipment();
          }
        };
      })(this);
      scope.saveEquipment = (function(_this) {
        return function(item) {
          var property;
          if (item) {
            property = _.find(scope.equipment.model.properties, function(pro) {
              var _ref;
              return pro.id === (item != null ? (_ref = item.model) != null ? _ref.property : void 0 : void 0);
            });
            if (property && (item.model.dataType === "float" || item.model.dataType === "int")) {
              property.value = Number(item.value);
            } else if (property) {
              property.value = item.value;
            }
          }
          return scope.equipment.save(function(err, model) {
            return loadStatisticByEquipmentTypes();
          });
        };
      })(this);
      scope.lookData = (function(_this) {
        return function(equipment) {
          scope.detailShow = true;
          scope.editShow = false;
          if (equipment) {
            scope.equipment = equipment;
          }
          return setEquipmentData();
        };
      })(this);
      scope.filterEditItems = (function(_this) {
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
      scope.publishBack = (function(_this) {
        return function() {
          return _this.publishEventBus('backList', "backList");
        };
      })(this);
      addPortStatus = (function(_this) {
        return function() {
          return _.each(scope.equipment.ports.items, function(item) {
            item.model.staus = false;
            item.model.linkPort = {};
            return _.each(scope.equipment.model.ports, function(port) {
              if (port.id === item.model.port) {
                item.model.staus = true;
                return item.model.linkPort = {
                  equipment: port.port.equipment,
                  equipmentName: port.port.equipmentName,
                  port: port.port.port,
                  portType: port.port.portType,
                  portName: port.port.portName
                };
              }
            });
          });
        };
      })(this);
      loadAllUsers = (function(_this) {
        return function() {
          var userService;
          userService = _this.commonService.modelEngine.modelManager.getService('users');
          return userService.query({}, null, function(err, data) {
            if (!err) {
              return scope.userMsg = data;
            }
          });
        };
      })(this);
      getStationEquipTypes = (function(_this) {
        return function(callback) {
          var allEquipModels, allassetStationsCount, allassetStationsLen, stationObj, _i, _len, _ref, _results;
          _this.allassetStations = [];
          _this.getAllStations(scope, scope.station.model.station);
          allassetStationsLen = _this.allassetStations.length;
          allassetStationsCount = 0;
          allEquipModels = [];
          _ref = _this.allassetStations;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            stationObj = _ref[_i];
            _results.push(stationObj.loadStatisticByEquipmentTypes(function(err, mod) {
              allEquipModels.push(mod);
              allassetStationsCount++;
              if (allassetStationsCount === allassetStationsLen) {
                return typeof callback === "function" ? callback(allEquipModels) : void 0;
              }
            }, true));
          }
          return _results;
        };
      })(this);
      selectType = (function(_this) {
        return function(type, callback, refresh) {
          var getStationEquipment;
          if (!type) {
            return;
          }
          scope.equipments = [];
          getStationEquipment = function(station, callback) {
            var sta, _i, _len, _ref;
            _ref = station.stations;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              sta = _ref[_i];
              getStationEquipment(sta, callback);
            }
            return _this.commonService.loadEquipmentsByType(station, type, function(err, mods) {
              return typeof callback === "function" ? callback(mods) : void 0;
            }, refresh);
          };
          return getStationEquipment(scope.station, function(equips) {
            var diff, equip, _i, _len, _ref, _ref1, _ref2, _ref3, _results;
            diff = _.difference(equips, scope.equipments);
            scope.equipments = scope.equipments.concat(diff);
            scope.$applyAsync();
            _results = [];
            for (_i = 0, _len = equips.length; _i < _len; _i++) {
              equip = equips[_i];
              equip.loadProperties();
              equip.loadPorts();
              equip.model.typeName = (_ref = _.find(scope.project.dictionary.equipmenttypes.items, function(type) {
                return type.key === equip.model.type;
              })) != null ? _ref.model.name : void 0;
              equip.model.templateName = (_ref1 = _.find(scope.project.equipmentTemplates.items, function(template) {
                return template.model.type === equip.model.type && template.model.template === equip.model.template;
              })) != null ? _ref1.model.name : void 0;
              equip.model.vendorName = (_ref2 = _.find(scope.project.dictionary.vendors.items, function(vendor) {
                return vendor.key === equip.model.vendor;
              })) != null ? _ref2.model.name : void 0;
              _results.push(equip.model.stationName = (_ref3 = _.find(scope.project.stations.items, function(station) {
                return station.model.station === equip.model.station;
              })) != null ? _ref3.model.name : void 0);
            }
            return _results;
          });
        };
      })(this);
      processTypes = (function(_this) {
        return function(data, refresh) {
          var key, types, typesArr, value, _ref;
          if (!(data != null ? data.statistic : void 0)) {
            return;
          }
          types = [];
          _ref = data.statistic;
          for (key in _ref) {
            value = _ref[key];
            if (value.type[0] !== '_') {
              types.push(value);
            }
          }
          _.map(types, function(type) {
            var currentType;
            currentType = _.find(scope.project.dictionary.equipmenttypes.items, function(item) {
              return item.model.type === type.type;
            });
            if (currentType.model.image) {
              return type.image = currentType.model.image;
            }
          });
          scope.equipTypes = types;
          typesArr = _.filter(scope.equipTypes, function(type) {
            return type.count !== 0 && type.type !== 'KnowledgeDepot';
          });
          if (!scope.currentType) {
            scope.currentType = typesArr[0];
          }
          return selectType(scope.currentType.type, null, refresh);
        };
      })(this);
      loadStatisticByEquipmentTypes = (function(_this) {
        return function() {
          return getStationEquipTypes(function(equipTypeDatas) {
            var equipTypeDataItem, it, item, j, stationType, _i, _len, _ref;
            stationType = {
              statistic: {}
            };
            for (_i = 0, _len = equipTypeDatas.length; _i < _len; _i++) {
              equipTypeDataItem = equipTypeDatas[_i];
              _ref = equipTypeDataItem.statistic;
              for (j in _ref) {
                item = _ref[j];
                it = _.findWhere(stationType.statistic, {
                  type: item.type
                });
                if (it) {
                  it.count = it.count + item.count;
                } else {
                  stationType.statistic[item.type] = item;
                }
              }
            }
            return processTypes(stationType, true);
          });
        };
      })(this);
      setEquipmentData = (function(_this) {
        return function() {
          scope.sizeInfo = [];
          scope.maintenanceInfo = [];
          scope.useInfo = [];
          scope.otherInfo = [];
          return _.each(scope.equipment.properties.items, function(item) {
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
              scope.equipment.model.remainDate = (life != null ? life.value : void 0) - moment().diff(item.value, 'months');
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
              scope.equipment.model.repairDate = '-';
            }
            if (item.model.property === "repair-records") {
              if (!item.value) {
                return;
              }
              scope.repairRecords = JSON.parse(item.value);
            }
            if (item.model.dataType !== "json") {
              if (item.model.group === "位置信息") {
                return scope.sizeInfo.push(item);
              } else if (item.model.group === "维保信息") {
                return scope.maintenanceInfo.push(item);
              } else if (item.model.group === "使用信息") {
                return scope.useInfo.push(item);
              } else {
                return scope.otherInfo.push(item);
              }
            }
          });
        };
      })(this);
      getWorkFlowRecord = (function(_this) {
        return function() {
          return _this.commonService.loadProjectModelByService('tasks', {}, null, function(err, taskModels) {
            var filter, processModelDB;
            scope.workFlowRecord = taskModels;
            processModelDB = _this.commonService.modelEngine.modelManager.getService('processes');
            filter = {
              project: scope.project.model.project
            };
            return processModelDB.query(filter, null, function(err, data) {
              if (!err) {
                return scope.processModelDB = data;
              }
            });
          });
        };
      })(this);
      getDeviceWorkOrder = (function(_this) {
        return function() {
          scope.deviceWorkOrder = _.filter(scope.workFlowRecord, function(task) {
            return task.nodes[0].parameters.equipment === scope.equipment.model.equipment && task.nodes[0].parameters.station === scope.equipment.model.station;
          });
          return _.each(scope.deviceWorkOrder, function(item) {
            _.each(scope.processModelDB, function(processModel) {
              if (item.process === processModel.process) {
                item.processName = processModel.name;
                if (processModel.priority === 1) {
                  item.priority = "高";
                  item.priorityColor = "#DB4E32";
                }
                if (processModel.priority === 2) {
                  item.priority = "中";
                  item.priorityColor = "#E9B943";
                }
                if (processModel.priority === 3) {
                  item.priority = "低";
                  item.priorityColor = "#BECA32";
                }
                if (processModel.priority === 4) {
                  item.priority = "其他";
                  item.priorityColor = "#FFFF00";
                }
              }
            });
            if (item.nodes[0].state === "approval") {
              item.status = "批准";
              return item.statusColor = "#32CA59";
            } else if (item.nodes[0].state === "forward") {
              item.status = "转发";
              return item.statusColor = "#4CA7F8";
            } else if (item.nodes[0].state === "save") {
              item.status = "保存";
              return item.statusColor = "#BECA32";
            } else if (item.nodes[0].state === "reject") {
              item.status = "拒绝";
              return item.statusColor = "#DB4E32";
            } else {
              item.status = "未处理";
              return item.statusColor = "#E9B943";
            }
          });
        };
      })(this);
      init = (function(_this) {
        return function() {
          var _ref;
          scope.status = false;
          scope.selectRefresh = 0;
          scope.linkDeviceId = "";
          scope.linkDeviceInfo = {};
          scope.linkPortInfo = {};
          scope.linkDevicePortId = "";
          scope.linkDevicePortType = "";
          scope.devicePortInfo = {};
          scope.deviceStation = {};
          scope.stationHasDevice = [];
          scope.repairRecords = {};
          scope.popoutShow = false;
          scope.userMsg = [];
          scope.sizeInfo = [];
          scope.maintenanceInfo = [];
          scope.useInfo = [];
          scope.otherInfo = [];
          scope.detailShow = true;
          scope.editShow = false;
          scope.setting = setting;
          scope.anchor = "基本信息";
          scope.popoutTitle = "";
          scope.equipment = {};
          scope.secondChangeImg = false;
          scope.processModelDB = [];
          scope.workFlowRecord = [];
          scope.tasksDB = [];
          scope.deviceWorkOrder = [];
          loadAllUsers();
          getWorkFlowRecord();
          if ((_ref = scope.subscribeEquipment) != null) {
            _ref.dispose();
          }
          scope.subscribeEquipment = _this.commonService.subscribeEventBus('equipmentid', function(msg) {
            return _this.commonService.loadStation(msg.message.stationid, function(err, station) {
              return station.loadEquipment(msg.message.equipmentid, null, function(err, equipment) {
                scope.deviceStation = station;
                if (msg.message.type === "editData") {
                  scope.detailShow = false;
                  scope.editShow = true;
                  scope.secondChangeImg = false;
                } else {
                  scope.detailShow = true;
                  scope.editShow = false;
                }
                scope.equipment = equipment;
                scope.equipment.loadPorts(null, function(err, ports) {
                  return addPortStatus();
                });
                scope.equipment.loadProperties(null, function(err, props) {
                  setEquipmentData();
                  return getDeviceWorkOrder();
                });
                scope.stationHasDevice = [];
                return station.loadEquipments({}, null, function(err, equipments) {
                  scope.stationHasDevice = equipments;
                  return scope.stationHasDevice = _.filter(scope.stationHasDevice, function(item) {
                    return item.model.equipment.indexOf("_") === -1;
                  });
                });
              });
            });
          });
          if (!scope.firstload) {
            return;
          }
          return scope.$watch('equipment.model.image', function() {
            if (scope.editShow && scope.secondChangeImg) {
              scope.saveEquipment();
            }
            return scope.secondChangeImg = true;
          });
        };
      })(this);
      return init();
    };

    AssetDetailDirective.prototype.getAllStations = function(refScope, refStation) {
      var childStations, childStationsItem, stationResult, stationResultItem, _i, _j, _len, _len1;
      stationResult = _.filter(refScope.project.stations.items, function(stationItem) {
        return stationItem.model.station === refStation;
      });
      for (_i = 0, _len = stationResult.length; _i < _len; _i++) {
        stationResultItem = stationResult[_i];
        childStations = _.filter(refScope.project.stations.items, function(stationItem) {
          return stationItem.model.parent === refStation;
        });
        this.allassetStations.push(stationResultItem);
        if (!childStations) {
          return;
        }
        for (_j = 0, _len1 = childStations.length; _j < _len1; _j++) {
          childStationsItem = childStations[_j];
          this.getAllStations(refScope, childStationsItem.model.station);
        }
      }
    };

    AssetDetailDirective.prototype.resize = function(scope) {};

    AssetDetailDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.subscribeEquipment) != null ? _ref.dispose() : void 0;
    };

    return AssetDetailDirective;

  })(base.BaseDirective);
  return exports = {
    AssetDetailDirective: AssetDetailDirective
  };
});
