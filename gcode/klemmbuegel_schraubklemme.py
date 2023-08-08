from pync import *

f=100

G54() - G64(0.05) - S(1000) - F(100) - M3

def kontur():
	G0(X=5+5, Y=50, Z=-16)
	d = 10
	while not equal(d, 9.5):
		G41_1(D=d) - G1(X=0, Y=50) - F(f)
		G1(X=0, Y=15)
		G3(X=15, Y=0, I=15, J=0)
		G1(X=88, Y=0)
		G40() - G1(X=88, Y=5+5)
		G0(X=5+5, Y=50)
		d = max(d - 0.5, 9.5)

def fase():
	G0(X=-(5+5), Y=50, Z=-2.5)

	d = 2.5
	G42_1(D=d) - G1(X=0, Y=50) - F(f)
	G1(X=0, Y=15)
	G2(X=-15, Y=0, I=-15, J=0)
	G1(X=-88, Y=0)
	G40() - G1(X=-88, Y=5+5)
	G0(X=-(5+5), Y=50)

def aussenradius():
	G0(X=-10, Y=-33, Z=-16)

	d = 10.5
	while not equal(d, 10):
		G41_1(D=d) - G1(X=0, Y=-30) - F(f)
		G2(X=30, Y=0, I=30, J=0)
		G1(X=63)
		G40() - G1(X=68, Y=10)
		G0(X=10)
		G0(X=-10, Y=-10)
		G0(Y=-33)
		d = max(d - 0.25, 10)

def aussenfase():
	G0(X=10, Y=-33, Z=-2.5)

	d = 2.5
	G42_1(D=d) - G1(X=0, Y=-30) - F(f)
	G3(X=-30, Y=0, I=-30, J=0)
	G1(X=-63)
	G40() - G1(X=-68, Y=10)
	G0(X=-10)
	G0(X=10, Y=-10)
	G0(Y=-33)

def spitzenradius():
#	r = 7
	r = 5
	G0(X=-7.5-r, Y=0, Z=-16)
	while 1:
		G1(X=-7.5-r, Y=0) - F(f)
		G2(X=7.5+r, Y=0, I=7.5+r, J=0)
		G1(X=7.5+2+r, Y=0)
		G3(X=-7.5-2-r, Y=0, I=-7.5-2-r, J=0) - F(50000)

		if equal(r, 5):
			break
		r = max(r - 0.25, 5)

def spitzenfase():
#	r = 1.25
	r = 1.35
	G0(Y=7.5+r, X=0, Z=-2.5)
	G1(Y=7.5+r, X=0) - F(f)
	G2(Y=-7.5-r, X=0, J=-7.5-r, I=0)
	G1(Y=-7.5-2-r, X=0)
	G3(Y=7.5+2+r, X=0, J=7.5+2+r, I=0) - F(50000)

