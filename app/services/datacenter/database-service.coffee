# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define [
  'clc.foundation',
  'underscore',
  'mongodb',
  '../../../index-setting.json',
  'clc.foundation.data/app/models/monitoring/signal-values-model',
  'clc.foundation.data/app/models/monitoring/event-values-model',
  'clc.foundation.data/app/models/monitoring/command-values-model',
  'clc.foundation.data/app/models/monitoring/signal-statistics-model'
  'fs'
  'moment'
], (base, _, mongodb, settings, svm, evm, cvm, ssm, fs, moment) ->
  class DatabaseService extends base.MqttService
    constructor: (@options) ->
      super @options

      @setting = {}
      @signal = new svm.SignalValuesModel
      @event = new evm.EventValuesModel
      @command = new cvm.CommandValuesModel
      @statistic = new ssm.SignalStatisticsModel

    initialize: (callback) ->
      super callback
      @publishDatabaseSetting()
      @subscribeDatabaseCmd()

      url = settings.mongodb.urls[settings.mongodb.env]
      options =
        auth:
          user: settings.mongodb.options.user
          password: settings.mongodb.options.pass
        authSource: 'admin'
        useUnifiedTopology: true
      mongodb.MongoClient.connect url, options, (err, client)=>
        @db = client.db("clc-dev")
        setInterval =>
          @diagnosticDatabase()
          @clearData()
        ,50000

    diagnosticDatabase: ()->
      @db.stats {}, (err, status) =>
        return if err
        value =
          collections: status.collections
          indexes: status.indexes
          count: status.objects
          size: parseFloat (status.storageSize/1024/1024/1024).toFixed(2)
#          dbSize: parseFloat ((status.storageSize+status.indexSize)/1024/1024/1024).toFixed(2)
        @publishMessage "diagnostic", "database", "db", value
        @getCollectionInfo "signalvalues", (err, count, size) =>
          value =
            count: count
            size: size
          @publishMessage "diagnostic", "database", "signals", value
          @signals = size
        @getCollectionInfo "eventvalues", (err, count, size) =>
          value =
            count: count
            size: size
          @publishMessage "diagnostic", "database", "events", value
          @events = size
        @getCollectionInfo "commandvalues", (err, count, size) =>
          value =
            count: count
            size: size
          @publishMessage "diagnostic", "database", "commands", value
          @commands = size
        @getCollectionInfo "signalstatistics", (err, count, size) =>
          value =
            count: count
            size: size
          @publishMessage "diagnostic", "database", "statistics", value
          @statistics = size

    getCollectionInfo: (name, callback) ->
      @db.collection(name).stats {}, (err, data) ->
        return if err
        count = data?.count
        size = parseFloat (data?.size/1024/1024).toFixed(2)
#        size = parseFloat ((data?.storageSize+data?.totalIndexSize)/1024/1024/1024).toFixed(2)
        callback? err, count, size

    publishMessage: (mu, su, ch, value) ->
      topic = "sample-values/"+mu+"/"+su+"/"+ch
      @publishToMqtt topic, {monitoringUnitId: mu, sampleUnitId: su, channelId: ch, value: value, timestamp: new Date() }

    publishDatabaseSetting: ->
      if fs.existsSync "./db-setting.json"
        @setting = JSON.parse fs.readFileSync "./db-setting.json"
        @publishToMqtt "cmd/diagnostic/database/setting", @setting, {qos:0, retain: false}

    subscribeDatabaseCmd: ->
      @subscribeToMqtt "cmd/diagnostic/database/setting", {qos: 0}, (d) =>
        @saveSetting d.message

    saveSetting: (sting) ->
      @setting = sting
      fs.writeFileSync "./db-setting.json", JSON.stringify @setting

    clearData:  ->
      if @setting.months
        date = moment().subtract(@setting.months, 'months')
        try
          @signal.remove {timestamp : {$lt: date}}, null, (err, records) =>
            console.log err if err
            @backupData records, "signals" if @setting.path
          @event.remove {startTime : {$lt: date}}, null, (err, records) =>
            console.log err if err
            @backupData records, "events" if @setting.path
          @command.remove {startTime : {$lt: date}}, null, (err, records) =>
            console.log err if err
            @backupData records, "commands" if @setting.path
          @statistic.remove {timestamp : {$lt: date}}, null, (err, records) =>
            console.log err if err
            @backupData records, "statistics" if @setting.path
        catch error
          console.log "remove date error:", error

      if @setting.signals and @setting.signals <= @signals
        @signal.findLastOne {}, "_index", (err, item) =>
          sindex = item._index+(@setting.count ? 100)
          console.log "signal index:", sindex
          try
            @signal.remove {_index : {$lt: sindex}}, null, (err, records) =>
              return console.log err if err
              console.log "removed signals:", records.length
              @backupData records, "signals" if @setting.path
          catch err
            console.log "remove signals error:", err

      if @setting.events and @setting.events <= @events
        @event.findLastOne {}, "_index", (err, item) =>
          eindex = item._index+(@setting.count ? 100)
          console.log "event index:", eindex
          try
            @event.remove {_index : {$lt: eindex}}, null, (err, records) =>
              return console.log err if err
              console.log "removed events:", records.length
              @backupData records, "events" if @setting.path
          catch err
            console.log "remove events error:", err

      if @setting.commands and @setting.commands <= @commands
        @command.findLastOne {}, "_index", (err, item) =>
          cindex = item._index+(@setting.count ? 100)
          console.log "command index:", cindex
          try
            @command.remove {_index : {$lt: cindex}}, null, (err, records) =>
              return console.log err if err
              console.log "removed commands:", records.length
              @backupData records, "commands" if @setting.path
          catch err
            console.log "remove commands error:", err

      if @setting.statistics and @setting.statistics <= @statistics
        @statistic.model.find({}, "_id").sort("_id").limit(@setting.count ? 100).exec (err, items)=>
          index = items[(@setting.count ? 100)-1]._id
          console.log "statistic _id:", index
          try
            @statistic.remove {_id : {$lte: index}}, null, (err, records) =>
              return console.log err if err
              console.log "removed statistics:", records.length
              @backupData records, "statistics" if @setting.path
          catch err
            console.log "remove statistics error:", err

    backupData: (data, type)->
      return if not @setting.path or not fs.existsSync @setting.path
      return if not data or data.length is 0
      name = type+ moment().format("YYYYMMDDHHmmss")+".json"
      fs.writeFileSync @setting.path+"/"+name, JSON.stringify data


  exports =
    DatabaseService: DatabaseService
