; M. Akil, T. Grandpierre, R. Kachouri : département IT - ESIEE Paris -
; 01/2013 - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui même)



		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		
		;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
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
		
		IMPORT	LED_INIT
		IMPORT	LED_DROIT_ON
		IMPORT	LED_GAUCHE_ON
		IMPORT	LED_GAUCHE_OFF
		IMPORT  LED_DROIT_OFF
		IMPORT  LED_DROIT_INVERSE	
		IMPORT	LED_GAUCHE_INVERSE
		
		IMPORT	BUMPER_INIT
		IMPORT	BUMPER_DROIT_VERIF
		IMPORT  BUMPER_GAUCHE_VERIF
		
		IMPORT	BOUTTON_INIT
		IMPORT	BOUTTON_DROIT_VERIF
		IMPORT  BOUTTON_GAUCHE_VERIF
		
		EXPORT  start
		EXPORT  loop


__main	


		;; BL Branchement vers un lien (sous programme)
		mov r11,#0x172
		; Configure les PWM + GPIO
		BL	LED_INIT
		BL	BUMPER_INIT
		BL	BOUTTON_INIT
		BL	MOTEUR_INIT
;; Phase 1 -> Avance un demi-temps
start	
		BL	LED_GAUCHE_ON
		BL	LED_DROIT_ON
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		MOV r5,#0x150
		BL 	WAIT

;; Phase 2 -> Avance un temps
loop	
		; Evalbot avance droit devant
		BL	LED_GAUCHE_OFF
		BL	LED_DROIT_ON
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		BL	LED_DROIT_ON
		BL	LED_GAUCHE_OFF
		MOV R5,#0x150
		
		; Avancement pendant une période (deux WAIT)
		BL  WAIT2
;; Phase 3 -> S'arrete un temps
loop2		
		BL	LED_GAUCHE_ON
		BL	LED_DROIT_OFF
		BL MOTEUR_DROIT_OFF
		BL MOTEUR_GAUCHE_OFF
		BL	LED_DROIT_OFF
		BL	LED_GAUCHE_ON
		MOV R5,#0x250
		
		BL WAIT2

		b	loop

;; Boucle d'attente pour la phase 1
WAIT 	ldr r4,=0xD557F
		b wait1
;; Boucle d'attente pour la phase 2 et 3
WAIT2	ldr r4,=0x1AAAFF
;WAIT	ldr r4, =0xAFFFFF 
wait1
		BL 	BUMPER_DROIT_VERIF
		BL 	BUMPER_GAUCHE_VERIF
		BL 	BOUTTON_DROIT_VERIF
		BL 	BOUTTON_GAUCHE_VERIF
		subs r4, #1
        bne wait1
		CMP r5,#0x150
		BEQ loop2
		CMP r5,#0x250
		BEQ loop
		
		b loop

		NOP
        END
