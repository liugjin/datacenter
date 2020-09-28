###
* File: component-rolesrights-directive
* User: James
* Date: 2018/11/17
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive'
  ,'text!./style.css', 'text!./view.html'
, 'underscore'
, "moment"
], (base, css, view, _, moment) ->
  class ComponentRolesrightsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      super $timeout, $window, $compile, $routeParams, commonService
      @id = "component-rolesrights"
      @commonService = commonService

      @urlPath = $window.location.href.substr(0,$window.location.href.indexOf("#"))
      @roleService = commonService.modelEngine.modelManager.getService("roles")


    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      @scope = scope
      @init()


    init:()=>
      #初始全部选项值
      @scope.allStationFlag = true
      @scope.allEquipTypeFlag = true
      @scope.allOperatorFlag = true
      @scope.allModuleFlag = true
      @scope.roleObject = null
      @scope.current = {
        user: @scope.project.model.user
        project:@scope.project.model.project
        name:""
        role:""
        desc:""
        portal:""
        group:""
        index:0
        stations:["_all"]
        operations:["_all"]
        categories:["_all"]
        modules:["_all"]
        commands:[]
        services:["_all"]
        users:[]
        createtime:new Date()
      }

      @scope.allStationCheckFlags ={}
      @scope.allEquipTypeCheckFlags ={}
      @scope.allModuleCheckFlags ={}
      @scope.allOperatorCheckFlags ={}

      @scope.stations = @scope.project.stations.items
      roots = _.filter @scope.project.stations.items,(val,key)=>
            return val.model.parent == ""
      @htmlstr = ""
      for rootItem in roots
        @htmlstr += '<div class="repeat-label"><md-checkbox ng-model="allStationCheckFlags[\'' + rootItem.model.station + '\']"  id="station-' + rootItem.model.station + '" ng-change="changeStations(\''+ rootItem.model.station + '\')" ng-disabled="allStationFlag" with-gap=false label="' + rootItem.model.name + '"></md-checkbox>'
        @recurStation rootItem,@htmlstr
      @htmlstr += "</div>"

      elem = @$compile(@htmlstr)(@scope)
      $('#recurestationid').append elem

      @resetCheckFlags()

      #获取设备类型，初始化设备类型选项值
      @scope.equipmentTypes = @scope.project.dictionary.equipmenttypes.items

      @scope.changeStations = (refItem)=>


      ##获取模块数据
      @commonService.modelEngine.modelManager.$http.get(@urlPath + "res/roles/modules.json").then (data)=>
        @scope.modules = _.filter data.data.modules,(dataItem)->
                            return _.isEmpty dataItem.parent
        for moduleItem in @scope.modules
          @scope.allModuleCheckFlags[moduleItem.module] = false
          tmpModules = _.filter data.data.modules,(refData)->
                  return refData.parent == moduleItem.module
          for tmpModuleItem in tmpModules
            @scope.allModuleCheckFlags[tmpModuleItem.module] = false
          moduleItem.submodules = tmpModules

      ##获取操作数据
      @commonService.modelEngine.modelManager.$http.get(@urlPath + "res/roles/operations.json").then (data)=>
        @scope.operators = _.filter data.data.operations,(dataItem)->
          return _.isEmpty dataItem.parent
        for operatorItem in @scope.operators
          @scope.allOperatorCheckFlags[operatorItem.operation] = false
          tmpOperators = _.filter data.data.operations,(refData)->
            return refData.parent == operatorItem.operation

          for tmpOperatorItem in tmpOperators
            @scope.allOperatorCheckFlags[tmpOperatorItem.operation] = false
          operatorItem.suboperators = angular.copy tmpOperators

      @query()

      @scope.changeModule = (refItem)=>
      #模块选项
        if !@scope.allModuleCheckFlags[refItem.module]
          #处理父节点，当子节点为true时，父节点应为true
          tmpModules = _.filter @scope.modules,(refData)=>
              for subModuleItem in refData.submodules
                if subModuleItem.module == refItem.module
                  return true
              return false

          if tmpModules.length > 0
            @scope.allModuleCheckFlags[tmpModules[0].module] = !@scope.allModuleCheckFlags[refItem.module]
        if refItem.submodules
          #处理子节点，设置当前节点的子节点值与当前节点值相同
          for dataItem in refItem.submodules
            @scope.allModuleCheckFlags[dataItem.module] =  !@scope.allModuleCheckFlags[refItem.module]


      @scope.changeOperator = (refItem)=>
      #操作选项
        if !@scope.allOperatorCheckFlags[refItem.operation]
          #处理父节点，当子节点为true时，父节点应为true
          tmpOperators = _.filter @scope.operators,(refData)=>
            for subOperatorItem in refData.suboperators
              if subOperatorItem.operation == refItem.operation
                return true
            return false

          if tmpOperators.length > 0
            @scope.allOperatorCheckFlags[tmpOperators[0].operation] = !@scope.allOperatorCheckFlags[refItem.operation]

        if refItem.suboperators
          #处理子节点，设置当前节点的子节点值与当前节点值相同
          for dataItem in refItem.suboperators
            @scope.allOperatorCheckFlags[dataItem.operation] =  !@scope.allOperatorCheckFlags[refItem.operation]

      @scope.addRole = ()=>
        @scope.roleObject = @scope.current = {
          user: @scope.project.model.user
          project:@scope.project.model.project
          name:""
          role:""
          desc:""
          portal:""
          group:""
          index:0
          stations:["_all"]
          operations:["_all"]
          categories:["_all"]
          modules:["_all"]
          commands:[]
          services:["_all"]
          users:[]
          createtime:new Date()
        }

      @scope.delRole = ()=>
        @roleService.remove @scope.roleObject,(err,data)=>
          @query()
          @display err, '操作成功！'

      # 角色保存
      @scope.saveRole = (type) =>
        if type == 1 && $("#roleLists").find(".active").length == 0
          return @display("请先选择一条角色信息!!")
        else if type == 1 && $("#roleLists").find(".active").length > 0
          refData = _.find(@scope.roles, (d) => d.role == $("#roleLists").find(".active")[0].firstChild.innerText)
          @scope.roleObject = refData
          @scope.current = {
            name:refData.name
            role:refData.role
            desc:refData.desc
            portal:refData.portal
            group:refData.group
            index:refData.index
            _id:refData._id
          }
        @scope.roleObject.name = @scope.current.name
        @scope.roleObject.group = @scope.current.group
        @scope.roleObject.index = @scope.current.index
        @scope.roleObject.desc = @scope.current.desc
        @scope.roleObject.portal = @scope.current.portal

        if @scope.allStationFlag
          @scope.roleObject.stations = ["_all"]
        else
          tmpStations = []
          _.mapObject @scope.allStationCheckFlags,(val,key)=>
            if val
              tmpStations.push key
          @scope.roleObject.stations = tmpStations
          
        if @scope.allEquipTypeFlag
          @scope.roleObject.categories = ["_all"]
        else
          tmpEquipTypes = []
          _.mapObject @scope.allEquipTypeCheckFlags,(val,key)=>
            if val
              tmpEquipTypes.push key
          @scope.roleObject.categories = tmpEquipTypes

        if @scope.allModuleFlag
          @scope.roleObject.modules = ["_all"]
        else
          tmpModules = []
          _.mapObject @scope.allModuleCheckFlags,(val,key)=>
            if val
              tmpModules.push key
          @scope.roleObject.modules = tmpModules

        if @scope.allOperatorFlag
          @scope.roleObject.operations = ["_all"]
        else
          tmpOperators = []
          _.mapObject @scope.allOperatorCheckFlags,(val,key)=>
            if val
              tmpOperators.push key
          @scope.roleObject.operations = tmpOperators

        # console.log(@scope.roleObject)
        @roleService.save @scope.roleObject,(err,data)=>
          @query()
          @display err, '操作成功！'

      @scope.roleDetails = (refData,key)=>
        $('.roles-active').removeClass('active')
        $('#roles'+key).addClass('active')
        @resetCheckFlags()
        @scope.roleObject = refData
        @scope.current = {
          name:refData.name
          role:refData.role
          desc:refData.desc
          portal:refData.portal
          group:refData.group
          index:refData.index
          _id:refData._id
        }
        if refData.stations[0] == "_all"
          @scope.allStationFlag = true
        else
          @scope.allStationFlag = false
          for stationItem in refData.stations
            @scope.allStationCheckFlags[stationItem] = true

        if refData.categories[0] == "_all"
          @scope.allEquipTypeFlag = true
        else
          @scope.allEquipTypeFlag = false
          for categorieItem in refData.categories
            @scope.allEquipTypeCheckFlags[categorieItem] = true

        if refData.modules[0] == "_all"
          @scope.allModuleFlag = true
        else
          @scope.allModuleFlag = false
          for moduleItem in refData.modules
            @scope.allModuleCheckFlags[moduleItem] = true

        if refData.operations[0] == "_all"
          @scope.allOperatorFlag = true
        else
          @scope.allOperatorFlag = false
          for operationItem in refData.operations
            @scope.allOperatorCheckFlags[operationItem] = true

    recurStation:(restation)=>
      if restation.stations.length > 0
        @htmlstr += '<div style="margin-left: 30px;margin-top: .5rem">'
        for stationItem in restation.stations
          @htmlstr += '<div>'
          @htmlstr += '<md-checkbox ng-model="allStationCheckFlags[\'' + stationItem.model.station + '\']"  id="station-' + stationItem.model.station + '" ng-change="changeStations(\''+ stationItem.model.station + '\')" ng-disabled="allStationFlag" with-gap=false label="' + stationItem.model.name + '"></md-checkbox>'
          @recurStation(stationItem)
        @htmlstr += "</div>"
      else
        @htmlstr += "</div>"
        return

    #根据用户和项目获取角色数据
    query: ()->
        filter = @scope.project.getIds()
        @roleService.query filter, null,(err, model) =>
          @scope.roles = model
        ,true


    resetCheckFlags: ()->
      if @scope.equipmentTypes
        for equipmentTypeItem in @scope.equipmentTypes
          @scope.allEquipTypeCheckFlags[equipmentTypeItem.model.type] = false

      if  @scope.stations
        for stationItem in @scope.stations
          @scope.allStationCheckFlags[stationItem.model.station] = false

      if @scope.modules
        for moduleItem in @scope.modules
          @scope.allModuleCheckFlags[moduleItem.module] = false

      if @scope.operators
        for operatorItem in @scope.operators
          @scope.allOperatorCheckFlags[operatorItem.operation] = false

    resize: (scope)->

    dispose: (scope)->


  exports =
    ComponentRolesrightsDirective: ComponentRolesrightsDirective