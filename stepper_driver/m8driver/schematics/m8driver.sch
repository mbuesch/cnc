EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Atmel Mega8 based driver for LMD18245"
Date "2020-01-04"
Rev "1"
Comp "Copyright (c) 2009-2020 Michael Buesch"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Connection ~ 9300 3750
Wire Wire Line
	9000 1350 8850 1350
Wire Wire Line
	6600 3400 7950 3400
Wire Wire Line
	7950 3400 7950 2150
Wire Wire Line
	5300 2000 5300 2100
Connection ~ 6700 4800
Wire Wire Line
	9650 4750 9800 4750
Wire Wire Line
	9800 3650 9100 3650
Wire Wire Line
	5600 5300 5600 5400
Wire Wire Line
	6600 3000 7200 3000
Wire Wire Line
	7200 3000 7200 1600
Wire Wire Line
	7200 1600 2550 1600
Wire Wire Line
	2150 3400 3350 3400
Wire Wire Line
	3350 3400 3350 3350
Wire Wire Line
	3350 3350 3650 3350
Wire Wire Line
	3650 3350 3650 3600
Wire Wire Line
	3650 3600 4200 3600
Wire Wire Line
	2150 3700 3450 3700
Wire Wire Line
	3450 3700 3450 3300
Wire Wire Line
	3450 3300 4200 3300
Wire Wire Line
	2150 2900 2850 2900
Wire Wire Line
	2150 3100 4200 3100
Wire Wire Line
	2150 3300 2950 3300
Wire Wire Line
	2150 3500 4200 3500
Wire Wire Line
	2550 1600 2550 3800
Wire Wire Line
	2950 3300 2950 2900
Wire Wire Line
	2950 2900 4200 2900
Wire Wire Line
	4200 3200 2850 3200
Wire Wire Line
	2850 3200 2850 2900
Wire Wire Line
	2650 3200 2650 1700
Wire Wire Line
	2550 3800 2150 3800
Wire Wire Line
	2650 3200 2150 3200
Wire Wire Line
	2150 3000 4200 3000
Wire Wire Line
	2150 2800 2250 2800
Wire Wire Line
	4200 3400 3550 3400
Wire Wire Line
	3550 3400 3550 3600
Wire Wire Line
	3550 3600 2150 3600
Wire Wire Line
	6600 2900 7100 2900
Wire Wire Line
	7100 2900 7100 1700
Wire Wire Line
	7100 1700 2650 1700
Wire Wire Line
	5200 5300 5200 5400
Wire Wire Line
	9800 3750 9300 3750
Wire Wire Line
	6700 4500 6700 4800
Connection ~ 6700 4500
Wire Wire Line
	5700 2000 5700 2100
Wire Wire Line
	7850 2050 7850 3300
Wire Wire Line
	7850 3300 6600 3300
Wire Wire Line
	9900 1350 10000 1350
Connection ~ 9100 3650
$Comp
L power:+5V #PWR013
U 1 1 4A5A3DD8
P 9300 4400
F 0 "#PWR013" H 9300 4490 20  0001 C CNN
F 1 "+5V" H 9300 4490 30  0000 C CNN
F 2 "" H 9300 4400 50  0001 C CNN
F 3 "" H 9300 4400 50  0001 C CNN
	1    9300 4400
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR012
U 1 1 4A5A3DD2
P 9100 4400
F 0 "#PWR012" H 9100 4490 20  0001 C CNN
F 1 "+5V" H 9100 4490 30  0000 C CNN
F 2 "" H 9100 4400 50  0001 C CNN
F 3 "" H 9100 4400 50  0001 C CNN
	1    9100 4400
	-1   0    0    1   
$EndComp
$Comp
L Device:R R4
U 1 1 4A5A3DC1
P 9100 4100
F 0 "R4" V 9180 4100 50  0000 C CNN
F 1 "1k" V 9100 4100 50  0000 C CNN
F 2 "" H 9100 4100 50  0001 C CNN
F 3 "" H 9100 4100 50  0001 C CNN
	1    9100 4100
	1    0    0    -1  
$EndComp
$Comp
L Device:R R5
U 1 1 4A5A3DBB
P 9300 4100
F 0 "R5" V 9380 4100 50  0000 C CNN
F 1 "1k" V 9300 4100 50  0000 C CNN
F 2 "" H 9300 4100 50  0001 C CNN
F 3 "" H 9300 4100 50  0001 C CNN
	1    9300 4100
	1    0    0    -1  
$EndComp
NoConn ~ 9800 4650
NoConn ~ 9800 4350
NoConn ~ 9800 4550
NoConn ~ 9800 4150
NoConn ~ 6600 4300
NoConn ~ 6600 4200
NoConn ~ 6600 4100
Text Label 9400 3750 0    50   ~ 0
DIR
Text Label 9400 3650 0    50   ~ 0
CLK
$Comp
L power:GND #PWR02
U 1 1 4A579F9C
P 1150 1600
F 0 "#PWR02" H 1150 1600 30  0001 C CNN
F 1 "GND" H 1150 1530 30  0001 C CNN
F 2 "" H 1150 1600 50  0001 C CNN
F 3 "" H 1150 1600 50  0001 C CNN
	1    1150 1600
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR01
U 1 1 4A579F96
P 1150 950
F 0 "#PWR01" H 1150 1040 20  0001 C CNN
F 1 "+5V" H 1150 1040 30  0000 C CNN
F 2 "" H 1150 950 50  0001 C CNN
F 3 "" H 1150 950 50  0001 C CNN
	1    1150 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C1
U 1 1 4A579F7A
P 1150 1250
F 0 "C1" H 1200 1350 50  0000 C CNN
F 1 "10u" H 1200 1150 50  0000 C CNN
F 2 "" H 1150 1250 50  0001 C CNN
F 3 "" H 1150 1250 50  0001 C CNN
	1    1150 1250
	1    0    0    -1  
$EndComp
NoConn ~ 6600 3100
$Comp
L power:GND #PWR017
U 1 1 4A579F03
P 8850 1350
F 0 "#PWR017" H 8850 1350 30  0001 C CNN
F 1 "GND" H 8850 1280 30  0001 C CNN
F 2 "" H 8850 1350 50  0001 C CNN
F 3 "" H 8850 1350 50  0001 C CNN
	1    8850 1350
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR016
U 1 1 4A579EFF
P 10000 1350
F 0 "#PWR016" H 10000 1440 20  0001 C CNN
F 1 "+5V" H 10000 1440 30  0000 C CNN
F 2 "" H 10000 1350 50  0001 C CNN
F 3 "" H 10000 1350 50  0001 C CNN
	1    10000 1350
	0    1    1    0   
$EndComp
$Comp
L Connector:AVR-ISP-6 P3
U 1 1 4A579EA6
P 9400 1450
F 0 "P3" H 9400 1700 50  0000 C CNN
F 1 "ISP" V 9400 1500 40  0000 C CNN
F 2 "" H 9400 1450 50  0001 C CNN
F 3 "" H 9400 1450 50  0001 C CNN
	1    9400 1450
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR08
U 1 1 4A579E71
P 5700 2000
F 0 "#PWR08" H 5700 2090 20  0001 C CNN
F 1 "+5V" H 5700 2090 30  0000 C CNN
F 2 "" H 5700 2000 50  0001 C CNN
F 3 "" H 5700 2000 50  0001 C CNN
	1    5700 2000
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR06
U 1 1 4A579E6C
P 5300 2000
F 0 "#PWR06" H 5300 2090 20  0001 C CNN
F 1 "+5V" H 5300 2090 30  0000 C CNN
F 2 "" H 5300 2000 50  0001 C CNN
F 3 "" H 5300 2000 50  0001 C CNN
	1    5300 2000
	1    0    0    -1  
$EndComp
NoConn ~ 5100 2100
$Comp
L power:GND #PWR011
U 1 1 4A579E12
P 7400 4800
F 0 "#PWR011" H 7400 4800 30  0001 C CNN
F 1 "GND" H 7400 4730 30  0001 C CNN
F 2 "" H 7400 4800 50  0001 C CNN
F 3 "" H 7400 4800 50  0001 C CNN
	1    7400 4800
	0    -1   -1   0   
$EndComp
$Comp
L Device:C C3
U 1 1 4A579DFE
P 7000 4800
F 0 "C3" H 7050 4900 50  0000 C CNN
F 1 "47p" H 7050 4700 50  0000 C CNN
F 2 "" H 7000 4800 50  0001 C CNN
F 3 "" H 7000 4800 50  0001 C CNN
	1    7000 4800
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR010
U 1 1 4A579DEF
P 7350 4500
F 0 "#PWR010" H 7350 4590 20  0001 C CNN
F 1 "+5V" H 7350 4590 30  0000 C CNN
F 2 "" H 7350 4500 50  0001 C CNN
F 3 "" H 7350 4500 50  0001 C CNN
	1    7350 4500
	0    1    1    0   
$EndComp
$Comp
L Device:R R3
U 1 1 4A579DE6
P 7050 4500
F 0 "R3" V 7130 4500 50  0000 C CNN
F 1 "1k" V 7050 4500 50  0000 C CNN
F 2 "" H 7050 4500 50  0001 C CNN
F 3 "" H 7050 4500 50  0001 C CNN
	1    7050 4500
	0    1    1    0   
$EndComp
NoConn ~ 6600 3600
NoConn ~ 9800 4450
NoConn ~ 9800 4250
NoConn ~ 9800 4050
NoConn ~ 9800 3950
NoConn ~ 9800 3850
$Comp
L power:GND #PWR015
U 1 1 4A579CA0
P 9650 4750
F 0 "#PWR015" H 9650 4750 30  0001 C CNN
F 1 "GND" H 9650 4680 30  0001 C CNN
F 2 "" H 9650 4750 50  0001 C CNN
F 3 "" H 9650 4750 50  0001 C CNN
	1    9650 4750
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR05
U 1 1 4A579BDB
P 5200 5400
F 0 "#PWR05" H 5200 5400 30  0001 C CNN
F 1 "GND" H 5200 5330 30  0001 C CNN
F 2 "" H 5200 5400 50  0001 C CNN
F 3 "" H 5200 5400 50  0001 C CNN
	1    5200 5400
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR07
U 1 1 4A579BD7
P 5600 5400
F 0 "#PWR07" H 5600 5400 30  0001 C CNN
F 1 "GND" H 5600 5330 30  0001 C CNN
F 2 "" H 5600 5400 50  0001 C CNN
F 3 "" H 5600 5400 50  0001 C CNN
	1    5600 5400
	1    0    0    -1  
$EndComp
Text Label 6650 3000 0    50   ~ 0
LMD2_DIR
Text Label 6650 2900 0    50   ~ 0
LMD1_DIR
Text Label 3700 3600 0    50   ~ 0
LMD2_M4
Text Label 3700 3500 0    50   ~ 0
LMD2_M3
Text Label 3700 3400 0    50   ~ 0
LMD2_M2
Text Label 3700 3300 0    50   ~ 0
LMD2_M1
Text Label 3700 3200 0    50   ~ 0
LMD1_M4
Text Label 3700 3100 0    50   ~ 0
LMD1_M3
Text Label 3700 3000 0    50   ~ 0
LMD1_M2
Text Label 3700 2900 0    50   ~ 0
LMD1_M1
NoConn ~ 2150 3900
$Comp
L power:+5V #PWR03
U 1 1 4A579AC8
P 2250 2800
F 0 "#PWR03" H 2250 2890 20  0001 C CNN
F 1 "+5V" H 2250 2890 30  0000 C CNN
F 2 "" H 2250 2800 50  0001 C CNN
F 3 "" H 2250 2800 50  0001 C CNN
	1    2250 2800
	0    1    1    0   
$EndComp
$Comp
L Connector:Conn_01x24_Female P1
U 1 1 4A5798D7
P 1950 4000
F 0 "P1" H 1850 5250 70  0000 C CNN
F 1 "CHIP2 SOCKET (to LMD)" H 1850 5400 70  0000 C CNN
F 2 "" H 1950 4000 50  0001 C CNN
F 3 "" H 1950 4000 50  0001 C CNN
	1    1950 4000
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x24_Female P2
U 1 1 4A5798D3
P 10000 4750
F 0 "P2" H 9900 3450 70  0000 C CNN
F 1 "CHIP1 SOCKET (from parport)" H 9900 3300 70  0000 C CNN
F 2 "" H 10000 4750 50  0001 C CNN
F 3 "" H 10000 4750 50  0001 C CNN
	1    10000 4750
	1    0    0    -1  
$EndComp
$Comp
L atmega8x:ATMEGA8-16PI I1
U 1 1 4A5796FB
P 5400 3650
F 0 "I1" H 6100 5050 60  0000 C CNN
F 1 "ATMEGA8-16PI" H 6050 2200 60  0000 C CNN
F 2 "" H 5400 3650 50  0001 C CNN
F 3 "" H 5400 3650 50  0001 C CNN
	1    5400 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	6700 4800 6700 5100
Wire Wire Line
	6700 4500 6600 4500
Wire Wire Line
	1150 950  1150 1100
Wire Wire Line
	1150 1400 1150 1600
$Comp
L power:GND #PWR09
U 1 1 5E11A49F
P 1500 1600
F 0 "#PWR09" H 1500 1600 30  0001 C CNN
F 1 "GND" H 1500 1530 30  0001 C CNN
F 2 "" H 1500 1600 50  0001 C CNN
F 3 "" H 1500 1600 50  0001 C CNN
	1    1500 1600
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR04
U 1 1 5E11A4A9
P 1500 950
F 0 "#PWR04" H 1500 1040 20  0001 C CNN
F 1 "+5V" H 1500 1040 30  0000 C CNN
F 2 "" H 1500 950 50  0001 C CNN
F 3 "" H 1500 950 50  0001 C CNN
	1    1500 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:C C2
U 1 1 5E11A4B3
P 1500 1250
F 0 "C2" H 1550 1350 50  0000 C CNN
F 1 "100n" H 1550 1150 50  0000 C CNN
F 2 "" H 1500 1250 50  0001 C CNN
F 3 "" H 1500 1250 50  0001 C CNN
	1    1500 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	1500 950  1500 1100
Wire Wire Line
	1500 1400 1500 1600
Wire Wire Line
	6700 4500 6900 4500
Wire Wire Line
	7200 4500 7350 4500
Wire Wire Line
	6700 4800 6850 4800
Wire Wire Line
	7150 4800 7400 4800
Wire Wire Line
	9100 3650 9100 3950
Wire Wire Line
	9100 4250 9100 4400
Wire Wire Line
	9300 4250 9300 4400
Wire Wire Line
	9300 3750 9300 3950
Wire Wire Line
	7950 2150 9400 2150
Wire Wire Line
	9400 1850 9400 2150
Wire Wire Line
	7850 2050 9600 2050
Wire Wire Line
	9600 2050 9600 1850
Wire Wire Line
	8050 2250 9500 2250
Wire Wire Line
	9500 2250 9500 1850
Wire Wire Line
	8050 2250 8050 3200
$Comp
L Connector:Conn_01x01_Female J1
U 1 1 5E166A15
P 7450 4250
F 0 "J1" H 7478 4276 50  0000 L CNN
F 1 "DEBUG" H 7478 4185 50  0000 L CNN
F 2 "" H 7450 4250 50  0001 C CNN
F 3 "~" H 7450 4250 50  0001 C CNN
	1    7450 4250
	1    0    0    -1  
$EndComp
Wire Wire Line
	6600 4400 6700 4400
Wire Wire Line
	6700 4400 6700 4250
NoConn ~ 2150 4000
NoConn ~ 2150 4100
NoConn ~ 2150 4200
NoConn ~ 2150 4300
NoConn ~ 2150 4400
NoConn ~ 2150 4500
NoConn ~ 2150 4600
NoConn ~ 2150 4700
NoConn ~ 2150 4800
NoConn ~ 2150 4900
NoConn ~ 2150 5000
NoConn ~ 2150 5100
Wire Wire Line
	6600 3200 8050 3200
$Comp
L crystalosc:CRYSTALOSC X1
U 1 1 4A579707
P 9550 3050
F 0 "X1" H 9550 2750 60  0000 C CNN
F 1 "16MHz OSC" H 9550 3050 60  0000 C CNN
F 2 "" H 9550 3050 50  0001 C CNN
F 3 "" H 9550 3050 50  0001 C CNN
	1    9550 3050
	-1   0    0    1   
$EndComp
$Comp
L power:GND #PWR014
U 1 1 4A579CDA
P 8750 2900
F 0 "#PWR014" H 8750 2900 30  0001 C CNN
F 1 "GND" H 8750 2830 30  0001 C CNN
F 2 "" H 8750 2900 50  0001 C CNN
F 3 "" H 8750 2900 50  0001 C CNN
	1    8750 2900
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR018
U 1 1 4A579CDF
P 10350 3200
F 0 "#PWR018" H 10350 3290 20  0001 C CNN
F 1 "+5V" H 10350 3290 30  0000 C CNN
F 2 "" H 10350 3200 50  0001 C CNN
F 3 "" H 10350 3200 50  0001 C CNN
	1    10350 3200
	0    1    1    0   
$EndComp
NoConn ~ 10250 2900
Wire Wire Line
	8750 2900 8850 2900
Wire Wire Line
	10250 3200 10350 3200
Wire Wire Line
	6600 3500 8700 3500
Wire Wire Line
	8700 3500 8700 3200
Wire Wire Line
	8700 3200 8850 3200
Wire Wire Line
	9300 1850 9300 1950
Wire Wire Line
	9300 1950 7750 1950
Wire Wire Line
	7750 1950 7750 5100
Wire Wire Line
	7750 5100 6700 5100
NoConn ~ 9800 4850
NoConn ~ 9800 4950
NoConn ~ 9800 5050
NoConn ~ 9800 5150
NoConn ~ 9800 5250
NoConn ~ 9800 5350
NoConn ~ 9800 5450
NoConn ~ 9800 5550
NoConn ~ 9800 5650
NoConn ~ 9800 5750
NoConn ~ 9800 5850
NoConn ~ 9800 5950
Wire Wire Line
	8400 3900 8400 3650
Wire Wire Line
	6600 3900 8400 3900
Wire Wire Line
	8400 3650 9100 3650
Wire Wire Line
	8500 3750 8500 4000
Wire Wire Line
	6600 4000 8500 4000
Wire Wire Line
	8500 3750 9300 3750
Wire Wire Line
	6700 4250 7250 4250
$EndSCHEMATC
