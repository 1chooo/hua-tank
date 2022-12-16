INCLUDE Irvine32.inc
INCLUDE InLevel.asm
INCLUDE EndScene.asm
INCLUDE Score.asm
INCLUDE MapChange.asm
INCLUDE PausedScreen.asm
INCLUDE StartScene.asm
; 組員公約:
; 	玩遊戲		eax = 1
; 	暫停		eax = 2
; 	結束畫面	eax = 3
; 	離開程式	eax = 4
.data
	windowTitleStr BYTE "Crossy Road",0
	consoleHandle    DWORD ?
	windowBound SMALL_RECT <0,0,80,25>					; 視窗大小
	score WORD 0
	changeScene BYTE 0
	levelNow BYTE 0

main EQU start@0
.code
main PROC

	INVOKE GetstdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle, eax
	
	INVOKE SetConsoleTitle, ADDR windowTitleStr			; 設定視窗標題

	INVOKE SetConsoleWindowInfo,						; 設定視窗大小
     	consoleHandle,
     	TRUE,
     	ADDR windowBound

	INVOKE printStart, consoleHandle					; 遊戲歡迎/開始畫面
	.IF eax == 3										; 跳到結束畫面	eax = 3
		jmp ExitProgram
	.ENDIF
	
restart:												; 從 level one 重新開始
	mov score, 0
	mov life, 3
	mov levelNow, 0
newLevelStart:											; 進入下一關
	inc levelNow
	INVOKE mapChange, consoleHandle, levelNow			; 印出切換關卡畫面
	call Clrscr
	INVOKE init, consoleHandle, levelNow				; 關卡初始化
	jmp play
resumeFormPause:										; 從暫停畫面回遊戲畫面
	INVOKE resume, consoleHandle
	INVOKE printScore, consoleHandle
play:													; 主要遊戲
	INVOKE controlSheep, consoleHandle					; 控制羊的動作
	.IF eax == 2										; 跳到暫停		eax = 2
		jmp pause
	.ENDIF
	INVOKE carsRun, consoleHandle						; 讓車跑起來
	.IF life == 0										; 生命值為零，結束遊戲
		jmp EndScene
	.ENDIF
	.IF sheepPosition.x == 79							; 走到最右邊，進入下一關
		jmp newLevelStart
	.ENDIF
	jmp play

pause:													; 切到暫停畫面
	INVOKE pausedScreen, consoleHandle, score
	.IF eax == 1										; 跳到玩遊戲	eax = 1
		jmp resumeFormPause
	.ENDIF
	.IF eax == 3										; 跳到結束畫面	eax = 3
		jmp EndScene
	.ENDIF

EndScene:												; 切到 GAME OVER 畫面
	INVOKE printChoices, score, consoleHandle
	.IF changeScene == 1								; 玩家選擇重新開始遊戲
		mov changeScene, 0
		jmp restart
	.ENDIF
	.IF changeScene == 4								; 玩家選擇結束程式
		mov changeScene, 0
		jmp ExitProgram
	.ENDIF
ExitProgram:											; 結束程式
	exit
main ENDP

END main
