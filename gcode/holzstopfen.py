#!/usr/bin/env python

from pync import *

TOLR	= 0.2
ZFEED	= 1000
XYFEED	= 5000
XYFEED2	= 1000
TD	= 6	# Tool D

TR	= TD / 2.0

def cpock(r, z, maxinc=TR,
	  xyfeed=XYFEED, xyfeed2=XYFEED2, zfeed=ZFEED):
	c("Circular pocket: r=%f, z=%f, maxinc=%f, "
	  "xyfeed=%f, xyfeed2=%f, zfeed=%f" %(
	  r, z, maxinc,
	  xyfeed, xyfeed2, zfeed))
	inc = r / ceil(r / maxinc)
	prev_r = 0
	cur_r = inc
	G1(z=z) | F(zfeed)
	G91()
	while 1:
		final_run = ge(cur_r, r)
		if final_run:
			G61()
		G1(x=cur_r-prev_r) | F(xyfeed2)
		G3(x=0, y=0, i=-cur_r, j=0) | F(xyfeed)
		if final_run:
			break
		prev_r = cur_r
		cur_r += inc
	G64(TOLR)
	G1(x=-cur_r)
	G90()

def cpeg(x_center, r_start, r_end, z, maxinc=TR,
	 xyfeed=XYFEED, xyfeed2=XYFEED2, zfeed=ZFEED):
	c("Circular peg: x_center=%f, r_start=%f, r_end=%f, z=%f, maxinc=%f, "
	  "xyfeed=%f, xyfeed2=%f, zfeed=%f" %(
	  x_center, r_start, r_end, z, maxinc,
	  xyfeed, xyfeed2, zfeed))
	assert(ge(r_start, r_end))
	r_diff = r_start - r_end
	inc = r_diff / ceil(r_diff / maxinc) if r_diff else 0
	cur_r = r_start
	G0(x=r_start)
	G1(z=z) | F(zfeed)
	G91()
	final_run = le(cur_r, r_end)
	while 1:
		G2(x=0, y=0, i=-(cur_r-x_center), j=0) | F(xyfeed)
		if final_run:
			break
		prev_r = cur_r
		cur_r -= inc
		final_run = le(cur_r, r_end)
		if final_run:
			G61()
		G1(x=-inc) | F(xyfeed2)
	G64(TOLR)
	G90()
	G1(x=r_start)

G64(TOLR)
G0(z=25)
S(2000) | M3 | F(XYFEED)

bases = ((0, 0), ((34+TD+TD+1), 0))

for base_x, base_y in bases:
	c("=== base_x=%f, base_y=%f ===" %(
	  base_x, base_y))
	G0(x=base_x, y=base_y)

	if 1:
		c("-- Planfraesen --")
		G0(z=19)
		cpock(r=34/2+2+TR, z=10, maxinc=5)
	if 1:
		c("-- Tasche --")
		G1(z=10)
		cpock(r=16/2-TR, z=5, maxinc=5)
	if 1:
		c("-- Aussendurchmesser --")
		G0(z=11)
		cpeg(x_center=base_x,
		     r_start=base_x+(34/2+1+TR),
		     r_end=base_x+(25/2+TR),
		     z=3)
	if 1:
		c("-- Freifraesen --")
		G0(x=base_x+(34/2+TR), z=3)
		cpeg(x_center=base_x,
		     r_start=base_x+(34/2+TR),
		     r_end=base_x+(34/2+TR),
		     z=0.5,
		     xyfeed=XYFEED2)
	M0() | M5
	G0(z=25)
