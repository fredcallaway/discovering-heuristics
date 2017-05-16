###*
# Initialize the stimulus.
###


###*
# A generic stimulus base class. This creates the scene from the
# given config, and handles animating the scene. In general, you
# should not use Stimulus directory but subclass it. Stimulus only
# gives the generic skeleton of how a stimulus should be created.
#
# @constructor
# @param {Object} config - the configuration for the stimulus. This
# should include information about things like the width of the
# walls, the ball radius, etc. See jsonstruct.txt for details.
###

Stimulus = (config) ->
  window.stim = this  # debug
  # check that a configuration was actually passed in
  if !config
    return
  # parameters for the dimensions of the scene
  @width = check('width', config.Dims[0])
  @height = check('height', config.Dims[1])
  # width of the borders and the wall
  @wall_width = check('wall width', config.WallWid)
  # radius of the ball
  @ball_radius = check('ball radius', config.BallRad)

  # the initial trajectory that the ball will take
  @ball_path = check('ball path', config.ObsPath)
  # the feedback trajectory
  @ball_path_extra = undefined
  # the actual trajectory that the animation will show (because it
  # could be just the stimulus, or just the feedback, or both of
  # them concatenated together)
  @ball_trajectory = undefined
  @draw_trajectory = config.draw_trajectory
  # different scene layouts
  @layouts = check('layouts', config.Layouts)
  @current_layout = undefined
  # frame timer, for animating the ball
  @animator =
    'timer': undefined
    't': undefined
    'onFinish': undefined
  # drawing timer, for actually drawing the scene
  @drawer = 'timer': undefined
  # countdown timer, for animating a countdown
  @countdown =
    'timer': undefined
    'start_time': undefined
    'length': undefined
    'onFinish': undefined
  # misc metadata
  @metadata =
    'distance': check('distance', config.Distance)
    'num_bounces': check('num bounces', config.Bounces)
    'fps': check('fps', config.FPS)
  # the scene object, which contains the information about shapes
  # are in the scene
  @scene = undefined
  # inner bounds (inside the border) of the scene
  @inner_bounds = undefined
  # canvas for drawing, and the drawing context
  @canvas = undefined
  @ctx = undefined
  return

Stimulus::init = (canvas) ->
  # create the container scene
  @scene = new Scene
  # add outer walls/border
  @scene.addObject 'left_border', new Wall(0, 0, @wall_width, @height + 2 * @wall_width)
  @scene.addObject 'right_border', new Wall(@width + @wall_width, 0, @wall_width, @height + 2 * @wall_width)
  @scene.addObject 'top_border', new Wall(0, 0, @width + @wall_width, @wall_width)
  @scene.addObject 'bottom_border', new Wall(0, @height + @wall_width, @width + 2 * @wall_width, @wall_width)


  # compute the inner dimensions of the scene
  @inner_bounds =
    'xmin': @scene.objects.left_border.getBounds()[1]
    'ymin': @scene.objects.top_border.getBounds()[3]
    'xmax': @scene.objects.right_border.getBounds()[0]
    'ymax': @scene.objects.bottom_border.getBounds()[2]

  # the canvas and context for drawing
  @canvas = canvas
  @canvas.attr 'width', @width + @wall_width * 2
  @canvas.attr 'height', @height + @wall_width * 2
  @ctx = @canvas[0].getContext('2d')
  return

###*
# Destroy the stimulus. This includes completely removing everything
# from the scene, and removing width and height attributes from the
# canvas.
###

Stimulus::destroy = ->
  @clearLayout()
  while @scene.object_names.length > 0
    @scene.removeObject @scene.object_names[0]
  @scene = undefined
  @inner_bounds = undefined
  @canvas.removeAttr 'width'
  @canvas.removeAttr 'height'
  @canvas = undefined
  @ctx = undefined
  return

###*
# Loads the particular scene layout. This includes setting the ball
# trajector, and creating the ball. Any other scene loading must be
# handled by a subclass method.
#
# @param {string} layout_name - the name of the layout to load, which
# should be a key in the this.layouts object.
# @param {string} animation - the type of animation to play; can be
# one of "stimulus" (only the stimulus presentation), "feedback"
# (only the feedback, after the stimulus has been presented), or
# "full" (both the stimulus presentation and the feedback).
###

Stimulus::loadLayout = (layout_name, animation) ->
  # console.log 'loadLayout', layout_name, animation
  layout = undefined
  x = undefined
  y = undefined
  check 'layout_name', layout_name
  check 'animation', animation
  # read in the specified layout
  layout = check('layout \'' + layout_name + '\'', @layouts[layout_name])
  @current_layout = [
    layout_name
    animation
  ]
  @ball_path_extra = check('end path', layout.EndPath)
  # determine which ball path to animate
  if animation == 'stimulus'
    @ball_trajectory = @ball_path
  else if animation == 'feedback'
    @ball_trajectory = @ball_path_extra
    # this.ball_trajectory = [];
  else if animation == 'full'
    # we don't get here -F
    # this.ball_trajectory = this.ball_path.concat(this.ball_path_extra);
    @ball_trajectory = @ball_path
  else
    throw new Error('invalid animation type: ' + animation)
  # ball coordinates
  x = @ball_trajectory[0][0] + @inner_bounds.xmin
  y = @ball_trajectory[0][1] + @inner_bounds.ymin
  # add the trajectory
  if @scene.objects.trajectory != undefined
    @scene.removeObject 'trajectory'
  if @scene.objects.trajectory_init != undefined
    @scene.removeObject 'trajectory_init'
  if @draw_trajectory
    @scene.addObject 'trajectory', new Trajectory(@ball_trajectory, @inner_bounds.xmin, @inner_bounds.ymin, 0)
    if animation == 'feedback'
      @scene.addObject('trajectory_init',
        new Trajectory(@ball_path, @inner_bounds.xmin, @inner_bounds.ymin,
                       @ball_path.length - 1, @ball_path.length + @ball_path_extra.length - 1))
  # add the ball
  @scene.removeObject 'ball'
  @scene.addObject 'ball', new Ball(x, y, @ball_radius)
  return

###*
# Unloads the layout that was loaded in by this.loadLayout. This will
# also stop the animation, if it is currently running.
###

Stimulus::clearLayout = ->
  # stop the animation, if it is running
  @clearAnimation()
  @clearCountdown()
  @hideOccluder()
  @animator.t = undefined
  # unset various variables that were set when we loaded the layout
  @current_layout = undefined
  @ball_path_extra = undefined
  @ball_trajectory = undefined
  # remove objects from the scene that we had added
  @scene.removeObject 'ball'
  @scene.removeObject 'trajectory'
  @scene.removeObject 'trajectory_init'
  # stop drawing
  @stopDrawing()
  return

###*
# Moves the ball to the appropriate position for a given frame.
# @param [int] frame - the index of the frame to display
###

Stimulus::showFrame = (frame) ->
  @scene.objects.ball.x = @ball_trajectory[frame][0] + @inner_bounds.xmin
  @scene.objects.ball.y = @ball_trajectory[frame][1] + @inner_bounds.ymin
  if @scene.objects.trajectory != undefined
    @scene.objects.trajectory.index = frame
  return

###*
# Sets up the next frame of the stimulus' animation, based on the
# value of this.animator.t (currently, a frame just constitutes the
# position of the ball). If there are no more frames left, then an
# optional callback is excuted (specified when this.animate() was
# called), and the animation inteval is cleared.
###

Stimulus::showNextFrame = ->
  if @animator.t < @ball_trajectory.length
    @showFrame @animator.t
    @animator.t = @animator.t + 1
  else
    @stopAnimation()
    if @animator.onFinish
      f = @animator.onFinish
      @animator.onFinish = undefined
      f()
  return

###*
# Starts the stimulus' ball animation. The animation will be played
# back at the rate specified in this.metadata.fps.
#
# @param {function} [callback] - an optional callback to be executed
# when the animation is complete. This will NOT be called if the
# animation is stopped prematurely.
###

Stimulus::animate = (callback) ->
  # clear the animation if it already exists
  @clearAnimation()
  # store the relevant variables
  @animator.onFinish = callback
  @animator.t = 0
  # begin the animation
  that = this
  @animator.timer = window.setInterval((->
    that.showNextFrame()
    return
  ), 1000 / @metadata.fps)
  return

###*
# Stops the animation, if it is currently playing, but does not reset
# it (for that, use clearAnimation()).
###

Stimulus::stopAnimation = ->
  if @animator.timer
    window.clearInterval @animator.timer
    @animator.timer = undefined
  return

###*
# Completely clears the animation. This means stopping it, if it is
# currently playing, and unsetting all the relevant variables.
###

Stimulus::clearAnimation = ->
  @stopAnimation()
  @animator.t = undefined
  @animator.timer = undefined
  @animator.onFinish = undefined
  return

###*
# Add an occluder to the scene.
###

Stimulus::showOccluder = ->
  @scene.addObject 'occluder', new Occluder(@wall_left + @inner_bounds.xmin + @wall_width, @inner_bounds.xmax, @inner_bounds.ymin, @inner_bounds.ymax)
  if @scene.objects.trajectory != undefined
    @scene.reorderObject 'trajectory'
  return

###*
# Remove the occluder from the scene.
###

Stimulus::hideOccluder = ->
  if @scene.objects.occluder != undefined
    @scene.removeObject 'occluder'
    @scene.reorderObject 'ball'
  return

###*
# Update the countdown timer. This computes the current time, figures
# what percentage of the total time has passed, and updates the
# countdown object.
###

Stimulus::updateCountdown = ->
  f = undefined
  pct = undefined
  pct = 100 * (Date.now() - (@countdown.start_time)) / @countdown.length
  if pct < 100
    @scene.objects.countdown.percentFilled = 100 - pct
  else
    @scene.objects.countdown.percentFilled = 0
    @stopCountdown()
    if @countdown.onFinish
      f = @countdown.onFinish
      @countdown.onFinish = undefined
      f()
  return

###*
# Begin the countdown timer. This will stop and reset the timer if it
# has already been started before.
#
# @param {int} length - the length of time in milliseconds that the
# countdown should run for
# @param {function} [callback] - a function to call when the timer
# has finished counting down. This will NOT be called if the timer is
# stopped prematurely.
###

Stimulus::startCountdown = (length, callback) ->
  x = undefined
  y = undefined
  that = undefined
  # remove the countdown if it already exists
  @clearCountdown()
  # compute position for the countdown timer
  x = @inner_bounds.xmin + 30
  y = @inner_bounds.ymin + 30
  @scene.addObject 'countdown', new Timer(x, y, 15)
  # record the relevant variables
  @countdown.start_time = Date.now()
  @countdown.length = check('countdown length', length)
  @countdown.onFinish = callback
  # start animating the timer
  that = this
  @countdown.timer = window.setInterval((->
    that.updateCountdown()
    return
  ), 10)
  return

###*
# Stops the countdown timer if it is running, but does not reset it
# (for that, use clearCountdown()).
###

Stimulus::stopCountdown = ->
  if @countdown.timer
    window.clearInterval @countdown.timer
    @countdown.timer = undefined
  return

###*
# Completely clears the countdown timer if it is running, which
# includes unsetting the relevant variables.
###

Stimulus::clearCountdown = ->
  @stopCountdown()
  if @scene.objects.countdown != undefined
    @scene.removeObject 'countdown'
  @countdown.timer = undefined
  @countdown.start_time = undefined
  @countdown.length = undefined
  @countdown.onFinish = undefined
  return

###*
# Begins the main drawing loop. This calls a function (at a rate
# specified by this.metadata.fps) which redraws the canvas each
# time. The canvas should ONLY ever be redrawn using this drawing
# loop. If you don't need an entire drawing loop, then you can use
# this.drawOnce() to redraw the canvas exactly once.
###

Stimulus::startDrawing = ->
  if @drawer.timer
    throw new Error('drawing has already been started')
  @drawOnce()
  @drawer.timer = window.setInterval (=> @drawOnce()), 1000 / @metadata.fps

###*
# Stops the main drawing loop. After stopping the drawing timer, it
# will draw the scene again once to make sure that the most recent
# changes to the scene are displayed.
###

Stimulus::stopDrawing = ->
  @drawOnce()
  if @drawer.timer
    window.clearInterval @drawer.timer
    @drawer.timer = undefined

###*
# Draws the scene exactly once. In general, this function should not
# be used; you should start the drawing loop with this.startDrawing()
# instead. You should only use this function when you really just
# need to draw the scene once; any type of animation should be shown
# using the loop.
###

Stimulus::drawOnce = ->
  @scene.draw @ctx
  return
