initScore PROTO, outPutHandle:DWORD
countScore PROTO, sheepPos_X:WORD, roadPos_x:WORD, outPutHandle:DWORD
printScore PROTO, outPutHandle:DWORD
decStr PROTO, scoreDec:WORD
.data
	score_Text BYTE "SCORE: "				;分數訊息
	score_initPos COORD <0, 1>				;分數初始位置
	score_Pos COORD <0, 1>					;要印的分數位置
	printScoreLenth DWORD 4					;要印的分數長度
	tokenswritten DWORD ?
	score_inLevel BYTE 4 DUP(?)				;分數字串

.code

initScore PROC,								;一開始印分數訊息
	outPutHandle:DWORD
	mov ebx, score_initPos
	mov score_Pos, ebx
	INVOKE WriteConsoleOutputCharacter, 	;印分數訊息
		outPutHandle,
		ADDR score_Text,
		LENGTHOF score_Text,
		score_Pos,
		ADDR tokenswritten
	add score_Pos.x, LENGTHOF score_Text	;將分數要印的位置增加分數訊息的長度(印在分數訊息後)
	mov dx, score
	INVOKE decStr, dx						;分數轉字串
	INVOKE printScore, outPutHandle			;印分數
	ret
initScore ENDP

countScore PROC,							;計算分數
	sheepPos_X:WORD,
	roadPos_x:WORD,
	outPutHandle:DWORD

	mov bx, sheepPos_x						;若羊的 x 座標等於路的右邊，增加一分
	.IF bx == roadPos_x
		inc score
	.ENDIF
	
	mov dx, score
	INVOKE decStr, dx						;分數轉字串
	INVOKE printScore, outPutHandle			;印分數

	ret
countScore ENDP

printScore PROC,							;印分數
	outPutHandle:DWORD

	INVOKE WriteConsoleOutputCharacter, 			
		outPutHandle,
		ADDR score_inLevel,
		4,
		score_Pos,
		ADDR tokenswritten
	ret
printScore ENDP

decStr PROC,
	scoreDec:WORD
	mov ecx, 4					;WORD型態最高4位數
	mov dl, 10					;除數
	mov ax, scoreDec			;被除數
change:
	push ecx
	div dl
	add ah, '0'					;餘數轉成字存到score_inLevel
	dec ecx
	mov [score_inLevel + ecx], ah
	movzx ax, al				;商繼續除
	pop ecx
	loop change
	ret
decStr ENDP