###
* File: record-manager-base
* User: Dow
* Date: 12/4/2016
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['./module-base', '../models/paging-model', 'moment'], (base, pm, moment) ->
  class RecordManagerBase extends base.ModuleBase
    constructor: (options, @reportingService) ->
      super options

    initialize: (callback) ->
      super callback

      @records = new pm.PagingModel
        predicate: '_index'
        reverse: false

      @parameters = {}

    dispose: ->
      super

      @records.setItems []
      @parameters = {}

    selectRecordType: (type = @recordType) ->
      @recordType = type

    getPeriod: (type = @recordType) ->
      switch type.type
        when '60minutes'
          startTime = moment().subtract 60, 'minutes'
          endTime = moment()
        when 'hour'
          startTime = moment().startOf 'hour'
          endTime = moment().endOf 'hour'
        when 'day'
          startTime = moment().startOf 'day'
          endTime = moment().endOf 'day'
        when 'week'
          startTime = moment().startOf 'week'
          endTime = moment().endOf 'week'
        when 'month'
          startTime = moment().startOf 'month'
          endTime = moment().endOf 'month'
        when 'year'
          startTime = moment().startOf 'year'
          endTime = moment().endOf 'year'
        else
          startTime = moment().subtract 60, 'minutes'
          endTime = moment()

      @period =
        startTime: startTime
        endTime: endTime
        type: type.type

    nextPeriod: () ->
      if not @period
        return getPeriod()

      switch @period.type
        when '60minutes'
          startTime = @period.endTime
          endTime = moment(@period.endTime).add(60, 'minutes')
        when 'hour'
          startTime = moment(@period.startTime).add(1, 'hour').startOf 'hour'
          endTime = moment(@period.startTime).add(1, 'hour').endOf 'hour'
        when 'day'
          startTime = moment(@period.startTime).add(1, 'day').startOf 'day'
          endTime = moment(@period.startTime).add(1, 'day').endOf 'day'
        when 'week'
          startTime = moment(@period.startTime).add(1, 'week').startOf 'week'
          endTime =moment(@period.startTime).add(1, 'week').endOf 'week'
        when 'month'
          startTime = moment(@period.startTime).add(1, 'month').startOf 'month'
          endTime = moment(@period.startTime).add(1, 'month').endOf 'month'
        when 'year'
          startTime = moment(@period.startTime).add(1, 'year').startOf 'year'
          endTime = moment(@period.startTime).add(1, 'year').endOf 'year'
        else
          startTime = @period.endTime
          endTime = moment(@period.endTime).add(60, 'minutes')

      @period =
        startTime: startTime
        endTime: endTime
        type: @period.type

    previousPeriod: () ->
      if not @period
        return getPeriod()

      switch @period.type
        when '60minutes'
          startTime = moment(@period.startTime).subtract(60, 'minutes')
          endTime = @period.startTime
        when 'hour'
          startTime = moment(@period.startTime).subtract(1, 'hour').startOf 'hour'
          endTime = moment(@period.startTime).subtract(1, 'hour').endOf 'hour'
        when 'day'
          startTime = moment(@period.startTime).subtract(1, 'day').startOf 'day'
          endTime = moment(@period.startTime).subtract(1, 'day').endOf 'day'
        when 'week'
          startTime = moment(@period.startTime).subtract(1, 'week').startOf 'week'
          endTime =moment(@period.startTime).subtract(1, 'week').endOf 'week'
        when 'month'
          startTime = moment(@period.startTime).subtract(1, 'month').startOf 'month'
          endTime = moment(@period.startTime).subtract(1, 'month').endOf 'month'
        when 'year'
          startTime = moment(@period.startTime).subtract(1, 'year').startOf 'year'
          endTime = moment(@period.startTime).subtract(1, 'year').endOf 'year'
        else
          startTime = moment(@period.startTime).subtract(60, 'minutes')
          endTime = @period.startTime

      @period =
        startTime: startTime
        endTime: endTime
        type: @period.type

    queryRecords: (item, periodType, page = 1, pageItems = 20) ->
      return if not item

      switch periodType
        when 'next'
          period = @nextPeriod()
        when 'previous'
          period = @previousPeriod()
        when 'refresh'
          period = @period ? @getPeriod()
        else
          period = @getPeriod()

      paging =
        page: page
        pageItems: pageItems

      sorting = {}
      sorting[@records.predicate] = if @records.reverse then -1 else 1

      @parameters =
        item: item

        startTime: period.startTime
        endTime: period.endTime

        queryTime: moment()
        periodType: periodType

        paging: paging
        sorting: sorting

      filter = @getFilter item

      data =
        filter: filter
        fields: null
        paging: paging
        sorting: sorting

      @queryReport data, (err, records, paging2) =>
        records = @processRecords records
        @records.setItems records

        paging2.pages = [1..paging2.pageCount] if paging2 and paging2.pageCount > 1

        @parameters.paging = paging2

    getFilter: (item) ->
      filter = item.getIds()
      filter.startTime = @period.startTime
      filter.endTime = @period.endTime

      filter

    queryReport: (data, callback) ->
      @reportingService[@options.queryReportMethod] data, callback

    processRecords: (records) ->
      return if not records

      for record in records
        @processRecord record

      records

    processRecord: (record) ->
      record

    queryPage: (page) ->
      paging = @parameters?.paging
      return if not paging

      if page is 'next'
        page = paging.page + 1
      else if page is 'previous'
        page = paging.page - 1

      return if page > paging.pageCount or page < 1

      @queryRecords @parameters.item, @parameters.periodType, page, paging.pageItems


  exports =
    RecordManagerBase: RecordManagerBase
