;
; 8bit power
;
;

.cseg
.nolist
	.include "tn12def.inc"
	.include "macro.asm"
.list

	.org	0
		rjmp RESET ; Reset handler
;		rjmp EXT_INT0 ; IRQ0 handler
;		rjmp PIN_CHANGE ; Pin change handler
;		rjmp TIM0_OVF ; Timer0 overflow handler
;		rjmp ANA_COMP ; Analog Comparator handler

	.org	0x60
RESET:
	; set PORTB pins to output
	ser		r29
	out		DDRB,r29
	
	rcall	wait_1s

	.include "audioplayer.asm"


; Magic starts here.
start:
	digitalWrite	clk, SET_LOW	// digitalWrite(MAX7219::clk, LOW);

	send_command	0x09, 0x00	// Decode mode: led matrix
	send_command	0x0a, 0x08	// Intensity 50%
	send_command	0x0b, 0x07	// Scan limit
	send_command	0x0c, 0x01	// Shutdown mode: no
	send_command	0x0f, 0x00	// Display test: no

	send_data		image_data, 8

/*
	TEST code
	
	rcall	wait_1s
	rcall	clear_leds
	rcall	wait_1s
	rcall	test

	ldi		ZL,low(test_data*2)
	ldi  	ZH,high(test_data*2)
	ldi		data_loop_register,8
	ldi		data_loop_index_register,1
send_data_loop:
	mov		byte_register,data_loop_index_register
	rcall	write_byte
	lpm
	inc		ZL
	rcall	write_byte
	inc		data_loop_index_register
	dec		data_loop_register
	brne	send_data_loop
*/

end:
	rjmp	start
; Magic ends here

// TEST code
clear_leds:
	ldi		command_register,1
	ldi		data_register,0
clear_leds_loop:
	rcall	write
	inc		command_register
	cpi		command_register,8
	brne	clear_leds_loop
	ret

test:
	ldi		data_register,0
loop_main:
	ldi		command_register,1
loop_line:
	rcall	write
	inc		command_register
	cpi		command_register,$09
	brne	loop_line
	rcall	wait_1s
	inc		data_register
	brne	loop_main
	ret

; Generated by delay loop calculator
; at http://www.bretmulvey.com/avrdelay.html
;
; Delay 1 000 000 cycles
; 1s at 1.0 MHz
wait_1s:
    ldi  r18, 6
    ldi  r19, 19
    ldi  r20, 174
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    rjmp PC+1
	ret

	.include "portbsender.asm"
;	.include "audioplayer.asm"


; image sprite 8x8 pixels
image_data:	.db 0b00100000, 0b01001110, 0b10001110, 0b10000000, 0b10000000, 0b10001110, 0b01001110, 0b00100000
; song data: tone, length
song_data:	.db 142, 255, 127, 255, 239, 255, 213, 255, 190, 255, 179, 255, 159, 255, 0, 0
