pausedScreen PROTO,     ; 宣告PROTO
	consoleH:DWORD,
	score:WORD

.data
	continueT BYTE "> Press ENTER to continue", 0
	exitT BYTE "> Press ENTER to exit", 0
	PauseT 	BYTE " ____   _   _   _ ____  _____ "
            BYTE "|  _ \ / \ | | | / ___|| ____|"
            BYTE "| |_) / _ \| | | \___ \|  _|  "
            BYTE "|  __/ ___ \ |_| |___) | |___ "
            BYTE "|_| /_/   \_\___/|____/|_____|"

.code

pausedScreen PROC,
	consoleH:DWORD,     ; 傳入Handle和當前的分數
	score:WORD

	LOCAL continueText:PTR BYTE     ; 設置變數
	LOCAL exitText:PTR BYTE
	LOCAL PauseText:PTR BYTE

	LOCAL count:DWORD
	LOCAL continuePos:COORD
	LOCAL exitPos:COORD
	LOCAL continueLength:DWORD
	LOCAL exitLength:DWORD
	LOCAL PausePos:COORD
	LOCAL cursorPos:COORD
	LOCAL cursorInfo:CONSOLE_CURSOR_INFO

	pushad          ; push所有暫存器
	call Clrscr     ; 清空畫面

	mov cursorInfo.dwSize, 100      ; 設置cursor的資訊
	mov cursorInfo.bVisible, 1
	INVOKE SetConsoleCursorInfo,    ; cursor設為可見
    	consoleH,
        ADDR cursorInfo

	mov continueText, OFFSET continueT      ; 將continueT的起始位置mov到continueText
	mov exitText, OFFSET exitT              ; 將exitT的起始位置mov到exitText
	mov PauseText, OFFSET PauseT            ; 將PauseT的起始位置mov到PauseText

	mov PausePos.x, 24          ; 設置即將印出的文字的xy坐標
	mov PausePos.y, 5
	mov continuePos.x, 24
	mov continuePos.y, 12
	mov exitPos.x, 24
	mov exitPos.y, 13
	mov cursorPos.x, 24
	mov cursorPos.y, 12

	mov ecx, 5      ; ecx設為5
Print:
	push ecx        ; 將ecx push起來
	INVOKE WriteConsoleOutputCharacter, ; 印出 Pause 字樣
		consoleH,
		PauseText,
		30,
		PausePos,
		ADDR count

	mov ebx, 30             ; 將Pause的長度(30)mov到ebx
	add PauseText, ebx      ; PauseText移動30
	add PausePos.y, 1       ; PausePos的y加一

	pop ecx             ; 將ecx pop出來

	LOOP Print          ; 將5行印出

	INVOKE Str_length, continueText		; 獲取 continue 長度
	mov continueLength, eax

	INVOKE WriteConsoleOutputCharacter,	    ; 印出continueT
		consoleH,
		continueText,
		continueLength,
		continuePos,
		ADDR count

	INVOKE Str_length, exitText		; 獲取 exitText 長度
	mov exitLength, eax

	INVOKE WriteConsoleOutputCharacter,	    ; 印出exitT
		consoleH,
		exitText,
		exitLength,
		exitPos,
		ADDR count

START:
    INVOKE SetConsoleCursorPosition,    ; 設置cursor位置
		consoleH,
        cursorPos

    call ReadChar
    .IF ax == 4800h             ; 如果按上
        sub cursorPos.y, 1      ; cursorPos的y減一
    .ENDIF
    .IF ax == 5000h             ; 如果按下
        add cursorPos.y, 1      ; cursorPos的y加一
    .ENDIF

    mov bx, continuePos.y       ; 將lowerbound移至bx
    dec bx                      ; bx減一
    .IF cursorPos.y == bx       ; 如果低於lowerbound
        add cursorPos.y, 1      ; cursorPos加一
    .ENDIF
    mov dx, exitPos.y           ; 將upperbound移至dx
    inc dx                      ; dx加一
    .IF cursorPos.y == dx       ; 如果高於upperbound
        sub cursorPos.y, 1      ; cursorPos加一
    .ENDIF

    mov bx, continuePos.y       ; bx存continue字樣的位置
    mov dx, exitPos.y           ; dx存exit字樣的位置
    .IF (ax == 1C0Dh) && (cursorPos.y == bx)    ; 若按下Enter且此時cursor在continue那行
        call Clrscr     ; 清空畫面
        popad           ; 將暫存器pop出來
        mov eax, 1      ; 以eax回傳下一步(1表示繼續遊戲)
        ret             ; 回到主程式
    .ENDIF
    .IF (ax == 1C0Dh) && (cursorPos.y == dx)    ; 若按下Enter且此時cursor在exit那行
        call Clrscr     ; 清空畫面
        popad           ; 將暫存器pop出來
        mov eax, 3      ; 以eax回傳下一步(3表示前往離開畫面)
        ret             ; 回到主程式
    .ENDIF

    jmp START


pausedScreen ENDP
