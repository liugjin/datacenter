###
* File: base-map-configuration-directive
* User: David
* Date: 2020/04/27
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment"], (base, css, view, _, moment) ->
  class BaseMapConfigurationDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "base-map-configuration"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      scope.imgUrl = ""
      scope.fileNameStr =""
      scope.imgshow = false
      # 给Btn添加file属性
      scope.fileUpload= () =>
        scope.fileNameStr = ""
        input = $(element).find("#upload")
        input.click()
        input.click(()=>
          input.val('');
        );
        reads = new FileReader()
        input.on('change', (evt)=>
          file = input[0]?.files?[0]
          scope.file = file
          imgArr = file.name.split('.')
          strSrc = imgArr[imgArr.length - 1].toLowerCase()
          if (strSrc.localeCompare('jpg') == 0 or strSrc.localeCompare('jpeg') == 0 or strSrc.localeCompare('png') == 0 or strSrc.localeCompare('svg') == 0)
            scope.fileNameStr = file.name
            reads.readAsDataURL(file)
            reads.onload = (e)=>
              scope.imgUrl = e.target.result
              scope.imgshow = true
              scope.$applyAsync()
          else
            @display("暂不支持该格式的图片上传!!", 500)
        );


      # 确认上传
      scope.confirmSha =()=>
        if scope.imgUrl == ''
          @display("上传失败,请先上传现场图片!!", 500)
          return
        blob = @dataURLtoBlob(scope,scope.imgUrl)
        file = @blobToFile(blob, scope.file.name)
        uploadUrl = setting.urls.uploadUrl + "/" + file.name
        @commonService.uploadService.upload(file,null,uploadUrl,(err, resource) =>
          return @display("上传失败!!", 500) if err
          scope.station.model.image = resource.resource + resource.extension
          scope.station.save (err, model) =>
            
        )

    #将base64转换为blob
    dataURLtoBlob:(scope,dataurl)=>
      arr = dataurl.split(',')
      bstr = atob(arr[1])
      n = bstr.length
      u8arr = new Uint8Array(n)
      while(n--)
        u8arr[n] = bstr.charCodeAt(n)
      return new Blob([u8arr], { type: scope.file.type })
    
    #将blob转换为file
    blobToFile:(theBlob, fileName)=>
      theBlob.lastModifiedDate = new Date()
      theBlob.name = fileName
      return theBlob
 
    resize: (scope)->

    dispose: (scope)->


  exports =
    BaseMapConfigurationDirective: BaseMapConfigurationDirective