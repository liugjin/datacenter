###
 * File: routes
 * User: Dow
 * Date: 4/11/13
 * Desc: 
###

setting = require '../index-setting.json'
cr = require '../app/routers/datacenter/router'

module.exports = ->

  datacenterRouter = new cr.Router setting, @
  datacenterRouter.start()
