###
* File: reporting-asset-directive
* User: bingo
* Date: 2018/11/22
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ReportingAssetDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "reporting-asset"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      $scope.headers = [
        {headerName:"站点名称", field: 'stationName'}
        {headerName:"设备名称", field: 'equipmentName'}
        {headerName:"设备类型", field: 'typeName'}
        {headerName:"厂商", field: 'vendorName'}
        {headerName:"设备型号", field: 'templateName'}
        {headerName:"资产编码", field: 'assetId'}
        {headerName:"出厂编号", field: 'productNo'}
        {headerName:"资产归属", field: 'owner'}
        {headerName:"生产日期", field: 'productDate'}
        {headerName:"购买日期", field: 'buyDate'}
        #{headerName:"安装位置", field: 'location'}
        {headerName:"安装日期", field: 'installDate'}
        {headerName:"保修期(月)", field: 'guarantee'}
        {headerName:"寿命(月)", field: 'life'}
        #{headerName:"维修次数", field: 'guaranteeTimes'}
        {headerName:"保修状态",field:'guaranteeStatus'}
        {headerName:"使用状态",field:'status'}
        {headerName:"管理员", field: 'owner'}
      ]
      $scope.data = []
      equipments = []
      $scope.stations = []
      $scope.selectedStations = []

      stations = _.filter $scope.project.stations.items, (item)=>item.model.station.charAt(0) isnt "_"
      for item in stations
        station = item
        singleData = {
          id: item.model.station
          name: item.model.name
          checked: true
        }
        $scope.stations.push singleData
        $scope.selectedStations.push station.model.station
        station.loadEquipments null, null, (err, equips)=>
          return if err or equips.length is 0
          equipments = equipments.concat equips
          for equip in equips
            equip.loadProperties()
      $scope.userMsg=[]
      # 加载所有的用户
      $scope.loadAllUsers = () =>
        userService = @commonService.modelEngine.modelManager.getService 'users'
        filter = {}
        fields = null
        userService.query filter, fields, (err, data) =>
          if not err
            $scope.userMsg = data
      $scope.loadAllUsers()
      $scope.equipmentTypes = []
      $scope.selectedTypes=[]
      for equipTypeItem in $scope.project.dictionary.equipmenttypes.items
        if equipTypeItem.model.type.indexOf("_") != 0 and equipTypeItem.model.base
          singleData = {
            id: equipTypeItem.model.type
            name: equipTypeItem.model.name
            checked: true
          }
          $scope.equipmentTypes.push singleData
          $scope.selectedTypes.push equipTypeItem.model.type

      $scope.vendors = []
      $scope.selectedVendors=[]
      for vendorItem in $scope.project.dictionary.vendors.items
        singleData = {
          id: vendorItem.model.vendor
          name: vendorItem.model.name
          checked: true
        }
        $scope.vendors.push singleData
        $scope.selectedVendors.push vendorItem.model.vendor

      $scope.selectedGuaranteeStatus = ["true", "false", "unknown"]
      $scope.guaranteeStatus = [
        {id: 'true', name: '保修中', checked: true}
        {id: 'false', name: '已过保', checked: true}
        {id: 'unknown', name: '未知', checked: true}
      ]

      initProperty = (callback)=>
        $scope.project.loadEquipmentTemplates {template: 'facility_base'}, 'user project type vendor template name base index image', (err, result)=>
          return if not result
          result[0].loadProperties null, (err, properties)=>
            status = _.find properties, (sig)->sig.model.property is 'status'
            arrStatus = status?.model.format.split(',')
            callback? arrStatus

      initProperty (arrStatus)=>
        return if not arrStatus
        $scope.selectedUsageStatus = []
        $scope.usageStatus = []
        for arr in arrStatus
          item =
            id: arr.split(':')[0]
            name: arr.split(':')[1]
            checked: true
          $scope.selectedUsageStatus.push arr.split(':')[0]
          $scope.usageStatus.push item

      $scope.subscribe?.dispose()
      $scope.subscribe = @subscribeEventBus "drop-down-select", (d) =>
        msg = d.message
        if msg.origin is "station"
          $scope.selectedStations = msg.selected
        if msg.origin is "type"
          $scope.selectedTypes = msg.selected
        if msg.origin is "vendor"
          $scope.selectedVendors = msg.selected
        if msg.origin is "guarantee"
          $scope.selectedGuaranteeStatus = msg.selected
        if msg.origin is "usage"
          $scope.selectedUsageStatus = msg.selected

      $scope.queryData = ()=>
        $scope.data = []
        assetData = []
        _.each equipments, (equip)=>
          #bugDate为购买日期  guarantee为保修月数  maintenance为维保记录  guaranteeFlag维保标记
          equip.model.buyDate = equip.getPropertyValue("buy-date")
          equip.model.productionDate = equip.getPropertyValue("production-time")
          equip.model.guarantte = equip.getPropertyValue("guarantee-month")
          equip.model.life = equip.getPropertyValue("life")
          #equip.model.maintenance = equip.getPropertyValue "maintenance"
          equip.model.guaranteeFlag = "unknown"
          if equip.model.productionDate and equip.model.guarantte
            equip.model.guaranteeFlag = (moment().diff(moment(equip.model.productionDate).add(equip.model.guarantte, 'months'), 'days')<= 0).toString()
          usage = _.find $scope.usageStatus, (status)=>status.id is equip.getPropertyValue('status')
          equip.model.usageFlag = usage?.id || 'unknown'

        filterData = _.filter equipments, (equip) =>
          equip.model.station in $scope.selectedStations and equip.model.type in $scope.selectedTypes and equip.model.vendor in $scope.selectedVendors and equip.model.guaranteeFlag in $scope.selectedGuaranteeStatus and equip.model.usageFlag in $scope.selectedUsageStatus

        for equip in filterData
          abc=(_.find $scope.userMsg ,(userobj)=>userobj.user == equip.model.owner)
          item =
            stationName: equip.station.model.name
            equipmentName: equip.model.name
            typeName: (_.find @project.dictionary.equipmenttypes.items, (type)->type.key is equip.model.type)?.model.name
            vendorName: (_.find @project.dictionary.vendors.items, (vendor)->vendor.key is equip.model.vendor)?.model.name
            templateName: (_.find @project.equipmentTemplates.items, (it)->it.model.template is equip.model.template)?.model.name
            assetId: equip.getPropertyValue "asserts-code"
            productDate: if equip.getPropertyValue("production-time") then moment(equip.getPropertyValue("production-time")).format("YYYY-MM-DD")
            productNo: equip.getPropertyValue "production-no"
            buyDate: if equip.model.buyDate then moment(equip.model.buyDate).format("YYYY-MM-DD")
            #location: equip.getPropertyValue "location"
            installDate: if equip.getPropertyValue("install-date") then moment(equip.getPropertyValue("install-date")).format("YYYY-MM-DD")
            guarantee: equip.model.guarantte
            life: equip.model.life
            #guaranteeTimes: equip.model.maintenance?.length ? 0
            guaranteeStatus: (_.find $scope.guaranteeStatus, (status)=>status.id is equip.model.guaranteeFlag)?.name || '未知'
            status: (_.find $scope.usageStatus, (status)=>status.id is equip.model.usageFlag)?.name || '未知'
            owner: abc?.name
          assetData.push item
        $scope.data = assetData

      $scope.exportReport = (header,name)=>
        reportName = name+moment().format("YYYYMMDDHHmmss")+".csv"
        @publishEventBus "export-report", {header: header, name: reportName}


    resize: ($scope)->

    dispose: ($scope)->
      $scope.subscribe?.dispose()


  exports =
    ReportingAssetDirective: ReportingAssetDirective