from pync import *
G54 - F(99999) - S(1000) - M3
for _ in range(100):
    G0(x=0, y=0, z=0) - G17
    G2(x=10, y=0, i=5, j=0)
    G2(x=10, z=-10, i=0, k=-5) - G18
# vim: ts=4 sw=4 expandtab
