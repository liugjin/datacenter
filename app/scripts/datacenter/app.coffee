###
* File: app
* User: Dowr
* Date: 2014/10/24
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['angular', './routes', 'socketio', 'clc.foundation.angular/app-manager',
  'ngRoute', 'angularLocalStorage', 'angular-moment', 'angularSocketio', 'angularTimeline', 'angular.filter', 'angular-translate', 'angular-translate-loader-static-files'
  'src'
], (angular, routes, io, am) ->
  app = angular.module 'app', ['ngRoute', 'angularLocalStorage', 'angularMoment', 'btford.socket-io', 'angular-timeline', 'angular.filter', 'pascalprecht.translate', 'clc.datacenter']

  manager = new am.AppManager app
  manager.config 'datacenter', routes
  manager.connect io
  # login whitelist, language of moment, $ace trust
  manager.run [], 'zh-cn', true


  exports =
    app: app
