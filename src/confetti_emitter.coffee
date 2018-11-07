BOUNCE = 0.3
GRAVITY = -0.005

# A global class
class window.ConfettiEmitter
  @minY: -5  # How far can the cofetti fall?
  @maxAliveConfetti: 1000  # How much coffetti to be in the scene
  constructor: (x = 0, y = 0, z = 0) ->
    @pos = [x, y, z]
    @confetti = []
  update: ->
    i = @confetti.length

    # Create new cofetti if needed
    while i <= ConfettiEmitter.maxAliveConfetti
      @confetti.push new Confetto(@pos...)
      ++i

    # Loop backwards and update/ kill confetti
    while --i
      @confetti[i].update()

      # Did it fall too far?
      @confetti.splice(i, 1) if @confetti[i].pos[1] < ConfettiEmitter.minY
  draw: (animateOpacity) ->
    # Both position and color will come from array buffers
    gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute)
    gl.enableVertexAttribArray(shaderProgram.vertexColorAttribute)

    vertices = []
    colors = []
    animateOpacity =
    for confetto in @confetti
      # Modify the alpha over time
      if animateOpacity
        confetto.color[3] = performance.now() % 4000 / 3000

      vertices.push(confetto.pos...)
      colors.push(confetto.color...)

    # Create an array buffer for the positions
    vertexBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)
    gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute,
                           3,  # Size of a position (x, y, z)
                           gl.FLOAT, false, 0, 0);

    # Create an array buffer for the colors
    colorBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW)
    gl.vertexAttribPointer(shaderProgram.vertexColorAttribute,
                           4,  # Size of a color (r, g, b, a)
                           gl.FLOAT, false, 0, 0);

    # Draw all the confetti at once
    gl.drawArrays(gl.POINTS, 0, @confetti.length)

class Confetto
  constructor: (x = 0, y = 0 , z = 0) ->
    @pos = [x, y, z]

    # rgba (values between 0 and 1)
    @color = [Math.random(), Math.random(), Math.random(), 1]

    # Velocities
    @vx = Math.random() * 0.1 - 0.05
    @vy = Math.random() * 0.1 + 0.1
    @vz = Math.random() * 0.1 - 0.05
  update: ->
    @pos[0] += @vx
    @pos[1] += @vy
    @pos[2] += @vz

    @vy += GRAVITY

    # Did the confetto hit the floor?
    if @pos[1] < 0 and @pos[0] > -2 and @pos[0] < 2 and @pos[2] > -2 and @pos[2] < 2
      @pos[1] = 0
      @vy *= -BOUNCE
