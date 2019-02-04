;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Mall för lab1 i TSEA28 Datorteknik Y
;;
;; 190123 K.Palmkvist
;;

	;; Ange att koden är för thumb mode
	.thumb
	.text
	.align 2

	;; Ange att labbkoden startar här efter initiering
	.global	main
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 	Placera programmet här
main:				; Start av programmet

	;----STORES ERROR MESSAGE-----------------------------------
	mov r4,#0x0000		;points to error msg address
	movt r4,#0x2000

	mov r0,#0x6546		;Fe
	movt r0,#0x616C		;la
	str r0,[r4],#4

	mov r0,#0x746B		;kt
	movt r0,#0x6769		;ig
	str r0,[r4],#4

	mov r0,#0x6B20		; k
	movt r0,#0x646F		;od
	str r0,[r4],#4

	mov r0,#0x0A21		;! newline
	movt r0,#0x000D		;leftmargin
	str r0,[r4]
	;------------------------------------------------------------

	;----INITIALIZE PROGRAM--------------------------------------
	bl inituart
	bl initGPIOB
	bl initGPIOF
	bl deactivatealarm

	;bl endloop4 ;TEST ONE SUBROUTINE

	;----PROGRAM--------------------------------------

alarmOff:
	bl getkey
	nop
	cmp r4,#0xA
	bne alarmOff

	bl activatealarm
	b alarmOn

alarmOn:
	bl getkey
	cmp r4,#0xF
	nop
	beq checkpass
	bl addkey
	b alarmOn

checkpass:
	push {lr}
	bl checkcode
	pop {lr}

	cmp r4,#1			;r4 contains result from checkcode
	beq correctpass
	bne incorrectpass

correctpass:
	bl deactivatealarm
	b alarmOff

incorrectpass:
	add r6,#1 		;add try to counter
	bl printstring
	bl clearinput
	b alarmOn


	;----SUBRUTINER----
	;bl activatealarm
	;bl deactivatealarm
	;bl initcode
	;bl inittestcode
	;bl checkcode
	;bl printstring
	;bl getkey		;NOT WORKING
	;bl addkey
	;bl clearinput



mainloop:
	b mainloop

;-------------TESTS-------------

	;----printchar TEST----
endloop:
	mov r0,#64
	bl printchar
	b endloop

	;----initGPIOB TEST-----
endloop2:
	b endloop2

	;----initGPIOF TEST----
endloop3:
	b endloop3

	;----printstring TEST----
endloop4:
	mov r4,#0x00c0
	movt r4,#0x0100
	mov r5,#13
	bl printstring
	b endloop4

	;----deactivatealarm TEST----
endloop5:
	bl deactivatealarm
	b endloop5

	;----activatealarm TEST----
endloop6:
	bl activatealarm
	b endloop6

	;----getkey TEST----
endloop7:
	bl getkey
	b endloop7
	;OBS, NOT WORKING

	;----clearinput TEST----
	bl clearinput
endloop8:
	b endloop8

	;----addkey TEST----
endloop9:
	push {lr}
	bl clearinput
	pop {lr}
	mov r4,#1
addkeytestloop:
	push {lr}
	bl addkey
	pop {lr}
	cmp r4,#4
	add r4,#1
	bne addkeytestloop
	b endloop9

	;----checkcode TEST----
endloop10:
	bl checkcode
	b endloop10

	;----sets user pass to 1 2 3 4
inittestcode:
	mov r1,#0x1000
	movt r1,#0x2000
	mov r0,#0x4
	str r0,[r1],#1
	mov r0,#0x3
	str r0,[r1],#1
	mov r0,#0x2
	str r0,[r1],#1
	mov r0,#0x1
	str r0,[r1]

	bx lr

;----------SUBRUTINER-----------
initcode:			;sets password in descending order
	mov r1,#0x1010	;r1 points to the address where
	movt r1,#0x2000	;the correct passcode will be stored
	mov r0,#0x4
	str r0,[r1],#1 	; r1 = 0x200010011
	mov r0,#0x3
	str r0,[r1],#1
	mov r0,#0x2
	str r0,[r1],#1
	mov r0,#0x1
	str r0,[r1]

	bx lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Pekare till strängen i r4
; Längd på strängen i r5
printstring:
	mov r4,#0x0000		;point to error msg
	movt r4,#0x2000
	mov r5,#15
printstringloop:
	push {lr}
	ldrb r0,[r4],#1 ;puts letter stored in r4 into r0, then shifts r4:s address 4 steps
	bl printchar
	pop {lr}
	subs r5,r5,#1
	bne printstringloop

	push {lr}
	mov r0,r6	;prints counter
	bl printchar
	pop {lr}

	bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
;
; Funktion: Tänder grön lysdiod (bit 3 = 1, bit 2 = 0, bit 1 = 0)
deactivatealarm:

	mov r1,#(GPIOF_GPIODATA & 0xffff)
	movt r1,#(GPIOF_GPIODATA >> 16)
	mov r0,#0x8
	str r0,[r1]
	;ldr r0, [r1]
	bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
;
; Funktion: Tänder röd lysdiod (bit 3 = 0, bit 2 = 0, bit 1 = 1)
activatealarm:
;
	mov r1,#(GPIOF_GPIODATA & 0xffff)
	movt r1,#(GPIOF_GPIODATA >> 16)
	mov r0,#0x2
	str r0,[r1]

	bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Tryckt knappt returneras i r4
getkey:
	;TEST KEY, doesn't work?---
	;mov r0,#0x5E
	;------------

	mov r1,#(GPIOB_GPIODATA & 0xffff)	 	;get the user key value address 0x400053fc
	movt r1,#(GPIOB_GPIODATA >> 16)
	;-----------------
	;strb r0,[r1] ;TEST, doesn't work?
	;str
	;-----------------
	ldrb r4,[r1]	;put the entered key value from [r1] into r4

	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Inargument: Vald tangent i r4
; Utargument: Inga
;
; Funktion: Flyttar innehållet på 0x20001000-0x20001002 framåt en byte
; till 0x20001001-0x20001003. Lagrar sedan innehållet i r4 på
; adress 0x20001000.
addkey:
	;;TEST---------
	;mov r1,#0x1000
	;movt r1,#0x2000
	;mov r0,#0x3c4d
	;movt r0,#0x1e2b
	;str r0,[r1]
	;--------------

	mov r1,#0x1003
	movt r1,#0x2000
	mov r2,#3 		;loop counter

addkeyloop:
	subs r2,#1 		;loop counter
	sub r1,#1		;go to next adress
	ldrb r0,[r1]	;load letter into r0
	strb r0,[r1,#1]	;store letter in the next pos
	bne addkeyloop

	strb r4,[r1]		;adds the user key

	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Inargument: Inga
; Utargument: Inga
;
; Funktion: Sätter innehållet på 0x20001000-0x20001003 till 0xFF
clearinput:
	mov r0,#0xFF
	mov r1,#0x1000
	movt r1,#0x2000
	mov r2,#0x4 	;loop counter

clearinputloop:
	subs r2,#1 			;loop counter
	strb r0,[r1],#1		;stores dummy value in letter pos, shifts r1 one
	bne clearinputloop

	bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Returnerar 1 i r4 om koden var korrekt, annars 0 i r4
checkcode:
	mov r1,#0x1010	;let r1 point to the adress
	movt r1,#0x2000	;where correct pass is stored.
	ldr r0,[r1]		;store correct pass in r0

	mov r3,#0x1000	;let r3 point to the adress
	movt r3,#0x2000 ;where user pass is stored.
	ldr r2,[r3]		;store user entered pass in r2

	cmp r0,r2

	push {lr}
	beq corrkey
	bne wrongkey
	pop {lr}
	bx lr

corrkey:
	mov r4,#0x1
	bx lr

wrongkey:
	mov r4,#0x0
	bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;;
;;; Allt här efter ska inte ändras
;;;
;;; Rutiner för initiering
;;; Se labmanual för vilka namn som ska användas
;;;
	
	.align 4

;; 	Initiering av seriekommunikation
;;	Förstör r0, r1
	
inituart:
	mov r1,#(RCGCUART & 0xffff)		; Koppla in serieport
	movt r1,#(RCGCUART >> 16)
	mov r0,#0x01
	str r0,[r1]

	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x01
	str r0,[r1]		; Koppla in GPIO port A

	nop			; vänta lite
	nop
	nop

	mov r1,#(GPIOA_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOA_GPIOAFSEL >> 16)
	mov r0,#0x03
	str r0,[r1]		; pinnar PA0 och PA1 som serieport

	mov r1,#(GPIOA_GPIODEN & 0xffff)
	movt r1,#(GPIOA_GPIODEN >> 16)
	mov r0,#0x03
	str r0,[r1]		; Digital I/O på PA0 och PA1

	mov r1,#(UART0_UARTIBRD & 0xffff)
	movt r1,#(UART0_UARTIBRD >> 16)
	mov r0,#0x08
	str r0,[r1]		; Sätt hastighet till 115200 baud
	mov r1,#(UART0_UARTFBRD & 0xffff)
	movt r1,#(UART0_UARTFBRD >> 16)
	mov r0,#44
	str r0,[r1]		; Andra värdet för att få 115200 baud

	mov r1,#(UART0_UARTLCRH & 0xffff)
	movt r1,#(UART0_UARTLCRH >> 16)
	mov r0,#0x60
	str r0,[r1]		; 8 bit, 1 stop bit, ingen paritet, ingen FIFO
	
	mov r1,#(UART0_UARTCTL & 0xffff)
	movt r1,#(UART0_UARTCTL >> 16)
	mov r0,#0x0301
	str r0,[r1]		; Börja använda serieport

	bx  lr

; Definitioner för registeradresser (32-bitars konstanter)
GPIOHBCTL	.equ	0x400FE06C
RCGCUART	.equ	0x400FE618
RCGCGPIO	.equ	0x400fe608
UART0_UARTIBRD	.equ	0x4000c024
UART0_UARTFBRD	.equ	0x4000c028
UART0_UARTLCRH	.equ	0x4000c02c
UART0_UARTCTL	.equ	0x4000c030
UART0_UARTFR	.equ	0x4000c018
UART0_UARTDR	.equ	0x4000c000
GPIOA_GPIOAFSEL	.equ	0x40004420
GPIOA_GPIODEN	.equ	0x4000451c
GPIOB_GPIODATA	.equ	0x400053fc
GPIOB_GPIODIR	.equ	0x40005400
GPIOB_GPIOAFSEL	.equ	0x40005420
GPIOB_GPIOPUR	.equ	0x40005510
GPIOB_GPIODEN	.equ	0x4000551c
GPIOB_GPIOAMSEL	.equ	0x40005528
GPIOB_GPIOPCTL	.equ	0x4000552c
GPIOF_GPIODATA	.equ	0x4002507c
GPIOF_GPIODIR	.equ	0x40025400
GPIOF_GPIOAFSEL	.equ	0x40025420
GPIOF_GPIODEN	.equ	0x4002551c
GPIOF_GPIOLOCK	.equ	0x40025520
GPIOKEY		.equ	0x4c4f434b
GPIOF_GPIOPUR	.equ	0x40025510
GPIOF_GPIOCR	.equ	0x40025524
GPIOF_GPIOAMSEL	.equ	0x40025528
GPIOF_GPIOPCTL	.equ	0x4002552c

;; Initiering av port F
;; Förstör r0, r1, r2
initGPIOF:
	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x20		; Koppla in GPIO port F
	str r0,[r1]
	nop 			; Vänta lite
	nop
	nop

	mov r1,#(GPIOHBCTL & 0xffff)	; Använd apb för GPIO
	movt r1,#(GPIOHBCTL >> 16)
	ldr r0,[r1]
	mvn r2,#0x2f		; bit 5-0 = 0, övriga = 1 (DET BLIR JU 111...010000??)
	and r0,r0,r2
	str r0,[r1]

	mov r1,#(GPIOF_GPIOLOCK & 0xffff)
	movt r1,#(GPIOF_GPIOLOCK >> 16)
	mov r0,#(GPIOKEY & 0xffff)
	movt r0,#(GPIOKEY >> 16)
	str r0,[r1]		; Lås upp port F konfigurationsregister

	mov r1,#(GPIOF_GPIOCR & 0xffff)
	movt r1,#(GPIOF_GPIOCR >> 16)
	mov r0,#0x1f		; tillåt konfigurering av alla bitar i porten
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAMSEL >> 16)
	mov r0,#0x00		; Koppla bort analog funktion
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPCTL & 0xffff)
	movt r1,#(GPIOF_GPIOPCTL >> 16)
	mov r0,#0x00		; använd port F som GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIODIR & 0xffff)
	movt r1,#(GPIOF_GPIODIR >> 16)
	mov r0,#0x0e		; styr LED (3 bits), andra bitar är ingångar
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar är GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPUR & 0xffff)
	movt r1,#(GPIOF_GPIOPUR >> 16)
	mov r0,#0x11		; svag pull-up för tryckknapparna
	str r0,[r1]

	mov r1,#(GPIOF_GPIODEN & 0xffff)
	movt r1,#(GPIOF_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar som digital I/O
	str r0,[r1]

	bx lr


;; Initiering av port B
;; Förstör r0, r1
initGPIOB:
	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x02		; koppla in GPIO port B
	str r0,[r1]
	nop			; vänta lite
	nop
	nop

	mov r1,#(GPIOB_GPIODIR & 0xffff)
	movt r1,#(GPIOB_GPIODIR >> 16)
	mov r0,#0x0		; alla bitar är ingångar
	str r0,[r1]

	mov r1,#(GPIOB_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOB_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar är GPIO
	str r0,[r1]

	mov r1,#(GPIOB_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOB_GPIOAMSEL >> 16)
	mov r0,#0x00		; använd inte analoga funktioner
	str r0,[r1]

	mov r1,#(GPIOB_GPIOPCTL & 0xffff)
	movt r1,#(GPIOB_GPIOPCTL >> 16)
	mov r0,#0x00		; använd inga specialfunktioner på port B
	str r0,[r1]

	mov r1,#(GPIOB_GPIOPUR & 0xffff)
	movt r1,#(GPIOB_GPIOPUR >> 16)
	mov r0,#0x00		; ingen pullup på port B
	str r0,[r1]

	mov r1,#(GPIOB_GPIODEN & 0xffff)
	movt r1,#(GPIOB_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar är digital I/O
	str r0,[r1]

	bx lr


;; Utskrift av ett tecken på serieport
;; r0 innehåller tecken att skriva ut (1 byte)
;; returnerar först när tecken skickats
;; förstör r0, r1 och r2
printchar:
	mov r1,#(UART0_UARTFR & 0xffff)	; peka på serieportens statusregister
	movt r1,#(UART0_UARTFR >> 16)
loop1:
	ldr r2,[r1]			; hämta statusflaggor
	ands r2,r2,#0x20		; kan ytterligare tecken skickas?
	bne loop1			; nej, försök igen
	mov r1,#(UART0_UARTDR & 0xffff)	; ja, peka på serieportens dataregister
	movt r1,#(UART0_UARTDR >> 16)
	str r0,[r1]			; skicka tecken
	bx lr



