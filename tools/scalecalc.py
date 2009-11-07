#!/usr/bin/env python
"""
# EMC2 stepper SCALE calculation helper
# Copyright (c) 2009 Michael Buesch <mb@bu3sch.de>
# Licensed under the GNU GPL version 2 or (at your option) any later version.
"""

import sys
import getopt

degree_per_fullstep = 1.8
units_per_rev = None
range_max = 30

def usage():
	print "Usage: %s [OPTIONS]" % sys.argv[0]
	print ""
	print "-u|--units-per-rev X        Use X units per revolution (mandatory)"
	print "-d|--deg-per-fullstep X     Use X degree per motor-fullstep (default 1.8)"
	print "-r|--range X                List scale values up to X microsteps (default 30)"
	print "-h|--help                   Print this help text"

try:
	(opts, args) = getopt.getopt(sys.argv[1:],
		"hu:d:r:",
		[ "help", "units-per-rev=", "deg-per-fullstep=",
		  "range=", ])
	for (o, v) in opts:
		if o in ("-h", "--help"):
			usage()
			sys.exit(0)
		if o in ("-u", "--units-per-rev"):
			units_per_rev = float(v)
		if o in ("-d", "--deg-per-fullstep"):
			degree_per_fullstep = float(v)
		if o in ("-r", "--range"):
			range_max = int(v)
	if units_per_rev is None:
		raise ValueError()
except (ValueError, getopt.GetoptError):
	usage()
	sys.exit(1)

for microsteps in range(1, range_max + 1):
  print "%d microsteps  =>  SCALE=%f" %\
    (microsteps,
     (float(microsteps) / float(degree_per_fullstep))
     * 360.0 * (1.0 / float(units_per_rev)))
