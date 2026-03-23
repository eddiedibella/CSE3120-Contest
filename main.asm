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
moveSnake PROC
	; retrieve the current seconds (ch 10)
	INVOKE GetLocalTime, ADDR sysTime
	movzx eax, sysTime.wSecond
	; get the next second
	mov ebx, eax
	inc ebx
	;call WriteDec


	; while statement for 1 second delay
	mov ecx, 1
go:
	INVOKE GetLocalTime, ADDR sysTime
	movzx eax, sysTime.wSecond
	;call WriteDec
;delay:
	; code to make a 1 second delay
	; check if a second has passed
	cmp eax, ebx
	; if a second has passed end the delay
	jz enddelay
	; if not, wait again
	jmp go

enddelay:
	; update ebx to be eax +1
	mov ebx, eax
	inc ebx

	; code to move snake
	mov dx, snakePOS

	;row stays the same, but change col
	inc dl
	call GotoXY
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


END main