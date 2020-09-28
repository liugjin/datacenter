###
* File: reporting-table-directive
* User: David
* Date: 2020/03/17
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportingTableDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "reporting-table"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.paramRouterObj = []
      
      routerObj = [
        { name: 'UPS告警记录', src: @getComponentPath('image/1.svg'), router: 'ups-alarm', title: 'UPS告警记录' }
        { name: '空调告警记录', src: @getComponentPath('image/2.svg'), router: 'ac-alarm', title: '空调告警记录' }
        { name: '蓄电池告警记录', src: @getComponentPath('image/3.svg'), router: 'battery-alarm', title: '蓄电池故障告警统计' }
        { name: '门禁刷卡记录', src: @getComponentPath('image/11.svg'), router: 'door-report', title: '门禁刷卡记录' }
        { name: '设备告警记录', src: @getComponentPath('image/5.svg'), router: 'reporting-signal', title: '设备告警记录' }
        { name: '活动告警记录', src: @getComponentPath('image/6.svg'), router: 'report-activeevents', title: '活动告警记录' }
        { name: '告警屏蔽记录', src: @getComponentPath('image/7.svg'), router: 'repord-report-alarm', title: '告警屏蔽记录' }
        { name: '按告警级别统计', src: @getComponentPath('image/8.svg'), router: 'reporting-events-level', title: '按告警级别统计' }
        { name: '高频次告警记录', src: @getComponentPath('image/9.svg'), router: 'report-frequencyevents', title: '高频次告警记录' }
        { name: '强制结束告警记录', src: @getComponentPath('image/10.svg'), router: 'finish-alarm', title: '强制结束告警记录' }
        { name: '历史数据曲线记录', src: @getComponentPath('image/12.svg'), router: 'record-hiscurve', title: '历史数据曲线' }
        { name: '蓄电池放电统计', src: @getComponentPath('image/4.svg'), router: 'reporting-battery-discharge', title: '蓄电池放电统计' }
        { name: '资产统计', src: @getComponentPath('image/13.svg'), router: 'asset-report', title: '资产统计' }
        { name: '用电量统计', src: @getComponentPath('image/14.svg'), router: 'electricity-consumption', title: '用电量统计' }
        { name: '设备信号记录', src: @getComponentPath('image/15.svg'), router: 'reporting-signal', title: '设备信号记录' }
        { name: '设备操作日志记录', src: @getComponentPath('image/16.svg'), router: 'log', title: '设备操作日志记录' }
        { name: '系统日志查询', src: @getComponentPath('image/17.svg'), router: 'report-systemlog', title: '系统日志查询' }
        { name: '通知发送记录', src: @getComponentPath('image/18.svg'), router: 'history-send-notification', title: '通知发送记录' }
      ]

      scope.paramRouterObj = _.chunk(routerObj, 4)
      _.each scope.paramRouterObj,(o, i)=>
        if o.length < 4
          _.each o,(t,j)=>
            scope.paramRouterObj[i].push {}    

    resize: (scope)->

    dispose: (scope)->


  exports =
    ReportingTableDirective: ReportingTableDirective