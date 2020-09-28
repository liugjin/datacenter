// Generated by IcedCoffeeScript 108.0.12

/*
* File: reporting-table-directive
* User: David
* Date: 2020/03/17
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var ReportingTableDirective, exports;
  ReportingTableDirective = (function(_super) {
    __extends(ReportingTableDirective, _super);

    function ReportingTableDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "reporting-table";
      ReportingTableDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    ReportingTableDirective.prototype.setScope = function() {};

    ReportingTableDirective.prototype.setCSS = function() {
      return css;
    };

    ReportingTableDirective.prototype.setTemplate = function() {
      return view;
    };

    ReportingTableDirective.prototype.show = function(scope, element, attrs) {
      var routerObj;
      scope.paramRouterObj = [];
      routerObj = [
        {
          name: 'UPS告警记录',
          src: this.getComponentPath('image/1.svg'),
          router: 'ups-alarm',
          title: 'UPS告警记录'
        }, {
          name: '空调告警记录',
          src: this.getComponentPath('image/2.svg'),
          router: 'ac-alarm',
          title: '空调告警记录'
        }, {
          name: '蓄电池告警记录',
          src: this.getComponentPath('image/3.svg'),
          router: 'battery-alarm',
          title: '蓄电池故障告警统计'
        }, {
          name: '门禁刷卡记录',
          src: this.getComponentPath('image/11.svg'),
          router: 'door-report',
          title: '门禁刷卡记录'
        }, {
          name: '设备告警记录',
          src: this.getComponentPath('image/5.svg'),
          router: 'reporting-signal',
          title: '设备告警记录'
        }, {
          name: '活动告警记录',
          src: this.getComponentPath('image/6.svg'),
          router: 'report-activeevents',
          title: '活动告警记录'
        }, {
          name: '告警屏蔽记录',
          src: this.getComponentPath('image/7.svg'),
          router: 'repord-report-alarm',
          title: '告警屏蔽记录'
        }, {
          name: '按告警级别统计',
          src: this.getComponentPath('image/8.svg'),
          router: 'reporting-events-level',
          title: '按告警级别统计'
        }, {
          name: '高频次告警记录',
          src: this.getComponentPath('image/9.svg'),
          router: 'report-frequencyevents',
          title: '高频次告警记录'
        }, {
          name: '强制结束告警记录',
          src: this.getComponentPath('image/10.svg'),
          router: 'finish-alarm',
          title: '强制结束告警记录'
        }, {
          name: '历史数据曲线记录',
          src: this.getComponentPath('image/12.svg'),
          router: 'record-hiscurve',
          title: '历史数据曲线'
        }, {
          name: '蓄电池放电统计',
          src: this.getComponentPath('image/4.svg'),
          router: 'reporting-battery-discharge',
          title: '蓄电池放电统计'
        }, {
          name: '资产统计',
          src: this.getComponentPath('image/13.svg'),
          router: 'asset-report',
          title: '资产统计'
        }, {
          name: '用电量统计',
          src: this.getComponentPath('image/14.svg'),
          router: 'electricity-consumption',
          title: '用电量统计'
        }, {
          name: '设备信号记录',
          src: this.getComponentPath('image/15.svg'),
          router: 'reporting-signal',
          title: '设备信号记录'
        }, {
          name: '设备操作日志记录',
          src: this.getComponentPath('image/16.svg'),
          router: 'log',
          title: '设备操作日志记录'
        }, {
          name: '系统日志查询',
          src: this.getComponentPath('image/17.svg'),
          router: 'report-systemlog',
          title: '系统日志查询'
        }, {
          name: '通知发送记录',
          src: this.getComponentPath('image/18.svg'),
          router: 'history-send-notification',
          title: '通知发送记录'
        }
      ];
      scope.paramRouterObj = _.chunk(routerObj, 4);
      return _.each(scope.paramRouterObj, (function(_this) {
        return function(o, i) {
          if (o.length < 4) {
            return _.each(o, function(t, j) {
              return scope.paramRouterObj[i].push({});
            });
          }
        };
      })(this));
    };

    ReportingTableDirective.prototype.resize = function(scope) {};

    ReportingTableDirective.prototype.dispose = function(scope) {};

    return ReportingTableDirective;

  })(base.BaseDirective);
  return exports = {
    ReportingTableDirective: ReportingTableDirective
  };
});