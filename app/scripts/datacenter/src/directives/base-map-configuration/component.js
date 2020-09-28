// Generated by IcedCoffeeScript 108.0.11

/*
* File: base-map-configuration-directive
* User: David
* Date: 2020/04/27
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment"], function(base, css, view, _, moment) {
  var BaseMapConfigurationDirective, exports;
  BaseMapConfigurationDirective = (function(_super) {
    __extends(BaseMapConfigurationDirective, _super);

    function BaseMapConfigurationDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.blobToFile = __bind(this.blobToFile, this);
      this.dataURLtoBlob = __bind(this.dataURLtoBlob, this);
      this.show = __bind(this.show, this);
      this.id = "base-map-configuration";
      BaseMapConfigurationDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    BaseMapConfigurationDirective.prototype.setScope = function() {};

    BaseMapConfigurationDirective.prototype.setCSS = function() {
      return css;
    };

    BaseMapConfigurationDirective.prototype.setTemplate = function() {
      return view;
    };

    BaseMapConfigurationDirective.prototype.show = function(scope, element, attrs) {
      scope.imgUrl = "";
      scope.fileNameStr = "";
      scope.imgshow = false;
      scope.fileUpload = (function(_this) {
        return function() {
          var input, reads;
          scope.fileNameStr = "";
          input = $(element).find("#upload");
          input.click();
          input.click(function() {
            return input.val('');
          });
          reads = new FileReader();
          return input.on('change', function(evt) {
            var file, imgArr, strSrc, _ref, _ref1;
            file = (_ref = input[0]) != null ? (_ref1 = _ref.files) != null ? _ref1[0] : void 0 : void 0;
            scope.file = file;
            imgArr = file.name.split('.');
            strSrc = imgArr[imgArr.length - 1].toLowerCase();
            if (strSrc.localeCompare('jpg') === 0 || strSrc.localeCompare('jpeg') === 0 || strSrc.localeCompare('png') === 0 || strSrc.localeCompare('svg') === 0) {
              scope.fileNameStr = file.name;
              reads.readAsDataURL(file);
              return reads.onload = function(e) {
                scope.imgUrl = e.target.result;
                scope.imgshow = true;
                return scope.$applyAsync();
              };
            } else {
              return _this.display("暂不支持该格式的图片上传!!", 500);
            }
          });
        };
      })(this);
      return scope.confirmSha = (function(_this) {
        return function() {
          var blob, file, uploadUrl;
          if (scope.imgUrl === '') {
            _this.display("上传失败,请先上传现场图片!!", 500);
            return;
          }
          blob = _this.dataURLtoBlob(scope, scope.imgUrl);
          file = _this.blobToFile(blob, scope.file.name);
          uploadUrl = setting.urls.uploadUrl + "/" + file.name;
          return _this.commonService.uploadService.upload(file, null, uploadUrl, function(err, resource) {
            if (err) {
              return _this.display("上传失败!!", 500);
            }
            scope.station.model.image = resource.resource + resource.extension;
            return scope.station.save(function(err, model) {});
          });
        };
      })(this);
    };

    BaseMapConfigurationDirective.prototype.dataURLtoBlob = function(scope, dataurl) {
      var arr, bstr, n, u8arr;
      arr = dataurl.split(',');
      bstr = atob(arr[1]);
      n = bstr.length;
      u8arr = new Uint8Array(n);
      while (n--) {
        u8arr[n] = bstr.charCodeAt(n);
      }
      return new Blob([u8arr], {
        type: scope.file.type
      });
    };

    BaseMapConfigurationDirective.prototype.blobToFile = function(theBlob, fileName) {
      theBlob.lastModifiedDate = new Date();
      theBlob.name = fileName;
      return theBlob;
    };

    BaseMapConfigurationDirective.prototype.resize = function(scope) {};

    BaseMapConfigurationDirective.prototype.dispose = function(scope) {};

    return BaseMapConfigurationDirective;

  })(base.BaseDirective);
  return exports = {
    BaseMapConfigurationDirective: BaseMapConfigurationDirective
  };
});