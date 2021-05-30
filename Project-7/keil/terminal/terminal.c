#include <stm32f4xx.h>

#define RS 0x01     /* Pin mask for reg select (here is pin 0) */
#define RW 0x02     /* Pin mask for read/write (here is pin 1) */
#define EN 0x04     /* Pin mask for enable     (here is pin 2) */
 
void delayMs(int n);
void delayUs(int n); 
void LCD_command(unsigned char command); 
void LCD_data(char data);
void LCD_init(void);
void ports_init(void);
char keypad_getkey(void);
void USART2_init(void);
void UART2_send(uint8_t c);
uint8_t UART2_recieve(void);
uint8_t UART2_recieve_number(void);
int is_valid_char(uint8_t c);
int is_reset_button_pressed(void);

int main(void) {
    /* initialization */
		ports_init();
    LCD_init();
		USART2_init();
		unsigned char key;
		uint8_t data;
		int number_of_recieved_nums = 0;
		int max_digit = 5;
	
    while(1) {

				key = keypad_getkey();		
				if (is_reset_button_pressed()){
							LCD_command(0x01);      					/* clear screen, move cursor to home */
							number_of_recieved_nums = 0;							
							UART2_send('r');
							
				}
        if (key != 10){																/*if a key is pressed*/				
							UART2_send(key);
							data = UART2_recieve();
							if (is_valid_char(data)) {
										if (data == '*'){
													LCD_command(0x10);								/* shift the cursor one to left */
										}
										else if (data == '#' && number_of_recieved_nums == 3){
													LCD_command(0x01);      					/* clear screen, move cursor to home */
													for (int i = 0; i < max_digit; i++){
																data = UART2_recieve();
																LCD_data(data);
													}
																
										}
										else if (data == '#' && number_of_recieved_nums < 3) {
													number_of_recieved_nums += 1;	
													LCD_command(0x01);      					/* clear screen, move cursor to home */
										}else {
													LCD_data(data);
										}
							}
				}				
    }
	
}

/* initialize port pins then initialize LCD controller */
void LCD_init(void) {  
    delayMs(30);            /* initialization sequence */
    LCD_command(0x30);			
    delayMs(10);
    LCD_command(0x30);			/* set font=5x7 dot, 1-line display, 8-bit */
    delayMs(1);
    LCD_command(0x30);

    LCD_command(0x38);      /* set 8-bit data, 2-line, 5x7 font */
    LCD_command(0x06);      /* move cursor right after each char */
    LCD_command(0x01);      /* clear screen, move cursor to home */
    LCD_command(0x0F);      /* turn on display, cursor blinking */
}

void ports_init(void) {
		/* Initialize needed GPIOs and set ports mode appropriately  */
		
		RCC -> AHB1ENR |= RCC_AHB1ENR_GPIOAEN;								/* turn on the GPIOA clk */
		RCC -> AHB1ENR |= RCC_AHB1ENR_GPIOBEN;								/* turn on the GPIOB clk */
		GPIOA -> MODER |= 0x555500;														/* set the GPIOA as output registers */
		GPIOB -> MODER |= 0x55000015;													/* set the GPIOB as output registers */		
		RCC -> APB2ENR |= RCC_APB2ENR_SYSCFGEN;
}
		 
void LCD_command(unsigned char command) {
    GPIOB -> ODR &= ~(RS | RW);           								/* RS = 0, R/W = 0 */          								
		GPIOA -> ODR = command << 4;                         	/* put command on data bus */
    GPIOB -> ODR |= EN;																		/* pulse EN high */
    delayMs(0);
		GPIOB -> ODR &= ~EN;
		
    if (command < 4)
        delayMs(4);        	 												/* command 1 and 2 needs up to 1.64ms */
    else
        delayMs(1);         												/* all others 40 us */
}

void LCD_data(char data) {
    GPIOB -> ODR |= RS;                   					/* RS = 1 */
    GPIOB -> ODR &= ~RW;                   					/* R/W = 0 */
    GPIOA -> ODR = data << 4;                   		/* put data on data bus */
    GPIOB -> ODR |= EN;                   					/* pulse EN high */
    delayMs(0);              												/* Do not change this line! */
		GPIOB -> ODR &= ~EN;

    delayMs(1);
}

char keypad_getkey(void){
		int row, col;
		const int row_select[] = {0x1000, 0x2000, 0x4000, 0x8000};
		/*check to see any key pressed*/
		GPIOB -> ODR |= 0xF000;										/*enable all rows*/
		GPIOB -> ODR &= ~(0xF000);								/*load all rows with zero output*/
		delayUs(5);																/*wait for signal return*/
		col = GPIOB ->IDR & 0x700;								/*read all columns*/
		GPIOB -> ODR |= 0xF000;										/*disable all rows*/
		if (col == 0x700) return 10;								/*no key pressed*/
		/*if a key is pressed, it gets here to find out which key.*/
		/*It activates one row at a time and read the input to see which column is active*/
		for (row = 0; row < 4; row++){
				GPIOB -> ODR |= 0xF000;											/*disable all rows*/
				GPIOB -> ODR |= row_select[row];						/*enable one row*/
				GPIOB -> ODR &= ~row_select[row];						/*drive the active row low*/
				delayUs(5);
				col = GPIOB -> IDR & 0x700;									/*read all columns*/
				if (col != 0x700) break;										/*if one of the input is low, some key is pressed*/
		}
		GPIOB -> ODR |= 0xF000;													/*disable all Mows00*/
		delayMs(200);
		if (row == 4) return 10;
		if (row == 3 && col == 0x600) return '*';
		if (row == 3 && col == 0x500) return '0';
		if (row == 3 && col == 0x300) return '#';
		if (col == 0x300) return (row * 3 + 3) + '0';						/*0000 0011 0000 0000 key in column 0*/
		if (col == 0x500) return (row * 3 + 2) + '0';						/*0000 0101 0000 0000 key in column 1*/
		if (col == 0x600) return (row * 3 + 1) + '0';						/*0000 0110 0000 0000 key in column 2*/
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

uint8_t UART2_recieve(void) {
		uint8_t c;
		while (!(USART2 -> SR & (1<<5)));  											/* wait for RXNE bit to set */
		c = USART2 -> DR;  																			/* Read the data. This clears the RXNE also */
		return c;
}

uint8_t UART2_recieve_number(void) {
		uint8_t c;
		c = UART2_recieve();
		return c;
}

int is_valid_char(uint8_t c){
		if ((c <= '9' && c >= '0') || c == '*' || c == '#'){
				return 1;
		}
		return 0;
}

int is_reset_button_pressed(void){
			return (GPIOB -> IDR & 0x8) == 0;			
}

/* delay n milliseconds (16 MHz CPU clock) */
void delayMs(int n) {
    int i;
    for (; n > 0; n--)
        for (i = 0; i < 3195; i++) ;
}

void delayUs(int n) {
    int i;
    for (; n > 0; n--)
        for (i = 0; i < 8; i++) ;
}

