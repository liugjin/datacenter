setting = require '../../index-setting.json'
web = require 'clc.foundation.web'

module.exports = ->
  options = setting.web

  app = new web.Application @, options
  app.initialize()



