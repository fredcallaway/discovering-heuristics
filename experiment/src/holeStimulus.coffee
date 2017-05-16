###jslint browser: true###

###global check, _, $, Stimulus, Ball, Wall###

###*
# A stimulus with a wall that has a hole in it.
#
# @constructor
# @extends Stimulus
# @param {Object} config - the configuration for the stimulus. This
# should include information about things like the width of the
# walls, the ball radius, etc. See jsonstruct.txt for details.
###

HoleStimulus = (config) ->
  # call the parent constructor
  @base = Stimulus
  @base config
  # add more stuff to the metadata
  @metadata.goes_in = undefined
  @color_cue = check('color_cue', config.color_cue)
  @wall_cue = check('wall_cue', config.wall_cue)
  @good_cue = check('good_cue', config.good_cue)
  @cue_colors = check('cue_colors', config.cue_colors)
  @cue_present = check('cue_present', config.cue_present)
  
  return

HoleStimulus.prototype = new Stimulus

###*
# Loads the particular wall layout. This includes specifying where
# the hole is in the wall, and what animation should be played.
#
# @param {string} layout_name - the name of the layout to load, which
# should be a key in the this.layouts object.
# @param {string} animation - the type of animation to play; can be
# one of "stimulus" (only the stimulus presentation), "feedback"
# (only the feedback, after the stimulus has been presented), or
# "full" (both the stimulus presentation and the feedback).
###

HoleStimulus::loadLayout = (layout_name, animation) ->
  # call the parent class version of this method
  Stimulus::loadLayout.call this, layout_name, animation

  layout = @layouts[@current_layout[0]]
  # @bounce_limits = check('bounce limits', layout.BounceLimits)
  @bounce_limits = layout.BounceLimits
  @false_bounce_limits = layout.FalseBounceLimits
  @center_bounce_limits = layout.CenterBounceLimits
  @false_center_bounce_limits = layout.FalseCenterBounceLimits

  goes_in = check('goes in', layout.GoesIn)
  @metadata.goes_in = goes_in

  if @cue_present
    cue_says_hit = @good_cue == goes_in
    color_of_cue = if cue_says_hit then @cue_colors.hit else @cue_colors.miss
  else
    color_of_cue = @cue_colors.neutral
  

  wall_color = undefined
  @scene.objects.ball.color = 'black'

  switch @color_cue
    when 'ball'
      @scene.objects.ball.color = color_of_cue
    
    when 'wall'
      wall_color = color_of_cue

    when 'background'
      background_color = color_of_cue
      @scene.removeObject 'background'
      @scene.addObject 'background', background(@inner_bounds, background_color)
      @scene.reorderObject 'background', 0

    else
      if @color_cue
        throw new Error "bad color_cue #{@color_cue}"

  # topmost part of the wall
  wall_top = @inner_bounds.ymin
  # where the hole begins
  hole_top = check('hole top', layout.HoleYs[0]) + @inner_bounds.ymin
  # the height of the first part of the wall (before the hole)
  wall_top_height = hole_top - wall_top
  # where the hole ends
  hole_bottom = check('hole bottom', layout.HoleYs[1]) + @inner_bounds.ymin
  # the height of the second part of the wall (after the hole)
  wall_bottom_height = @inner_bounds.ymax - hole_bottom
  # the left edge of the wall
  wall_left = check('hole right', layout.HoleX) - (@wall_width) + @inner_bounds.xmin
  # add the wall with the hole in it
  @scene.removeObject 'wall_top'
  @scene.removeObject 'wall_bottom'
  @scene.addObject 'wall_top', new Wall(wall_left, wall_top, @wall_width,
                                        wall_top_height, wall_color)
  @scene.addObject 'wall_bottom', new Wall(wall_left, hole_bottom, @wall_width,
                                           wall_bottom_height, wall_color)
 
  if @wall_cue
    # Add the bounce limit marks
    @scene.removeObject 'mark1'
    @scene.removeObject 'mark2'

    adjust = (x, y) =>
      if y > 0
        y += @inner_bounds.ymin  # account for wall width
      if x > 0
        x += @inner_bounds.xmin
      return [x, y]
    
    mark = (x, y, color='#ff0000') =>
      [x, y] = adjust x, y
      return new Wall(x, y, @wall_width, @wall_width, color)

    long_mark = (one, two, color='#ff0000') =>
      [x1, y1] = adjust one...
      [x2, y2] = adjust two...
      x = Math.min(x1, x2)
      y = Math.min(y1, y2)
      if x1 == x2
        width = @wall_width
        height = Math.abs(y2 - y1)
      else
        width = Math.abs(x2 - x1)
        height = @wall_width
      return new Wall(x, y, width, height, color)

    if @bounce_limits or @center_bounce_limits
      limits = if @good_cue then @bounce_limits else @false_bounce_limits
      switch @wall_cue
        when 'bounds'
          @scene.addObject 'mark1', mark(limits[0]...)
          @scene.addObject 'mark2', mark(limits[1]...)
        when 'full'
          @scene.addObject 'mark1', long_mark(limits...)
        when 'center'
          limits = if @good_cue then @center_bounce_limits else @false_center_bounce_limits
          @scene.addObject 'mark1', long_mark(limits...)

  return

###*
# Unloads the layout that was loaded in by this.loadLayout. This will
# also stop the animation, if it is currently running.
###

HoleStimulus::clearLayout = ->
  Stimulus::clearLayout.call this
  # unset various variables that were set when we loaded the layout
  @metadata.goes_in = undefined
  # remove objects from the scene that we had added
  @scene.removeObject 'wall_top'
  @scene.removeObject 'wall_bottom'
  @scene.removeObject 'mark1'
  @scene.removeObject 'mark2'
  @drawOnce()
  return
