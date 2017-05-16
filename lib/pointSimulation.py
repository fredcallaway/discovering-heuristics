from __future__ import division

import physicsTable as pt
import physicsTable.constants as ptc
import random
import numpy as np

from multiprocessing import cpu_count


class PointSimulation(pt.PointSimulation):

    def __init__(self, table, seed=1, kapv=ptc.KAPV_DEF, kapb=ptc.KAPB_DEF, kapm=ptc.KAPM_DEF, perr=ptc.PERR_DEF, ensure_end=False, nsims=200, maxtime=50., cpus=cpu_count(), timeres=0.05):
        self.tab = table
        self.kapv = kapv
        self.kapb = kapb
        self.kapm = kapm / (timeres / 0.001) # Correction for the fact that we're simulating fewer steps and thus jitter must be noisier
        self.perr = perr
        self.maxtime = maxtime
        self.nsims = nsims
        self.ts = timeres

        self.outcomes = None
        self.endpts = []
        self.bounces = None
        self.time = None
        self.run = False
        self.enend = ensure_end

        self.ucpus = cpus
        self.badsims = 0
        self.seed = seed

    def singleSim(self, i):
        random.seed(self.seed + i)
        np.random.seed(self.seed + i)
        return super(PointSimulation, self).singleSim(i)

    def getEndpoints(self, xonly=False, yonly=False):
        if not self.run:
            raise Exception('Cannot get simulation endpoints without running simulations first')
        if xonly and not yonly:
            return [int(p[0]) for p in self.endpts]
        elif yonly and not xonly:
            return [int(p[1]) for p in self.endpts]
        else:
            return [(int(p[0]), int(p[1])) for p in self.endpts]
        return self.endpts
