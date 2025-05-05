// PROJECT  : DoubleDabble Assembly
// PURPOSE  : Read analog value from A5 and output it to Serial Monitor (0-1023)
// COURSE   : ICS4U-E
// AUTHOR   : Lucas Quintas - Tang
// DATE     : 05/04/2025
// MCU      : ATmega328P
// STATUS   : Working (LED blink and leading 2 zeros removed)

#include <avr/io.h>
#include "Timer1prescalers.h"
#include "ADCprescalers.h"

.global main
.global TIMER1_OVF_vect
.global ADC_vect

.equ plHI, 0xF9        ; Timer1 preload high byte to update every 0.1 s
.equ plLO, 0xB6        ; Timer1 preload low byte

; Register alias
util   = 16            ; General utility register
offset = 23            ; Register to hold ASCII '0' offset

.org 0x00
  jmp main             ; Reset vector

.org 0x1A
  jmp TIMER1_OVF_vect  ; Timer1 overflow interrupt vector

.org 0x2A
  jmp ADC_vect         ; ADC complete interrupt vector

.org _VECTORS_SIZE
.org 0x100

; --- Main Setup ---
main:
  rcall IOSetup          ; Configure I/O pins
  rcall TIMER1Setup      ; Configure Timer1 for regular overflow
  rcall ADCSetup         ; Set up ADC on A5 to auto-trigger from Timer1
  rcall USARTSetup       ; Initialize UART at 9600 baud
  sei                    ; Enable global interrupts
loop:
  rjmp loop              ; Infinite loop

ret                      ; (Unreachable return for safety)

; --- USART Setup: 9600 baud, 8-bit, no parity ---
USARTSetup:
  ldi util, hi8(103)               ; Set high byte of baud rate (103 for 9600 @ 16MHz)
  sts UBRR0H, util
  ldi util, lo8(103)               ; Set low byte of baud rate
  sts UBRR0L, util
  ldi util, (1<<RXEN0)|(1<<TXEN0)  ; Enable UART receiver and transmitter
  sts UCSR0B, util
  ldi util, (1<<UCSZ01)|(1<<UCSZ00); Set data frame: 8-bit
  sts UCSR0C, util
  ret

; --- I/O Setup: LED on PB5 as output (not used here anymore) ---
IOSetup:
  sbi DDRB-0x20, DDB5     ; Set PB5 (Arduino pin 13) as output
  ret

; --- Timer1 Setup: Overflow every ~1 second ---
TIMER1Setup:
  clr util                ; Clear TCCR1A (normal mode)
  sts TCCR1A, util
  ldi util, T1ps1024      ; Set prescaler to 1024
  sts TCCR1B, util
  ldi util, plHI          ; Preload high byte
  sts TCNT1H, util
  ldi util, plLO          ; Preload low byte
  sts TCNT1L, util
  ldi util, (1<<TOIE1)    ; Enable Timer1 overflow interrupt
  sts TIMSK1, util
  ret

; --- ADC Setup: ADC5 input, auto-triggered by Timer1 overflow ---
ADCSetup:
  ser util                        ; Set all bits to 1
  sts DIDR0, util                 ; Disable digital input on all ADC pins

  ldi util, ADCAVCC | ADC5       ; Use AVCC as ref, select ADC5 (A5)
  sts ADMUX, util

  ldi util, (1<<ADEN) | ADCps128 ; Enable ADC, set prescaler
  ori util, (1<<ADSC)            ; Start first conversion
  sts ADCSRA, util

waitADC:
  lds util, ADCSRA               ; Wait for conversion complete
  sbrs util, ADIF
  rjmp waitADC

  lds util, ADCSRA
  ori util, (1<<ADIF)            ; Clear interrupt flag
  ori util, (1<<ADATE)          ; Enable auto trigger
  sts ADCSRA, util

  ldi util, ADCtsT1OVF           ; Auto trigger source: Timer1 Overflow
  sts ADCSRB, util

  lds util, ADCSRA
  ori util, (1<<ADIE)            ; Enable ADC interrupt
  sts ADCSRA, util
  ret

; --- Timer1 Overflow ISR: Reload timer ---
TIMER1_OVF_vect:
  ldi util, plHI          ; Reload Timer1 high byte
  sts TCNT1H, util
  ldi util, plLO          ; Reload Timer1 low byte
  sts TCNT1L, util
  reti

; --- ADC Complete ISR: Convert and display result ---
ADC_vect:
  lds R18, ADCL           ; Load low byte of ADC result
  lds R19, ADCH           ; Load high byte of ADC result
  andi R19, 0x03          ; Mask top bits (keep only 10-bit ADC value)

  clr R20                 ; Clear BCD result bytes
  clr R21
  clr R22

  rcall doubleDabble      ; Convert binary to BCD format
  rcall display           ; Send result via UART

  ; Removed LED toggle: sbi PINB-0x20, PINB5

  reti

; --- Double Dabble: Convert 10-bit binary to 6-digit BCD ---
doubleDabble:
  ldi R25, 16             ; 16-bit shift loop (10-bit value into BCD)

dd_loop:
  ; --- BCD correction on each nibble ---

  ; R22
  mov R24, R22
  swap R24
  andi R24, 0x0F
  cpi R24, 5
  brlo skip_adj22h
  subi R22, -0x30         ; Add 3 << 4
skip_adj22h:
  mov R24, R22
  andi R24, 0x0F
  cpi R24, 5
  brlo skip_adj22l
  subi R22, -0x03         ; Add 3
skip_adj22l:

  ; R21
  mov R24, R21
  swap R24
  andi R24, 0x0F
  cpi R24, 5
  brlo skip_adj21h
  subi R21, -0x30
skip_adj21h:
  mov R24, R21
  andi R24, 0x0F
  cpi R24, 5
  brlo skip_adj21l
  subi R21, -0x03
skip_adj21l:

  ; R20
  mov R24, R20
  swap R24
  andi R24, 0x0F
  cpi R24, 5
  brlo skip_adj20h
  subi R20, -0x30
skip_adj20h:
  mov R24, R20
  andi R24, 0x0F
  cpi R24, 5
  brlo skip_adj20l
  subi R20, -0x03
skip_adj20l:

  ; --- Shift binary value into BCD registers ---
  lsl R18                ; Shift left LSB of ADC value
  rol R19                ; Rotate into MSB
  rol R20                ; Rotate into BCD LSB
  rol R21
  rol R22

  dec R25
  brne dd_loop           ; Repeat for all bits
  ret

; --- Display BCD result via UART (skip leading zeros in R22) ---
display:
  ldi offset, '0'         ; ASCII offset for digit '0'

  ; --- Skip R22 (leading two BCD digits are always zero) ---

  ; R21 high nibble
  mov r24, R21
  swap r24
  andi r24, 0x0F
  add r24, offset
  rcall TXCHAR

  ; R21 low nibble
  mov r24, R21
  andi r24, 0x0F
  add r24, offset
  rcall TXCHAR

  ; R20 high nibble
  mov r24, R20
  swap r24
  andi r24, 0x0F
  add r24, offset
  rcall TXCHAR

  ; R20 low nibble
  mov r24, R20
  andi r24, 0x0F
  add r24, offset
  rcall TXCHAR

  ; --- Send newline ---
  ldi r24, 0x0D           ; Carriage return
  rcall TXCHAR
  ldi r24, 0x0A           ; Line feed
  rcall TXCHAR
  ret

; --- UART Character Transmit Subroutine ---
TXCHAR:
  lds util, UCSR0A
  sbrs util, UDRE0        ; Wait until buffer is empty
  rjmp TXCHAR
  sts UDR0, r24           ; Send character
  ret
