from __future__ import division

import random
import numpy as np
from numpy import sin, cos, pi, mean





def EUgTp(T, p, ucorrect=1, uincorrect=0):
    """Expected utility per decision given threshold, probability of action (One
    & Done, Eq 9-10)

    """
    q = (p ** T) / ((p ** T) + ((1 - p) ** T))
    wplus = p*q + (1-p)*(1-q)
    return (wplus*ucorrect) + ((1 - wplus)*uincorrect)

def PkH0gTp(k, T, p):
    """Probability of taking k samples and choosing H0 given threshold,
    probability of action (One & done, Eq 11)

    Note that this assumes:
    - you start at point T
    - P(k | T, p) is the probability of the number of samples it takes to
      get to 2*T, but is more like P(k, ruin | T, p) because we are assuming
      that we always actually get to T. In order to get the real P(k | T, p),
      we need to calculate P(k, ruin | T, p) + P(k, ruin | T, 1-p).

    """
    if T <= 0:
        return np.zeros_like(p)

    if T == 1:
        if T == k:
            return np.ones_like(p) * (1 - p)
        else:
            return np.zeros_like(p)

    if (k % 2) != (T % 2):
        return np.zeros_like(p)

    if k < T:
        return np.zeros_like(p)

    # use equations from Feller
    z = T
    a = 2 * T

    # Get the latter half of the equation
    def infn(v):
        theta = v*pi / a
        c = cos(theta) ** (k - 1)
        s1 = sin(theta)
        s2 = sin(theta * z)
        return c * s1 * s2

    latter = sum([infn(v) for v in range(1, a)])
    C = (2 ** k) / a

    # for P(k, ruin | T, p)
    p1 = p ** ((k - z) / 2)
    p2 = (1 - p) ** ((k + z) / 2)

    return C * latter * p1*p2

def PkgTp(k, T, p):
    p_H0 = PkH0gTp(k, T, p)
    p_H1 = PkH0gTp(k, T, 1 - p)
    return p_H1 + p_H0


def ERoRgTc(T, c, presolution=201, ucor=1, uincor=0):
    """Expected rate of return for a given threshold, cost of sample (One &
    done, Eq 13). Note: assumes uniform prior over ps

    """
    if T == 0:
        return 0.5

    def infn(p):
        EU = EUgTp(T, p, ucor, uincor)

        def infnpart(x):
            P2xT = PkgTp(2*x + T, T, p)
            denom = ((2*x + T) / c) + 1
            return EU * P2xT / denom

        # Sum at least 10 xs
        ret = sum([infnpart(i) for i in range(0, 11)])
        i = 10
        newr = ret
        # Keep going until it's adding less than .1% per new iteration
        while newr > (ret * .001):
            i += 1
            newr = infnpart(i)
            ret += newr
        return ret

    # Approximate integral from 0.5 to 1
    # Enforces uniform distribution over ps
    testps = np.linspace(0.5, 1, num=presolution)
    # Need to multiply by 2 since we are only integrating over half the space
    # (but it is symmetric, so we don't need to actually to the integral over
    # the other half)
    return 2 * np.trapz([infn(p) for p in testps], testps)

def bestThreshold(c, ucor=1, uincor=0, maxT=20):
    """Find the threshold that maximizes rate of return for a given sample cost
    (One & done, Eq 14)

    """
    f = lambda x: ERoRgTc(x, c, ucor=ucor, uincor=uincor)
    rors = map(f, range(1, maxT + 1))
    idx = np.argmax(rors)
    return [idx + 1, rors[idx]]

def _check_tiny(p, factor=1):
    logp = np.log(p)
    tiny = np.log(np.finfo(float).tiny)
    toosmall = (logp * factor) < tiny
    return toosmall

def EkgTp(T, p):
    """Expected number of samples given a threshold and probability of success
    (One & done, Eq 12)

    """
    is_zero = _check_tiny(p)
    is_one = _check_tiny(1 - p)
    is_half = p == 0.5
    other = ~(is_zero | is_one | is_half)

    ret = p.copy()
    ret[is_zero] = T
    ret[is_one] = T
    ret[is_half] = T ** 2

    pother = p[other]
    first = T / (1 - 2*pother)
    mid = 2*T / (1 - 2*pother)
    num = 1 - ((1 - pother) / pother) ** T
    denom = 1 - ((1 - pother) / pother) ** (2*T)
    ret[other] = first - (mid * (num / denom))

    return ret

def EkgTpH0(T, p):
    is_zero = _check_tiny(p)
    is_one = _check_tiny(1 - p)
    is_half = p == 0.5
    other = ~(is_zero | is_one | is_half)

    Ek = np.zeros_like(p)
    Ek[is_zero] = T
    Ek[is_one] = np.nan
    Ek[is_half] = T ** 2

    if T == 0:
        Ek[other] = np.nan
    elif T == 1:
        Ek[other] = 1
    else:
        pother = p[other]
        for k in range(T, 100, 2):
            Ek[other] += PkH0gTp(k, T, pother) * k / (1 - pother)

    return Ek

def EkgTpH1(T, p):
    is_zero = _check_tiny(p)
    is_one = _check_tiny(1 - p)
    is_half = p == 0.5
    other = ~(is_zero | is_one | is_half)

    Ek = np.zeros_like(p)
    Ek[is_zero] = np.nan
    Ek[is_one] = T
    Ek[is_half] = T ** 2

    if T == 0:
        Ek[other] = np.nan
    elif T == 1:
        Ek[other] = 1
    else:
        pother = p[other]
        for k in range(T, 100, 2):
            Ek[other] += PkH0gTp(k, T, 1 - pother) * k / pother

    return Ek

def pRuin(z, a, p):
    """Probability of getting failure at point z with upper limit a & add
    probability p (From Feller: Ch 14, Eq 2.4/5)

    """
    is_zero = _check_tiny(p, factor=a) | _check_tiny(p, factor=z)
    is_half = p == 0.5
    other = ~(is_zero | is_half)

    ret = p.copy()
    ret[is_half] = 1 - (z / a)
    ret[is_zero] = 1

    rat = (1 - p[other]) / p[other]
    ret[other] = ((rat ** a) - (rat ** z)) / ((rat ** a) - 1)

    return ret

def simSingleSPRT(T, p):
    """Testing SPRT sample calculations. Returns number of steps and boolean for
    success.

    """
    i = 0
    D = 0
    while i > -T and i < T:
        D += 1
        if random.random() < p:
            i += 1
        else:
            i -= 1
    return [D, i == T]

def simSPRT(T, p, n=10000):
    """Returns number of steps on average, number of steps for success, and
    number of steps for failure

    """
    rets = [simSingleSPRT(T, p) for i in range(n)]
    sucs = []
    fails = []
    for steps, success in rets:
        if success:
            sucs.append(steps)
        else:
            fails.append(steps)
    return [
        mean(sucs + fails),
        mean(sucs), mean(fails),
        len(sucs) / n,
        len(fails) / n
    ]
