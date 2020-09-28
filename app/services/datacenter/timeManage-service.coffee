###
* File: changeStoreModel-service
* User: foam
* Date: 2020/05/22
* Desc: 
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.web', 'child_process','fs','underscore','path',], (base, process,fs,_,path) ->
  class TimeManageService extends base.MqttService
    constructor: (options) ->
      super options

    getServiceTime: (callback) -> (
      serviceTime =  new Date()
      callback?(null, {time:serviceTime})
    )
    changeServiceTime: (options, callback) -> (
      process.exec('date -s "' + options.parameters.time + '"')
      serviceTime =  new Date()
      callback?(null, {time: serviceTime})
    )
    saveNTPIP: (options, callback) -> (
      console.log("options",options)
      process.exec("ntpdate -u #{options.parameters.ip}")
      src = path.join __dirname, "../../../../"
      if(!fs.existsSync("#{src}/ntp.json"))
        fs.writeFileSync("#{src}/ntp.json",JSON.stringify([]))
      ntpConf = JSON.parse(fs.readFileSync("#{src}/ntp.json"))
      data = {"ntpIP":options.parameters.ip}
      if(ntpConf.length>0)
        ntpConf.splice(0,ntpConf.length)
      ntpConf.push(data)
      infos = JSON.stringify ntpConf, null, 2
      fs.writeFileSync("#{src}/ntp.json", infos)
      serviceTime =  new Date()
      callback?(null, { ntpIp: options.parameters.ip, time: serviceTime })
    )

    getNTPIP: (callback)->
      src = path.join __dirname, "../../../../"
      if(fs.existsSync("#{src}/ntp.json"))
        ntpConf = JSON.parse(fs.readFileSync("#{src}/ntp.json"))
        console.log("ntpConf",ntpConf)
        callback?(null, ntpConf)
#       console.log("函数调用")
#       operateText= (arr) ->
#         patt1 = /server(\s)*((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))/g     #匹配server xxx.xxx.xxx.xxx
#         item = _.filter arr, (it)->it.match patt1
#         console.log 'item:',item
#         return null if not item.length
#         return item[0].split(" ")[1]

#       ntpConfPath = "/etc/ntp.conf"
# #      ntpConfPath = "D:/test.conf"  #得到npt配置文件  从里面提取ntp服务地址
#       if fs.existsSync ntpConfPath
#         file = (fs.readFileSync ntpConfPath).toString()
#         ntpConf = file.split(/[\n\r]/)
# #        console.log ntpConf
# #        console.log 'data',operateText ntpConf
#         ntpip = operateText(ntpConf)
#         result = ntpip || "111.111.111.111"
#         callback?(null, { ntpip: result})
      else
        callback {_err:"未找到ntp.json"}


  exports =
    TimeManageService: TimeManageService
