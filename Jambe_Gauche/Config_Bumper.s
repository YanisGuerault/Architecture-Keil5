SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTE_BASE		EQU		0x40024000

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
BUMP_DROIT			EQU		0x1

BUMP_GAUCHE			EQU		0x2

BUMP_TOUS		EQU		0x3

VERIF			EQU		0x120


; Durée du clignotement
DUREE   			EQU     0x002FFFFF
						
						
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		;; The EXPORT command specifies that a symbol can be accessed by other shared objects or executables.
		EXPORT	BUMPER_INIT
		EXPORT	BUMPER_DROIT_VERIF
		EXPORT  BUMPER_GAUCHE_VERIF
		
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
		IMPORT	start
		IMPORT	loop


BUMPER_INIT	
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumper 1 et 2

				; ;; Enable the Port F & D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)
		; ;;									
		ldr r8, = SYSCTL_PERIPH_GPIO  			;; RCGC2
		ldr	r0, [r8]
        ORR	r0, #0x00000030   ;;bit 20 = PWM recoit clock: ON (p271) 
        str r0, [r8]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; tres tres important....
		nop	   
		nop	   									;; pas necessaire en simu ou en debbug step by step...

		
		
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumper 1 et 2

		ldr r0, = BUMP_TOUS
		
		ldr r8, = GPIO_PORTE_BASE+GPIO_I_PUR	;; Pul_up 		
        str r0, [r8]
		
		ldr r8, = GPIO_PORTE_BASE+GPIO_O_DEN	;; Enable Digital Function 	
        str r0, [r8]     
		
		ldr r8, = GPIO_PORTE_BASE + (BUMP_TOUS<<2)
		
		;ldr r8, = GPIO_PORTE_BASE + (BUMP_GAUCHE<<2)
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Switcher 
		
		BX LR

;Enable PWM0 (bit 0) et PWM2 (bit 2) p1145 
;Attention ici c'est les sorties PWM0 et PWM2
;qu'on controle, pas les blocks PWM0 et PWM1!!!
BUMPER_DROIT_VERIF
		;Enable sortie PWM0 (bit 0), p1145 
		ldr r1,[r8]
		CMP r1,#BUMP_GAUCHE
		BEQ BUMPER_DROIT_ACTIF
		CMP r2,#VERIF
		MOV r2,#0x0
		BEQ start
		BX	LR
		
BUMPER_GAUCHE_VERIF
		;Enable sortie PWM0 (bit 0), p1145 

		ldr r1,[r8]
		CMP r1,#BUMP_DROIT
		BEQ BUMPER_GAUCHE_ACTIF
		CMP r2,#VERIF
		MOV r2,#0x0
		BEQ start
		BX	LR
	
BUMPER_DROIT_ACTIF
		BL	LED_GAUCHE_OFF
		BL	LED_DROIT_ON
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ARRIERE
		BL MOTEUR_GAUCHE_AVANT
		BL WAIT
		BL MOTEUR_DROIT_OFF
		BL MOTEUR_GAUCHE_OFF
		BL WAITS2
		BL WAITS2
		MOV r2,#0x120
		B	BUMPER_DROIT_VERIF
		
BUMPER_GAUCHE_ACTIF
		BL	LED_GAUCHE_ON
		BL	LED_DROIT_OFF
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ARRIERE
		BL MOTEUR_GAUCHE_ARRIERE
		BL WAITS2
		BL MOTEUR_DROIT_AVANT
		BL WAIT
		BL MOTEUR_DROIT_ARRIERE
		BL WAITS2
		MOV r2,#0x120
		B	BUMPER_GAUCHE_VERIF
		
WAIT 	ldr r4,=0xC11111
wait1	subs r4, #1
        bne wait1
		BX LR
		
WAITS2	ldr r4,=0x161FFFF
wait2	subs r4, #1
        bne wait2
		BX LR
		
;WAIT2 	mov r10,r4
;		ldr r4,=0x1AAAFF
;		subs r4,r10
;wait2	subs r4, #1
;        bne wait2
;		BX LR
		

		END