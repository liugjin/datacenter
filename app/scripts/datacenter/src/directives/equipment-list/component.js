// Generated by IcedCoffeeScript 108.0.12

/*
* File: equipment-list-directive
* User: David
* Date: 2020/05/21
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "angularGrid"], function(base, css, view, _, moment, agGrid) {
  var EquipmentListDirective, exports;
  EquipmentListDirective = (function(_super) {
    __extends(EquipmentListDirective, _super);

    function EquipmentListDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.setData = __bind(this.setData, this);
      this.exportReport = __bind(this.exportReport, this);
      this.show = __bind(this.show, this);
      this.id = "equipment-list";
      EquipmentListDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    EquipmentListDirective.prototype.setScope = function() {};

    EquipmentListDirective.prototype.setCSS = function() {
      return css;
    };

    EquipmentListDirective.prototype.setTemplate = function() {
      return view;
    };

    EquipmentListDirective.prototype.show = function(scope, element, attrs) {
      scope.deviceData = [];
      scope.header = [
        {
          headerName: "设备ID",
          field: 'equipment'
        }, {
          headerName: "设备名称",
          field: 'name'
        }, {
          headerName: "设备类型",
          field: 'typeName'
        }, {
          headerName: "设备地址",
          field: 'address'
        }, {
          headerName: "端口号",
          field: 'newport'
        }, {
          headerName: "通讯参数",
          field: 'parameters'
        }, {
          headerName: "设备型号",
          field: 'templateName'
        }, {
          headerName: "设备库版本",
          field: 'libraryVersion'
        }, {
          headerName: "设备厂商",
          field: 'vendorName'
        }, {
          headerName: "资产归属",
          field: 'user'
        }, {
          headerName: "过保日期",
          field: 'expiryDate'
        }, {
          headerName: "上线日期",
          field: 'createtime'
        }
      ];
      scope.equipments = [];
      scope.project.loadEquipmentTemplates(null, null, (function(_this) {
        return function(err, tps) {
          var station, _i, _len, _ref, _results;
          _ref = scope.project.stations.nitems;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            station = _ref[_i];
            _results.push(station.loadEquipments(null, null, function(err, equips) {
              var desc, equip, fields, _j, _len1, _ref1, _ref2, _ref3, _ref4;
              equips = _.filter(equips, function(equip) {
                return equip.model.type.substr(0, 1) !== "_" && equip.model.template.substr(0, 1) !== "_" && equip.model.equipment.substr(0, 1) !== "_";
              });
              for (_j = 0, _len1 = equips.length; _j < _len1; _j++) {
                equip = equips[_j];
                equip.model.typeName = (_ref1 = _.find(scope.project.dictionary.equipmenttypes.items, function(type) {
                  return type.key === equip.model.type;
                })) != null ? _ref1.model.name : void 0;
                equip.model.templateName = (_ref2 = _.find(scope.project.equipmentTemplates.items, function(template) {
                  return template.model.type === equip.model.type && template.model.template === equip.model.template;
                })) != null ? _ref2.model.name : void 0;
                equip.model.vendorName = (_ref3 = _.find(scope.project.dictionary.vendors.items, function(vendor) {
                  return vendor.key === equip.model.vendor;
                })) != null ? _ref3.model.name : void 0;
                equip.model.stationName = (_ref4 = _.find(scope.project.stations.items, function(station) {
                  return station.model.station === equip.model.station;
                })) != null ? _ref4.model.name : void 0;
                desc = equip.model.desc;
                fields = ["port", "address", "parameters", "addr", "expiryDate", "libraryVersion"];
                if (desc && desc.substr(0, 1) === "{" && desc.substr(desc.length - 1, 1) === "}") {
                  desc = JSON.parse(desc);
                  _.each(fields, function(field) {
                    equip.model[field] = desc[field];
                    if (desc.port && desc.port.split("/")[2]) {
                      return equip.model.newport = desc.port.split("/")[2];
                    } else {
                      return equip.model.newport = desc.port;
                    }
                  });
                }
              }
              if (!err) {
                scope.equipments = scope.equipments.concat(equips);
              }
              return _this.setData(scope);
            }, true));
          }
          return _results;
        };
      })(this), true);
      return this.exportReport(scope, element);
    };

    EquipmentListDirective.prototype.exportReport = function(scope, element) {
      scope.gridOptions = {
        columnDefs: scope.header,
        rowData: null,
        enableFilter: true,
        enableSorting: true,
        enableColResize: true,
        overlayNoRowsTemplate: " ",
        headerHeight: 41,
        rowHeight: 61
      };
      console.log("1234", element.find("#grid")[0]);
      new agGrid.Grid(element.find("#grid")[0], scope.gridOptions);
      return scope.exportReport = (function(_this) {
        return function(name) {
          var nowDate, reportName;
          nowDate = moment(new Date()).format("YYYY-MM-DD");
          if (!scope.gridOptions) {
            return;
          }
          reportName = "" + name + "(" + nowDate + ").csv";
          return scope.gridOptions.api.exportDataAsCsv({
            fileName: reportName,
            allColumns: true,
            skipGroups: true
          });
        };
      })(this);
    };

    EquipmentListDirective.prototype.setData = function(scope) {
      scope.deviceData.splice(0, scope.deviceData.length);
      if (!scope.gridOptions) {
        return;
      }
      _.each(scope.equipments, (function(_this) {
        return function(item) {
          var value;
          value = {
            equipment: null,
            name: null,
            typeName: null,
            address: null,
            newport: null,
            parameters: null,
            templateName: null,
            libraryVersion: null,
            vendorName: null,
            user: null,
            expiryDate: null,
            createtime: null
          };
          value.equipment = item.model.equipment;
          value.name = item.model.name;
          value.typeName = item.model.typeName;
          value.address = item.model.address;
          value.newport = item.model.newport;
          value.parameters = item.model.parameters;
          value.templateName = item.model.templateName;
          value.libraryVersion = item.model.libraryVersion;
          value.vendorName = item.model.vendorName;
          value.user = item.model.user;
          value.expiryDate = item.model.expiryDate;
          value.createtime = item.model.createtime;
          return scope.deviceData.push(value);
        };
      })(this));
      return scope.gridOptions.api.setRowData(scope.deviceData);
    };

    EquipmentListDirective.prototype.resize = function(scope) {};

    EquipmentListDirective.prototype.dispose = function(scope) {};

    return EquipmentListDirective;

  })(base.BaseDirective);
  return exports = {
    EquipmentListDirective: EquipmentListDirective
  };
});