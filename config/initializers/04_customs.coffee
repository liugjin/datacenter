# data = require 'clc.foundation.data'

# setting = require '../../index-setting.json'

# dsv = require '../../app/services/datacenter/database-service'

# connection = new data.MongodbConnection setting.mongodb
# connection.start()

# dService = new dsv.DatabaseService setting
# dService.start()

setting = require '../../index-setting.json'
dsv = require '../../app/services/datacenter/database-service'
dService = new dsv.DatabaseService setting
dService.start()