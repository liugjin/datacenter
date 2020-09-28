// Generated by IcedCoffeeScript 108.0.13

/*
* File: 3d/thing
* User: Hardy
* Date: 2018/08/22
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
define(["lodash", "threejs", "tween"], function(_, THREE, TWEEN) {
  var Thing, exports, showingType;
  showingType = ["normal", "wireframe", "capacity"];
  if (!window.debugR) {
    window.debugR = {};
  }
  Thing = (function() {
    function Thing(name, object3D, parent) {
      var box3;
      if (!object3D.isObject3D) {
        return console.error('this is not a object3D', object3D);
      }
      this.name = name;
      this.object3D = object3D;
      object3D.name = this.name + '-object3D';
      object3D.$thing = this;
      this.isThing = true;
      this.normal = object3D;
      this.showingObject = this.normal;
      this.showingType = 'normal';
      this.tween = null;
      this.visible = true;
      this.position = object3D.position.clone();
      this.rotation = object3D.rotation.clone();
      this.scale = object3D.scale.clone();
      this.originalPosition = object3D.position.clone();
      this.originalRotation = object3D.rotation.clone();
      this.originalScale = object3D.scale.clone();
      this.userData = object3D.userData;
      if ((object3D != null ? object3D.children.length : void 0) > 0) {
        box3 = (new THREE.Box3()).setFromObject(object3D);
        this.box3 = box3;
      }
      this.children = [];
      if (parent) {
        if (parent.isThing) {
          this.parent = parent;
        } else {
          console.error('parent should be a thing.', parent);
        }
      }
    }

    Thing.prototype.getParentThing = function() {
      var o, parent, parentThing;
      parent = this.showingObject.parent;
      parentThing = null;
      while (parent) {
        o = parent;
        if (o.$thing) {
          parentThing = o.$thing;
          break;
        } else {
          parent = o.parent;
        }
      }
      return parentThing;
    };

    Thing.prototype.setPosition = function(position) {
      if (position) {
        if (_.isNumber(position.x)) {
          this.position.x = position.x;
        }
        if (_.isNumber(position.y)) {
          this.position.y = position.y;
        }
        if (_.isNumber(position.z)) {
          this.position.z = position.z;
        }
        this.originalPosition = this.position.clone();
        this.fitParameters();
      }
    };

    Thing.prototype.setScale = function(scale) {
      if (_.isNumber(scale)) {
        this.scale.x = scale;
        this.scale.y = scale;
        this.scale.z = scale;
        this.fitParameters();
      }
    };

    Thing.prototype.addChild = function(thing) {
      if (thing.isThing) {
        this.children.push(thing);
        this.showingObject.add(thing.showingObject);
      } else {
        console.log('thing error', thing);
      }
    };

    Thing.prototype.removeChild = function(thing) {
      var obj;
      if (thing.isThing) {
        _.remove(this.children, function(c) {
          return c.name === thing.name;
        });
        obj = this.showingObject;
        obj.children.forEach(function(c) {
          if (c.$thing && c.$thing.name === thing.name) {
            obj.remove(c);
          }
        });
      } else {
        console.log('thing error', thing);
      }
    };

    Thing.prototype.removeAllChildren = function() {
      var child;
      while (this.children.length !== 0) {
        child = this.children.pop();
        child.dispose();
      }
    };

    Thing.prototype.selectedAction = function() {
      var offset, offsetPosition, position, x, y, z;
      if (this.userData.selectedPositionOffset) {
        if (!this.offsetPosition) {
          offset = this.userData.selectedPositionOffset;
          position = this.originalPosition;
          x = (position.x || 0) + (offset.x || 0);
          y = (position.y || 0) + (offset.y || 0);
          z = (position.z || 0) + (offset.z || 0);
          this.offsetPosition = new THREE.Vector3(x, y, z);
        }
        offsetPosition = this.offsetPosition;
        this.tween = new TWEEN.Tween(this.showingObject.position).to({
          x: offsetPosition.x,
          y: offsetPosition.y,
          z: offsetPosition.z
        }, 500).start();
        return this.position.copy(this.offsetPosition);
      }
    };

    Thing.prototype.unpackAction = function() {
      var child, offset, offsetPosition, position, t, x, y, z, _i, _len, _ref, _ref1, _ref2, _results;
      _ref = this.showingObject.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        t = child != null ? child.$thing : void 0;
        if (t != null ? (_ref1 = t.userData) != null ? _ref1.unpackPositionOffset : void 0 : void 0) {
          if (!(t != null ? t.unpackPositionOffset : void 0)) {
            offset = t != null ? (_ref2 = t.userData) != null ? _ref2.unpackPositionOffset : void 0 : void 0;
            position = t.originalPosition;
            x = (position.x || 0) + (offset.x || 0);
            y = (position.y || 0) + (offset.y || 0);
            z = (position.z || 0) + (offset.z || 0);
            t.unpackOffsetPosition = new THREE.Vector3(x, y, z);
          }
          offsetPosition = t.unpackOffsetPosition;
          new TWEEN.Tween(t.showingObject.position).to({
            x: offsetPosition.x,
            y: offsetPosition.y,
            z: offsetPosition.z
          }, 1000).easing(TWEEN.Easing.Back.InOut).start();
          _results.push(t.position.copy(t.unpackOffsetPosition));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Thing.prototype.packAction = function() {
      var child, t, _i, _len, _ref, _results;
      _ref = this.showingObject.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        t = child.$thing;
        if (t.unpackOffsetPosition) {
          new TWEEN.Tween(t.showingObject.position).to({
            x: t.originalPosition.x,
            y: t.originalPosition.y,
            z: t.originalPosition.z
          }, 1000).easing(TWEEN.Easing.Back.InOut).start();
          _results.push(t.position.copy(t.originalPosition));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Thing.prototype.fitParameters = function() {
      var position, rotation, scale;
      if (!this.isThing) {
        return console.error('this is not thing.', this);
      }
      position = this.position.clone();
      rotation = this.rotation.clone();
      scale = this.scale.clone();
      if (this.name === "micromodule-10") {
        console.log("position:", position);
      }
      if (this.name === "micromodule-10") {
        console.log("rotation:", rotation);
      }
      this.showingObject.position.set(position.x, position.y, position.z);
      this.showingObject.rotation.set(rotation.x, rotation.y, rotation.z);
      this.showingObject.scale.set(scale.x, scale.y, scale.z);
      return this.showingObject.visible = this.visible;
    };

    Thing.prototype.changeToNormal = function() {
      var g, old, parent, parentThing, _i, _len, _ref, _ref1;
      old = this.showingObject;
      this.showingObject.visible = false;
      this.showingObject = this.normal;
      this.showingType = 'normal';
      this.fitParameters();
      _ref = Array.from(old.children);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        g = _ref[_i];
        if ((g != null ? g.type : void 0) === "Group") {
          switch ((_ref1 = g.$thing) != null ? _ref1.showingType : void 0) {
            case "normal":
              if (this.showingObject.uuid !== g.$thing.normal.uuid) {
                this.showingObject.add(g.$thing.normal);
              }
              break;
            case "wireframe":
              if (this.showingObject.uuid !== g.$thing.wireframe.uuid) {
                this.showingObject.add(g.$thing.wireframe);
              }
              break;
            case "capacity":
              if (this.showingObject.uuid !== g.$thing.capacity.uuid) {
                this.showingObject.add(g.$thing.capacity);
              }
          }
        }
      }
      parent = this.showingObject.parent;
      parentThing = this.getParentThing();
      if (parentThing && parentThing.showingObject) {
        return parentThing.showingObject.add(this.showingObject);
      } else if (parent) {
        return parent.add(this.showingObject);
      }
    };

    Thing.prototype.changeToWireframe = function() {
      var g, old, parent, parentThing, _i, _len, _ref, _ref1, _results;
      old = this.showingObject;
      if (!this.wireframe) {
        this.initWireframe();
      }
      this.showingObject.visible = false;
      parent = this.showingObject.parent;
      parentThing = this.getParentThing();
      this.showingObject = this.wireframe;
      this.showingType = 'wireframe';
      this.fitParameters();
      if (parentThing && parentThing.showingObject) {
        parentThing.showingObject.add(this.showingObject);
      } else if (parent) {
        parent.add(this.showingObject);
      }
      _ref = Array.from(old.children);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        g = _ref[_i];
        if ((g != null ? g.type : void 0) === "Group" && ((_ref1 = g.$thing) != null ? _ref1.showingObject : void 0) && this.showingObject.uuid !== g.$thing.showingObject.uuid) {
          _results.push(this.showingObject.add(g.$thing.showingObject));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Thing.prototype.initWireframe = function() {
      var group, material, outsideGroup, wireframeGroup;
      group = new THREE.Group;
      group.visible = false;
      group.name = this.name + '_wireframe';
      group.$thing = this;
      wireframeGroup = new THREE.Group;
      wireframeGroup.name = this.name + '_wireframe_wireframe';
      material = new THREE.LineBasicMaterial({
        color: 0x00FFFF
      });
      this.object3D.children.forEach(function(v) {
        var geo, line;
        if (v.geometry) {
          geo = new THREE.EdgesGeometry(v.geometry);
          line = new THREE.LineSegments(geo, material);
          wireframeGroup.add(line);
        }
      });
      group.add(wireframeGroup);
      outsideGroup = new THREE.Group;
      outsideGroup.name = this.name + '_wireframe_outside';
      outsideGroup.scale.copy(new THREE.Vector3(1.01, 1.01, 1.01));
      material = new THREE.LineBasicMaterial({
        color: 0xcccccc,
        depthWrite: false,
        side: THREE.BackSide,
        transparent: true,
        opacity: 0,
        depthTest: false
      });
      this.object3D.children.forEach(function(v) {
        var mesh;
        if (v.geometry) {
          mesh = new THREE.Mesh(v.geometry, material);
          outsideGroup.add(mesh);
        }
      });
      group.add(outsideGroup);
      outsideGroup.$thing = this;
      return this.wireframe = group;
    };

    Thing.prototype.changeToCapacity = function() {
      var g, old, parent, parentThing, _i, _len, _ref, _ref1, _results;
      old = this.showingObject;
      if (!this.capacity) {
        this.initCapacity();
      }
      if (this.userData.noCapacity) {
        return;
      }
      this.showingObject.visible = false;
      parent = this.showingObject.parent;
      parentThing = this.getParentThing();
      this.showingObject = this.capacity;
      this.showingType = 'capacity';
      this.fitParameters();
      if (parentThing && parentThing.showingObject) {
        parentThing.showingObject.add(this.showingObject);
      } else if (parent) {
        parent.add(this.showingObject);
      }
      _ref = Array.from(old.children);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        g = _ref[_i];
        if ((g != null ? g.type : void 0) === "Group" && ((_ref1 = g.$thing) != null ? _ref1.showingObject : void 0) && this.showingObject.uuid !== g.$thing.showingObject.uuid) {
          _results.push(this.showingObject.add(g.$thing.showingObject));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Thing.prototype.initCapacity = function() {
      var box3, group, material, outsideGroup, realGroup, self, virtualGroup, wireframeGroup;
      group = new THREE.Group();
      group.name = this.name + '_capacity';
      group.visible = false;
      group.$thing = this;
      group.position.copy(this.position);
      group.scale.copy(this.scale);
      group.rotation.copy(this.rotation);
      this.capacity = group;
      wireframeGroup = new THREE.Group;
      wireframeGroup.name = this.name + '_capacity' + '_wireframe';
      material = new THREE.LineBasicMaterial({
        color: 0x00FFFF
      });
      self = this;
      this.object3D.children.forEach(function(v) {
        var geo, line;
        if (v.geometry && !self.isTipCube(v)) {
          geo = new THREE.EdgesGeometry(v.geometry);
          line = new THREE.LineSegments(geo, material);
          wireframeGroup.add(line);
        }
      });
      group.add(wireframeGroup);
      realGroup = new THREE.Group();
      realGroup.name = this.name + '_capacity' + '_real';
      realGroup.scale.copy(new THREE.Vector3(0.8, 0.01, 0.8));
      realGroup.visible = false;
      material = new THREE.LineBasicMaterial({
        color: 0x00FFFF
      });
      this.object3D.children.forEach(function(v) {
        var mesh;
        if (v.geometry && !self.isTipCube(v)) {
          mesh = new THREE.Mesh(v.geometry, material);
          realGroup.add(mesh);
        }
      });
      group.add(realGroup);
      virtualGroup = new THREE.Group();
      virtualGroup.name = this.name + '_capacity' + '_virtual';
      virtualGroup.scale.copy(new THREE.Vector3(0.8, 0.01, 0.8));
      virtualGroup.visible = false;
      material = new THREE.LineBasicMaterial({
        color: 0x00FFFF,
        depthWrite: false,
        side: THREE.BackSide,
        transparent: true,
        opacity: 0.5,
        depthTest: false
      });
      this.object3D.children.forEach(function(v) {
        var mesh;
        if (v.geometry && !self.isTipCube(v)) {
          mesh = new THREE.Mesh(v.geometry, material);
          virtualGroup.add(mesh);
        }
      });
      group.add(virtualGroup);
      outsideGroup = new THREE.Group();
      outsideGroup.name = this.name + '_capacity' + '_outside';
      outsideGroup.scale.copy(new THREE.Vector3(1.01, 1.01, 1.01));
      outsideGroup.$thing = this;
      material = new THREE.LineBasicMaterial({
        color: 0xcccccc,
        depthWrite: false,
        side: THREE.BackSide,
        transparent: true,
        opacity: 0,
        depthTest: false
      });
      this.object3D.children.forEach(function(v) {
        var mesh;
        if (v.geometry && !self.isTipCube(v)) {
          mesh = new THREE.Mesh(v.geometry, material);
          outsideGroup.add(mesh);
        }
      });
      group.add(outsideGroup);
      box3 = (new THREE.Box3()).setFromObject(outsideGroup);
      return this.anchorY = box3.max.y;
    };

    Thing.prototype.resetAction = function() {
      var position;
      if (this.tween) {
        this.tween.stop();
      }
      if (this.userData.selectedPositionOffset) {
        position = this.originalPosition;
        this.showingObject.position.copy(this.originalPosition);
        return this.position.copy(this.originalPosition);
      }
    };

    Thing.prototype.setRealCapacity = function(value, color) {
      var capacity, real, virtual;
      if (!this.capacity) {
        return;
      }
      if (value && (value < 0 || value > 100)) {
        if (value > 100) {
          console.log(this.name, 'value err:', value);
          value = 100;
          color = "0xff0000";
        }
      }
      capacity = this.capacity;
      real = capacity.getObjectByName(capacity.name + '_real');
      virtual = capacity.getObjectByName(capacity.name + '_virtual');
      if (_.isNumber(value)) {
        if (value === 0) {
          real.visible = false;
          virtual.position.y = this.anchorY * 0.01;
        } else {
          real.visible = true;
          value = value / 100;
          real.scale.y = value;
          virtual.position.y = this.anchorY * value;
        }
      }
      if (color) {
        color = color.replace('#', '0x');
        return real.children.forEach(function(i) {
          return i.material.color.setHex(color);
        });
      }
    };

    Thing.prototype.setVirtualCapacity = function(value, color) {
      var capacity, real, virtual;
      if (!this.capacity) {
        return;
      }
      if (value && (value < 0 || value > 100)) {
        return console.log('value err:', value);
      }
      capacity = this.capacity;
      real = capacity.getObjectByName(capacity.name + '_real');
      virtual = capacity.getObjectByName(capacity.name + '_virtual');
      if (_.isNumber(value)) {
        if (value === 0) {
          virtual.visible = false;
        } else if (value / 100 + real.scale.y > 1) {
          virtual.visible = false;
        } else {
          virtual.visible = true;
          value = value / 100;
          virtual.scale.y = value;
        }
      }
      if (color) {
        color = color.replace('#', '0x');
        return virtual.children.forEach(function(i) {
          return i.material.color.setHex(color);
        });
      }
    };

    Thing.prototype.rotateAction = function(rotation, time) {
      var newRotation, x, y, z;
      x = (this.rotation.x || 0) + (rotation.x || 0) * Math.PI / 180;
      y = (this.rotation.y || 0) + (rotation.y || 0) * Math.PI / 180;
      z = (this.rotation.z || 0) + (rotation.z || 0) * Math.PI / 180;
      newRotation = new THREE.Euler(x, y, z);
      this.tween = new TWEEN.Tween(this.showingObject.rotation).to({
        x: newRotation.x,
        y: newRotation.y,
        z: newRotation.z
      }, time || 2000).start();
      return this.rotation.copy(newRotation);
    };

    Thing.prototype.setVisible = function(flag) {
      if (!_.isBoolean(flag)) {
        return console.error('flag should be boolean.');
      }
      this.visible = flag;
      return this.showingObject.visible = this.visible;
    };

    Thing.prototype.isTipCube = function(mesh) {
      return mesh.name === this.name + '-tip-cube';
    };

    Thing.prototype.dispose = function() {
      var parent;
      parent = this.parent;
      if (parent) {
        parent.removeChild(this);
      } else {
        console.log('error:only support thing which is added dynamically.', this.name, this);
      }
    };

    return Thing;

  })();
  return exports = Thing;
});
