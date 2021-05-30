#include <stm32f4xx.h>
#include <math.h>

#define RS 0x01     /* Pin mask for reg select (here is pin 0) */
#define RW 0x02     /* Pin mask for read/write (here is pin 1) */
#define EN 0x04     /* Pin mask for enable     (here is pin 2) */
 
void delayMs(int n);
void ports_init(void);
void toggle_LED(int mode);
void USART2_init(void);
void UART2_send(uint8_t c);
void UART2_send_number(int num);
uint8_t UART2_recieve(void);
int is_valid_char(uint8_t c);
int array2integer(int arr[], int size);
int calculate(int x, int coeffs[]);



int main(void) {
    /* initialization */
		ports_init();
		USART2_init();
		
		int a_b_c[] = {0, 0, 0};
		int x;		
		int number_of_recieved_coeffs = 0;
		int current_coeff = 0;	
		uint8_t data;
		
    while(1) {
			
				data = UART2_recieve();
				toggle_LED(0);													/* turn on the LED */			
				delayMs(50);								
				toggle_LED(1);													/* turn off the LED */
				delayMs(100);
				if (is_valid_char(data)) {
							if (data == 'r') {
									current_coeff = 0;
									number_of_recieved_coeffs = 0;
							}
							if (data == '*'){
									current_coeff /= 10;
									UART2_send(data);
							}
							if (data != '#' && data != 'r' && data != '*') {
										current_coeff = current_coeff*10 + (data - '0');
										UART2_send(data);
							}
							if (data == '#' && number_of_recieved_coeffs == 3){		
										UART2_send(data);
										x = current_coeff;
										UART2_send_number(calculate(x, a_b_c));
										current_coeff = 0;
							}
							if (data == '#' && number_of_recieved_coeffs < 3){									
										UART2_send(data);
										a_b_c[number_of_recieved_coeffs] = current_coeff;
										current_coeff = 0;
										number_of_recieved_coeffs++;
							}
							
				}
    }
}


void ports_init(void) {
		/* Initialize needed GPIOs and set ports mode appropriately  */
		
		RCC -> AHB1ENR |= RCC_AHB1ENR_GPIOBEN;								/* turn on the GPIOB clk */
		GPIOB -> MODER |= 0x1;																/* set the GPIOB pin 0 as output registers */	
		RCC -> APB2ENR |= RCC_APB2ENR_SYSCFGEN;
}

void toggle_LED(int mode){
		if (mode == 0){			/* turn LED off */
				GPIOB -> ODR |= 0x1;
		}else if (mode == 1){
				GPIOB -> ODR &= 0x0;
		}
}

void USART2_init(void){

		/* 1. Enable the UART CLOCK and GPIO CLOCK */
		RCC -> AHB1ENR |= RCC_AHB1ENR_GPIOAEN;									/* turn on the GPIOC clk */
		RCC -> APB1ENR |= (1<<17);															/* Enable USART2 clock */
		
		/* 2. Configure the UART PINs for ALternate Functions */
		GPIOA -> MODER |= (2<<4); 															/* Bits (5:4)= 1:0 --> Alternate Function for Pin PA2 */
		GPIOA -> MODER |= (2<<6);  															/* Bits (7:6)= 1:0 --> Alternate Function for Pin PA3 */
		
		GPIOA -> OSPEEDR |= (3<<4) | (3<<6);  									/* Bits (5:4)= 1:1 and Bits (7:6)= 1:1 --> High Speed for PIN PA2 and PA3 */
		
		GPIOA -> AFR[0] |= (7<<8);  														/* Bytes (11:10:9:8) = 0:1:1:1  --> AF7 Alternate function for USART2 at Pin PA2 */
		GPIOA -> AFR[0] |= (7<<12); 														/* Bytes (15:14:13:12) = 0:1:1:1  --> AF7 Alternate function for USART2 at Pin PA3 */
		
		/* 3. Enable the USART by writing the UE bit in USART_CR1 register to 1. */
		USART2 -> CR1 = 0x00;  																	/* clear all */
		USART2 -> CR1 |= (1<<13);  															/* UE = 1... Enable USART */
		
		/* 4. Program the M bit in USART_CR1 to define the word length. */
		USART2 -> CR1 &= ~ (1<<12);  														/* M =0; 8 bit word length */
		
		/* 5. Select the desired baud rate using the USART_BRR register. */
		USART2 -> BRR = 0x0683;   															/* Baud rate of 9600, @ 16MHz */
		
		/* 6. Enable the Transmitter/Receiver by Setting the TE and RE bits in USART_CR1 Register */
		USART2 -> CR1 |= (1<<2); 																/* RE=1.. Enable the Receiver */
		USART2 -> CR1 |= (1<<3);  															/* TE=1.. Enable Transmitter */
}

void UART2_send(uint8_t c){
		USART2 -> DR = c; 																			/* load the data into DR register */
		while (!(USART2 -> SR & (1<<6)));  											/* Wait for TC to SET.. This indicates that the data has been transmitted */
}

void UART2_send_number(int num){
		int len = 1;
		for(int i = 10; i <= num; i*=10){
					len++;
		}		
		for (int i = len; i >= 1; i--){
					UART2_send((int)(num / pow(10, i-1)) % 10 + '0');
					delayMs(5);
		}
}

uint8_t UART2_recieve(void) {
		uint8_t c;
		while (!(USART2 -> SR & (1<<5)));  											/* wait for RXNE bit to set */
		c = USART2 -> DR;  																			/* Read the data. This clears the RXNE also */
		return c;
}

int is_valid_char(uint8_t c){
		if ((c <= '9' && c >= '0') || c == '*' || c == '#' || c == 'r'){
				return 1;
		}
		return 0;
}

int array2integer(int arr[], int size){
		int result = 0;	
		for (int i = size - 1; i >= 0; i--){
					result += arr[i] * pow(10, size - i - 1);
		}
		return result;
}

int calculate(int x, int coeffs[]){
		return coeffs[0]*x + 2*coeffs[1]*x + 3*coeffs[2]*x;
}

/* delay n milliseconds (16 MHz CPU clock) */
void delayMs(int n) {
    int i;
    for (; n > 0; n--)
        for (i = 0; i < 3195; i++) ;
}
