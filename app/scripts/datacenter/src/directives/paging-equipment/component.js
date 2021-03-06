// Generated by IcedCoffeeScript 108.0.13

/*
* File: paging-equipment-directive
* User: David
* Date: 2019/12/12
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var PagingEquipmentDirective, exports;
  PagingEquipmentDirective = (function(_super) {
    __extends(PagingEquipmentDirective, _super);

    function PagingEquipmentDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "paging-equipment";
      PagingEquipmentDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    PagingEquipmentDirective.prototype.setScope = function() {};

    PagingEquipmentDirective.prototype.setCSS = function() {
      return css;
    };

    PagingEquipmentDirective.prototype.setTemplate = function() {
      return view;
    };

    PagingEquipmentDirective.prototype.show = function(scope, element, attrs) {
      var checkPage, initPage;
      scope.pages = {
        page: [],
        current: 1
      };
      scope.count = 1;
      initPage = (function(_this) {
        return function(len) {
          var arr, count, x, _i, _j;
          arr = [];
          if (len > 0) {
            count = Math.ceil(len / 10);
            if (count <= 10) {
              for (x = _i = count; count <= 1 ? _i <= 1 : _i >= 1; x = count <= 1 ? ++_i : --_i) {
                arr.push(x);
              }
            } else {
              for (x = _j = count; count <= 1 ? _j <= 1 : _j >= 1; x = count <= 1 ? ++_j : --_j) {
                if (x <= 3 || x >= count - 2) {
                  arr.push(x);
                } else if (x === 4) {
                  arr.push(-2);
                } else if (x === count - 3) {
                  arr.push(-1);
                }
              }
            }
          }
          return scope.pages = {
            page: arr,
            current: 1
          };
        };
      })(this);
      checkPage = function(pages) {
        var _pageItems, _pages;
        _pages = _.uniq(pages);
        _pageItems = _.filter(_pages, function(d) {
          return d > 0;
        });
        if (_pageItems.length === 6) {
          return pages;
        } else {
          if (_pages[_pages.length - 1] === 0) {
            _pageItems.push(-5);
          }
          if (_pages[0] === -3) {
            _pageItems.unshift(-4);
          }
          return _pageItems;
        }
      };
      scope.update = (function(_this) {
        return function(page) {
          var count, len, max, min;
          if (scope.pages.current === page) {
            return;
          }
          count = Math.ceil(scope.count / 10);
          if (page <= 0 && count > 10) {
            if (scope.pages.page.indexOf(-1) === -1 && scope.pages.page.indexOf(-2) === -1) {
              if (page === -4) {
                max = _.max(scope.pages.page);
                min = _.min(_.filter(scope.pages.page, function(p) {
                  return p > 0;
                }));
                scope.pages.page = [max + 3, max + 2, max + 1, -1, -2, min + 2, min + 1, min];
              } else if (page === -5) {
                max = _.max(scope.pages.page);
                min = _.min(_.filter(scope.pages.page, function(p) {
                  return p > 0;
                }));
                scope.pages.page = [max, max - 1, max - 2, -1, -2, min - 1, min - 2, min - 3];
              }
              if (scope.pages.page[0] !== count) {
                scope.pages.page.unshift(-3);
              }
              if (scope.pages.page[scope.pages.page.length - 1] !== count) {
                scope.pages.page.push(0);
              }
              return scope.$applyAsync();
            }
            len = scope.pages.page.length;
            if (page === 0) {
              scope.pages.page = _.map(scope.pages.page, function(d, i) {
                if (i >= 5 && d > 0) {
                  return d - 3;
                } else {
                  return d;
                }
              });
              if (scope.pages.page[len - 1] === 0 && scope.pages.page[len - 2] === 1) {
                scope.pages.page = _.filter(scope.pages.page, function(d) {
                  return d !== 0;
                });
              }
            } else if (page === -1) {
              scope.pages.page = _.map(scope.pages.page, function(d, i) {
                if (i <= 3 && d > 0) {
                  return d - 3;
                } else {
                  return d;
                }
              });
              if (scope.pages.page[0] > 0 && scope.pages.page !== count) {
                scope.pages.page.unshift(-3);
              }
            } else if (page === -2) {
              scope.pages.page = _.map(scope.pages.page, function(d, i) {
                if (i >= 5 && d > 0) {
                  return d + 3;
                } else {
                  return d;
                }
              });
              if (scope.pages.page[len - 1] > 1) {
                scope.pages.page.push(0);
              }
            } else if (page === -3) {
              scope.pages.page = _.map(scope.pages.page, function(d, i) {
                if (i <= 3 && d > 0) {
                  return d + 3;
                } else {
                  return d;
                }
              });
              if (scope.pages.page[1] === count) {
                scope.pages.page = _.filter(scope.pages.page, function(d) {
                  return d !== -3;
                });
              }
            }
            scope.pages.page = checkPage(scope.pages.page);
            return scope.$applyAsync();
          }
          scope.pages.current = page;
          _this.commonService.publishEventBus('pageTemplate', page);
          return scope.$applyAsync();
        };
      })(this);
      scope.$watch("parameters.count", (function(_this) {
        return function(count) {
          if (scope.count !== count) {
            scope.count = count;
            return initPage(scope.count);
          }
        };
      })(this));
      return initPage(scope.parameters.count);
    };

    PagingEquipmentDirective.prototype.resize = function(scope) {};

    PagingEquipmentDirective.prototype.dispose = function(scope) {};

    return PagingEquipmentDirective;

  })(base.BaseDirective);
  return exports = {
    PagingEquipmentDirective: PagingEquipmentDirective
  };
});
