EESchema Schematic File Version 1
LIBS:power,./atmega8x,device,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,contrib,valves
EELAYER 23  0
EELAYER END
$Descr A4 11700 8267
Sheet 1 1
Title "ODIN Emergency Stop extension"
Date "15 jul 2009"
Rev "1"
Comp "Copyright (c) 2009 Michael Buesch"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	10450 1550 10350 1550
Wire Wire Line
	10350 1550 10350 1300
Wire Wire Line
	10350 1300 10450 1300
Wire Wire Line
	10100 1450 10100 1100
Wire Wire Line
	9250 2050 9350 2050
Wire Wire Line
	9800 1650 9250 1650
Wire Wire Line
	10100 2050 9850 2050
Connection ~ 3600 3850
Wire Wire Line
	3600 4250 3600 3850
Connection ~ 4000 4050
Wire Wire Line
	4000 4250 4000 4050
Wire Wire Line
	3800 4750 3800 4850
Wire Wire Line
	4300 3950 1100 3950
Wire Wire Line
	4200 4850 4200 4750
Wire Wire Line
	2100 5850 2200 5850
Wire Wire Line
	2200 5850 2200 4150
Wire Wire Line
	2200 4150 4300 4150
Wire Wire Line
	4300 4050 1100 4050
Wire Wire Line
	4000 4850 4000 4750
Wire Wire Line
	6700 3850 7350 3850
Wire Wire Line
	7350 4050 6850 4050
Connection ~ 9750 3550
Wire Wire Line
	9750 3700 9750 3550
Connection ~ 5800 2400
Wire Wire Line
	6050 2400 5400 2400
Wire Wire Line
	5400 2400 5400 2650
Wire Wire Line
	6450 2400 6550 2400
Wire Wire Line
	6850 4050 6850 6600
Wire Wire Line
	8150 4050 8250 4050
Wire Wire Line
	4950 6800 5050 6800
Wire Wire Line
	6250 6800 6250 7100
Connection ~ 6850 7100
Wire Wire Line
	6850 7200 6850 7000
Connection ~ 6850 5050
Wire Wire Line
	6850 5400 7000 5400
Wire Wire Line
	7600 5050 7500 5050
Connection ~ 5500 6050
Wire Wire Line
	5500 6050 5500 6150
Wire Wire Line
	5300 5850 5300 6050
Wire Wire Line
	5300 6050 9700 6050
Wire Wire Line
	9700 6050 9700 4900
Wire Wire Line
	9700 4900 10150 4900
Connection ~ 10000 3650
Wire Wire Line
	10000 3550 10000 4050
Connection ~ 10000 3850
Wire Wire Line
	10000 3750 10250 3750
Wire Wire Line
	10000 3950 10250 3950
Wire Wire Line
	10000 4050 10250 4050
Wire Wire Line
	10000 3850 10250 3850
Connection ~ 10000 3950
Wire Wire Line
	10000 3650 10250 3650
Connection ~ 10000 3750
Connection ~ 10000 3550
Wire Wire Line
	5700 5850 5700 6050
Connection ~ 5700 6050
Wire Wire Line
	7400 5400 7650 5400
Wire Wire Line
	7000 5050 6700 5050
Wire Wire Line
	6850 7100 6750 7100
Connection ~ 6850 5400
Wire Wire Line
	6000 6800 6550 6800
Connection ~ 6250 6800
Wire Wire Line
	5450 6800 5500 6800
Wire Wire Line
	8150 3850 8200 3850
Wire Wire Line
	8150 3950 8400 3950
Wire Wire Line
	8400 3950 8400 3650
Wire Wire Line
	8400 3650 7050 3650
Wire Wire Line
	7050 3650 7050 3750
Wire Wire Line
	5800 2400 5800 2650
Wire Wire Line
	5600 2300 5600 2400
Connection ~ 5600 2400
Wire Wire Line
	6700 3550 10250 3550
Wire Wire Line
	9750 4200 9750 4250
Wire Wire Line
	7350 3950 6700 3950
Wire Wire Line
	7050 3750 6700 3750
Wire Wire Line
	1000 5950 1100 5950
Wire Wire Line
	4200 4250 4200 4150
Connection ~ 4200 4150
Wire Wire Line
	1100 3850 4300 3850
Wire Wire Line
	3600 4750 3600 4850
Wire Wire Line
	3800 4250 3800 3950
Connection ~ 3800 3950
Wire Wire Line
	10100 2200 10100 1850
Connection ~ 10100 2050
Wire Wire Line
	9250 1650 9250 3450
Wire Wire Line
	9250 3450 6700 3450
Connection ~ 9250 2050
Wire Wire Line
	10100 1100 10450 1100
$Comp
L R R8
U 1 1 4A5E4F50
P 9600 2050
F 0 "R8" V 9680 2050 50  0000 C C
F 1 "4.7k" V 9600 2050 50  0000 C C
	1    9600 2050
	0    1    1    0   
$EndComp
$Comp
L MOS_N Q2
U 1 1 4A5E4F23
P 10000 1650
F 0 "Q2" H 10010 1820 60  0000 R C
F 1 "IRF530" H 10010 1500 60  0000 R C
	1    10000 1650
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR17
U 1 1 4A5E4DB2
P 10100 2200
F 0 "#PWR17" H 10100 2200 30  0001 C C
F 1 "GND" H 10100 2130 30  0001 C C
	1    10100 2200
	1    0    0    -1  
$EndComp
$Comp
L +12V #PWR16
U 1 1 4A5E4D7A
P 10450 1550
F 0 "#PWR16" H 10450 1500 20  0001 C C
F 1 "+12V" H 10450 1650 30  0000 C C
	1    10450 1550
	0    1    1    0   
$EndComp
Text Notes 11000 1750 1    40   ~
To Master Spindle relais
$Comp
L CONN_2 P2
U 1 1 4A5E4D52
P 10800 1200
F 0 "P2" V 10750 1200 40  0000 C C
F 1 "SPINDLE" V 10850 1200 40  0000 C C
	1    10800 1200
	1    0    0    -1  
$EndComp
Text Label 1150 3850 0    40   ~
Master Spindle ON from EMC2 (inverted logic)
Text Label 1150 3950 0    40   ~
E-STOP from EMC2
Text Label 1150 4050 0    40   ~
E-STOP to EMC2
$Comp
L +5V #PWR3
U 1 1 4A5E4C9A
P 3800 4850
F 0 "#PWR3" H 3800 4940 20  0001 C C
F 1 "+5V" H 3800 4940 30  0000 C C
	1    3800 4850
	-1   0    0    1   
$EndComp
$Comp
L +5V #PWR2
U 1 1 4A5E4C96
P 3600 4850
F 0 "#PWR2" H 3600 4940 20  0001 C C
F 1 "+5V" H 3600 4940 30  0000 C C
	1    3600 4850
	-1   0    0    1   
$EndComp
$Comp
L R R1
U 1 1 4A5E4C82
P 3600 4500
F 0 "R1" V 3680 4500 50  0000 C C
F 1 "1k" V 3600 4500 50  0000 C C
	1    3600 4500
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 4A5E4C7E
P 3800 4500
F 0 "R2" V 3880 4500 50  0000 C C
F 1 "1k" V 3800 4500 50  0000 C C
	1    3800 4500
	1    0    0    -1  
$EndComp
$Comp
L CONN_3 K1
U 1 1 4A5E4C44
P 750 3950
F 0 "K1" V 700 3950 50  0000 C C
F 1 "EMC2" V 800 3950 40  0000 C C
	1    750  3950
	-1   0    0    1   
$EndComp
Text Notes 1150 5650 0    40   ~
STOP
Text Notes 1150 6050 0    40   ~
RUN
Text Notes 750  6250 1    40   ~
User E-STOP pushbutton
$Comp
L +5V #PWR5
U 1 1 4A5E4854
P 4200 4850
F 0 "#PWR5" H 4200 4940 20  0001 C C
F 1 "+5V" H 4200 4940 30  0000 C C
	1    4200 4850
	-1   0    0    1   
$EndComp
$Comp
L R R4
U 1 1 4A5E4842
P 4200 4500
F 0 "R4" V 4280 4500 50  0000 C C
F 1 "1k" V 4200 4500 50  0000 C C
	1    4200 4500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR1
U 1 1 4A5E481B
P 1000 5950
F 0 "#PWR1" H 1000 5950 30  0001 C C
F 1 "GND" H 1000 5880 30  0001 C C
	1    1000 5950
	0    1    1    0   
$EndComp
NoConn ~ 1100 5750
$Comp
L SWITCH_INV SW1
U 1 1 4A5E47EF
P 1600 5850
F 0 "SW1" H 1400 6000 50  0000 C C
F 1 "E-STOP switch" H 1450 5700 50  0000 C C
	1    1600 5850
	-1   0    0    1   
$EndComp
NoConn ~ 4300 3750
NoConn ~ 4300 3650
NoConn ~ 4300 3550
NoConn ~ 4300 3450
$Comp
L +5V #PWR4
U 1 1 4A5E4744
P 4000 4850
F 0 "#PWR4" H 4000 4940 20  0001 C C
F 1 "+5V" H 4000 4940 30  0000 C C
	1    4000 4850
	-1   0    0    1   
$EndComp
$Comp
L R R3
U 1 1 4A5E4735
P 4000 4500
F 0 "R3" V 4080 4500 50  0000 C C
F 1 "1k" V 4000 4500 50  0000 C C
	1    4000 4500
	1    0    0    -1  
$EndComp
Text Notes 600  4700 1    40   ~
E-STOP and spindle control signal to/from EMC2 via parport
Text Notes 11000 6250 1    40   ~
Pulling pin10 of the LMD18245 high will short the motors.
$Comp
L +5V #PWR15
U 1 1 4A5E4391
P 9750 4250
F 0 "#PWR15" H 9750 4340 20  0001 C C
F 1 "+5V" H 9750 4340 30  0000 C C
	1    9750 4250
	-1   0    0    1   
$EndComp
$Comp
L R R9
U 1 1 4A5E4382
P 9750 3950
F 0 "R9" V 9830 3950 50  0000 C C
F 1 "1k" V 9750 3950 50  0000 C C
	1    9750 3950
	1    0    0    -1  
$EndComp
NoConn ~ 6700 3650
NoConn ~ 6700 4950
NoConn ~ 6700 4850
NoConn ~ 6700 4750
NoConn ~ 6700 4650
NoConn ~ 6700 4550
NoConn ~ 6700 4450
NoConn ~ 5200 2650
$Comp
L +5V #PWR8
U 1 1 4A5E40E2
P 5600 2300
F 0 "#PWR8" H 5600 2390 20  0001 C C
F 1 "+5V" H 5600 2390 30  0000 C C
	1    5600 2300
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR9
U 1 1 4A5E40D5
P 6550 2400
F 0 "#PWR9" H 6550 2400 30  0001 C C
F 1 "GND" H 6550 2330 30  0001 C C
	1    6550 2400
	0    -1   -1   0   
$EndComp
$Comp
L C C2
U 1 1 4A5E40BB
P 6250 2400
F 0 "C2" H 6300 2500 50  0000 L C
F 1 "10u" H 6300 2300 50  0000 L C
	1    6250 2400
	0    1    1    0   
$EndComp
$Comp
L GND #PWR14
U 1 1 4A5E404C
P 8250 4050
F 0 "#PWR14" H 8250 4050 30  0001 C C
F 1 "GND" H 8250 3980 30  0001 C C
	1    8250 4050
	0    -1   -1   0   
$EndComp
$Comp
L +5V #PWR13
U 1 1 4A5E4048
P 8200 3850
F 0 "#PWR13" H 8200 3940 20  0001 C C
F 1 "+5V" H 8200 3940 30  0000 C C
	1    8200 3850
	0    1    1    0   
$EndComp
NoConn ~ 6700 4150
NoConn ~ 6700 4050
$Comp
L CONN_3X2 P1
U 1 1 4A5E3FFD
P 7750 4000
F 0 "P1" H 7750 4250 50  0000 C C
F 1 "ISP" V 7750 4050 40  0000 C C
	1    7750 4000
	1    0    0    -1  
$EndComp
Text Notes 5400 7250 0    60   ~
Reset delay
$Comp
L +5V #PWR6
U 1 1 4A5E3FA1
P 4950 6800
F 0 "#PWR6" H 4950 6890 20  0001 C C
F 1 "+5V" H 4950 6890 30  0000 C C
	1    4950 6800
	0    -1   -1   0   
$EndComp
$Comp
L C C1
U 1 1 4A5E3F95
P 5250 6800
F 0 "C1" H 5300 6900 50  0000 L C
F 1 "100u" H 5300 6700 50  0000 L C
	1    5250 6800
	0    1    1    0   
$EndComp
$Comp
L R R5
U 1 1 4A5E3F7A
P 5750 6800
F 0 "R5" V 5830 6800 50  0000 C C
F 1 "4.7k" V 5750 6800 50  0000 C C
	1    5750 6800
	0    1    1    0   
$EndComp
$Comp
L GND #PWR10
U 1 1 4A5E3F3E
P 6850 7200
F 0 "#PWR10" H 6850 7200 30  0001 C C
F 1 "GND" H 6850 7130 30  0001 C C
	1    6850 7200
	1    0    0    -1  
$EndComp
$Comp
L R R6
U 1 1 4A5E3F29
P 6500 7100
F 0 "R6" V 6580 7100 50  0000 C C
F 1 "47k" V 6500 7100 50  0000 C C
	1    6500 7100
	0    1    1    0   
$EndComp
$Comp
L NPN Q1
U 1 1 4A5E3F1D
P 6750 6800
F 0 "Q1" H 6900 6800 50  0000 C C
F 1 "BC547C" H 6652 6950 50  0000 C C
	1    6750 6800
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR12
U 1 1 4A5E3EF8
P 7650 5400
F 0 "#PWR12" H 7650 5400 30  0001 C C
F 1 "GND" H 7650 5330 30  0001 C C
	1    7650 5400
	0    -1   -1   0   
$EndComp
$Comp
L +5V #PWR11
U 1 1 4A5E3EF3
P 7600 5050
F 0 "#PWR11" H 7600 5140 20  0001 C C
F 1 "+5V" H 7600 5140 30  0000 C C
	1    7600 5050
	0    1    1    0   
$EndComp
$Comp
L C C3
U 1 1 4A5E3EEA
P 7200 5400
F 0 "C3" H 7250 5500 50  0000 L C
F 1 "47p" H 7250 5300 50  0000 L C
	1    7200 5400
	0    1    1    0   
$EndComp
$Comp
L R R7
U 1 1 4A5E3EE3
P 7250 5050
F 0 "R7" V 7330 5050 50  0000 C C
F 1 "1k" V 7250 5050 50  0000 C C
	1    7250 5050
	0    1    1    0   
$EndComp
$Comp
L GND #PWR7
U 1 1 4A5E3EB3
P 5500 6150
F 0 "#PWR7" H 5500 6150 30  0001 C C
F 1 "GND" H 5500 6080 30  0001 C C
	1    5500 6150
	1    0    0    -1  
$EndComp
Text Notes 10300 5350 1    60   ~
ODIN board GND
$Comp
L GND #PWR18
U 1 1 4A5E3E4D
P 10150 4900
F 0 "#PWR18" H 10150 4900 30  0001 C C
F 1 "GND" H 10150 4830 30  0001 C C
	1    10150 4900
	0    -1   -1   0   
$EndComp
Text Notes 10850 6250 1    40   ~
To pin10 of each LMD18245 on each axis (3 axis, 2 LMDs each = 6 pins)
$Comp
L CONN_6 P3
U 1 1 4A5E3CF8
P 10600 3800
F 0 "P3" V 10550 3800 60  0000 C C
F 1 "XYZ BRAKE PIN10" V 10650 3800 60  0000 C C
	1    10600 3800
	1    0    0    -1  
$EndComp
$Comp
L ATMEGA8-16PI I1
U 1 1 4A5E3CD8
P 5500 4200
F 0 "I1" H 6200 5600 60  0000 C C
F 1 "ATMEGA8-16PI" H 6150 2750 60  0000 C C
	1    5500 4200
	1    0    0    -1  
$EndComp
$EndSCHEMATC
