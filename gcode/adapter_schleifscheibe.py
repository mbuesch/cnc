#!/usr/bin/env python3
#
# Adapter Schleifscheibe
#

from pync import *

TOLR	= 0.01
ZFEED	= 1000
XYFEED	= 5000
XYFEED2	= 1000
TD	= 6	# Tool D

TR	= TD / 2.0

G64(TOLR)
G0(z=5)
S(2000) | M3 | F(XYFEED)

di=12.8
ri=di/2.0

da=32.0
ra=da/2.0

t=-17.0

G0(x=ri-TR, y=0, z=1)
G1(z=t)
G2(x=ri-TR, y=0, i=-(ri-TR), j=0)
G0(z=1)
G0(x=ra+TR, y=0)
G1(z=t)
G3(x=ra+TR, y=0, i=-(ra+TR), j=0)
G0(z=5)

M0() | M5

