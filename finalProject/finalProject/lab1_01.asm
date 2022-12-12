include Irvine32.inc
BoxWidth = 1
.data
dot BYTE 0b3h

outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0
xyPosition COORD <100,5>
xyPosition2 COORD <120,10>
xyPosition3 COORD <90,7>
xyPosition4 COORD <70,7>

cellsWritten DWORD ?

.code
lab1_01 PROC

	INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
    mov outputHandle, eax ; save console handle
	call Clrscr


    mov ecx, 200
L1: push ecx
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dot,
       BoxWidth,   ; size of box line
       xyPosition3,   ; coordinates of first char
       ADDR count    ; output count
    pop ecx

    push ecx
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dot,
       BoxWidth,   ; size of box line
       xyPosition4,   ; coordinates of first char
       ADDR count    ; output count
    pop ecx

    mov ax, xyPosition.x
    sub ax,1
    mov xyPosition.x, ax


    cmp ax, 90
    ja L2
    
    cmp ax, 70
    jnb R2
    jb R1

R1: mov ax, 100
    mov xyPosition.x, ax
    jmp L2

R2: push ecx
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,   ; console output handle
       ADDR dot,   ; pointer to the top box line
       BoxWidth,   ; size of box line
       xyPosition,   ; coordinates of first char
       ADDR count    ; output count
    pop ecx

L2: 
    mov ax, xyPosition2.x
    sub ax,1
    mov xyPosition2.x, ax
    cmp ax, 90
    ja L3

    cmp ax, 70
    jnb R4
    jb R3

R3: mov ax, 120
    mov xyPosition2.x, ax
    jmp L3

R4: push ecx
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,   ; console output handle
       ADDR dot,   ; pointer to the top box line
       BoxWidth,   ; size of box line
       xyPosition2,   ; coordinates of first char
       ADDR count    ; output count
    pop ecx

L3: 
    mov eax, 500
    call Delay

    call Clrscr


    dec cx
    cmp cx, 0
    jne l1

    call WaitMsg
    call Clrscr

	ret

lab1_01 ENDP
END lab1_01