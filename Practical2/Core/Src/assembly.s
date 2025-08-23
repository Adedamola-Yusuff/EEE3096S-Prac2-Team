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
	LDRB R3, [R0, #0x10]    @ Loads the state of bits 0 to 7 into R3 from the IDR every loop cycle. We only care about buttons SW0 to SW3 though
	MVNS R3, R3             @ Inverts R3. Necessary because a button being pressed sends a logic 0 but it's much easier to work with 1s

	MOVS R5, #8              @ New line
	TST R3, R5              @ Checks bit 3 of the IDR to see if SW3 is being pressed. Sets Z flag to 0 (ANDS result = 0b00000001) if SW0 is pressed and Z flag to 1 (ANDS result = 0b00000000) if SW0 isn't pressed
	BNE freeze              @ Skips all the code that would change the pattern of the LEDs if SW3 is pressed

	MOVS R5, #4              @ New line
    TST R3, R5              @ Checks bit 2 of the IDR to see if SW2 is being pressed
    BEQ dont_set_pattern    @ If Z=1, don't set pattern. If Z=0, set pattern
    MOVS R2, #0xAA     @ Sets the pattern of the LEDs
    B write_leds            @ Unconditional branching to write the pattern to the LEDs

dont_set_pattern:           @ If the program reaches this point, then the 0xAA pattern was not set
	MOVS R5, #1              @ New line
	TST R3, R5              @ Checks bit 0 of the IDR to see if SW0 Is being pressed

	BEQ increment_by_one    @ This and next three lines increment the pattern by one if SW0 is not pressed and by 2 if SW0 is pressed
	ADDS R2, R2, #1
increment_by_one:
	ADDS R2, R2, #1

	MOVS R5, #2
	TST R3, R5              @ Checks if SW1 is being pressed
    BNE short_delay         @ Makes it so that the loop_delay is going to use SHORT_DELAY_CNT because SW1 is not being pressed
    LDR R4, LONG_DELAY_CNT  @ If we're here, then we're not using SHORT_DELAY, which means that we want to use LONG_DELAY_CNT
    B loop_delay            @ Makes sure that we skip short_delay and immediately implement the delay
short_delay:
	LDR R4, SHORT_DELAY_CNT
loop_delay:
	SUBS R4, #1             @ Implements a delay based on what R4 is
    BNE loop_delay
	B write_leds            @ Branch to write_leds after completing the loop delay

freeze:                     @ Go back to main_loop after doing nothing to the LEDs
	B main_loop

write_leds:
	STRB R2, [R1, #0x14]    @ Write only 8 bits of the modified value of R2 to the GPIOB ODR
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1399995
SHORT_DELAY_CNT: 	.word 599995
