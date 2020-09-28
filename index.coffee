###
* File: index
* User: Pu
* Date: 11/01/13
* Desc: 
###

setting = require './index-setting.json'

web = require 'clc.foundation.web'

# start web server
server = new web.Server setting
server.start()



