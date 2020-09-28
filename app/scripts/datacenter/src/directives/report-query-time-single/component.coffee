###
* File: report-query-time-single-directive
* User: David
* Date: 2020/02/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportQueryTimeSingleDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "report-query-time-single"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.modes = [
        {mode:'none',modeName:"时间段"}
#        {mode:'selectday',modeName:"按天查询"}
        {mode:'day',modeName:"日查询"}
        {mode:'year',modeName:"本年"}
        {mode:'month',modeName:"本月"}
      ]
      scope.mode = {}
      scope.time =
        startTime : moment().subtract(7,"days").startOf('day').format('L')
        endTime :moment().endOf('day').format('L')
        mode: 'none'
        modeName: '时间段'

      setGlDatePicker = (element,value)->
        return if not value
        setTimeout ->
          gl = $(element).glDatePicker({
            dowNames:["日","一","二","三","四","五","六"],
            monthNames:["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"],
            selectedDate: moment(value).toDate()
            onClick:(target,cell,date,data)->
              month = date.getMonth()+1
              if month < 10
                month = "0"+ month
              day = date.getDate()
              if day < 10
                day = "0"+ day
              target.val(date.getFullYear()+"-"+month+"-"+day).trigger("change")
              if scope.time.mode == 'day'
                scope.time.startTime = moment(scope.time.startTime).startOf('day').format('L')
                scope.time.endTime = moment(scope.time.startTime).endOf('day').format('L')
                $('#mymodes').hide()
              else
                scope.time.mode = 'none'
                scope.time.modeName = '自定义'
          })
        ,500
      setGlDatePicker($('#startdate')[0],scope.time.startTime)
      setGlDatePicker($('#enddate')[0],scope.time.startTime)

      scope.selectMode = (mode)->
        $(".gldp-default").css("z-index", 9999)

        switch mode.mode
          when 'year'
            scope.time.startTime = moment().startOf('year').format('L')
            scope.time.endTime = moment().endOf('year').format('L')
            scope.time.mode = mode.mode
            scope.time.modeName = mode.modeName
            $('#mymodes').hide()

          when 'month'
            scope.time.startTime = moment().startOf('month').format('L')
            scope.time.endTime = moment().endOf('month').format('L')
            scope.time.mode = mode.mode
            scope.time.modeName = mode.modeName
            $('#mymodes').hide()

          when 'day'
            scope.time.startTime = moment().startOf('day').format('L')
            scope.time.endTime = moment().endOf('day').format('L')
            scope.time.mode = mode.mode
            scope.time.modeName = mode.modeName
            $('#mymodes').hide()

          when 'none'
            scope.time.startTime = moment().startOf('day').format('L')
            scope.time.endTime = moment().endOf('day').format('L')
            scope.time.mode = mode.mode
            scope.time.modeName = mode.modeName
            $('#mymodes').hide()



      scope.formatDate = (id) =>
        $(".gldp-default").css("z-index", 9999)

        switch id
          when 'startdate'
            scope.time.startTime = moment(scope.time.startTime).format('L')
          when 'enddate'
            scope.time.endTime = moment(scope.time.endTime).format('L')


      scope.$watch 'time',(time)=>
        @commonService.publishEventBus 'time',time
      ,true

      scope.myenter = (id)->
       #解决左侧菜单显示和隐藏式引起日期选择错位的bug
        $(".gldp-default").css("z-index", 9999)
        switch id
          when 'startdate'
            nowvalue = $('#startdate').offset().left
            $('.gldp-default').css "left", nowvalue+'px'
          when 'enddate'
            nowvalue = $('#enddate').offset().left
            $('.gldp-default').css "left", nowvalue+'px'


    resize: (scope)->

    dispose: (scope)->


  exports =
    ReportQueryTimeSingleDirective: ReportQueryTimeSingleDirective