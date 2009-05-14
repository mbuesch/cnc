#!/bin/bash
#
# Convenient BRL-CAD to G-Code (RS274NGC) converter script
#
# Copyright (c) 2009 Michael Buesch <mb@bu3sch.de>
# Licensed under the GNU/GPL version 2 or later.
#


# Below you can define alternative paths to the conversion tools
# Default is to use the tool found in $PATH

# BRL-CAD G-to-VRML conversion tool
G2VRML="g-vrml"
# VRML to PGM conversion tool
MESH2HMAP="mesh2hmap"
# PGM to PNG conversion tool
PGM2PNG="pnmtopng"
# Image to GCODE conversion tool
IMAGE2GCODE="image-to-gcode"
# GNU bc calculator
BC="bc"

# Set to one, if using metric units. Set to zero, if using imperial units.
METRIC=1
# Resolution (in units; see above) for the mesh.
# You also need to specify this value in image-to-gcode as "Pixel size"!
MESH_RES="0.1"





tmp_prefix="/tmp/brlcad2gcode-$RANDOM"
log_file="$tmp_prefix.log"
vrml_file="$tmp_prefix.vrml"
pgm_file="$tmp_prefix.pgm"
png_file="$tmp_prefix.png"

if [ $METRIC -eq 0 ]; then
	UNITS="inch"
else
	UNITS="mm"
fi

function cleanup
{
	rm -f ${log_file}
	rm -f ${vrml_file}
	rm -f ${pgm_file}
	rm -f ${png_file}
}

# cleanup_and_exit(exit_code)
function cleanup_and_exit
{
	cleanup
	exit $1
}

function sigterm
{
	echo "Terminating."
	cleanup_and_exit 1
}

trap sigterm TERM INT

# check_tool(tool, args, expected_return_code, install_hint, debian_package)
function check_tool
{
	local tool="$1"
	local args="$2"
	local expected_return="$3"
	local install_hint="$4"
	local debian_package="$5"

	$tool $args > ${log_file} 2>&1
	res=$?
	if [ $res -ne $expected_return ]; then
		cat ${log_file}
		echo
		echo "ERROR: Failed to probe $tool"
		echo "Please install $install_hint"
		if [ -n "$debian_package" ]; then
			echo
			echo "If you are running Debian Linux, please run the"
			echo "following command (as root) to install the package:"
			echo " apt-get install $debian_package"
		fi
		cleanup_and_exit 1
	fi
}

check_tool $G2VRML --help		1 "'BRL-CAD' (http://brlcad.org/)"		""
check_tool $MESH2HMAP --help		0 "'mesh2hmap' (http://mesh2hmap.sf.net/)"	""
check_tool $PGM2PNG --help		1 "'netpbm' (http://netpbm.sf.net/)"		"netpbm"
check_tool $IMAGE2GCODE /dev/zero	1 "'EMC2' (http://linuxcnc.org/)"		""
check_tool $BC --help			0 "'GNU bc' (http://www.gnu.org/software/bc/)"	"bc"

function usage
{
	echo "BRL-CAD to GCODE (RS274NGC) converter"
	echo
	echo "Usage: $0 brlcad_db.g brlcad-db-object gcode.ngc"
}

if [ $# -ne 3 ]; then
	usage
	exit 1
fi
brlcad_g_file="$1"
brlcad_g_object="$2"
ngc_file="$3"
if ! [ -r "${brlcad_g_file}" ]; then
	echo "ERROR: Could not read input .g file ${brlcad_g_file}"
	exit 1
fi


# Convert the BRL-CAD database to VRML
echo "Converting BRL-CAD database object to VRML..."
$G2VRML ${brlcad_g_file} ${brlcad_g_object} > ${vrml_file}
res=$?
if [ $res -ne 0 ]; then
	echo "BRL-CAD to VRML conversion failed: $res"
	cleanup_and_exit 1
fi

# Convert the VRML file to a PGM image
r="$MESH_RES"
if [ $METRIC -eq 0 ]; then
	r=$(echo "scale=6; $r * 25.4" | bc)
fi
echo "Converting VRML to PGM image (Mesh resolution = $r mm)..."
$MESH2HMAP "--m-pix=$r" ${vrml_file} ${pgm_file} > ${log_file} 2>&1
res=$?
if [ $res -ne 0 ]; then
	cat ${log_file}
	echo "VRML to PGM conversion failed: $res"
	cleanup_and_exit 1
fi

# Convert the PGM image to a PNG image
echo "Converting PGM image to PNG image..."
$PGM2PNG ${pgm_file} > ${png_file}
res=$?
if [ $res -ne 0 ]; then
	echo "PGM to PNG conversion failed: $res"
	cleanup_and_exit 1
fi

# Convert PNG image to GCODE
echo "Converting PNG image to GCODE..."
echo; echo
echo "--- IMPORTANT ---"
echo "Please use $MESH_RES $UNITS as 'Pixel size' inside of the following dialog box."
echo "--- IMPORTANT ---"
echo; echo
$IMAGE2GCODE ${png_file} > ${ngc_file}
res=$?
if [ $res -ne 0 ]; then
	echo "PNG to GCODE conversion failed: $res"
	rm -f ${ngc_file}
	cleanup_and_exit 1
fi

# Done! :)
cleanup_and_exit 0
