from __future__ import division, print_function

import sys, os

from physicsTable import *
from physicsTable.constants import *
import cPickle as pickle
import json
import math
import random
import numpy as np

MIN_BOUNCE_SIZE = 40

def logged(func):
    def wrapped(*args, **kwargs):
        result = func(*args, **kwargs)
        print(func.__name__, args, kwargs, result)
        return result
    return wrapped

def check_within_walls(limits, x_max, y_max):
    print('limits:', limits)
    (x1, y1), (x2, y2) = limits
    good = all((0 <= x1 <= x_max,
                0 <= y1 <= y_max,
                0 <= x2 <= x_max,
                0 <= y2 <= y_max,
                # y2 - y1 > MIN_BOUNCE_SIZE
    ))
    if not good:
        # Signal failure with an exception. This leads to the trial
        # being rejected and resampled in makeTrial()
        raise RuntimeError('Not within walls')

class HoleTrial(SimpleTrial):

    def __init__(self, name, dims, closed_ends=[LEFT, RIGHT, BOTTOM, TOP],
                 background_cl=WHITE, def_ball_vel=600, def_ball_rad=20,
                 def_ball_cl=BLUE, def_pad_len=100, def_wall_cl=BLACK,
                 def_occ_cl=GREY, def_pad_cl=BLACK, wallwid=10):
        self.name = name
        self.dims = dims
        self.ce = closed_ends
        self.bkc = background_cl
        self.dbr = def_ball_rad
        self.dbc = def_ball_cl
        self.dpl = def_pad_len
        self.dwc = def_wall_cl
        self.doc = def_occ_cl
        self.dpc = def_pad_cl
        self.dbv = def_ball_vel

        self.ball = None
        self.normwalls = []
        self.abnormwalls = []
        self.occs = []
        self.goals = []
        self.paddle = None
        self.holepos = 0
        self.holeends = (0,0)
        self.wallwid = wallwid

        self.ttot = None

    def addHole(self, xpos, endpts):
        self.holepos = xpos
        self.holeends = endpts

    def makeTable(self, soffset = None):
        tb = super(HoleTrial, self).makeTable(soffset)
        tb.addWall( (self.holepos - self.wallwid, 0), (self.holepos, self.holeends[0]), BLACK, 1.)
        tb.addWall( (self.holepos - self.wallwid, self.holeends[1]), (self.holepos, self.dims[1]), BLACK, 1.)
        return tb

    # To check for whether the ball hits or not (and how long to sample for)
    def makeGoalTable(self, soffset = None):
        tb = super(HoleTrial, self).makeTable(soffset)
        tb.addGoal( (self.holepos - self.wallwid, 0), (self.holepos, self.holeends[0]), REDGOAL, BLACK)
        tb.addGoal( (self.holepos - self.wallwid, self.holeends[1]), (self.holepos, self.dims[1]),REDGOAL, BLACK)
        tb.addGoal( (self.holepos - self.wallwid, self.holeends[0]), (self.holepos, self.holeends[1]),GREENGOAL, GREEN)
        return tb


class Hole(object):
    def __init__(self, name, xpos, ep1, ep2, ttot):
        self.name = name
        self.xpos = xpos
        self.ep1 = ep1
        self.ep2 = ep2
        self.ttot = ttot
        self.path = None  # these are set by the MultiHole
        self.bounceLimits = None


class MultiHole(object):
    """Represents one "trial" as created by makeTrial().

    """
    def __init__(self, name, dims, tobs, hz, def_ball_vel=600, def_ball_rad=20,
                 wallwid=10, color_cue=1, wall_mark_cue=1):
    
        self.ht = HoleTrial(name, dims, def_ball_vel=def_ball_vel, def_ball_rad=def_ball_rad, wallwid=wallwid)
        self.holes = []
        self.tobs = tobs
        self.hz = hz
        self.dbvel = def_ball_vel
        self.ctrltr = False
        self.color_cue = color_cue
        self.wall_mark_cue = wall_mark_cue

    def setCtrl(self, ctr=True):
        self.ctrltr = ctr

    def addBall(self, initpos, initvel, rad = None, color = None, elast = 1.):
        self.ht.addBall(initpos,initvel,rad,color,elast)
        self.ht.normalizeVel()

    def addHole(self, name, xpos, ep1, ep2, ttot):
        h = Hole(name, xpos, ep1, ep2, ttot)
        self.loadHole(h)
        self.setPath(h)
        if self.wall_mark_cue:
            self.setBounceLimits(h)
        self.holes.append(h)
        return h

    def loadHole(self, h):
        self.ht.holepos = h.xpos
        self.ht.holeends = (h.ep1,h.ep2)
        self.ht.ttot = h.ttot

    def save(self, flnm):
        pickle.dump(self, open(flnm,'wb'))

    def jsonify(self, pretty = False):
        if len(self.holes) == 0: raise Exception('No holes added yet')
        jdict = {'Name' : self.ht.name,
                 'Dims' : self.ht.dims,
                 'BallRad' : self.ht.ball[2],
                 'FPS' : self.hz,
                 'WallWid' : self.ht.wallwid,
                 'ControlTrial': self.ctrltr,
                 'BallColor': True,
                 'WallMarks': False,

        } # FIXME

        layouts = dict()  # one layout is one unique hole placement

        # Iterate through holes
        for h in self.holes:
            #hdic, spath, bnc, htm = self.getPath(h)
            hdic, spath, bnc, htm = h.path
            if 'ObsPath' not in jdict:
                jdict['ObsPath'] = spath
                jdict['Bounces'] = bnc
                jdict['Distance'] = (htm * self.dbvel)
            hdic['HoleYs'] = (h.ep1, h.ep2)
            hdic['HoleX'] = h.xpos
            # hdic['BounceLimits'] = h.bounceLimits
            # hdic['FalseBounceLimits'] = h.falseBounceLimits
            # hdic['CenterBounceLimits'] = h.centerBounceLimits
            # hdic['FalseCenterBounceLimits'] = h.falseCenterBounceLimits
            layouts[h.name] = hdic

        # Add catch path
        cadict = {'EndPath': self.getCatchPath()}
        layouts['Catch'] = cadict

        jdict['Layouts'] = layouts

        if pretty: jfl = json.dumps(jdict, separators=(',',': '), sort_keys=True, indent = 2)
        else: jfl = json.dumps(jdict)
        return jfl

    def getPath(self, hole=None):
        if hole is not None:
            self.loadHole(hole)
        timestep = 1. / self.hz

        # First check whether it is a hit or miss
        tb = self.ht.makeGoalTable()
        hit = tb.simulate() == GREENGOAL
        bounces = tb.balls.bounces
        hittm = tb.tm

        if self.color_cue > 0:
            # TODO probabilistic cue
            ball_color = 1 if hit else -1
        elif self.color_cue < 0:  # incorrect cue1
            ball_color = -1 if hit else 1
        else:
            ball_color = 0

        # Next get the path
        tb = self.ht.makeTable()
        spath = tb.simulate(maxtime = self.tobs, timeres = timestep, return_path = True)[1]
        epath = tb.simulate(maxtime = self.ht.ttot, timeres = timestep, return_path = True)[1]

        hdic = {'GoesIn' : hit, 'EndPath' : epath, 'BallColor': ball_color}
        return [hdic, spath, bounces, hittm]

    def setPath(self, hole=None):
        hole.path = self.getPath(hole)

    def getCatchPath(self):
        timestep = 1. / self.hz
        tb = self.ht.makeGoalTable()
        #spath = tb.simulate(maxtime = self.tobs, timeres = timestep, return_path=True)[1]
        epath = tb.simulate(timeres = timestep, return_path=True)[1]
        return epath

    def getCenterBounceLimits(self, hole, falsify=False):
        n_bounces = hole.path[2]
        if not n_bounces:
            return False


        x_max, y_max = self.ht.dims  # walls
        hit = hole.path[0]['GoesIn']
        if falsify:
            hit = not hit
        vx, vy = self.ht.ball[1]
        size = 55  # half the length of the mark

        path = hole.path[0]['EndPath']
        def get_true_bounce_pos():
            for i, (x, y) in enumerate(path):
                x1, y1 = path[i + 1]
                if vx > 0 and x_max - x < 20 and x1 < x:
                    return (x_max, y)
                elif vy > 0 and y_max - y < 20 and y1 < y:
                    return (x, y_max)
                elif vy < 0 and y < 20 and y1 > y:
                    return (x, 0)

        def expand(x, y, offset):
            if x == x_max:
                if y < y_max / 2:
                    y += offset
                else:
                    y -= offset
                return [[x, y - size], [x, y + size]]
            else:
                if x < x_max / 2:
                    x += offset
                else:
                    x -= offset
                return [[x - size, y], [x + size, y]]


        # x, y = get_true_bounce_pos()
        x0, y0 = self.ht.ball[0]  # initial position of ball
        
        x_hole, y_hole_top, y_hole_bottom = hole.xpos, hole.ep1, hole.ep2
        y1 = int((hole.ep1 + hole.ep2) / 2)
        x, y = self.get_bounce_pos(hole, x0, y0, hole.xpos, y1)
        # offset = 0 if hit else size * 2
        offset = 0
        limits = expand(x, y, offset)
        assert limits
        return limits

    def get_bounce_pos(self, hole, x0, y0, x1, y1):
        # finds the position the ball would bounce if it starts at (x0, y0)
        # and ends at (x1, y1), assuming it bounces off the same wall as the 
        # real ball will actually bounce on (based on vx and vy).

        vx, vy = self.ht.ball[1]  # velocity
        ball_radius = self.ht.ball[2]
        x_hole, y_hole_top, y_hole_bottom = hole.xpos, hole.ep1, hole.ep2
        x_max, y_max = self.ht.dims  # walls
        n_bounce = self.getPath(hole)[2]
        if n_bounce == 0:
            return False

        if n_bounce == 1:
            if vx < 0 and vy < 0:  # bounce off top wall
                y0 -= ball_radius  # top of ball
                x = (x0 * y1 + x1 * y0) / (y0 + y1)
                return (x, 0)                  
            elif vx < 0 and vy > 0:  # bottom wall
                y0 += ball_radius  # bottom of ball
                y0 = y_max - y0  # flip y axis
                y1 = y_max - y1
                x = (x0 * y1 + x1 * y0) / (y0 + y1)
                return (x, y_max)
            elif vx > 0:  # side wall
                # Note: no need to flip y because the reflection
                # is canceled out in the math.
                x0 += ball_radius
                x0 = x_max - x0
                x1 = x_max - x1
                y = (x0 * y1 + x1 * y0) / (x0 + x1)
                return (x_max, y)
        elif n_bounce == 2:
            if vx > 0 and vy < 0:
                #assert 0
                x0 += ball_radius
                y0 -= ball_radius
                x0 = x_max - x0
                x1 = x_max - x1
                y = (x1 * y0 - x0 * y1) / (x0 + x1)
                return (x_max, y)
            elif vx > 0 and vy > 0:
                x0 += ball_radius
                y0 += ball_radius
                x0 = x_max - x0
                x1 = x_max - x1
                y0 = y_max - y0
                y1 = y_max - y1
                y = (x1 * y0 - x0 * y1) / (x0 + x1)
                y = y_max - y  # flip back
                #import IPython; IPython.embed()
                return (x_max, y)
            else:
                raise NotImplementedError('Double-bounces only allowed on back wall')
        else: 
            raise Exception('Only 0-2 bounces allowed')

        
    def getBounceLimits(self, hole):
        x0, y0 = self.ht.ball[0]  # initial position of ball
        vx, vy = self.ht.ball[1]  # velocity
        ball_radius = self.ht.ball[2]
        x_hole, y_hole_top, y_hole_bottom = hole.xpos, hole.ep1, hole.ep2
        x_max, y_max = self.ht.dims  # walls
        n_bounce = self.getPath(hole)[2]
        if n_bounce == 0:
            return False

  

        def expand(limits):
            # draw the marks such that hitting the marks are "out" like so:
            # ---------.-----.---------  ( bounce positions )
            # --------**-----**--------  ( markers )

            (x1, y1), (x2, y2) = limits
            ww = self.ht.wallwid
            if x1 == x2:  # side wall
                    return (x1, y1 - ww), (x2, y2)
            else:
                return (x1 - ww, y1), (x2, y2)


        bounce_to_top_of_hole = self.get_bounce_pos(hole, x0, y0, x_hole, y_hole_top)
        bounce_to_bottom_of_hole = self.get_bounce_pos(hole, x0, y0, x_hole, y_hole_bottom)
        limits = sorted([bounce_to_top_of_hole, bounce_to_bottom_of_hole])
        check_within_walls(limits, x_max, y_max)

        limits = expand(limits)
        assert limits
        return limits

    def getBadLimits(self, hole):
        x_max, y_max = self.ht.dims  # walls
        if hole.bounceLimits is False:
            return False

        y_bounce = max(hole.path[0]['EndPath'])[1]
        error = 50
        (x1, y1), (x2, y2) = hole.bounceLimits
        hit = hole.path[0]['GoesIn']
        dist_to_top, dist_to_bottom = abs(y_bounce - y1), abs(y_bounce - y2)
        
        def limits():        
            if hit:
                # move the marks so that the ball hits outside by distance `error`
                if dist_to_top < dist_to_bottom:
                    return (x1, y1 + dist_to_top + error), (x2, y2 + dist_to_top + error)
                else:
                    return (x1, y1 - dist_to_bottom - error), (x2, y2 - dist_to_bottom - error)
            else:
                # move the marks so that the ball hits inside, `error` from edge
                if dist_to_top < dist_to_bottom:
                    return (x1, y1 - dist_to_top - error), (x2, y2 - dist_to_top - error)
                else:
                    return (x1, y1 + dist_to_bottom + error), (x2, y2 + dist_to_bottom + error)

        lims = limits()
        check_within_walls(lims, x_max, y_max)
        return lims


    def setBounceLimits(self, hole):
        # hole.bounceLimits = self.getBounceLimits(hole)
        # hole.falseBounceLimits = self.getBadLimits(hole)
        hole.centerBounceLimits = self.getCenterBounceLimits(hole)
        hole.falseCenterBounceLimits = self.getCenterBounceLimits(hole, falsify=True)


    def demonstrate(self):
        print('Observed')
        tb = self.ht.makeTable()
        tb.demonstrate(maxtime = self.tobs)
        for h in self.holes:
            self.loadHole(h)
            print(h.name)
            tb = self.ht.makeTable()
            tb.demonstrate(maxtime = self.ht.ttot)

    def getHoleByName(self, name):
        for h in self.holes:
            if h.name == name: return h
        return None


# Testing
if __name__ == '__main__':
    import pygame as pg

    mh = MultiHole('tst', (900, 650), .5, 40)
    mh.addBall((700, 500), (-1, 1))
    mh.addHole('h1', 100, 350, 550, 2.5)
    mh.addHole('h2', 200, 100, 300, 1.5)
    mh.addHole('c', 300, 0, 650, 0.5)

    # pg.init()
    # sc = pg.display.set_mode((900,650))
    # mh.demonstrate()

    ofl = open('tmp.json', 'w')
    ofl.write( mh.jsonify(True) )
    ofl.close()
