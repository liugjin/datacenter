###
* File: 3d/room
* User: Hardy
* Date: 2018/08/22
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`
define ["underscore","threejs","orbit-controls","tween","./thing"], (_,THREE,orbitControls,TWEEN,Thing) ->
  if(!window.debugR)
    window.debugR={}

  #  EffectComposer = THREE.EffectComposer
  #  RenderPass = THREE.RenderPass
  #  OutlinePass = THREE.OutlinePass
  #  ShaderPass = THREE.ShaderPass

  roomList = {}
  window.debugR.roomList=roomList

  class Room
    constructor:(name,element,options)->

      if roomList[name]
#        console.log("重复创建3D ROOM：",name,"继续使用旧对象")
        return roomList[name]

      @initDb()
      @name = name
      @options = options

      roomList[name] = this

      @thingList = {}
      # thingList show thing in parallel
      @groupList = {}
      # groupList show thing'name in depth
      @renderOrder = []
      # renderOrder order thing by groupList

      @element = element
      @innerWidth = element.clientWidth
      @innerHeight = element.clientHeight
      @getOffset()

      @scene = new THREE.Scene()
      @scene.name = name + '_scene'
      @renderer = new THREE.WebGLRenderer(options.renderder)
      @renderer.setSize @innerWidth, @innerHeight
      @renderer.setClearColor 0x000000, 0
      element.appendChild @renderer.domElement

      cameraOptions = options.camera
      cameraOptions.aspect = @innerWidth / @innerHeight
      return console.error("请检查样式，保证canvas有占用实际空间，否则无法渲染。") if not cameraOptions.aspect
      @initCamera cameraOptions

      @animateList = []
      @raycaster = new THREE.Raycaster()
      @mouse = new THREE.Vector2()
      @raycaster.checkList = []
      @raycaster.recursiveFlag = false
      @raycaster.callback =
        click:null
        dblclick:null
        mousemove:null

      @isDisposed = false
      @selectedThing = null

      @animate()

      @addAnimate 'updateRaycaster', @updateRaycaster.bind(@)
      window.addEventListener 'resize', @resize.bind(@)
      element.addEventListener 'click', @updateMouse.bind(@)
      element.addEventListener "dblclick",@updateMouse.bind(@)
      element.addEventListener "mousemove",@updateMouse.bind(@)

      if options.orbitControl

# NOTE:avoid 3d disappear when right click
        stopEvent = (event)=>
          if (event.button == 2)
            event.preventDefault();
            event.stopPropagation();
            event.stopImmediatePropagation()

        #          console.log("stopEvent",event)

        @renderer.domElement.addEventListener("mousedown",stopEvent)
        @orbitControl = new THREE.OrbitControls(@camera,@renderer.domElement)

      if !THREE.Cache.enabled
        THREE.Cache.enabled = true

    initCamera:(options)->
      switch options.type
        when 'PerspectiveCamera'
# TODO:fov calculate
# aspect = innerWidth / innerHeight
          if( !options.aspect )
            return console.error("PerspectiveCamera should have aspect parameter.")
          else
            @camera = new (THREE.PerspectiveCamera)(options.fov, options.aspect, 0.1, 100000)
          break
        else
          console.error 'init camera error: don\'t support ', options.type
          break
      camera = @camera
      camera.position.set options.x or 0, options.y or 0, options.z or 0
      camera.rotation.set options.rotationX * Math.PI / 180 or 0, options.rotationY * Math.PI / 180 or 0, options.rotationz * Math.PI / 180 or 0

    addAnimate:(key,func)->
      index = _.findLastIndex(@animateList, {key: key})
      if index is -1
        @animateList.push({key:key,func:func})
      else
        @animateList[index]?.func = func

    removeAnimate:(key)->
      index = _.findLastIndex(@animateList, {key: key})
      return console.log('err: key is not in list',key,@animateList) if index is -1
      @animateList.splice(index,1)

    animate:()->

      if !@isDisposed
        animateFun = @animate.bind(@)
        requestAnimationFrame animateFun

      @animateList.forEach((obj)->
        if(_.isFunction(obj.func))
          obj.func()
      )
      TWEEN.update()
      if @composer
        @composer.render()
      else
        @renderer.render @scene, @camera

    setCamera:(options)->
      return console.log("setCamera options is null") if not options
      camera = @camera
      if options.fov
        camera.fov = options.fov
      camera.position.set options.x or 0, options.y or 0, options.z or 0
      camera.rotation.set options.rotationX * Math.PI / 180 or 0, options.rotationY * Math.PI / 180 or 0, options.rotationz * Math.PI / 180 or 0
      camera.updateProjectionMatrix()
      if @orbitControl
        @orbitControl.update()


    initScene:(obj)->
      @resize()
      scene = obj
      @scene = obj
      # @focus(scene.children[0])
      if scene.userData
        @setCamera scene.userData
      # clear scene background to keep tranparent
      scene.background = null
      @generatorThings()
      @setRaycasterCheckList @thingList, true, @raycaster.callback
      # console.log(@element)
      @renderer.render @scene, @camera
      # clear scene background to keep tranparent
      @scene.background = null

    loadSceneByUrl:(url,callback,preloadCallback,cache)->
      loader = new THREE.ObjectLoader
      #      self = @
      onLoad = (obj) =>
        if cache
          @setDataToDataBase(url,obj)
        @initScene(obj)
        callback?(null,obj)

      onProgress = (xhr) ->
#        console.log((xhr.loaded / xhr.total * 100) + '% loaded' )
        preloadCallback?((xhr.loaded / xhr.total * 100).toFixed(0))

      onErrors = (xhr) ->
        console.error '加载3D文件失败：',xhr

      loader.load url, onLoad, onProgress , onErrors

    loadSceneByJSON:(json,callback)->

      loader = new THREE.ObjectLoader
      object =JSON.parse(json)
      loader.parse object,(obj)=>
        @initScene(obj)
        callback?(null,obj)

    loadScene:(url,callback,preloadCallback)->
      load=()=>
        @getDataFromDatabase url,(err,json)=>
          return console.warn(err) if err
          if json
            @loadSceneByJSON(json,callback)
          else
            @loadSceneByUrl(url,callback,preloadCallback,true)

      if !@db
        @dbCallback=(err)=>
          return console.warn(err) if err
          load()
      else
        load()


    generatorThings:()->
      @thingList = {}
      @scene.traverse((object3D)=>
        if(object3D.name.indexOf("$") == 0)
          name = object3D.name.substring(1)
          if(@thingList[name])
            return console.error(name,'is repeat.',object3D)

          @thingList[name] = new Thing(name,object3D)
      )
      @initCroupList()
      @initRenderOrder()

      _.forEach @thingList, (thing) ->
        if thing.userData.showingType == 'wireframe'
          thing.changeToWireframe()
          list = []
          thing.object3D.children.forEach (object3d) ->
            if object3d.$thing
              list.push object3d
          list.forEach (object3d) ->
            thing.showingObject.add object3d
          thing.normal = thing.wireframe

    getOffset:()->
      node = @element
      @offsetLeft =node.offsetLeft
      @offsetTop = node.offsetTop
      while(node.offsetParent)
        node = node.offsetParent
        @offsetLeft += node.offsetLeft
        @offsetTop += node.offsetTop

    initCroupList:()->
      groupList = @groupList
      _.forEach(@thingList,(thing)->
        path = []
        t = thing.getParentThing()
        while(t)
          path.push(t.name)
          t = t.getParentThing()
        path.push(thing.name)
        #        console.log("initCroupList:",thing.name,path)
        #ensure the path is available
        anchor = groupList
        while(path.length>1)
          key = path.shift()
          if(!groupList[key])
            groupList[key] = {}
          anchor = groupList[key]

        anchor[path[0]] = null
      )
#      console.log("initCroupList:",groupList)

    initRenderOrder:()->
      self = @
      getKeys=(object)->
        _.forEach(object,(value,key)->
          self.renderOrder.push(key)
          if(value)
            getKeys(value)
        )
      getKeys(@groupList)
#      console.log("initRenderOrder",@renderOrder)
    resize:()->
#      console.log("room resize")
      @getOffset()
      element = @element
      if(element.clientWidth is 0 or element.clientHeight is 0)
        return console.log("element width and height error:",element.clientWidth,element.clientHeight)
      #        setTimeout(()->
      #          window.dispatchEvent(new Event('resize'))
      #        ,1000)

      @innerWidth = element.clientWidth
      @innerHeight = element.clientHeight
      #      console.log @innerWidth, @innerHeight

      if @options.camera.type == 'PerspectiveCamera'
        @camera.aspect = @innerWidth / @innerHeight
        @camera.updateProjectionMatrix()
      #        camera.fov = Math.atan(window.innerHeight / 2 / camera.position.z) * 2 * THREE.Math.RAD2DEG

      #        console.log @camera.aspect
      @renderer.setSize @innerWidth, @innerHeight

      self = @
      setTimeout(()->
        if(self.innerWidth != element.clientWidth or self.innerHeight != element.clientHeight)
          self.resize()
      ,1000)
#      console.log("room resize",self.innerWidth,element.clientHeight)

    updateMouse:(event)->
      mouse = @mouse
      if event.type == 'click'
        mouse.eventType = 'click'
      else if event.type == 'dblclick'
        mouse.eventType = 'dblclick'
      else if event.type == 'mousemove'
        mouse.eventType = 'mousemove'
      mouse.x = (event.clientX - (@offsetLeft)) / @innerWidth * 2 - 1
      mouse.y = -((event.clientY - (@offsetTop)) / @innerHeight) * 2 + 1
#      console.log('X:',event.clientX,"y:",event.clientY,mouse)


    updateRaycaster:()->
      if @raycaster.checkList.length == 0
        return

      raycaster = @raycaster
      checkList = []
      _.forEach(raycaster.checkList,(thing)->
        checkList.push(thing.showingObject)
      )
      raycaster.setFromCamera @mouse, @camera
      intersects = raycaster.intersectObjects(checkList, raycaster.recursiveFlag)

      if intersects.length == 0
        if @mouse.eventType == "dblclick"
          @selectedThing = null
          @mouse.eventType = null
          @setOutline([])
        else if @mouse.eventType == 'mousemove'
          raycaster.callback?.mousemove?(null,intersects)
        return

      if @mouse.eventType == 'click'
        @mouse.eventType = null
        raycaster.callback?.click?(null,intersects)
      else if @mouse.eventType == 'dblclick'
        @mouse.eventType = null
        raycaster.callback?.dblclick?(null,intersects)
      else if @mouse.eventType == 'mousemove'
        @mouse.eventType = null
        raycaster.callback?.mousemove?(null,intersects)
        if not @selectedThing and intersects[0]?.object?.parent?.$thing?.userData.selectedPositionOffset
          @setOutline([intersects[0]?.object])

    setRaycasterCheckList:(thingList,recursive,callback)->
      raycaster = @raycaster
      raycaster.checkList = []
      _.forEach thingList, (value, key) ->
        if !value.isThing
          return console.error('it should be thing.', value)
        raycaster.checkList.push value
        return
      if _.isBoolean(recursive)
        raycaster.recursiveFlag = recursive
      if callback
        raycaster.callback = callback

    setRaycasterCallback:(callback)->
      return if not callback
      @raycaster.callback = callback

    getThingByObject3D:(object3D)->
      if !object3D.isObject3D
        return console.error(name,"is not object3d,but is:",object)

      mesh = object3D
      while !mesh.$thing
        if !mesh.parent
          break
        mesh = mesh.parent

      return mesh.$thing

    getThingByName:(name)->
      return @thingList[name]

    selectThing:(thing)->
      return if not thing
      if thing?.isThing
        if @selectedThing and @selectedThing.name == thing.name
          thing.resetAction()
          @selectedThing = null
          return

        @selectedThing = thing
        _.forEach @thingList, (t) ->
          if t.name == thing.name
            t.selectedAction()
          else
            t.resetAction()
          return
      else
        return console.error 'can\'t get thing', thing

    changeToCapacity:()->
      self = this
      thing = null
      _.forEach @renderOrder, (name) ->
        thing = self.getThingByName(name)
        if thing
          thing.changeToCapacity()

    changeToNormal:()->
      self = this
      thing = null
      _.forEach @renderOrder, (name) ->
        thing = self.getThingByName(name)
        if thing
          thing.changeToNormal()

    rotateAction:(rotation,time)->
      @scene.children.forEach((t)->
        if(t.$thing)
          t.$thing.rotateAction(rotation,time)
      )

    autoRotate:(flag,autoRotateSpeed)->
      @orbitControl?.autoRotateSpeed = autoRotateSpeed || 2
      if flag
        @orbitControl?.autoRotate = true
        @addAnimate('autoRotate',()=>
          @orbitControl?.update()
        )
      else
        @orbitControl?.autoRotate = false
        @removeAnimate('autoRotate')


    setThingCapacity:(name,value,color,virtualFlag)->
      thing = @getThingByName(name)
      if !thing
        return
      if virtualFlag
        thing.setVirtualCapacity value, color
      else
        thing.setRealCapacity value, color

    setThingVisible:(name,flag)->
      thing = @getThingByName(name)
      if !thing
        return console.log 'error:this thing is not exit:', name, thing

      if flag
        thing.setVisible(true)
      else
        thing.setVisible(false)

    initOutline:()->
      composer = new THREE.EffectComposer @renderer
      @composer = composer

      renderPass = new THREE.RenderPass( @scene, @camera)
      composer.addPass( renderPass )

      outlinePass = new THREE.OutlinePass( new THREE.Vector2( @innerWidth, @innerHeight ), @scene, @camera )
      composer.addPass( outlinePass )
      @outlinePass = outlinePass
      outlinePass.edgeStrength = 5
      outlinePass.edgeGlow = 1
      outlinePass.pulsePeriod = 2
      outlinePass.visibleEdgeColor?.set('#35f2d1')
      outlinePass.hiddenEdgeColor?.set('#30a0de')

      effectFXAA = new THREE.ShaderPass( THREE.FXAAShader )
      effectFXAA.uniforms[ 'resolution' ].value.set( 1 / @innerWidth, 1 / @innerHeight )
      effectFXAA.renderToScreen = true
      composer.addPass( effectFXAA )

    setOutline:(array)->
      @outlinePass.selectedObjects = array if @outlinePass

    setThingOutline:(thingArray)->
      return if not thingArray
      arr = []
      if thingArray.length != 0
        for thing in thingArray
          arr.push(thing.showingObject)

      @setOutline arr

    setThingTipCube:(thing,color1,color2)->
      return console.log(thing ,'is not a thing') if not thing?.isThing
      @deleteThingTipCube(thing)

      # get all scale
      scale = thing.showingObject.getWorldScale(new THREE.Vector3(1,1,1))
      box3 = (new THREE.Box3()).setFromObject(thing.object3D)
      x = box3.max.x - box3.min.x
      y = box3.max.y - box3.min.y
      z = box3.max.z - box3.min.z
      scaleMin = _.min([scale.x,scale.y,scale.z])
      len = _.min([x,y,z])/scaleMin/8
      geometry = new THREE.BoxGeometry(len,len,len)
      material = new THREE.MeshBasicMaterial( {color: color1 || 0x00ff00 } )
      cube = new THREE.Mesh( geometry, material )
      cube.name = thing.name+'-tip-cube'
      thing.tipCube = cube
      thing.showingObject.add(thing.tipCube)
      offset = thing.userData?.selectedPositionOffset

      cube.position.y = (y/scale.y) + len
      cube.position.x += (x/scale.x)/2 - 2*len if offset?.x
      cube.position.z += (z/scale.z)/2 - 2*len if offset?.z

      cube.interpolates = 0
      cube.interpolatesAdd = 0.02

      if color2
        col1 = new THREE.Color(color1)
        col2 = new THREE.Color(color2)
        thing.tipCube.animate = cube.name+ '-animate'
        @addAnimate(thing.tipCube.animate,()=>
          if(cube.interpolates <= 0)
            cube.interpolatesAdd = 0.02
          else if(cube.interpolates >= 1)
            cube.interpolatesAdd = -0.02

          cube.interpolates += cube.interpolatesAdd
          color = col1.clone()
          cube.material.color = color.lerp(col2,cube.interpolates)
        )

    deleteThingTipCube:(thing)->
      if thing?.tipCube
        @removeAnimate(thing.tipCube.animate) if thing.tipCube.animate
        thing.tipCube.parent.remove(thing.tipCube)
        thing.tipCube = null

    getScreenCoordinate:(object) ->
      vector = new (THREE.Vector3)

      if object.$thing?.box3?
        object.$thing?.box3?.getCenter(vector)
        vector.y *= 1.5
      else
        vector.setFromMatrixPosition object.matrixWorld
      #      console.log(object.$thing.name,vector)
      vector.project @camera
      width = @innerWidth
      height = @innerHeight
      widthHalf = width / 2
      heightHalf = height / 2
      result = {}
      result.x = vector.x * widthHalf + widthHalf + @offsetLeft
      result.y = -(vector.y * heightHalf) + heightHalf + @offsetTop
      #      console.log("getScreenCoordinate:",result,@offsetLeft,@offsetTop,vector)
      result

    initDb:()->
      if not @db
        request = indexedDB.open("3d-files-db")
        request.onerror=(event)=>
          console.log("Database error: "+event.target.errorCode)
          @dbCallback?("Database error: "+event.target.errorCode)
        request.onupgradeneeded=(event)=>
          @db = event.target.result
          if not @db.objectStoreNames.contains('3d-files-table')
            @db.createObjectStore('3d-files-table', { keyPath: 'id' })
        request.onsuccess=(event)=>
          @db = event.target.result
          @dbCallback?()
      else
        @dbCallback?()


    getDataFromDatabase:(path,cb)->
      return console.warn("db is null") if not @db
      transaction = @db.transaction(["3d-files-table"],"readonly")
      objectStore = transaction.objectStore('3d-files-table')
      objectStoreRequest=objectStore.get(path)
      transaction.onerror =(event)=>
        console.warn("transaction error:",event)

      objectStoreRequest.onsuccess=()=>
        cb?(null,objectStoreRequest.result?.data)

      objectStoreRequest.onerror=(event)=>
        cb?(event)

    setDataToDataBase:(key,data)->
      return console.warn("db is null") if not @db
      transaction = @db.transaction(["3d-files-table"],"readwrite")
      transaction.onerror =(event)=>
        console.warn("transaction error:",event)

      objectStore = transaction.objectStore('3d-files-table')
      objectStore.put({id:key,data:JSON.stringify(data)})

    dispose:()->
      @isDisposed = true
      @animateList = []
      window.removeEventListener 'resize', @resize
      @renderer.dispose()
      roomList[@name] = null
      scene = @scene
      scene.children.forEach (mesh) ->
        scene.remove mesh



  exports = Room