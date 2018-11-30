; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Broches select

BOUTTON_DROIT			EQU 	0x40

BOUTTON_GAUCHE			EQU 	0x80

BOUTTON_TOUS		EQU 	0xC0

VERIF 				EQU		0x120


; Durée du clignotement
DUREE   			EQU     0x002FFFFF
						
						
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		;; The EXPORT command specifies that a symbol can be accessed by other shared objects or executables.
		EXPORT	BOUTTON_INIT
		EXPORT	BOUTTON_DROIT_VERIF
		EXPORT  BOUTTON_GAUCHE_VERIF
		
		IMPORT 	MOTEUR_INIT
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; déactiver le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arrière
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant0
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arrière
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
		
		IMPORT	LED_DROIT_ON
		IMPORT	LED_GAUCHE_ON
		IMPORT	LED_GAUCHE_OFF
		IMPORT  LED_DROIT_OFF
		IMPORT	loop
		IMPORT	VITESSE
		IMPORT	start


BOUTTON_INIT
		; ;; Enable the Port F & D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)
		; ;;									
		ldr r9, = SYSCTL_PERIPH_GPIO  			;; RCGC2
		ldr	r0, [r9]
        ORR	r0, #0x00000028   ;;bit 20 = PWM recoit clock: ON (p271) 
        str r0, [r9]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; tres tres important....
		nop	   
		nop	   									;; pas necessaire en simu ou en debbug step by step...

		
		
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumper 1 et 2

		ldr r0, = BOUTTON_TOUS
		ldr r9, = GPIO_PORTD_BASE+GPIO_I_PUR	;; Pul_up 		
        str r0, [r9]
		
		ldr r9, = GPIO_PORTD_BASE+GPIO_O_DEN	;; Enable Digital Function 	
        str r0, [r9]     
		
		ldr r9, = GPIO_PORTD_BASE + (BOUTTON_TOUS<<2)
		
		;ldr r9, = GPIO_PORTD_BASE + (BROCHE7<<2)
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Switcher 
		
		BX LR

;Enable PWM0 (bit 0) et PWM2 (bit 2) p1145 
;Attention ici c'est les sorties PWM0 et PWM2
;qu'on controle, pas les blocks PWM0 et PWM1!!!
BOUTTON_DROIT_VERIF
		;Enable sortie PWM0 (bit 0), p1145 
		ldr r1,[r9]
		CMP r1,#BOUTTON_GAUCHE
		BEQ BOUTTON_DROIT_ACTIF
		CMP r2,#VERIF
		MOV r2,#0x0
		BEQ loop
		BX	LR
		
BOUTTON_GAUCHE_VERIF
		;Enable sortie PWM0 (bit 0), p1145 
		ldr r1,[r9]
		CMP r1,#BOUTTON_DROIT
		BEQ BOUTTON_GAUCHE_ACTIF
		CMP r2,#VERIF
		MOV r2,#0x0
		BEQ loop
		BX	LR
	
BOUTTON_DROIT_ACTIF
		mov r11,#0x179
		MOV r2,#0x120
		BL  MOTEUR_INIT
		B	BOUTTON_DROIT_VERIF
		
BOUTTON_GAUCHE_ACTIF
		mov r11,#0x160
		MOV r2,#0x120
		BL  MOTEUR_INIT
		B	BOUTTON_DROIT_VERIF

		END