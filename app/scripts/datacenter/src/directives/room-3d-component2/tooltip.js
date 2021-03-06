// Generated by IcedCoffeeScript 108.0.12

/*
* 对3d视图的操作
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['underscore', "d3"], function(_, d3) {
  var ToolTip;
  ToolTip = (function() {
    function ToolTip(element) {
      this.show = __bind(this.show, this);
      this.hide = __bind(this.hide, this);
      this.element = element[0];
      d3.select(this.element).append("div").attr("class", "tooltip");
    }

    ToolTip.prototype.hide = function() {
      return d3.select(this.element).select(".tooltip").attr("style", "display: none");
    };

    ToolTip.prototype.show = function(data, event) {
      var left, name, top;
      name = "--";
      top = (event.offsetY + 8).toFixed(0);
      left = (event.offsetX + 10).toFixed(0);
      if (data && (data != null ? data.length : void 0) === 1) {
        name = data[0].name;
      } else if (data && (data != null ? data.length : void 0) > 1) {
        name = (data != null ? data.length : void 0) + "个设备: <br />";
        _.each(data, (function(_this) {
          return function(d) {
            return name += "" + d.name + "<br />";
          };
        })(this));
      }
      return d3.select(this.element).select(".tooltip").attr("style", "top: " + top + "px;left: " + left + "px").html(name);
    };

    return ToolTip;

  })();
  return {
    ToolTip: ToolTip
  };
});
