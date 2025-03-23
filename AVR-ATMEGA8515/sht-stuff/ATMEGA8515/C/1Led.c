/*
------ Orlando Reyes ------
--------- Auf Das ---------
------- LedHeartbeat -------
-------- 21/12/2024 --------
*/
// ------- Main Library -------
#include <avr/io.h>
#include <util/delay.h>

// --------- Function ---------
// ---------- Class ----------
// -------- Variables --------
// -- Pin/out --

#define LED_PIN PB0  // Define the pin where the LED is connected (Pin B0)
// ----------- Main -----------
void main(void) {

    // Set LED_PIN as output
    DDRB |= (1 << LED_PIN);  // Data Direction Register B: Set PB0 as output

    while (1) {
        // Turn the LED on
        PORTB |= (1 << LED_PIN);  // Set PB0 high
        _delay_ms(500);          // Wait for 500 milliseconds

        // Turn the LED off
        PORTB &= ~(1 << LED_PIN); // Set PB0 low
        _delay_ms(500);           // Wait for 500 milliseconds
    }

}
