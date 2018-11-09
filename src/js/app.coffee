RADIANS_PER_DEGREE = Math.PI / 180
# Should particles animate their opacity?
ANIMATE_OPACITY = false

gl = undefined  # WebGL API handle
shaderProgram = undefined

# How far the mouse has dragged in the X axis
mouseDeltaX = 0

# Position of the camera
cameraPos =
  x: -5
  y: 3
  z: 5

# Floor
floorVertexBuffer = undefined
floorIndexBuffer = undefined

# Cube
cubeVertexBuffer = undefined
cubeIndexBuffer = undefined

# Emitter
confettiEmitter = new ConfettiEmitter(0, 0.8, 0)

# Transformation Matrices
projectionMatrix = mat4.create()
modelViewMatrix = mat4.create()

# Matrix Stack
# Used to conserve state
modelViewMatrixStack =
  stack: []
  push: ->
    @stack.push mat4.clone(modelViewMatrix)
  pop: ->
    modelViewMatrix = @stack.pop()

# Helpers to update the matrix uniforms inside the shaders
sendProjectionMatrixToShader = ->
  gl.uniformMatrix4fv(shaderProgram.projectionMatrixUniform, false, projectionMatrix)

sendModelViewMatrixToShader = ->
  gl.uniformMatrix4fv(shaderProgram.modelViewMatrixUniform, false, modelViewMatrix)

# Grab the WegGL context from the canvas element
initGLContext = ->
  canvas = document.getElementById('gl-canvas')
  gl = canvas.getContext('experimental-webgl')

  # Attach custom viewport information onto the GL context
  gl.viewportWidth = canvas.width
  gl.viewportHeight = canvas.height

# The shaders are stored in DOM <script> tags.
# This helper grabs the shader source and compiles a new shader object.
getShaderFromDOM = (id, shaderType) ->
  source = $('#' + id).text()

  if shaderType == 'vertex'
    shader = gl.createShader(gl.VERTEX_SHADER)
  else if shaderType == 'fragment'
    shader = gl.createShader(gl.FRAGMENT_SHADER)

  gl.shaderSource(shader, source)
  gl.compileShader(shader)

  shader

# Grab the shaders from the DOM, create a shader program and attach it to the GL context
initShaders = ->
  vertexShader = getShaderFromDOM('vertex-shader', 'vertex')
  fragmentShader = getShaderFromDOM('fragment-shader', 'fragment')

  shaderProgram = gl.createProgram()
  gl.attachShader(shaderProgram, vertexShader)
  gl.attachShader(shaderProgram, fragmentShader)
  gl.linkProgram(shaderProgram)
  gl.useProgram(shaderProgram)

  # Create pointers to variables inside the shader's source to be set later
  shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, 'aVertexPosition')
  shaderProgram.vertexColorAttribute = gl.getAttribLocation(shaderProgram, 'aVertexColor')
  shaderProgram.projectionMatrixUniform = gl.getUniformLocation(shaderProgram, 'uProjectionMatrix')
  shaderProgram.modelViewMatrixUniform = gl.getUniformLocation(shaderProgram, 'uModelViewMatrix')

# Buffers store the information about objects
initBuffers = ->
  initFloorBuffer()
  initCubeBuffer()

# Define the floor and bind it to a buffer
initFloorBuffer = ->
  floorVertexBuffer = gl.createBuffer()
  # Make this the active buffer
  gl.bindBuffer(gl.ARRAY_BUFFER, floorVertexBuffer)

  floorVertices = [
     1,   0,   -1,  # top right
    -1,   0,   -1,  # top left
    -1,   0,    1,  # bottom left
     1,   0,    1   # bottom right
  ]

  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(floorVertices), gl.STATIC_DRAW)
  floorVertexBuffer.numOfItems = 4  # 4 vertices
  floorVertexBuffer.itemSize = 3  # 3 coordinates per vertex

  # Use indices to reuse vertices
  floorIndexBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, floorIndexBuffer)
  floorIndices = [
    0,  # top right
    1,  # top left
    2,  # bottom left
    0,  # top right
    3   # bottom right
    2,  # bottom left
  ]

  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(floorIndices), gl.STATIC_DRAW)
  floorIndexBuffer.numOfItems = 6
  floorIndexBuffer.itemSize = 1

drawFloor = ->
  # Every vertex should use the same color
  gl.disableVertexAttribArray(shaderProgram.vertexColorAttribute);
  gl.vertexAttrib4f(shaderProgram.vertexColorAttribute, 1, 1, 1, 1);  # white

  # Use the vertex buffer array for vertex positions
  gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute)

  # Make the floor the active buffer
  gl.bindBuffer(gl.ARRAY_BUFFER, floorVertexBuffer)
  gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, floorVertexBuffer.itemSize, gl.FLOAT, false, 0, 0)
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, floorIndexBuffer)

  # Fill the triangles
  gl.drawElements(gl.TRIANGLE_FAN, floorIndexBuffer.numOfItems, gl.UNSIGNED_SHORT, 0)

  # Draw the outline lines
  gl.lineWidth(5)
  gl.vertexAttrib4f(shaderProgram.vertexColorAttribute, 0, 0, 0, 1);  # black
  gl.drawElements(gl.LINE_LOOP, floorIndexBuffer.numOfItems, gl.UNSIGNED_SHORT, 0)

# Define the properties of a cube
initCubeBuffer = ->
  # Create and make active the cube vertex buffer
  cubeVertexBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexBuffer)

  # omg...
  cubeVertices = [
    # Front face
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,

    # Back face
     1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,

    # Left face
    -1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,

    # Right face
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,

    # Top face
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,

    # Bottom face
     1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,
    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0
  ]

  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(cubeVertices), gl.STATIC_DRAW)
  cubeVertexBuffer.numOfItems = 24
  cubeVertexBuffer.itemSize = 3

  # Again, use indices to specify shared vertices
  cubeIndexBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeIndexBuffer)
  cubeIndices = [
     0,  1,  2,    0,  2,  3,  # Front face
     4,  6,  5,    4,  7,  6,  # Back face
     8,  9, 10,    8, 10, 11,  # Left face
    12, 13, 14,   12, 14, 15,  # Right face
    16, 17, 18,   16, 18, 19,  # Top face
    20, 22, 21,   20, 23, 22   # Bottom face
  ]
  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeIndices), gl.STATIC_DRAW)
  cubeIndexBuffer.numOfItems = 36
  cubeIndexBuffer.itemSize = 1

drawCube = ->
  # Every vertex should use the same color
  gl.disableVertexAttribArray(shaderProgram.vertexColorAttribute);
  gl.vertexAttrib4f(shaderProgram.vertexColorAttribute, 1, 1, 1, 1);  # white

  # Use the vertex buffer array for vertex positions
  gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute)

  # Make the cube the active buffer
  gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexBuffer)
  gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, cubeVertexBuffer.itemSize, gl.FLOAT, false, 0, 0)
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeIndexBuffer)

  # Draw triangles
  gl.drawElements(gl.TRIANGLES, cubeVertexBuffer.numOfItems, gl.UNSIGNED_SHORT, 0)

  # Draw the outline lines
  gl.lineWidth(5)
  gl.vertexAttrib4f(shaderProgram.vertexColorAttribute, 0, 0, 0, 1);  # black
  gl.drawElements(gl.LINE_LOOP, cubeIndexBuffer.numOfItems, gl.UNSIGNED_SHORT, 0)

prepareToDraw = ->
  vertical_fov = 45 * RADIANS_PER_DEGREE
  # perspective(out matrix, fov in radians, aspect ratio, near limit, far limit)
  mat4.perspective(projectionMatrix, vertical_fov, gl.viewportWidth / gl.viewportHeight, 0.1, 100)

  # Enable the depth buffer to hide hidden fragments
  gl.enable(gl.DEPTH_TEST);

  # Background color
  gl.clearColor(0, 0, 0, 1)
  gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)

# Draw the entire scene and repeat 30 frames a second
draw = ->
  # Actually clear the background to what gl.clearColor() declared
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

  mat4.identity(modelViewMatrix)
  # lookAt(out matrix, eye position, view direction, up direction)
  mat4.lookAt(modelViewMatrix, [cameraPos.x, cameraPos.y, cameraPos.z], [0, 0, 0], [0, 1, 0])
  # Rotate the scene based on the mouse movements
  mat4.rotateY(modelViewMatrix, modelViewMatrix, (mouseDeltaX / 10) * RADIANS_PER_DEGREE)

  # Update the vertex shader with the matrices
  sendProjectionMatrixToShader()
  sendModelViewMatrixToShader()

  confettiEmitter.update()
  confettiEmitter.draw(ANIMATE_OPACITY)

  # Draw the scaled floor
  modelViewMatrixStack.push()
  mat4.scale(modelViewMatrix, modelViewMatrix, [2, 2, 2])
  sendModelViewMatrixToShader()
  drawFloor()
  modelViewMatrixStack.pop()

  # Make the emitter model
  modelViewMatrixStack.push()
  mat4.scale(modelViewMatrix, modelViewMatrix, [0.3, 0.3, 0.3])
  mat4.translate(modelViewMatrix, modelViewMatrix, [0, 1.03, 0])
  sendModelViewMatrixToShader()
  drawCube()
  mat4.scale(modelViewMatrix, modelViewMatrix, [0.5, 0.5, 0.5])
  mat4.translate(modelViewMatrix, modelViewMatrix, [0, 3, 0])
  sendModelViewMatrixToShader()
  drawCube()
  modelViewMatrixStack.pop()

  # Repeat!
  setTimeout(draw, 30)

init = ->
  initGLContext()

  initShaders()
  initBuffers()

  # Make global
  window.gl = gl
  window.shaderProgram = shaderProgram

  prepareToDraw()
  draw()

# Begin when the DOM is ready
$ ->
  init()

  # Allow the scene to be rotated by the mouse
  mouseDown = false  # Mousedown status
  oldMouseDeltaX = 0
  onStop = ->
    mouseDown = false
    oldMouseDeltaX = mouseDeltaX

  $('#gl-canvas').mousedown (e) ->
    mouseDown =
      x: e.pageX
      y: e.pageY
  .mouseup(onStop)
  .mouseout(onStop)
  .mousemove (e) ->
    mouseDeltaX = oldMouseDeltaX + e.pageX - mouseDown.x if mouseDown

  # Setup the confetti slider
  $confettiCount = $('#confetti-count')
  $confettiCount.text(ConfettiEmitter.maxAliveConfetti)

  $('#confetti-slider').slider(
    value: ConfettiEmitter.maxAliveConfetti
    min: 10
    max: 10000
    slide: (e, ui) ->
      ConfettiEmitter.maxAliveConfetti = ui.value
      $confettiCount.text(ui.value)
  )

  $('#animate-opacity').change ->
    ANIMATE_OPACITY = @checked
