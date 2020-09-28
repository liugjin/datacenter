###
* File: custom-label-location-directive
* User: David
* Date: 2020/04/24
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","rx"], (base, css, view, _, moment,Rx) ->
  class CustomLabelLocationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "custom-label-location"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      console.log("scope",scope.station)
      @token = scope.controller.$rootScope.user.token   # 调用restful API 保存设备时用
      @userId = scope.project.model.user
      @projectId = scope.project.model.project
      @host = @$window.origin
      @Rx = new Rx.Subject
      @Rx.debounce(100).subscribe(() =>
        @display("保存成功")
      )
      scope.equips = []
      scope.equipSubscription = {}
      scope.x = 0;
      scope.y = 0;
      scope.l = 0;
      scope.t = 0;
      scope.isDown = false;
      scope.editStatus = false
      # 获取ul元素的宽和高
      console.log("321",$(element).find(".humiture-box"))
      scope.ulWidth = $(element).find(".humiture-box").width()
      scope.ulHeight = $(element).find(".humiture-box").height() 
      scope.box = null
      scope.equip = null
      scope.editName = "编辑"
      @getSensor(scope)
      # 编辑
      scope.edit = ()=>
        scope.editStatus = !scope.editStatus
        if(!scope.editStatus)
          scope.editName = "编辑"
          scope.isDown = false
          console.log 'scope.equips',scope.equips
          @baocun(scope)
        else
          scope.editName = "保存"
      # 鼠标按下
      scope.mouseDown= (e,index) =>
        scope.label =  $(element).find(".humiture-label")
        scope.liWidth = scope.label.width()
        scope.liHeight = scope.label.height()
        #获取x坐标和y坐标
        scope.x = e.clientX;
        scope.y = e.clientY;
        scope.box = scope.label[index]
        scope.box.style.cursor = 'move'
        #获取左部和顶部的偏移量
        scope.l = scope.box.offsetLeft;
        scope.t = scope.box.offsetTop;
        #开关打开
        if(scope.editStatus)
          scope.isDown = true;
      # 鼠标抬起 设置对应的位置
      scope.mouseup=(index,equip)=>
        scope.isDown = false;
        scope.box.style.cursor = "pointer"
        scope.equip = equip
        event = scope.project.getIds()
        key = "#{event.user}.#{event.project}.#{scope.station.model.station}.#{scope.equip.model.equipment}.position"
        _.each scope.equip.properties.items, (properties) =>
          if(properties.key == key)
            properties.value = scope.box.style.cssText
      #鼠标移动
      scope.mousemove=(e)=>
        if (!scope.isDown)
          return;
        #获取x和y
        nx = e.clientX;
        ny = e.clientY;
        #计算移动后的左偏移量和顶部的偏移量
        nl = nx - (scope.x - scope.l);
        nt = ny - (scope.y - scope.t);
        # 对移动范围进行限制
        width = scope.ulWidth - 34
        height = scope.ulHeight - scope.liHeight - 20
        if(nl <= 0)
          scope.box.style.left = 10 + 'px';
        else if(nl >= width)
          scope.box.style.left = width + 'px';
        else if(nl > 0 and nl < width)
          scope.box.style.left = nl + 'px';

        if(nt <= 0 )
          scope.box.style.top = 10 + 'px';
        else if(nt >= height)
          scope.box.style.top = height + 'px';
        else if(nt > 0 and nt < height)
          scope.box.style.top = nt + 'px';

    # 获取温湿度传感器的集合
    getSensor:(scope)=>
      @commonService.loadEquipmentsByType scope.station, "environmental", (err, equips) =>
        if(equips and equips.length>0)
          _.each equips, (equip) =>
            @loadProperties(scope,equip)

    #获取设备属性
    loadProperties:(scope,equip)=>
      event = scope.project.getIds()
      key = "#{event.user}.#{event.project}.#{scope.station.model.station}.#{equip.model.equipment}.position"
      equip.loadProperties null, (err, data)=>
        _.each data, (properties) =>
          if(properties.key == key and properties.model.template =="temperature_humidity_template")
            scope.equips.push(equip)
            @loadSignals(scope,equip)
            equip.model.position = properties.value
      ,true
    #获取信号列表
    loadSignals:(scope,equip)=>
      equip.loadSignals null,(err,signals)=>
        if(signals and signals.length>0)
          _.each signals, (signal) =>
            if(signal.model.signal == "temperature") #温度
              @getDeviceSpecialSignal(scope,equip,signal)
            if(signal.model.signal == "humidity") #湿度
              @getDeviceSpecialSignal(scope,equip,signal)
    # 订阅各设备的信号
    getDeviceSpecialSignal:(scope,equip,sig)=>
      filter =
        user: scope.project.model.user
        project: scope.project.model.project
        station: scope.station.model.station
        equipment: equip.model.equipment
        signal: sig.model.signal
      scope.equipSubscription[equip.model.equipment+"."+sig.model.signal]?.dispose()
      scope.equipSubscription[equip.model.equipment+"."+sig.model.signal] = @commonService.signalLiveSession.subscribeValues filter, (err,signal) =>
        if signal and signal.message
          sig?.setValue signal.message
          if(equip.model.equipment == signal.message.equipment)
            equip.model[signal.message.signal] = signal.message.value
    #保存
    baocun:(scope)=>
      _.each scope.equips, (equip) =>
#        equip.save (err, model) =>
#          console.log("model",model)
        #  改用查数据库数据并修改数据库设备表的方式 修复equip.save方法多次弹出保存成功的问题。
        key = "#{@userId}.#{@projectId}.#{equip.model.station}.#{equip.model.equipment}.position"
        newLocation = _.find equip.properties.items,(item)-> item.key == key
        # console.log("newLocation",newLocation)
        @commonService.modelEngine.modelManager.$http.get(
          "#{@host}/model/clc/api/v1/equipments/#{@userId}/#{@projectId}/#{equip.model.station}/#{equip.model.equipment}?token=#{@token}",).then((res) =>
#          console.log '---查询设备---',res
          equipment = res.data
          locationProperty = _.find equipment.properties,(item)->item.id == 'position'
          if _.isEmpty(locationProperty)   #新添加的设备properties为空需push position对象否则保存失败
            equipment.properties.push({ id:"position",value: newLocation.value})
          else
            locationProperty?.value = newLocation.value     # 将修改后的位置属性值 给到数据库查出的设备对象
            
          postObj = {
            _id: equip.model._id
            token: @token
            properties: equipment.properties
          }
          @commonService.modelEngine.modelManager.$http.post(
            "#{@host}/model/clc/api/v1/equipments/#{@userId}/#{@projectId}/#{equip.model.station}/#{equip.model.equipment}",
            postObj).then((res) =>
#            console.log '---修改设备---',res
            @Rx.onNext()
          )
        )
    resize: (scope)->

    dispose: (scope)->
      _.map scope.equipSubscription, (value, key) =>
        value?.dispose()

  exports =
    CustomLabelLocationDirective: CustomLabelLocationDirective