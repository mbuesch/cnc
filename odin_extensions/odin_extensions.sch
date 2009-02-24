EESchema Schematic File Version 2
LIBS:power,device,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,contrib,valves
EELAYER 43  0
EELAYER END
$Descr A4 11700 8267
Sheet 1 1
Title "Extensions to the ODIN stepper motor control board"
Date "24 feb 2009"
Rev "1"
Comp "Copyright (c) 2009 Michael Buesch <mb@bu3sch.de>"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 2400 3300 0    40   ~
(The static GND connection trace of the 6 break pins is interrupted)
Text Notes 4900 4850 0    50   ~
switch closed => normal operation
Text Notes 4900 4750 0    50   ~
switch open => E-stop active
Connection ~ 6650 4450
Wire Wire Line
	7950 4450 6250 4450
Wire Wire Line
	3400 3950 5050 3950
Wire Wire Line
	6650 4450 6650 3950
Wire Wire Line
	6650 3950 5550 3950
Wire Wire Line
	3400 3450 6650 3450
Wire Wire Line
	3400 4450 5250 4450
Text Label 7200 4450 0    50   ~
E-stop signal
$Comp
L CONN_1 P4
U 1 1 49A43FA5
P 8100 4450
F 0 "P4" H 8180 4450 40  0000 L C
F 1 "CONN_1" H 8100 4505 30  0001 C C
	1    8100 4450
	1    0    0    -1  
$EndComp
Text Label 3450 4450 0    50   ~
LMD18245 GND
Text Label 3450 3950 0    50   ~
LMD18245 +5Vcc
Text Label 3450 3450 0    50   ~
6x LMD18245 BRAKE pins
$Comp
L SPST SW1
U 1 1 49A43EBE
P 5750 4450
F 0 "SW1" H 5750 4550 70  0000 C C
F 1 "EXTERNAL EMERGENCY STOP" H 5750 4350 70  0000 C C
	1    5750 4450
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 49A43DE1
P 5300 3950
F 0 "R1" V 5380 3950 50  0000 C C
F 1 "10k" V 5300 3950 50  0000 C C
	1    5300 3950
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 49A43DCC
P 6650 3700
F 0 "R2" V 6730 3700 50  0000 C C
F 1 "47" V 6650 3700 50  0000 C C
	1    6650 3700
	1    0    0    -1  
$EndComp
$Comp
L CONN_1 P3
U 1 1 49A43DA8
P 3250 4450
F 0 "P3" H 3330 4450 40  0000 L C
F 1 "CONN_1" H 3250 4505 30  0001 C C
	1    3250 4450
	-1   0    0    1   
$EndComp
$Comp
L CONN_1 P2
U 1 1 49A43DA3
P 3250 3950
F 0 "P2" H 3330 3950 40  0000 L C
F 1 "CONN_1" H 3250 4005 30  0001 C C
	1    3250 3950
	-1   0    0    1   
$EndComp
$Comp
L CONN_1 P1
U 1 1 49A43D65
P 3250 3450
F 0 "P1" H 3330 3450 40  0000 L C
F 1 "CONN_1" H 3250 3505 30  0001 C C
	1    3250 3450
	-1   0    0    1   
$EndComp
$EndSCHEMATC
