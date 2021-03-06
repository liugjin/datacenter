// Generated by IcedCoffeeScript 108.0.12

/*
* File: datacenter-service
* User: Pu
* Date: 2018/9/1
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.web', 'clc.foundation.data/app/models/system/configurations-model', 'iced-coffee-script', 'adm-zip', '../../../index-setting', 'path', 'fs', 'urllib', 'underscore', 'child_process', "moment"], function(base, configurations, iced, zip, setting, path, fs, urllib, _, process, moment) {
  var DatacenterService, exports;
  if (iced.iced) {
    iced = iced.iced;
  }
  DatacenterService = (function(_super) {
    __extends(DatacenterService, _super);

    function DatacenterService(options) {
      this.saveNTPIP = __bind(this.saveNTPIP, this);
      this.getNTPIP = __bind(this.getNTPIP, this);
      this.changeServiceTime = __bind(this.changeServiceTime, this);
      this.getServiceTime = __bind(this.getServiceTime, this);
      this.getVersionInfo = __bind(this.getVersionInfo, this);
      this.changeStoreInfo = __bind(this.changeStoreInfo, this);
      this.getStoreMode = __bind(this.getStoreMode, this);
      this.changeStoreMode = __bind(this.changeStoreMode, this);
      this.getSystemInfo = __bind(this.getSystemInfo, this);
      var sm;
      DatacenterService.__super__.constructor.call(this, options);
      sm = require("./service-manager");
      this.systemInfoService = sm.getService("SystemInfoService");
      this.configurationSetuoService = sm.getService("ConfigurationSetuoService");
      this.TimeManageService = sm.getService("TimeManageService");
      this.BackupInfoService = sm.getService("BackupInfo");
      this.GetVersionService = sm.getService("GetVersionService");
      this.configurations = new configurations.ConfigurationsModel;
    }

    DatacenterService.prototype.initializeProcedures = function() {
      return this.registerProcedure(['echo', 'upload', "uploadElement", "configurationRecovery", "ipSetting", "muSetting", "getSystemInfo", "upgrade", "changeStoreMode", "getStoreMode", "changeStoreInfo", "getVersionInfo", "getServiceTime", "changeServiceTime", "getNTPIP", "saveNTPIP", "getConfigurationInfo"]);
    };

    DatacenterService.prototype.echo = function(options, callback) {
      var result, time;
      time = options.parameters.time + (" -- server: " + (new Date().toISOString()));
      result = {
        time: time
      };
      return typeof callback === "function" ? callback(null, result) : void 0;
    };

    DatacenterService.prototype.upload = function(file, callback) {
      var component, js, main, plugin, plugins, result, src, text, zp;
      zp = new zip(file.path);
      text = zp.readAsText("component.json");
      js = zp.readAsText("component.js");
      result = "error";
      if (text && js) {
        component = JSON.parse(text);
        if (component.id && component.version && js.indexOf("BaseDirective") > 0) {
          result = "ok";
          src = path.join(__dirname, "../../scripts/", setting.id, "/src/");
          main = fs.readFileSync(src + "main.js");
          plugins = JSON.parse(fs.readFileSync(src + "directives/plugins.json"));
          if (main.indexOf("directives/" + component.id + "/component") < 0) {
            plugin = _.find(plugins, function(item) {
              return item.id === component.id;
            });
            if (!plugin) {
              plugins.push({
                id: component.id
              });
              fs.writeFileSync(src + "directives/plugins.json", JSON.stringify(plugins));
            }
          }
          zp.extractAllTo(src + "directives/" + component.id, true);
        }
      }
      return callback(null, result);
    };

    DatacenterService.prototype.upgrade = function(file, callback) {
      var data, fileName, infos, pageFilePackage, pageFilelog, src, zp;
      console.log("file", file);
      if (file.originalFilename) {
        fileName = file.originalFilename.split(".zip")[0];
      } else if (file.originalname) {
        fileName = file.originalname.split(".zip")[0];
      } else {
        fileName = "clc.datacenter";
      }
      console.log("fileName", fileName);
      zp = new zip(file.path);
      src = path.join(__dirname, "../../../../");
      zp.extractAllTo(src, true);
      pageFilePackage = JSON.parse(fs.readFileSync("" + src + "/" + fileName + "/package.json"));
      if (!fs.existsSync("" + src + "/version-info-log.json")) {
        fs.writeFileSync("" + src + "/version-info-log.json", JSON.stringify([]));
      }
      pageFilelog = JSON.parse(fs.readFileSync("" + src + "/version-info-log.json"));
      data = {
        "version": pageFilePackage.version,
        "updateTime": moment(new Date(new Date().getTime() + 28800000)).format("YYYY-MM-DD HH:mm")
      };
      pageFilelog.push(data);
      infos = JSON.stringify(pageFilelog, null, 2);
      fs.writeFileSync("" + src + "/version-info-log.json", infos);
      console.log("脚本指令", "sh /root/huayuan/" + fileName + ".sh");
      process.spawn("sh", ["/root/huayuan/" + fileName + ".sh"]);
      return typeof callback === "function" ? callback(null, "ok") : void 0;
    };

    DatacenterService.prototype.uploadElement = function(file, callback) {
      return this.configurationSetuoService.uploadElement(file, callback);
    };

    DatacenterService.prototype.configurationRecovery = function(file, callback) {
      return this.configurationSetuoService.configurationRecovery(file, callback);
    };

    DatacenterService.prototype.ipSetting = function(options, callback) {
      var defaultData, _ref;
      if (options.action === "get") {
        defaultData = {
          type: 'static',
          ip: '127.0.0.1',
          mask: '255.255.255.0',
          gateway: '192.168.0.1',
          dns: '',
          hostName: ''
        };
        this.networkPath = "/etc/network/interfaces";
        this.netHostNamePath = "/etc/hostname";
        if (fs.existsSync(this.netHostNamePath)) {
          this.hostName = (fs.readFileSync(this.netHostNamePath)).toString();
        }
        if (fs.existsSync(this.networkPath)) {
          this.file = (fs.readFileSync(this.networkPath)).toString();
          this.network = this.file.split(/[\n\r]/);
          this.data = {
            type: this.operateText(this.network, "iface eth0 inet"),
            ip: this.operateText(this.network, "address"),
            mask: this.operateText(this.network, "netmask"),
            gateway: this.operateText(this.network, "gateway"),
            dns: this.operateText(this.network, "dns-nameserver"),
            hostName: this.hostName
          };
        }
        return typeof callback === "function" ? callback(null, (_ref = this.data) != null ? _ref : defaultData) : void 0;
      } else if (options.action === "post") {
        setting = options.parameters;
        if (setting.type) {
          this.operateText(this.network, "iface eth0 inet", setting.type);
        }
        if (setting.ip) {
          this.operateText(this.network, "address", setting.ip);
        }
        if (setting.mask) {
          this.operateText(this.network, "netmask", setting.mask);
        }
        if (setting.gateway) {
          this.operateText(this.network, "gateway", setting.gateway);
        }
        if (setting.dns) {
          this.operateText(this.network, "dns-nameserver", setting.dns);
        }
        if (fs.existsSync(this.networkPath)) {
          fs.writeFileSync(this.networkPath, this.file);
        }
        if (fs.existsSync(this.netHostNamePath)) {
          fs.writeFileSync(this.netHostNamePath, setting.hostName);
        }
        if (setting.type === "static") {
          if (setting.ip !== this.data.ip || setting.mask !== this.data.mask) {
            process.exec("ifconfig eth0 " + setting.ip + " netmask " + setting.mask);
          }
          if (setting.gateway && setting.gateway !== this.data.gateway) {
            process.exec("route add default gw " + setting.gateway);
          }
          if (setting.hostName && setting.hostName !== this.data.hostName) {
            process.exec("hostnamectl set-hostname " + setting.hostName);
          }
        }
        return callback(null, "ok");
      }
    };

    DatacenterService.prototype.operateText = function(arr, key, value) {
      var item, keys, news;
      item = _.find(arr, function(it) {
        return it.indexOf(key) >= 0;
      });
      if (!item) {
        return null;
      }
      keys = item.trim().split(" ");
      if (value == null) {
        return keys[keys.length - 1];
      } else {
        keys[keys.length - 1] = value;
        news = keys.join(" ");
        return this.file = this.file.replace(item, news);
      }
    };

    DatacenterService.prototype.muSetting = function(options, callback) {
      var element, mu, _i, _len, _ref;
      if (options.action === "get") {
        this.muPath = "/root/apps/app/aggregation/monitoring-units.json";
        this.elementPath = "/root/apps/app/aggregation/element-lib/";
        if (fs.existsSync(this.muPath)) {
          this.muInfo = JSON.parse((fs.readFileSync(this.muPath)).toString());
          console.log("@muInfo", this.muInfo);
          this.elements = {};
          _ref = fs.readdirSync(this.elementPath);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            element = _ref[_i];
            this.elements[element.split(".")[0]] = JSON.parse((fs.readFileSync(this.elementPath + element)).toString());
          }
          return typeof callback === "function" ? callback(null, {
            mu: this.muInfo,
            elements: this.elements
          }) : void 0;
        }
      } else if (options.action === "post") {
        mu = options.parameters;
        if (fs.existsSync(this.muPath)) {
          fs.writeFileSync(this.muPath, JSON.stringify(mu));
        }
        process.exec("pm2 restart start_aggregation");
        return typeof callback === "function" ? callback(null, "ok") : void 0;
      }
    };

    DatacenterService.prototype.getSystemInfo = function(options, callback) {
      return this.systemInfoService.run(callback);
    };

    DatacenterService.prototype.changeStoreMode = function(options, callback) {
      return this.BackupInfoService.changeStoreMode(options, callback);
    };

    DatacenterService.prototype.getStoreMode = function(options, callback) {
      return this.BackupInfoService.getStoreMode(callback);
    };

    DatacenterService.prototype.changeStoreInfo = function(options, callback) {
      return this.BackupInfoService.changeStoreInfo(options, callback);
    };

    DatacenterService.prototype.getVersionInfo = function(options, callback) {
      return this.GetVersionService.getVersion(callback);
    };

    DatacenterService.prototype.getServiceTime = function(options, callback) {
      return this.TimeManageService.getServiceTime(callback);
    };

    DatacenterService.prototype.changeServiceTime = function(options, callback) {
      return this.TimeManageService.changeServiceTime(options, callback);
    };

    DatacenterService.prototype.getNTPIP = function(options, callback) {
      return this.TimeManageService.getNTPIP(callback);
    };

    DatacenterService.prototype.saveNTPIP = function(options, callback) {
      return this.TimeManageService.saveNTPIP(options, callback);
    };

    DatacenterService.prototype.getConfigurationInfo = function(options, callback) {
      var endTime, startTime;
      startTime = options.parameters.startTime;
      endTime = options.parameters.endTime;
      return this.configurations.find({
        updatetime: {
          "$gte": startTime,
          "$lt": endTime
        }
      }, null, (function(_this) {
        return function(err, datas) {
          var result;
          if (err) {
            console.log(err);
          }
          console.log(datas.length);
          result = {};
          if (datas.length) {
            result = {
              result: 1,
              data: datas
            };
          } else {
            result = {
              result: 0
            };
          }
          return typeof callback === "function" ? callback(null, result) : void 0;
        };
      })(this));
    };

    return DatacenterService;

  })(base.RpcService);
  return exports = {
    DatacenterService: DatacenterService
  };
});
