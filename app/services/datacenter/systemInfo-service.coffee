`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['clc.foundation.web', 'fs', "moment",'path'], (base, fs, moment,path) ->
  class SystemInfoService extends base.MqttService
    constructor: (options) ->
      super options
    initialize: (callback) ->
      super callback
      @subscribeDatabaseCmd()


    run: (callback) -> (
      src = path.join __dirname, "../../../../"
      if(fs.existsSync(src+"/version-info-log.json"))
        pageFilelog = JSON.parse(fs.readFileSync(src+"/version-info-log.json"))
        callback?(null, pageFilelog)
      else
        callback?(null, "暂无升级记录")
    )

    publishDatabaseSetting:(str) =>
        setting={
          str:str
        }
        @publishToMqtt "ping-callback", setting, {qos:0, retain: false}

    subscribeDatabaseCmd:->
      @process = require('child_process')
      @subscribeToMqtt "ping-network",{qos:0},(d)=>
        console.log("d",d)
        if(d and d.message.state)
          @ping = @process.spawn('ping',[d.message.ip]);
          iconv = require('iconv-lite')
          @ping.stdout.on('data',(data)=>
            str = iconv.decode(data,'cp936');
            @publishDatabaseSetting(str)
            console.log("str",str);
          )
          @ping.stderr.on('data',(data)=>
            console.log("ping stderr",data); 
          )
        else
          @ping.kill()
          @ping.on('close',(code,signal)=>
            console.log("子进程因收到信号 #{signal} 而终止")
          )
    
  exports =
    SystemInfoService: SystemInfoService