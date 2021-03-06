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

; Adresse des Broches

BOUTTON_DROIT			EQU 	0x40

BOUTTON_GAUCHE			EQU 	0x80

BOUTTON_TOUS		EQU 	0xC0

VERIF 				EQU		0x120


; Import
DUREE   			EQU     0x002FFFFF
						
						
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		;; The EXPORT command specifies that a symbol can be accessed by other shared objects or executables.
		EXPORT	BOUTTON_INIT
		EXPORT	BOUTTON_DROIT_VERIF
		EXPORT  BOUTTON_GAUCHE_VERIF
		
		IMPORT	MOTEUR_INIT
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; d�activer le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arri�re
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; d�activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant0
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arri�re
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
		
		IMPORT	LED_DROIT_ON
		IMPORT	LED_GAUCHE_ON
		IMPORT	LED_GAUCHE_OFF
		IMPORT  LED_DROIT_OFF
		IMPORT	loop
		IMPORT	wait1

BOUTTON_INIT				
		;; Mise en place de l'horloge
		ldr r9, = SYSCTL_PERIPH_GPIO
		ldr	r0, [r9]
        ORR	r0, #0x00000028
        str r0, [r9]
		
		nop
		nop	   
		nop

		
		
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bouton 1 et 2

		ldr r0, = BOUTTON_TOUS
		ldr r9, = GPIO_PORTD_BASE+GPIO_I_PUR	
        str r0, [r9]
		
		ldr r9, = GPIO_PORTD_BASE+GPIO_O_DEN
        str r0, [r9]     
		
		ldr r9, = GPIO_PORTD_BASE + (BOUTTON_TOUS<<2)
		
		;ldr r9, = GPIO_PORTD_BASE + (BROCHE7<<2)
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Bouton
		
		BX LR

;Permet de savoir si le bouton est actif, si oui on renvoi vers BOUTTON_DROIT_ACTIF
BOUTTON_DROIT_VERIF
		ldr r1,[r9]
		CMP r1,#BOUTTON_GAUCHE
		BEQ BOUTTON_DROIT_ACTIF
		CMP r2,#VERIF
		MOV r2,#0x0
		BEQ wait1
		BX	LR
		
;Permet de savoir si le bouton est actif, si oui on renvoi vers BOUTTON_GAUCHE_ACTIF
BOUTTON_GAUCHE_VERIF
		ldr r1,[r9]
		CMP r1,#BOUTTON_DROIT
		BEQ BOUTTON_GAUCHE_ACTIF
		CMP r2,#VERIF
		MOV r2,#0x0
		BEQ wait1
		BX	LR
	
;Modifie le registre R11 qui g�re la vitesse des moteurs
BOUTTON_DROIT_ACTIF
		mov r11,#0x179
		MOV r2,#0x120
		BL  MOTEUR_INIT
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		B	BOUTTON_DROIT_VERIF
		
;Modifie le registre R11 qui g�re la vitesse des moteurs	
BOUTTON_GAUCHE_ACTIF
		mov r11,#0x160
		MOV r2,#0x120
		BL  MOTEUR_INIT
		BL	MOTEUR_DROIT_AVANT
		BL	MOTEUR_GAUCHE_AVANT
		B	BOUTTON_DROIT_VERIF

		END