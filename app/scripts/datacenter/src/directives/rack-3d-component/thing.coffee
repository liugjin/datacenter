###
* File: 3d/thing
* User: Hardy
* Date: 2018/08/22
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`
define ["lodash","threejs","tween"], (_,THREE,TWEEN) ->
  showingType = ["normal","wireframe","capacity"]
  if(!window.debugR)
    window.debugR={}

  class Thing
    constructor:(name,object3D,parent)->
      if(!object3D.isObject3D)
        return console.error('this is not a object3D',object3D)
      @name = name
      @object3D = object3D
      object3D.name = @name+'-object3D'
      object3D.$thing = @
      @isThing = true

      @normal = object3D

      @showingObject = @normal
      @showingType = 'normal'
      @tween = null

      @visible = true

      @position = object3D.position.clone()
      @rotation = object3D.rotation.clone()
      @scale = object3D.scale.clone()
      @originalPosition = object3D.position.clone()
      @originalRotation = object3D.rotation.clone()
      @originalScale = object3D.scale.clone()
      @userData = object3D.userData

      @children = []
      if parent
        if parent.isThing
          @parent = parent
        else
          console.error 'parent should be a thing.', parent


    getParentThing:()->
      parent = this.showingObject.parent
      parentThing = null
      while(parent)
        o = parent
        if(o.$thing)
          parentThing = o.$thing
          break
        else
          parent = o.parent

      return parentThing

    setPosition:(position) ->
      if position
        if _.isNumber(position.x)
          @position.x = position.x
        if _.isNumber(position.y)
          @position.y = position.y
        if _.isNumber(position.z)
          @position.z = position.z
        @originalPosition = @position.clone()
        @fitParameters()
      return

    setScale:(scale) ->
      if _.isNumber(scale)
        @scale.x = scale
        @scale.y = scale
        @scale.z = scale
        @fitParameters()
      return

    addChild:(thing) ->
#      console.log("addChild",this.name,thing.name)
      if thing.isThing
        @children.push thing
        @showingObject.add thing.showingObject
      else
        console.log 'thing error', thing
      return

    removeChild:(thing) ->
#      console.log 'removeChild:', thing.name
      if thing.isThing
    # remove child form children array
        _.remove @children, (c) ->
          c.name == thing.name
        # remove object3d form parent object3d
        obj = @showingObject
        obj.children.forEach (c) ->
          if c.$thing and c.$thing.name == thing.name
            obj.remove c
          return
      else
        console.log 'thing error', thing
      return

    removeAllChildren:()->
#      console.log 'removeAllChildren'
      while @children.length != 0
        child = @children.pop()
        child.dispose()
      return

    selectedAction:()->
#      console.log("selectedAction",@)
      if @userData.selectedPositionOffset
        if !@offsetPosition
          offset = @userData.selectedPositionOffset
          position = @originalPosition
          x = (position.x or 0) + (offset.x or 0)
          y = (position.y or 0) + (offset.y or 0)
          z = (position.z or 0) + (offset.z or 0)
          @offsetPosition = new THREE.Vector3(x, y, z)
        offsetPosition = @offsetPosition
        @tween = new TWEEN.Tween(@showingObject.position).to({
          x: offsetPosition.x
          y: offsetPosition.y
          z: offsetPosition.z
        }, 500).start()
        @position.copy @offsetPosition

    fitParameters:()->
      if !@isThing
        return console.error 'this is not thing.', this
      position = @position.clone()
      rotation = @rotation.clone()
      scale = @scale.clone()
      @showingObject.position.set position.x, position.y, position.z
      @showingObject.rotation.set rotation.x, rotation.y, rotation.z
      @showingObject.scale.set scale.x, scale.y, scale.z
      @showingObject.visible = @visible

    changeToNormal:()->
      # make old object invisible
      @showingObject.visible = false
      # console.log(this.name,this.showingType,'-->','normal')
      @showingObject = @normal
      @showingType = 'normal'
      @fitParameters()

    changeToWireframe:()->
      if !@wireframe
        @initWireframe()
      # console.log(this.name,this.showingType,'-->','wireframe')
      # make old object invisible
      @showingObject.visible = false
      parent = @showingObject.parent
      parentThing = @getParentThing()
      @showingObject = @wireframe
      @showingType = 'wireframe'
      @fitParameters()
      # add same object3D repeatly is idempotent
      if parentThing and parentThing.showingObject
      # console.log("changeToWireframe 1:",parentThing.showingObject.name)
        parentThing.showingObject.add @showingObject
      else if parent
      #parent is scene
      # console.log("changeToWireframe 2:",parent)
        parent.add @showingObject

    initWireframe:()->
      group = new (THREE.Group)
      group.visible = false
      group.name = @name + '_wireframe'
      group.$thing = this
      wireframeGroup = new (THREE.Group)
      wireframeGroup.name = @name + '_wireframe_wireframe'
      material = new (THREE.LineBasicMaterial)(color: 0x00FFFF)
      @object3D.children.forEach (v) ->
        if v.geometry
          geo = new (THREE.EdgesGeometry)(v.geometry)
          line = new (THREE.LineSegments)(geo, material)
          wireframeGroup.add line
        return
      group.add wireframeGroup
      outsideGroup = new (THREE.Group)
      outsideGroup.name = @name + '_wireframe_outside'
      outsideGroup.scale.copy new (THREE.Vector3)(1.01, 1.01, 1.01)
      material = new (THREE.LineBasicMaterial)(
        color: 0xcccccc
        depthWrite: false
        side: THREE.BackSide
        transparent: true
        opacity: 0
        depthTest: false)
      @object3D.children.forEach (v) ->
        if v.geometry
          mesh = new (THREE.Mesh)(v.geometry, material)
          outsideGroup.add mesh
        return
      group.add outsideGroup
      outsideGroup.$thing = this
      @wireframe = group
    changeToCapacity:()->
      if !@capacity
        @initCapacity()
      if(this.userData.noCapacity)
        return console.log(this.name," noCacapacity.")

      # console.log(this.name,this.showingType,'-->','capacity')
      # make old object invisible
      @showingObject.visible = false
      parent = @showingObject.parent
      parentThing = @getParentThing()
      @showingObject = @capacity
      @showingType = 'capacity'
      @fitParameters()
      # add same object3D repeatly is idempotent
      if parentThing and parentThing.showingObject
      # console.log("changeToCapacity 1:",parentThing.showingObject.name)
        parentThing.showingObject.add @showingObject
      else if parent
      #parent is scene
      # console.log("changeToCapacity 2:",parent)
        parent.add @showingObject

    initCapacity:()->
      group = new THREE.Group()
      group.name = @name + '_capacity'
      group.visible = false
      group.$thing = this
      group.position.copy @position
      group.scale.copy @scale
      group.rotation.copy @rotation
      @capacity = group
      wireframeGroup = new (THREE.Group)
      wireframeGroup.name = @name + '_capacity' + '_wireframe'
      material = new (THREE.LineBasicMaterial)(color: 0x00FFFF)
      self = @
      @object3D.children.forEach (v) ->
        if v.geometry and not self.isTipCube(v)
          geo = new (THREE.EdgesGeometry)(v.geometry)
          line = new (THREE.LineSegments)(geo, material)
          wireframeGroup.add line
        return
      group.add wireframeGroup

      realGroup = new THREE.Group()
      realGroup.name = @name + '_capacity' + '_real'
      realGroup.scale.copy new THREE.Vector3(0.8, 0.01, 0.8)
      realGroup.visible = false
      material = new THREE.LineBasicMaterial(color: 0x00FFFF)
      @object3D.children.forEach (v) ->
        if v.geometry and not self.isTipCube(v)
          mesh = new THREE.Mesh(v.geometry, material)
          realGroup.add mesh
        return
      group.add realGroup
      virtualGroup = new THREE.Group()
      virtualGroup.name = @name + '_capacity' + '_virtual'
      virtualGroup.scale.copy new (THREE.Vector3)(0.8, 0.01, 0.8)
      virtualGroup.visible = false
      material = new THREE.LineBasicMaterial(
        color: 0x00FFFF
        depthWrite: false
        side: THREE.BackSide
        transparent: true
        opacity: 0.5
        depthTest: false)
      @object3D.children.forEach (v) ->
        if v.geometry and not self.isTipCube(v)
          mesh = new THREE.Mesh(v.geometry, material)
          virtualGroup.add mesh
        return
      group.add virtualGroup
      outsideGroup = new THREE.Group()
      outsideGroup.name = @name + '_capacity' + '_outside'
      outsideGroup.scale.copy new (THREE.Vector3)(1.01, 1.01, 1.01)
      outsideGroup.$thing = this
      material = new THREE.LineBasicMaterial(
        color: 0xcccccc
        depthWrite: false
        side: THREE.BackSide
        transparent: true
        opacity: 0
        depthTest: false)
      @object3D.children.forEach (v) ->
        if v.geometry and not self.isTipCube(v)
          mesh = new THREE.Mesh(v.geometry, material)
          outsideGroup.add mesh
        return
      group.add outsideGroup
      # TODO：bug: change scale could change box size value
      #remember ths first right value
      box3 = (new THREE.Box3()).setFromObject(outsideGroup)
      @anchorY = box3.max.y

    resetAction:()->
      if @tween
        @tween.stop()
      if @userData.selectedPositionOffset
        position = @originalPosition
        @showingObject.position.copy @originalPosition
        @position.copy @originalPosition

    setRealCapacity:(value,color)->
      if !@capacity
        return console.error 'capacity is not init.'
      if value and (value < 0 or value > 100)
        if value > 100
          console.log this.name,'value err:', value
          value = 100
          color = "0xff0000"

      capacity = @capacity
      real = capacity.getObjectByName(capacity.name + '_real')
      virtual = capacity.getObjectByName(capacity.name + '_virtual')
      if _.isNumber(value)
        if value == 0
          real.visible = false
          # change virtualCapacity position
          virtual.position.y = @anchorY * 0.01
        else
          real.visible = true
          value = value / 100
          real.scale.y = value
          # change virtualCapacity position
          virtual.position.y = @anchorY * value

      if color
        color = color.replace('#', '0x')
        real.children.forEach (i) ->
          i.material.color.setHex color

    setVirtualCapacity:(value,color)->

      if !@capacity
        return console.error 'capacity is not init.'
      if value and (value < 0 or value > 100)
        return console.log 'value err:', value
      capacity = @capacity
      real = capacity.getObjectByName(capacity.name + '_real')
      virtual = capacity.getObjectByName(capacity.name + '_virtual')
      if _.isNumber(value)
        if value == 0
          virtual.visible = false
        else if value / 100 + real.scale.y > 1
      # don't show virtual when virtual + real over 100.
          virtual.visible = false
        else
          virtual.visible = true
          value = value / 100
          virtual.scale.y = value
      if color
        color = color.replace('#', '0x')
        virtual.children.forEach (i) ->
          i.material.color.setHex color

    rotateAction:(rotation,time)->
      x = (@rotation.x or 0) + (rotation.x or 0) * Math.PI / 180
      y = (@rotation.y or 0) + (rotation.y or 0) * Math.PI / 180
      z = (@rotation.z or 0) + (rotation.z or 0) * Math.PI / 180
      newRotation = new (THREE.Euler)(x, y, z)
      @tween = new (TWEEN.Tween)(@showingObject.rotation).to({
        x: newRotation.x
        y: newRotation.y
        z: newRotation.z
      }, time||2000).start()
      console.log newRotation, @rotation
      @rotation.copy newRotation

    setVisible:(flag)->
      if not _.isBoolean(flag)
        return console.error('flag should be boolean.')

      @visible = flag
      @showingObject.visible = @visible


    isTipCube:(mesh)->
      return mesh.name is @name+'-tip-cube'


    dispose:()->
      # console.log("dispose:",this.name)
      parent = @parent
      #TODO: only support thing which is added dynamically.
      if parent
        parent.removeChild this
      else
        console.log 'error:only support thing which is added dynamically.', @name, this
      return

  exports = Thing