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

main_loop:
	LDRB R3, [R0, #0x10]    @ Loads the state of buttons 0 to 7 into R3 from the IDR every loop cycle. We only care about buttons SW0 to SW3
	MVN R4, R3              @ This and next two lines check whether SW0 is pressed
	TST R4, #1              @ Sets Z flag to 0 (ANDS result = 0b00000001) if SW0 is pressed and Z flag to 1 (ANDS result = 0b00000000) if SW0 isn't pressed

	BEQ increment_by_one    @ This and next three lines increment the pattern by one if SW0 is not pressed and by 2 if SW0 is pressed
	ADDS R2, R2, #1
increment_by_one:
	ADDS R2, R2, #1

	B write_leds            @ Update the pattern displayed by the LEDS

write_leds:
	STR R2, [R1, #0x14]     @ Write the modified value of R2 to the GPIOB ODR
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
