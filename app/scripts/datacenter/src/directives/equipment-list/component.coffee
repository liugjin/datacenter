###
* File: equipment-list-directive
* User: David
* Date: 2020/05/21
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","angularGrid"], (base, css, view, _, moment,agGrid) ->
  class EquipmentListDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "equipment-list"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.deviceData = []
      scope.header = [
        {headerName:"设备ID", field: 'equipment'},
        {headerName:"设备名称", field: 'name',},
        {headerName:"设备类型", field: 'typeName'},
        {headerName:"设备地址", field: 'address'}
        {headerName:"端口号", field: 'newport'}
        {headerName:"通讯参数", field: 'parameters'}
        {headerName:"设备型号", field: 'templateName'}
        {headerName:"设备库版本", field: 'libraryVersion'}
        {headerName:"设备厂商", field: 'vendorName'}
        {headerName:"资产归属", field: 'user'}
        {headerName:"过保日期", field: 'expiryDate'}
        {headerName:"上线日期", field: 'createtime'}
      ]
      scope.equipments = []
      scope.project.loadEquipmentTemplates null, null, (err, tps) =>
        for station in scope.project.stations.nitems
          station.loadEquipments null, null, (err, equips) =>
            equips = _.filter equips, (equip)->equip.model.type.substr(0,1)!="_" and equip.model.template.substr(0,1)!="_" and equip.model.equipment.substr(0,1)!="_"
            for equip in equips
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
            @setData(scope)
          , true
      , true
      @exportReport(scope,element)
    # 导出
    exportReport:(scope,element)=>
        scope.gridOptions =
          columnDefs: scope.header
          rowData: null
          enableFilter: true
          enableSorting: true
          enableColResize: true
          overlayNoRowsTemplate: " "
          headerHeight:41
          rowHeight: 61
        console.log("1234",element.find("#grid")[0])
        new agGrid.Grid element.find("#grid")[0], scope.gridOptions
        scope.exportReport=(name)=>
          nowDate = moment(new Date()).format("YYYY-MM-DD")
          return if not scope.gridOptions
          reportName = "#{name}(#{nowDate}).csv"
          scope.gridOptions.api.exportDataAsCsv({fileName:reportName, allColumns: true, skipGroups:true})

    # 导出表格填写查询到的内容并设置页面内容
    setData:(scope)=>
      scope.deviceData.splice(0,scope.deviceData.length)
      return if not scope.gridOptions
      _.each scope.equipments, (item) =>
        value = {equipment:null,name:null,typeName:null,address:null,newport:null,parameters:null,templateName:null,libraryVersion:null,vendorName:null,user:null,expiryDate:null,createtime:null}
        value.equipment = item.model.equipment
        value.name = item.model.name
        value.typeName = item.model.typeName
        value.address = item.model.address
        value.newport = item.model.newport
        value.parameters = item.model.parameters
        value.templateName = item.model.templateName
        value.libraryVersion = item.model.libraryVersion
        value.vendorName = item.model.vendorName
        value.user = item.model.user
        value.expiryDate = item.model.expiryDate
        value.createtime = item.model.createtime
        scope.deviceData.push (value)
      scope.gridOptions.api.setRowData scope.deviceData
    resize: (scope)->

    dispose: (scope)->


  exports =
    EquipmentListDirective: EquipmentListDirective