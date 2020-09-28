###
* File: service-manager
* User: Dow
* Date: 5/7/2015
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../../../index-setting.json', './service-register'
], (setting, sr) ->
  sm = new sr.ServiceRegister setting, 'datacenter'

  getService = (name, callback) ->
    sm.getService name, callback

  startService = (name, callback) ->
    sm.startService name, callback

  startServicesSync = (name, callback) ->
    sm.startServicesSync name, callback

  exports =
    getService: getService
    startService: startService
    startServicesSync: startServicesSync
