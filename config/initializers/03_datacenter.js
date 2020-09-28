// Generated by IcedCoffeeScript 108.0.11

/*
* File: 02_gateway
* User: Dow
* Date: 5/7/2015
* Desc:
 */
var connection, data, setting, sm;

data = require('clc.foundation.data');

setting = require('../../index-setting.json');

connection = new data.MongodbConnection(setting.mongodb);

connection.start();

sm = require('../../app/services/datacenter/service-manager');

module.exports = function() {
  return sm.startService(['register', 'configuration', 'datacenter']);
};
