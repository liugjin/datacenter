###
* 对3d视图的操作
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define(['underscore', "d3"], (_, d3) -> 
  class ToolTip
    constructor: (element) -> (
      @element = element[0]
      d3.select(@element)
        .append("div")
        .attr("class", "tooltip")
    )
    
    hide: () => (
      d3.select(@element)
        .select(".tooltip")
        .attr("style", "display: none")
    )
    
    show: (data, event) => (
      name = "--"
      top = (event.offsetY + 8).toFixed(0)
      left = (event.offsetX + 10).toFixed(0)
      if data && data?.length == 1
        name = data[0].name
      else if data && data?.length > 1
        name = data?.length + "个设备: <br />"
        _.each(data, (d) => name += "#{d.name}<br />")
      d3.select(@element)
        .select(".tooltip")
        .attr("style", "top: #{top}px;left: #{left}px")
        .html(name)
    )
    
  return { ToolTip: ToolTip }
)