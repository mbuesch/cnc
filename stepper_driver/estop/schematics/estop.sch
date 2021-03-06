EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "CNC stepper driver Emergency Stop"
Date "2020-01-04"
Rev "1"
Comp "Copyright (c) 2009-2020 Michael Buesch"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Label 1150 3750 0    40   ~ 0
Charge pump signal from EMC2
Wire Wire Line
	4300 3750 3400 3750
Connection ~ 9250 2050
Wire Wire Line
	6700 3450 9250 3450
Wire Wire Line
	9250 3450 9250 2050
Connection ~ 10100 2050
Wire Wire Line
	10100 2200 10100 2050
Connection ~ 3800 3950
Wire Wire Line
	1100 3850 3600 3850
Connection ~ 4200 4150
Wire Wire Line
	6700 3550 9750 3550
Connection ~ 5600 2400
Wire Wire Line
	5600 2300 5600 2400
Wire Wire Line
	5800 2400 5800 2650
Wire Wire Line
	7250 4600 7200 4600
Connection ~ 5500 6850
Connection ~ 6850 5400
Connection ~ 5700 6050
Wire Wire Line
	5700 5850 5700 6050
Connection ~ 10000 3550
Connection ~ 10000 3750
Wire Wire Line
	10000 3650 10250 3650
Connection ~ 10000 3950
Wire Wire Line
	10000 3850 10250 3850
Wire Wire Line
	10250 4050 10000 4050
Wire Wire Line
	10000 3950 10250 3950
Wire Wire Line
	10000 3750 10250 3750
Connection ~ 10000 3850
Wire Wire Line
	10000 4050 10000 3950
Connection ~ 10000 3650
Wire Wire Line
	10150 4900 9700 4900
Wire Wire Line
	9700 4900 9700 6050
Wire Wire Line
	9700 6050 5700 6050
Wire Wire Line
	5300 6050 5300 5850
Wire Wire Line
	5500 6050 5500 6150
Connection ~ 5500 6050
Connection ~ 6850 5050
Wire Wire Line
	6100 7250 6100 7150
Connection ~ 6100 7150
Wire Wire Line
	5500 6850 5500 7150
Wire Wire Line
	8150 4600 8250 4600
Wire Wire Line
	5400 2650 5400 2400
Wire Wire Line
	5400 2400 5600 2400
Connection ~ 5800 2400
Connection ~ 9750 3550
Wire Wire Line
	4300 4050 4000 4050
Wire Wire Line
	4300 4150 4200 4150
Wire Wire Line
	2200 4150 2200 5850
Wire Wire Line
	4300 3950 3800 3950
Connection ~ 4000 4050
Connection ~ 3600 3850
Wire Wire Line
	9250 1650 9800 1650
Wire Wire Line
	10450 1300 10350 1300
Wire Wire Line
	10350 1300 10350 1550
Wire Wire Line
	10350 1550 10450 1550
Connection ~ 3400 3750
$Comp
L power:+5V #PWR02
U 1 1 4A6B03B5
P 3400 4850
F 0 "#PWR02" H 3400 4940 20  0001 C CNN
F 1 "+5V" H 3400 5000 30  0000 C CNN
F 2 "" H 3400 4850 50  0001 C CNN
F 3 "" H 3400 4850 50  0001 C CNN
	1    3400 4850
	-1   0    0    1   
$EndComp
$Comp
L Device:R R1
U 1 1 4A6B0397
P 3400 4500
F 0 "R1" V 3480 4500 50  0000 C CNN
F 1 "1k" V 3400 4500 50  0000 C CNN
F 2 "" H 3400 4500 50  0001 C CNN
F 3 "" H 3400 4500 50  0001 C CNN
	1    3400 4500
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x04_Female P1
U 1 1 4A6B0361
P 900 3950
F 0 "P1" V 950 3900 50  0000 C CNN
F 1 "EMC2" V 1050 3900 50  0000 C CNN
F 2 "" H 900 3950 50  0001 C CNN
F 3 "" H 900 3950 50  0001 C CNN
	1    900  3950
	-1   0    0    1   
$EndComp
$Comp
L Device:R R9
U 1 1 4A5E4F50
P 9600 2050
F 0 "R9" V 9680 2050 50  0000 C CNN
F 1 "4.7k" V 9600 2050 50  0000 C CNN
F 2 "" H 9600 2050 50  0001 C CNN
F 3 "" H 9600 2050 50  0001 C CNN
	1    9600 2050
	0    1    1    0   
$EndComp
$Comp
L Transistor_FET:IRF540N Q2
U 1 1 4A5E4F23
P 10000 1650
F 0 "Q2" H 9900 1850 60  0000 C CNN
F 1 "IRF530" H 9800 1500 60  0000 C CNN
F 2 "" H 10000 1650 50  0001 C CNN
F 3 "" H 10000 1650 50  0001 C CNN
	1    10000 1650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR017
U 1 1 4A5E4DB2
P 10100 2200
F 0 "#PWR017" H 10100 2200 30  0001 C CNN
F 1 "GND" H 10100 2130 30  0001 C CNN
F 2 "" H 10100 2200 50  0001 C CNN
F 3 "" H 10100 2200 50  0001 C CNN
	1    10100 2200
	1    0    0    -1  
$EndComp
$Comp
L power:+12V #PWR019
U 1 1 4A5E4D7A
P 10450 1550
F 0 "#PWR019" H 10450 1500 20  0001 C CNN
F 1 "+12V" H 10450 1700 30  0000 C CNN
F 2 "" H 10450 1550 50  0001 C CNN
F 3 "" H 10450 1550 50  0001 C CNN
	1    10450 1550
	0    1    1    0   
$EndComp
Text Notes 11000 1600 1    40   ~ 0
To Master Spindle relais
$Comp
L Connector:Conn_01x02_Female P4
U 1 1 4A5E4D52
P 10650 1200
F 0 "P4" V 10700 1150 40  0000 C CNN
F 1 "SPINDLE" V 10800 1150 40  0000 C CNN
F 2 "" H 10650 1200 50  0001 C CNN
F 3 "" H 10650 1200 50  0001 C CNN
	1    10650 1200
	1    0    0    -1  
$EndComp
Text Label 1150 3850 0    40   ~ 0
Master Spindle ON from EMC2 (inverted logic)
Text Label 1150 3950 0    40   ~ 0
E-STOP from EMC2
Text Label 1150 4050 0    40   ~ 0
E-STOP to EMC2
$Comp
L power:+5V #PWR04
U 1 1 4A5E4C9A
P 3800 4850
F 0 "#PWR04" H 3800 4940 20  0001 C CNN
F 1 "+5V" H 3800 5000 30  0000 C CNN
F 2 "" H 3800 4850 50  0001 C CNN
F 3 "" H 3800 4850 50  0001 C CNN
	1    3800 4850
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR03
U 1 1 4A5E4C96
P 3600 4850
F 0 "#PWR03" H 3600 4940 20  0001 C CNN
F 1 "+5V" H 3600 5000 30  0000 C CNN
F 2 "" H 3600 4850 50  0001 C CNN
F 3 "" H 3600 4850 50  0001 C CNN
	1    3600 4850
	-1   0    0    1   
$EndComp
$Comp
L Device:R R2
U 1 1 4A5E4C82
P 3600 4500
F 0 "R2" V 3680 4500 50  0000 C CNN
F 1 "1k" V 3600 4500 50  0000 C CNN
F 2 "" H 3600 4500 50  0001 C CNN
F 3 "" H 3600 4500 50  0001 C CNN
	1    3600 4500
	1    0    0    -1  
$EndComp
$Comp
L Device:R R3
U 1 1 4A5E4C7E
P 3800 4500
F 0 "R3" V 3880 4500 50  0000 C CNN
F 1 "1k" V 3800 4500 50  0000 C CNN
F 2 "" H 3800 4500 50  0001 C CNN
F 3 "" H 3800 4500 50  0001 C CNN
	1    3800 4500
	1    0    0    -1  
$EndComp
Text Notes 1150 5750 0    40   ~ 0
STOP
Text Notes 1150 5950 0    40   ~ 0
RUN
Text Notes 750  6250 1    40   ~ 0
User E-STOP pushbutton
$Comp
L power:+5V #PWR06
U 1 1 4A5E4854
P 4200 4850
F 0 "#PWR06" H 4200 4940 20  0001 C CNN
F 1 "+5V" H 4200 5000 30  0000 C CNN
F 2 "" H 4200 4850 50  0001 C CNN
F 3 "" H 4200 4850 50  0001 C CNN
	1    4200 4850
	-1   0    0    1   
$EndComp
$Comp
L Device:R R5
U 1 1 4A5E4842
P 4200 4500
F 0 "R5" V 4280 4500 50  0000 C CNN
F 1 "1k" V 4200 4500 50  0000 C CNN
F 2 "" H 4200 4500 50  0001 C CNN
F 3 "" H 4200 4500 50  0001 C CNN
	1    4200 4500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR01
U 1 1 4A5E481B
P 1000 5950
F 0 "#PWR01" H 1000 5950 30  0001 C CNN
F 1 "GND" H 1000 5880 30  0001 C CNN
F 2 "" H 1000 5950 50  0001 C CNN
F 3 "" H 1000 5950 50  0001 C CNN
	1    1000 5950
	0    1    1    0   
$EndComp
NoConn ~ 1400 5750
$Comp
L Switch:SW_SPDT SW1
U 1 1 4A5E47EF
P 1600 5850
F 0 "SW1" H 1400 6000 50  0000 C CNN
F 1 "E-STOP switch" H 1600 6150 50  0000 C CNN
F 2 "" H 1600 5850 50  0001 C CNN
F 3 "" H 1600 5850 50  0001 C CNN
	1    1600 5850
	-1   0    0    1   
$EndComp
NoConn ~ 4300 3650
NoConn ~ 4300 3550
NoConn ~ 4300 3450
$Comp
L power:+5V #PWR05
U 1 1 4A5E4744
P 4000 4850
F 0 "#PWR05" H 4000 4940 20  0001 C CNN
F 1 "+5V" H 4000 5000 30  0000 C CNN
F 2 "" H 4000 4850 50  0001 C CNN
F 3 "" H 4000 4850 50  0001 C CNN
	1    4000 4850
	-1   0    0    1   
$EndComp
$Comp
L Device:R R4
U 1 1 4A5E4735
P 4000 4500
F 0 "R4" V 4080 4500 50  0000 C CNN
F 1 "1k" V 4000 4500 50  0000 C CNN
F 2 "" H 4000 4500 50  0001 C CNN
F 3 "" H 4000 4500 50  0001 C CNN
	1    4000 4500
	1    0    0    -1  
$EndComp
Text Notes 650  4700 1    40   ~ 0
E-STOP and spindle control signal to/from EMC2 via parport
Text Notes 11000 5050 1    40   ~ 0
Pulling pin10 of the LMD18245 high will short the motors.
$Comp
L power:+5V #PWR016
U 1 1 4A5E4391
P 9750 4250
F 0 "#PWR016" H 9750 4340 20  0001 C CNN
F 1 "+5V" H 9750 4400 30  0000 C CNN
F 2 "" H 9750 4250 50  0001 C CNN
F 3 "" H 9750 4250 50  0001 C CNN
	1    9750 4250
	-1   0    0    1   
$EndComp
$Comp
L Device:R R10
U 1 1 4A5E4382
P 9750 3950
F 0 "R10" V 9830 3950 50  0000 C CNN
F 1 "1k" V 9750 3950 50  0000 C CNN
F 2 "" H 9750 3950 50  0001 C CNN
F 3 "" H 9750 3950 50  0001 C CNN
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
L power:+5V #PWR09
U 1 1 4A5E40E2
P 5600 2300
F 0 "#PWR09" H 5600 2390 20  0001 C CNN
F 1 "+5V" H 5600 2450 30  0000 C CNN
F 2 "" H 5600 2300 50  0001 C CNN
F 3 "" H 5600 2300 50  0001 C CNN
	1    5600 2300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR010
U 1 1 4A5E40D5
P 6550 2400
F 0 "#PWR010" H 6550 2400 30  0001 C CNN
F 1 "GND" H 6550 2330 30  0001 C CNN
F 2 "" H 6550 2400 50  0001 C CNN
F 3 "" H 6550 2400 50  0001 C CNN
	1    6550 2400
	0    -1   -1   0   
$EndComp
$Comp
L Device:CP C2
U 1 1 4A5E40BB
P 6250 2400
F 0 "C2" H 6350 2500 50  0000 C CNN
F 1 "10u" H 6350 2300 50  0000 C CNN
F 2 "" H 6250 2400 50  0001 C CNN
F 3 "" H 6250 2400 50  0001 C CNN
	1    6250 2400
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR015
U 1 1 4A5E404C
P 8250 4600
F 0 "#PWR015" H 8250 4600 30  0001 C CNN
F 1 "GND" H 8250 4530 30  0001 C CNN
F 2 "" H 8250 4600 50  0001 C CNN
F 3 "" H 8250 4600 50  0001 C CNN
	1    8250 4600
	0    -1   -1   0   
$EndComp
$Comp
L power:+5V #PWR014
U 1 1 4A5E4048
P 7200 4600
F 0 "#PWR014" H 7200 4690 20  0001 C CNN
F 1 "+5V" H 7200 4750 30  0000 C CNN
F 2 "" H 7200 4600 50  0001 C CNN
F 3 "" H 7200 4600 50  0001 C CNN
	1    7200 4600
	0    -1   -1   0   
$EndComp
NoConn ~ 6700 4150
NoConn ~ 6700 4050
$Comp
L Connector:AVR-ISP-6 P2
U 1 1 4A5E3FFD
P 7750 4500
F 0 "P2" H 7750 4750 50  0000 C CNN
F 1 "ISP" V 7750 4550 40  0000 C CNN
F 2 "" H 7750 4500 50  0001 C CNN
F 3 "" H 7750 4500 50  0001 C CNN
	1    7750 4500
	0    -1   -1   0   
$EndComp
Text Notes 4650 7300 0    60   ~ 0
Reset delay
$Comp
L power:+5V #PWR07
U 1 1 4A5E3FA1
P 4200 6850
F 0 "#PWR07" H 4200 6940 20  0001 C CNN
F 1 "+5V" H 4200 7000 30  0000 C CNN
F 2 "" H 4200 6850 50  0001 C CNN
F 3 "" H 4200 6850 50  0001 C CNN
	1    4200 6850
	0    -1   -1   0   
$EndComp
$Comp
L Device:CP C1
U 1 1 4A5E3F95
P 4500 6850
F 0 "C1" H 4600 6950 50  0000 C CNN
F 1 "100u" H 4650 6750 50  0000 C CNN
F 2 "" H 4500 6850 50  0001 C CNN
F 3 "" H 4500 6850 50  0001 C CNN
	1    4500 6850
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R6
U 1 1 4A5E3F7A
P 5000 6850
F 0 "R6" V 5080 6850 50  0000 C CNN
F 1 "4.7k" V 5000 6850 50  0000 C CNN
F 2 "" H 5000 6850 50  0001 C CNN
F 3 "" H 5000 6850 50  0001 C CNN
	1    5000 6850
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR011
U 1 1 4A5E3F3E
P 6100 7250
F 0 "#PWR011" H 6100 7250 30  0001 C CNN
F 1 "GND" H 6100 7180 30  0001 C CNN
F 2 "" H 6100 7250 50  0001 C CNN
F 3 "" H 6100 7250 50  0001 C CNN
	1    6100 7250
	1    0    0    -1  
$EndComp
$Comp
L Device:R R7
U 1 1 4A5E3F29
P 5750 7150
F 0 "R7" V 5830 7150 50  0000 C CNN
F 1 "47k" V 5750 7150 50  0000 C CNN
F 2 "" H 5750 7150 50  0001 C CNN
F 3 "" H 5750 7150 50  0001 C CNN
	1    5750 7150
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR013
U 1 1 4A5E3EF8
P 7650 5400
F 0 "#PWR013" H 7650 5400 30  0001 C CNN
F 1 "GND" H 7650 5330 30  0001 C CNN
F 2 "" H 7650 5400 50  0001 C CNN
F 3 "" H 7650 5400 50  0001 C CNN
	1    7650 5400
	0    -1   -1   0   
$EndComp
$Comp
L power:+5V #PWR012
U 1 1 4A5E3EF3
P 7600 5050
F 0 "#PWR012" H 7600 5140 20  0001 C CNN
F 1 "+5V" H 7600 5200 30  0000 C CNN
F 2 "" H 7600 5050 50  0001 C CNN
F 3 "" H 7600 5050 50  0001 C CNN
	1    7600 5050
	0    1    1    0   
$EndComp
$Comp
L Device:C C3
U 1 1 4A5E3EEA
P 7200 5400
F 0 "C3" H 7300 5500 50  0000 C CNN
F 1 "47p" H 7300 5300 50  0000 C CNN
F 2 "" H 7200 5400 50  0001 C CNN
F 3 "" H 7200 5400 50  0001 C CNN
	1    7200 5400
	0    1    1    0   
$EndComp
$Comp
L Device:R R8
U 1 1 4A5E3EE3
P 7250 5050
F 0 "R8" V 7330 5050 50  0000 C CNN
F 1 "1k" V 7250 5050 50  0000 C CNN
F 2 "" H 7250 5050 50  0001 C CNN
F 3 "" H 7250 5050 50  0001 C CNN
	1    7250 5050
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR08
U 1 1 4A5E3EB3
P 5500 6150
F 0 "#PWR08" H 5500 6150 30  0001 C CNN
F 1 "GND" H 5500 6080 30  0001 C CNN
F 2 "" H 5500 6150 50  0001 C CNN
F 3 "" H 5500 6150 50  0001 C CNN
	1    5500 6150
	1    0    0    -1  
$EndComp
Text Notes 10450 5150 1    60   ~ 0
LMD18245\nboard GND
$Comp
L power:GND #PWR018
U 1 1 4A5E3E4D
P 10150 4900
F 0 "#PWR018" H 10150 4900 30  0001 C CNN
F 1 "GND" H 10150 4830 30  0001 C CNN
F 2 "" H 10150 4900 50  0001 C CNN
F 3 "" H 10150 4900 50  0001 C CNN
	1    10150 4900
	0    -1   -1   0   
$EndComp
Text Notes 10900 5050 1    40   ~ 0
To pin10 of each LMD18245 on each axis (3 axis, 2 LMDs each = 6 pins)
$Comp
L Connector:Conn_01x06_Female P3
U 1 1 4A5E3CF8
P 10450 3750
F 0 "P3" V 10550 3700 60  0000 C CNN
F 1 "XYZ BRAKE PIN10" V 10650 3700 60  0000 C CNN
F 2 "" H 10450 3750 50  0001 C CNN
F 3 "" H 10450 3750 50  0001 C CNN
	1    10450 3750
	1    0    0    -1  
$EndComp
$Comp
L atmega8x:ATMEGA8-16PI I1
U 1 1 4A5E3CD8
P 5500 4200
F 0 "I1" H 6200 5600 60  0000 C CNN
F 1 "ATMEGA8-16PI" H 6150 2750 60  0000 C CNN
F 2 "" H 5500 4200 50  0001 C CNN
F 3 "" H 5500 4200 50  0001 C CNN
	1    5500 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	9250 2050 9250 1650
Wire Wire Line
	10100 2050 10100 1850
Wire Wire Line
	3800 3950 1100 3950
Wire Wire Line
	4200 4150 2200 4150
Wire Wire Line
	5600 2400 5800 2400
Wire Wire Line
	5500 6850 5800 6850
Wire Wire Line
	6850 5400 6850 5050
Wire Wire Line
	5700 6050 5500 6050
Wire Wire Line
	10000 3550 10250 3550
Wire Wire Line
	10000 3750 10000 3650
Wire Wire Line
	10000 3950 10000 3850
Wire Wire Line
	10000 3850 10000 3750
Wire Wire Line
	10000 3650 10000 3550
Wire Wire Line
	5500 6050 5300 6050
Wire Wire Line
	6850 5050 6700 5050
Wire Wire Line
	6100 7150 6100 7050
Wire Wire Line
	9750 3550 10000 3550
Wire Wire Line
	4000 4050 1100 4050
Wire Wire Line
	3600 3850 4300 3850
Wire Wire Line
	3400 3750 1100 3750
Wire Wire Line
	9750 3550 9750 3800
Wire Wire Line
	9750 4100 9750 4250
Wire Wire Line
	3400 3750 3400 4350
Wire Wire Line
	3600 3850 3600 4350
Wire Wire Line
	3800 3950 3800 4350
Wire Wire Line
	4000 4050 4000 4350
Wire Wire Line
	4200 4150 4200 4350
Wire Wire Line
	4200 4650 4200 4850
Wire Wire Line
	4000 4650 4000 4850
Wire Wire Line
	3800 4650 3800 4850
Wire Wire Line
	3600 4650 3600 4850
Wire Wire Line
	3400 4650 3400 4850
Wire Wire Line
	5800 2400 6100 2400
Wire Wire Line
	6400 2400 6550 2400
Wire Wire Line
	10450 1200 10100 1200
Wire Wire Line
	10100 1200 10100 1450
Wire Wire Line
	9250 2050 9450 2050
Wire Wire Line
	9750 2050 10100 2050
Wire Wire Line
	6850 5050 7100 5050
Wire Wire Line
	7400 5050 7600 5050
Wire Wire Line
	6850 5400 7050 5400
Wire Wire Line
	7350 5400 7650 5400
Wire Wire Line
	6850 5750 8550 5750
Wire Wire Line
	8550 5750 8550 4000
Wire Wire Line
	8550 4000 7850 4000
Wire Wire Line
	7850 4000 7850 4100
Wire Wire Line
	6850 5750 6850 5400
Wire Wire Line
	7750 3950 7750 4100
Wire Wire Line
	6700 3950 7750 3950
Wire Wire Line
	7550 3850 7550 4100
Wire Wire Line
	6700 3850 7550 3850
Wire Wire Line
	7650 4100 7650 3750
Wire Wire Line
	6700 3750 7650 3750
Wire Wire Line
	1000 5950 1400 5950
Wire Wire Line
	1800 5850 2200 5850
Wire Wire Line
	4200 6850 4350 6850
Wire Wire Line
	4650 6850 4850 6850
Wire Wire Line
	5150 6850 5500 6850
Wire Wire Line
	5500 7150 5600 7150
Wire Wire Line
	5900 7150 6100 7150
$Comp
L Transistor_BJT:BC547 Q1
U 1 1 4A5E3F1D
P 6000 6850
F 0 "Q1" H 6150 6850 50  0000 C CNN
F 1 "BC547C" H 5902 7000 50  0000 C CNN
F 2 "" H 6000 6850 50  0001 C CNN
F 3 "" H 6000 6850 50  0001 C CNN
	1    6000 6850
	1    0    0    -1  
$EndComp
Wire Wire Line
	6850 5750 6850 6250
Wire Wire Line
	6850 6250 6100 6250
Wire Wire Line
	6100 6250 6100 6650
Connection ~ 6850 5750
$Comp
L Device:C C4
U 1 1 5E1E0CF0
P 6250 2050
F 0 "C4" V 5998 2050 50  0000 C CNN
F 1 "100n" V 6089 2050 50  0000 C CNN
F 2 "" H 6288 1900 50  0001 C CNN
F 3 "~" H 6250 2050 50  0001 C CNN
	1    6250 2050
	0    1    1    0   
$EndComp
Wire Wire Line
	6100 2050 5800 2050
Wire Wire Line
	5800 2050 5800 2400
$Comp
L power:GND #PWR020
U 1 1 5E1E4160
P 6550 2050
F 0 "#PWR020" H 6550 2050 30  0001 C CNN
F 1 "GND" H 6550 1980 30  0001 C CNN
F 2 "" H 6550 2050 50  0001 C CNN
F 3 "" H 6550 2050 50  0001 C CNN
	1    6550 2050
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6400 2050 6550 2050
$EndSCHEMATC
