###
* File: scrum-controller
* User: Dow
* Date: 2/27/2015
###

# compatible for node.js and requirejs
#`if (typeof define !== 'function') { var define = require('amdefine')(module) }`
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.web', '../../services/datacenter/service-manager','underscore'
], (web, sm, _) ->
  class PortalController extends web.PortalController
    constructor: ->
      super sm

      @datacenterService = sm.getService 'datacenter'

    onRpc: (method, options, callback) ->
      if method not in ["upload","uploadElement","configurationRecovery","upgrade"]
        @datacenterService.rpc method, options, callback
      else
        if(_.isArray(@req.files))
          file = @req.files?[0]
          file.options = options.parameters
          @datacenterService.rpc method, file, callback
        else if(_.isObject(@req.files))
          file = @req.files?.file
          file.options = options.parameters
          @datacenterService.rpc method, file, callback
  exports =
    PortalController: PortalController
