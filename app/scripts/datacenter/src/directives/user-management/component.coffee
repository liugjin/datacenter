###
* File: user-management-directive
* User: David
* Date: 2019/04/01
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class UserManagementDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "user-management"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.currentpeople={}
      scope.peoplesex =
        0: {type: '0', name: '男'}
        1: {type: '1', name: '女'}
      scope.peopleposition =
        0: {type: '0', name: '普通员工'}
        1: {type: '1', name: '经理'}
      scope.peoplegroup =
        0: {type: '0', name: '默认部门'}
        1: {type: '1', name: '研发部'}
      scope.peopletitle =
        0: {type: '0', name: '研发'}
        1: {type: '1', name: '市场'}
      scope.peoples = []
      @station = @project.stations.roots[0]
      @selectStation(@station,scope.peoples)

      # 编辑
      scope.selectPeople=(people)=>
        people.loadProperties()
        scope.currentpeople.peopleid = people.propertyValues['people-id']
        scope.currentpeople.peoplename = people.propertyValues['people-name']
        scope.currentpeople.peopleimgsrc = people.propertyValues['people-imgsrc']
        scope.currentpeople.peoplemobile = people.propertyValues['people-mobile']
        scope.currentpeople.peoplesex = people.propertyValues['people-sex']
        scope.currentpeople.peopleposition = people.propertyValues['people-position']
        scope.currentpeople.peoplegroup = people.propertyValues['people-group']
        scope.currentpeople.peopletitle = people.propertyValues['people-title']
        scope.currentpeople.peopleemail = people.propertyValues['people-email']
        scope.currentpeople.peopledescribe = people.propertyValues['people-describe']
        scope.currentpeople.peopletelephone = people.propertyValues['people-telephone']
        scope.currentpeople.peopleSelected = true

      # 新增
      scope.addPeople=(obj)=>
        scope.currentpeople.peopleSelected = false
        scope.instance = M.Modal.init(element.find('#door-people-modal'))
        @peopleSelected = false
        if obj?
          scope.currentpeople=obj
        else
          scope.currentpeople =
            user: @station.model.user
            project: @station.model.project
            station: @station.model.station
            peopleid: moment().format("YYYYMMDDHHmmssSSS")
            peoplename: 'new-people-name'
            peopleimgsrc: ''
            peoplemobile: ''
            peoplesex: '0'
            peopleposition: '0'
            peoplegroup: '0'
            peopletitle: '0'
            peopleemail:''
            peopledescribe :''
            peopletelephone:''

      #  保存
      scope.saveEquipment=(obj,callback) =>
          PhoneReg = /(^1[3|4|5|7|8]\d{9}$)|(^09\d{8}$)/;
          mailReg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.|-]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;
          if not scope.currentpeople.peopleid
            title = "ID不能为空"
            message = "ID不能为空，请输入ID。"
            return scope.prompt title,message
          if not scope.currentpeople.peoplename
            title = "姓名不能为空"
            message = "姓名不能为空，请输入姓名。"
            return scope.prompt title,message
          if not scope.currentpeople.peoplemobile || (!PhoneReg.test(scope.currentpeople.peoplemobile))
            title="手机号码不正确"
            message="请填写有效的手机号码。"
            return scope.prompt title,message
          if not scope.currentpeople.peopleemail || (!mailReg.test(scope.currentpeople.peopleemail))
            title = "邮箱格式不正确"
            message = "请填写正确的邮箱地址。"
            return scope.prompt title,message
          model =
            user: scope.currentpeople.user
            project: scope.currentpeople.project
            station: scope.currentpeople.station
            equipment:scope.currentpeople.peopleid
            name:scope.currentpeople.peoplename
            type: 'access'
            vendor:'huayuan-iot'
            enable: true
            template:'people_template'
          @equipment = null
          @equipment = @station.createEquipment model, null
          @equipment.loadProperties null, (err, data)=>
            @equipment.setPropertyValue('people-id', scope.currentpeople.peopleid)
            @equipment.setPropertyValue('people-name', scope.currentpeople.peoplename)
            @equipment.setPropertyValue('people-sex', scope.currentpeople.peoplesex)
            @equipment.setPropertyValue('people-imgsrc', scope.currentpeople.peopleimgsrc)
            @equipment.setPropertyValue('people-mobile', scope.currentpeople.peoplemobile)
            @equipment.setPropertyValue('people-email', scope.currentpeople.peopleemail)
            @equipment.setPropertyValue('people-position', scope.currentpeople.peopleposition)
            @equipment.setPropertyValue('people-group', scope.currentpeople.peoplegroup)
            @equipment.setPropertyValue('people-title', scope.currentpeople.peopletitle)
            @equipment.setPropertyValue('people-telephone', scope.currentpeople.peopletelephone)
            @equipment.setPropertyValue('people-describe', scope.currentpeople.peopledescribe)
            @equipment.save data
            scope.peoples.splice(0,scope.peoples.length)
            @selectStation(@station,scope.peoples)
            $('#door-people-modal').modal('close')
      # 删除
      scope.removeEquipment=(callback)=>
        console.log scope.currentpeople.peopleid
        #      得到设备id 在站点里找到此设备并删除
        @equipment = _.find @station.equipments.items ,(item)=>
          return item.model.equipment == scope.currentpeople.peopleid

        title = "删除设备确认: #{@equipment.model.name}"
        message = "请确认是否删除设备: #{@equipment.model.name}？删除后设备和数据将从系统中移除不可恢复！"
        scope.prompt title, message, (ok) =>
          return if not ok
          @equipment.remove (err, model) =>
            scope.peoples.splice(0,scope.peoples.length)
            @selectStation(@station,scope.peoples)
            $('#door-people-modal').modal('close')
      # 排序
      scope.sortBy=(predicate) ->
        if scope.predicate is predicate
          scope.reverse = !scope.reverse
        else
          scope.predicate = predicate
          scope.reverse = true

    selectStation: (station,peoples) =>
      station?.loadEquipments {type:"access",template:"people_template"}, null, (err, model) =>
        for equipmitem in model
          equipmitem?.loadProperties()
          peoples.push(equipmitem)
        console.log("peoples1",peoples)

    resize: (scope)->

    dispose: (scope)->


  exports =
    UserManagementDirective: UserManagementDirective