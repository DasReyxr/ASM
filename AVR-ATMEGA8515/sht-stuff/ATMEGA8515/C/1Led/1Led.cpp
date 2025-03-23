/*
------ Orlando Reyes ------
--------- Auf Das ---------
------- LedHeartbeat -------
-------- 21/12/2024 --------
*/
// ------- Main Library -------
#define F_CPU 16000000 // Replace 16000000UL with your microcontroller's clock frequency in Hz
#include <avr/io.h>
#include <util/delay.h>

// --------- Function ---------
// ---------- Class ----------
// -------- Variables --------
// -- Pin/out --
#define LED_PIN PA0 // Define the pin where the LED is connected (Pin B0)
// ----------- Main -----------
int main(void) {

    DDRA|= 0xFF;  // Data Direction Register B: Set PB0 as output

    while (1) {

        PORTA |= (1 << LED_PIN);  // Set PB1 high
        _delay_ms(500);          // Wait for 500 milliseconds

        PORTA &= ~(1 << LED_PIN); // Clear PB1 (set it low)
        _delay_ms(500);           // Wait for 500 milliseconds        
	}
	return 0;
}


