// Generated by IcedCoffeeScript 108.0.13

/*
* File: lineorbar-echart-directive
* User: David
* Date: 2020/01/03
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "echarts"], function(base, css, view, _, moment, echarts) {
  var LineorbarEchartDirective, exports;
  LineorbarEchartDirective = (function(_super) {
    __extends(LineorbarEchartDirective, _super);

    function LineorbarEchartDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.show = __bind(this.show, this);
      this.id = "lineorbar-echart";
      LineorbarEchartDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    LineorbarEchartDirective.prototype.setScope = function() {};

    LineorbarEchartDirective.prototype.setCSS = function() {
      return css;
    };

    LineorbarEchartDirective.prototype.setTemplate = function() {
      return view;
    };

    LineorbarEchartDirective.prototype.show = function(scope, element, attrs) {
      var chartelement, max;
      scope.mychart = null;
      chartelement = element.find('.chart-line');
      scope.mychart = echarts.init(chartelement[0]);
      max = 31;
      return scope.$watch("parameters.chartValues", (function(_this) {
        return function(data) {
          var d, i, index, legendData, option, series, seriesData, type, value, values, xAxisData, yNameData, _i, _j, _legendData, _len, _len1;
          values = _.sortBy(_.sortBy(data, 'index'), 'name');
          if (!type) {
            type = 'line';
          }
          legendData = _.uniq(_.pluck(values, 'name'));
          xAxisData = _.uniq(_.pluck(values, 'key'));
          yNameData = _.uniq(_.pluck(values, 'category'));
          if (_.isEmpty(yNameData)) {
            yNameData = [''];
          }
          seriesData = [];
          for (index = _i = 0, _len = legendData.length; _i < _len; index = ++_i) {
            value = legendData[index];
            data = {
              name: value,
              data: _.pluck(_.where(values, {
                name: value,
                category: yNameData[index]
              }), 'value'),
              yAxisIndex: index
            };
            seriesData.push(data);
          }
          series = [
            {
              name: '',
              type: 'line',
              symbol: "none",
              smooth: true,
              data: [],
              lineStyle: {
                normal: {
                  color: {
                    type: 'linear',
                    x: 0,
                    y: 0,
                    x2: 0,
                    y2: 1,
                    colorStops: [
                      {
                        offset: 0,
                        color: '#1A45A2'
                      }, {
                        offset: 1,
                        color: '#00E7EE'
                      }
                    ]
                  }
                }
              },
              areaStyle: {
                normal: {
                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                    {
                      offset: 0,
                      color: '#1A45A2'
                    }, {
                      offset: 0.34,
                      color: '#00E7EE'
                    }, {
                      offset: 1,
                      color: '#00e7ee33'
                    }
                  ])
                }
              }
            }, {
              name: '',
              type: 'line',
              smooth: true,
              symbol: "none",
              data: [],
              lineStyle: {
                normal: {
                  color: {
                    type: 'linear',
                    x: 0,
                    y: 0,
                    x2: 0,
                    y2: 1,
                    colorStops: [
                      {
                        offset: 0,
                        color: '#90D78A'
                      }, {
                        offset: 1,
                        color: '#1CAA9E'
                      }
                    ]
                  }
                }
              },
              areaStyle: {
                normal: {
                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                    {
                      offset: 0,
                      color: '#90D78A'
                    }, {
                      offset: 0.34,
                      color: '#1CAA9E'
                    }, {
                      offset: 1,
                      color: '#1caa9e33'
                    }
                  ])
                }
              }
            }, {
              name: '',
              type: 'line',
              smooth: true,
              symbol: "none",
              data: [],
              lineStyle: {
                normal: {
                  color: {
                    type: 'linear',
                    x: 0,
                    y: 0,
                    x2: 0,
                    y2: 1,
                    colorStops: [
                      {
                        offset: 0,
                        color: '#F9722C'
                      }, {
                        offset: 1,
                        color: '#FF085C'
                      }
                    ]
                  }
                }
              },
              areaStyle: {
                normal: {
                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                    {
                      offset: 0,
                      color: '#F9722C'
                    }, {
                      offset: 0.34,
                      color: '#FF085C'
                    }, {
                      offset: 1,
                      color: '#ff085c33'
                    }
                  ])
                }
              }
            }
          ];
          if (xAxisData.length > max) {
            xAxisData = xAxisData.slice(xAxisData.length - max, xAxisData.length);
          }
          for (i = _j = 0, _len1 = seriesData.length; _j < _len1; i = ++_j) {
            d = seriesData[i];
            series[i].name = yNameData[i];
            if (d.data.length > max) {
              series[i].data = d.data.slice(d.data.length - max, d.data.length);
            } else {
              series[i].data = d.data;
            }
            if (xAxisData.length < (series[i].data.length - 1)) {
              series[i].data.slice(0, series[i].data.length - 1);
            }
          }
          _legendData = _.map(legendData, function(d, i) {
            return {
              name: yNameData[i],
              icon: "image://" + _this.getComponentPath('image/color' + (i + 1) + '.svg')
            };
          });
          option = {
            tooltip: {
              trigger: "axis"
            },
            legend: {
              show: true,
              orient: "horizontal",
              right: "10%",
              textStyle: {
                fontSize: 14,
                color: "#FFFFFF"
              },
              data: _legendData
            },
            toolbox: {
              show: true,
              right: 20,
              feature: {
                dataZoom: {
                  show: false
                },
                dataView: {
                  show: false
                },
                magicType: {
                  type: ['line', 'bar']
                },
                restore: {
                  show: false
                },
                saveAsImage: {
                  show: false
                }
              }
            },
            xAxis: [
              {
                data: xAxisData,
                boundaryGap: false,
                nameLocation: "middle",
                axisLine: {
                  lineStyle: {
                    color: "#204BAD"
                  }
                },
                axisLabel: {
                  textStyle: {
                    color: "#A2CAF8"
                  },
                  rotate: 30,
                  interval: 0,
                  fontSize: 14,
                  margin: 16
                }
              }
            ],
            yAxis: [
              {
                type: 'value',
                axisLine: {
                  lineStyle: {
                    color: "#204BAD"
                  }
                },
                axisLabel: {
                  textStyle: {
                    color: "#A2CAF8"
                  }
                },
                splitLine: {
                  lineStyle: {
                    color: ["#204BAD"]
                  }
                }
              }
            ],
            series: series.slice(0, seriesData.length)
          };
          if (typeof scope.parameters.legend === "boolean" && !scope.parameters.legend) {
            option.legend.show = false;
          }
          if (typeof scope.parameters["switch"] === "boolean" && !scope.parameters["switch"]) {
            option.toolbox.show = false;
          }
          if (_.has(scope.parameters, "tip")) {
            option.tooltip.formatter = scope.parameters.tip;
          }
          scope.mychart.clear();
          return scope.mychart.setOption(option);
        };
      })(this));
    };

    LineorbarEchartDirective.prototype.resize = function(scope) {
      return this.$timeout((function(_this) {
        return function() {
          var _ref;
          return (_ref = scope.mychart) != null ? _ref.resize() : void 0;
        };
      })(this), 0);
    };

    LineorbarEchartDirective.prototype.dispose = function(scope) {
      var _ref;
      return (_ref = scope.mychart) != null ? _ref.dispose() : void 0;
    };

    return LineorbarEchartDirective;

  })(base.BaseDirective);
  return exports = {
    LineorbarEchartDirective: LineorbarEchartDirective
  };
});