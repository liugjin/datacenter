###
* File: main
* User: Dow
* Date: 2014/10/24
###

requirejs ['json!/datacenter/setting', 'materialize-css','threejs', 'angular', './app'
], (setting, M,THREE, angular, app) ->
  window.setting = setting
  window.THREE = THREE

  angular.bootstrap document.documentElement, ['app']
