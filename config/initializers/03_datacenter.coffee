###
* File: 02_gateway
* User: Dow
* Date: 5/7/2015
* Desc: 
###

# sm = require '../../app/services/datacenter/service-manager'

# module.exports = ->
# #  sm.startServicesSync ['register', 'configuration', 'datacenter']
#   sm.startService ['register', 'configuration', 'datacenter']
data = require 'clc.foundation.data'
setting = require '../../index-setting.json'
connection = new data.MongodbConnection setting.mongodb
connection.start()
sm = require '../../app/services/datacenter/service-manager'
module.exports = ->
  sm.startService ['register', 'configuration', 'datacenter']