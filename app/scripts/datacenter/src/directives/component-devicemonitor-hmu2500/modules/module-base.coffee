###
* File: module-base
* User: Dow
* Date: 12/4/2016
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.angular/disposable'], (base) ->
  class ModuleBase extends base.Disposable
    constructor: (@options = {}) ->
      super


  exports =
    ModuleBase: ModuleBase
