; Adresse horloge
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; Adresse Port F
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; Adresse DIR
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; Adresse DR2R
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Adresse DEN
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)


LED_DROITE			EQU		0x10

LED_GAUCHE			EQU		0x20
; Broches
LED_TOUS			EQU		0x30		; led1 & led2 sur broche 4 et 5

; Durée du clignotement
DUREE   			EQU     0x002FFFFF
						
						
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		;; The EXPORT command specifies that a symbol can be accessed by other shared objects or executables.
		EXPORT	LED_INIT
		EXPORT	LED_DROIT_ON
		EXPORT  LED_GAUCHE_ON
		EXPORT  LED_DROIT_OFF
		EXPORT  LED_GAUCHE_OFF
		EXPORT  LED_DROIT_INVERSE	
		EXPORT	LED_GAUCHE_INVERSE


LED_INIT	
		; ;; Mise en place de l'horloge						
		ldr r7, = SYSCTL_PERIPH_GPIO  			;; RCGC2
		ldr	r0, [r7]
        ORR	r0, #0x00000020   ;;bit 20 = PWM recoit clock: ON (p271) 
        str r0, [r7]
		
		; ;; 3 temps horloge pour attendre la mise en place
		nop
		nop	   
		nop
	
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

		ldr r0, = LED_TOUS
		
        ldr r7, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)	
        str r0, [r7]
		
		ldr r7, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 	
        str r0, [r7]
		
		ldr r7, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensité de sortie (2mA)		
        str r0, [r7]
		
		 mov r2, #0x000       					;; pour eteindre LED
     
		; allumer la led broche 4 (BROCHE4_5)
		;mov r3, #LED_TOUS		;; Allume LED1&2 portF broche 4&5 : 00110000
		
		ldr r7, = GPIO_PORTF_BASE + (LED_TOUS<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 
		
		BX	LR	; FIN du sous programme d'init.

;Enable PWM0 (bit 0) et PWM2 (bit 2) p1145 
;Attention ici c'est les sorties PWM0 et PWM2
;qu'on controle, pas les blocks PWM0 et PWM1!!!
LED_DROIT_ON
		;Enable sortie PWM0 (bit 0), p1145 
		ldr r2,[r7]
		ORR r2,#LED_DROITE
		str r2,[r7]
		BX	LR
		
LED_GAUCHE_ON
		;Enable sortie PWM0 (bit 0), p1145 
		ldr r2,[r7]
		ORR r2,#LED_GAUCHE
		str r2,[r7]
		BX	LR
		
LED_DROIT_OFF
		;Enable sortie PWM0 (bit 0), p1145 
		ldr r2,[r7]
		AND r2,#LED_GAUCHE
		str r2,[r7]
		BX	LR
		
LED_GAUCHE_OFF
		;Enable sortie PWM0 (bit 0), p1145 
		ldr r2,[r7]
		AND r2,#LED_DROITE
		str r2,[r7]
		BX	LR
		
LED_DROIT_INVERSE
		ldr r2,[r7]
		EOR r2,#LED_DROITE
		str r2,[r7]
		BX	LR
		
LED_GAUCHE_INVERSE
		ldr r2,[r7]
		EOR r2,#LED_GAUCHE
		str r2,[r7]
		BX	LR

		END