###
* File: import-assets-directive
* User: David
* Date: 2019/10/22
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class ImportAssetsDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "import-assets"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.ng = {
        xlsx: null, # js-xlsx对象
        reader: null, # 读取excel的对象
        excelTable: [], # 渲染在表格里的设备
        compareEquipment: [], # 服务器里面的设备
        service: null,
        allEquiptment: [],
        importProgress: '0%',
        judgeConfirmExecute: true, # 判断确定按钮是否执行
        progressShow: false
      }
      # 发送添加的设备到数据库
      scope.addDevice = () => (
        if scope.ng.excelTable.length == 0
          @display "请导入设备信息"
          return
        if scope.ng.judgeConfirmExecute == false
          scope.prompt("提示", "是否导入设备", (result)=>
            return if not result
            scope.ng.progressShow = true
            nowTime = (new Date).toISOString()
            postData = _.map scope.ng.excelTable, (item) => (
              {
                "index": 0,
                "enable": true,
                "visible": true,
                "user": scope.project.model.user
                "project": scope.project.model.project
                "owner": scope.$root.user.user,
                "signals": [],
                "events": [],
                "commands": [],
                "traces": [],
                "createtime": nowTime,
                "updatetime": nowTime,
                "parent": item["上级设备"] || "",
                "station": item["站点ID"],
                "type": item["设备类型ID"],
                "template": item["设备模板ID"],
                "vendor": item["厂商"],
                "equipment": item["设备ID"]
                "name": item["设备名"],
                "tag": item["资产标签序列号"] || "",
                "properties": [
                  {
                    "id": "row",
                    "value": Number(item["位置"]) || ""
                  }
                ],
                "sampleUnits": []
              }
            )
            postDataLength = postData.length
            whetherExecute = postData.length
            # post到数据库
            _.each postData, (item, num)=> (
              scope.ng.service.save item, (err, data) => (
                width = (num + 1) / postData.length
                scope.ng.importProgress = width * 100 + "%"
                whetherExecute--
                # 导入成功后的处理
                if whetherExecute == 0
                  scope.ng.judgeConfirmExecute = true
                  _.each scope.ng.excelTable, (repeat)->(
                    repeat.iserror = true
                  )
                  @display "数据导入成功"
                  init()

                  setTimeout(()=>
                    scope.ng.progressShow = false
                    scope.ng.importProgress = "0%"
                    scope.$applyAsync()
                  , 500)
              )
            )
          )
        else
          @display "导入设备信息重复,无法导入"
      )
      # 下载excel模板
      scope.downloadExcel = () => (
        data = [{
          "站点ID": "",
          "设备类型ID": "",
          "设备模板ID": "",
          "厂商": "",
          "设备ID": "",
          "设备名": "",
          "位置": "",
          "上级设备": "",
          "资产标签序列号": ""
        }]
        wb = scope.ng.xlsx.utils.book_new();
        excel = scope.ng.xlsx.utils.json_to_sheet(data)
        scope.ng.xlsx.utils.book_append_sheet(wb, excel, "Sheet1")
        scope.ng.xlsx.writeFile(wb, "需要导入的信息.xlsx")
      )
      # 返回按钮执行函数
      scope.publishBack = () => (
        @publishEventBus('backList', "backList")
      )
      # 导入资产按钮执行函数
      scope.importExcel = () => (
        element.find('.import-file').click()
      )
      # 判断是否已经添加了设备
      judgeHasEquipment = () => (
        _.each scope.ng.excelTable, (item) -> (
          excelRepect = []
          # 判断EXCEL里是否有重复的项
          for device in scope.ng.excelTable
            if device["设备ID"] == item["设备ID"]
              excelRepect.push(device)
            if excelRepect.length >= 2
              excelRepect = []
              _.each scope.ng.excelTable, (repeat) -> (
                if device["设备ID"] == repeat["设备ID"]
                  repeat.iserror = true
                  repeat.remark = "导入信息有重复的项" + repeat["设备ID"] + " "
              )
          # 判断服务器中是否已经拥有改设备
          _.find scope.ng.compareEquipment, (equipment) -> (
            if equipment["设备ID"] == item["设备ID"]
              item.iserror = true
              item.remark = if item.remark then item.remark else "" + "服务器中已经拥有该设备 "
          )
          if item["站点ID"]==undefined || item["设备类型ID"]==undefined || item["设备模板ID"]==undefined || item["厂商"]==undefined || item["设备ID"]==undefined || item["设备名"]==undefined
            item.iserror = true
            item.remark = if item.remark then item.remark else "" + "必填项不能为空 "
        )
        # 判断是否可以进行执行操作
        judgeConfirmExecute = _.filter scope.ng.excelTable, (item) ->
          item.iserror == true
        if judgeConfirmExecute.length > 0 then scope.ng.judgeConfirmExecute = true else scope.ng.judgeConfirmExecute = false
        scope.$applyAsync();
        @commonService.$rootScope.executing = false
      )
      # excle文件导入成功后执行的函数
      renderExcel = () => (
        scope.ng.reader.onload = (file) => (

          excel = scope.ng.xlsx.read(file.target.result, {type: "binary"}) # 获取到excel表格
          sheet0 = excel.Sheets[excel.SheetNames[0]] # 获取第一张表
          scope.ng.excelTable = scope.ng.xlsx.utils.sheet_to_json(sheet0) # 把获取的表格转化成json
          if scope.ng.excelTable && scope.ng.excelTable.length == 0
             @display "导入资产信息为空,请重新导入"
             return false
          else if scope.ng.excelTable && scope.ng.excelTable.length>0
             excelTitles = scope.ng.excelTable[0]
             if excelTitles['站点ID'] && excelTitles['设备类型ID'] && excelTitles['设备模板ID'] && excelTitles['厂商'] && excelTitles['设备ID'] && excelTitles['设备名']
                @commonService.$rootScope.executing = true
                judgeHasEquipment()
             else
                @display "导入信息格式错误,无法导入"
                scope.ng.excelTable = []
                return false
        )
      )
      # 监听excel是否被导入
      listenImportFile = () => (
        element.find('.import-file').on('change', (obj)=>
          file = obj.target.files[0]
          return if not file
          if file.name.indexOf('xlsx') != -1
            scope.ng.reader.readAsBinaryString(file)
            obj.target.value=null
          else
            @display "导入文件的格式应为 xlsx"
        )
      )
      # 构建该项目下已经拥有的所有设备信息
      createCompareEquipment = () => (
        scope.ng.compareEquipment = _.map scope.ng.allEquiptment, (equipment) ->(
          {
            "设备ID": equipment.model.equipment,
            "设备名": equipment.model.name,
            "设备类型ID": equipment.model.type,
            "设备模板ID": equipment.model.template,
            "厂商": equipment.model.vendor,
            "站点ID": equipment.model.station
            "iserror": false
            "remark": ""
          }
        )
      )
      # 初始化执行函数
      init = () => (
        scope.ng.xlsx = @$window.XLSX
        scope.ng.reader = new FileReader()
        whetherExecute = scope.project.stations.items.length
        scope.ng.allEquiptment = []
        scope.ng.service = @commonService.modelEngine.modelManager.getService('equipments')
        for sta in scope.project.stations.items
          sta.loadEquipments {}, null, (err, equips)=>
            whetherExecute--
            scope.ng.allEquiptment = scope.ng.allEquiptment.concat(equips)
            if whetherExecute == 0
              createCompareEquipment()
          ,true
        renderExcel()
        listenImportFile()
      )
      init()

    resize: (scope)->

    dispose: (scope)->


  exports =
    ImportAssetsDirective: ImportAssetsDirective