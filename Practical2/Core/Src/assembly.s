/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns
increment_by_one:           @ When this function is called, it increments the LED pattern by one
	ADDS R2, R2, #1
 	BX LR

increment_by_two:           @ When this function is called, it increments the LED pattern by two
	ADDS R2, R2, #2
	BX LR

main_loop:
	LDRB R1, [R0, #0x10]    @ Loads the state of buttons 0 to 7 into R1 from the IDR. We only care about buttons SW0 to SW3
	MVN R3, R1              @ Check whether SW0 is pressed
	MOV R4, #0b00000001
	ANDS R5, R3, R4
	CMP R5, #0b00000001

	BLEQ increment_by_two   @ Go to the the increment_by_two function if SW0 is pressed and then come back to this point in the main_loop

	BLNE increment_by_one   @ Go to the increment_by_one function if SW0 is not pressed and then come back to this point in the main loop

	B main_loop


write_leds:
	STR R2, [R1, #0x14]
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 0.7
SHORT_DELAY_CNT: 	.word 0.3
