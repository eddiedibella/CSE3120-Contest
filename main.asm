;  Fun Snake main file        (main.asm)

; this file is the main file of our snake game

; GAMEPLAY INSTRUCTION
; use W A S D to navigate the snake around the mao
; if the game is over press r to start another game

; SETUP INSTRUCTIONS
; build the project in visual studio
; open a terminal window
; navigate to the debug folder inside of the project folder
; run the .exe file project.exe 

INCLUDE Irvine32.inc

.data 
	x BYTE "O",0
	eyes BYTE ":",0
	blank BYTE " ",0
	snakePOS WORD 0h
	timeDelay DWORD 0h
	tickStart DWORD 0
	direction WORD 90

	applesEaten DWORD 0
	snakeCols BYTE 62,61,60
	snakeRows BYTE 15,15,15
	appleCol BYTE 0
	appleRow BYTE 0
	tailCol BYTE 0
	TailRow BYTE 0
	deathMsg BYTE "GAME OVER -- Push 'r' to restart or any other button to quit",0
	restart BYTE 0
.code
main PROC
	
rs:
	mov restart, 0
	; initialize the snake
	call initSnake

	; initialize the bounds of the map
	; BOUNDS
	; 0 < col <= 119
	; 0 < row <= 28
	call initMap

	; initialize random generator for the production of the first apple
	call Randomize
	call spawnApple
	; initialize the snake moving 1 pixel per second to the right
	mov timeDelay, 500		; initial time delay in milliseconds
	call flushInput
	call moveSnake

	; check for restart
	cmp restart, 1
	je rs

	; recommended next steps

	; then add the random apple spawner (within map bounds and not on snake)

	; then add the apple eating logic (which in turn makes the snake faster)
	; - update timeDelay variable to be half of what it was before

	; some bugs/more changes to eventually fix:
	; snake eyes only update instead of whole body
	; - im thinking to just keep the snake size 3 parts long the whole time
	; no matter how many apples are eaten
	; - old snake part deletion can be added by setting a character to a " " 
	; wall bounds that are 1 pixel off
	; could make smaller map to a square grid to make the game go by faster
	; input delay can be fixed by adding more of the handle input calls 
	;  elsewhere (such as in the delay section)



	exit
main ENDP

; added flushInput for the start of the game
; if flushing wasn't added there would be no buffer the game could end immediately
flushInput PROC
flushLoop:
    call readKey
    jz flushDone 
 	jmp flushLoop     
flushDone:
    ret
flushInput ENDP

initSnake PROC
; This procedure initializes the snake in the middle of the screen
	; Set text color to green on black background
	mov eax, green + (black*16)
	call SetTextColor 
	; clears the screen
	call Clrscr
	; moves cursor to row 15,15,15 and col 60,61,62
	mov snakeCols[0], 62
	mov snakeRows[0], 15
	mov snakeCols[1], 61
	mov snakeRows[1], 15
	mov snakeCols[2], 60
	mov snakeRows[2], 15

	mov direction, 90

	mov dx, 0
	mov dl, snakeCols[0]
	mov dh, snakeRows[0]
	mov snakePOS, dx

	call drawSnake
	ret
initSnake ENDP

;added in the apple system that will randomy choose an apple location
; from columns 2 to 118 and from rows 2 to 27 
; it also makes sure the apple doesn't spawn on the snake
spawnApple PROC
newApple:
	; bounds from columns 2 to 118
	mov eax, 117
	call RandomRange
	add eax, 2
	and eax, 0FEh
	mov appleCol, al

	; bounds from rows 2 to 27
	mov eax, 26
	call RandomRange
	add eax, 2
	mov appleRow, al

	; this will make sure there will not be an apple on the snake 
	mov al, appleCol
	cmp al, snakeCols[0]
	jne checkBody1
	mov al, appleRow
	cmp al, snakeRows[0]
	je newApple

checkBody1:
	mov al, appleCol
	cmp al, snakeCols[1]
	jne checkBody2
	mov al, appleRow
	cmp al, snakeRows[1]
	je newApple

checkBody2:
	mov al, appleCol
	cmp al, snakeCols[2]
	jne drawApple
	mov al, appleRow
	cmp al, snakeRows[2]
	je newApple

drawApple:
	mov dl, appleCol
	mov dh, appleRow
	call GotoXY
	mov al, '@'
	call WriteChar
	ret
spawnApple ENDP

; responsible for removing the tail for every position the snake moves
; without this the snake would get increasingly longer the farther it travels
eraseTail PROC
	mov dl, tailCol
	mov dh, tailRow
	call GotoXY
	mov al, blank
	call WriteChar
	ret
eraseTail ENDP

; will be a centralized hub for the drawing of the snakes body 
drawSnake PROC
	; responsible for drawing the tail
	mov dl, snakeCols[2]
	mov dh, snakeRows[2]
	call GotoXY
	mov al, x
	call WriteChar

	; will draw the middle section
	mov dl, snakeCols[1]
	mov dh, snakeRows[1]
	call GotoXY
	mov al, x
	call WriteChar

	; will now draw the head
	mov dl, snakeCols[0]
	mov dh, snakeRows[0]
	call GotoXY
	mov al, eyes
	call WriteChar

	mov snakePOS, dx
	ret
drawSnake ENDP

initMap PROC
; This procedure initializes the map bounds (colored in yellow)

; Set text color to green on yellow background
	mov eax, green + (yellow*16)
	call SetTextColor 

	; iterate across the columns (120 of them)
	mov ecx, 119
	mov bl, 1
TopBar:
	; move cursor to row 1 col 1, then move right
	mov dh, 1
	mov dl, bl
	call GotoXY
	; write the string space
	mov al, blank
	call WriteChar

	inc bl
	dec ecx
	jnz TopBar


	; iterate across the rows (30 of them)
	mov ecx, 28
	mov bl, 1
RightBar:
	; move cursor to row 1 col 119, then go down
	mov dh, bl
	mov dl, 119
	call GotoXY
	; write the string space
	mov al, blank
	call WriteChar

	inc bl
	dec ecx
	jnz RightBar

	; iterate across the columns (120 of them)
	mov ecx, 119
	mov bl, 119
BottomBar:
	; move cursor to row 30 col 120, then move left
	mov dh, 28
	mov dl, bl
	call GotoXY
	; write the string space
	mov al, blank
	call WriteChar

	dec bl
	dec ecx
	jnz BottomBar

	; iterate across the rows (30 of them)
	mov ecx, 28
	mov bl, 28
LeftBar:
	; move cursor to row 30 col 1, then go up
	mov dh, bl
	mov dl, 1
	call GotoXY
	; write the string space
	mov al, blank
	call WriteChar

	dec bl
	dec ecx
	jnz LeftBar

	; Set text color to green on black background
	mov eax, green + (black*16)
	call SetTextColor

	ret
initMap ENDP



; initialize the snake moving 1 pixel per second to the right
; eax holds time of initial delay
; ebx holds current time since delay started
; edx holds time difference between eax and ebx
moveSnake PROC
gameLoop:
	; this will check the TimeDelay that we have set
	; it will also check for the inputs at the start of the game
	call GetTickCount
	mov tickStart, eax

waitLoop:
	call handleInput
	INVOKE Sleep, 20
	call GetTickCount
	sub eax, tickStart
	cmp eax, timeDelay
	jb waitLoop

	; saves the position of the old tail
	mov al, snakeCols[2]
	mov tailCol, al
	mov al, snakeRows[2]
	mov tailRow, al

	; this will start from the current head and will clear EDX
	xor edx, edx         
	mov dl, snakeCols[0]
	mov dh, snakeRows[0]

	; gets the next position 
	mov ax, direction
	cmp ax, 90
	jne checkDown
	add dl, 2
	jmp headReady

checkDown:
	cmp ax, 180
	jne checkLeft
	inc dh
	jmp headReady

checkLeft:
	cmp ax, 270
	jne checkUp
	sub dl, 2
	jmp headReady

checkUp:
	dec dh

headReady:
	; this is responsible for checking bounds and seeing wall position for the end of the game
	call checkBounds
	cmp ecx, 0
	jl gameOver

	; for the snakes body movement 
	mov al, snakeCols[1]
	mov snakeCols[2], al
	mov al, snakeRows[1]
	mov snakeRows[2], al

	mov al, snakeCols[0]
	mov snakeCols[1], al
	mov al, snakeRows[0]
	mov snakeRows[1], al

	; write new head
	mov snakeCols[0], dl
	mov snakeRows[0], dh
	mov snakePOS, dx

	; kind of redundant but added in a self collision clause if we decide to make the snake bigger
	call checkSelfCollision
	cmp ecx, 0
	jl gameOver

	; this will update the screen
	call eraseTail
	call drawSnake

	; used when the snake collides with an apple 
	mov al, snakeCols[0]
	cmp al, appleCol
	jne continueGame
	mov al, snakeRows[0]
	cmp al, appleRow
	jne continueGame

	inc applesEaten

	; half the time delay but it is capped below at 60 ms
	mov eax, timeDelay
	shr eax, 1
	cmp eax, 20
	jae saveDelay
	mov eax, 20

saveDelay:
	mov timeDelay, eax
	call spawnApple

continueGame:
	jmp gameLoop

gameOver:
	; print death message
	mov dl, 0
	mov dh, 29
	call GotoXY
	mov edx, OFFSET deathMsg
	call WriteString
	; check if user pushed r or something else
	call handleOption 
	ret
moveSnake ENDP

debug PROC
	push dx
	mov dh, 0
	mov dl, 0
	call GotoXY
	pop dx
	call DumpRegs

	ret
debug ENDP

; returns negative number in ecx if out of bounds
; bounds so the snake dies if it touches the wall
checkBounds PROC
	; zero extend DL into ECX
	movzx ecx, dl          
	cmp ecx, 2
	jl outOfBounds
	cmp ecx, 118
	jg outOfBounds
	; zero extend DH into ECX
	movzx ecx, dh          
	cmp ecx, 2
	jl outOfBounds
	cmp ecx, 27
	jg outOfBounds

	mov ecx, 1
	ret

outOfBounds:
	mov ecx, -1
	ret
checkBounds ENDP

checkSelfCollision PROC
	mov ecx, 1

	mov al, snakeCols[0]
	cmp al, snakeCols[1]
	jne checkTail
	mov al, snakeRows[0]
	cmp al, snakeRows[1]
	je hitSelf

checkTail:
	mov al, snakeCols[0]
	cmp al, snakeCols[2]
	jne safe
	mov al, snakeRows[0]
	cmp al, snakeRows[2]
	je hitSelf

safe:
	ret

hitSelf:
	mov ecx, -1
	ret
checkSelfCollision ENDP

; user input with WASD
handleInput PROC
	call readKey ; ch 5
	; if zero flag is zero
	jz quit
	; and AL is not zero
	cmp al, 0
	jz quit

	; read the character
	push dx
	mov dh, 0
	mov dl, 0
	call GotoXY
	pop dx
	call WriteChar

	; check direction of snake
	; up = 0, ascii of w = 119
	; right = 90, ascii of d = 100
	; down = 180, ascii of s = 115
	; left = 270, ascii of a = 97
	mov bx, direction
	; if direction is right, only accept up and down as input (119 or 115)
	cmp bx, 90
	jnz next
	cmp al, 119
	jz validinput
	cmp al, 115
	jz validinput
	jmp quit
next:
	; if direction is down, only accept left and right as input (97 or 100)
	cmp bx, 180
	jnz next2
	cmp al, 97
	jz validinput
	cmp al, 100
	jz validinput
	jmp quit
next2:
	; if direction is left, only accept up and down as input (119 or 115)
	cmp bx, 270
	jnz next3
	cmp al, 119
	jz validinput
	cmp al, 115
	jz validinput
	jmp quit
next3:
	; if direction is up, only accept left and right as input (97 or 100)
	cmp bx, 0
	jnz quit
	cmp al, 97
	jz validinput
	cmp al, 100
	jz validinput
	jmp quit

; check which valid input it is, then set the correct direction
validinput:
	; if up (119)
	cmp al, 119
	jnz cv
	mov direction, 0
	jmp quit
cv:
	; if right (100)
	cmp al, 100
	jnz cv2
	mov direction, 90
	jmp quit
cv2:
	; if down (115)
	cmp al, 115
	jnz cv3
	mov direction, 180
	jmp quit
cv3:
	; if left (97)
	cmp al, 97
	jnz quit
	mov direction, 270

quit:
	ret
handleInput ENDP

; user input for restarting the game or quitting
handleOption PROC
	call readChar ; ch 5
	; if zero flag is zero
	jz quit
	; and AL is not zero
	cmp al, 0
	jz quit

	; check key
	; ascii of r = 114
	cmp al, 114
	jne quit
	mov restart, 1
quit:
	ret
handleOption ENDP

breakout:
END main
