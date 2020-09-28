###
* File: glvideo-datepicker-directive
* User: David
* Date: 2019/03/01
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment",'gl-datepicker'], (base, css, view, _, moment,gl) ->
  class GlvideoDatepickerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "glvideo-datepicker"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      $scope.time =
        timedate : moment().startOf('day').format('L')
#        endTime :moment().endOf('day').format('L')

      setGlDatePicker = (element,value)->
        return if not value
        setTimeout ->
          gl = $(element).glDatePicker({
            showAlways:true
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
          })
        ,500
      setGlDatePicker($('#datevalue')[0],$scope.time.timedate)
#      setGlDatePicker($('#enddate')[0],$scope.time.startTime)


      $scope.formatDate = (id) =>
        switch id
          when 'datevalue'
            $scope.time.timedate = moment($scope.time.timedate).format('L')
            @commonService.publishEventBus 'somedayplayback',$scope.time

#      $scope.$watch 'time',(time)=>
#        @commonService.publishEventBus 'time',time
#      ,true

      @commonService.subscribeEventBus 'menu-collapsed',(d)->
        console.log d
        $('.gldp-default').hide()
#        订阅到菜单缩放获取input位置
        setTimeout ()->
          inputvalue = $('#datevalue').offset().left
          switch d.message.value
            when false
#              nowvalue = 260
              nowvalue = 256
            when true
              nowvalue = 20
          console.log inputvalue
          console.log nowvalue
          $('.gldp-default').css "left", nowvalue+'px'
          $('.gldp-default').show()
        ,500
#
#      $scope.$watch 'videos', (video) ->
#        $('.gldp-default').css "top", (element[0].offsetTop + 2)+"px"

    resize: (scope)->

    dispose: (scope)->
      $('.gldp-default').remove()


  exports =
    GlvideoDatepickerDirective: GlvideoDatepickerDirective