web = require 'clc.foundation.web'

module.exports = ->
  development = new web.Development @
  development.initialize()