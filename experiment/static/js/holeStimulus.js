// Generated by CoffeeScript 1.12.3

/*jslint browser: true */

/*global check, _, $, Stimulus, Ball, Wall */

/**
 * A stimulus with a wall that has a hole in it.
 *
 * @constructor
 * @extends Stimulus
 * @param {Object} config - the configuration for the stimulus. This
 * should include information about things like the width of the
 * walls, the ball radius, etc. See jsonstruct.txt for details.
 */
var HoleStimulus;

HoleStimulus = function(config) {
  this.base = Stimulus;
  this.base(config);
  this.metadata.goes_in = void 0;
  this.color_cue = check('color_cue', config.color_cue);
  this.wall_cue = check('wall_cue', config.wall_cue);
  this.good_cue = check('good_cue', config.good_cue);
  this.cue_colors = check('cue_colors', config.cue_colors);
  this.cue_present = check('cue_present', config.cue_present);
};

HoleStimulus.prototype = new Stimulus;


/**
 * Loads the particular wall layout. This includes specifying where
 * the hole is in the wall, and what animation should be played.
 *
 * @param {string} layout_name - the name of the layout to load, which
 * should be a key in the this.layouts object.
 * @param {string} animation - the type of animation to play; can be
 * one of "stimulus" (only the stimulus presentation), "feedback"
 * (only the feedback, after the stimulus has been presented), or
 * "full" (both the stimulus presentation and the feedback).
 */

HoleStimulus.prototype.loadLayout = function(layout_name, animation) {
  var adjust, background_color, color_of_cue, cue_says_hit, goes_in, hole_bottom, hole_top, layout, limits, long_mark, mark, wall_bottom_height, wall_color, wall_left, wall_top, wall_top_height;
  Stimulus.prototype.loadLayout.call(this, layout_name, animation);
  layout = this.layouts[this.current_layout[0]];
  this.bounce_limits = layout.BounceLimits;
  this.false_bounce_limits = layout.FalseBounceLimits;
  this.center_bounce_limits = layout.CenterBounceLimits;
  this.false_center_bounce_limits = layout.FalseCenterBounceLimits;
  goes_in = check('goes in', layout.GoesIn);
  this.metadata.goes_in = goes_in;
  if (this.cue_present) {
    cue_says_hit = this.good_cue === goes_in;
    color_of_cue = cue_says_hit ? this.cue_colors.hit : this.cue_colors.miss;
  } else {
    color_of_cue = this.cue_colors.neutral;
  }
  wall_color = void 0;
  this.scene.objects.ball.color = 'black';
  switch (this.color_cue) {
    case 'ball':
      this.scene.objects.ball.color = color_of_cue;
      break;
    case 'wall':
      wall_color = color_of_cue;
      break;
    case 'background':
      background_color = color_of_cue;
      this.scene.removeObject('background');
      this.scene.addObject('background', background(this.inner_bounds, background_color));
      this.scene.reorderObject('background', 0);
      break;
    default:
      if (this.color_cue) {
        throw new Error("bad color_cue " + this.color_cue);
      }
  }
  wall_top = this.inner_bounds.ymin;
  hole_top = check('hole top', layout.HoleYs[0]) + this.inner_bounds.ymin;
  wall_top_height = hole_top - wall_top;
  hole_bottom = check('hole bottom', layout.HoleYs[1]) + this.inner_bounds.ymin;
  wall_bottom_height = this.inner_bounds.ymax - hole_bottom;
  wall_left = check('hole right', layout.HoleX) - this.wall_width + this.inner_bounds.xmin;
  this.scene.removeObject('wall_top');
  this.scene.removeObject('wall_bottom');
  this.scene.addObject('wall_top', new Wall(wall_left, wall_top, this.wall_width, wall_top_height, wall_color));
  this.scene.addObject('wall_bottom', new Wall(wall_left, hole_bottom, this.wall_width, wall_bottom_height, wall_color));
  if (this.wall_cue) {
    this.scene.removeObject('mark1');
    this.scene.removeObject('mark2');
    adjust = (function(_this) {
      return function(x, y) {
        if (y > 0) {
          y += _this.inner_bounds.ymin;
        }
        if (x > 0) {
          x += _this.inner_bounds.xmin;
        }
        return [x, y];
      };
    })(this);
    mark = (function(_this) {
      return function(x, y, color) {
        var ref;
        if (color == null) {
          color = '#ff0000';
        }
        ref = adjust(x, y), x = ref[0], y = ref[1];
        return new Wall(x, y, _this.wall_width, _this.wall_width, color);
      };
    })(this);
    long_mark = (function(_this) {
      return function(one, two, color) {
        var height, ref, ref1, width, x, x1, x2, y, y1, y2;
        if (color == null) {
          color = '#ff0000';
        }
        ref = adjust.apply(null, one), x1 = ref[0], y1 = ref[1];
        ref1 = adjust.apply(null, two), x2 = ref1[0], y2 = ref1[1];
        x = Math.min(x1, x2);
        y = Math.min(y1, y2);
        if (x1 === x2) {
          width = _this.wall_width;
          height = Math.abs(y2 - y1);
        } else {
          width = Math.abs(x2 - x1);
          height = _this.wall_width;
        }
        return new Wall(x, y, width, height, color);
      };
    })(this);
    if (this.bounce_limits || this.center_bounce_limits) {
      limits = this.good_cue ? this.bounce_limits : this.false_bounce_limits;
      switch (this.wall_cue) {
        case 'bounds':
          this.scene.addObject('mark1', mark.apply(null, limits[0]));
          this.scene.addObject('mark2', mark.apply(null, limits[1]));
          break;
        case 'full':
          this.scene.addObject('mark1', long_mark.apply(null, limits));
          break;
        case 'center':
          limits = this.good_cue ? this.center_bounce_limits : this.false_center_bounce_limits;
          this.scene.addObject('mark1', long_mark.apply(null, limits));
      }
    }
  }
};


/**
 * Unloads the layout that was loaded in by this.loadLayout. This will
 * also stop the animation, if it is currently running.
 */

HoleStimulus.prototype.clearLayout = function() {
  Stimulus.prototype.clearLayout.call(this);
  this.metadata.goes_in = void 0;
  this.scene.removeObject('wall_top');
  this.scene.removeObject('wall_bottom');
  this.scene.removeObject('mark1');
  this.scene.removeObject('mark2');
  this.drawOnce();
};