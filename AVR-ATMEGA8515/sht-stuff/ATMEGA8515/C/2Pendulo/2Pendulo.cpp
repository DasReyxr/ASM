/*
------ Orlando Reyes ------
--------- Auf Das ---------
------- 2 Pendulo --------
-------- 21/12/2024 --------
*/
// ------- Main Library -------
#define F_CPU 16000000 // Replace with your microcontroller's clock frequency in Hz
#include <avr/io.h>
#include <util/delay.h>

// --------- Function ---------
void dynamic_delay(int ms) {
	for (int i = 0; i < ms; i++) {
		_delay_ms(1);  // Delay 1 ms (built-in delay)
	}
}
// ---------- Class ----------
// -------- Variables --------
// -- Pin/out --
#define B1 PB1
#define B2 PB2
#define S1 PC0 
int time = 20;

// ----------- Main -----------
int main(void) {
	// Configure PB1 and PB2 as input
	DDRB  &= ~(1 << B1) | ~(1 << B2);  
	PORTB |= (1 << B1) | (1 << B2);  

	DDRC  = 0x01;
	
	DDRA  = 0xFF; 
	PORTA = 0x01;  

	while (1) {
		dynamic_delay(time);
		
		PORTA <<= 1;

		if (PORTA == 0x80){
			PORTA = 0x01;
		}
		
		if (!(PINB & (1 << B1))) {  // Button pressed
				PORTC = 0x00;
				time -= 20;
				if (time < 20) time = 20;  // Prevent negative delay
				dynamic_delay(time);

				while (!(PINB & (1 << B1)));  // Wait until button released
			
		}

		if (!(PINB & (1 << B2))) {  // Button pressed
				PORTC = 0x01;
				time += 20;
				dynamic_delay(time);

				while (!(PINB & (1 << B2)));  // Wait until button released
			
		}
	}


	return 0;
}
