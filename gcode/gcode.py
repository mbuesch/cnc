"""
# Python Gcode wrapper
#
# Copyright (c) 2010 Michael Buesch <mb@bu3sch.de>
#
# Licensed under the GNU General Public License version 2
# or (at your option) any later version.
#
# Example usage:

from gcode import *
prologue()
G54() << G0(0, 0, 2) << S(1000) << F(100) << M3
for (x, y) in ((0, 0), (10, 10), (20, 20)):
	G0(x, y)
	G1(Z=-20)
	G0(Z=2)
end()
"""

import sys
import datetime


lineBuffer = []

def dumpGCode(fd=sys.stdout):
	"Print the Gcode. Defaults to stdout."
	global lineBuffer
	for line in lineBuffer:
		fd.write(str(line))
		fd.write("\n")
	fd.write("\n")
	lineBuffer = []

class Line:
	"A generic Gcode line."
	def __init__(self, code=""):
		global lineBuffer
		self.code = code
		lineBuffer.append(self)

	def __merge(self, add):
		global lineBuffer
		if str(type(add)) == "<type 'classobj'>":
			add = add()
		if type(add) == str:
			self.code += " " + add
		else:
			self.code += " " + add.code
			lineBuffer.remove(add)
		return self

	def __lshift__(self, add): # a << b
		"Merge code lines."
		return self.__merge(add)

	def __repr__(self):
		return self.code

	@staticmethod
	def makecoordnum(coord):
		if type(coord) == float:
			return "%.4f" % coord
		return "%d" % coord

	@staticmethod
	def makecoord(axis, coord):
		return axis + Line.makecoordnum(coord)

	@staticmethod
	def makegcodenum(number):
		if type(number) == float:
			return "%.1f" % number
		return "%d" % number

	@staticmethod
	def makegcode(code, number):
		return code + Line.makegcodenum(number)

class Comment(Line):
	"A human readable comment"
	def __init__(self, text="", space=" "):
		text = text.replace("\n", " ")
		text = text.replace("\r", " ")
		if text:
			text = "(%s%s%s)" % (space, text, space)
		Line.__init__(self, text)

class Print(Comment):
	"Print a message"
	def __init__(self, text):
		Comment.__init__(self, "PRINT," + text, space="")

class Debug(Comment):
	"Print a debugging message"
	def __init__(self, text):
		Comment.__init__(self, "DEBUG," + text, space="")

class LogOpen(Comment):
	"Open a log file"
	def __init__(self, filename):
		Comment.__init__(self, "LOGOPEN," + filename, space="")

class LogClose(Comment):
	"Close the log file"
	def __init__(self):
		Comment.__init__(self, "LOGCLOSE", space="")

class Log(Comment):
	"Write text to the log file"
	def __init__(self, text):
		Comment.__init__(self, "LOG," + text, space="")

class G(Line):
	"Generic G-code"
	def __init__(self, number, X=None, Y=None, Z=None,
				   A=None, B=None, C=None,
				   I=None, J=None, K=None,
				   U=None, V=None, W=None,
				   P=None, Q=None, R=None,
				   L=None,):
		Line.__init__(self, self.makegcode("G", number))
		for paramStr in ("X", "Y", "Z",
				 "A", "B", "C",
				 "I", "J", "K",
				 "U", "V", "W",
				 "P", "Q", "R",
				 "L",):
			param = eval(paramStr)
			if param is not None:
				self << Line.makecoord(paramStr, param)

class G0(G):
	"G0 => rapid move"
	def __init__(self, X=None, Y=None, Z=None,
			   A=None, B=None, C=None,
			   U=None, V=None, W=None):
		G.__init__(self, 0, X=X, Y=Y, Z=Z,
				    A=A, B=B, C=C,
				    U=U, V=V, W=W)

class G1(G):
	"G1 => move"
	def __init__(self, X=None, Y=None, Z=None,
			   A=None, B=None, C=None,
			   U=None, V=None, W=None):
		G.__init__(self, 1, X=X, Y=Y, Z=Z,
				    A=A, B=B, C=C,
				    U=U, V=V, W=W)

class G2(G):
	"G2 => clockwise arc move"
	def __init__(self, X=None, Y=None, Z=None,
			   I=None, J=None, K=None,
			   R=None):
		G.__init__(self, 2, X=X, Y=Y, Z=Z, I=I, J=J, K=K, R=R)

class G3(G):
	"G3 => counterclockwise arc move"
	def __init__(self, X=None, Y=None, Z=None,
			   I=None, J=None, K=None,
			   R=None):
		G.__init__(self, 3, X=X, Y=Y, Z=Z, I=I, J=J, K=K, R=R)

class G10L1(G):
	"G10 L1 => Set tool table"
	def __init__(self, P=None, R=None, X=None, Z=None, Q=None):
		G.__init__(self, 10, L=1, P=P, R=R, X=X, Z=Z, Q=Q)

class G10L2(G):
	"G10 L2 => Set coordinate system"
	def __init__(self, P=None, X=None, Y=None, Z=None,
				   A=None, B=None, C=None,
				   U=None, V=None, W=None):
		G.__init__(self, 10, L=2, P=P,
			   X=X, Y=Y, Z=Z,
			   A=A, B=B, C=C,
			   U=U, V=V, W=W)

class G64(G):
	"G64 => Path control mode"
	def __init__(self, P=None):
		G.__init__(self, 64, P=P)

class M(Line):
	"Generic M-code"
	def __init__(self, number):
		Line.__init__(self, self.makegcode("M", number))

class S(Line):
	"Set spindle speed"
	def __init__(self, number):
		Line.__init__(self, self.makegcode("S", number))

class F(Line):
	"Set feed rate"
	def __init__(self, number):
		Line.__init__(self, self.makegcode("F", number))

class T(Line):
	"Set tool"
	def __init__(self, number):
		Line.__init__(self, self.makegcode("T", number))

def __genTrivial(code, number):
	template = """
class %s%s(%s):
	def __init__(self):
		%s.__init__(self, %s)
"""
	numStr = Line.makegcodenum(number)
	return template % (code, numStr.replace(".", "_"), code,
			   code, numStr)

# Declare trivial G codes
for __num in (17, 18, 19, 17.1, 18.1, 19.1,
	      20, 21,
	      28, 28.1,
	      30, 30.1,
	      40, 41, 42, 41.1, 42.1,
	      49,
	      53, 54, 55, 56, 57, 58, 59, 59.1, 59.2, 59.3,
	      61, 61.1,
	      80,
	      90, 91,
	      93, 94, 95):
	exec(__genTrivial("G", __num))

# Declare trivial M codes
for __num in range(0, 200):
	exec(__genTrivial("M", __num))

# Convenience functions
def prologue():
	"Generate the file prologue"
	Comment("This file is generated by gcode.py. Do not edit!")
	Comment(str(datetime.datetime.today()))
	Comment()
	G54() << G17 << G40 << G49 << G80 \
	      << G90 << G94 << G61 << G21

def end(fd=sys.stdout):
	"Generate an M30 (program end) and dump the code."
	M30()
	dumpGCode(fd)

def equal(a, b):
	"Test a and b for equalness. Returns bool. Also works for float."
	if type(a) == float or type(b) == float:
		return abs(float(a) - float(b)) < 0.00005
	return a == b

# Declare aliases
rapid = G0
move = G1
arcCw = G2
arcCcw = G3
