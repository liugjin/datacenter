// Generated by IcedCoffeeScript 108.0.12

/*
* File: 3d/room
* User: Hardy
* Date: 2018/08/22
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
define(["underscore", "threejs", "orbit-controls", "tween", "./thing"], function(_, THREE, orbitControls, TWEEN, Thing) {
  var Room, exports, roomList;
  if (!window.debugR) {
    window.debugR = {};
  }
  roomList = {};
  window.debugR.roomList = roomList;
  Room = (function() {
    function Room(name, element, options) {
      var cameraOptions, stopEvent;
      if (roomList[name]) {
        return roomList[name];
      }
      this.initDb();
      this.name = name;
      this.options = options;
      roomList[name] = this;
      this.thingList = {};
      this.groupList = {};
      this.renderOrder = [];
      this.element = element;
      this.innerWidth = element.clientWidth;
      this.innerHeight = element.clientHeight;
      this.getOffset();
      this.scene = new THREE.Scene();
      this.scene.name = name + '_scene';
      this.renderer = new THREE.WebGLRenderer(options.renderder);
      this.renderer.setSize(this.innerWidth, this.innerHeight);
      this.renderer.setClearColor(0x000000, 0);
      element.appendChild(this.renderer.domElement);
      cameraOptions = options.camera;
      cameraOptions.aspect = this.innerWidth / this.innerHeight;
      if (!cameraOptions.aspect) {
        return console.error("请检查样式，保证canvas有占用实际空间，否则无法渲染。");
      }
      this.initCamera(cameraOptions);
      this.animateList = [];
      this.raycaster = new THREE.Raycaster();
      this.mouse = new THREE.Vector2();
      this.raycaster.checkList = [];
      this.raycaster.recursiveFlag = false;
      this.raycaster.callback = {
        click: null,
        dblclick: null,
        mousemove: null
      };
      this.isDisposed = false;
      this.selectedThing = null;
      this.animate();
      this.addAnimate('updateRaycaster', this.updateRaycaster.bind(this));
      window.addEventListener('resize', this.resize.bind(this));
      element.addEventListener('click', this.updateMouse.bind(this));
      element.addEventListener("dblclick", this.updateMouse.bind(this));
      element.addEventListener("mousemove", this.updateMouse.bind(this));
      if (options.orbitControl) {
        stopEvent = (function(_this) {
          return function(event) {
            if (event.button === 2) {
              event.preventDefault();
              event.stopPropagation();
              return event.stopImmediatePropagation();
            }
          };
        })(this);
        this.renderer.domElement.addEventListener("mousedown", stopEvent);
        this.orbitControl = new THREE.OrbitControls(this.camera, this.renderer.domElement);
      }
      if (!THREE.Cache.enabled) {
        THREE.Cache.enabled = true;
      }
    }

    Room.prototype.initCamera = function(options) {
      var camera;
      switch (options.type) {
        case 'PerspectiveCamera':
          if (!options.aspect) {
            return console.error("PerspectiveCamera should have aspect parameter.");
          } else {
            this.camera = new THREE.PerspectiveCamera(options.fov, options.aspect, 0.1, 100000);
          }
          break;
        default:
          console.error('init camera error: don\'t support ', options.type);
          break;
      }
      camera = this.camera;
      camera.position.set(options.x || 0, options.y || 0, options.z || 0);
      return camera.rotation.set(options.rotationX * Math.PI / 180 || 0, options.rotationY * Math.PI / 180 || 0, options.rotationz * Math.PI / 180 || 0);
    };

    Room.prototype.addAnimate = function(key, func) {
      var index, _ref;
      index = _.findLastIndex(this.animateList, {
        key: key
      });
      if (index === -1) {
        return this.animateList.push({
          key: key,
          func: func
        });
      } else {
        return (_ref = this.animateList[index]) != null ? _ref.func = func : void 0;
      }
    };

    Room.prototype.removeAnimate = function(key) {
      var index;
      index = _.findLastIndex(this.animateList, {
        key: key
      });
      if (index === -1) {
        return console.log('err: key is not in list', key, this.animateList);
      }
      return this.animateList.splice(index, 1);
    };

    Room.prototype.animate = function() {
      var animateFun;
      if (!this.isDisposed) {
        animateFun = this.animate.bind(this);
        requestAnimationFrame(animateFun);
      }
      this.animateList.forEach(function(obj) {
        if (_.isFunction(obj.func)) {
          return obj.func();
        }
      });
      TWEEN.update();
      if (this.composer) {
        return this.composer.render();
      } else {
        return this.renderer.render(this.scene, this.camera);
      }
    };

    Room.prototype.setCamera = function(options) {
      var camera;
      if (!options) {
        return console.log("setCamera options is null");
      }
      camera = this.camera;
      if (options.fov) {
        camera.fov = options.fov;
      }
      camera.position.set(options.x || 0, options.y || 0, options.z || 0);
      camera.rotation.set(options.rotationX * Math.PI / 180 || 0, options.rotationY * Math.PI / 180 || 0, options.rotationz * Math.PI / 180 || 0);
      camera.updateProjectionMatrix();
      if (this.orbitControl) {
        return this.orbitControl.update();
      }
    };

    Room.prototype.initScene = function(obj) {
      var scene;
      this.resize();
      scene = obj;
      this.scene = obj;
      if (scene.userData) {
        this.setCamera(scene.userData);
      }
      scene.background = null;
      this.generatorThings();
      this.setRaycasterCheckList(this.thingList, true, this.raycaster.callback);
      this.renderer.render(this.scene, this.camera);
      return this.scene.background = null;
    };

    Room.prototype.loadSceneByUrl = function(url, callback, preloadCallback, cache) {
      var loader, onErrors, onLoad, onProgress;
      loader = new THREE.ObjectLoader;
      onLoad = (function(_this) {
        return function(obj) {
          if (cache) {
            _this.setDataToDataBase(url, obj);
          }
          _this.initScene(obj);
          return typeof callback === "function" ? callback(null, obj) : void 0;
        };
      })(this);
      onProgress = function(xhr) {
        return typeof preloadCallback === "function" ? preloadCallback((xhr.loaded / xhr.total * 100).toFixed(0)) : void 0;
      };
      onErrors = function(xhr) {
        return console.error('加载3D文件失败：', xhr);
      };
      return loader.load(url, onLoad, onProgress, onErrors);
    };

    Room.prototype.loadSceneByJSON = function(json, callback) {
      var loader, object;
      loader = new THREE.ObjectLoader;
      object = JSON.parse(json);
      return loader.parse(object, (function(_this) {
        return function(obj) {
          _this.initScene(obj);
          return typeof callback === "function" ? callback(null, obj) : void 0;
        };
      })(this));
    };

    Room.prototype.loadScene = function(url, callback, preloadCallback) {
      var load;
      load = (function(_this) {
        return function() {
          return _this.getDataFromDatabase(url, function(err, json) {
            if (err) {
              return console.warn(err);
            }
            if (json) {
              return _this.loadSceneByJSON(json, callback);
            } else {
              return _this.loadSceneByUrl(url, callback, preloadCallback, true);
            }
          });
        };
      })(this);
      if (!this.db) {
        return this.dbCallback = (function(_this) {
          return function(err) {
            if (err) {
              return console.warn(err);
            }
            return load();
          };
        })(this);
      } else {
        return load();
      }
    };

    Room.prototype.generatorThings = function() {
      this.thingList = {};
      this.scene.traverse((function(_this) {
        return function(object3D) {
          var name;
          if (object3D.name.indexOf("$") === 0) {
            name = object3D.name.substring(1);
            if (_this.thingList[name]) {
              return console.error(name, 'is repeat.', object3D);
            }
            return _this.thingList[name] = new Thing(name, object3D);
          }
        };
      })(this));
      this.initCroupList();
      this.initRenderOrder();
      return _.forEach(this.thingList, function(thing) {
        var list;
        if (thing.userData.showingType === 'wireframe') {
          thing.changeToWireframe();
          list = [];
          thing.object3D.children.forEach(function(object3d) {
            if (object3d.$thing) {
              return list.push(object3d);
            }
          });
          list.forEach(function(object3d) {
            return thing.showingObject.add(object3d);
          });
          return thing.normal = thing.wireframe;
        }
      });
    };

    Room.prototype.getOffset = function() {
      var node, _results;
      node = this.element;
      this.offsetLeft = node.offsetLeft;
      this.offsetTop = node.offsetTop;
      _results = [];
      while (node.offsetParent) {
        node = node.offsetParent;
        this.offsetLeft += node.offsetLeft;
        _results.push(this.offsetTop += node.offsetTop);
      }
      return _results;
    };

    Room.prototype.initCroupList = function() {
      var groupList;
      groupList = this.groupList;
      return _.forEach(this.thingList, function(thing) {
        var anchor, key, path, t;
        path = [];
        t = thing.getParentThing();
        while (t) {
          path.push(t.name);
          t = t.getParentThing();
        }
        path.push(thing.name);
        anchor = groupList;
        while (path.length > 1) {
          key = path.shift();
          if (!groupList[key]) {
            groupList[key] = {};
          }
          anchor = groupList[key];
        }
        return anchor[path[0]] = null;
      });
    };

    Room.prototype.initRenderOrder = function() {
      var getKeys, self;
      self = this;
      getKeys = function(object) {
        return _.forEach(object, function(value, key) {
          self.renderOrder.push(key);
          if (value) {
            return getKeys(value);
          }
        });
      };
      return getKeys(this.groupList);
    };

    Room.prototype.resize = function() {
      var element, self;
      this.getOffset();
      element = this.element;
      if (element.clientWidth === 0 || element.clientHeight === 0) {
        return console.log("element width and height error:", element.clientWidth, element.clientHeight);
      }
      this.innerWidth = element.clientWidth;
      this.innerHeight = element.clientHeight;
      if (this.options.camera.type === 'PerspectiveCamera') {
        this.camera.aspect = this.innerWidth / this.innerHeight;
        this.camera.updateProjectionMatrix();
      }
      this.renderer.setSize(this.innerWidth, this.innerHeight);
      self = this;
      return setTimeout(function() {
        if (self.innerWidth !== element.clientWidth || self.innerHeight !== element.clientHeight) {
          return self.resize();
        }
      }, 1000);
    };

    Room.prototype.updateMouse = function(event) {
      var mouse;
      mouse = this.mouse;
      if (event.type === 'click') {
        mouse.eventType = 'click';
      } else if (event.type === 'dblclick') {
        mouse.eventType = 'dblclick';
      } else if (event.type === 'mousemove') {
        mouse.eventType = 'mousemove';
      }
      mouse.x = (event.clientX - this.offsetLeft) / this.innerWidth * 2 - 1;
      return mouse.y = -((event.clientY - this.offsetTop) / this.innerHeight) * 2 + 1;
    };

    Room.prototype.updateRaycaster = function() {
      var checkList, intersects, raycaster, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
      if (this.raycaster.checkList.length === 0) {
        return;
      }
      raycaster = this.raycaster;
      checkList = [];
      _.forEach(raycaster.checkList, function(thing) {
        return checkList.push(thing.showingObject);
      });
      raycaster.setFromCamera(this.mouse, this.camera);
      intersects = raycaster.intersectObjects(checkList, raycaster.recursiveFlag);
      if (intersects.length === 0) {
        if (this.mouse.eventType === "dblclick") {
          this.selectedThing = null;
          this.mouse.eventType = null;
          this.setOutline([]);
        } else if (this.mouse.eventType === 'mousemove') {
          if ((_ref = raycaster.callback) != null) {
            if (typeof _ref.mousemove === "function") {
              _ref.mousemove(null, intersects);
            }
          }
        }
        return;
      }
      if (this.mouse.eventType === 'click') {
        this.mouse.eventType = null;
        return (_ref1 = raycaster.callback) != null ? typeof _ref1.click === "function" ? _ref1.click(null, intersects) : void 0 : void 0;
      } else if (this.mouse.eventType === 'dblclick') {
        this.mouse.eventType = null;
        return (_ref2 = raycaster.callback) != null ? typeof _ref2.dblclick === "function" ? _ref2.dblclick(null, intersects) : void 0 : void 0;
      } else if (this.mouse.eventType === 'mousemove') {
        this.mouse.eventType = null;
        if ((_ref3 = raycaster.callback) != null) {
          if (typeof _ref3.mousemove === "function") {
            _ref3.mousemove(null, intersects);
          }
        }
        if (!this.selectedThing && ((_ref4 = intersects[0]) != null ? (_ref5 = _ref4.object) != null ? (_ref6 = _ref5.parent) != null ? (_ref7 = _ref6.$thing) != null ? _ref7.userData.selectedPositionOffset : void 0 : void 0 : void 0 : void 0)) {
          return this.setOutline([(_ref8 = intersects[0]) != null ? _ref8.object : void 0]);
        }
      }
    };

    Room.prototype.setRaycasterCheckList = function(thingList, recursive, callback) {
      var raycaster;
      raycaster = this.raycaster;
      raycaster.checkList = [];
      _.forEach(thingList, function(value, key) {
        if (!value.isThing) {
          return console.error('it should be thing.', value);
        }
        raycaster.checkList.push(value);
      });
      if (_.isBoolean(recursive)) {
        raycaster.recursiveFlag = recursive;
      }
      if (callback) {
        return raycaster.callback = callback;
      }
    };

    Room.prototype.setRaycasterCallback = function(callback) {
      if (!callback) {
        return;
      }
      return this.raycaster.callback = callback;
    };

    Room.prototype.getThingByObject3D = function(object3D) {
      var mesh;
      if (!object3D.isObject3D) {
        return console.error(name, "is not object3d,but is:", object);
      }
      mesh = object3D;
      while (!mesh.$thing) {
        if (!mesh.parent) {
          break;
        }
        mesh = mesh.parent;
      }
      return mesh.$thing;
    };

    Room.prototype.getThingByName = function(name) {
      return this.thingList[name];
    };

    Room.prototype.selectThing = function(thing) {
      if (!thing) {
        return;
      }
      if (thing != null ? thing.isThing : void 0) {
        if (this.selectedThing && this.selectedThing.name === thing.name) {
          thing.resetAction();
          this.selectedThing = null;
          return;
        }
        this.selectedThing = thing;
        return _.forEach(this.thingList, function(t) {
          if (t.name === thing.name) {
            t.selectedAction();
          } else {
            t.resetAction();
          }
        });
      } else {
        return console.error('can\'t get thing', thing);
      }
    };

    Room.prototype.changeToCapacity = function() {
      var self, thing;
      self = this;
      thing = null;
      return _.forEach(this.renderOrder, function(name) {
        thing = self.getThingByName(name);
        if (thing) {
          return thing.changeToCapacity();
        }
      });
    };

    Room.prototype.changeToNormal = function() {
      var self, thing;
      self = this;
      thing = null;
      return _.forEach(this.renderOrder, function(name) {
        thing = self.getThingByName(name);
        if (thing) {
          return thing.changeToNormal();
        }
      });
    };

    Room.prototype.rotateAction = function(rotation, time) {
      return this.scene.children.forEach(function(t) {
        if (t.$thing) {
          return t.$thing.rotateAction(rotation, time);
        }
      });
    };

    Room.prototype.autoRotate = function(flag, autoRotateSpeed) {
      var _ref, _ref1, _ref2;
      if ((_ref = this.orbitControl) != null) {
        _ref.autoRotateSpeed = autoRotateSpeed || 2;
      }
      if (flag) {
        if ((_ref1 = this.orbitControl) != null) {
          _ref1.autoRotate = true;
        }
        return this.addAnimate('autoRotate', (function(_this) {
          return function() {
            var _ref2;
            return (_ref2 = _this.orbitControl) != null ? _ref2.update() : void 0;
          };
        })(this));
      } else {
        if ((_ref2 = this.orbitControl) != null) {
          _ref2.autoRotate = false;
        }
        return this.removeAnimate('autoRotate');
      }
    };

    Room.prototype.setThingCapacity = function(name, value, color, virtualFlag) {
      var thing;
      thing = this.getThingByName(name);
      if (!thing) {
        return;
      }
      if (virtualFlag) {
        return thing.setVirtualCapacity(value, color);
      } else {
        return thing.setRealCapacity(value, color);
      }
    };

    Room.prototype.setThingVisible = function(name, flag) {
      var thing;
      thing = this.getThingByName(name);
      if (!thing) {
        return console.log('error:this thing is not exit:', name, thing);
      }
      if (flag) {
        return thing.setVisible(true);
      } else {
        return thing.setVisible(false);
      }
    };

    Room.prototype.initOutline = function() {
      var composer, effectFXAA, outlinePass, renderPass, _ref, _ref1;
      composer = new THREE.EffectComposer(this.renderer);
      this.composer = composer;
      renderPass = new THREE.RenderPass(this.scene, this.camera);
      composer.addPass(renderPass);
      outlinePass = new THREE.OutlinePass(new THREE.Vector2(this.innerWidth, this.innerHeight), this.scene, this.camera);
      composer.addPass(outlinePass);
      this.outlinePass = outlinePass;
      outlinePass.edgeStrength = 5;
      outlinePass.edgeGlow = 1;
      outlinePass.pulsePeriod = 2;
      if ((_ref = outlinePass.visibleEdgeColor) != null) {
        _ref.set('#35f2d1');
      }
      if ((_ref1 = outlinePass.hiddenEdgeColor) != null) {
        _ref1.set('#30a0de');
      }
      effectFXAA = new THREE.ShaderPass(THREE.FXAAShader);
      effectFXAA.uniforms['resolution'].value.set(1 / this.innerWidth, 1 / this.innerHeight);
      effectFXAA.renderToScreen = true;
      return composer.addPass(effectFXAA);
    };

    Room.prototype.setOutline = function(array) {
      if (this.outlinePass) {
        return this.outlinePass.selectedObjects = array;
      }
    };

    Room.prototype.setThingOutline = function(thingArray) {
      var arr, thing, _i, _len;
      if (!thingArray) {
        return;
      }
      arr = [];
      if (thingArray.length !== 0) {
        for (_i = 0, _len = thingArray.length; _i < _len; _i++) {
          thing = thingArray[_i];
          arr.push(thing.showingObject);
        }
      }
      return this.setOutline(arr);
    };

    Room.prototype.setThingTipCube = function(thing, color1, color2) {
      var box3, col1, col2, cube, geometry, len, material, offset, scale, scaleMin, x, y, z, _ref;
      if (!(thing != null ? thing.isThing : void 0)) {
        return console.log(thing, 'is not a thing');
      }
      this.deleteThingTipCube(thing);
      scale = thing.showingObject.getWorldScale(new THREE.Vector3(1, 1, 1));
      box3 = (new THREE.Box3()).setFromObject(thing.object3D);
      x = box3.max.x - box3.min.x;
      y = box3.max.y - box3.min.y;
      z = box3.max.z - box3.min.z;
      scaleMin = _.min([scale.x, scale.y, scale.z]);
      len = _.min([x, y, z]) / scaleMin / 8;
      geometry = new THREE.BoxGeometry(len, len, len);
      material = new THREE.MeshBasicMaterial({
        color: color1 || 0x00ff00
      });
      cube = new THREE.Mesh(geometry, material);
      cube.name = thing.name + '-tip-cube';
      thing.tipCube = cube;
      thing.showingObject.add(thing.tipCube);
      offset = (_ref = thing.userData) != null ? _ref.selectedPositionOffset : void 0;
      cube.position.y = (y / scale.y) + len;
      if (offset != null ? offset.x : void 0) {
        cube.position.x += (x / scale.x) / 2 - 2 * len;
      }
      if (offset != null ? offset.z : void 0) {
        cube.position.z += (z / scale.z) / 2 - 2 * len;
      }
      cube.interpolates = 0;
      cube.interpolatesAdd = 0.02;
      if (color2) {
        col1 = new THREE.Color(color1);
        col2 = new THREE.Color(color2);
        thing.tipCube.animate = cube.name + '-animate';
        return this.addAnimate(thing.tipCube.animate, (function(_this) {
          return function() {
            var color;
            if (cube.interpolates <= 0) {
              cube.interpolatesAdd = 0.02;
            } else if (cube.interpolates >= 1) {
              cube.interpolatesAdd = -0.02;
            }
            cube.interpolates += cube.interpolatesAdd;
            color = col1.clone();
            return cube.material.color = color.lerp(col2, cube.interpolates);
          };
        })(this));
      }
    };

    Room.prototype.deleteThingTipCube = function(thing) {
      if (thing != null ? thing.tipCube : void 0) {
        if (thing.tipCube.animate) {
          this.removeAnimate(thing.tipCube.animate);
        }
        thing.tipCube.parent.remove(thing.tipCube);
        return thing.tipCube = null;
      }
    };

    Room.prototype.getScreenCoordinate = function(object) {
      var height, heightHalf, result, vector, width, widthHalf, _ref, _ref1, _ref2;
      vector = new THREE.Vector3;
      if (((_ref = object.$thing) != null ? _ref.box3 : void 0) != null) {
        if ((_ref1 = object.$thing) != null) {
          if ((_ref2 = _ref1.box3) != null) {
            _ref2.getCenter(vector);
          }
        }
        vector.y *= 1.5;
      } else {
        vector.setFromMatrixPosition(object.matrixWorld);
      }
      vector.project(this.camera);
      width = this.innerWidth;
      height = this.innerHeight;
      widthHalf = width / 2;
      heightHalf = height / 2;
      result = {};
      result.x = vector.x * widthHalf + widthHalf + this.offsetLeft;
      result.y = -(vector.y * heightHalf) + heightHalf + this.offsetTop;
      return result;
    };

    Room.prototype.initDb = function() {
      var request;
      if (!this.db) {
        request = indexedDB.open("3d-files-db");
        request.onerror = (function(_this) {
          return function(event) {
            console.log("Database error: " + event.target.errorCode);
            return typeof _this.dbCallback === "function" ? _this.dbCallback("Database error: " + event.target.errorCode) : void 0;
          };
        })(this);
        request.onupgradeneeded = (function(_this) {
          return function(event) {
            _this.db = event.target.result;
            if (!_this.db.objectStoreNames.contains('3d-files-table')) {
              return _this.db.createObjectStore('3d-files-table', {
                keyPath: 'id'
              });
            }
          };
        })(this);
        return request.onsuccess = (function(_this) {
          return function(event) {
            _this.db = event.target.result;
            return typeof _this.dbCallback === "function" ? _this.dbCallback() : void 0;
          };
        })(this);
      } else {
        return typeof this.dbCallback === "function" ? this.dbCallback() : void 0;
      }
    };

    Room.prototype.getDataFromDatabase = function(path, cb) {
      var objectStore, objectStoreRequest, transaction;
      if (!this.db) {
        return console.warn("db is null");
      }
      transaction = this.db.transaction(["3d-files-table"], "readonly");
      objectStore = transaction.objectStore('3d-files-table');
      objectStoreRequest = objectStore.get(path);
      transaction.onerror = (function(_this) {
        return function(event) {
          return console.warn("transaction error:", event);
        };
      })(this);
      objectStoreRequest.onsuccess = (function(_this) {
        return function() {
          var _ref;
          return typeof cb === "function" ? cb(null, (_ref = objectStoreRequest.result) != null ? _ref.data : void 0) : void 0;
        };
      })(this);
      return objectStoreRequest.onerror = (function(_this) {
        return function(event) {
          return typeof cb === "function" ? cb(event) : void 0;
        };
      })(this);
    };

    Room.prototype.setDataToDataBase = function(key, data) {
      var objectStore, transaction;
      if (!this.db) {
        return console.warn("db is null");
      }
      transaction = this.db.transaction(["3d-files-table"], "readwrite");
      transaction.onerror = (function(_this) {
        return function(event) {
          return console.warn("transaction error:", event);
        };
      })(this);
      objectStore = transaction.objectStore('3d-files-table');
      return objectStore.put({
        id: key,
        data: JSON.stringify(data)
      });
    };

    Room.prototype.dispose = function() {
      var scene;
      this.isDisposed = true;
      this.animateList = [];
      window.removeEventListener('resize', this.resize);
      this.renderer.dispose();
      roomList[this.name] = null;
      scene = this.scene;
      return scene.children.forEach(function(mesh) {
        return scene.remove(mesh);
      });
    };

    return Room;

  })();
  return exports = Room;
});
