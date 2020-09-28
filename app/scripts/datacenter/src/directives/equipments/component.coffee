###
* File: equipments-directive
* User: David
* Date: 2020/03/26
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class EquipmentsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipments"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.pageIndex = 1
      scope.pageItems = 12
      scope.elementsArr = []
      scope.ip = @$window.origin
      scope.ports = [
        {value: "/ual/com1", name: "COM1"}
        {value: "/ual/com2", name: "COM2"}
        {value: "/ual/com3", name: "COM3"}
        {value: "/ual/com4", name: "COM4"}
        {value: "di1", name: "DI1"}
        {value: "di2", name: "DI2"}
        {value: "di3", name: "DI3"}
        {value: "di4", name: "DI4"}
        {value: "do1", name: "DO1"}
        {value: "do2", name: "DO2"}
        {value: "do3", name: "DO3"}
        {value: "do4", name: "DO4"}
        {value: "ip", name: "网口"}
      ]
      @commonService.rpcGet "muSetting", null, (err,data)=>
        scope.mu = data?.data?.mu[0]
        scope.elements = data?.data?.elements
      @initEquips scope
      scope.createDevice =(num) =>
        if(num == 1)
          scope.equipment = scope.station.createEquipment()
        if(num ==2)
          scope.fileNameStr = ""
          #获取设备类型
          @getEquipmentType(scope)
        

      # 编辑
      scope.editDevice = (device) =>
        scope.equipment = device
      # 删除
      scope.deleteDevice = (device) =>
        scope.equipment = device
        title = "删除设备确认"
        message = "请确认是否删除设备: #{scope.equipment.model.name}？删除后设备和数据将从系统中移除不可恢复！"
        scope.prompt title, message, (ok) =>
          return if not ok
          scope.equipment.remove (err, model) =>
            @initEquips scope
          for port in scope.mu.ports
            su = _.find port.sampleUnits, (it)->it.id is scope.equipment.model.equipment
            break if su
          if su
            pindex = scope.mu.ports.indexOf port
            sindex = port.sampleUnits.indexOf su
            port.sampleUnits.splice sindex, 1
            scope.mu.ports.splice pindex, 1 if port.sampleUnits.length is 0

          data =
            parameters: [scope.mu]
          @commonService.rpcPost "muSetting", data.parameters, (err, data)=>
            console.log "保存失败:", err if err or not data?.data
            console.log "保存成功" if data?.data is "ok"
      # 保存
      scope.saveDevice = =>
        if not scope.equipment.model.type
          return @display "请选择设备类型"
        if not scope.equipment.model.template
          return @display "请选择设备型号"
        if not scope.equipment.model.name
          return @display "请填入设备名称"
        if not scope.equipment.model.station
          return @display "请选择设备站点"
        if not scope.equipment.model.port
          return @display "请选择设备端口"
        if scope.equipment.model.port
          name = @checkExistSetting scope
          return @display '该设备所设端口号及地址与设备"'+name+'"的配置重复' if name
 
        template = _.find scope.project.equipmentTemplates.items, (item)->item.model.type is scope.equipment.model.type and item.model.template is scope.equipment.model.template
        libraryVersion = ""
        templateSymbol = template.model.symbol ? template.model.desc
        if not scope.equipment.model.equipment
          scope.equipment.model.vendor = template.model.vendor
          id = if scope.equipments.length then (_.max scope.equipments, (item)->item.model._index).model.equipment else "0"
          scope.equipment.model.equipment = @getNextName id

        _.mapObject scope.elements, (ele)=>
          if ele.id == templateSymbol
            libraryVersion = ele.version
            
        desc = {port: scope.equipment.model.port, address: scope.equipment.model.address, parameters: scope.equipment.model.parameters, addr: scope.equipment.model.addr,libraryVersion: libraryVersion,expiryDate:scope.equipment.model.expiryDate}
        scope.equipment.model.desc = JSON.stringify desc

        if scope.mu and scope.equipment.model.port
          suid = if scope.equipment.model.port?.substr(0,1) is "d" then scope.equipment.model.port else scope.equipment.model.equipment
          scope.equipment.sampleUnits = template.model.sampleUnits if _.isEmpty scope.equipment.sampleUnits
          scope.equipment.sampleUnits[0].value = scope.mu.id+"/"+suid
          scope.equipment.sampleUnits[1]?.value = scope.mu.id+"/_"

        if scope.equipment.model.port and  scope.equipment.model.port.substr(0,1) isnt "d"
          return @display "找不到该设备型号对应的协议采集库，无法保存！" if not scope.elements?[template.model.symbol ? template.model.desc]
          sport = {id: scope.equipment.model.equipment, name: scope.equipment.model.name, enable: true, setting: {}, sampleUnits: []}
          sport.protocol = if scope.elements[template.model.symbol ? template.model.desc]?.mappings.length > 1 then "protocol-modbus-serial" else scope.elements[template.model.symbol ? template.model.desc]?.mappings[0].protocol
          if scope.equipment.model.port isnt "ip"
            sport.setting.port = scope.equipment.model.port
            sport.setting.baudRate = parseInt scope.equipment.model.parameters.split(",")[0]
          sport.setting.server = scope.equipment.model.address if scope.equipment.model.port is "ip"

          sunit = {id: scope.equipment.model.equipment, name: scope.equipment.model.name, period: 60000, timeout: 50000, maxCommunicationErrors: 5, enable: true, setting: {} }
          sunit.element = (template.model.symbol ? template.model.desc)+".json"
          sunit.setting.address = parseInt(if scope.equipment.model.port is "ip" then scope.equipment.model.addr else scope.equipment.model.address)
          for port in scope.mu.ports
            su = _.find port.sampleUnits, (it)->it.id is scope.equipment.model.equipment
            break if su
          if su
            pindex = scope.mu.ports.indexOf port
            sindex = port.sampleUnits.indexOf su
            port.sampleUnits.splice sindex, 1
            scope.mu.ports.splice pindex, 1 if port.sampleUnits.length is 0

          sp = _.find scope.mu.ports, (port)->port.setting.port is scope.equipment.model.port or port.setting.server is scope.equipment.model.address
          if sp
            sp.protocol = sport.protocol
            sp.setting = sport.setting
            sp.sampleUnits.push sunit
          else
            sport.sampleUnits.push sunit
            scope.mu.ports.push sport

          data =
            parameters: [scope.mu]
          @commonService.rpcPost "muSetting", data.parameters, (err, data)=>
            console.log "保存失败:", err if err or not data?.data
            console.log "保存成功" if data?.data is "ok"

        
        # @loadProperties(scope,scope.equipment,false)

        scope.equipment.save (err, model) =>
          console.log("model",model)
          if not err
            @initEquips scope
          M.Modal.getInstance($("#device-modal")).close()

      scope.portChange = ->
        if scope.equipment.model.port.substr(0,1) is "/"
          scope.equipment.model.parameters = "9600,n,8,1"
          scope.equipment.model.address = 1
          scope.equipment.model.addr = null
        else if scope.equipment.model.port is "ip"
          scope.equipment.model.parameters = null
          scope.equipment.model.address = "192.168.1.100"
          scope.equipment.model.addr = 1
        else
          scope.equipment.model.parameters = null
          scope.equipment.model.address = null
          scope.equipment.model.addr = null

      scope.filterTypes = ()=>
        (item) ->
          return true if item.model.base
          return false

      scope.filterTemplates = ()=>
        (item) ->
          return true if item.model.type is scope.equipment?.model.type
          return false

      scope.filterEquipmentItem = ()=>
        return if not scope.equipments
        items = []
        items = _.filter scope.equipments, (equipment) =>
          text = scope.search?.toLowerCase()
          if not text
            return true
          if equipment.model.equipment?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.name?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.typeName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.stationName?.toLowerCase().indexOf(text) >= 0
            return true
          if equipment.model.vendorName?.toLowerCase().indexOf(text) >= 0
            return true
          return false
        pageCount = Math.ceil(items.length / scope.pageItems)
        result = {page:1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      scope.limitToEquipment = () =>
        if scope.filterEquipmentItem() and scope.filterEquipmentItem().pageCount is scope.pageIndex
          aa = scope.filterEquipmentItem().items % scope.pageItems;
          result = -(if aa==0 then scope.pageItems else aa)
        else
          result = -scope.pageItems
        result

      scope.selectPage = (page)=>
        scope.pageIndex = page

      # ......设备库安装卸载......
      scope.file= () =>
        scope.fileNameStr = ""
        input = element.find('input[type="file"]')
        input.click()
        input.click(()=>
          input.val('');
        );
        input.on('change', (evt)=>
          file = input[0]?.files?[0]
          scope.fileNameStr = file.name
          evt.target.value = null
          scope.zp = new FormData
          scope.zp.append "file", file
          scope.$applyAsync()
        );

      # 确认上传
      scope.confirmSha =()=>
        url = scope.controller.$location.$$absUrl.substr(0, scope.controller.$location.$$absUrl.indexOf("#"))+"rpc/uploadElement"
        params =
          token: scope.controller.$rootScope.user.token
          parameters:
            token: scope.controller.$rootScope.user.token
            project: scope.project.model.project
            user: scope.project.model.user
            ip: scope.ip
        @commonService.uploadService.$http({method: 'POST', url: url, data: scope.zp, params: params,headers: {'Content-Type': undefined}}).then (res)=>
          if res.data?.data is "ok"
            @display "上传成功"
            @getEquipmentType(scope)
          else
            @display "上传失败"

      # 卸载
      scope.uninstall =(equip)=>
        template = _.find(scope.equipments, (equipment) => equipment.model.template == equip.model.template )
        console.log("template",template)
        return @display "所卸载的设备库下已有设备,请先删除设备后进行卸载！！！" if(template)
        @deleteMoreData(scope,equip,null,false)
        title = "删除设备确认"
        message = "请确认是否删除: #{equip.model.name}？删除后将从数据库移除相关记录，不可恢复。"
        scope.prompt title, message, (ok) =>
          return if not ok
          user = scope.project.model.user
          project = scope.project.model.project
          url = "#{scope.ip}/model/clc/api/v1/equipmenttemplates/#{user}/#{project}/#{equip.model.type}/#{equip.model.template}?token=#{scope.controller.$rootScope.user.token}"
          @httpRequest(url,null,"delete",(res) =>
            if res.data.length > 0
              scope.elementsArr = _.filter(scope.elementsArr, (item)=>
                item.model.template != res.data[0].template
              )
              @setMoreData(scope,equip.signals.items,res.data,"signal","equipmentsignals")#删除信号
              @setMoreData(scope,equip.properties.items,res.data,"property","equipmentproperties") #删除属性
              @setMoreData(scope,equip.events.items,res.data,"event","equipmentevents") #删除事件
              @setMoreData(scope,equip.commands.items,res.data,"command","equipmentcommands")#删除控制
              @setMoreData(scope,equip.ports.items,res.data,"port","equipmentports")#删除端口
              @deleteEquipmenttypes(scope,res.data)
          )
      
    
    # load属性信号事件控制端口
    deleteMoreData:(scope,equip,resData,isdelete)=>
      if(equip)
        equip.loadSignals null, (err, signals) =>
          scope.signals = signals
        equip.loadEvents null,(err,event)=>
          scope.event = event
        equip.loadProperties null,(err,properties)=>
          scope.properties = properties
        equip.loadCommands null,(err,command)=>
          scope.command = command
        equip.loadPorts null,(err,ports)=>
          scope.ports = ports
        

    # 设置删除数据的url格式
    setMoreData:(scope,moreData,resData,typeData,urlType)=>
      parameter = {
        items:[]
        token:scope.controller.$rootScope.user.token
      }
      if moreData.length>0
        _.each moreData, (item) =>
          item.model._removed = true
          parameter.items.push(item.model)
        user = scope.project.model.user
        project = scope.project.model.project
        url = "#{scope.ip}/model/clc/api/v1/#{urlType}/#{user}/#{project}/#{resData[0].type}/#{resData[0].template}/_batch"
        @httpRequest(url,parameter,"put",(res) =>
        )

    #删除设备类型
    deleteEquipmenttypes:(scope,resData)=>
      scope.project.loadEquipmentTemplates {type: resData[0].type}, null, (err, templates) =>
        if templates.length == 0
          user = scope.project.model.user
          project = scope.project.model.project
          url = "#{scope.ip}/model/clc/api/v1/equipmenttypes/#{user}/#{project}/#{resData[0].type}/?token=#{scope.controller.$rootScope.user.token}"
          @httpRequest(url,null,"delete",(res) =>
            scope.project.loadTypeModel "equipmenttypes",null,(err, data)=>
              console.log("err",err)
            ,true
          )
      ,true
      
    # http请求
    httpRequest:(url,parameter,type,callback)=>
      @commonService.modelEngine.modelManager.$http[type](url,parameter).then((res)=>
        callback?res
      )
    # 获取设备类型
    getEquipmentType:(scope)=>
      # 获取设备类型保证项目是最新的设备类型
      scope.project.loadTypeModel "equipmenttypes",null,(err, data)=>
        console.log("err",err)
      ,true
      # 获取设备模板
      scope.project.loadEquipmentTemplates null, null, (err, tmps) =>
        scope.elementsArr.splice(0,scope.elementsArr.length)
        equipmenttypes = scope.project.typeModels.equipmenttypes.items
        _.each tmps, (template) =>
          _.each equipmenttypes, (item) =>
            if item.model.base and template.model.type is item?.model.type
              template.model.typeName = item.model.name
              symbol = template.model.symbol ? template.model.desc
              if(symbol)
                _.mapObject scope.elements, (ele)=>
                  if ele.id == symbol
                    template.model.libraryVersion = ele.version
                    template.model.description = ele.description
              if template.model.visible
                scope.elementsArr.push(template)
      ,true
      scope.$applyAsync()

    checkExistSetting: (scope) =>
      equip = _.find scope.equipments, (item)->item.model.port is scope.equipment.model.port and item.model.address?.toString() is scope.equipment.model.address?.toString() and (item.model.addr ? "") is (scope.equipment.model.addr ? "") and item.model.equipment isnt scope.equipment.model.equipment
      equip?.model.name

    initEquips: (scope) =>
      scope.equipments = []
      scope.project.loadEquipmentTemplates null, null, (err, tps) =>
        for station in scope.project.stations.nitems
          station.loadEquipments null, null, (err, equips) =>
            equips = _.filter equips, (equip)->equip.model.type.substr(0,1)!="_" and equip.model.template.substr(0,1)!="_" and equip.model.equipment.substr(0,1)!="_"
            for equip in equips
              # @loadProperties(scope,equip,true)
              equip.model.typeName = (_.find scope.project.dictionary.equipmenttypes.items, (type)=>type.key is equip.model.type)?.model.name
              equip.model.templateName = (_.find scope.project.equipmentTemplates.items, (template)=>template.model.type is equip.model.type and template.model.template is equip.model.template)?.model.name
              equip.model.vendorName = (_.find scope.project.dictionary.vendors.items, (vendor)=>vendor.key is equip.model.vendor)?.model.name
              equip.model.stationName = (_.find scope.project.stations.items, (station)=>station.model.station is equip.model.station)?.model.name
              desc = equip.model.desc
              fields = ["port","address","parameters","addr","expiryDate","libraryVersion"]
              if desc and desc.substr(0,1) is "{" and desc.substr(desc.length-1,1) is "}"
                desc = JSON.parse desc
                _.each fields, (field) =>
                  equip.model[field] = desc[field]
                  if desc.port and desc.port.split("/")[2]
                    equip.model.newport = desc.port.split("/")[2]
                  else 
                    equip.model.newport = desc.port
            scope.equipments = scope.equipments.concat equips if not err
          , true
      , true


    #获取设备属性
    loadProperties:(scope,equip,d)=>
      event = scope.project.getIds()
      key = "#{event.user}.#{event.project}.#{scope.station.model.station}.#{equip.model.equipment}.expiry-date"
      equip.loadProperties null, (err, data)=>
        _.each data, (properties) =>
          console.log("properties",properties)
          if(properties.key == key)
            if(d)
              equip.model.expiryDate = properties.value
            else
              properties.value = equip.model.expiryDate

    getNextName: (name, defaultName="") =>
      return defaultName if not name
      name2 = name.replace /(\d*$)/, (m, p1) ->
        num = if p1 then parseInt(p1) + 1 else '-0'
      return name2

    resize: (scope)->

    dispose: (scope)->


  exports =
    EquipmentsDirective: EquipmentsDirective