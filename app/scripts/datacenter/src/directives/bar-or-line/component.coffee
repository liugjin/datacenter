###
* File: bar-or-line-directive
* User: Sheen
* Date: 2018/12/06
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], (base, css, view, _, moment, echarts) ->
  class BarOrLineDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "bar-or-line"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
#      考虑到一个页面多个用到此组件的情况，不能用订阅的方式拿图表数据，改为parameter传参数方式传递数据
#      接收参数title value type xname yname mutilcolorflag mutillevelflag leghidflag hidsplitlineflag hidlabelshowflag l
#              bbevelflag hidxaxislabel hidyaxisLineShow hidaxislineshow hidtoolboxshow grahpcolor
#      console.log $scope
      $scope.mychart = null
#      echarts图表数据通过外层组件传过来
      $scope.value = []
#                    {name:"能耗信号1", key:'2016-01-01', value:20, type:'bar'},
#                    {name:"能耗信号1", key:'2016-01-02', value:22, type:'bar'},
#                    {name:"能耗信号2", key:'2016-01-01', value:40, type:'line'},
#                    {name:"能耗信号2", key:'2016-01-02', value:42, type:'line'}
#                    ]
      $scope.$watch 'parameters.barlinevalue',(value)=>
        $scope.value = $scope.parameters.barlinevalue
#      @commonService.subscribeEventBus 'barlinevalue',(msg)=>
#        console.log "----订阅barlinevalue--"
#        $scope.value = msg.message


      e = element.find('.ss-chart')
      waitingLayout = ($timeout, element, callback) =>
        $timeout ->
          if element.width() <= 100
            waitingLayout $timeout, element, callback
          else
            callback()
        , 200

      # chart container is created dynamically so that render the chart until the layout is completed after the container is visible
      waitingLayout @$timeout, e, ()=>
        renderChart e


      renderChart = (element) ->
        $scope.mychart = echarts.init element[0]
        $scope.$watch 'value', (value) ->
#          return if not value
          $scope.mychart?.clear()
          option = createChartOption $scope.value, $scope.parameters.title, $scope.parameters.type, $scope.parameters.xname, $scope.parameters.yname, $scope.parameters.mutilcolorflag, $scope.parameters.mutillevelflag,$scope.parameters.leghidflag,$scope.parameters.hidsplitlineflag,$scope.parameters.hidlabelshowflag,$scope.parameters.lbbevelflag,$scope.parameters.hidxaxislabel,$scope.parameters.hidxaxislineshow,$scope.parameters.hidyaxislineshow,$scope.parameters.hidtoolboxshow,$scope.parameters.graphcolor
          $scope.mychart?.setOption option

      createChartOption = (values, title, type,xname,yname,mutilcolorflag,mutillevelflag,leghidflag,hidsplitlineflag,hidlabelshowflag,lbbevelflag,hidxaxislabel,hidxaxislineshow,hidyaxislineshow,hidtoolboxshow,graphcolor) ->
#    values like: [{name:"y1", key:'2016-01-01', value:10, type:'line'},
#                  {name:"y1", key:'2016-01-02', value:11, type:'line'},
#                  {name:"y2", key:'2016-01-01', value:20, type:'bar'},
#                  {name:"y2", key:'2016-01-02', value:22, type:'bar'}]
#    values = _.sortBy(_.sortBy(values, 'key'), 'name')
          legendShowFlag = true
          splitLineShowFlag = true
          labelShowFlag = false
          axisLabelShow = true
          xaxisLineShow = true
          yaxisLineShow = true
          toolboxShow = true
          defaultColor = "#00a856"
          lbrotate = 0

          if graphcolor
            defaultColor = graphcolor
          if lbbevelflag
            lbrotate =  15

          if hidsplitlineflag
            splitLineShowFlag = false

          if hidxaxislabel
            axisLabelShow = false

          if hidxaxislineshow
            xaxisLineShow = false

          if hidyaxislineshow
            yaxisLineShow = false

          if hidtoolboxshow
            toolboxShow = false

          if leghidflag
            legendShowFlag = false

          if hidlabelshowflag
            labelShowFlag = false
          else
            labelShowFlag = true

          labelOption =
            normal:
              show: labelShowFlag,
              position: 'inside'

          type = 'bar' if !type
          legendPosition = "top"
          legendPosition = "bottom" if type.indexOf("LB") >= 0
          legendData = _.uniq _.pluck values, 'name'
          #  xAxisData = _.uniq _.pluck values, 'key'     #不用做去重，x和y要一一对应，会导致某些情况x数据和对应值产生偏差
          xAxisData = _.pluck values, 'key'
          if mutillevelflag
            for i in [0..(xAxisData.length-1)]
              if(i%2 > 0)
                xAxisData[i] = "\n"+xAxisData[i]

          seriesData = _.map legendData, (value) ->
            dataColor = ''
            if value
              if (value.toUpperCase()).indexOf("A") == 0
                dataColor = '#ffeb3b'
              else if (value.toUpperCase()).indexOf("B") == 0
                dataColor = '#4caf50'
              else
                dataColor = '#f44336'

            if mutilcolorflag
              data =
                name: value
                label: labelOption
                data: _.pluck(_.filter(values, (val)->val.name is value and val.type isnt 'markline'), 'value')
                smooth:true
                lineStyle:
                  normal:
                    width: 3,
                    shadowColor: 'rgba(0,0,0,0.4)',
                    shadowBlur: 10,
                    shadowOffsetY: 10
            else
              data =
                name: value
                label: labelOption
                data: _.pluck(_.filter(values, (val)->val.name is value and val.type isnt 'markline'), 'value')
                smooth:true
                lineStyle:
                  normal:
                    width: 3,
                    shadowColor: 'rgba(0,0,0,0.4)',
                    shadowBlur: 10,
                    shadowOffsetY: 10
            if mutilcolorflag
              data.itemStyle = {
                normal:{
      #每个柱子的颜色即为colorList数组里的每一项，如果柱子数目多于colorList的长度，则柱子颜色循环使用该数组
                  color: (params)->
                    colorList = ['#00a856','#C3362F','#324354','#D28367','#93C8AC','#799E82','#CD8620','#BCA29B','#6C5685','#819D48','#9B4441','#406C9B','#E68D39'];
                    return colorList[params.dataIndex%13];
                  lineStyle:{
                    color: defaultColor
                  }
                }
              }
            markLineType = _.findWhere(values, {name:value, type:'markline'})
            if markLineType
              data.markLine =
                data : [
                  {yAxis: parseFloat(markLineType.value), name: '标准线'}
                ]
            valueType = _.pick(_.find(values, (val)->val.name is value and val.type isnt 'markline'), 'type')
            if not _.isEmpty valueType
              data.type = valueType.type
              return data

            if type.indexOf('line') >= 0
              data.type = 'line'
            else if type.indexOf('stack') >= 0
              data.type = 'bar'
              data.stack = 'bar'
            else
              data.type = 'bar'
            if type.indexOf('Smooth') >= 0
              data.smooth = true
            if type.indexOf('Maxmin') >= 0
              data.markPoint =
                data : [
                  {type : 'max', name: '最大值'}
                  {type : 'min', name: '最小值'}
                ]
            if type.indexOf('Avg') >= 0
              data.markLine =
                data : [
                  {type : 'average', name: '平均值'}
                ]
            data


          option =
            color:['#00a856','#C3362F','#324354','#D28367','#93C8AC','#799E82','#CD8620','#BCA29B','#6C5685','#819D48','#9B4441','#406C9B','#E68D39']
            backgroundColor:"rgba(255,255,255,0.0)",
            tooltip:
              trigger: 'axis'
            legend :
              data: legendData
              y: legendPosition
              show:legendShowFlag
              textStyle:
                color: '#9E9E9E'
            toolbox:
              show : toolboxShow,
              x:'right',
              y:'top',
              feature :
                dataView : {show: true, readOnly: false}
                magicType : {show: true, type: ['line', 'bar']}
                restore : {show: true}
                saveAsImage : {show: true}
              orient: 'vertical'
            xAxis : [
              {
                name:xname
                type : 'category'
                data : xAxisData
                axisLine:
                  show:xaxisLineShow
                  lineStyle:
                    color: '#dedede'
                axisLabel:
                  show:axisLabelShow
#                  interval: 0   #横轴信息全部显示
#                  rotate: lbrotate   #度角倾斜显示
                  textStyle:
                    color: '#dedede'
              }
            ]
            yAxis : [
              {
                name:yname
                type : 'value'
                splitLine:         #分隔线
                  show: splitLineShowFlag,     #默认显示，属性show控制显示与否
      #onGap: null,
                  lineStyle:    #属性lineStyle（详见lineStyle）控制线条样式
                    color: ['#dedede'],
                    width: 1,
                    type: 'dashed'
                axisLine:
                  show:yaxisLineShow
                  lineStyle:
                    color: '#dedede'
                axisLabel:
                  show:axisLabelShow
                  interval: 0   #横轴信息全部显示
                  rotate: lbrotate   #度角倾斜显示
                  textStyle:
                    color: '#dedede'
              }]
            dataZoom: [
              {
                type: 'slider',
                height: 20,
                bottom: 4,
                xAxisIndex: 0,
                start: 0,
                end: 100,
                borderColor: '#bfcff3',
                handleIcon: 'M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
                filterMode: 'empty',
                textStyle:
                  color: '#fff'
              },
              {
                type: 'inside',
                xAxisIndex: 0,
                start: 0,
                end: 100,
                filterMode: 'empty'
              }
            ],
            series: seriesData

          if  legendPosition == "bottom"
            option.title = {text: title,textStyle: {color: '#9E9E9E'},x:'center',y:'top',textAlign:'center'} if title
          else
            option.title = {text: title,textStyle: {color: '#9E9E9E'}} if title
          option.xAxis[0].boundaryGap = false if type.indexOf('line') >= 0
          option

      $scope.menuSubscription?.dispose()
      $scope.menuSubscription = @commonService.subscribeEventBus 'menu-collapsed',(d)=>
#        console.log "----曲线-订阅菜单切换--"
        setTimeout ()=>
          $scope.mychart?.resize()
        ,500

    resize: ($scope)->
      $scope.mychart?.resize()

    dispose: ($scope)->
      $scope.mychart?.dispose()
      $scope.mychart = null
      $scope.menuSubscription?.dispose()


  exports =
    BarOrLineDirective: BarOrLineDirective