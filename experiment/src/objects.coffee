###*
# Add an object to the scene.
#
# @param {string} name - the name of the object
#
# @param {Object} object - the object to be added. Should have
# methods draw() and getBounds().
#
# @param {int} [index] - the sorting index where the object should be
# inserted. This determines in what order the objects are drawn;
# lower numbers will be drawn first. If not provided, then the object
# will be added at the end of the list.
#
# @throws {Error} - if the object is already in the scene (you should
# explicitly remove it first)
###

###jslint browser: true###

###global _, check###

###*
# Generic scene container for drawing on the canvas.
# @constructor
###

Scene = ->
  @xmin = @xmax = @ymin = @ymax = undefined
  @object_names = []
  @objects = {}
  return

###*
# A drawable object representing a wall.
#
# @constructor
# @param {integer} x - the x-coordinate of the upper-left corner
# @param {integer} y - the y-coordinate of the upper-left corner
# @param {integer} width - the width of the wall
# @param {integer} height - the height of the wall
# @param {string} [color=rgb(0, 0, 0)] - the color of the wall,
# represented as a rgb string. The default is black.
###

Wall = (x, y, width, height, color) ->
  @x = check('x', x)
  @y = check('y', y)
  @width = check('width', width)
  @height = check('height', height)
  @color = color or 'rgb(0, 0, 0)'
  return

background = (bounds, color) ->
  {xmin, ymin, xmax, ymax} = bounds
  x = check('xmin', xmin)
  y = check('ymin', ymin)
  width = check('xmax', xmax) - xmin
  height = check('ymax', ymax) - ymin
  color = color or '#cccccc'
  return new Wall(x, y, width, height, color)

###*
# A drawable object representing a gray, rectangular occluder.
#
# @constructor
# @param {integer} xmin - the minimum x value to be occluded
# @param {integer} xmax - the maximum x value to be occluded
# @param {integer} ymin - the minimum y value to be occluded
# @param {integer} ymax - the maximum y value to be occluded
###

Occluder = (bounds, color) ->
  {xmin, ymin, xmax, ymax} = bounds
  @x = check('xmin', xmin)
  @y = check('ymin', ymin)
  @width = check('xmax', xmax) - xmin
  @height = check('ymax', ymax) - ymin
  @color = color or '#cccccc'
  console.log '@color', @color
  return

###*
# A drawable object representing a ball.
#
# @constructor
# @param {integer} x - the x-coordinate of the center of the ball
# @param {integer} y - the y-coordinate of the center of the ball
# @param {integer} radius - the radius of the ball
# @param {string} [color=rgb(0, 0, 255)] - the color of the ball,
# represented as a rgb string. The default is blue.
###

Ball = (x, y, radius, color) ->
  @x = check('x', x)
  @y = check('y', y)
  @radius = check('radius', radius)
  @color = color or 'rgb(0, 0, 255)'
  return

###
# A drawable object representing a countdown timer.
#
# @constructor
# @param {integer} x - the x-coordinate of the center of the timer
# @param {integer} y - the y-coordinate of the center of the timer
# @param {integer} radius - the radius of the timer
###

Timer = (x, y, radius) ->
  @x = check('x', x)
  @y = check('y', y)
  @radius = check('radius', radius)
  @percentFilled = 100
  return

Trajectory = (t, x_offset, y_offset, index, color_bound) ->
  @t = check('trajectory', t)
  @x_offset = check('x_offset', x_offset)
  @y_offset = check('y_offset', y_offset)
  @index = check('index', index)
  @color_bound = color_bound
  return

Scene::addObject = (name, object, index) ->
  if @objects[name] != undefined
    throw new Error('object \'' + name + '\' already exists in the scene')
  @objects[name] = object
  if index == undefined
    @object_names.push name
  else
    @object_names.splice index, 0, name
  @computeBounds()
  return

###*
# Remove an object from the scene.
#
# @param {string} name - the name of the object to remove
# @throws {Error} - if the object is not in the scene
###

Scene::removeObject = (name) ->
  if @objects[name] == undefined
    # throw new Error('object \'' + name + '\' is not in the scene')
    return  # we can be sloppy about this
  delete @objects[name]
  @object_names = _.without(@object_names, name)
  @computeBounds()
  return

###*
# Computes the bounding box of the scene. This does not return
# anything, but stores the computed values in this.xmin, this.xmax,
# this.ymin, and this.ymax.
###

Scene::computeBounds = ->
  # if there are no objects in the scene, then the bounds are
  # undefined
  if @object_names.length == 0
    @xmin = undefined
    @xmax = undefined
    @ymin = undefined
    @ymax = undefined
    return
  # bounds are [xmin, xmax, ymin, ymax]
  bounds = undefined
  i = undefined
  @xmin = 100000
  # big number, this is a hack...
  @ymin = 100000
  @xmax = 0
  @ymax = 0
  i = 0
  while i < @object_names.length
    bounds = @objects[@object_names[i]].getBounds()
    @xmin = Math.min(@xmin, bounds[0])
    @xmax = Math.max(@xmax, bounds[1])
    @ymin = Math.min(@ymin, bounds[2])
    @ymax = Math.max(@ymax, bounds[3])
    i = i + 1
  return

###*
# Change the order position of an object such that it is the nth
# object that is drawn, where n is specified by the index.
#
# @param {string} name - the name of the object
# @param {integer} [index] - the index where the object should be
# moved to. If not provided, then this defaults to the end of the
# list.
# @throws {Error} - if the object is not in the scene
###

Scene::reorderObject = (name, index) ->
  if @objects[name] == undefined
    throw new Error('object \'' + name + '\' is not in the scene')
  @object_names = _.without(@object_names, name)
  if index == undefined
    @object_names.push name
  else
    @object_names.splice index, 0, name
  return

###*
# Get the bounding box of the scene.
# 
# @returns {Array} length 4 array containing [xmin, xmax, ymin, ymax]
###

Scene::getBounds = ->
  [
    @xmin
    @xmax
    @ymin
    @ymax
  ]

###*
# Clears the drawing of the scene.
#
# @param {Object} ctx - the canvas drawing context
###

Scene::clear = (ctx) ->
  ctx.clearRect @xmin, @ymin, @xmax - (@xmin), @ymax - (@ymin)
  return

###*
# Draws the scene.
#
# @param {Object} ctx - the canvas drawing context
###

Scene::draw = (ctx) ->
  i = undefined
  @clear ctx
  i = 0
  while i < @object_names.length
    @objects[@object_names[i]].draw ctx
    i = i + 1
  return

###*
# Get the bounds of the wall.
#
# @returns {Array} length 4 array containing [xmin, xmax, ymin, ymax]
###

Wall::getBounds = ->
  [
    @x
    @x + @width
    @y
    @y + @height
  ]

###*
# Draws the wall.
#
# @param {Object} ctx - the canvas drawing context
###

Wall::draw = (ctx) ->
  ctx.fillStyle = @color
  ctx.fillRect @x, @y, @width, @height
  return

###*
# Get the bounds of the occluder.
#
# @returns {Array} length 4 array containing [xmin, xmax, ymin, ymax]
###

Occluder::getBounds = ->
  [
    @x
    @x + @width
    @y
    @y + @height
  ]

###*
# Draws the occluder.
#
# @param {Object} ctx - the canvas drawing context
###

Occluder::draw = (ctx) ->
  ctx.fillStyle = @color
  ctx.fillRect @x, @y, @width, @height
  return

###*
# Get the (rectangular) bounds of the ball.
#
# @returns {Array} length 4 array containing [xmin, xmax, ymin, ymax]
###

Ball::getBounds = ->
  [
    @x - (@radius)
    @x + @radius
    @y - (@radius)
    @y + @radius
  ]

###*
# Draws the ball.
#
# @param {Object} ctx - the canvas drawing context
###

Ball::draw = (ctx) ->
  ctx.fillStyle = @color
  ctx.beginPath()
  ctx.arc @x, @y, @radius, 0, Math.PI * 2, true
  ctx.fill()
  return

###*
# Get the (rectangular) bounds of the timer.
#
# @returns {Array} length 4 array containing [xmin, xmax, ymin, ymax]
###

Timer::getBounds = ->
  [
    @x - (@radius)
    @x + @radius
    @y - (@radius)
    @y + @radius
  ]

###*
# Draws the timer. This will fill a percentage of a circle, depending
# on the value of this.percentFilled (which starts at 100% by
# default).
#
# @param {Object} ctx - the canvas drawing context
###

Timer::draw = (ctx) ->
  pct = Math.max(0, Math.min(@percentFilled / 100, 1))
  origin = -Math.PI / 2
  ctx.fillStyle = 'rgb(100, 100, 100)'
  # fill amount
  if @percentFilled > 0
    ctx.beginPath()
    ctx.arc @x, @y, @radius, origin, origin - (Math.PI * 2 * pct), true
    ctx.lineTo @x, @y
    ctx.fill()
  return

Trajectory::getBounds = ->
  xmin = undefined
  xmax = undefined
  ymin = undefined
  ymax = undefined
  i = undefined
  xmin = @t[0][0]
  xmax = @t[0][1]
  ymin = @t[0][0]
  ymax = @t[0][1]
  i = 1
  while i <= @index
    if @t[i][0] < xmin
      xmin = @t[i][0]
    if @t[i][1] < ymin
      ymin = @t[i][1]
    if @t[i][0] > xmax
      xmax = @t[i][0]
    if @t[i][1] > ymax
      ymax = @t[i][1]
    i = i + 1
  [
    xmin + @x_offset
    xmax + @x_offset
    ymin + @y_offset
    ymax + @y_offset
  ]

Trajectory::draw = (ctx) ->
  i = undefined
  c = undefined
  cb = undefined
  cb = @color_bound or @index - 1
  if @index > 1 and @index < @t.length
    i = 0
    while i < @index
      if cb - i > 20
        c = 200
      else
        c = (cb - i) * 10
      c /= 2
      ctx.beginPath()
      ctx.strokeStyle = 'rgb(' + c + ', ' + c + ', ' + c + ')'
      ctx.moveTo @t[i][0] + @x_offset, @t[i][1] + @y_offset
      ctx.lineTo @t[i + 1][0] + @x_offset, @t[i + 1][1] + @y_offset
      ctx.stroke()
      i = i + 1
  return
