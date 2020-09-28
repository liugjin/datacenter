###
* File: room-3d-component2-directive
* User: David
* Date: 2019/07/10
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "./building", "./tooltip"], (base, css, view, _, build, tooltip) ->
  class Room3dComponent2Directive extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "room-3d-component2"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
# loading加载条
      scope.showProcess = false
      scope.processStyle = { left: "-100%" }

      # 储存所有要展示的信号
      scope.signalGroup = {}

      # 设备id和3d定位的互相映射
      scope.equipMap = {}
      scope.posMap = {}

      # 详情框內部信号订阅
      scope.detailSubs = {}
      scope.detailData = []
      scope.detailSignal = {}

      # 悬浮框內部信号订阅
      scope.databoxSubs = {}
      scope.databoxData = []
      scope.databoxSignal = {}

      # 设备状态订阅
      scope.stateSubs = {}
      scope.stateData = []


      # 获取信号单位
      if !scope.signalUnitMap
        scope.signalUnitMap = {}
        _.each(scope.project.dictionary.signaltypes.items, (item) => scope.signalUnitMap[item.model.type] = item.model.unit)

      # 鼠标 - detail - 点击事件
      $(element.find(".canvas-div")[0]).click((event) =>
        return if _.isEmpty(scope.posMap) or scope.building.checkList.length == 0
        position = scope.building.getObjByMouse(event)
        if _.has(scope.posMap, position)
          showDetail(scope.posMap[position])
      )

      # 鼠标 - tooltip - mouseover
      $(element.find(".canvas-div")[0]).mousemove((event) =>
        return if _.isEmpty(scope.posMap) or scope.building.checkList.length == 0
        position = scope.building.getObjByMouse(event)
        if _.has(scope.posMap, position)
          scope.tooltip.show(scope.posMap[position], event)
        else
          scope.tooltip.hide()
      )

      # 鼠标 - tooltip - mouseout
      $(element.find(".canvas-div")[0]).mouseout((event) =>
        return if _.isEmpty(scope.posMap) or scope.building.checkList.length == 0
        scope.tooltip.hide()
      )

      # detail - 关闭信号弹框 signalDetail
      scope.closeDetail = (d) => (
        scope.detailData = _.filter(scope.detailData, (item) => item.equipment != d.equipment)
        scope.$applyAsync()
      )

      # icon - 旋转切换
      scope.rotateRoom = () => (
        return if _.isEmpty(scope.posMap) or scope.building.checkList.length == 0
        scope.building.rotate()
      )

      # databox - 设置悬浮的信号的订阅
      setBoxSubs = (data) => (
        _.map(scope.databoxSubs, (sub) => sub.dispose())

        filter = scope.station.getIds()
        _.each(data, (item) =>
          boxs = scope.signalGroup[item.template].box
          _.map(boxs, (sig) =>
            filter.equipment = item.equipment
            filter.signal = sig.signal
            key = item.equipment + "_" + sig.signal
            scope.databoxSubs[key] = @commonService.signalLiveSession.subscribeValues(filter, (err, signal) =>
              return console.error("信号报错: " + err) if err
              msg = signal.message
              scope.databoxSignal[msg.equipment] = {} if !_.has(scope.databoxSignal, msg.equipment)
              if typeof(msg.value) == "number" && !_.isNaN(msg.value)
                scope.databoxSignal[msg.equipment][msg.signal] = msg.value.toFixed(2)
              else
                scope.databoxSignal[msg.equipment][msg.signal] = "--"
              scope.$applyAsync()
            )
          )
        )
      )

      # databox - 展示要悬浮的信号
      showDataBox = () => (
        scope.databoxData = _.filter(_.map(scope.equipMap, (item, index) =>
          item.sigs = scope.signalGroup[item.template].box
          item.style = {}
          if item.sigs.length > 0
            mouse = scope.building.getScreenByObj(item.position)
            item.style = {
              "margin-top": mouse.y.toFixed(0) + 'px',
              "margin-left": mouse.x.toFixed(0) + 'px'
            }
          return item
        ), (p) -> p.sigs.length > 0)
        if scope.databoxData.length > 0
          setBoxSubs(scope.databoxData)
          window.clearInterval(scope.interval) if scope.interval
          scope.interval = window.setInterval(() =>
            scope.databoxData = _.map(scope.databoxData, (item) =>
              mouse = scope.building.getScreenByObj(item.position)
              item.style = "margin-top:" + mouse.y.toFixed(0) + "px; margin-left:" + mouse.x.toFixed(0) + "px;"
              return item
            )
            scope.$applyAsync()
          , 500)
      )

      # detail - 设置详情框内信号的订阅
      setDetailSubs = (data) => (
        _.map(scope.detailSubs, (sub) => sub.dispose())

        filter = scope.station.getIds()
        _.each(data, (item) =>
          details = scope.signalGroup[item.template].detail
          _.map(details, (sig) =>
            filter.equipment = item.equipment
            filter.signal = sig.signal
            key = item.equipment + "_" + sig.signal
            scope.detailSubs[key] = @commonService.signalLiveSession.subscribeValues(filter, (err, signal) =>
              return console.error("信号报错: " + err) if err
              msg = signal.message
              scope.detailSignal[msg.equipment] = {} if !_.has(scope.detailSignal, msg.equipment)
              if typeof(msg.value) == "number" && !_.isNaN(msg.value)
                scope.detailSignal[msg.equipment][msg.signal] = msg.value.toFixed(2)
              else
                scope.detailSignal[msg.equipment][msg.signal] = "--"
              scope.$applyAsync()
            )
          )
        )
      )

      # detail - 展示详情弹框
      showDetail = (data) => (
        setDetailSubs(data)
        scope.detailData = _.map(data, (item, index) =>
          item.sigs = scope.signalGroup[item.template].detail
          item.style = {
            "margin-top": (50 + 170 * index) + 'px',
            "margin-left": "#{scope.building.width - 200}px"
          }
          return item
        )
        scope.$applyAsync()
      )

      # state - 设置设备状态的订阅
      setStateSubs = (data) => (
        _.map(scope.stateSubs, (sub) => sub.dispose())
        filter = scope.station.getIds()
        _.each(data, (d) =>
          filter.equipment = d.equipment
          filter.signal = d.signal.signal
          key = filter.equipment + "_" + filter.signal
          scope.stateSubs[key] = @commonService.signalLiveSession.subscribeValues(filter, (err, signal) =>
            return console.error("信号报错: " + err) if err
            pos = scope.equipMap[signal.message.equipment].position
            scope.building.updateState(pos, signal.message.value)
          )
        )
      )

      # state - 状态与信号相绑定
      updateEquipState = () => (
        scope.stateData = _.filter(_.map(scope.equipMap, (item, index) =>
          if scope.signalGroup[item.template].state.length > 0
            item.signal = scope.signalGroup[item.template].state[0]
          else
            item.signal = false
          return item
        ), (p) -> p.signal)
        setStateSubs(scope.stateData)
      )

      # 处理设备, 查询所有有可能要显示的信号
      setEquipments = (equipments) => (
        groups = _.groupBy(equipments, (d) -> d.model.template)
        groupSize = _.map(groups, (d) -> d).length
        signalGroup = {}
        _.mapObject(groups, (d, key) =>
          signalGroup[key] = {}
          d[0].loadSignals(null, (err, signals) =>
            groupSize--
            signalGroup[key].detail = _.map(_.filter(signals, (sig) -> sig.model.group is '3d-detail'), (d) => {
              signal: d.model.signal,
              name: d.model.name,
              unit: scope.signalUnitMap[d.model.unit]
            })
            signalGroup[key].state = _.map(_.filter(signals, (sig) -> sig.model.group is '3d-state'), (d) => {
              signal: d.model.signal,
              name: d.model.name,
              unit: scope.signalUnitMap[d.model.unit]
            })
            signalGroup[key].box = _.map(_.sortBy(_.filter(signals, (sig) -> sig.model.group is '3d-data-box'), (d) -> d.model.index), (p) => {
              signal: p.model.signal,
              name: p.model.name,
              unit: scope.signalUnitMap[p.model.unit]
            })
            if groupSize == 0
              scope.signalGroup = signalGroup
              # 避免scene没有加载完
              @$timeout(() =>
                showDataBox()
                updateEquipState()
              , 1000)
          )
        )
      )

      # 加载所有设备
      loadEquipment = () => (
        scope.station.loadEquipments({}, null, (err, equipments) =>
          equips = []
          equipMap = {}
          count = equipments.length
          _.each(equipments, (equip) => (
            count--
            pos = equip.getPropertyValue("3d-position")
            if pos
              equips.push(equip)
              equipMap[equip.model.equipment] = {
                equipment: equip.model.equipment,
                name: equip.model.name,
                position: pos,
                template: equip.model.template
              }
            if count == 0
              scope.equipMap = equipMap
              scope.posMap = _.groupBy(_.map(scope.equipMap, (d) -> d), (item) -> item.position)
              setEquipments(equips)
          ))
        )
      )

      # 站点初始化
      if !scope.building
        scope.building = new build.Building(element, ".canvas-div")
        scope.tooltip = new tooltip.ToolTip(element)

      # 3d加载
      if scope.station.model?.d3
        scope.building.loadScene(scope.station.model.d3, (resp) =>
          if typeof(resp) == "number"
            scope.showProcess = true
            scope.processStyle = { left: "-#{100 - resp}%" }
            if resp == 100
              scope.showProcess = false
            scope.$applyAsync()
          else
            loadEquipment()
        )
      else
        window.clearInterval(scope.interval)
        _.each(scope.detailSubs, (sub) => sub.dispose())
        _.each(scope.stateSubs, (sub) => sub.dispose())
        _.each(scope.databoxSubs, (sub) => sub.dispose())
        @display("该站点没有配置模型!!", 500)

    resize: (scope) -> (
      scope.building.resize()
    )

    dispose: (scope) -> (
      window.clearInterval(scope.interval)
      _.each(scope.detailSubs, (sub) => sub.dispose())
      _.each(scope.stateSubs, (sub) => sub.dispose())
      _.each(scope.databoxSubs, (sub) => sub.dispose())
      scope.equipMap = {}
      scope.posMap = {}
      scope.building.dispose() if scope.building
    )

  exports = Room3dComponent2Directive: Room3dComponent2Directive