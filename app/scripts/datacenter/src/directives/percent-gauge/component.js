// Generated by IcedCoffeeScript 108.0.13

/*
* File: percent-gauge-directive
* User: David
* Date: 2019/03/16
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", 'echarts'], function(base, css, view, _, moment, echarts) {
  var PercentGaugeDirective, exports;
  PercentGaugeDirective = (function(_super) {
    __extends(PercentGaugeDirective, _super);

    function PercentGaugeDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.createOption = __bind(this.createOption, this);
      this.show = __bind(this.show, this);
      this.id = "percent-gauge";
      PercentGaugeDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    PercentGaugeDirective.prototype.setScope = function() {
      return {
        color: '='
      };
    };

    PercentGaugeDirective.prototype.setCSS = function() {
      return css;
    };

    PercentGaugeDirective.prototype.setTemplate = function() {
      return view;
    };

    PercentGaugeDirective.prototype.show = function(scope, element, attrs) {
      var gauge;
      if (!scope.parameters.equipment) {
        return;
      }
      gauge = element.find(".percent-gauge");
      return this.waitingLayout(this.$timeout, gauge, (function(_this) {
        return function() {
          var _ref;
          if ((_ref = scope.echart) != null) {
            _ref.dispose();
          }
          scope.echart = echarts.init(gauge[0]);
          return scope.$watch("signal.data.value", function(value) {
            var option;
            option = _this.createOption(scope, value);
            return scope.echart.setOption(option);
          });
        };
      })(this));
    };

    PercentGaugeDirective.prototype.createOption = function(scope, value) {
      var data, option, _ref;
      if (!value) {
        data = [
          {
            value: 100,
            itemStyle: {
              normal: {
                color: 'transparent'
              }
            }
          }
        ];
      } else {
        data = [
          {
            value: (100 - value).toFixed(2),
            itemStyle: {
              normal: {
                color: 'transparent'
              }
            }
          }, {
            value: value.toFixed(2),
            label: {
              normal: {
                show: true,
                position: 'center',
                color: 'white',
                formatter: '{c}%',
                textStyle: {
                  fontSize: '22',
                  fontWeight: 'bold'
                }
              },
              emphasis: {
                show: true,
                textStyle: {
                  fontSize: '26',
                  fontWeight: 'bold'
                }
              }
            },
            itemStyle: {
              normal: {
                color: (_ref = scope.parameters.color) != null ? _ref : new echarts.graphic.LinearGradient(1, 0, 0, 1, [
                  {
                    offset: 0,
                    color: 'rgb(78,112,234)'
                  }, {
                    offset: 1,
                    color: 'rgb(32,193,244)'
                  }
                ], false)
              }
            }
          }
        ];
      }
      option = {
        series: [
          {
            type: 'pie',
            radius: ['80%', '85%'],
            label: {
              normal: {
                show: false
              }
            },
            itemStyle: {
              normal: {
                color: 'rgba(158,158,158,0.3)'
              }
            },
            data: [
              {
                value: 100
              }
            ]
          }, {
            type: 'pie',
            radius: ['75%', '90%'],
            label: {
              normal: {
                show: false
              }
            },
            itemStyle: {
              normal: {
                color: 'rgba(158,158,158,0.3)'
              }
            },
            data: data
          }
        ]
      };
      return option;
    };

    PercentGaugeDirective.prototype.resize = function(scope) {
      var _ref;
      return (_ref = scope.echart) != null ? _ref.resize() : void 0;
    };

    PercentGaugeDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.echart) != null ? _ref.dispose() : void 0;
    };

    return PercentGaugeDirective;

  })(base.BaseDirective);
  return exports = {
    PercentGaugeDirective: PercentGaugeDirective
  };
});
