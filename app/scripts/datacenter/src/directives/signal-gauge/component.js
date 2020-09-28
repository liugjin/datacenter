// Generated by IcedCoffeeScript 108.0.13

/*
* File: signal-gauge-directive
* User: David
* Date: 2019/02/20
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", 'echarts'], function(base, css, view, _, moment, echarts) {
  var SignalGaugeDirective, exports;
  SignalGaugeDirective = (function(_super) {
    __extends(SignalGaugeDirective, _super);

    function SignalGaugeDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "signal-gauge";
      SignalGaugeDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    SignalGaugeDirective.prototype.setScope = function() {
      return {
        min: '=',
        max: '='
      };
    };

    SignalGaugeDirective.prototype.setCSS = function() {
      return css;
    };

    SignalGaugeDirective.prototype.setTemplate = function() {
      return view;
    };

    SignalGaugeDirective.prototype.show = function(scope, element, attrs) {
      var gauge;
      gauge = element.find(".signal-gauge");
      return this.waitingLayout(this.$timeout, gauge, (function(_this) {
        return function() {
          var _ref;
          if ((_ref = scope.echart) != null) {
            _ref.dispose();
          }
          scope.echart = echarts.init(gauge[0]);
          return scope.$watch("signal.data.value", function(val) {
            var option, value;
            value = val != null ? val : 0;
            option = _this.createOption(value, scope.parameters.min, scope.parameters.max);
            return scope.echart.setOption(option);
          }, true);
        };
      })(this));
    };

    SignalGaugeDirective.prototype.createOption = function(value, min, max) {
      var multiple, option;
      multiple = 1;
      option = {
        series: [
          {
            type: 'gauge',
            splitNumber: 3,
            startAngle: 180,
            endAngle: 0,
            min: min != null ? min : 1,
            max: max != null ? max : 4,
            radius: '100%',
            axisLine: {
              lineStyle: {
                width: 3 * multiple,
                color: [[0.3, 'lime'], [0.7, 'orange'], [1, '#ff4500']],
                shadowColor: '#fff',
                shadowBlur: 10
              }
            },
            axisTick: {
              lineStyle: {
                color: 'auto',
                shadowColor: '#fff',
                shadowBlur: 10
              },
              length: 15,
              splitNumber: 10
            },
            splitLine: {
              length: 24,
              lineStyle: {
                color: '#fff',
                width: 3 * multiple,
                shadowColor: '#fff',
                shadowBlur: 10
              }
            },
            axisLabel: {
              distance: 2,
              textStyle: {
                color: '#fff',
                fontWeight: 'bolder',
                fontSize: 12 * multiple,
                shadowColor: '#fff',
                shadowBlur: 10
              }
            },
            itemStyle: {
              normal: {
                color: 'transparent',
                borderColor: 'rgba(72,207,255)',
                borderWidth: 2 * multiple
              },
              emphasis: {
                color: 'transparent',
                borderColor: 'rgba(72,207,255)',
                borderWidth: 2 * multiple
              }
            },
            pointer: {
              length: '60%',
              width: 4
            },
            detail: {
              textStyle: {
                fontWeight: 'bolder',
                color: 'auto'
              },
              offsetCenter: ['0%', '-20%']
            },
            data: [
              {
                value: value != null ? value.toFixed(2) : void 0
              }
            ]
          }
        ]
      };
      return option;
    };

    SignalGaugeDirective.prototype.resize = function(scope) {
      var _ref;
      return (_ref = scope.echart) != null ? _ref.resize() : void 0;
    };

    SignalGaugeDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.echart) != null ? _ref.dispose() : void 0;
    };

    return SignalGaugeDirective;

  })(base.BaseDirective);
  return exports = {
    SignalGaugeDirective: SignalGaugeDirective
  };
});