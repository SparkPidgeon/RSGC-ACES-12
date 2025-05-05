;Library of ADC-related equates for the ATmega328P
;------------------------------------------------------------------
; ADC (Chapter 24)  Voltage Reference Selection for the ADC
.equ    ADCVREF   , 0<<REFS1 | 0<<REFS0  ;AREF, Interval Vref turned off
.equ    ADCAVCC   , 0<<REFS1 | 1<<REFS0  ;AVcc, ext. capacitor at AREF pin
.equ    ADCRSVD   , 1<<REFS1 | 0<<REFS0  ;Reserved
.equ    ADCINTR   , 1<<REFS1 | 1<<REFS0  ;Interval 1.1V Voltage Reference 
;------------------------------------------------------------------
; ADC (Chapter 24)  Recommended ADC run between 50k and 200k
.equ    ADCps2    , 0<<ADPS2 | 0<<ADPS1 | 1<<ADPS0  ;Division Factor 2 
.equ    ADCps4    , 0<<ADPS2 | 1<<ADPS1 | 0<<ADPS0  ;Division Factor 4 
.equ    ADCps8    , 0<<ADPS2 | 1<<ADPS1 | 1<<ADPS0  ;Division Factor 8 
.equ    ADCps16   , 1<<ADPS2 | 0<<ADPS1 | 0<<ADPS0  ;Division Factor 16 
.equ    ADCps32   , 1<<ADPS2 | 0<<ADPS1 | 1<<ADPS0  ;Division Factor 32
.equ    ADCps64   , 1<<ADPS2 | 1<<ADPS1 | 0<<ADPS0  ;Division Factor 64
.equ    ADCps128  , 1<<ADPS2 | 1<<ADPS1 | 0<<ADPS0  ;Division Factor 128
;------------------------------------------------------------------
; ADC (Chapter 24)  Trigger Source
.equ    ADCtsFR   , 0<<ADTS2 | 0<<ADTS1 | 0<<ADTS0  ;Free Running Mode
.equ    ADCtsAC   , 0<<ADTS2 | 0<<ADTS1 | 1<<ADTS0  ;Analog Comparator
.equ    ADCtsEI   , 0<<ADTS2 | 1<<ADTS1 | 0<<ADTS0  ;Ext. Int. Request 0
.equ    ADCtsT0CM , 0<<ADTS2 | 1<<ADTS1 | 1<<ADTS0  ;TCounter0 Comp Match A
.equ    ADCtsT0OVF, 1<<ADTS2 | 0<<ADTS1 | 0<<ADTS0  ;TCounter0 Overflow
.equ    ADCtsT1CM , 1<<ADTS2 | 0<<ADTS1 | 1<<ADTS0  ;TCounter1 Comp Match A
.equ    ADCtsT1OVF, 1<<ADTS2 | 1<<ADTS1 | 0<<ADTS0  ;TCounter1 Overflow
.equ    ADCtsT1CAP, 1<<ADTS2 | 1<<ADTS1 | 1<<ADTS0  ;TCounter1 Capt. Event
;------------------------------------------------------------------
; ADC (Chapter 24)  Single-Ended Input
.equ    ADC0      , 0<<MUX3  | 0<<MUX2  | 0<<MUX1  | 0<<MUX0  ;
.equ    ADC1      , 0<<MUX3  | 0<<MUX2  | 0<<MUX1  | 1<<MUX0  ;
.equ    ADC2      , 0<<MUX3  | 0<<MUX2  | 1<<MUX1  | 0<<MUX0  ;
.equ    ADC3      , 0<<MUX3  | 0<<MUX2  | 1<<MUX1  | 1<<MUX0  ;
.equ    ADC4      , 0<<MUX3  | 1<<MUX2  | 0<<MUX1  | 0<<MUX0  ;
.equ    ADC5      , 0<<MUX3  | 1<<MUX2  | 0<<MUX1  | 1<<MUX0  ;
.equ    ADC6      , 0<<MUX3  | 1<<MUX2  | 1<<MUX1  | 0<<MUX0  ;
.equ    ADC7      , 0<<MUX3  | 1<<MUX2  | 1<<MUX1  | 1<<MUX0  ;
.equ    ADC8      , 1<<MUX3  | 0<<MUX2  | 0<<MUX1  | 0<<MUX0  ; Temp.Sensor
.equ    ADC1V     , 1<<MUX3  | 1<<MUX2  | 1<<MUX1  | 0<<MUX0  ; 1.1V 
.equ    ADCGND    , 1<<MUX3  | 1<<MUX2  | 1<<MUX1  | 1<<MUX0  ; 0V (GND)
