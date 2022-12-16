mapChange PROTO,            ; 宣告兩個PROTO
	consoleHandle:DWORD,
	level:BYTE

printNumber PROTO,
    consoleHandle:DWORD,
    level:BYTE

.data
	levelT  BYTE " _     _______     _______ _     "    ; level字樣
            BYTE "| |   | ____\ \   / / ____| |    "
            BYTE "| |   |  _|  \ \ / /|  _| | |    "
            BYTE "| |___| |___  \ V / | |___| |___ "
            BYTE "|_____|_____|  \_/  |_____|_____|"
    num1T   BYTE "   _    "         ; 數字藝術字體 1~10
            BYTE "  / |   "
            BYTE "  | |   "
            BYTE "  | |   "
            BYTE "  |_|   "
    num2T   BYTE "  ____  "
            BYTE " |___ \ "
            BYTE "   __) |"
            BYTE "  / __/ "
            BYTE " |_____|"
    num3T   BYTE "  _____ "
            BYTE " |___ / "
            BYTE "   |_ \ "
            BYTE "  ___) |"
            BYTE " |____/ "
    num4T   BYTE " _  _   "
            BYTE "| || |  "
            BYTE "| || |_ "
            BYTE "|__   _|"
            BYTE "   |_|  "
    num5T   BYTE "  ____  "
            BYTE " | ___| "
            BYTE " |___ \ "
            BYTE "  ___) |"
            BYTE " |____/ "
    num6T   BYTE "   __   "
            BYTE "  / /_  "
            BYTE " | '_ \ "
            BYTE " | (_) |"
            BYTE "  \___/ "
    num7T   BYTE "  _____ "
            BYTE " |___  |"
            BYTE "    / / "
            BYTE "   / /  "
            BYTE "  /_/   "
    num8T   BYTE "   ___  "
            BYTE "  ( _ ) "
            BYTE "  / _ \ "
            BYTE " | (_) |"
            BYTE "  \___/ "
    num9T   BYTE "   ___  "
            BYTE "  / _ \ "
            BYTE " | (_) |"
            BYTE "  \__, |"
            BYTE "    /_/ "
    num0T   BYTE "   ___  "
            BYTE "  / _ \ "
            BYTE " | | | |"
            BYTE " | |_| |"
            BYTE "  \___/ "

.code

mapChange PROC,
	consoleHandle:DWORD,    ; 傳入Handle和當前的level數
	levelNum:BYTE

	LOCAL levelText:PTR BYTE    ; 區域變數
	LOCAL levelLength:DWORD
	LOCAL count:DWORD
	LOCAL levelTPos:COORD
	LOCAL cursorInfo:CONSOLE_CURSOR_INFO

	pushad                  ; 把所有暫存器 push
	call Clrscr             ; 清除畫面

	mov levelText, OFFSET levelT    ; 將levelT的起始位置mov到levelText
	mov levelTPos.x, 16             ; levelPos的x設為16
	mov levelTPos.y, 9              ; levelPos的y設為9
	mov cursorInfo.dwSize, 100      ; cursor的size設為100
	mov cursorInfo.bVisible, 0      ; cursor的visible設為0

	INVOKE SetConsoleCursorInfo,    ; 設置cursor的大小(100)和可見度(0)
        consoleHandle,
        ADDR cursorInfo

	mov ecx, 5          ; ecx設為5(levelT一共有5行)
Print_level:
    push ecx            ; 將ecx push起來，以免後續動到
    INVOKE WriteConsoleOutputCharacter,     ; 印出level字樣
        consoleHandle,
        levelText,
        33,
        levelTPos,
        ADDR count
                            ; 調整下一行輸出的位子
    mov ebx, 33             ; 將level的長度(33)mov到ebx
    add levelText, ebx      ; levelText移動33
    add levelTPos.y, 1      ; levelPos的y加一

    pop ecx             ; 將ecx pop出來

    LOOP Print_level    ; 若ecx大於0，則跳回Print_level，直到5行全部印出


    INVOKE printNumber,    ; 呼叫Print_Number，印出當前level數字
        consoleHandle,
        levelNum

	INVOKE Sleep, 2000      ; 畫面保持2秒

	popad       ; 將所有暫存器 pop

	ret         ; 回到主程式
mapChange ENDP

printNumber PROC,          ; Print_Number函式需要傳入Handle和level數
    consoleHandle:DWORD,
    level:BYTE

    LOCAL print_count:DWORD     ; 區域變數
    LOCAL print_num:PTR BYTE
    LOCAL print_num_2:PTR BYTE
    LOCAL printPos:COORD
    LOCAL printPos_2:COORD

    pushad

    mov printPos.x, 53      ; 第一位數的x位置設為53
    mov printPos.y, 9       ; 第一位數的y位置設為9
    mov printPos_2.x, 61    ; 第二位數的x位置設為61
    mov printPos_2.y, 9     ; 第二位數的y位置設為9

    .IF level >=10      ; 如果level大於等於10
        jmp L           ; 則跳到印兩位數的部分 L
    .ENDIF

    .IF level == 1                      ; 若level為1，則print_num存num1T
        mov print_num, OFFSET num1T
    .ENDIF
    .IF level == 2
        mov print_num, OFFSET num2T     ; 若level為2，則print_num存num2T
    .ENDIF
    .IF level == 3
        mov print_num, OFFSET num3T     ; 若level為3，則print_num存num3T，以下以此類推
    .ENDIF
    .IF level == 4
        mov print_num, OFFSET num4T
    .ENDIF
    .IF level == 5
        mov print_num, OFFSET num5T
    .ENDIF
    .IF level ==6
        mov print_num, OFFSET num6T
    .ENDIF
    .IF level == 7
        mov print_num, OFFSET num7T
    .ENDIF
    .IF level == 8
        mov print_num, OFFSET num8T
    .ENDIF
    .IF level == 9
        mov print_num, OFFSET num9T
    .ENDIF

    mov ecx, 5          ; ecx設為5
START:
    push ecx            ; 開始印前先把ecx push起來，以免後續動到
    INVOKE WriteConsoleOutputCharacter,     ; 印出print_num的字樣
        consoleHandle,
        print_num,
        8,
        printPos,
        ADDR print_count
                            ; 調整下一行輸出的位子
    mov ebx, 8              ; 將數字的長度(8)mov到ebx
    add print_num, ebx      ; print_num移動8
    add printPos.y, 1       ; printPos的y加一

    pop ecx             ; 將ecx pop出來

    LOOP START          ; 若ecx大於0，則跳回START，直到5行全部印出

    jmp L_final         ; 跳至L_final

L:
    movzx ax, level     ; 將level mov到ax(被除數)
    mov bl, 10          ; bl=10 為除數
    div bl              ; 商(十位數)存在al，餘數(個位數)存在ah

    .IF al == 1                         ; 判斷十位數，存在print_num
        mov print_num, OFFSET num1T
    .ENDIF
    .IF al == 2
        mov print_num, OFFSET num2T
    .ENDIF
    .IF al == 3
        mov print_num, OFFSET num3T
    .ENDIF
    .IF al == 4
        mov print_num, OFFSET num4T
    .ENDIF
    .IF al == 5
        mov print_num, OFFSET num5T
    .ENDIF
    .IF al ==6
        mov print_num, OFFSET num6T
    .ENDIF
    .IF al == 7
        mov print_num, OFFSET num7T
    .ENDIF
    .IF al == 8
        mov print_num, OFFSET num8T
    .ENDIF
    .IF al == 9
        mov print_num, OFFSET num9T
    .ENDIF


    .IF ah == 1                         ; 判斷個位數，存在print_num_2
        mov print_num_2, OFFSET num1T
    .ENDIF
    .IF ah == 2
        mov print_num_2, OFFSET num2T
    .ENDIF
    .IF ah == 3
        mov print_num_2, OFFSET num3T
    .ENDIF
    .IF ah == 4
        mov print_num_2, OFFSET num4T
    .ENDIF
    .IF ah == 5
        mov print_num_2, OFFSET num5T
    .ENDIF
    .IF ah ==6
        mov print_num_2, OFFSET num6T
    .ENDIF
    .IF ah == 7
        mov print_num_2, OFFSET num7T
    .ENDIF
    .IF ah == 8
        mov print_num_2, OFFSET num8T
    .ENDIF
    .IF ah == 9
        mov print_num_2, OFFSET num9T
    .ENDIF
    .IF ah == 0
        mov print_num_2, OFFSET num0T
    .ENDIF

    mov ecx, 5                  ; 方法同上，印出十位數
L1:
    push ecx
    INVOKE WriteConsoleOutputCharacter,
        consoleHandle,
        print_num,
        8,
        printPos,
        ADDR print_count

    mov ebx, 8
    add print_num, ebx
    add printPos.y, 1

    pop ecx

    LOOP L1

    mov ecx, 5                  ; 方法同上，印出個位數
L2:
    push ecx
    INVOKE WriteConsoleOutputCharacter,
        consoleHandle,
        print_num_2,
        8,
        printPos_2,
        ADDR print_count

    mov ebx, 8
    add print_num_2, ebx
    add printPos_2.y, 1

    pop ecx

    LOOP L2

L_final:
    popad               ; 將暫存器pop出來

    ret                 ; 回到主程式
printNumber ENDP
