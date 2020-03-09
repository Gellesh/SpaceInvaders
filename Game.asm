.MODEL SMALL

.STACK 64
.DATA                                                ;Main Menu GUI 
PLAYER1 DB 'PLAYER1:','$'                            ;Main Menu GUI 
PLAYER2 DB 'PLAYER2:','$'                            ;Main Menu GUI 
PLAYER1NAME DB 30,?,30 DUP(?)   ;FI                  ;Main Menu GUI 
PLAYER2NAME DB 30,?,30 DUP(?)                        ;Main Menu GUI 
STARTGAME DB '[1] START GAME','$'                    ;Main Menu GUI 
STARTCHATTING DB '[2] START CHATTING','$'            ;Main Menu GUI 
EXITGAME DB '[3] EXIT GAME','$'                      ;Main Menu GUI 
S_INIT_HEALTH EQU 3    ;how many lifes each ship got and starts with    
S1HEALTH DB ?           ;actual in-game health at any given time      
S2HEALTH DB ?           ;actual in-game health at any given time      
S1SHIELD DB 0           ;1-> ship is shielded 0->ship is not shielded 
S2SHIELD DB 0           ;1-> ship is shielded 0->ship is not shielded
SELECTARROWPOSX DB 24
SELECTARROWPOSY DB 10
ARROW DB 0AFH
PWRSPEED EQU 16         ;SPEED OF POWER (HIGHER IS SLOWER)
HEALTH DB 'HEALTH:','$'
THREE DB '                                XXXXXXXXX',10,13,'                                     XXX',10,13,'                                   XX',10,13,'                                     XX',10,13,'                                       XX',10,13,'                                      XX',10,13,'                                XXXXXX','$'
TWO DB '                               XXXX',10,13,'                              XX  XX',10,13,'                                 XX',10,13,'                                XX',10,13,'                               XX',10,13,'                              XX',10,13,'                             XXXXXXX','$'
ONE DB '                               XXX',10,13,'                             XX XX',10,13,'                                XX',10,13,'                                XX',10,13,'                                XX',10,13,'                                XX',10,13,'                             XXXXXXXX','$'

GFIG DB 0DBH           ;SHAPE OF SHIP PIXEL
BORDER DB 80 DUP(2DH),'$'  ;SHAPE OF BORDER
FIRSTBORDERX EQU 0200H     ;POS OF TOP BORDER
SECONDBORDERX EQU 1700H    ;POS OF BOTTOM BORDER
S_LENGTH EQU 5             ;LENGTH OF SHIP 
SMAXBULLETS EQU 5         ;MAX NO. OF BULLETS PER SHIP PER SCREEN
S1_BULLET_COUNT DB 0      ;COUNTS BULLETS FOR EACH SHIP
S2_BULLET_COUNT DB 0                                  

S1_BULLET_POS DW SMAXBULLETS DUP(?)  ;ARRAY FOR BULLETS POSITIONS
S2_BULLET_POS DW SMAXBULLETS DUP(?)                              

S1_BULLET_SPD DB SMAXBULLETS DUP(?)  ;ARRAY FOR BULLETS SPEEDS 1=RIGHT 2=LEFT 3=IDLE
S2_BULLET_SPD DB SMAXBULLETS DUP(?)

S1_BULLET_SUP DB SMAXBULLETS DUP(0)  ;ARRAY FOR SUPER BULLETS
S2_BULLET_SUP DB SMAXBULLETS DUP(0)

VARKEY DW ?                          ;STORES THE CLICKED KEYS

S1_CURRENTPOS DW  0A00H  ;INTIALLY EQUAL TO S1_STARTPOS // THE POS OF TOP EDGE OF SHIP1 

S2_CURRENTPOS DW  0A4FH  ;INTIALLY EQUAL TO S2_STARTPOS    THE POS OF TOP EDGE OF SHIP2


powers DB  3h,'$',0dbh,'$',23h,'$',15h,'$'  
powerpos DB 3,3,3,3                                     ;;varibles used in powers function
names  DB 'health$','rewall$','shield$','super$$'

delay_counter DB 0
count DW 0 
f7 DB 7       ;;varibles used in powers function
f2 DB 2
divs DB 4 
newloop DB 0   
color1 DB 00000001b
color2 DB 00000100b            ;COLORS USED IN GUI
bordercolor DB 00001100b 
shieldcolor1 DB 10011111b
shieldcolor2 DB 11001111b 

WINSTR DB 'WINS$'
CONTINUE DB 'Press Any Key To Return To Main Menu','$'
paused DB   'GAME IS PAUSED','$'
resume DB   'Press Any Key To Continue','$'   
value  Db    ?
;---------------------------------------------------------------------------------------------                                      
.CODE         
MAIN PROC FAR             
MOV AX,@DATA
MOV DS,AX 



MOV AX,0600H
MOV BH,07H
MOV CX,0000H 
MOV DX,184FH                    ;CLEAR THE SCREEN
INT 10H 

MOV AH,3
MOV BH,0
INT 10H   

CALL GETPLAYERSNAME
JMP DLABEL19
DLABEL9:
CALL WINORLOSE                 ;CALLED ONLY WHEN SOMEPLAYER WINS
DLABEL19:
CALL MAINMENU
CALL INITIALIZE
CALL COUNT_DOWN

;-------------------------------|
;NOW LETS START THE GAME :D     |
;-------------------------------|



DLABEL3:        ;;LOOP  TILL ONE OF PLAYERS WIN
CALL DELAY          
CALL UPDATE
CALL power  
CALL CHECK_KEYS
CALL CHECKBULLETS
CALL DRAWBULLETS 
CALL CHECKGAMESTATUS

JMP DLABEL3

ENDPROGRAM:
MOV AX,0600H
MOV BH,07H
MOV CX,0000H 
MOV DX,184FH
INT 10H
MOV AX,4c00h
INT 21h 
HLT
JMP ENDPROGRAM
         HLT
MAIN ENDP
;------------------------------------------------- 
;-------------------------------------------------
;-------------------------------------------------
;-------------------------------------------------

;--------------------------------------------------------|
;MAINMENU FUNCTION  -   FUNCTION TO PRESENT A MENU FOR   |
;PLAYER TO SELECT FROM IT  A SPECIFIC MODE               |
;(STARTGAME,CHAT,EXITGAME)                               |
;--------------------------------------------------------|
MAINMENU  PROC 
    
MOV AX,700H
MOV BH,7
MOV CX,0
MOV DX,184FH
INT 10H

MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,25
MOV DH,10
INT 10H

MOV AH,9
MOV DX,OFFSET STARTGAME         ;;PRINT START GAME
INT 21H

MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,25
MOV DH,11
INT 10H

MOV AH,9
MOV DX,OFFSET STARTCHATTING       ;;PRINT START CHATTING
INT 21H            

MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,25
MOV DH,12
INT 10H

MOV AH,9
MOV DX,OFFSET EXITGAME           ;;PRINT EXIT GAME
INT 21H

MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,SELECTARROWPOSX           ;;SET POSITION OF ARROW TO SELECT
MOV DH,SELECTARROWPOSY
INT 10H               

MOV AH,2
MOV DL,ARROW
INT 21H 

DLABEL6:
MOV AH,0
INT 16H

CMP AH,48H                ;;CHECK IF UP KEY IS PRESSED
JZ MOVARROWUP             
CMP AH,50H                ;;CHECK IF DOWN KEY IS PRESSED
JZ MOVARROWDOWN 
CMP AH,1CH                ;;CHECK IF ENTER PRESSED
JZ ENTERMODE              


MOVARROWUP:
CMP SELECTARROWPOSY,10    ;;CHECK IF ARROW ALREADY ON TOP ROW SO ARROW POSITION REMAINS SAME
JZ DLABEL6 
DEC SELECTARROWPOSY       ;; MOVE ARROW UP
JMP DLABEL7

MOVARROWDOWN:
CMP SELECTARROWPOSY,12    ;;CHECK IF ARROW ALREADY ON DOWN ROW SO ARROW POSITION REMAINS SAME
JZ DLABEL6 
INC SELECTARROWPOSY      ;;MOVE ARROW DOWN
JMP DLABEL7

ENTERMODE:
CMP SELECTARROWPOSY,10     
JZ DLABEL8:                ;;SELECT START GAME MODE
CMP SELECTARROWPOSY,11
JZ DLABEL6                 ;;SELECT CHAT MODE
CMP SELECTARROWPOSY,12
JZ ENDPROGRAM              ;;EXIT PROGRAM
DLABEL7:
CALL MAINMENU


DLABEL8: 

                          RET
MAINMENU                ENDP 
;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------    
;--------------------------------------------------------------------------------------- 
;--------------------------------------------------------|
;GETPLAYERSNAME FUNCTION  -   FUNCTION GET PLAYER NAMES  |
;BEFORE THE GAME STARTS                                  |
;--------------------------------------------------------|
GETPLAYERSNAME PROC 
    
MOV AX,700H
MOV BH,7
MOV CX,0                     
MOV DX,184FH
INT 10H

              
MOV AH,3
MOV BH,0
INT 10H

MOV AH,2                       ;ADJUST CURSOR POSTION
MOV DL,10
MOV DH,10
INT 10H

MOV AH,3
MOV BH,0
INT 10H    

MOV AH,9
MOV DX,OFFSET Player1
INT 21H


MOV AH,0AH
MOV DX,OFFSET PLAYER1NAME     ;;GET FIRST PLAYER NAME
INT 21H 






MOV CL,PLAYER1NAME[1]
ADD CL,3 
MOV CH,0
MOV SI,CX
MOV PLAYER1NAME+SI,'$' 

MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,10                         ;ADJUST CURSOR POSTION
MOV DH,14
INT 10H

MOV AH,3
MOV BH,0
INT 10H  

MOV AH,9
MOV DX,OFFSET Player2
INT 21H

MOV AH,0AH
MOV DX,OFFSET PLAYER2NAME     ;;GET SECOND PLAYER NAME
INT 21H

MOV CL,PLAYER2NAME[1]
ADD CL,3
MOV CH,0
MOV SI,CX
MOV PLAYER2NAME+SI,'$'
    
                          RET
GETPLAYERSNAME                ENDP
;-------------------------------------------------

;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------
;--------------------------------------------------------|
;INITALIZE FUNCTION  - RESPONSIBLE TO SET ALL VARIABLES  |   
;TO THEIR INITAIL VALUE                                  |      
;--------------------------------------------------------|    
INITIALIZE PROC 
    
MOV S1_CURRENTPOS,0A00H  
MOV S2_CURRENTPOS,0A4FH    
MOV S1HEALTH,S_INIT_HEALTH
MOV S2HEALTH,S_INIT_HEALTH
MOV S1SHIELD,0
MOV S2SHIELD,0              ;RESETTING HEALTH AND SHIELDS     
MOV SI,0                                                      
MOV CX,4                                                      
PWR_ADJ:                                                      
MOV powerpos[SI],3          ;RESETS POWER POSITIONS           
INC SI                                                        
LOOP PWR_ADJ                                                  
                                                              
MOV SI,0                                                      
REINIT:                                                       
MOV S1_BULLET_SPD[SI],3     ;RESET BULLETS POSITIONS AND TYPES 
MOV S2_BULLET_SPD[SI],3
MOV S1_BULLET_SUP[SI],0
MOV S2_BULLET_SUP[SI],0
INC SI
CMP SI,SMAXBULLETS
JNZ REINIT
RET
INITIALIZE ENDP
;---------------------------------------------------------------------------------------     
;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------    

;--------------------------------------------------------|
;COUNT_DOWN FUNCTION  -   FUNCTION TO COUNT 3..2..1      |
;BEFORE GAME STARTS                                      |
;--------------------------------------------------------|
COUNT_DOWN          PROC

MOV AX,700H
MOV BH,7
MOV CX,0
MOV DX,184FH
INT 10H

MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,0
MOV DH,4
INT 10H

MOV AH,3
MOV BH,0
INT 10H
 
CALL DELAYCOUNTDOWN 
 
MOV AH,9
MOV DX,OFFSET THREE        ;;PRINT # 3
INT 21H  

CALL DELAYCOUNTDOWN

MOV AX,700H
MOV BH,7
MOV CX,0
MOV DX,184FH
INT 10H


MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,0
MOV DH,4
INT 10H

MOV AH,3
MOV BH,0
INT 10H


MOV AH,9
MOV DX,OFFSET TWO         ;;PRINT # 2
INT 21H

CALL DELAYCOUNTDOWN

MOV AX,700H
MOV BH,7
MOV CX,0
MOV DX,184FH
INT 10H


MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,0
MOV DH,4
INT 10H

MOV AH,3
MOV BH,0
INT 10H
  
MOV AH,9
MOV DX,OFFSET ONE        ;;PRINT # 1
INT 21H


CALL DELAYCOUNTDOWN

     
                         RET
COUNT_DOWN                ENDP

;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------    
;--------------------------------------------------------|
;DELAYCOUNTDOWN FUNCTION-FUNCTION TO STOP THE PROGRAM FOR|
;1 SECOND USED IN COUNT DOWN                             |              
;--------------------------------------------------------| 
DELAYCOUNTDOWN PROC
    
MOV CX,0FH
MOV DX,4240H
MOV AH,86H
INT 15H

RET
DELAYCOUNTDOWN ENDP  
;---------------------------------------------------------------------------------------
;--------------------------------------------------------|
;DELAY FUNCTION  -   FUNCTION TO STOP THE PROGRAM FOR    |
;MILLI SECONDS                                           |
;--------------------------------------------------------|    
DELAY PROC
    
MOV CX,00h
MOV DX,0AC40h
MOV AH,86H
INT 15H

RET
DELAY ENDP   
;---------------------------------------------------------------------------------------        
;---------------------------------------------------------------------------------------  
;---------------------------------------------------------------------------------------    
;----------------------------------------------------------|
;UPDATE FUNCTION  -   FUNCTION TO DRAW STATUS BAR THAT     |
;INCLUDE PLAYER NAMES,HEALTH,BORDERS AND SHIPS AND UPDATE  |
;THEIR POSTIONS AND HEALTH EVERY LOOP                      |
;----------------------------------------------------------|
UPDATE                PROC
    
MOV AX,700H
MOV BH,7
MOV CX,0
MOV DX,184FH                         ;;CLEAR SCREEN
INT 10H
     
MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,0
MOV DH,0
INT 10H

MOV AH,3
MOV BH,0
INT 10H    
    
MOV AH,9
MOV DX,OFFSET Player1   
INT 21H

MOV AH,3h
MOV BH,0h
INT 10h

MOV AL, 1
MOV BH, 0
MOV BL, color1 
MOV CH,0
MOV CL,Player1Name[1]                ;;PRINT 1ST PLAYER NAME
PUSH DS
POP ES     
MOV BP, OFFSET Player1Name[2]
MOV AH, 13h
INT 10h

MOV AH,2
MOV DL,0
MOV DH,1
INT 10H

MOV AH,9
MOV DX,OFFSET HEALTH                 ;;FIRST PLAYER HEALTH
INT 21H

                 
MOV AH,9
MOV BH,0
MOV AL,03h
MOV BL,COLOR1
MOV CL,S1HEALTH  
MOV CH,0
INT 10h

MOV AH,2
MOV DX,69
SUB DL,S_INIT_HEALTH
INT 10H        

MOV AH,9
MOV DX,OFFSET Player2
INT 21H

MOV AH,3h
MOV BH,0h
INT 10h


MOV AL, 1
MOV BH, 0
MOV BL, color2 
MOV CH,0                             ;;print 2nd player name
MOV CL,Player2Name[1]
PUSH DS
POP ES     
MOV BP, OFFSET Player2Name[2]
MOV AH, 13h
INT 10h


MOV AH,2
MOV DX,69
SUB DL,S_INIT_HEALTH
MOV DH,1
INT 10H

MOV AH,9
MOV DX,OFFSET HEALTH
INT 21H


MOV AH,9                             ;;SECOND PLAYER HEALTH
MOV BH,0
MOV AL,03h
MOV BL,4
MOV CL,S2HEALTH  
MOV CH,0
INT 10h
          

          

                           
CALL DRAW_BORDERS                    ;;DRAW THE TWO SHIPS AND THE BOARDERs
CALL DRAW_SHIP1
CALL DRAW_SHIP2

                         RET
UPDATE                ENDP
;---------------------------------------------------------------------------------------   
;---------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------    
;--------------------------------------------------------|
;CHECK_KEYS FUNCTION  - FUNCTION TO CHECK IF ANY KEY IS  | 
;PRESSED BY ANY PLAYER TO UPDATE GAME WITH INPUTS        |
;--------------------------------------------------------|
CHECK_KEYS PROC 
    
        
CMP AH,11H      ;;CHECK IF W KEY IS PRESSED
JZ S1Up

CMP AH,1FH      ;;CHECK IF S KEY IS PRESSED
JZ S1Down

CMP AH,72       ;;CHECK IF UP ARROW  KEY IS PRESSED
JZ S2Up

CMP AH,80       ;;CHECK IF DOWN ARROW KEY IS PRESSED
JZ S2Down

CMP AH,19h       ;;CHECK IF PAUSE KEY IS PRESSED
JZ pause

JMP DLABEL4

S1Up:
MOV AX,S1_currentpos
CMP AH,3h                      
JZ DLABEL4
SUB  S1_currentpos,0100h       ;;SHIFT SHIP1 UP
JMP  DLABEL4

S1Down:
MOV AX,S1_currentpos
CMP AH,12h
JZ DLABEL4                     
ADD  S1_currentpos,0100h       ;;SHIFT SHIP1 DOWN
JMP  DLABEL4

S2Up:
MOV AX,S2_currentpos
CMP AH,3h
JZ DLABEL4
SUB  S2_currentpos,0100h       ;;SHIFT SHIP2 UP
JMP  DLABEL4 

S2Down:
MOV AX,S2_currentpos
CMP AH,12h
JZ DLABEL4
ADD  S2_currentpos,0100h       ;;SHIFT SHIP2 DOWN
JMP  DLABEL4


Pause:
MOV AH,2
MOV DL,35
MOV DH,12
INT 10h                        ;;PAUSE GAME
MOV AH,9
MOV DX,OFFSET paused
INT 21h

MOV AH,2
MOV DL,30
MOV DH,14
INT 10h
MOV AH,9
MOV DX,OFFSET resume
INT 21h                        ;;WAIT FOR KEY TO RESUME GAME
MOV AH,0CH                                                                                                     
INT 21H
MOV AH,0
INT 16h

JMP DLABEL4
     
      
DLABEL4:
MOV AH,0CH                                                                                                     
INT 21H
    
RET
CHECK_KEYS ENDP
;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------      
;---------------------------------------------------------------------------------------  
;---------------------------------------------------------------------------------------    
;----------------------------------------------------------|
;CHECK BULLETS FUNCTION :CHECK IF BULLETS KEYS ARE PRESSED,|     
;   MOVES CURRENT BULLETS AND APPLY LOGIC OF POWERS UP     |            
;----------------------------------------------------------| 
CHECKBULLETS PROC


MOV AX,VARKEY   ;;PUTS THE PRESSED KEY BACK INTO AX TO
                ;;GET FIRE INPUT FROM PLAYERS
CMP AH,39H      ;;CHECK IF SPACEBAR KEY IS PRESSED
JZ S1FIRE

CMP AH,1CH      ;;CHECK IF ENTER IS PRESSED
JZ S2FIRE


JMP INITMOVE 

S1FIRE:                   ;PLAYER 1 FIRE LOGIC
MOV BL,S1_BULLET_COUNT
MOV BH,0   
CMP BL,SMAXBULLETS
JNZ FWD
MOV BL,0
MOV S1_BULLET_COUNT,0     ;RESETS THE COUNTER
FWD:
     

CMP S1_BULLET_SPD[BX],3   ;CHECKS IF THE PLAYER COULD FIRE
JNZ INITMOVE



MOV AL,S1_BULLET_COUNT    
MOV AH,0
MOV BX,2
MUL BX
MOV BX,AX
MOV AX,S1_CURRENTPOS
MOV S1_BULLET_POS[BX],AX        ;GETS LOCATION FOR THE BULLET
ADD S1_BULLET_POS[BX], 0201H
MOV BL,S1_BULLET_COUNT
MOV BH,0
MOV S1_BULLET_SPD[BX],1
INC S1_BULLET_COUNT
JMP INITMOVE

S2FIRE:                        ;PLAYER 1 FIRE LOGIC                
                                                                   
MOV BL,S2_BULLET_COUNT                                             
                                                                   
MOV BH,0                                                           
CMP BL,SMAXBULLETS                                                 
JNZ FWD2                       ;RESETS THE COUNTER                 
MOV BL,0                                                           
MOV S2_BULLET_COUNT,0                                              
FWD2:                                                              
                               ;CHECKS IF THE PLAYER COULD FIRE    
CMP S2_BULLET_SPD[BX],3                                            
JNZ INITMOVE                                                       
                                                                   
MOV AL,S2_BULLET_COUNT                                             
MOV AH,0                                                           
MOV BX,2                                                           
MUL BX                                                             
MOV BX,AX                                                          
MOV AX,S2_CURRENTPOS                                               
MOV S2_BULLET_POS[BX],AX                                           
ADD S2_BULLET_POS[BX], 01FFH         ;GETS LOCATION FOR THE BULLET 

MOV BL,S2_BULLET_COUNT
MOV BH,0
MOV S2_BULLET_SPD[BX],2
INC S2_BULLET_COUNT

INITMOVE:

MOV SI,0 
MOVALLBULLETS:           ;MOVES BULLETS
CMP SI,SMAXBULLETS
JZ EXITBUPDATE
CMP S1_BULLET_COUNT,SMAXBULLETS
JNZ FD1
MOV S1_BULLET_COUNT,0
FD1:

MOV BL,S1_BULLET_COUNT
MOV BH,0
CMP S1_BULLET_SPD[BX],3  ;CHECK FOR IDLE AND IGNORE
JZ INCS1COUNT
CMP S1_BULLET_SPD[BX],2  ;IF SPEED IS 2 MOVE LEFT
JZ DECS1XLOOP
MOV AL,S1_BULLET_COUNT
MOV AH,0
MOV BX,2
MUL BX
MOV BX,AX
INC S1_BULLET_POS[BX]    ;OTHERWISE MOVE RIGHT
JMP INCS1COUNT
DECS1XLOOP:
MOV AL,S1_BULLET_COUNT
MOV AH,0
MOV BX,2
MUL BX
MOV BX,AX
DEC S1_BULLET_POS[BX]
INCS1COUNT:
INC S1_BULLET_COUNT
CMP S1_BULLET_COUNT,SMAXBULLETS
JNZ MOVES2BULLETS
MOV S1_BULLET_COUNT,0 

MOVES2BULLETS:
CMP S2_BULLET_COUNT,SMAXBULLETS
JNZ FD2
MOV S2_BULLET_COUNT,0
FD2:
MOV BL,S2_BULLET_COUNT
MOV BH,0
CMP S2_BULLET_SPD[BX],3  ;CHECK FOR IDLE AND IGNORE
JZ INCS2COUNT
CMP S2_BULLET_SPD[BX],2  ;IF SPEED IS 2 MOVE LEFT
JZ DECS2XLOOP
MOV AL,S2_BULLET_COUNT
MOV AH,0
MOV BX,2
MUL BX
MOV BX,AX
INC S2_BULLET_POS[BX]    ;OTHERWISE MOVE RIGHT
JMP INCS2COUNT
DECS2XLOOP:
MOV AL,S2_BULLET_COUNT
MOV AH,0
MOV BX,2
MUL BX
MOV BX,AX
DEC S2_BULLET_POS[BX]
INCS2COUNT:
INC SI
INC S2_BULLET_COUNT
CMP S2_BULLET_COUNT,SMAXBULLETS
JNZ MOVALLBULLETS
MOV S2_BULLET_COUNT,0

JMP MOVALLBULLETS


EXITBUPDATE:

RET
CHECKBULLETS ENDP
;--------------------------------------------------------------------------------------- 
;---------------------------------------------------------------------------------------  
;---------------------------------------------------------------------------------------    
;--------------------------------------------------------|
;DRAW BULLETS FUNCTION                                   |
;--------------------------------------------------------|
  
DRAWBULLETS    PROC 
    
MOV SI,0 
DRAWALLBULLETS:           
CMP SI,SMAXBULLETS
JZ EXITBULLETDRAW 
MOV BL,S1_BULLET_COUNT ;
MOV BH,0
CMP S1_BULLET_SPD[BX],3  ;CHECK FOR IDLE AND IGNORE
JZ INCS1DCOUNT

MOV AL,S1_BULLET_COUNT
MOV AH,0
MOV BX,2
MUL BX
MOV BX,AX
MOV DX,S1_BULLET_POS[BX]    ;MOVE S1 POSITION OF BULLETS
MOV AH,2
INT 10h
MOV BL,S1_BULLET_COUNT
MOV BH,0 
CMP S1_BULLET_SPD[BX],2         ;DETERMINES WHETHER TO MOVE LEFT OR RIGHT
JZ LEFTB1
CMP S1_BULLET_SUP[BX],1
JNZ NORM1
MOV DL,0AFh
JMP DRAWB1
NORM1:
MOV DL,62
JMP DRAWB1
LEFTB1:
MOV DL,60
DRAWB1:
PUSH AX
PUSH BX
PUSH CX
PUSH DX
MOV AL,DL
MOV AH,9
MOV CX,1
MOV BH,0
MOV BL,color1
INT 10h
POP DX
POP CX
POP BX
POP AX

INCS1DCOUNT:
INC S1_BULLET_COUNT
CMP S1_BULLET_COUNT,SMAXBULLETS
JNZ DRAWS2BULLETS
MOV S1_BULLET_COUNT,0
  
DRAWS2BULLETS:
;mov ah, 0
;int 16h
MOV BL,S2_BULLET_COUNT ;
MOV BH,0
CMP S2_BULLET_SPD[BX],3  ;CHECK FOR IDLE AND IGNORE
JZ INCS2DCOUNT

MOV AL,S2_BULLET_COUNT
MOV AH,0
MOV BX,2
MUL BX
MOV BX,AX
MOV DX,S2_BULLET_POS[BX]    ;MOVE S2 POSITION OF BULLETS
MOV AH,2
INT 10h
MOV BL,S2_BULLET_COUNT
MOV BH,0
CMP S2_BULLET_SPD[BX],2         ;DETERMINES WHETHER TO MOVE LEFT OR RIGHT
JZ LEFTB2
MOV DL,62
JMP DRAWB2
LEFTB2:
CMP S2_BULLET_SUP[BX],1
JNZ NORM2
MOV DL,0AEh
JMP DRAWB2
NORM2:
MOV DL,60
DRAWB2:
PUSH AX
PUSH BX
PUSH CX
PUSH DX
MOV AL,DL
MOV AH,9
MOV CX,1
MOV BH,0
MOV BL,color2
INT 10h
POP DX
POP CX
POP BX
POP AX

INCS2DCOUNT:
INC S2_BULLET_COUNT
CMP S2_BULLET_COUNT,SMAXBULLETS
JNZ INCSI
MOV S2_BULLET_COUNT,0
INCSI:

INC SI
JMP DRAWALLBULLETS
EXITBULLETDRAW:
MOV AH,2
MOV DH,30h
MOV DL,50h
INT 10h

                RET
DRAWBULLETS    ENDP   

;---------------------------------------------------------------------------------------  
;--------------------------------------------------------------------------------------- 
;---------------------------------------------------------------------------------------    
;CHECKGAMESTATUS FUNCTION: CALCULATES HEALTH AND BULLET STATUS AND|
;DETERMINES GAME STATUS                                           |
;-----------------------------------------------------------------| 
CHECKGAMESTATUS PROC
                                                                                                        
MOV SI,0                                                                                                
CHECKB1L1:                                   ;Bullets form ship 1 reacting to ship 2                    
MOV AX,SI                                                                                               
MOV BX,2                                                                                                
MUL BX                                                                                                  
MOV BX,AX                                                                                               
CMP S1_BULLET_SPD[SI],3                                                                                 
JZ CHECKB2L1                                 ;checks bullet's position with respect to ships            
MOV CX,S2_CURRENTPOS                                                                                    
DEC CL                                                                                                  
DEC CL                                                                                                  
CMP BYTE PTR S1_BULLET_POS[BX],CL                                                                       
JNZ CHPWR1                                                                                              
MOV S1_BULLET_SPD[SI],3                                                                                 
INC BX                                                                                                  
CMP BYTE PTR S1_BULLET_POS[BX],CH                                                                       
JL RSUP1                                                                                                
MOV DH,CH                                                                                               
ADD DH,4                                                                                                
CMP BYTE PTR S1_BULLET_POS[BX],DH                                                                       
JG RSUP1                                                                                                
                                              ;shielded enemies shot not get hurt                       
CMP S2SHIELD,1                                                                                          
JNZ S2NOTS                                                                                              
MOV S2SHIELD,0                                                                                          
JMP CONT                                                                                                
S2NOTS:                                                                                                 
CMP S1_BULLET_SUP[SI],1                                                                                 
JNZ NORMALDEC1                                                                                          
DEC S2HEALTH                                                                                            
MOV S1_BULLET_SUP[SI],0                                                                                 
CMP S2HEALTH,0                                                                                          
JZ DLABEL9                                                                                              
NORMALDEC1:                                                                                             
DEC S2HEALTH                                                                                            
JMP CHECKB2L1                                                                                           
CHPWR1:                                        ;checks if the bullet got a power                        
CMP BYTE PTR S1_BULLET_POS[BX],27h             ;and acts based upon the type of it                      
JNZ CHECKB1L2                                                                                           
INC BX                                                                                                  
MOV DI,count                                                                                            
MOV DL,powerpos[DI]                                                                                     
CMP BYTE PTR S1_BULLET_POS[BX],DL                                                                       
JNZ CHECKB2L1                                                                                           
CMP count,0                                                                                             
JZ HEAL1                                                                                                
CMP count,1                                                                                             
JZ REFLECT1                                                                                             
CMP count,2                                                                                             
JZ SHIELD1                                                                                              
CMP count,3                                                                                             
JZ SUPER1                                                                                               
SUPER1:                                                                                                 
MOV S1_BULLET_SUP[SI],1                                                                                 
JMP CHECKB1L2                                                                                           
SHIELD1:                                                                                                
MOV S1SHIELD,1
MOV powerpos[DI],17h                                                                                           
JMP CHECKB2L1                                                                                           
REFLECT1:                                                                                               
MOV S1_BULLET_SPD[SI],2                                                                                 
JMP CHECKB2L1                                                                                           
HEAL1:                                                                                                  
CMP S1HEALTH,S_INIT_HEALTH                                                                              
JZ CHECKB2L1                                                                                            
INC S1HEALTH                                                                                            
MOV powerpos[DI],17h                                                                                    
JMP CHECKB2L1                                                                                           
                                                                                                        
                                                                                                        
CHECKB1L2:                                   ;Bullets form ship 1 reacting to ship 1                    
MOV BX,AX                                                                                               
MOV CX,S1_CURRENTPOS                                                                                    
INC CL                                                                                                  
CMP BYTE PTR S1_BULLET_POS[BX],CL                                                                       
JNZ CHECKB2L1                                                                                           
MOV S1_BULLET_SPD[SI],3                                                                                 
INC BX                                                                                                  
CMP BYTE PTR S1_BULLET_POS[BX],CH                                                                       
JL CHECKB2L1                                                                                            
MOV DH,CH                                                                                               
ADD DH,4                                                                                                
CMP BYTE PTR S1_BULLET_POS[BX],DH                                                                       
JG CHECKB2L1                                                                                            
CMP S1SHIELD,1                                                                                          
JZ  adjusts1                                                                                            
DEC S1HEALTH                                                                                            
adjusts1:                                                                                               
MOV S1SHIELD,0                                                                                          
JMP CHECKB2L1                                                                                           
RSUP1:                                                                                                  
MOV S1_BULLET_SUP[SI],0                                                                                 
                                                                                                        
                                                                                                        
CHECKB2L1:                                  ;Bullets form ship 2 reacting to ship 1                     
                                                                                                        
MOV BX,AX                                                                                               
CMP S2_BULLET_SPD[SI],3                                                                                 
JZ CONT                                                                                                 
MOV CX,S1_CURRENTPOS                                                                                    
INC CL                                                                                                  
INC CL                                     ;checks bullet's position with respect to ships              
CMP BYTE PTR S2_BULLET_POS[BX],CL                                                                       
JNZ CHPWR2                                                                                              
MOV S2_BULLET_SPD[SI],3                                                                                 
INC BX                                                                                                  
CMP BYTE PTR S2_BULLET_POS[BX],CH                                                                       
JL RSUP2                                                                                                
MOV DH,CH                                                                                               
ADD DH,4                                                                                                
CMP BYTE PTR S2_BULLET_POS[BX],DH                                                                       
JG RSUP2                                                                                                
CMP S1HEALTH,0                                                                                          
JZ CONT                                                                                                 
CMP S1SHIELD,1                                                                                          
JNZ S1NOTS                                ;shielded enemies shot not get hurt                           
MOV S1SHIELD,0                                                                                          
JMP CONT                                                                                                
S1NOTS:                                                                                                 
                                                                                                        
CMP S2_BULLET_SUP[SI],1                                                                                 
JNZ NORMALDEC2                                                                                          
DEC S1HEALTH                                                                                            
MOV S2_BULLET_SUP[SI],0                                                                                 
CMP S1HEALTH,0                                                                                          
JZ DLABEL9                                                                                              
NORMALDEC2:                                                                                             
DEC S1HEALTH                                                                                            
JMP CONT                                                                                                
                                                                                                        
                                            ;checks if the bullet got a power                           
CHPWR2:                                     ;and acts based upon the type of it                         
                                                                                                        
CMP BYTE PTR S2_BULLET_POS[BX],27h                                                                      
JNZ CHECKB2L2                                                                                           
INC BX                                                                                                  
MOV DI,count                                                                                            
MOV DL,powerpos[DI]                                                                                     
CMP BYTE PTR S2_BULLET_POS[BX],DL                                                                       
JNZ CONT                                                                                                
CMP count,0                                                                                             
JZ HEAL2                                                                                                
CMP count,1                                                                                             
JZ REFLECT2                                                                                             
CMP count,2                                                                                             
JZ SHIELD2                                                                                              
CMP count,3                                                                                             
JZ SUPER2                                                                                               
SUPER2:                                                                                                 
MOV S2_BULLET_SUP[SI],1                                                                                 
JMP CONT                                                                                                
SHIELD2:                                                                                                
MOV S2SHIELD,1 
MOV powerpos[DI],17h                                                                                          
JMP CONT                                                                                                
REFLECT2:                                                                                               
MOV S2_BULLET_SPD[SI],1                                                                                 
JMP CONT                                                                                                
HEAL2:                                                                                                  
CMP S2HEALTH,S_INIT_HEALTH                                                                              
JZ CONT                                                                                                 
INC S2HEALTH                                                                                            
MOV powerpos[DI],17h                                                                                    
JMP CONT                                                                                                
                                                                                                        
                                                                                                        
CHECKB2L2:                               ;Bullets form ship 2 reacting to ship 2                          
MOV BX,AX                                                                                               
MOV CX,S2_CURRENTPOS                                                                                    
DEC CL                                                                                                  
CMP BYTE PTR S2_BULLET_POS[BX],CL
JNZ CONT
MOV S2_BULLET_SPD[SI],3
INC BX
CMP BYTE PTR S2_BULLET_POS[BX],CH
JL CONT  
MOV DH,CH
ADD DH,4 
CMP BYTE PTR S2_BULLET_POS[BX],DH
JG CONT 
CMP S2SHIELD,1
JZ  adjusts2 
DEC S2HEALTH
adjusts2:
MOV S2SHIELD,0
JMP CONT
RSUP2:
MOV S2_BULLET_SUP[SI],0

CONT:
CMP S1HEALTH,0                      
JZ DLABEL9
CMP S2HEALTH,0
JZ DLABEL9
INC SI
CMP SI,SMAXBULLETS
JNZ CHECKB1L1



RET
CHECKGAMESTATUS ENDP
;--------------------------------------------------------------------------------------- 
;---------------------------------------------------------------------------------------         
;---------------------------------------------------------------------------------------    
;--------------------------------------------------------|
;DRAW_BORDERS FUNCTION  - FUNCTION TO DRAW BORDERS OF    |
;SHIPS                                                   |
;--------------------------------------------------------|
DRAW_BORDERS    PROC
MOV AH,3
MOV BH,0
INT 10h

MOV AH,2
MOV DX,firstborderx           ;adjust cursor of topborder
INT 10h
    
MOV AL, 1
MOV BH, 0
MOV BL, bordercolor
MOV CX,80
PUSH DS
POP ES     
MOV BP, OFFSET border
MOV AH, 13h
INT 10h  


MOV AH,2
MOV DX,secondborderx          ;adjust cursor of bottomborder
INT 10h

MOV AL, 1
MOV BH, 0
MOV BL, bordercolor
MOV CX,80
PUSH DS
POP ES     
MOV BP, OFFSET border
MOV AH, 13h
INT 10h
                RET
draw_borders    ENDP             
;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------    
;--------------------------------------------------------|
;DRAW_SHIP1 FUNCTION  - FUNCTION TO DRAW SHIP OF FIRST   |
;PLAYER                                                  |
;--------------------------------------------------------|
draw_SHIP1    PROC


MOV DX,S1_currentpos       ;--MOVE CURSOR TO STARING POS
MOV CX,s_length
gDs1_first:
MOV AH,2
INT 10h
PUSH DX
MOV AH,9                      ;--DRAW FIRST LINE OF SHIP
MOV BH,0
MOV AL,gfig
PUSH CX
MOV CX,1
CMP S1SHIELD,1
JZ change_color
MOV BL,color1
JMP nott
change_color:
MOV BL,shieldcolor1
nott:
INT 10h
POP CX
POP DX
ADD DX,0100h
LOOP gDs1_first 

MOV AH,3
MOV BH,0
INT 10h

MOV DX,S1_currentpos       ;--ADJUST SECOND LINE CURSOR
ADD DX,0101h

MOV CX,s_length 
SUB CX,2
gDs1_second:
MOV AH,2 
INT 10h
PUSH DX
MOV AH,9                      ;--DRAW second LINE OF SHIP
MOV BH,0
MOV AL,gfig
PUSH CX
MOV CX,1
CMP S1SHIELD,1
JZ change_color0
MOV BL,color1
JMP nott0
change_color0:
MOV BL,shieldcolor1
nott0:
INT 10h
POP CX
POP DX 
ADD DX,0100H
LOOP gDs1_second
                RET
draw_SHIP1    ENDP             
;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------    
;--------------------------------------------------------|
;DRAW_SHIP2 FUNCTION  - FUNCTION TO DRAW SHIP OF SECOND  |
;PLAYER                                                  |
;--------------------------------------------------------|
  
draw_SHIP2    PROC


MOV DX,S2_currentpos       ;--MOVE CURSOR TO STARING POS
MOV CX,s_length
gDs2_first:
MOV AH,2
INT 10h
PUSH DX
MOV AH,9                      ;--DRAW FIRST LINE OF SHIP
MOV BH,0
MOV AL,gfig
PUSH CX
MOV CX,1
CMP S2SHIELD,1
JZ change_color2
MOV BL,color2
JMP nott1
change_color2:
MOV BL,shieldcolor2
nott1:
INT 10h
POP CX
POP DX
ADD DX,0100h
LOOP gDs2_first 


MOV DX,S2_currentpos       ;--ADJUST SECOND LINE CURSOR
SUB DX,0001h
ADD DX,0100H

MOV CX,s_length 
SUB CX,2
gDs2_second:
MOV AH,2 
INT 10h
PUSH DX
MOV AH,9                      ;--DRAW second LINE OF SHIP
MOV BH,0
MOV AL,gfig
PUSH CX
MOV CX,1
CMP S2SHIELD,1
JZ change_color3
MOV BL,color2
JMP nott2
change_color3:
MOV BL,shieldcolor2
nott2:
INT 10h
POP CX
POP DX 
ADD DX,0100H
LOOP gDs2_second
                RET
draw_SHIP2    ENDP  
;---------------------------------------------------------------------------------------    
;--------------------------------------------------------------------------------------- 
;---------------------------------------------------------------------------------------
;--------------------------------------------------------|
;POWER FUNCTION                                          |
;--------------------------------------------------------| 
;--------------------------------------------------------|
power    PROC     
CMP newloop,0
JNZ onrun: 
MOV DI,OFFSET powerpos
CMP [DI],3
JNZ onrun
INC newloop    
MOV AH,2ch
INT 21h 
MOV AX,0          ;;Generate Random number
MOV AL,DL
DIV DIVs
MOV CX,AX
MOV AL,AH
MOV AH,0
MOV count,AX 
   
onrun: 

MOV SI,OFFSET powers
MOV AX,count
MUL f2
ADD SI,AX
MOV DI,OFFSET powerpos
ADD DI,count

CMP [DI],17h
JZ next



MOV AH,2
MOV DH,[DI]
MOV DL,27h
                  ;;Adjust cursor of powers
INT 10h

MOV DX,SI
MOV AH,9          ;;DRAW SELECTED POWER
INT 21h 

MOV AH,2
MOV DH,30h
MOV DL,50h
                  
INT 10h

INC delay_counter
CMP delay_counter,PWRSPEED
JNZ next2

MOV delay_counter,0  
  
INC [DI]

next2:
  
RET

next:

MOV [DI],3
MOV newloop,0

RET

power ENDP
;--------------------------------------------------------------------------------------- 
;---------------------------------------------------------------------------------------    
;-----------------------------------------------------------------------|
;WINORLOSE FUNCTION     DISPLAY WINNER PLAYER AND                       |
;                       SWITCH BACK TO MAIN MENU                        |
;-----------------------------------------------------------------------| 
WINORLOSE  PROC 
    
MOV AX,700H
MOV BH,7
MOV CX,0
MOV DX,184FH
INT 10H
    
CMP S2HEALTH,0
JZ P1WIN                                                                
CMP S1HEALTH,0
JZ P2WIN

P1WIN:

MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,30
MOV DH,10
INT 10H

MOV SI,2
U&D_bord:

MOV AH,9
MOV BH,0
MOV AL,2d                                ;;DRAW WON SCREEN 
MOV CX,20
MOV BL,bordercolor
INT 10h

MOV AH,2
MOV DL,30
MOV DH,16
INT 10H
DEC SI
JNZ U&D_bord:

MOV AH,2
MOV DL,35
MOV DH,13
INT 10H

MOV AL, 1
MOV BH, 0
MOV BL, 00001010B 
MOV CH,0
MOV CL,Player1Name[1]                    ;;PRINT 1ST PLAYER NAME
PUSH DS
POP ES     
MOV BP, OFFSET Player1Name[2]
MOV AH, 13h
INT 10h

MOV AH,3h
MOV BH,0h
INT 10H
ADD DL,1

MOV AL, 1
MOV BH, 0
MOV BL,00001010B 
MOV CH,0
MOV CL,4                    
PUSH DS
POP ES     
MOV BP, OFFSET WINSTR
MOV AH, 13h
INT 10h

MOV AH,2
MOV DL,30
MOV DH,20
INT 10H

MOV AH,9
MOV DX,OFFSET CONTINUE
INT 21H

JMP DLABEL18:

P2WIN:
MOV AH,3
MOV BH,0
INT 10H

MOV AH,3
MOV BH,0
INT 10H

MOV AH,2
MOV DL,30
MOV DH,10
INT 10H

MOV SI,2
U&D_bord2:

MOV AH,9
MOV BH,0
MOV AL,2d
MOV CX,20
MOV BL,bordercolor
INT 10h

MOV AH,2
MOV DL,30
MOV DH,16
INT 10H
DEC SI
JNZ U&D_bord2:

MOV AH,2
MOV DL,35
MOV DH,13
INT 10H

MOV AL, 1
MOV BH, 0
MOV BL, 00001010B 
MOV CH,0
MOV CL,Player2Name[1]                    ;PRINT 1ST PLAYER NAME
PUSH DS
POP ES     
MOV BP, OFFSET Player2Name[2]
MOV AH, 13h
INT 10h

MOV AH,3h
MOV BH,0h
INT 10H
ADD DL,1

MOV AL, 1
MOV BH, 0
MOV BL,00001010B 
MOV CH,0
MOV CL,4                    
PUSH DS
POP ES     
MOV BP, OFFSET WINSTR
MOV AH, 13h
INT 10h

MOV AH,2
MOV DL,24
MOV DH,20
INT 10H

MOV AH,9
MOV DX,OFFSET CONTINUE
INT 21H

DLABEL18:
MOV AH,0                                 ;;WAIT FOR KEY PRESSED TO RETURN TO MAIN MENU
INT 16h
    
RET
WINORLOSE ENDP
;---------------------------------------------------------------------------------------    
;---------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------    
    
    END MAIN        ; End of the program 