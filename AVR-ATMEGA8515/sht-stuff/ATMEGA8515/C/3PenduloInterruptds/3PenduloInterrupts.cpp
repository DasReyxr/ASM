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
#include <avr/interrupt.h>

// --------- Function ---------
void dynamic_delay(int ms) {
	for (int i = 0; i < ms; i++) {
		_delay_ms(1);  // Delay 1 ms (built-in delay)
	}
}

// ---------- Class ----------
// -------- Variables --------
// -- Pin/out --
#define S1 PC0 
int time = 10;

void Config_Interrupts(void){
	    MCUCR |= (1 << ISC01) | (1 << ISC11);  // Falling edge triggers for INT0 and INT1
	    MCUCR &= ~((1 << ISC00) | (1 << ISC10));

/*    MCUCR = x x x x ISC11 ISC10 ISC01 ISC00 = flancos negativos
            0 0 0 0   1     0     1     0  */

	    GICR |= (1 << INT0) | (1 << INT1);     // Enable INT0 and INT1
	    sei();                                 // Enable global interrupts
    
        /*    GICR = INT1 INT0 INT2 x x x x x
                        1     1    0  0 0 0 0 0 */

}
ISR(INT0_vect) {
	if (time > -1) {
		time -= 10;  // Decrease delay by 20ms
	}
	PORTC = 0x02;
	/*
	_delay_ms(100);
	PORTC = 0x00;
*/
}



ISR(INT1_vect) {
	if (time < 1000) {
		time += 10;  // Increase delay by 50ms
	}
	PORTC = 0x01;
	/*
	;
	_delay_ms(100);
	PORTC = 0x00;
*/
	}

// ----------- Main -----------
int main(void) {
	// Configure PB1 and PB2 as input

    DDRD &= ~((1 << PD2) | (1 << PD3));  // Set PD2 and PD3 as inputs
    PORTD |= (1 << PD2) | (1 << PD3);    // Enable pull-up resistors

	DDRC  = 0x01;
	PORTC = 0x00;
	DDRA  = 0xFF; 
	PORTA = 0x01;  

	Config_Interrupts();
	while (1) {
		dynamic_delay(time);
		
		PORTA <<= 1;

		if (PORTA == 0x80)
			PORTA = 0x01;
		
	}


	return 0;
}
