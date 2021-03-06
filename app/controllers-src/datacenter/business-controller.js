// Generated by IcedCoffeeScript 108.0.11
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.web', 'clc.foundation', 'clc.foundation.data/app/models/configuration/equipments-model', 'clc.foundation.data/app/models/monitoring/signal-values-model', 'clc.foundation.data/app/models/monitoring/command-values-model', 'clc.foundation.data/app/models/system/configurations-model', '../../services/datacenter/service-manager', '../../../index-setting.json', 'moment/moment', 'underscore'], function(web, service, equipment, signal, command, configurations, sm, setting, moment, _) {
  var BusinessController, exports;
  BusinessController = (function(_super) {
    __extends(BusinessController, _super);

    function BusinessController() {
      var options;
      BusinessController.__super__.constructor.apply(this, arguments);
      this.equip = new equipment.EquipmentsModel;
      this.signal = new signal.SignalValuesModel;
      this.command = new command.CommandValuesModel;
      this.configurations = new configurations.ConfigurationsModel;
      options = {};
      options.setting = sm.getService("register").getSetting();
      options.configurationService = sm.getService("configuration");
      options.mqtt = setting.mqtt;
      this.mqttService = new service.MqttService(setting);
      this.mqttService.start();
      this.doorstatusflag = {};
      this.doorstatussubscription = {};
      this.dooropencommandvaluesphase = {};
      this.dooropencommandvaluesscription = {};
      this.doorStatus = {};
    }

    BusinessController.prototype.tokenCheck = function(token, callback) {
      console.log(token);
      return this.roleService.getTokenRole(token, {
        user: setting.myproject.user,
        project: setting.myproject.project
      }, (function(_this) {
        return function(err, data) {
          if (err) {
            return _this.renderData(err, {
              result: 0
            });
          }
          return typeof callback === "function" ? callback() : void 0;
        };
      })(this));
    };

    BusinessController.prototype.renderData = function(err, data) {
      if (data == null) {
        data = {};
      }
      if (err) {
        data._err = err;
      }
      return this.res.json(data);
    };

    BusinessController.prototype.getConfigurationInfo = function() {
      var params;
      params = this.req.query;
      console.log(params);
      return this.configurations.query({
        type: params.type,
        action: params.action
      }, null, (function(_this) {
        return function(err, equipments) {
          if (err) {
            console.log(err);
          }
          if (equipments.length) {
            return _this.renderData(null, {
              result: 1,
              data: equipments
            });
          } else {
            return _this.renderData('无数据', {
              result: 0
            });
          }
        };
      })(this));
    };

    return BusinessController;

  })(web.AuthController);
  return exports = {
    BusinessController: BusinessController
  };
});
