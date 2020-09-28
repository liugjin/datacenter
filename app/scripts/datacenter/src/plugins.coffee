`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['angular', 'json!./directives/plugins.json'
], (angular, plugins) ->

  module = angular.module 'clc.plugins', ['clc.materialize']
#  module.service 'commonService', ['$rootScope', '$http', 'modelEngine','liveService', 'reportingService', 'uploadService', commonService.CommonService]

  camelCaseName = (name, notFirst) ->
    name2 = ''
    words = name.split '-'
    for word, i in words
      if i is 0 and notFirst
        name2 += word
      else
        name2 += "#{word[0].toUpperCase()}#{word.substr 1}"
    name2

  createDirective = (plugin) ->
    name = camelCaseName plugin.id, true
    type = camelCaseName(plugin.id, false)+"Directive"
    require ["./src/directives/"+plugin.id+"/component"], (com) ->
      module.directive name, ['$timeout', '$window', '$compile', '$routeParams', 'commonService', ($timeout, $window, $compile, $routeParams, commonService)->
        new com[type] $timeout, $window, $compile, $routeParams, commonService
      ]

  for plugin in plugins
    createDirective plugin


  exports =
    'clc.plugins': module
