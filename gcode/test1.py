from pync import *

f=100

G54() - G64(0.05) - S(1000) - F(100) - M3

G0(X=0, Y=0, Z=2)
z=-1
while z > -2.001:
	G1(Z=z) - F(f/3)
	G1(X=5.5-3) - F(f/2)
	G2(X=5.5-3, Y=0, I=-(5.5-3), J=0) - F(f)
	G1(X=9.5-3) - F(f/2)
	G2(X=9.5-3, Y=0, I=-(9.5-3), J=0) - F(f)
	G0(X=5.5-3)
	G1(Z=z-0.3) - F(f/3)
	G2(X=5.5-3, Y=0, I=-(5.5-3), J=0) - F(f)
	z -= 1
