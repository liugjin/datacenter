###
* File: menu-directive
* User: David
* Date: 2018/10/25
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['jquery','../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment", "json!../../../setting.json", 'jquery.ui'], ($,base, css, view, _, moment, setting) ->
  class MenuDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "menu"
      super $timeout, $window, $compile, $routeParams, commonService

      @projectService = commonService.modelEngine.modelManager.getService("project")

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    link: ($scope, element, attrs) ->
      $scope.controller.flag = false
      @menuSub?.dispose()
      @menuSub = @subscribeEventBus 'menuState', (d)=>
        if d.message.menu is "menu"
          $('menu').toggle()
          $('menu').toggleClass('menu-hide')
          $('menu').toggleClass('menu-show')
          $scope.controller.flag = !$scope.controller.flag
          $scope.isadmin=false
          @publishEventBus "menu-collapsed", {value: $scope.controller.flag}
          # trigger windows resize event
          clearTimeout $scope.resizeTimer
          $scope.resizeTimer = setTimeout ->
            window.dispatchEvent(new Event('resize'))
          ,100
          if $(".menu").hasClass("menu-lock")
            $scope.menuExpanded = @getComponentPath("/images/menu-expanded.svg")
            $(".menu").removeClass("menu-lock")
            $(".menu").addClass("menu-close")
            $(".menu").addClass("menu-collapsed")
            $scope.noExpanded=2
          else
            $scope.menuExpanded = @getComponentPath("/images/menu-collapsed.svg")
            $(".menu").removeClass("menu-close")
            $(".menu").removeClass("menu-collapsed")
            $(".menu").addClass("menu-expanded")
            $(".menu").addClass("menu-lock")
            $scope.noExpanded= 1

#      clearTimeout $scope.projectTimer
#      $scope.projectTimer = setTimeout =>
#        @getProject $scope, ()->
#          $scope.menus = $scope.project.model.setting?.menus ? setting.menus
#          $scope.$applyAsync()
#      ,50
#
#      $scope.menus = setting.menus

      $scope.menuExpanded = @getComponentPath("/images/menu-collapsed.svg")
      $scope.noExpanded= 1

      $scope.enterMenu = ->
        if !$('.menu').hasClass("menu-lock")
          $('.menu').addClass("menu-expanded").removeClass("menu-collapsed")

      $scope.leaveMenu = ->
        if !$('.menu').hasClass("menu-lock")
          $('.menu').addClass("menu-collapsed").removeClass("menu-expanded")

      $scope.selectSubmenu = (menu) =>
        $scope.noExpanded= 1
        @commonService.$rootScope.submenu = menu

      $scope.$watch 'controller.$location.$$path', (url) =>
        urls = url.split("/")
        $scope.myproject = {user: urls[2], project: urls[3]} if urls.length>3
        searchUrl = (menus, type)->
          ret = ""
          dex = -1
          for menu, index in menus
            dex = index if type is 1
            dex++ if type is 2 and menu.submenus
            if $scope.controller.$location.$$absUrl.indexOf(menu.url+"/")>0 or (menu.suburl and (_.find menu.suburl, (value)->$scope.controller.$location.$$absUrl.indexOf(value)>0) != undefined)
              ret = dex
              break
            else if menu.submenus?.length> 0
              ind = searchUrl menu.submenus, type
              ret = dex+"-"+ ind if ind != ""
          ret+""

        @getProject $scope, ()=>
          $scope.menus = $scope.project.model.setting?.menus ? setting.menus
          id = searchUrl $scope.menus, 1
          #        hid = searchUrl $scope.menus, 2
          if id != ''
            ids = id.split('-')
            ids.pop()
            if ids.length>1 then ids[i] = ids[i-1]+"-"+ids[i] for i in [1..ids.length-1]
            @$timeout.cancel $scope.menuTimer
            $scope.menuTimer = @$timeout =>
              $('.item').removeClass('active')
              for sid, ind in ids
                if !$("#collapsible-"+sid).hasClass "active"
                  aid = sid.split('-')
                  aid.pop()
                  cid = "#collaps"
                  cid = "#collaps"+aid.join '-' if sid.indexOf('-')>= 0
                  $(cid).collapsible 'open', parseInt id.split('-')[ind]
              $("#collapsible-"+id).addClass('active')
            , if $scope.controller.project then 10 else 800

    dispose: (scope)->
      @menuSub?.dispose()

      clearTimeout(scope.resizeTimer)
      clearTimeout scope.projectTimer
      @$timeout.cancel scope.menuTimer


  exports =
    MenuDirective: MenuDirective