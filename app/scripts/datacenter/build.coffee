###
* File: build
* User: Dow
* Date: 9/14/2015
* Desc: 
###

###
  to create one bundle file
###

{
  baseUrl: "."
  paths:
    jquery: '../../../public/lib/jquery/dist/jquery'
    materialize: '../../../public/lib/materialize/dist/js/materialize'
    bootstrap: '../../../public/lib/bootstrap/dist/js/bootstrap'
    angular: '../../../public/lib/angular/angular'
    ngRoute: '../../../public/lib/angular-route/angular-route'
    ngResource: '../../../public/lib/angular-resource/angular-resource'
    text: '../../../public/lib/requirejs-plugins/lib/text'
    json: '../../../public/lib/requirejs-plugins/src/json'
    async: '../../../public/lib/requirejs-plugins/src/async'
    ngSanitize: '../../../public/lib/angular-sanitize/angular-sanitize'
    showdown: '../../../public/lib/showdown/compressed/Showdown'
    btfMarkdown: '../../../public/lib/angular-markdown-directive/markdown'
  #    marked: '../../../public/lib/marked/marked.min'
    marked: '../../../public/lib/marked/lib/marked'
    highlight: '../../../public/lib/highlightjs/highlight.pack'
    angularMarked: '../../../public/lib/angular-marked/angular-marked'
    angularHighlight: '../../../public/lib/angular-highlightjs/angular-highlightjs'
    rx: '../../../public/lib/rxjs/dist/rx.all'
    ngCookies: '../../../public/lib/angular-cookies/angular-cookies'
    angularLocalStorage: '../../../public/lib/angularLocalStorage/src/angularLocalStorage'
    tripledes: '../../../public/lib/cryptojslib/rollups/tripledes'
    md5: '../../../public/lib/cryptojslib/rollups/md5'
    moment: '../../../public/lib/moment/moment'
    'angular-moment': '../../../public/lib/angular-moment/angular-moment'
    'moment-locale-cn': '../../../public/lib/moment/locale/zh-cn'
    echarts: '../../../public/lib/echarts/dist'
    'clc.foundation.angular': '../../../public/lib/clc.foundation.angular/src'
    underscore: '../../../public/lib/underscore/underscore-min'
    angularGrid: '../../../public/lib/ag-grid/website/dist/angularGrid-latest'
    reveal: '../../../public/lib/reveal.js/js/reveal'
    restangular: '../../../public/lib/restangular/dist/restangular'
    setting: './setting.json'
    register: './register.json'
    mqtt: '../../../public/lib/mqtt'
    socketio: '../../../public/lib/socket.io-client/dist/socket.io'
    angularSocketio: '../../../public/lib/angular-socket-io/socket'

  shim:
    jquery:
      exports: 'jquery'
    materialize:
      deps: ['jquery']
    bootstrap:
      deps: ['jquery']
    angular:
      exports: 'angular'
    ngRoute:
      deps: ['angular']
    ngResource:
      deps: ['angular']
    ngSanitize:
      deps: ['angular']
    btfMarkdown:
      deps: ['angular']
    marked:
      exports: 'marked'
    angularMarked:
      deps: ['angular', 'marked', 'highlight']
    angularHighlight:
      deps: ['angular', 'highlight']
    ngCookies:
      deps: ['angular']
    angularLocalStorage:
      deps: ['angular', 'ngCookies']
    tripledes:
      exports: 'CryptoJS'
    md5:
      exports: 'CryptoJS'
    'angular-moment':
      deps: ['moment', 'moment-locale-cn', 'angular']
    underscore:
      exports: '_'
    angularGrid:
      deps: ['angular']
    reveal:
      exports: 'Reveal'
    restangular:
      deps: ['angular']
    mqtt:
      exports: 'mqtt'
    socketio:
      exports: 'io'
    angularSocketio:
      deps: ['angular', 'socketio']

  packages: ['src']
  waitSeconds: 180

  name: "main"
  out: "bundle.js"

}
