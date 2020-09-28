`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define(['underscore', "threejs", "orbit-controls"], (_, THREE) ->
  class Building
    constructor: (element, elementKey) -> (
      @element = element.find(elementKey)[0]
      @height = @element.offsetHeight
      @width = @element.offsetWidth

      @scene = null

      @camera = null

      @renderer = new THREE.WebGLRenderer({antialias: true, alpha :true})
      @renderer.setSize(@width, @height)
      @renderer.setClearColor(0x000000, 0)
      @renderer.gammaOutput = true
      @element.appendChild(@renderer.domElement)

      @raycaster = new THREE.Raycaster()
      @checkList = []

      @objs = {}

      @active = null

      @animate = null

      @url = null
      @loadStatus = false
    )

# 渲染
    render: () -> (
      @animate = window.requestAnimationFrame(@render.bind(@))
      @orbitControl.update()
      @composer.render()
    )

# 设置摄像头
    setCamera: (data) -> (
      camera = new THREE.PerspectiveCamera(data.fov, @width / @height, 0.1, 10000)
      p = Math.PI / 180
      if _.has(data, "screen")
        d = data.screen
        camera.position.set(d.x, d.y, d.z)
        camera.rotation.set(p * d.rotationX, p * d.rotationY, p * d.rotationZ)
      else
        camera.position.set(data.x, data.y, data.z)
        camera.rotation.set(p * data.rotationX, p * data.rotationY, p * data.rotationZ)
      if !@orbitControl
        @orbitControl = new THREE.OrbitControls(camera, @renderer.domElement)
        @orbitControl.minPolarAngle = 0
        @orbitControl.maxPolarAngle = Math.PI / 2
      return camera
    )

# 场景更新
    setScene: (scene) -> (
      @scene.dispose() if @scene
      @scene = scene
      @scene.background = null

      @checkList = []
      @objs = {}

      @scene.traverse((obj) => (
        if obj?.name?[0] == "$"
          @objs[obj.name.slice(1)] = obj
        if obj?.parent?.name?[0] == "$"
          @checkList.push(obj)
      ))

      @camera = @setCamera(scene.userData)
      window.cameraHelp = @camera

      @composer = new THREE.EffectComposer( @renderer )
      @composer.addPass( new THREE.RenderPass( @scene, @camera ) );

      @outlinePass = new THREE.OutlinePass( new THREE.Vector2( @width, @height ), @scene, @camera );
      @outlinePass.edgeStrength = 10
      @outlinePass.edgeGlow = 1
      @outlinePass.edgeThickness = 1
      @outlinePass.pulsePeriod = 3
      @outlinePass.visibleEdgeColor.set('#35f2d1');
      @outlinePass.hiddenEdgeColor.set('#30a0de');
      @outlinePass.selectedObjects = []
      @composer.addPass( @outlinePass );

      @effectFXAA = new THREE.ShaderPass( THREE.FXAAShader );
      @effectFXAA.uniforms[ 'resolution' ].value.set( 1 / @width, 1 / @height );
      @effectFXAA.renderToScreen = true
      @effectFXAA.clear = true
      @composer.addPass( @effectFXAA )

      @orbitControl = new THREE.OrbitControls(@camera, @renderer.domElement)
      @orbitControl.minPolarAngle = 0
      @orbitControl.maxPolarAngle = Math.PI / 2

      @render()
    )

# 加载scene的json文件
    loadScene: (url, callback) => (
      if @loadStatus && @url == url
        return callback()

      @loadStatus = false
      @url = url
      loader = new THREE.ObjectLoader
      success = (json) => (
        @loadStatus = true
        callback()
        @setScene(json)
      )
      progess = (xhr) => callback(parseInt(xhr.loaded * 100 / xhr.total))
      error = (xhr) -> console.error('加载3D文件失败：', xhr)

      loader.load("/resource/upload/img/public/" + url, success, progess, error)
    )

# 通过鼠标点击获得选中的对象
    getObjByMouse: (e) => (
      mouse = new THREE.Vector2()
      mouse.x = (e.offsetX / @renderer.domElement.clientWidth) * 2 - 1
      mouse.y = -(e.offsetY / @renderer.domElement.clientHeight) * 2 + 1
      @raycaster.setFromCamera( mouse, @camera )
      intersects = @raycaster.intersectObjects( @checkList )
# @active.position.setY(0) if !_.isNull(@active)
      if intersects.length > 0
        key = intersects[0].object.parent.name.slice(1)
        @active = @objs[key].children
        @outlinePass.selectedObjects = @objs[key].children
        return intersects[0].object.parent.name.slice(1)
      else
        @active = null
        @outlinePass.selectedObjects = []
        return null
    )

# 通过对象获取屏幕位置
    getScreenByObj: (key) => (
      return if _.isEmpty(this.objs) || !_.has(this.objs, key)
      vector = new THREE.Vector3()
      vector.setFromMatrixPosition(@objs[key].matrixWorld)
      vector.project(@camera)
      widthHalf = @width / 2
      heightHalf = @height / 2
      result = {
        x: vector.x * widthHalf + widthHalf,
        y: -(vector.y * heightHalf) + heightHalf
      }
      return result
    )

# 旋转
    rotate: () => (
      @orbitControl.autoRotateSpeed = 2
      @orbitControl.autoRotate = !@orbitControl.autoRotate
    )

# 更新对象的状态
    updateState: (key, state) => (
      data = @objs[key].userData[state]
      return if !data
      if _.has(data, "color")
        _.each(@objs[key].children, (obj) =>
          obj.material = new THREE.MeshBasicMaterial({ color: new THREE.Color(data["color"]) })
        )
      else if _.has(data, "position")
        @objs[key].position.set(data["position"][0], data["position"][1], data["position"][2])
    )

# 自适应
    resize: () => (
      return if typeof(@element.offsetHeight) == "number" && @element.offsetHeight > 0
      if @height != @element.offsetHeight || @width != @element.offsetWidth
        @height = @element.offsetHeight
        @width = @element.offsetWidth
        @renderer.setSize(@width, @height)
        @camera.aspect = @width / @height
        @outlinePass = new THREE.OutlinePass( new THREE.Vector2( @width, @height ), @scene, @camera );
        @effectFXAA.uniforms[ 'resolution' ].value.set( 1 / @width, 1 / @height );
    )

# 销毁
    dispose: () => (
      window.cancelAnimationFrame(@animate)
      @checkList = []
      @objs = {}
      @active = null
      @animate = null
      @scene.dispose()
      $(@element).empty()
    )

  return { Building: Building }
)