// Generated by IcedCoffeeScript 108.0.12

/*
* File: drop-down-directive
* User: David
* Date: 2018/11/23
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var DropDownDirective, exports;
  DropDownDirective = (function(_super) {
    __extends(DropDownDirective, _super);

    function DropDownDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "drop-down";
      DropDownDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    DropDownDirective.prototype.setScope = function() {};

    DropDownDirective.prototype.setCSS = function() {
      return css;
    };

    DropDownDirective.prototype.setTemplate = function() {
      return view;
    };

    DropDownDirective.prototype.show = function($scope, element, attrs) {
      var allSelect, orderItem, setItemName;
      $scope.selectedName = '';
      $scope.itemArr = [];
      allSelect = {
        id: 'all',
        name: '全选',
        checked: true
      };
      $scope.$watch('parameters.all', (function(_this) {
        return function(allItems) {
          var i, item, _i, _ref, _results;
          if (!allItems) {
            return;
          }
          $scope.all = allItems;
          _results = [];
          for (i = _i = 0, _ref = Math.ceil((allItems != null ? allItems.length : void 0) / 10); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
            item = {
              index: i,
              items: allItems.slice(i * 10, (i + 1) * 10)
            };
            _results.push($scope.itemArr.push(item));
          }
          return _results;
        };
      })(this));
      $scope.$watch('parameters.selected', (function(_this) {
        return function(selectedItem) {
          if (!selectedItem) {
            return;
          }
          return setItemName(selectedItem);
        };
      })(this));
      $scope.selectOne = (function(_this) {
        return function() {
          var selected;
          selected = [];
          _.each($scope.all, function(item) {
            if (item.checked) {
              return selected.push(item.id.toString());
            }
          });
          _this.publishEventBus("drop-down-select", {
            origin: $scope.parameters.origin,
            selected: selected
          });
          return setItemName(selected);
        };
      })(this);
      $scope.selectItem = function($event, item) {
        var index;
        index = _.indexOf($scope.parameters.selected, item.id.toString());
        if (index > -1) {
          $scope.parameters.selected.splice(index, 1);
        } else {
          if ($($event.target).is(':checked')) {
            $scope.parameters.selected.push(item.id.toString());
          }
        }
        return orderItem($scope.parameters.selected);
      };
      $scope.dropDown = (function(_this) {
        return function($event) {
          $('.venting').slideUp(500);
          return $($($event.target).siblings('.venting')[0]).slideDown(500);
        };
      })(this);
      orderItem = (function(_this) {
        return function(orderItem) {
          var current, item, newArr, _i, _len, _ref;
          newArr = [];
          _ref = $scope.all;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            current = _.find(orderItem, function(single) {
              return single === item.id.toString();
            });
            if (current) {
              newArr.push(current);
            }
          }
          return setItemName(newArr);
        };
      })(this);
      return setItemName = (function(_this) {
        return function(selectedItem) {
          var current, item, _i, _len;
          $scope.selectedName = '';
          for (_i = 0, _len = selectedItem.length; _i < _len; _i++) {
            item = selectedItem[_i];
            current = _.find($scope.all, function(single) {
              return single.id.toString() === item;
            });
            if (current) {
              $scope.selectedName += current.name + ',';
            }
          }
          return $scope.selectedName = $scope.selectedName.slice(0, $scope.selectedName.length - 1);
        };
      })(this);
    };

    DropDownDirective.prototype.resize = function($scope) {};

    DropDownDirective.prototype.dispose = function($scope) {};

    return DropDownDirective;

  })(base.BaseDirective);
  return exports = {
    DropDownDirective: DropDownDirective
  };
});