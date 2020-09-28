###
* File: grid-table-directive
* User: bingo
* Date: 2018/11/23
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "angularGrid"], (base, css, view, _, moment, agGrid) ->
  class GridTableDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "grid-table"
      super $timeout, $window, $compile, $routeParams, commonService


    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: ($scope, element, attrs) =>
      return if not $scope.firstload
      $scope.agrid = null

      onSelectionChanged = ()=>
        @commonService.publishEventBus("grid-single-selection", gridOptions.api.getSelectedRows())

      createGridOptions = (header) ->
        gridOptions =
          columnDefs: header
          rowData: null
          enableFilter: false
          enableSorting: true
          rowSelection: 'single'
          enableColResize: true
          overlayNoRowsTemplate: "无数据"
          headerHeight:35
          singleClickEdit: false
          rowHeight: 50
          onSelectionChanged: onSelectionChanged

        gridOptions

      gridOptions = null

      createGrid = () =>
        gridOptions = createGridOptions $scope.parameters.header
        $scope.agrid?.destroy()
        $scope.agrid = new agGrid.Grid element.find("#grid")[0], gridOptions
      createGrid()

      $scope.setting = setting
      $scope.$watch 'setting.theme', (theme)->
        element.find(".ag-header").addClass theme+" lighten-2" if theme and theme isnt 'teal'

      $scope.$watchCollection 'parameters.header', (header) ->
        return if not header
        if not gridOptions
          createGrid()
        gridOptions.api?.setColumnDefs header
        gridOptions.api?.setRowData $scope.parameters.data
        gridOptions.api?.sizeColumnsToFit() if header?.length <= 7

      $scope.$watchCollection 'parameters.data', (data) ->
        if not gridOptions
          createGrid()
        if gridOptions.api
          gridOptions.api.setColumnDefs $scope.parameters.header
          gridOptions.api.setRowData data
          gridOptions.api.sizeColumnsToFit() if $scope.parameters.header?.length <= 7

      $scope.subscribe?.dispose()
      $scope.subscribe = @subscribeEventBus "export-report", (msg) ->
        if msg.message.header == $scope.parameters.header
          gridOptions.api.exportDataAsCsv({fileName:msg.message.name, allColumns: true, skipGroups:true})

    resize: ($scope)->

    dispose: ($scope)->
      $scope.subscribe?.dispose()


  exports =
    GridTableDirective: GridTableDirective