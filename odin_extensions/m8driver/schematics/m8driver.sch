EESchema Schematic File Version 1
LIBS:power,./crystalosc,./atmega8x,device,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,contrib,valves,./m8driver.cache
EELAYER 23  0
EELAYER END
$Descr A4 11700 8267
Sheet 1 1
Title ""
Date "11 jul 2009"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
NoConn ~ 9950 4650
NoConn ~ 9250 5650
NoConn ~ 9250 5350
NoConn ~ 9250 5550
NoConn ~ 9250 5150
NoConn ~ 7000 4550
NoConn ~ 7000 4450
NoConn ~ 7000 4350
NoConn ~ 1850 4150
Text Notes 8450 4400 0    60   ~
FIXME additional external pullups?
Text Label 8850 4750 0    50   ~
DIR
Text Label 8850 4650 0    50   ~
CLK
Wire Wire Line
	2200 1800 2200 1950
Wire Wire Line
	7000 3450 8450 3450
Wire Wire Line
	8450 3450 8450 2700
Wire Wire Line
	8450 2700 10550 2700
Wire Wire Line
	10550 2700 10550 2400
Wire Wire Line
	10550 2400 10250 2400
Wire Wire Line
	10250 2500 10400 2500
Wire Wire Line
	7000 3650 8350 3650
Wire Wire Line
	8350 3650 8350 2400
Wire Wire Line
	8350 2400 9450 2400
Wire Wire Line
	7000 3750 9150 3750
Wire Wire Line
	5700 2250 5700 2350
Connection ~ 7100 5050
Wire Wire Line
	7200 5050 7100 5050
Wire Wire Line
	7700 4750 7750 4750
Wire Wire Line
	6800 6750 6300 6750
Wire Wire Line
	5200 6750 5300 6750
Wire Wire Line
	7100 6950 7100 7150
Wire Wire Line
	10550 3750 10650 3750
Wire Wire Line
	9100 5750 9250 5750
Wire Wire Line
	9250 4650 8450 4650
Wire Wire Line
	8450 4650 8450 4150
Wire Wire Line
	8450 4150 7000 4150
Wire Wire Line
	6000 5550 6000 5650
Wire Wire Line
	7000 3250 7600 3250
Wire Wire Line
	7600 3250 7600 1850
Wire Wire Line
	7600 1850 2950 1850
Wire Wire Line
	2550 3650 3750 3650
Wire Wire Line
	3750 3650 3750 3600
Wire Wire Line
	3750 3600 4050 3600
Wire Wire Line
	4050 3600 4050 3850
Wire Wire Line
	4050 3850 4600 3850
Wire Wire Line
	2550 3950 3850 3950
Wire Wire Line
	3850 3950 3850 3550
Wire Wire Line
	3850 3550 4600 3550
Wire Wire Line
	2550 3150 3250 3150
Wire Wire Line
	2550 3350 4600 3350
Wire Wire Line
	2550 3550 3350 3550
Wire Wire Line
	2550 3750 4600 3750
Wire Wire Line
	2950 1850 2950 4050
Wire Wire Line
	3350 3550 3350 3150
Wire Wire Line
	3350 3150 4600 3150
Wire Wire Line
	4600 3450 3250 3450
Wire Wire Line
	3250 3450 3250 3150
Wire Wire Line
	3050 3450 3050 1950
Wire Wire Line
	2950 4050 2550 4050
Wire Wire Line
	3050 3450 2550 3450
Wire Wire Line
	2550 3250 4600 3250
Wire Wire Line
	2550 3050 2650 3050
Wire Wire Line
	4600 3650 3950 3650
Wire Wire Line
	3950 3650 3950 3850
Wire Wire Line
	3950 3850 2550 3850
Wire Wire Line
	7000 3150 7500 3150
Wire Wire Line
	7500 3150 7500 1950
Wire Wire Line
	7500 1950 3050 1950
Wire Wire Line
	5600 5550 5600 5650
Wire Wire Line
	9250 4750 8350 4750
Wire Wire Line
	8350 4750 8350 4250
Wire Wire Line
	8350 4250 7000 4250
Wire Wire Line
	9050 3450 9150 3450
Wire Wire Line
	7100 4750 7100 6550
Wire Wire Line
	7050 7000 7100 7000
Connection ~ 7100 7000
Wire Wire Line
	5700 6750 5800 6750
Wire Wire Line
	6550 7000 6550 6750
Connection ~ 6550 6750
Wire Wire Line
	7200 4750 7000 4750
Connection ~ 7100 4750
Wire Wire Line
	7600 5050 7800 5050
Wire Wire Line
	6100 2250 6100 2350
Wire Wire Line
	9450 2300 8250 2300
Wire Wire Line
	8250 2300 8250 3550
Wire Wire Line
	8250 3550 7000 3550
Wire Wire Line
	9450 2500 9450 2850
Wire Wire Line
	9450 2850 11000 2850
Wire Wire Line
	11000 2850 11000 6250
Wire Wire Line
	11000 6250 7100 6250
Connection ~ 7100 6250
Wire Wire Line
	10250 2300 10350 2300
Wire Wire Line
	2200 1300 2200 1400
$Comp
L GND #PWR3
U 1 1 4A579F9C
P 2200 1950
F 0 "#PWR3" H 2200 1950 30  0001 C C
F 1 "GND" H 2200 1880 30  0001 C C
	1    2200 1950
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR2
U 1 1 4A579F96
P 2200 1300
F 0 "#PWR2" H 2200 1390 20  0001 C C
F 1 "+5V" H 2200 1390 30  0000 C C
	1    2200 1300
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 4A579F7A
P 2200 1600
F 0 "C1" H 2250 1700 50  0000 L C
F 1 "10u" H 2250 1500 50  0000 L C
	1    2200 1600
	-1   0    0    1   
$EndComp
NoConn ~ 7000 3350
$Comp
L GND #PWR17
U 1 1 4A579F03
P 10400 2500
F 0 "#PWR17" H 10400 2500 30  0001 C C
F 1 "GND" H 10400 2430 30  0001 C C
	1    10400 2500
	0    -1   -1   0   
$EndComp
$Comp
L +5V #PWR16
U 1 1 4A579EFF
P 10350 2300
F 0 "#PWR16" H 10350 2390 20  0001 C C
F 1 "+5V" H 10350 2390 30  0000 C C
	1    10350 2300
	0    1    1    0   
$EndComp
$Comp
L CONN_3X2 P3
U 1 1 4A579EA6
P 9850 2450
F 0 "P3" H 9850 2700 50  0000 C C
F 1 "ISP" V 9850 2500 40  0000 C C
	1    9850 2450
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR9
U 1 1 4A579E71
P 6100 2250
F 0 "#PWR9" H 6100 2340 20  0001 C C
F 1 "+5V" H 6100 2340 30  0000 C C
	1    6100 2250
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR7
U 1 1 4A579E6C
P 5700 2250
F 0 "#PWR7" H 5700 2340 20  0001 C C
F 1 "+5V" H 5700 2340 30  0000 C C
	1    5700 2250
	1    0    0    -1  
$EndComp
NoConn ~ 5500 2350
Text Notes 5750 7150 0    50   ~
Reset delay
$Comp
L GND #PWR12
U 1 1 4A579E12
P 7800 5050
F 0 "#PWR12" H 7800 5050 30  0001 C C
F 1 "GND" H 7800 4980 30  0001 C C
	1    7800 5050
	0    -1   -1   0   
$EndComp
$Comp
L C C3
U 1 1 4A579DFE
P 7400 5050
F 0 "C3" H 7450 5150 50  0000 L C
F 1 "47p" H 7450 4950 50  0000 L C
	1    7400 5050
	0    1    1    0   
$EndComp
$Comp
L +5V #PWR11
U 1 1 4A579DEF
P 7750 4750
F 0 "#PWR11" H 7750 4840 20  0001 C C
F 1 "+5V" H 7750 4840 30  0000 C C
	1    7750 4750
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 4A579DE6
P 7450 4750
F 0 "R3" V 7530 4750 50  0000 C C
F 1 "1k" V 7450 4750 50  0000 C C
	1    7450 4750
	0    1    1    0   
$EndComp
$Comp
L +5V #PWR5
U 1 1 4A579DC1
P 5200 6750
F 0 "#PWR5" H 5200 6840 20  0001 C C
F 1 "+5V" H 5200 6840 30  0000 C C
	1    5200 6750
	0    -1   -1   0   
$EndComp
$Comp
L C C2
U 1 1 4A579DB1
P 5500 6750
F 0 "C2" H 5550 6850 50  0000 L C
F 1 "100u" H 5550 6650 50  0000 L C
	1    5500 6750
	0    1    1    0   
$EndComp
$Comp
L R R1
U 1 1 4A579DA2
P 6050 6750
F 0 "R1" V 6130 6750 50  0000 C C
F 1 "4.7k" V 6050 6750 50  0000 C C
	1    6050 6750
	0    1    1    0   
$EndComp
$Comp
L GND #PWR10
U 1 1 4A579D83
P 7100 7150
F 0 "#PWR10" H 7100 7150 30  0001 C C
F 1 "GND" H 7100 7080 30  0001 C C
	1    7100 7150
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 4A579D6E
P 6800 7000
F 0 "R2" V 6880 7000 50  0000 C C
F 1 "47k" V 6800 7000 50  0000 C C
	1    6800 7000
	0    1    1    0   
$EndComp
$Comp
L NPN Q1
U 1 1 4A579D47
P 7000 6750
F 0 "Q1" H 7150 6750 50  0000 C C
F 1 "BC547C" H 6902 6900 50  0000 C C
	1    7000 6750
	1    0    0    -1  
$EndComp
NoConn ~ 10550 3450
$Comp
L +5V #PWR18
U 1 1 4A579CDF
P 10650 3750
F 0 "#PWR18" H 10650 3840 20  0001 C C
F 1 "+5V" H 10650 3840 30  0000 C C
	1    10650 3750
	0    1    1    0   
$EndComp
$Comp
L GND #PWR13
U 1 1 4A579CDA
P 9050 3450
F 0 "#PWR13" H 9050 3450 30  0001 C C
F 1 "GND" H 9050 3380 30  0001 C C
	1    9050 3450
	0    1    1    0   
$EndComp
NoConn ~ 7000 3850
NoConn ~ 9250 5450
NoConn ~ 9250 5250
NoConn ~ 9250 5050
NoConn ~ 9250 4950
NoConn ~ 9250 4850
$Comp
L GND #PWR14
U 1 1 4A579CA0
P 9100 5750
F 0 "#PWR14" H 9100 5750 30  0001 C C
F 1 "GND" H 9100 5680 30  0001 C C
	1    9100 5750
	0    1    1    0   
$EndComp
NoConn ~ 9950 5750
NoConn ~ 9950 5650
NoConn ~ 9950 5550
NoConn ~ 9950 5450
NoConn ~ 9950 5250
NoConn ~ 9950 5350
NoConn ~ 9950 5150
NoConn ~ 9950 5050
NoConn ~ 9950 4950
NoConn ~ 9950 4850
NoConn ~ 9950 4750
$Comp
L GND #PWR6
U 1 1 4A579BDB
P 5600 5650
F 0 "#PWR6" H 5600 5650 30  0001 C C
F 1 "GND" H 5600 5580 30  0001 C C
	1    5600 5650
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR8
U 1 1 4A579BD7
P 6000 5650
F 0 "#PWR8" H 6000 5650 30  0001 C C
F 1 "GND" H 6000 5580 30  0001 C C
	1    6000 5650
	1    0    0    -1  
$EndComp
Text Label 7050 3250 0    50   ~
LMD2_DIR
Text Label 7050 3150 0    50   ~
LMD1_DIR
Text Label 4100 3850 0    50   ~
LMD2_M4
Text Label 4100 3750 0    50   ~
LMD2_M3
Text Label 4100 3650 0    50   ~
LMD2_M2
Text Label 4100 3550 0    50   ~
LMD2_M1
Text Label 4100 3450 0    50   ~
LMD1_M4
Text Label 4100 3350 0    50   ~
LMD1_M3
Text Label 4100 3250 0    50   ~
LMD1_M2
Text Label 4100 3150 0    50   ~
LMD1_M1
NoConn ~ 2550 4150
$Comp
L +5V #PWR4
U 1 1 4A579AC8
P 2650 3050
F 0 "#PWR4" H 2650 3140 20  0001 C C
F 1 "+5V" H 2650 3140 30  0000 C C
	1    2650 3050
	0    1    1    0   
$EndComp
NoConn ~ 1850 4050
NoConn ~ 1850 3950
NoConn ~ 1850 3850
NoConn ~ 1850 3750
NoConn ~ 1850 3650
NoConn ~ 1850 3550
NoConn ~ 1850 3450
NoConn ~ 1850 3350
NoConn ~ 1850 3250
NoConn ~ 1850 3150
NoConn ~ 1850 3050
$Comp
L DIL24 P1
U 1 1 4A5798D7
P 2200 3600
F 0 "P1" H 2200 4350 70  0000 C C
F 1 "CHIP2 SOCKET (to LMD)" H 2200 2850 70  0000 C C
	1    2200 3600
	1    0    0    -1  
$EndComp
$Comp
L DIL24 P2
U 1 1 4A5798D3
P 9600 5200
F 0 "P2" H 9600 5950 70  0000 C C
F 1 "CHIP1 SOCKET (from parport)" H 9600 4450 70  0000 C C
	1    9600 5200
	1    0    0    -1  
$EndComp
$Comp
L CRYSTALOSC X1
U 1 1 4A579707
P 9850 3600
F 0 "X1" H 9850 3300 60  0000 C C
F 1 "16MHz OSC" H 9850 3600 60  0000 C C
	1    9850 3600
	-1   0    0    1   
$EndComp
$Comp
L ATMEGA8-16PI I1
U 1 1 4A5796FB
P 5800 3900
F 0 "I1" H 6500 5300 60  0000 C C
F 1 "ATMEGA8-16PI" H 6450 2450 60  0000 C C
	1    5800 3900
	1    0    0    -1  
$EndComp
$EndSCHEMATC