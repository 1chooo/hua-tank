include Irvine32.inc
printStartScene PROTO
decStrLevel PROTO, levelNumDec:WORD
decStrScore PROTO, scoreNumDec:WORD
decStrLives PROTO, livesNumDec:WORD
decStrBogys PROTO, bogysNumDec:WORD

printLevel PROTO, xyPosInit:COORD
printScore PROTO, xyPosInit:COORD
printLives PROTO, xyPosInit:COORD
printBogys PROTO, xyPosInit:COORD

bogyWalking PROTO, xyPosInBogy:COORD
bogyClear   PROTO, xyPosInBogy:COORD
printGreenLine PROTO, xyPosInLine:COORD

tankWalking PROTO, xyPosInit:COORD
tankClear   PROTO, xyPosInit:COORD

; 	玩遊戲   eax = 1
; 	暫停		eax = 2
; 	結束畫面	eax = 3
; 	離開程式	eax = 4

.data
	; 視窗的變數們
	windowTitleStr BYTE "Hua Tank V.S Bogy",0 ; 標題
	windowBound    SMALL_RECT <0,0,125,25>    ; 視窗大小
	consoleHandle  DWORD ?

	xyPos COORD   <6,5>
	xyPosTank COORD   <7,15>
	xyPosBogy0 COORD   <120,5>
	xyPosBogy1 COORD   <110,9>
	xyPosBogy2 COORD   <145,13>
	xyPosBogy3 COORD   <130,17>
	xyPosBogy4 COORD   <113,21>
	xyPosBogy5 COORD   <122,25>
	cells_Written DWORD ?

	; 開始畫面的字
	startStr BYTE " _________    _      ____  _____ ___  ____   ____   ____  ______      ______     ___      ______ ____  ____ "
			 BYTE "|  _   _  |  / \    |_   \|_   _|_  ||_  _| |_  _| |_  _.' ____ \    |_   _ \  .'   `.  .' ___  |_  _||_  _|"
			 BYTE "|_/ | | \_| / _ \     |   \ | |   | |_/ /     \ \   / / | (___ \_|     | |_) |/  .-.  \/ .'   \_| \ \  / /  " 
			 BYTE "    | |    / ___ \    | |\ \| |   |  __'.      \ \ / /   _.____`.      |  __'.| |   | || |   ____  \ \/ /   " 
			 BYTE "   _| |_ _/ /   \ \_ _| |_\   |_ _| |  \ \_     \ ' /_  | \____) | _  _| |__) \  `-'  /\ `.___]  | _|  |_   " 
			 BYTE "  |_____|____| |____|_____|\____|____||____|     \_/(_)  \______.'(_)|_______/ `.___.'  `._____.' |______|  "

	;印開始畫面的提示字
	enterMsg BYTE "Press ‘E’ to enter"
	leaveMsg BYTE "Press ‘L’ to leave"

	;印坦克
	startTank BYTE "       \                "
			  BYTE "       _\______         "
			  BYTE "      /        \=======D"
			  BYTE " ____|_HUA_TANK_\_____  "
			  BYTE "/ ___WHERE_ARE_YOU?__ \ "
			  BYTE "\/ _===============_ \/ "
			  BYTE "  \-===============-/   "
	;印Bogy
	startBogy BYTE " (\_/) "
			  BYTE " |OvO| "
			  BYTE "/ HUA \"
			  BYTE "\| X |/"
			  BYTE " |_|_| "

	gameIntro BYTE "*****************************************************************"
              BYTE "*                      Game Introduction:                       *"
              BYTE "*            Control the Hua Tank to kill the Bogy.             *"
              BYTE "*             Don't let Bogy cross the green line,              *"
			  BYTE "*                or your life will shock down!!                 *"
              BYTE "*   Start with 3 lives, once the live reaches zero, you lose!!  *"
              BYTE "*     Kill the last monsters, if you still alive, you win!!     *"
              BYTE "*                                                               *"
              BYTE "*                   How to control the tank:                    *"
              BYTE "*               + press 'up'    to move up                      *"
              BYTE "*               + press 'down'  to move down                    *"
              BYTE "*               + press 'right' to fire bullet                  *"
              BYTE "*                                                               *"
              BYTE "*                         How to play:                          *"
              BYTE "*               + press 'space' to start game                   *"
              BYTE "*               + press 'P'     to pause game                   *"
              BYTE "*****************************************************************"

	gameTank  BYTE "  __    "
			  BYTE " Hua\==D"
			  BYTE "(Tank)  "

	clearTank BYTE "        "
			  BYTE "        "
			  BYTE "        "

	gameBogy  BYTE "(\_/)"
			  BYTE "|OvO|"
			  BYTE "|_|_|"

	clearBogy BYTE "     "
			  BYTE "     "
			  BYTE "     "

	bullet BYTE "NOWORK",0
	clearBullet BYTE "      ",0

	line BYTE "|",0
	greenColor WORD 0Ah

	yellowColor WORD 0Eh

	level BYTE "Level: ",0
	state BYTE "State: ",0
	score BYTE "Score: ",0
	lives BYTE "Lives: ",0
	bogys BYTE "Bogies:",0

	levelNum WORD 1
	levelStr BYTE 4 DUP(?)

	paused BYTE "Paused ",0
	playing BYTE "Playing",0

	scoreNum WORD 0
	scoreStr BYTE 4 DUP(?)

	livesNum WORD 100
	livesStr BYTE 4 DUP(?)
	
	bogysNum WORD 5
	bogysStr BYTE 4 DUP(?)

	gameBgTB BYTE 110 DUP("*"),0
	gameBgM  BYTE "*", 108 DUP(" "), "*",0	  

.code

main PROC
	INVOKE GetstdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle, eax
	
	INVOKE SetConsoleTitle, ADDR windowTitleStr			; 設定視窗標題
	
	INVOKE SetConsoleWindowInfo,						; 設定視窗大小
     	consoleHandle,
     	TRUE,
     	ADDR windowBound
	
	INVOKE printStartScene

Ex:	.IF eax == 4        ;直接離開
		call Clrscr
		jmp ExitProgram
	.ENDIF

	;print test Bogy
GameLoop:
	Invoke tankWalking, xyPosTank
	.IF xyPosBogy0.x < 107
		INVOKE bogyWalking, xyPosBogy0
	.ENDIF
	.IF xyPosBogy1.x < 107
		INVOKE bogyWalking, xyPosBogy1
	.ENDIF
	.IF xyPosBogy2.x < 107
		INVOKE bogyWalking, xyPosBogy2
	.ENDIF
	.IF xyPosBogy3.x < 107
		INVOKE bogyWalking, xyPosBogy3
	.ENDIF
	.IF xyPosBogy4.x < 107
		INVOKE bogyWalking, xyPosBogy4
	.ENDIF
	.IF xyPosBogy5.x < 107
		INVOKE bogyWalking, xyPosBogy5
	.ENDIF

	push eax
	mov eax, 500
	call Delay
	pop eax

	.IF xyPosBogy0.x < 107
		INVOKE bogyClear, xyPosBogy0
	.ENDIF
	.IF xyPosBogy1.x < 107
		INVOKE bogyClear, xyPosBogy1
	.ENDIF
	.IF xyPosBogy2.x < 107
		INVOKE bogyClear, xyPosBogy2
	.ENDIF
	.IF xyPosBogy3.x < 107
		INVOKE bogyClear, xyPosBogy3
	.ENDIF
	.IF xyPosBogy4.x < 107
		INVOKE bogyClear, xyPosBogy4
	.ENDIF
	.IF xyPosBogy5.x < 107
		INVOKE bogyClear, xyPosBogy5
	.ENDIF

	
	INVOKE printGreenLine, xyPos
	sub xyPosBogy0.x, 10
	sub xyPosBogy1.x, 2
	sub xyPosBogy2.x, 3
	sub xyPosBogy3.x, 4
	sub xyPosBogy4.x, 5
	sub xyPosBogy5.x, 6

	.IF xyPosBogy0.x < 16
		mov xyPosBogy0.x, 107
		sub livesNum, 1
		INVOKE printLives, xyPos
		.IF livesNum == 0
			mov eax, 4 ;之後要改3
			jmp Ex		
		.ENDIF
	.ENDIF
	.IF xyPosBogy1.x < 16
		mov xyPosBogy1.x, 107
		sub livesNum, 1
		INVOKE printLives, xyPos
		.IF livesNum == 0
			mov eax, 4 ;之後要改3
			jmp Ex		
		.ENDIF
	.ENDIF
	.IF xyPosBogy2.x < 16
		mov xyPosBogy2.x, 107
		sub livesNum, 1
		INVOKE printLives, xyPos
		.IF livesNum == 0
			mov eax, 4 ;之後要改3
			jmp Ex		
		.ENDIF
	.ENDIF
	.IF xyPosBogy3.x < 16
		mov xyPosBogy3.x, 107
		sub livesNum, 1
		INVOKE printLives, xyPos
		.IF livesNum == 0
			mov eax, 4 ;之後要改3
			jmp Ex		
		.ENDIF
	.ENDIF
	.IF xyPosBogy4.x < 16
		mov xyPosBogy4.x, 107
		sub livesNum, 1
		INVOKE printLives, xyPos
		.IF livesNum == 0
			mov eax, 4 ;之後要改3
			jmp Ex		
		.ENDIF
	.ENDIF
	.IF xyPosBogy5.x < 16
		mov xyPosBogy5.x, 107
		sub livesNum, 1
		INVOKE printLives, xyPos
		.IF livesNum == 0
			mov eax, 4 ;之後要改3
			jmp Ex		
		.ENDIF
	.ENDIF
	
	jmp GameLoop



	call WaitMsg

ExitProgram:
	exit
main ENDP

printStartScene PROC
	LOCAL cursorInfo:CONSOLE_CURSOR_INFO
	mov cursorInfo.dwSize, 100
	mov cursorInfo.bVisible, 0
	INVOKE SetConsoleCursorInfo,
    	consoleHandle,
        ADDR cursorInfo

	; 清空畫面
	call Clrscr

	mov ecx, 6
	mov esi, 0

; 印開始畫面的標題
ShowStartStr:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR [startStr + esi],
		108,
		xyPos,
		ADDR cells_Written

	add esi, 108
	inc xyPos.y
	pop ecx
	loop ShowStartStr

; 印開始畫面的選項
PrintOption:
    add xyPos.y, 7
    add xyPos.x, 48

    INVOKE WriteConsoleOutputCharacter,
        consoleHandle,
        ADDR enterMsg,
        SIZEOF enterMsg,
        xyPos,
        ADDR cells_Written

    add xyPos.y, 2

    INVOKE WriteConsoleOutputCharacter,
        consoleHandle,
        ADDR LeaveMsg,
        SIZEOF LeaveMsg,
        xyPos,
        ADDR cells_Written

	mov ecx, 7
	mov esi, 0
	mov xyPos.x, 20
	mov xyPos.y, 15

PrintStartTank:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR [startTank + esi],
		24,
		xyPos,
		ADDR cells_Written

	add esi, 24
	inc xyPos.y
	pop ecx
	loop PrintStartTank

	mov ecx, 5
	mov esi, 0
	mov xyPos.x, 85
	mov xyPos.y, 16

PrintStartBogy:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR [startBogy + esi],
		7,
		xyPos,
		ADDR cells_Written

	add esi, 7
	inc xyPos.y
	pop ecx
	loop PrintStartBogy

StartOrNot:
    call ReadChar

	.IF ax == 1265h     ;press e to start game
        call Clrscr
		mov xyPos.x, 28
		mov xyPos.y, 7

		mov ecx, 17
		mov esi, 0
		jmp PrintIntro
    .ENDIF
    .IF ax == 266ch     ;press l to leave
		mov eax, 4
		call Clrscr
        ret
    .ENDIF
	jmp StartOrNot

PrintIntro:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR [gameIntro + esi],
		65,
		xyPos,
		ADDR cells_Written

	add esi, 65
	inc xyPos.y
	pop ecx
	loop PrintIntro

GameOrNot:
    call ReadChar
	.IF ax == 3920h     ;press space to start game
        call Clrscr
		mov xyPos.x, 5
		mov xyPos.y, 4
		jmp PrintGameSceneTop
	.ENDIF
	jmp GameOrNot

PrintGameSceneTop:
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR gameBgTB,
		110,
		xyPos,
		ADDR cells_Written
	inc xyPos.y

	mov ecx, 24
PrintGameScene:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR gameBgM,
		110,
		xyPos,
		ADDR cells_Written
	inc xyPos.y
	pop ecx
	loop PrintGameScene

	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR gameBgTB,
		110,
		xyPos,
		ADDR cells_Written
	inc xyPos.y

	INVOKE printGreenLine, xyPos
	
PrintBar:
	mov xyPos.x, 5
	mov xyPos.y, 2
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR level,
		SIZEOF level,
		xyPos,
		ADDR cells_Written

	INVOKE printLevel, xyPos

	mov xyPos.x, 29
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR state,
		SIZEOF state,
		xyPos,
		ADDR cells_Written
	
	mov xyPos.x, 56
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR score,
		SIZEOF score,
		xyPos,
		ADDR cells_Written

	INVOKE printScore, xyPos

	mov xyPos.x, 80
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR lives,
		SIZEOF lives,
		xyPos,
		ADDR cells_Written

	INVOKE printLives, xyPos

	mov xyPos.x, 104
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR bogys,
		SIZEOF bogys,
		xyPos,
		ADDR cells_Written

	INVOKE printBogys, xyPos

	ret
printStartScene ENDP

printLevel PROC,
	xyPosInit:COORD
	mov xyPosInit.x, 12
	mov xyPosInit.y, 2

	mov dx, levelNum
	INVOKE decStrLevel, dx

	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR levelStr,
		4,
		xyPosInit,
		ADDR cells_Written
	ret
printLevel ENDP

printScore PROC,
	xyPosInit:COORD
	mov xyPosInit.x, 63
	mov xyPosInit.y, 2

	mov dx, scoreNum
	INVOKE decStrScore, dx

	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR scoreStr,
		4,
		xyPosInit,
		ADDR cells_Written
	ret
printScore ENDP

printLives PROC,
	xyPosInit:COORD
	mov xyPosInit.x, 87
	mov xyPosInit.y, 2

	mov dx, livesNum
	INVOKE decStrLives, dx

	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR livesStr,
		4,
		xyPosInit,
		ADDR cells_Written
	ret
printLives ENDP

printBogys PROC,
	xyPosInit:COORD
	mov xyPosInit.x, 111
	mov xyPosInit.y, 2

	mov dx, bogysNum
	INVOKE decStrBogys, dx

	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR bogysStr,
		4,
		xyPosInit,
		ADDR cells_Written
	ret
printBogys ENDP

bogyWalking PROC,
	xyPosInBogy:COORD
	mov ecx, 3
	mov esi, 0

	;mov ebx, xyPosInBogy.y
printBogy:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR [gameBogy + esi],
		5,
		xyPosInBogy,
		ADDR cells_Written
	add esi, 5
	inc xyPosInBogy.y
	pop ecx
	loop printBogy
	
	ret
bogyWalking ENDP

bogyClear PROC,
	xyPosInBogy:COORD
	mov ecx, 3
	mov esi, 0
removeBogy:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR [clearBogy + esi],
		5,
		xyPosInBogy,
		ADDR cells_Written
	add esi, 5
	inc xyPosInBogy.y
	pop ecx
	loop removeBogy
	ret
bogyClear ENDP

tankWalking PROC,
	xyPosInit:COORD
	mov ecx, 3
	mov esi, 0

	;mov ebx, xyPosInit.y
printTank:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR [gameTank + esi],
		8,
		xyPosInit,
		ADDR cells_Written
	add esi, 8
	inc xyPosInit.y
	pop ecx
	loop printTank
	ret
tankWalking ENDP

tankClear PROC,
	xyPosInit:COORD
	mov ecx, 3
	mov esi, 0
removeTank:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR [clearTank + esi],
		8,
		xyPosInit,
		ADDR cells_Written
	add esi, 8
	inc xyPosInit.y
	pop ecx
	loop removeTank
	ret
tankClear ENDP

printGreenLine PROC,
	xyPosInLine:COORD
	mov xyPosInLine.x, 20
	mov xyPosInLine.y, 5

	mov ecx, 24
	mov esi, 0
PrintLine:
	push ecx
	INVOKE WriteConsoleOutputAttribute,
		consoleHandle,
		ADDR greenColor,
		1,
		xyPosInLine,
		ADDR cells_Written

	INVOKE WriteConsoleOutputCharacter,
		consoleHandle,
		ADDR line,
		1,
		xyPosInLine,
		ADDR cells_Written
	inc xyPosInLine.y
	pop ecx
	loop PrintLine
	ret
printGreenLine ENDP

decStrLevel PROC,
	levelNumDec:WORD
	mov ecx, 4					;WORD型態最高4位數
	mov dl, 10					;除數
	mov ax, levelNumDec			;被除數
change:
	push ecx
	div dl
	add ah, '0'					;餘數轉成字存到levelNum_inLevel
	dec ecx
	mov [levelStr + ecx], ah
	movzx ax, al				;商繼續除
	pop ecx
	loop change
	ret
decStrLevel ENDP

decStrScore PROC,
	scoreNumDec:WORD
	mov ecx, 4					;WORD型態最高4位數
	mov dl, 10					;除數
	mov ax, scoreNumDec			;被除數
change:
	push ecx
	div dl
	add ah, '0'					;餘數轉成字存到levelNum_inLevel
	dec ecx
	mov [scoreStr + ecx], ah
	movzx ax, al				;商繼續除
	pop ecx
	loop change
	ret
decStrScore ENDP

decStrLives PROC,
	livesNumDec:WORD
	mov ecx, 4					;WORD型態最高4位數
	mov dl, 10					;除數
	mov ax, livesNumDec			;被除數
change:
	push ecx
	div dl
	add ah, '0'					;餘數轉成字存到levelNum_inLevel
	dec ecx
	mov [livesStr + ecx], ah
	movzx ax, al				;商繼續除
	pop ecx
	loop change
	ret
decStrLives ENDP

decStrBogys PROC,
	bogysNumDec:WORD
	mov ecx, 4					;WORD型態最高4位數
	mov dl, 10					;除數
	mov ax, bogysNumDec			;被除數
change:
	push ecx
	div dl
	add ah, '0'					;餘數轉成字存到levelNum_inLevel
	dec ecx
	mov [bogysStr + ecx], ah
	movzx ax, al				;商繼續除
	pop ecx
	loop change
	ret
decStrBogys ENDP

END main