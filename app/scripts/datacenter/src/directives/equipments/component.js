// Generated by IcedCoffeeScript 108.0.12

/*
* File: equipments-directive
* User: David
* Date: 2020/03/26
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var EquipmentsDirective, exports;
  EquipmentsDirective = (function(_super) {
    __extends(EquipmentsDirective, _super);

    function EquipmentsDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.getNextName = __bind(this.getNextName, this);
      this.loadProperties = __bind(this.loadProperties, this);
      this.initEquips = __bind(this.initEquips, this);
      this.checkExistSetting = __bind(this.checkExistSetting, this);
      this.getEquipmentType = __bind(this.getEquipmentType, this);
      this.httpRequest = __bind(this.httpRequest, this);
      this.deleteEquipmenttypes = __bind(this.deleteEquipmenttypes, this);
      this.setMoreData = __bind(this.setMoreData, this);
      this.deleteMoreData = __bind(this.deleteMoreData, this);
      this.show = __bind(this.show, this);
      this.id = "equipments";
      EquipmentsDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    EquipmentsDirective.prototype.setScope = function() {};

    EquipmentsDirective.prototype.setCSS = function() {
      return css;
    };

    EquipmentsDirective.prototype.setTemplate = function() {
      return view;
    };

    EquipmentsDirective.prototype.show = function(scope, element, attrs) {
      scope.pageIndex = 1;
      scope.pageItems = 12;
      scope.elementsArr = [];
      scope.ip = this.$window.origin;
      scope.ports = [
        {
          value: "/ual/com1",
          name: "COM1"
        }, {
          value: "/ual/com2",
          name: "COM2"
        }, {
          value: "/ual/com3",
          name: "COM3"
        }, {
          value: "/ual/com4",
          name: "COM4"
        }, {
          value: "di1",
          name: "DI1"
        }, {
          value: "di2",
          name: "DI2"
        }, {
          value: "di3",
          name: "DI3"
        }, {
          value: "di4",
          name: "DI4"
        }, {
          value: "do1",
          name: "DO1"
        }, {
          value: "do2",
          name: "DO2"
        }, {
          value: "do3",
          name: "DO3"
        }, {
          value: "do4",
          name: "DO4"
        }, {
          value: "ip",
          name: "网口"
        }
      ];
      this.commonService.rpcGet("muSetting", null, (function(_this) {
        return function(err, data) {
          var _ref, _ref1;
          scope.mu = data != null ? (_ref = data.data) != null ? _ref.mu[0] : void 0 : void 0;
          return scope.elements = data != null ? (_ref1 = data.data) != null ? _ref1.elements : void 0 : void 0;
        };
      })(this));
      this.initEquips(scope);
      scope.createDevice = (function(_this) {
        return function(num) {
          if (num === 1) {
            scope.equipment = scope.station.createEquipment();
          }
          if (num === 2) {
            scope.fileNameStr = "";
            return _this.getEquipmentType(scope);
          }
        };
      })(this);
      scope.editDevice = (function(_this) {
        return function(device) {
          return scope.equipment = device;
        };
      })(this);
      scope.deleteDevice = (function(_this) {
        return function(device) {
          var message, title;
          scope.equipment = device;
          title = "删除设备确认";
          message = "请确认是否删除设备: " + scope.equipment.model.name + "？删除后设备和数据将从系统中移除不可恢复！";
          return scope.prompt(title, message, function(ok) {
            var data, pindex, port, sindex, su, _i, _len, _ref;
            if (!ok) {
              return;
            }
            scope.equipment.remove(function(err, model) {
              return _this.initEquips(scope);
            });
            _ref = scope.mu.ports;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              port = _ref[_i];
              su = _.find(port.sampleUnits, function(it) {
                return it.id === scope.equipment.model.equipment;
              });
              if (su) {
                break;
              }
            }
            if (su) {
              pindex = scope.mu.ports.indexOf(port);
              sindex = port.sampleUnits.indexOf(su);
              port.sampleUnits.splice(sindex, 1);
              if (port.sampleUnits.length === 0) {
                scope.mu.ports.splice(pindex, 1);
              }
            }
            data = {
              parameters: [scope.mu]
            };
            return _this.commonService.rpcPost("muSetting", data.parameters, function(err, data) {
              if (err || !(data != null ? data.data : void 0)) {
                console.log("保存失败:", err);
              }
              if ((data != null ? data.data : void 0) === "ok") {
                return console.log("保存成功");
              }
            });
          });
        };
      })(this);
      scope.saveDevice = (function(_this) {
        return function() {
          var data, desc, id, libraryVersion, name, pindex, port, sindex, sp, sport, su, suid, sunit, template, templateSymbol, _i, _len, _ref, _ref1, _ref10, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
          if (!scope.equipment.model.type) {
            return _this.display("请选择设备类型");
          }
          if (!scope.equipment.model.template) {
            return _this.display("请选择设备型号");
          }
          if (!scope.equipment.model.name) {
            return _this.display("请填入设备名称");
          }
          if (!scope.equipment.model.station) {
            return _this.display("请选择设备站点");
          }
          if (!scope.equipment.model.port) {
            return _this.display("请选择设备端口");
          }
          if (scope.equipment.model.port) {
            name = _this.checkExistSetting(scope);
            if (name) {
              return _this.display('该设备所设端口号及地址与设备"' + name + '"的配置重复');
            }
          }
          template = _.find(scope.project.equipmentTemplates.items, function(item) {
            return item.model.type === scope.equipment.model.type && item.model.template === scope.equipment.model.template;
          });
          libraryVersion = "";
          templateSymbol = (_ref = template.model.symbol) != null ? _ref : template.model.desc;
          if (!scope.equipment.model.equipment) {
            scope.equipment.model.vendor = template.model.vendor;
            id = scope.equipments.length ? (_.max(scope.equipments, function(item) {
              return item.model._index;
            })).model.equipment : "0";
            scope.equipment.model.equipment = _this.getNextName(id);
          }
          _.mapObject(scope.elements, function(ele) {
            if (ele.id === templateSymbol) {
              return libraryVersion = ele.version;
            }
          });
          desc = {
            port: scope.equipment.model.port,
            address: scope.equipment.model.address,
            parameters: scope.equipment.model.parameters,
            addr: scope.equipment.model.addr,
            libraryVersion: libraryVersion,
            expiryDate: scope.equipment.model.expiryDate
          };
          scope.equipment.model.desc = JSON.stringify(desc);
          if (scope.mu && scope.equipment.model.port) {
            suid = ((_ref1 = scope.equipment.model.port) != null ? _ref1.substr(0, 1) : void 0) === "d" ? scope.equipment.model.port : scope.equipment.model.equipment;
            if (_.isEmpty(scope.equipment.sampleUnits)) {
              scope.equipment.sampleUnits = template.model.sampleUnits;
            }
            scope.equipment.sampleUnits[0].value = scope.mu.id + "/" + suid;
            if ((_ref2 = scope.equipment.sampleUnits[1]) != null) {
              _ref2.value = scope.mu.id + "/_";
            }
          }
          if (scope.equipment.model.port && scope.equipment.model.port.substr(0, 1) !== "d") {
            if (!((_ref3 = scope.elements) != null ? _ref3[(_ref4 = template.model.symbol) != null ? _ref4 : template.model.desc] : void 0)) {
              return _this.display("找不到该设备型号对应的协议采集库，无法保存！");
            }
            sport = {
              id: scope.equipment.model.equipment,
              name: scope.equipment.model.name,
              enable: true,
              setting: {},
              sampleUnits: []
            };
            sport.protocol = ((_ref5 = scope.elements[(_ref6 = template.model.symbol) != null ? _ref6 : template.model.desc]) != null ? _ref5.mappings.length : void 0) > 1 ? "protocol-modbus-serial" : (_ref7 = scope.elements[(_ref8 = template.model.symbol) != null ? _ref8 : template.model.desc]) != null ? _ref7.mappings[0].protocol : void 0;
            if (scope.equipment.model.port !== "ip") {
              sport.setting.port = scope.equipment.model.port;
              sport.setting.baudRate = parseInt(scope.equipment.model.parameters.split(",")[0]);
            }
            if (scope.equipment.model.port === "ip") {
              sport.setting.server = scope.equipment.model.address;
            }
            sunit = {
              id: scope.equipment.model.equipment,
              name: scope.equipment.model.name,
              period: 60000,
              timeout: 50000,
              maxCommunicationErrors: 5,
              enable: true,
              setting: {}
            };
            sunit.element = ((_ref9 = template.model.symbol) != null ? _ref9 : template.model.desc) + ".json";
            sunit.setting.address = parseInt(scope.equipment.model.port === "ip" ? scope.equipment.model.addr : scope.equipment.model.address);
            _ref10 = scope.mu.ports;
            for (_i = 0, _len = _ref10.length; _i < _len; _i++) {
              port = _ref10[_i];
              su = _.find(port.sampleUnits, function(it) {
                return it.id === scope.equipment.model.equipment;
              });
              if (su) {
                break;
              }
            }
            if (su) {
              pindex = scope.mu.ports.indexOf(port);
              sindex = port.sampleUnits.indexOf(su);
              port.sampleUnits.splice(sindex, 1);
              if (port.sampleUnits.length === 0) {
                scope.mu.ports.splice(pindex, 1);
              }
            }
            sp = _.find(scope.mu.ports, function(port) {
              return port.setting.port === scope.equipment.model.port || port.setting.server === scope.equipment.model.address;
            });
            if (sp) {
              sp.protocol = sport.protocol;
              sp.setting = sport.setting;
              sp.sampleUnits.push(sunit);
            } else {
              sport.sampleUnits.push(sunit);
              scope.mu.ports.push(sport);
            }
            data = {
              parameters: [scope.mu]
            };
            _this.commonService.rpcPost("muSetting", data.parameters, function(err, data) {
              if (err || !(data != null ? data.data : void 0)) {
                console.log("保存失败:", err);
              }
              if ((data != null ? data.data : void 0) === "ok") {
                return console.log("保存成功");
              }
            });
          }
          return scope.equipment.save(function(err, model) {
            console.log("model", model);
            if (!err) {
              _this.initEquips(scope);
            }
            return M.Modal.getInstance($("#device-modal")).close();
          });
        };
      })(this);
      scope.portChange = function() {
        if (scope.equipment.model.port.substr(0, 1) === "/") {
          scope.equipment.model.parameters = "9600,n,8,1";
          scope.equipment.model.address = 1;
          return scope.equipment.model.addr = null;
        } else if (scope.equipment.model.port === "ip") {
          scope.equipment.model.parameters = null;
          scope.equipment.model.address = "192.168.1.100";
          return scope.equipment.model.addr = 1;
        } else {
          scope.equipment.model.parameters = null;
          scope.equipment.model.address = null;
          return scope.equipment.model.addr = null;
        }
      };
      scope.filterTypes = (function(_this) {
        return function() {
          return function(item) {
            if (item.model.base) {
              return true;
            }
            return false;
          };
        };
      })(this);
      scope.filterTemplates = (function(_this) {
        return function() {
          return function(item) {
            var _ref;
            if (item.model.type === ((_ref = scope.equipment) != null ? _ref.model.type : void 0)) {
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
            var text, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
            text = (_ref = scope.search) != null ? _ref.toLowerCase() : void 0;
            if (!text) {
              return true;
            }
            if (((_ref1 = equipment.model.equipment) != null ? _ref1.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref2 = equipment.model.name) != null ? _ref2.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref3 = equipment.model.typeName) != null ? _ref3.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref4 = equipment.model.stationName) != null ? _ref4.toLowerCase().indexOf(text) : void 0) >= 0) {
              return true;
            }
            if (((_ref5 = equipment.model.vendorName) != null ? _ref5.toLowerCase().indexOf(text) : void 0) >= 0) {
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
      scope.selectPage = (function(_this) {
        return function(page) {
          return scope.pageIndex = page;
        };
      })(this);
      scope.file = (function(_this) {
        return function() {
          var input;
          scope.fileNameStr = "";
          input = element.find('input[type="file"]');
          input.click();
          input.click(function() {
            return input.val('');
          });
          return input.on('change', function(evt) {
            var file, _ref, _ref1;
            file = (_ref = input[0]) != null ? (_ref1 = _ref.files) != null ? _ref1[0] : void 0 : void 0;
            scope.fileNameStr = file.name;
            evt.target.value = null;
            scope.zp = new FormData;
            scope.zp.append("file", file);
            return scope.$applyAsync();
          });
        };
      })(this);
      scope.confirmSha = (function(_this) {
        return function() {
          var params, url;
          url = scope.controller.$location.$$absUrl.substr(0, scope.controller.$location.$$absUrl.indexOf("#")) + "rpc/uploadElement";
          params = {
            token: scope.controller.$rootScope.user.token,
            parameters: {
              token: scope.controller.$rootScope.user.token,
              project: scope.project.model.project,
              user: scope.project.model.user,
              ip: scope.ip
            }
          };
          return _this.commonService.uploadService.$http({
            method: 'POST',
            url: url,
            data: scope.zp,
            params: params,
            headers: {
              'Content-Type': void 0
            }
          }).then(function(res) {
            var _ref;
            if (((_ref = res.data) != null ? _ref.data : void 0) === "ok") {
              _this.display("上传成功");
              return _this.getEquipmentType(scope);
            } else {
              return _this.display("上传失败");
            }
          });
        };
      })(this);
      return scope.uninstall = (function(_this) {
        return function(equip) {
          var message, template, title;
          template = _.find(scope.equipments, function(equipment) {
            return equipment.model.template === equip.model.template;
          });
          console.log("template", template);
          if (template) {
            return _this.display("所卸载的设备库下已有设备,请先删除设备后进行卸载！！！");
          }
          _this.deleteMoreData(scope, equip, null, false);
          title = "删除设备确认";
          message = "请确认是否删除: " + equip.model.name + "？删除后将从数据库移除相关记录，不可恢复。";
          return scope.prompt(title, message, function(ok) {
            var project, url, user;
            if (!ok) {
              return;
            }
            user = scope.project.model.user;
            project = scope.project.model.project;
            url = "" + scope.ip + "/model/clc/api/v1/equipmenttemplates/" + user + "/" + project + "/" + equip.model.type + "/" + equip.model.template + "?token=" + scope.controller.$rootScope.user.token;
            return _this.httpRequest(url, null, "delete", function(res) {
              if (res.data.length > 0) {
                scope.elementsArr = _.filter(scope.elementsArr, function(item) {
                  return item.model.template !== res.data[0].template;
                });
                _this.setMoreData(scope, equip.signals.items, res.data, "signal", "equipmentsignals");
                _this.setMoreData(scope, equip.properties.items, res.data, "property", "equipmentproperties");
                _this.setMoreData(scope, equip.events.items, res.data, "event", "equipmentevents");
                _this.setMoreData(scope, equip.commands.items, res.data, "command", "equipmentcommands");
                _this.setMoreData(scope, equip.ports.items, res.data, "port", "equipmentports");
                return _this.deleteEquipmenttypes(scope, res.data);
              }
            });
          });
        };
      })(this);
    };

    EquipmentsDirective.prototype.deleteMoreData = function(scope, equip, resData, isdelete) {
      if (equip) {
        equip.loadSignals(null, (function(_this) {
          return function(err, signals) {
            return scope.signals = signals;
          };
        })(this));
        equip.loadEvents(null, (function(_this) {
          return function(err, event) {
            return scope.event = event;
          };
        })(this));
        equip.loadProperties(null, (function(_this) {
          return function(err, properties) {
            return scope.properties = properties;
          };
        })(this));
        equip.loadCommands(null, (function(_this) {
          return function(err, command) {
            return scope.command = command;
          };
        })(this));
        return equip.loadPorts(null, (function(_this) {
          return function(err, ports) {
            return scope.ports = ports;
          };
        })(this));
      }
    };

    EquipmentsDirective.prototype.setMoreData = function(scope, moreData, resData, typeData, urlType) {
      var parameter, project, url, user;
      parameter = {
        items: [],
        token: scope.controller.$rootScope.user.token
      };
      if (moreData.length > 0) {
        _.each(moreData, (function(_this) {
          return function(item) {
            item.model._removed = true;
            return parameter.items.push(item.model);
          };
        })(this));
        user = scope.project.model.user;
        project = scope.project.model.project;
        url = "" + scope.ip + "/model/clc/api/v1/" + urlType + "/" + user + "/" + project + "/" + resData[0].type + "/" + resData[0].template + "/_batch";
        return this.httpRequest(url, parameter, "put", (function(_this) {
          return function(res) {};
        })(this));
      }
    };

    EquipmentsDirective.prototype.deleteEquipmenttypes = function(scope, resData) {
      return scope.project.loadEquipmentTemplates({
        type: resData[0].type
      }, null, (function(_this) {
        return function(err, templates) {
          var project, url, user;
          if (templates.length === 0) {
            user = scope.project.model.user;
            project = scope.project.model.project;
            url = "" + scope.ip + "/model/clc/api/v1/equipmenttypes/" + user + "/" + project + "/" + resData[0].type + "/?token=" + scope.controller.$rootScope.user.token;
            return _this.httpRequest(url, null, "delete", function(res) {
              return scope.project.loadTypeModel("equipmenttypes", null, function(err, data) {
                return console.log("err", err);
              }, true);
            });
          }
        };
      })(this), true);
    };

    EquipmentsDirective.prototype.httpRequest = function(url, parameter, type, callback) {
      return this.commonService.modelEngine.modelManager.$http[type](url, parameter).then((function(_this) {
        return function(res) {
          return typeof callback === "function" ? callback(res) : void 0;
        };
      })(this));
    };

    EquipmentsDirective.prototype.getEquipmentType = function(scope) {
      scope.project.loadTypeModel("equipmenttypes", null, (function(_this) {
        return function(err, data) {
          return console.log("err", err);
        };
      })(this), true);
      scope.project.loadEquipmentTemplates(null, null, (function(_this) {
        return function(err, tmps) {
          var equipmenttypes;
          scope.elementsArr.splice(0, scope.elementsArr.length);
          equipmenttypes = scope.project.typeModels.equipmenttypes.items;
          return _.each(tmps, function(template) {
            return _.each(equipmenttypes, function(item) {
              var symbol, _ref;
              if (item.model.base && template.model.type === (item != null ? item.model.type : void 0)) {
                template.model.typeName = item.model.name;
                symbol = (_ref = template.model.symbol) != null ? _ref : template.model.desc;
                if (symbol) {
                  _.mapObject(scope.elements, function(ele) {
                    if (ele.id === symbol) {
                      template.model.libraryVersion = ele.version;
                      return template.model.description = ele.description;
                    }
                  });
                }
                if (template.model.visible) {
                  return scope.elementsArr.push(template);
                }
              }
            });
          });
        };
      })(this), true);
      return scope.$applyAsync();
    };

    EquipmentsDirective.prototype.checkExistSetting = function(scope) {
      var equip;
      equip = _.find(scope.equipments, function(item) {
        var _ref, _ref1, _ref2, _ref3;
        return item.model.port === scope.equipment.model.port && ((_ref = item.model.address) != null ? _ref.toString() : void 0) === ((_ref1 = scope.equipment.model.address) != null ? _ref1.toString() : void 0) && ((_ref2 = item.model.addr) != null ? _ref2 : "") === ((_ref3 = scope.equipment.model.addr) != null ? _ref3 : "") && item.model.equipment !== scope.equipment.model.equipment;
      });
      return equip != null ? equip.model.name : void 0;
    };

    EquipmentsDirective.prototype.initEquips = function(scope) {
      scope.equipments = [];
      return scope.project.loadEquipmentTemplates(null, null, (function(_this) {
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
                return scope.equipments = scope.equipments.concat(equips);
              }
            }, true));
          }
          return _results;
        };
      })(this), true);
    };

    EquipmentsDirective.prototype.loadProperties = function(scope, equip, d) {
      var event, key;
      console.log("equip123456", equip);
      event = scope.project.getIds();
      key = "" + event.user + "." + event.project + "." + scope.station.model.station + "." + equip.model.equipment + ".expiry-date";
      return equip.loadProperties(null, (function(_this) {
        return function(err, data) {
          return _.each(data, function(properties) {
            console.log("properties", properties);
            if (properties.key === key) {
              if (d) {
                return equip.model.expiryDate = properties.value;
              } else {
                return properties.value = equip.model.expiryDate;
              }
            }
          });
        };
      })(this));
    };

    EquipmentsDirective.prototype.getNextName = function(name, defaultName) {
      var name2;
      if (defaultName == null) {
        defaultName = "";
      }
      if (!name) {
        return defaultName;
      }
      name2 = name.replace(/(\d*$)/, function(m, p1) {
        var num;
        return num = p1 ? parseInt(p1) + 1 : '-0';
      });
      return name2;
    };

    EquipmentsDirective.prototype.resize = function(scope) {};

    EquipmentsDirective.prototype.dispose = function(scope) {};

    return EquipmentsDirective;

  })(base.BaseDirective);
  return exports = {
    EquipmentsDirective: EquipmentsDirective
  };
});
