#!/usr/bin/env python2


from __future__ import division, print_function

import re
import random
import json
import numpy as np
import os
import sys
import util
import physicsTable as pt
import logging
import itertools
from collections import namedtuple
import yaml

logging.basicConfig(level='INFO')

sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'lib'))
import exp1_holeTrial as ht


def make_miss_hole(y_ball, y_max, holesize):
    y_min = 10
    def hole_above():
        hole_bottom = y_ball - (holesize // 2)
        hole_top = hole_bottom - holesize
        return hole_top, hole_bottom

    def hole_below():
        hole_top = y_ball + (holesize // 2)
        hole_bottom = hole_top + holesize
        return hole_top, hole_bottom

    options = [hole_above, hole_below]
    random.shuffle(options)
    for method in options:
        top, bottom = method()
        if top > y_min and bottom < y_max:
            return top, bottom


def dict_product(d):
    """All possible combinations of values in lists in `d`"""
    return [dict(zip(d.keys(), v))
            for v in list(itertools.product(*d.values()))]


# Randomly generates a trial within constraints above & holding # bounces
# (note: i is just for naming index)
def _make_trial(config, occtimes=None, nbounces=0, i=0):
    if occtimes is None:
        occtimes = config['occtimes']

    # Make sure ball doesn't end too close to edge for hole
    yrange = (int(config['holesize'] / 2.), int(config['dims'][1] - config['holesize'] / 2.))

    # Rough maximum hole x-pos to avoid needless computation
    xmin = config['wallwid'] + 40
    xmax = config['dims'][0] - int(config['ballvel'] * config['showtime'] * 0.75)

    # First determine the location and velocity of the ball at the
    # end of the trajectory
    xend = random.randint(xmin, xmax)
    yend = random.randint(yrange[0], yrange[1])
    if make_miss_hole(yend, config['dims'][1], config['holesize']) is None:
        return None
    angrange = np.radians(config['angrange'])
    theta = random.uniform(*angrange)
    bvel = (
        config['ballvel'] * np.cos(theta),
        config['ballvel'] * np.sin(theta))
    logging.debug('x={}, y={}, vel={}'.format(xend, yend, bvel))

    # The end point we have chosen will correspond to the maximum time. Compute
    # the points that correspond to the other times and make sure there are no
    # bounces in between.
    testtab = pt.SimpleTable(config['dims'], def_ball_rad=config['ballsize'])
    testtab.addBall((xend, yend), bvel)
    times = sorted(occtimes, reverse=True)
    for j in range(1, len(times)):
        testtab.step(times[j - 1] - times[j])
        if testtab.balls.bounces != 0:
            logging.debug('Bounced before going through time {}'.format(times[j]))
            return None

        x, y = testtab.balls.getpos()
        if y < yrange[0] or y > yrange[1]:
            logging.debug('Hole will not be able to be placed for time {}'.format(times[j]))
            return None

    testtab.step(times[-1])
    if testtab.balls.bounces != nbounces:
        logging.debug('Failed on occluded bounces; %d', testtab.balls.bounces)
        return None

    testtab.step(config['showtime'])
    if testtab.balls.bounces != nbounces:
        logging.debug('Failed on shown bounces; %d', testtab.balls.bounces - nbounces)
        return None
    if testtab.balls.getpos()[0] < (xend + config['ballsize']):
        logging.debug('Failed by starting beyond wall; %d %d', testtab.balls.getpos()[0], xend)
        return None
    if testtab.balls.getpos()[0] > (xmax - 50):
        logging.debug('Failed by starting too close to wall; %d %d', testtab.balls.getpos()[0], xend)
        return None

    logging.debug('Passed checks; %d %d %f', xend, yend, theta)

    # If it's passed checks, reverse to get start point (sometimes off by a few px for physics reasons)
    ballbeg = [int(x) for x in testtab.balls.getpos()]
    ballbegvel = [int(-x) for x in testtab.balls.getvel()]

    bpos = []
    for t in occtimes:
        fwdtab = pt.SimpleTable(config['dims'], def_ball_rad=config['ballsize'])
        fwdtab.addBall(ballbeg, ballbegvel)
        fwdtab.step(config['showtime'] + t)
        bex, bey = [int(x) for x in fwdtab.balls.getpos()]
        bpos.append((bex, bey))

        vex, vey = map(int, fwdtab.balls.getvel())
        if vex > 0:
            logging.debug('Hit the wall from the wrong side')
            return None
        if bex + config['ballsize'] + 5 > ballbeg[0]:
            logging.debug('Ball ends to the right of start')
            return None

        logging.debug('Re-simulated; %d %d %d %d', bex, bey, vex, vey)

    # Make the MultiHole stimulus
    tr = ht.MultiHole(
        'B_' + str(nbounces) + '_' + str(i),
        config['dims'],
        config['showtime'],
        config['fps'],
        config['ballvel'],
        config['ballsize'],
        config['wallwid'],)
    tr.addBall(ballbeg, ballbegvel)

    tottimes = [config['showtime'] + t + config['pasttime'] for t in occtimes]
    y_min, y_max = 10, config['dims'][1] - 10
    holesize = config['holesize']
    
    for tottime, occtime, (bex, bey) in zip(tottimes, occtimes, bpos):

        def add_hole(offset=0):
            if offset:
                y_center_options = [bey + offset, bey - offset]
                random.shuffle(y_center_options)
            else:
                y_center_options = [bey]

            for y_center in y_center_options:
                top = y_center - holesize // 2
                bottom = y_center + holesize // 2
                if top > y_min and bottom < y_max:
                    try:
                        hole = tr.addHole('{}_{}'.format(offset, occtime), bex, top, bottom, tottime)
                        return hole
                    except RuntimeError:
                        logging.warning('Failed on bounce limits')
                        # Try other options if available, otherwise return None indicating failure
                

        for hole_type in config['hole_types']:
            if hole_type == 'hit':
                offset = 0
            elif hole_type == 'miss':
                offset = config['holesize']
            else:
                raise ValueError('bad hole_type: {}'.format(hole_type))
            hole = add_hole(offset)
            if hole is None:
                return None



        ## Add the straight-on hole
        #try:
        #    straight_hole = tr.addHole('SO_{}'.format(occtime), bex, bey - int(hw / 2.), bey + int(hw / 2.), tottime)
        #except RuntimeError:
        #    logging.debug('Failed on bounce limits')
        #    return None


        #tb = tr.ht.makeTable()
        #tb.step(tottime)
        #if tb.balls.getpos()[0] > (bex - config['wallwid']):
        #    logging.debug('Bounced out')
        #    return None

        ## Add the far miss hole
        #miss_hole = make_miss_hole(bey, config['dims'][1], config['holesize'])
        #if miss_hole is None:
        #    logging.debug("Cannot place miss hole.")
        #    return None
        #ep1, ep2 = miss_hole
        #try:
        #    tr.addHole('FH_{}'.format(occtime), bex, ep1, ep2, tottime)
        #except RuntimeError:
        #    logging.debug('Failed on bounce limits')
        #    return None

    return tr


def make_trial(config, occtimes=None, nbounces=0, i=0):
    while True:
        # rejection sampling: try making a trial until it works
        tr = _make_trial(config, occtimes=occtimes, nbounces=nbounces, i=i)
        if tr is not None:
            return tr



def make_control(config):

    def make_multi_hole(name):
        return ht.MultiHole(
            name,
            config['dims'],
            config['showtime'],
            config['fps'],
            config["ballvel"],
            config["ballsize"],
            config["wallwid"])

    hx = 50
    tottime = config["showtime"] + .5 + config["pasttime"]

    # ctr1: Straight on, clear hit
    ctr1 = make_multi_hole('control_0')
    bx = int(50 + (config["showtime"]+.5)*config["ballvel"] + config["ballsize"])
    ctr1.addBall((bx, int(config["dims"][1]/2)), (-1, 0))
    ctr1.addHole('control', hx, int(config["dims"][1]/2 - 150), int(config["dims"][1]/2 + 150), tottime)
    ctr1.setCtrl(True)

    # ctr2: Straight on, clear miss
    ctr2 = make_multi_hole('control_1')
    ctr2.addBall((bx, 50), (-1, 0))
    ctr2.addHole('control', hx, config["dims"][1] - 150, config["dims"][1] - 50, tottime)
    ctr2.setCtrl(True)

    # ctr3: Goes up, clear hit
    bxdiag = bx*.8
    bydiag = bx*.6
    ctr3 = make_multi_hole('control_2')
    ctr3.addBall((bxdiag, bydiag + 150), (-4, -3))
    ctr3.addHole('control', hx, 25, 375, tottime)
    ctr3.setCtrl(True)

    # ctr4: Goes up, clear miss
    ctr4 = make_multi_hole('control_3')
    ctr4.addBall((bxdiag, bydiag + 150), (-4, -3))
    ctr4.addHole('control', hx, 450, 550, tottime)
    ctr4.setCtrl(True)

    # ctr5: Goes down, clear hit
    ctr5 = make_multi_hole('control_4')
    ctr5.addBall((bxdiag, 550 - bydiag), (-4, 3))
    ctr5.addHole('control', hx, 325, 625, tottime)
    ctr5.setCtrl(True)

    # ctr6: Goes down, clear miss
    ctr6 = make_multi_hole('control_5')
    ctr6.addBall((bxdiag, 550 - bydiag), (-4, 3))
    ctr6.addHole('control', hx, 150, 250, tottime)
    ctr6.setCtrl(True)

    # ctr7: Goes straight, clear hit
    ctr7 = make_multi_hole('control_6')
    ctr7.addBall((bx, 450), (-1, 0))
    ctr7.addHole('control', hx, 300, 600, tottime)
    ctr7.setCtrl(True)

    # ctr8: Goes straight, clear miss
    ctr8 = make_multi_hole('control_7')
    ctr8.addBall((bx, 450), (-1, 0))
    ctr8.addHole('control', hx, 50, 150, tottime)
    ctr8.setCtrl(True)

    controls = [ctr1, ctr2, ctr3, ctr4, ctr5, ctr6, ctr7, ctr8]
    logging.info('Created control trials')
    return controls


def make_all_trials(config='exp1_config.yml', json_path=None, python_path=None, rseed=10):
    if isinstance(config, str):
        if config.endswith('.json'):
            all_config = util.load_config(config)
        elif config.endswith('.yml'):
            all_config = yaml.load(open(config))
        else:
            raise ValueError('Bad config file: ' + config)
        python_path = all_config['paths']['python_stimuli']
        json_path = all_config['paths']['json_stimuli']
        config = all_config['stimuli']


    def make_instruct_mix(config):
        assert 0
        return make_block('easy', 4) + make_block('standard', 2) + make_block('hard', 2)

    def make_block(name, num=None):
        logging.info('making block: %s', name)
        if name == 'instruct' and config['blocks']['instruct'].get('mix'):
            return make_instruct_mix(config)
        if name == 'filler':
            num = (config['num']['critical'] / 2 - 1) * 2
        else:
            if num is None:
                num = config['num'][name]
        if name == 'control':
            return make_control(config)[:num]

        block_config = util.ChainMap(config['blocks'][name], config)
        block = []
        while True:  # until we make enough trials
            for t in block_config['occtimes']:
                for b in block_config['bounces']:
                    if len(block) >= num:
                        return block
                    tr = make_trial(block_config, occtimes=[t], nbounces=b)
                    tr.ht.name = '{}_{}'.format(name, len(block))
                    logging.info('Created %s', tr.ht.name)
                    block.append(tr)


    trial_blocks = {name: make_block(name) 
                    for name in config['blocks'].keys() + ['control']}


    all_trials = itertools.chain(*trial_blocks.values())
    

    def save(tr, filename):
        logging.debug('Saving %s', filename)
        if not os.path.exists(json_path):
            os.makedirs(json_path)
        trialpath = os.path.join(json_path, filename + '.json')
        with open(trialpath, 'w') as ofl:
            ofl.write(tr.jsonify())

        if python_path:
            if not os.path.exists(python_path):
                os.makedirs(python_path)
            pytrialpath = os.path.join(python_path, filename + '.mhtr')
            tr.save(pytrialpath)

    # Save all trials
    for tr in all_trials:
        save(tr, tr.ht.name)
    logging.info('All trials saved')

    def trial(name, layout, kind, good_cue=None):
        return {'hole': name, 'layout': layout, 'kind': kind, 'good_cue': good_cue}

    #def make_critical_conditions():
    #    for hit1, hit2 in (('hit', 'miss'), ('miss', 'hit')):
    #        for tr1, tr2 in ((1, 2), (2, 1)):
    #            yield (trial('critical_{}_true'.format(tr1), hit1, 'critical'),
    #                   trial('critical_{}_false'.format(tr2), hit2, 'critical'))

    def make_critical_conditions():
        layouts = [h.name for h in trial_blocks['critical'][0].holes]
        num_holes = config['num']['critical']

        def condition(c):
            for i in range(num_holes):
                hole = (i + 2*c) % num_holes
                lay = layouts[(i + c) % len(layouts)]
                good_cue = i < num_holes / 2
                name = 'critical_{}'.format(hole)
                yield trial(name, lay, 'critical', good_cue=good_cue)

        for c in range(4): # ASSUMPTION
            yield list(condition(c))

    critical_block_options = list(make_critical_conditions())

    def make_conditions():
        n_counterbalance = len(trial_blocks['standard'][0].holes)
        conditions = []
        for cb in range(n_counterbalance):
            blocks = {}
            for trial_type, multi_holes in trial_blocks.items():
                if trial_type == 'critical':
                    continue # handle these below
                blocks[trial_type] = []
                idx = [1, 1, 0, 0]
                for i, mh in enumerate(multi_holes):
                    hole = mh.holes[idx[i % 4] % len(mh.holes)]
                    # Pick the hole shown on each trial by cycling between the possibilities.
                    # This cycle is shifted by `cb`, resulting in a latin squares design.
                    # hole = mh.holes[(cb + i) % len(mh.holes)]
                    blocks[trial_type].append(trial(mh.ht.name, hole.name, trial_type))

            # Cue and critical conditions
            # We reuse `cb` to counterbalance the order of critical trials.
            latin_sq_critical = critical_block_options[cb % 2::2]
            for crit_trials in latin_sq_critical:
                for params in dict_product(config['between_subjects']):
                    if params['wall_cue'] and params['color_cue']:
                        logging.warning('Skipping condition with two cues.')
                        continue
                    if not (params['wall_cue'] or params['color_cue']):
                        # logging.warning('Skipping condition with no cues.')
                        # continue
                        pass
                    params['condition'] = len(conditions)
                    params['counter'] = cb
                    c_blocks = dict(blocks)
                    c_blocks['critical'] = crit_trials
                    c_dict = {'blocks': c_blocks,
                              'params': params}
                    conditions.append(c_dict)

        return conditions


    conditions = make_conditions()

    for idx, c_dict in enumerate(conditions):
        condpath = os.path.join(json_path, 'condition_{}.json'.format(idx))
        with open(condpath, 'w+') as file:
            json.dump(c_dict, file)
            print('created ', condpath)

    update_config(len(conditions))
    update_config(len(conditions), 'experiment/config.txt')


def update_config(num_conditions, file='experiment/remote-config.txt'):
    with open(file) as f:
        config = f.read()
    new_config = re.sub(r'num_conds = \d+', 'num_conds = {}'.format(num_conditions), config)
    with open(file, 'w+') as f:
        f.write(new_config)


def debug():
    #all_config = util.load_config(1)
    #paths = all_config["paths"]
    #config = all_config["stimuli"]
    #bounces = config["bounces"]
    #tr = make_trial(config, occtimes=[1.3], nbounces=0, i=0)
    #tr.demonstrate()
    make_all_trials(config='exp1_config_debug.json')

if __name__ == '__main__':
    make_all_trials(*sys.argv[1:])

