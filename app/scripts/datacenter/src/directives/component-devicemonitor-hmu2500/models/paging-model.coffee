###
* File: paging-controller
* User: Dow
* Date: 3/21/2015
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/disposable'], (base) ->
  class PagingModel extends base.Disposable
    constructor: (@options = {}) ->
      super 

      @predicate = @options.predicate ? ''
      @reverse = @options.reverse ? false
      # pager
      @pageItems = @options.pageItems ? 10

      @page = 1
      @pages =[]
      @pageCount = 0
      @itemCount = 0
      @items = []

    # filter item before adding it
    predicateItem: (item) ->
      true

    setItems: (items) ->
      items2 = []
      if not items
      else if items instanceof Array
        for v in items
          if @predicateItem item
            items2.push v
      else
        for key, item of items
          if @predicateItem item
            items2.push item

      @items = items2

      @processPages()

      @items

    addItem: (item) ->
      return if not item

      for item2 in @items
        if item2._id is item._id
          for key, value of item
            item2[key] = value
          return item2

      return if not @predicateItem item

      @items.push item
      @processPages()

      item

    removeItem: (item) ->
      return if not item

      index = @items.indexOf(item)
      @items.splice index, 1
      @processPages()

      index

    removeById: (id) ->
      for item, index in @items
        if item._id is id
          @items.splice index, 1
          @processPages()

          return index

      return -1

    sortBy: (predicate) ->
      if @predicate is predicate
        @reverse = !@reverse
      else
        @predicate = predicate
        @reverse = true

    nextPage: ->
      if @page < @pageCount
        @page++

    previousPage: ->
      if @page > 1
        @page--

    setPage: (page) ->
      page = 1 if not page or page > @pageCount
      @page = page

    processPages: (refresh) ->
      count = @items.length
      if not refresh and @itemCount is count
        return

      @itemCount = count
      @pageCount = Math.ceil count / @pageItems
      if @pageCount is 0
        @pages = []
      else
        @pages = [1..@pageCount]

      if page > @pageCount
        page = @pageCount - 1

    filter: (searchText, keys = ['name'], ignoreCase = true) ->
      (item) =>
        if not searchText
          return true

        for key in keys
          return true if @filterItemField searchText, item, key, ignoreCase

        return false

    filterItemField: (text, item, key, ignoreCase) ->
      # compatible to view model
      value = item[key] ? item.model?[key]
      return false if not value

      if ignoreCase
        text = text.toLowerCase()

        if value.toLowerCase().indexOf(text) >= 0
          return true
      else
        if value.indexOf(text) >= 0
          return true

      return false


  exports =
    PagingModel: PagingModel
