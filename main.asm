;  Fun Snake main file        (main.asm)

; this file is the main file of our snake game

INCLUDE Irvine32.inc

.data 
	x BYTE "O",0
	eyes BYTE ":",0
	blank BYTE " ", 0
	snakePOS WORD 0h
	sysTime SYSTEMTIME <>
	currCOL BYTE 0h
	timeDelay DWORD 0h
	timePassed DWORD 0h
	direction WORD 90
.code
main PROC
	
	; initialize the snake
	call initSnake

	; initialize the bounds of the map
	; BOUNDS
	; 0 < col <= 119
	; 0 < row <= 28
	call initMap

	; initialize the snake moving 1 pixel per second to the right
	mov timeDelay, 1000		; time delay in milliseconds
	call moveSnake

	; recommended next steps



	; add bounds so the snake dies if it touches the wall

	; then add user input with arrow keys or WASD

	; then add the random apple spawner

	; then add the apple eating logic (which in turn makes the snake faster)


	exit
main ENDP


initSnake PROC
; This procedure initializes the snake in the middle of the screen

; Set text color to green on black background
	mov eax, green + (black*16)
	call SetTextColor 

	; clear the screen
	call Clrscr
	; move cursor to row 15 col 60
	mov dh, 15
	mov dl, 60
	call GotoXY
	; write the string O
	mov al, x
	call WriteChar

	; move cursor to row 15 col 61
	mov dh, 15
	mov dl, 61
	call GotoXY
	; write the string O
	mov al, x
	call WriteChar
	; move cursor to row 15 col 62
	mov dh, 15
	mov dl, 62
	call GotoXY
	; write the string :
	mov al, eyes

	; this is where the eyes are, so now copy that to the snakePOS variable
	mov snakePOS, dx
	
	call WriteChar

	ret
initSnake ENDP

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
	; retrieve the current seconds (ch 10)
	INVOKE GetLocalTime, ADDR sysTime
	movzx eax, sysTime.wMilliseconds
	mov ebx, eax
	; get that next second

	;push eax
	; do modulus to get the next second
	;mov eax, ebx
	;add eax, timeDelay	; move one second into future
	;mov ebx, 1000
	;div ebx			; leaves quotient in eax, remainder in edx
	;pop eax

	;call WriteDec


	; while statement for 1 second delay
	mov ecx, 0
go:
	call handleInput
	INVOKE GetLocalTime, ADDR sysTime
	movzx eax, sysTime.wMilliseconds
	;call WriteDec
delayLoop:
	; code to make a 1 second delay (1000 ms)
	push eax
	INVOKE GetLocalTime, ADDR sysTime
	movzx eax, sysTime.wMilliseconds
	mov ebx, eax
	pop eax
	; check if a second has passed
	; if eax is smaller than or equal to ebx, do normal difference
	; ebx - eax = diff
	cmp eax, ebx
	jg elsestatement

	push eax
	push ebx
	sub ebx, eax
	mov edx, ebx
	pop ebx
	pop eax

	jmp notelse
elsestatement:
	; if eax is bigger, do weird difference
	; (1000 - eax) + (ebx) = diff
	push eax
	mov ecx, 1000
	sub ecx, eax
	mov eax, ecx
	add eax, ebx
	mov edx, eax
	pop eax
	
notelse:

	; check if a second has passed
	push eax
	push ebx
	mov eax, timePassed
	mov ebx, timeDelay
	; add the current time passed to the timePassed variable
	add eax, edx
	cmp eax, ebx

	; update timePassed variable
	mov timePassed, eax
	;call WriteDec
	;call debug

	pop ebx
	pop eax

	; update ebx time to eax time
	mov eax, ebx

	; if enough time passed (eax >= ebx), end delay 
	jge enddelay

	; if not time yet (eax < ebx), continue delay
	jmp delayLoop


	
	;add eax, timeDelay	; move one second into future
	;mov ebx, 1000
	;div ebx			; leaves quotient in eax, remainder in edx

	; if a second has passed end the delay
	jz enddelay
	; if not, wait again
	jmp go

enddelay:
	; update timePassed back to 0
	mov timePassed, 0h

	; code to move snake
	mov dx, snakePOS

	push ax
	; if direction is right
	mov ax, direction
	cmp ax, 90
	jnz next
	inc dl		;row stays the same, but change col
	jmp enddir
next:
	; if direction is down
	cmp ax, 180
	jnz next2
	inc dh		;row changes, but col stays the same
	jmp enddir
next2:
	; if direction is left
	cmp ax, 270
	jnz next3
	dec dl		;row stays the same, but change col
	jmp enddir
next3:
	; if direction is up
	cmp ax, 0
	jnz enddir
	dec dh		;row changes, but col stays the same
enddir:
	call GotoXY
	pop ax


	; check if out of bounds (uses ecx to return)
	push ecx
	call checkBounds
	cmp ecx, 0
	pop ecx
	jl endwhile


	; write the string eyes
	mov al, eyes
	call WriteChar

	; save current snake position
	mov snakePOS, dx
	call debug

jmp go
endwhile:
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
checkBounds PROC
.data
deathMsg BYTE "You have died!", 0
;BadXCoordMsg BYTE "X-Coordinate out of range!",0Dh,0Ah,0
;BadYCoordMsg BYTE "Y-Coordinate out of range!",0Dh,0Ah,0
.code
	.IF (DL < 0) || (DL > 119)
	   ;mov  edx,OFFSET BadXCoordMsg
	   mov  edx,OFFSET deathMsg
	   call WriteString
	   mov ecx, -1
	   jmp  quit
	.ENDIF
	.IF (DH < 0) || (DH > 28)
	   ;mov  edx,OFFSET BadYCoordMsg
	   mov  edx,OFFSET deathMsg
	   call WriteString
	   mov ecx, -1
	   jmp  quit
	.ENDIF
	mov ecx, 1
quit:
	ret
checkBounds ENDP

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

breakout:
END main