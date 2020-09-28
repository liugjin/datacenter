// Generated by IcedCoffeeScript 108.0.13

/*
* File: dcim-router
* User: Dow
* Date: 8/22/2016
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['clc.foundation.web'], function(base) {
  var Router, exports;
  Router = (function(_super) {
    __extends(Router, _super);

    function Router(options, app, namespace) {
      if (namespace == null) {
        namespace = 'datacenter';
      }
      Router.__super__.constructor.call(this, options, app, namespace);
    }

    Router.prototype.route = function() {
      Router.__super__.route.apply(this, arguments);
      return this.matchUrl("getConfigurationInfo", "business#getConfigurationInfo", {
        via: 'GET'
      });
    };

    return Router;

  })(base.Router);
  return exports = {
    Router: Router
  };
});
