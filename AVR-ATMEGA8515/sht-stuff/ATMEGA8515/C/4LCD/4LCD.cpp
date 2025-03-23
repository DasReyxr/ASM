/*
------ Orlando Reyes ------
--------- Auf Das ---------
------- 4 LCD --------
-------- 21/12/2024 --------
*/
// ------- Main Library -------
#define F_CPU 16000000 // Replace with your microcontroller's clock frequency in Hz
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupts.h>
// --------- Function ---------
// ---------- Class ----------
// -------- Variables --------
const uint8_t Config[] = {0x38, 0x38, 0x38, 0x0C, 0x06, 0x01};
const char Data1[] = "Das R Contreras";

// -- Pin/out --
#define EN PA5
#define RS PA7  



void send_data(uint8_t data, int cmd = 1) {
    PORTC = data;              
    PORTA |= (cmd << RS);       
    PORTA |= (1 << EN);    
    _delay_us(1);          
    PORTA &= ~(1 << EN);   
    _delay_us(50);
    _delay_ms(2);              
}

void send_string(const char *str) {
    while (*str) {
        send_data(*str++);
    }
}

void Config_LCD() {
    for (uint8_t i = 0; i < 5 ; i++) {
        send_data(Config[i],0);
    }
    _delay_ms(20);  
}
// ----------- Main -----------
int main(void) {
    DDRC = 0xFF;                           
    DDRA |= (1 << EN) | (1 << RS);         
    Config_LCD();                          
    while (1) {
        send_data(0x80,0);                
        send_string(Data1);                
        _delay_ms(1000);                  
    }
    return 0;
}
