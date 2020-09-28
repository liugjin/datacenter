###
* File: home-controller
* User: Dow
* Date: 2/4/2015
###

# compatible for node.js and requirejs
define = require('amdefine') module if typeof define isnt 'function'

define ['clc.foundation.web', '../../services/datacenter/service-manager', '../../../index-setting.json'
], (web, sm, setting) ->
  class HomeController extends web.HomeController
    constructor: ->
      super 'datacenter', setting, sm


  exports =
    HomeController: HomeController
