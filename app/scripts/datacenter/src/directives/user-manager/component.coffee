###
* File: user-manager-directive
* User: bingo
* Date: 2019/03/29
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class UserManagerDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "user-manager"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      element.css("display", "block")
      preview = element.find('.img-preview')
      input = element.find('input[type="file"]')
      $scope.setting = setting
      $scope.dir = setting.urls.uploadUrl
      $scope.addImg = @getComponentPath('image/add.svg')
      $scope.deleteImg = @getComponentPath('image/delete.svg')
      $scope.editImg = @getComponentPath('image/edit.svg')
      $scope.closeImg = @getComponentPath('image/close.svg')
      $scope.refreshImg = @getComponentPath('image/refresh.svg')
      $scope.saveImg = @getComponentPath('image/save.svg')
      $scope.uploadImg = @getComponentPath('image/upload.svg')
      $scope.linkImg = @getComponentPath('image/link.svg')
      $scope.downImg = @getComponentPath('image/download.svg')
      $scope.peopleEquips = []
      $scope.pageIndex = 1
      $scope.pageItems = 10
      $scope.accept = "image/*"
      $scope.showLink = false
      $scope.select = false
      selectEquips = []
      #获取所有设备厂商
      $scope.vendor = "hikvision"      #厂商ID 初始化取海康
      $scope.manufactorArr = []
      $scope.manufacturer = $scope.project.typeModels.vendors.items
      for value in $scope.manufacturer
        $scope.manufactorObj = {name:null,vendor:null}
        $scope.manufactorObj.name = value.model.name
        $scope.manufactorObj.vendor = value.model.vendor
        $scope.manufactorArr.push $scope.manufactorObj
      $scope.project.loadEquipmentTemplates {template: "people_template"}, 'user project type vendor template name base index image', (err, templates) =>
        return if err or templates.length < 1
        $scope.vendor = templates[0].model.vendor
        templates[0].loadProperties null, (err, properties) =>
          return if err or properties.length < 1
          $scope.properties = properties

      preview.bind 'click', ()=>
        input.click()

      input.bind 'change', (evt) =>
        if @commonService.uploadService
          uploadImage input[0]?.files?[0]
        evt.target.value = null
        return

      # 上传图片
      uploadImage = (file) =>
        return if not file
        # upload image
        url = "#{$scope.dir}/#{file.name}"
        # give filename then resource service doesn't append timestamp to file name
        @commonService.uploadService.upload file, $scope.filename, url, (err, resource) ->
          if err
            console.log err
          else
            # add a random number to enforce to refresh
            $scope.currentPeople.peopleImg = "#{resource.resource}#{resource.extension}?#{new Date().getTime()}"
        , (progress) ->
          $scope.progress = progress * 100
        return

      # 删除图片
      $scope.delete = () =>
        $scope.currentPeople.peopleImg = ""
        return

      # 加载指定模板的设备
      loadEquipsByTemplate = (refresh) =>
        $scope.peopleEquips = []
        _.each $scope.stations, (station) =>
          @commonService.loadEquipmentsByTemplate station, "people_template", (err, equips) =>
            _.map equips, (equip) =>
              equip.checked = false
              equip.loadProperties()
            $scope.peopleEquips = $scope.peopleEquips.concat(equips)
          , refresh

      # 加载项目站点
      $scope.stations = @commonService.loadStationChildren $scope.station, true
      loadEquipsByTemplate()

      # 选择页数
      $scope.selectPage = (page) =>
        $scope.pageIndex = page

      # 对设备进行分页设置
      $scope.filterEquipmentItem = ()=>
        return if not $scope.peopleEquips
        items = []
        items = _.filter $scope.peopleEquips, (equip) =>
          text = $scope.search?.toLowerCase()
          if not text
            return true
          return false
        pageCount = Math.ceil(items.length/$scope.pageItems)
        result = {page:1, pageCount: pageCount , pages:[1 .. pageCount], items: items.length}
        result

      # 限制每页的个数
      $scope.limitToEquipment = () =>
        if $scope.filterEquipmentItem() and $scope.filterEquipmentItem().pageCount is $scope.pageIndex
          aa = $scope.filterEquipmentItem().items % $scope.pageItems;
          result = -(if aa==0 then $scope.pageItems else aa)
        else
          result = -$scope.pageItems
        result

      # 格式化数据
      $scope.formatValue = (propertyId, value) =>
        val = ''
        property = _.find $scope.properties, (property) => property.model.property is propertyId
        if property
          arr = property.model.format.split(',')
          for i in arr
            if i.split(':')[0] == value
              val = i.split(':')[1]
        return val

      # 全选
      $scope.selectAll = () =>
        if $scope.select
          _.each $scope.peopleEquips, (equip) =>
            equip.checked = true
            selectEquips.push equip.model.equipment
        else
          _.each $scope.peopleEquips, (equip) =>
            equip.checked = false
            selectEquips = []
        selectEquips = _.uniq selectEquips

      # 单选
      $scope.selectOne = () =>
        _.each $scope.peopleEquips, (equip) =>
          index = _.indexOf selectEquips, equip.model.equipment
          if equip.checked and index is -1
            selectEquips.push equip.model.equipment
          else if not equip.checked and index isnt -1
            selectEquips.splice(index, 1)
        if $scope.peopleEquips.length is selectEquips.length
          $scope.select = true
        else
          $scope.select = false
        selectEquips = _.uniq selectEquips

      # 添加设备
      $scope.addEquip = () =>
        $scope.isAdd = true
        model =
          user: $scope.project.model.user
          project: $scope.project.model.project
          station: $scope.station.model.station
          equipment: ''
          name: ''
          type: 'access'
          vendor: $scope.vendor
          enable: true
          template: 'people_template'
        $scope.equipment = $scope.station.createEquipment model, null
        $scope.equipment.loadProperties()
        $scope.refreshData()

      # 批量删除
      $scope.deleteSelectEquip = () =>
        console.log selectEquips
        console.log @commonService

      # 删除设备
      $scope.deleteEquip = (equip)=>
        $scope.equipment = equip
        station = _.find $scope.stations, (station) => station.model.station is equip.model.station
        title = "删除设备确认: #{$scope.project.model.name}/#{station.model.name}/#{$scope.equipment.model.name}"
        message = "请确认是否删除人员: #{$scope.project.model.name}/#{station.model.name}/#{$scope.equipment.model.name}？删除后设备和数据将从系统中移除不可恢复！"
        $scope.prompt title, message, (ok) =>
          return if not ok
          $scope.equipment.remove (err, model) =>
            loadEquipsByTemplate(true)

      # 选择人
      $scope.selectPeople = (people) =>
        $scope.equipment = people
        $scope.currentPeople = {}
        $scope.currentPeople.peopleId = people.propertyValues['people-id']
        $scope.currentPeople.peopleName = people.propertyValues['people-name']
        $scope.currentPeople.peopleImg = people.propertyValues['people-imgsrc']
        $scope.currentPeople.peopleMobile = people.propertyValues['people-mobile']
        $scope.currentPeople.peopleSex = people.propertyValues['people-sex']
        $scope.currentPeople.peoplePosition = people.propertyValues['people-position']
        $scope.currentPeople.peopleGroup = people.propertyValues['people-group']
        $scope.currentPeople.peopleTitle = people.propertyValues['people-title']
        $scope.currentPeople.peopleEmail = people.propertyValues['people-email']
        $scope.currentPeople.peopleDescribe = people.propertyValues['people-describe']
        $scope.currentPeople.peopleTelephone = people.propertyValues['people-telephone']
        $scope.currentPeople.vendor = people.model.vendor
        $scope.currentPeople.station = people.model.station
      # 查找属性
      $scope.findProperty = (propertyId) =>
        property = _.find $scope.properties, (property) => property.model.property is propertyId
        return property if property

      # 保存设备
      $scope.saveEquipment = () =>
        phoneReg = /(^1[3|4|5|7|8]\d{9}$)|(^09\d{8}$)/;
        mailReg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.|-]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;
        if not $scope.currentPeople.peopleId
          title = "ID不能为空"
          message = "ID不能为空，请输入ID。"
          return @display title,message
        if not $scope.currentPeople.peopleName
          title = "姓名不能为空"
          message = "姓名不能为空，请输入姓名。"
          return @display title,message
        if not $scope.currentPeople.peopleMobile || (!phoneReg.test($scope.currentPeople.peopleMobile))
          title="手机号码不正确"
          message="请填写有效的手机号码。"
          return @display title,message
        if not $scope.currentPeople.peopleEmail || (!mailReg.test($scope.currentPeople.peopleEmail))
          title = "邮箱格式不正确"
          message = "请填写正确的邮箱地址。"
          return @display title,message
        if $scope.currentPeople.vendor == "0"
          title = "设备厂商不能为空"
          message = "ID不能为空，请重新选择厂商"
          return @display title,message
        $scope.equipment.model.equipment = $scope.currentPeople.peopleId if not $scope.equipment.model.equipment
        $scope.equipment.model.name = $scope.currentPeople.peopleName
        $scope.equipment.model.vendor = $scope.currentPeople.vendor
        $scope.equipment.model.station = $scope.currentPeople.station
        _.map $scope.equipment.properties.items, (property) =>
          if property.model.property is "people-id"
            property.value = $scope.currentPeople.peopleId
          if property.model.property is "people-name"
            property.value = $scope.currentPeople.peopleName
          if property.model.property is "people-sex"
            property.value = $scope.currentPeople.peopleSex
          if property.model.property is "people-imgsrc"
            property.value = $scope.currentPeople.peopleImg
          if property.model.property is "people-mobile"
            property.value = $scope.currentPeople.peopleMobile
          if property.model.property is "people-email"
            property.value = $scope.currentPeople.peopleEmail
          if property.model.property is "people-position"
            property.value = $scope.currentPeople.peoplePosition
          if property.model.property is "people-group"
            property.value = $scope.currentPeople.peopleGroup
          if property.model.property is "people-title"
            property.value = $scope.currentPeople.peopleTitle
          if property.model.property is "people-telephone"
            property.value = $scope.currentPeople.peopleTelephone
          if property.model.property is "people-describe"
            property.value = $scope.currentPeople.peopleDescribe
        $scope.equipment.save (err, model) =>
          $scope.closeModal()
          loadEquipsByTemplate(true)

      # 关闭弹出框
      $scope.closeModal = () =>
        $('#door-people-modal').modal('close')

      # 重置数据
      $scope.refreshData = () =>
        $scope.currentPeople =
          peopleId: moment().format("YYYYMMDDHHmmssSSS")
          peopleName: 'new-people-name'
          peopleImg: ''
          peopleMobile: ''
          peopleSex: '0'
          peoplePosition: '0'
          peopleGroup: '0'
          peopleTitle: '0'
          peopleEmail: ''
          peopleDescribe : ''
          peopleTelephone: ''
          vendor: '0'
          station: $scope.station.model.station

    resize: ($scope)->

    dispose: ($scope)->


  exports =
    UserManagerDirective: UserManagerDirective