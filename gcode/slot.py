from pync import *

FX = 250
FZ = 25

G54() - G64(P=0.05) - S(1000) - F(100) - M3

G0(X=0, Y=0, Z=2)
z=-1.0
while z > -13.999:
	G1(Z=z) - F(FZ)
	G1(X=80) - F(FX)
	G1(Y=9.5)
	G1(X=0)
	G1(Y=0)
	z -= 2
