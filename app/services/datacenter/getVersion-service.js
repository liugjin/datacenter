// Generated by IcedCoffeeScript 108.0.11

/*
* File: getStoreModel-service
* User: foam
* Date: 2020/05/22
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.web', 'fs'], function(base, fs) {
  var GetVersionService, exports;
  GetVersionService = (function(_super) {
    __extends(GetVersionService, _super);

    function GetVersionService(options) {
      this.getVersion = __bind(this.getVersion, this);
      GetVersionService.__super__.constructor.call(this, options);
    }

    GetVersionService.prototype.getVersion = function(callback) {
      var pageFile, result, versionFile;
      pageFile = JSON.parse(fs.readFileSync("./package.json"));
      if (fs.existsSync("./version.json")) {
        versionFile = JSON.parse(fs.readFileSync("./version.json"));
        result = {
          appVersion: pageFile.version,
          hardwareVersion: versionFile.hardwareVersion,
          systemVersion: versionFile.systemVersion,
          tag: versionFile.tag
        };
        return typeof callback === "function" ? callback(null, result) : void 0;
      } else {
        result = {
          appVersion: pageFile.version,
          hardwareVersion: "",
          systemVersion: "",
          tag: ""
        };
        return typeof callback === "function" ? callback(null, result) : void 0;
      }
    };

    return GetVersionService;

  })(base.MqttService);
  return exports = {
    GetVersionService: GetVersionService
  };
});