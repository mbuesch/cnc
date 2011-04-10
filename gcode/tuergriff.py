#!/usr/bin/env python

from pync import *


FEED = 200
ZFEED = 50
REDUCEDFEED = 120
MILL_RADIUS = 5.0
WP_RADIUS = 5.0
STEPS = 20

# sin(a) = Z/radius
# cos(a) = XY/radius
def calcOffsets(angle, radius):
	angle = radians(angle)
	xy = radius * cos(angle)
	z = radius * sin(angle)
	return (xy, z)

G64(0.03)
G0(0, 0, 5)
S(1500) - M3 - F(FEED)

angle = 0.0
while True:
	(millXY, millZ) = calcOffsets(angle, MILL_RADIUS)
	(wpXY, wpZ) = calcOffsets(angle, WP_RADIUS)

	Comment("mXY%f mZ%f wXY%f wZ%f" % (millXY, millZ, wpXY, wpZ))
	xyOff = WP_RADIUS - millXY - wpXY
	Comment("PLANE OFFSET %f" % xyOff)
	X = 39.5
	Y = 9.5
	Z = 0.0 - WP_RADIUS - MILL_RADIUS + millZ + wpZ

	if equal(angle, 0):
		G0(X - WP_RADIUS - 2, Y + xyOff - 2) # Clear X/Y
	else:
		G0(Z=(Z + 5))
		M1()
#		G0(Z=Z)

		G1(X - WP_RADIUS, Y + xyOff, Z=Z)		- F(ZFEED)
		G1(-(X - WP_RADIUS), Y + xyOff)			- F(FEED)
		G3(X = -(X + xyOff), Y = Y - WP_RADIUS,
		   I = 0, J = -(WP_RADIUS + xyOff))		- F(REDUCEDFEED)
		G1(-(X + xyOff), -(Y - WP_RADIUS))		- F(FEED)
		G3(X = -(X - WP_RADIUS), Y = -(Y + xyOff),
		   I = WP_RADIUS + xyOff, J = 0)		- F(REDUCEDFEED)
		G1(X - WP_RADIUS, -(Y + xyOff))			- F(FEED)
		G3(X = X + xyOff, Y = -(Y - WP_RADIUS),
		   I = 0, J = WP_RADIUS + xyOff)		- F(REDUCEDFEED)
		G1(X + xyOff, Y - WP_RADIUS)			- F(FEED)
		G3(X = X - WP_RADIUS, Y = Y + xyOff,
		   I = -(WP_RADIUS + xyOff), J = 0)		- F(REDUCEDFEED)
		G1(X - WP_RADIUS - 2, Y + xyOff)		- F(FEED)
		G0(X - WP_RADIUS - 2, Y + xyOff - 2) # Clear X/Y

	angle += 90.0 / STEPS
	if equal(angle, 90):
		break

G0(Z=5) - M5
