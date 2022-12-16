controlSheep PROTO,
	outputHandle: DWORD
checkIfSheepIsByRoad PROTO,
	roadSideX: WORD,
	outputHandle: DWORD
init PROTO,
	outputHandle: DWORD,
	levelNum: BYTE
setStratTime PROTO
setSpeed PROTO,
	levelNum: BYTE
newRoad PROTO,
	thisRoadPosition: COORD,
	roadNum: BYTE,
	outputHandle: DWORD
carRun PROTO,
	carPosition: COORD,
	roadNum: BYTE,
	outputHandle: DWORD
carsRun PROTO,
	outputHandle: DWORD
moveCarOnScreen PROTO,
	startTime: DWORD,
	carPosition: COORD,
	roadNum: BYTE,
	direction: BYTE,
	outputHandle: DWORD
moveCarPosition PROTO,
	roadNum: BYTE,
	direction: BYTE
copyCars PROTO,
	carPosition: COORD,
	carNum: WORD,
	outputHandle: DWORD
clearCars PROTO,
	carPosition: COORD,
	carNum: WORD,
	outputHandle: DWORD
getRandomNumber PROTO,
	rangeLowerbound: DWORD,
	rangeUpperbound: DWORD
checkIfSheepIsHitByCar PROTO,
	carPosition: COORD
changeDisplayLife PROTO,
	outputHandle: DWORD
decToStr PROTO,
	decNum: WORD
initScore PROTO,
	outputHandle: DWORD
countScore PROTO, 
	sheepPos_X: WORD, 
	roadPos_x: WORD, 
	outputHandle: DWORD

.data
	xyBound COORD <80,25> 						; 一個頁面最大的邊界
	roadPosition COORD <20,0>					; 路的起始位置
	roadOneCarPosition COORD <?,?>				; 第一條路的位置(最左)
	roadTwoCarPosition COORD <?,?>				; 第二條路的位置(中)
	roadThreeCarPosition COORD <?,?>			; 第三條路的位置(最右)
	sheepPosition COORD <5,12>					; 用來記錄羊的位置
	roadSide   BYTE 0B3h, 11 DUP(' '), 0B3h		; 路的長相
	sheep   BYTE '@'							; 羊的長相
	car   BYTE 0DAh, 0BFh,						; 車的長相
			   0B3h, 0B3h,
			   0C0h, 0D9h
	blank   BYTE 6 DUP(' ')						; 空白字串(清空畫面用)
	road   BYTE 0B3h							; 路邊的長相
	startTimeOne DWORD ?						; 第一條路的車子要移動的時間
	startTimeTwo DWORD ?						; 第二條路的車子要移動的時間
	startTimeThree DWORD ?						; 第三條路的車子要移動的時間
	cellsWritten DWORD 0
	speedOne DWORD ?							; 第一條路車子移動速度
	speedTwo DWORD ?							; 第二條路車子移動速度
	speedThree DWORD ?							; 第三條路車子移動速度
	lifeStr  BYTE 4 DUP(?)						; 印出生命值用
	lifeDisplayPosition COORD <0,0>				; 生命值印出位置
	lifeDisplay BYTE "LIFE:"
	life WORD 3									; 紀錄生命值

.code

init PROC uses ebx,					; 關卡初始化
    outputHandle: DWORD,
	levelNum: BYTE
    
	; 將羊移至起點
	mov sheepPosition.x, 5
	mov sheepPosition.y, 12

	; 給定每條路的位置
	mov roadPosition.x, 20							; 第一條路從 x = 20 開始
	INVOKE newRoad, roadPosition, 1, outputHandle	; 印出第一條路
	INVOKE getRandomNumber, 14, 25		; 兩條路的距離為 14 ~ 25 之間的隨機數
	add roadPosition.x, ax
	INVOKE newRoad, roadPosition, 2, outputHandle	; 印出第二條路
	INVOKE getRandomNumber, 14, 22		; 兩條路的距離為 14 ~ 22 之間的隨機數
	add roadPosition.x, ax
	INVOKE newRoad, roadPosition, 3, outputHandle	; 印出第三條路

	INVOKE setSpeed, levelNum 						; 設定每條路車行駛速度(隨機)

	INVOKE setStratTime								; 紀錄車移動的時間
	
	INVOKE WriteConsoleOutputCharacter,				; 印出羊
		outputHandle,   	; console output handle
		ADDR sheep,   		; pointer to sheep
		1,   				; size of string
		sheepPosition,   	; coordinates of first char
		ADDR cellsWritten   ; output count

	; 印出生命值
	mov lifeDisplayPosition.x, 0
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,   	; console output handle
		ADDR lifeDisplay,   ; pointer to the life string
		5,   				; size of string
		lifeDisplayPosition,; coordinates of first char
		ADDR cellsWritten   ; output count
	add lifeDisplayPosition.x, 6
	INVOKE changeDisplayLife, outputHandle
	
	; 印出分數
	INVOKE initScore, outputHandle
	ret
init ENDP

setSpeed PROC uses eax ebx,
	levelNum: BYTE

	mov ebx, 0
	mov al, levelNum
	mov bl, 20
	mul bl				; 每多進一關，速度(範圍)就快 20 毫秒
	mov bx, ax
	INVOKE getRandomNumber, 250, 300	; 取一個 250 ~ 300 之間的隨機數
	sub eax, ebx
	mov speedOne, eax					; 紀錄第一條路的速度
	INVOKE getRandomNumber, 250, 300	; 取一個 250 ~ 300 之間的隨機數
	sub eax, ebx
	mov speedTwo, eax					; 紀錄第二條路的速度
	INVOKE getRandomNumber, 250, 300	; 取一個 250 ~ 300 之間的隨機數
	sub eax, ebx
	mov speedThree, eax					; 紀錄第三條路的速度

	ret
setSpeed ENDP

setStratTime PROC uses eax

	INVOKE GetTickCount		; 取得現在的時間
	mov startTimeOne, eax
	mov eax, speedOne		; 加上要間隔的時間
	add startTimeOne, eax	; 設為第一條路車子要移動的時間
	
	INVOKE GetTickCount		; 取得現在的時間
	mov startTimeTwo, eax
	mov eax, speedTwo		; 加上要間隔的時間
	add startTimeTwo, eax	; 設為第二條路車子要移動的時間
	
	INVOKE GetTickCount		; 取得現在的時間
	mov startTimeThree, eax
	mov eax, speedThree		; 加上要間隔的時間
	add startTimeThree, eax	; 設為第三條路車子要移動的時間

	ret
setStratTime ENDP

resume PROC,
    outputHandle: DWORD
	
	; 將 cursor 隱藏
	LOCAL cursorInfo:CONSOLE_CURSOR_INFO
	mov cursorInfo.dwSize, 100
	mov cursorInfo.bVisible, 0
	INVOKE SetConsoleCursorInfo,
    	outputHandle,
        ADDR cursorInfo

	; 印出第一條路
	push roadOneCarPosition
	sub roadOneCarPosition.x, 6		; 路和車的距離為 6
	mov roadOneCarPosition.y, 0		; 從畫面最上面開始印
	mov ecx, 25						; 路的長度為 25
	drawRoadOne: 					; 一行一行印出路
		push ecx
		INVOKE WriteConsoleOutputCharacter,
			outputHandle,   	; console output handle
			ADDR roadSide,   	; pointer to the road
			13,   				; size of string
			roadOneCarPosition, ; coordinates of first char
			ADDR cellsWritten   ; output count
		inc roadOneCarPosition.y
		pop ecx
	loop drawRoadOne
	pop roadOneCarPosition

	; 印出第二條路
	push roadTwoCarPosition
	sub roadTwoCarPosition.x, 6		; 路和車的距離為 6
	mov roadTwoCarPosition.y, 0		; 從畫面最上面開始印
	mov ecx, 25						; 路的長度為 25
	drawRoadTwo: 					; 一行一行印出路
	push ecx
	INVOKE WriteConsoleOutputCharacter,
        outputHandle,   	; console output handle
        ADDR roadSide,   	; pointer to the road
        13,   				; size of string
        roadTwoCarPosition, ; coordinates of first char
        ADDR cellsWritten   ; output count
	inc roadTwoCarPosition.y
	pop ecx
	loop drawRoadTwo
	pop roadTwoCarPosition

	; 印出第三條路
	push roadThreeCarPosition
	sub roadThreeCarPosition.x, 6		; 路和車的距離為 6
	mov roadThreeCarPosition.y, 0		; 從畫面最上面開始印
	mov ecx, 25							; 路的長度為 25
	drawRoadThree:  					; 一行一行印出路
		push ecx
		INVOKE WriteConsoleOutputCharacter,
			outputHandle,   		; console output handle
			ADDR roadSide,   		; pointer to the road
			13,   					; size of string
			roadThreeCarPosition,   ; coordinates of first char
			ADDR cellsWritten     	; output count
		inc roadThreeCarPosition.y
		pop ecx
	loop drawRoadThree
	pop roadThreeCarPosition

	INVOKE setStratTime					; 紀錄車要移動的時間
	
	INVOKE WriteConsoleOutputCharacter,	; 印出羊
		outputHandle,   	; console output handle
		ADDR sheep,   		; pointer to the sheep
		1,   				; size of string
		sheepPosition,   	; coordinates of first char
		ADDR cellsWritten   ; output count

	; 印出生命值
	mov lifeDisplayPosition.x, 0
	INVOKE WriteConsoleOutputCharacter,
		outputHandle,   	; console output handle
		ADDR lifeDisplay,   ; pointer to the life string
		5,   				; size of string
		lifeDisplayPosition,; coordinates of first char
		ADDR cellsWritten   ; output count
	add lifeDisplayPosition.x, 6
	INVOKE changeDisplayLife, outputHandle

	; 印出分數
	INVOKE initScore, outputHandle
	ret
resume ENDP

controlSheep PROC uses ebx edx,	; 控制羊的移動
    outputHandle: DWORD

	INVOKE Sleep, 10			; 等一下輸入(不等有時候會讀不到)
	call ReadKey				; 讀取鍵盤輸入
	.IF ax == 011Bh 			; ESC
		mov eax, 2				; 跳到暫停	eax = 2
		ret
	.ENDIF
	.IF al == 0					; 判斷是按方向鍵
		push sheepPosition.x
		push sheepPosition.y
		
		.IF ah == 48h 			; UP
			sub sheepPosition.y, 1
		.ENDIF
		.IF ah == 50h 			; DOWN
			add sheepPosition.y, 1
		.ENDIF
		; 遊戲設計不能往左走
		;.IF ah == 4Bh 			; LEFT
		;	sub sheepPosition.x, 1
		;.ENDIF
		.IF ah == 4Dh 			; RIGHT
			add sheepPosition.x, 1
		.ENDIF
		
		; 檢查作完上下左右後有沒有超過限制邊界
		.IF sheepPosition.x == 0h	; x lowerbound
			add sheepPosition.x, 1	; 超過邊界停留在原位
		.ENDIF
		mov ax,xyBound.x ; 比較不能用雙定址，故將其中一個轉成 register
		.IF sheepPosition.x == ax 	; x upperbound
			sub sheepPosition.x, 1 	; 超過邊界停留在原位
		.ENDIF
		.IF sheepPosition.y == 0h 	; y lowerbound
			add sheepPosition.y, 1 	; 超過邊界停留在原位
		.ENDIF
		mov ax,xyBound.y
		.IF sheepPosition.y == ax 	; y upperbound
			sub sheepPosition.y, 1 	; 超過邊界停留在原位
		.ENDIF

		pop bx						; 接收原本的 sheepPosition.y
		pop dx						; 接收原本的 sheepPosition.x
		push sheepPosition			; 保護移動過後的位置
		mov sheepPosition.x, dx
		mov sheepPosition.y, bx
		INVOKE WriteConsoleOutputCharacter,	; 將羊原本的位置清空(印空白)
			outputHandle,   	; console output handle
			ADDR blank,   		; pointer to blank string
			1,   				; size of string
			sheepPosition,   	; coordinates of first char
			ADDR cellsWritten   ; output count
		; 確認羊有沒有被撞到
		INVOKE checkIfSheepIsByRoad, roadOneCarPosition.x, outputHandle
		INVOKE checkIfSheepIsByRoad, roadTwoCarPosition.x, outputHandle
		INVOKE checkIfSheepIsByRoad, roadThreeCarPosition.x, outputHandle

		pop sheepPosition		; 回復移動過後的位置
		INVOKE WriteConsoleOutputCharacter,
			outputHandle,   	; console output handle
			ADDR sheep,   		; pointer to sheep string
			1,   				; size of string
			sheepPosition,   	; coordinates of first char
			ADDR cellsWritten   ; output count
	.ENDIF

	mov eax, 1					; 繼續玩遊戲	eax = 1
	ret
controlSheep ENDP

checkIfSheepIsByRoad PROC,
	roadSideX: WORD,			; 車的 x 座標
    outputHandle: DWORD
	
	mov ax, roadSideX
	sub ax, 6					; 移動為路邊的座標(車和路邊距離為 6)
	; 如果剛剛在路邊，就把路邊的形狀印回來
	.IF sheepPosition.x == ax	; 檢查左邊
		INVOKE WriteConsoleOutputCharacter,
			outputHandle,   	; console output handle
			ADDR road,   		; pointer to road side string
			1,   				; size of string
			sheepPosition,   	; coordinates of first char
			ADDR cellsWritten   ; output count
	.ENDIF
	add ax, 12
	.IF sheepPosition.x == ax	; 檢查右邊
		INVOKE WriteConsoleOutputCharacter,
			outputHandle,   	; console output handle
			ADDR road,   		; pointer to road side string
			1,   				; size of string
			sheepPosition,   	; coordinates of first char
			ADDR cellsWritten   ; output count
	.ENDIF

	; 更新分數
	add roadSideX, 6
	INVOKE countScore, sheepPosition.x, roadSideX, outputHandle

	ret
checkIfSheepIsByRoad ENDP

carRun PROC,				; 讓某一條路的車子跑起來
	carPosition: COORD,
	roadNum: BYTE,			; 第幾條路
    outputHandle: DWORD

	.IF roadNum == 1
		INVOKE moveCarOnScreen,	; 更新畫面上的車子
			startTimeOne,
			roadOneCarPosition,
			1, ; road number
			1, ; direction (1 going down, 2 doing up)
            outputHandle
	.ENDIF
	.IF roadNum == 2
		INVOKE moveCarOnScreen,	; 更新畫面上的車子
			startTimeTwo,
			roadTwoCarPosition,
			2, ; road number
			2, ; direction (1 going down, 2 doing up)
            outputHandle
	.ENDIF
	.IF roadNum == 3
		INVOKE moveCarOnScreen,	; 更新畫面上的車子
			startTimeThree,
			roadThreeCarPosition,
			3, ; road number
			1, ; direction (1 going down, 2 doing up)
            outputHandle
	.ENDIF

	ret
carRun ENDP

carsRun PROC,
    outputHandle: DWORD

	; 讓三條路的車跑起來
	INVOKE carRun, roadOneCarPosition, 1, outputHandle
	INVOKE carRun, roadTwoCarPosition, 2, outputHandle
	INVOKE carRun, roadThreeCarPosition, 3, outputHandle

	ret
carsRun ENDP

moveCarOnScreen PROC,
	startTime: DWORD,		; 車子要移動的時間
	carPosition: COORD,		; 車子的位置
	roadNum: BYTE,			; 哪一條路
	direction: BYTE,		; 車子走的方向
    outputHandle: DWORD
	
	INVOKE GetTickCount		; 取得現在的時間
	.IF eax > startTime		; 如果現在時間大於車子該移動的時間就移動

		push carPosition
		INVOKE clearCars, carPosition, 4, outputHandle ; 清空車子現在位置
		pop carPosition

		.IF direction == 1 ; going down
			add carPosition.y, 1
		.ENDIF
		.IF direction == 2 ; going up
			.IF carPosition.y == 0 ; 超過上界從下面回來
				add carPosition.y, 25
			.ENDIF
			sub carPosition.y, 1
		.ENDIF

		.IF carPosition.y >= 25	; 超過下界從上面回來
			sub carPosition.y, 25
		.ENDIF

		push carPosition
		INVOKE copyCars, carPosition, 4, outputHandle ; 印出車子(四台)
		pop carPosition
		INVOKE moveCarPosition, roadNum, direction 	; 更新車子位置
	.ENDIF

	ret
moveCarOnScreen ENDP

moveCarPosition PROC,
	roadNum: BYTE,	; 第幾條路
	direction: BYTE ; 1 going down, 2 doing up

	.IF roadNum == 1
		mov eax, speedOne
		add startTimeOne, eax ; 更新車子下一次要移動的時間
		.IF direction == 1 ; going down
			add roadOneCarPosition.y, 1
		.ENDIF
		.IF direction == 2 ; going up
			.IF roadOneCarPosition.y == 0 ; 超過上界從下面回來
				add roadOneCarPosition.y, 25
			.ENDIF
			sub roadOneCarPosition.y, 1
		.ENDIF
		
		.IF roadOneCarPosition.y >= 25	; 超過下界從上面回來
			sub roadOneCarPosition.y, 25
		.ENDIF
	.ENDIF
	.IF roadNum == 2
		mov eax, speedTwo
		add startTimeTwo, eax ; 更新車子下一次要移動的時間
		.IF direction == 1 ; going down
			add roadTwoCarPosition.y, 1
		.ENDIF
		.IF direction == 2 ; going up
			.IF roadTwoCarPosition.y == 0 ; 超過上界從下面回來
				add roadTwoCarPosition.y, 25
			.ENDIF
			sub roadTwoCarPosition.y, 1
		.ENDIF

		.IF roadTwoCarPosition.y >= 25	; 超過下界從上面回來
			sub roadTwoCarPosition.y, 25
		.ENDIF
	.ENDIF
	.IF roadNum == 3
		mov eax, speedThree
		add startTimeThree, eax ; 更新車子下一次要移動的時間
		.IF direction == 1 ; going down
			add roadThreeCarPosition.y, 1
		.ENDIF
		.IF direction == 2 ; going up
			.IF roadThreeCarPosition.y == 0 ; 超過上界從下面回來
				add roadThreeCarPosition.y, 25
			.ENDIF
			sub roadThreeCarPosition.y, 1
		.ENDIF
		
		.IF roadThreeCarPosition.y >= 25	; 超過下界從上面回來
			sub roadThreeCarPosition.y, 25
		.ENDIF
	.ENDIF

	ret
moveCarPosition ENDP

copyCars PROC,
	carPosition: COORD,					; 車子的位置
	carNum: WORD,						; 印幾台車
    outputHandle: DWORD

	movzx ecx, carNum					; 印幾台車就重複幾次
	copy:
		push ecx
		add carPosition.y, 3 			; 每台車長 3
		mov ecx, 3
		mov esi, 0
		printWholeCar:
			push ecx
			.IF carPosition.y >= 25		; 超過下界從上面回來
				sub carPosition.y, 25
			.ENDIF
			; 印出一台車
			INVOKE WriteConsoleOutputCharacter,
				outputHandle,
				ADDR [car + esi],
				2,
				carPosition,
				ADDR cellsWritten     ; output count
			
			; 確認羊有沒有被撞到(有 eax = 1)
			INVOKE checkIfSheepIsHitByCar, carPosition
			.IF eax == 1				; 被撞到生命值扣 1
				sub life, 1
				INVOKE changeDisplayLife, outputHandle
			.ENDIF
			inc carPosition.y			; 每台車間隔 1
			add esi, 2
			pop ecx
		loop printWholeCar
		pop ecx
	loop copy

	ret
copyCars ENDP

clearCars PROC,
	carPosition: COORD,					; 要清空車子的位置
	carNum: WORD,						; 要清幾台車
    outputHandle: DWORD

	movzx ecx, carNum					; 要清幾台車就重複幾次
	clear:
		push ecx
		add carPosition.y, 3 			; 每台車長 3
		mov ecx, 3
		mov esi, 0
		printWholeCar:
			push ecx
			.IF carPosition.y >= 25		; 超過下界從上面回來
				sub carPosition.y, 25
			.ENDIF
			; 印出空白來清空畫面
			INVOKE WriteConsoleOutputCharacter,
				outputHandle,
				ADDR [blank + esi],
				2,
				carPosition,
				ADDR cellsWritten
			inc carPosition.y			; 每台車間隔 1
			add esi, 2
			pop ecx
		loop printWholeCar
		pop ecx
	loop clear

	ret
clearCars ENDP

newRoad PROC,
	thisRoadPosition: COORD,
	roadNum: BYTE,
    outputHandle: DWORD

	.IF roadNum == 1
		mov ax, thisRoadPosition.x
		add ax, 6					 ; 車子和路邊隔 6
		mov roadOneCarPosition.x, ax ; 設定車子位置
		mov roadOneCarPosition.y, 0
	.ENDIF
	.IF roadNum == 2
		mov ax, thisRoadPosition.x
		add ax, 6					 ; 車子和路邊隔 6
		mov roadTwoCarPosition.x, ax ; 設定車子位置
		mov roadTwoCarPosition.y, 0
	.ENDIF
	.IF roadNum == 3
		mov ax, thisRoadPosition.x
		add ax, 6					 ; 車子和路邊隔 6
		mov roadThreeCarPosition.x, ax; 設定車子位置
		mov roadThreeCarPosition.y, 0
	.ENDIF

	push thisRoadPosition
	mov ecx, 25						; 馬路長 25
	drawRoad: 						; 把馬路印出來
	push ecx
	INVOKE WriteConsoleOutputCharacter,
        outputHandle,   		; console output handle
        ADDR roadSide,   		; pointer to roaSdie string
        13,   					; size of string
        thisRoadPosition,   	; coordinates of first char
        ADDR cellsWritten     	; output count
	inc thisRoadPosition.y
	pop ecx
	loop drawRoad
	pop thisRoadPosition

	ret
newRoad ENDP

getRandomNumber PROC uses ebx,	; return in eax
	rangeLowerbound: DWORD,		; 隨機數的下界(最小值)
	rangeUpperbound: DWORD		; 隨機數的上界(最大值)

	INVOKE Sleep, 1
	call Randomize 				; re-seed generator
	mov	ebx, rangeUpperbound
	sub ebx, rangeLowerbound
	inc ebx
	mov eax, ebx
	call RandomRange			; get random 0 to ebx
	add eax, rangeLowerbound	; make range lowerbound to upperbound
	
	ret
getRandomNumber ENDP

checkIfSheepIsHitByCar PROC uses ebx ecx,	; 確認羊有沒有被撞到(有 eax = 1)
	carPosition: COORD

	; 檢查左半邊的車子有沒有撞到羊
	mov bx, carPosition.x
	.IF sheepPosition.x == bx		; 如果羊跟車在同一個 x 座標
		mov bx, carPosition.y
		.IF sheepPosition.y == bx	; 如果羊跟車在同一個座標
			mov eax, 1				; 羊被撞到 (回傳 eax = 1)
			ret
		.ENDIF
	.ENDIF
	; 檢查右半邊的車子有沒有撞到羊
	mov bx, carPosition.x
	inc bx
	.IF sheepPosition.x == bx		; 如果羊跟車在同一個 x 座標
		mov bx, carPosition.y
		.IF sheepPosition.y == bx	; 如果羊跟車在同一個座標
			mov eax, 1				; 羊被撞到 (回傳 eax = 1)
			ret
		.ENDIF
	.ENDIF

	mov eax, 0
    ret
checkIfSheepIsHitByCar ENDP

changeDisplayLife PROC,
	outputHandle: DWORD

	INVOKE decToStr, life				; 將生命值的數字轉成字串

	INVOKE WriteConsoleOutputCharacter, ; 印出生命值
		outputHandle,   		; console output handle
		ADDR lifeStr,			; pointer to the life string
		4,						; lenght of the string
		lifeDisplayPosition,   	; coordinates of first char
		ADDR cellsWritten     	; output count

	ret
changeDisplayLife ENDP

decToStr PROC,
	decNum: WORD

	mov ecx, 4			; WORD型態最高4位數
	mov dl, 10			; 除數
	mov ax, decNum		; 被除數
	change:
		push ecx
		div dl
		add ah, '0'					; 餘數轉成字存到 lifeStr
		dec ecx
		mov [lifeStr + ecx], ah
		movzx ax, al				; 商繼續除
		pop ecx
		loop change
	ret
decToStr ENDP