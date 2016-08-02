"""
# Python Gcode wrapper
#
# Copyright (c) 2010-2016 Michael Buesch <m@bues.ch>
#
# Licensed under the GNU General Public License version 2
# or (at your option) any later version.
#
# Example usage:

from pync import *
G54() | G0(0, 0, 2) | S(1000) | F(100) | M3
for (x, y) in ((0, 0), (10, 10), (20, 20)):
	G0(x, y)
	G1(Z=-20)
	G0(Z=2)
"""

import sys
import atexit
import datetime

from math import *


class __PyNC_State(object):
	def __init__(self):
		self.reset()

	def reset(self):
		self.lineBuffer = []

	def dump(self, fd=sys.stdout):
		code = "\n".join(str(l) for l in self.lineBuffer)
		fd.write(code + "\n")

pync = __PyNC_State()

class Line(object):
	"A generic Gcode line."
	def __init__(self, code=""):
		self.code = code
		pync.lineBuffer.append(self)

	def __merge(self, add):
		if not add:
			return self
		if isinstance(add, str):
			self.code += " " + add
		else:
			if not isinstance(add, Line):
				add = add()
				assert(isinstance(add, Line))
			self.code += " " + add.code
			pync.lineBuffer.remove(add)
		return self

	def __lshift__(self, add): # a << b
		"Merge code lines."
		return self.__merge(add)

	def __add__(self, add): # a + b
		"Merge code lines."
		return self.__merge(add)

	def __sub__(self, add): # a - b
		"Merge code lines."
		return self.__merge(add)

	def __and__(self, add): # a & b
		"Merge code lines."
		return self.__merge(add)

	def __or__(self, add): # a | b
		"Merge code lines."
		return self.__merge(add)

	def __repr__(self):
		return self.code

	@staticmethod
	def makecoordnum(coord):
		if equal(coord, int(coord)):
			return str(int(coord))
		return ("%f" % float(coord)).rstrip("0")

	@staticmethod
	def makecoord(axis, coord):
		return axis + Line.makecoordnum(coord)

	@staticmethod
	def makegcodenum(number):
		if isinstance(number, float):
			return "%.1f" % number
		return "%d" % number

	@staticmethod
	def makegcode(code, number):
		return code + Line.makegcodenum(number)

	@staticmethod
	def checkargs(kwargs, allowedList):
		for arg in kwargs.keys():
			if arg not in allowedList:
				raise TypeError("Got an unexpected keyword "
					"argument '%s'" % arg)

class Comment(Line):
	"A human readable comment"
	def __init__(self, text="", space=" "):
		text = str(text).replace("\r", " ").split("\n")
		Line.__init__(self, Comment.__format(text[0], space))
		if len(text) > 1: # Remaining lines, if any.
			Comment("\n".join(text[1:]), space)

	@staticmethod
	def __format(text, space):
		if text:
			return "(%s%s%s)" % (space, text, space)
		return ""

c = Comment

class Print(Comment):
	"Print a message"
	def __init__(self, text):
		Comment.__init__(self, "PRINT," + text, space="")

p = Print

class Debug(Comment):
	"Print a debugging message"
	def __init__(self, text):
		Comment.__init__(self, "DEBUG," + text, space="")

d = Debug

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

l = Log

class G(Line):
	"Generic G-code"
	def __init__(self, number, X=None, Y=None, Z=None,
				   A=None, B=None, C=None,
				   I=None, J=None, K=None,
				   U=None, V=None, W=None,
				   P=None, Q=None, R=None,
				   L=None, D=None,
				   **kwargs):
		Line.__init__(self, self.makegcode("G", number))
		for paramStr in ("X", "Y", "Z",
				 "A", "B", "C",
				 "I", "J", "K",
				 "U", "V", "W",
				 "P", "Q", "R",
				 "L", "D"):
			param = eval(paramStr) # Fetch __init__ argument
			if param is None:
				param = kwargs.get(paramStr.lower())
			if param is not None:
				self << Line.makecoord(paramStr, param)

class G0(G):
	"G0 => rapid move"
	def __init__(self, X=None, Y=None, Z=None,
			   A=None, B=None, C=None,
			   U=None, V=None, W=None,
			   **kwargs):
		self.checkargs(kwargs, {"x", "y", "z",
					"a", "b", "c",
					"u", "v", "w"})
		G.__init__(self, 0, X=X, Y=Y, Z=Z,
				    A=A, B=B, C=C,
				    U=U, V=V, W=W,
				    **kwargs)

rapid = G0

class G1(G):
	"G1 => move"
	def __init__(self, X=None, Y=None, Z=None,
			   A=None, B=None, C=None,
			   U=None, V=None, W=None,
			   **kwargs):
		self.checkargs(kwargs, {"x", "y", "z",
					"a", "b", "c",
					"u", "v", "w"})
		G.__init__(self, 1, X=X, Y=Y, Z=Z,
				    A=A, B=B, C=C,
				    U=U, V=V, W=W,
				    **kwargs)

move = G1

class G2(G):
	"G2 => clockwise arc move"
	def __init__(self, X=None, Y=None, Z=None,
			   I=None, J=None, K=None,
			   R=None,
			   **kwargs):
		self.checkargs(kwargs, {"x", "y", "z",
					"i", "j", "k",
					"r"})
		G.__init__(self, 2, X=X, Y=Y, Z=Z,
				    I=I, J=J, K=K,
				    R=R,
				    **kwargs)

arcCw = G2

class G3(G):
	"G3 => counterclockwise arc move"
	def __init__(self, X=None, Y=None, Z=None,
			   I=None, J=None, K=None,
			   R=None,
			   **kwargs):
		self.checkargs(kwargs, {"x", "y", "z",
					"i", "j", "k",
					"r"})
		G.__init__(self, 3, X=X, Y=Y, Z=Z,
				    I=I, J=J, K=K,
				    R=R,
				    **kwargs)

arcCcw = G3

class G10L1(G):
	"G10 L1 => Set tool table"
	def __init__(self, P=None, R=None, X=None,
			   Z=None, Q=None,
			   **kwargs):
		self.checkargs(kwargs, {"p", "r", "x",
					"z", "q"})
		G.__init__(self, 10, L=1, P=P, R=R,
				     X=X, Z=Z, Q=Q,
				     **kwargs)

class G10L2(G):
	"G10 L2 => Set coordinate system"
	def __init__(self, P=None, X=None, Y=None, Z=None,
				   A=None, B=None, C=None,
				   U=None, V=None, W=None,
				   **kwargs):
		self.checkargs(kwargs, {"p", "x", "y", "z",
					"a", "b", "c",
					"u", "v", "w"})
		G.__init__(self, 10, L=2, P=P,
			   X=X, Y=Y, Z=Z,
			   A=A, B=B, C=C,
			   U=U, V=V, W=W,
			   **kwargs)

class G64(G):
	"G64 => Path control mode"
	def __init__(self, P=None, **kwargs):
		self.checkargs(kwargs, {"p"})
		G.__init__(self, 64, P=P, **kwargs)

class G41(G):
	"G41 => Cutter radius compensation - left"
	def __init__(self, D=None, **kwargs):
		self.checkargs(kwargs, {"d"})
		G.__init__(self, 41, D=D, **kwargs)

class G42(G):
	"G42 => Cutter radius compensation - right"
	def __init__(self, D=None, **kwargs):
		self.checkargs(kwargs, {"d"})
		G.__init__(self, 42, D=D, **kwargs)

class G41_1(G):
	"G41_1 => Dynamic cutter radius compensation - left"
	def __init__(self, D=None, L=None, **kwargs):
		self.checkargs(kwargs, {"d", "l"})
		G.__init__(self, 41.1, D=D, L=L, **kwargs)

class G42_1(G):
	"G42_1 => Dynamic cutter radius compensation - right"
	def __init__(self, D=None, L=None, **kwargs):
		self.checkargs(kwargs, {"d", "l"})
		G.__init__(self, 42.1, D=D, L=L, **kwargs)

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
	className = numStr.replace(".", "_")
	return template % (code, className, code,
			   code, numStr)

# Declare trivial G codes
for __num in (17, 18, 19, 17.1, 18.1, 19.1,
	      20, 21,
	      28, 28.1,
	      30, 30.1,
	      40,
	      49,
	      53, 54, 55, 56, 57, 58, 59, 59.1, 59.2, 59.3,
	      61, 61.1,
	      80,
	      90, 91, 90.1, 91.1,
	      93, 94, 95):
	exec(__genTrivial("G", __num))

# Declare trivial M codes
for __num in range(0, 200):
	exec(__genTrivial("M", __num))

def equal(a, b):
	"Test a and b for equalness. Returns bool. Also works for float."
	if isinstance(a, float) or isinstance(b, float):
		return abs(float(a) - float(b)) < 0.00001
	return a == b

eq = equal
ne = lambda a, b: not equal(a, b)
ge = lambda a, b: equal(a, b) or a > b
le = lambda a, b: equal(a, b) or a < b
lt = lambda a, b: a < b
gt = lambda a, b: a > b

def __prologue():
	"Generate the file prologue"
	pync.reset()
	Line("%")
	Comment("This file is generated by PYNC gcode wrapper from '%s'." % sys.argv[0])
	Comment(str(datetime.datetime.today()))
	Comment()
	G54() << G17 << G40 << G49 << G80 \
	      << G90 << G91_1 << G94 << G61 << G21

def __epilogue(fd=sys.stdout):
	"Generate an M30 (program end) and dump the code."
	M30()
	Line("%")
	pync.dump()

# Generate prologue and epilogue
__prologue()
atexit.register(__epilogue)
