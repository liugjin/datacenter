

define ["clc.foundation.angular/controllers/live-main-controller", "tripledes", "underscore"], (base, des, _) ->

  class LiveMainController extends base.LiveMainController
    constructor: ($scope, $rootScope, $routeParams, $location, $window, $translate, storage, authService, liveService, modelManager, @modelEngine, @$filter) ->
      super $scope, $rootScope, $routeParams, $location, $window, $translate, storage, authService, modelManager, liveService

    logout: () ->
      $('menu').hide()
      $('menu-control a').off('click')
      $('main').css('padding-left','0')
      @authService.logout (err) =>
        path = @$rootScope.lastPath
        if not path or path.indexOf('/401') >= 0 or path.indexOf('/error') >= 0
          path = "/"

        url = "#{@getBaseUrl()}/#/login?path=#{path}"
        url = @encodeUrl url

        @redirect "/#{@setting.namespace}/#/login?url=#{url}"

  exports =
    LiveMainController: LiveMainController