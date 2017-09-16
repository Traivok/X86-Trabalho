org 0x7e00
jmp 0x0000:start

msg1 db "                                       MENU", 13, 10, 0
msg2 db "                                1 - Hangman Game", 13, 10, 0
msg3 db "                                2 - Animation", 13, 10, 0
jline db " ", 13, 10, 0
char times 1 db 0
initial db "Press any key", 0
opti1 db "COMECAR JOGO 1", 13, 10, 0
opti2 db "COMECAR JOGO 2", 13, 10, 0

initX dw 90
initY dw 200
endX dw 550
endY dw 270
color db 7

string db "Loading... Please wait", 0

str1 db "BOOTLOADER", 0
str2 db "BIOS", 0
str3 db "PROCESS", 0
str4 db "DEADLOCK", 0

hangmanStr dw 0
lostStr db "You lost ", 0
winStr db "You win ", 0
lives db 10


start:
	xor ax, ax
	mov ds, ax
	mov es, ax

	call menu

	jmp done

menu:
        
    mov ah, 0
    mov al, 12h
    int 10h


    mov ah, 0xb
    mov bh, 0
    mov bl, 4
    int 10h



    mov cx, 1000

    while:

        call jump_line_7

        mov si, msg1
        call print_string

        call jump_line_2
        
        mov si, msg2
        call print_string

        call jump_line_1

        mov si, msg3
        call print_string

        call jump_line_1

        mov di, char
        call read_character

        mov al, '1'

        cmp al, [char]
        je opt1

        mov al, '2'
        
        cmp al, [char]
        je opt2

        call clear_screen

        loop while

    ret

opt1:
	call loading_screen_1
    ret

opt2:
	jmp loading_screen_2
    ret

print_string:

    lodsb      
    cmp al, 0  
    je .done
 
    mov ah, 0xe
    int 10h    
    
    jmp print_string
 
    .done:
        ret

jump_line_7:
    
    mov cx, 7
    
    L1:
        mov si, jline
        call print_string
    loop L1

    .done:
        ret

jump_line_2:
     mov cx, 2
    
    L2:
        mov si, jline
        call print_string
    loop L1

    .done:
        ret

jump_line_1:
    mov cx, 1
    
    L3:
        mov si, jline
        call print_string
    loop L1

    .done:
        ret

clear_screen:

    mov ah, 0
    mov al, 12h
    int 10h


    .done:
        ret

read_character:
    .read:
        mov ah, 0
        int 16h  
        
        cmp al, 0xd
        je .done

        stosb

    .done:
        mov al, 0  
        stosb
   
        ret
loading_screen_1:
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init

	mov ah, 0
	mov al, 12h
	int 10h
	mov ah, 0xb
	mov bh, 0
	mov bl, 4
	int 10h

	mov dh, 10 ; row
	mov dl, 30 ; column
	call cur_pos

	mov si, string
	call printstr

	call printRect
	mov byte [color], 0x8
	call printRect
	mov byte [color], 0x7
	call printRect
	mov byte [color], 0x8
	call printRect
	mov byte [color], 0x7
	call printRect

	jmp hangman_game

loading_screen_2:
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init

	mov ah, 0
	mov al, 12h
	int 10h
	mov ah, 0xb
	mov bh, 0
	mov bl, 4
	int 10h

	mov dh, 10 ; row
	mov dl, 30 ; column
	call cur_pos

	mov si, string
	call printstr

	call printRect
	mov byte [color], 0x8
	call printRect
	mov byte [color], 0x7
	call printRect
	mov byte [color], 0x8
	call printRect
	mov byte [color], 0x7
	call printRect

	jmp print_square

cur_pos:
	; setting cursor position
	mov ah, 02h
	int 10h
	ret

printColumn:
	push dx			; stores the initial value of Y

.loop:				; print loop
	cmp dx, bx		; check if the dx has been exceeded	
	jae .end		; if it it's, using a unsigned ge comparison, then compute next row
	
	push bx			; bx will be used at next interruption, so store it's value

	mov ah, 0ch		; Write graphics pixel -> AL = Color, BH = Page Number, CX = x, DX = y
	mov bh, 0
	int 10h			; call graphical interrupt
	
	pop bx			; restore bx value
	inc dx			; compute next coordinate

	jmp .loop		; do the loop again, printing next (x, y + 1) pixel
		
.end:				; increment X axis and set Y axis to start value
	inc cx			; if you want to print more than one row in the screen, cx will be the next coordinate
	pop dx			; and the dx, the initial value of y axis was stored
	ret

printRect:
.begin:
	mov dx, word [initY]
	mov bx, word [endY]
	mov cx, word [initX]
.loop:
	mov ax, word [endX]
	cmp cx, ax 
	jae .end

	mov al, byte [color]
	call printColumn

	jmp .loop
	
.end:
	ret

printstr:
	.start:

		lodsb 		; si -> al
		cmp al, 0
		je .done 	; if (end of string) return
		jmp .print 	; else print current char

		.print:
			mov ah, 0xe 	; print char and move cursor foward
			mov bh, 0 	; page number
			mov bl, 0xf 	; white color
			int 10h 	; video interrupt

			jmp .start 
		.done:
			ret

;;; print line (\n)
;; @reg: ax, bx
println:
	mov ah, 0xe ; char print
	mov bh, 0 ; page number
	mov bl, 0xf ; white color
	mov al, 13 ; vertical tab
	int 10h ; visual interrupt
	
	mov ah, 0xe ; char print
	mov bh, 0 ; page number
	mov bl, 0xf ; white color
	mov al, 10 ; backspace
	int 10h ; visual interrupt	

	ret

print_square:

	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init

	mov ah, 0
	mov al, 12h
	int 10h
	mov ah, 0xb
	mov bh, 0
	mov bl, 15
	int 10h

	call printRect

.loop:
	call VerticalRand
	call HorizontalRand

	mov cx, 15
	xor bx, bx ; bx = 0
	call randint ; return dx as the random int
	mov byte [color], dl

	call printRect

	jmp .loop

	jmp done

VerticalRand:
	mov cx, 200
	xor bx, bx ; bx = 0
	call randint ; return dx as the random int
	mov word [initY], dx

	mov cx, 280
	mov bx, 200
	call randint ; return dx as the random int
	mov word [endY], dx
.done:
	ret

HorizontalRand:

	mov cx, 300
	xor bx, bx ; bx = 0
	call randint ; return dx as the random int
	mov word [initX], dx

	mov cx, 340
	mov bx, 300 ; bx = 0
	call randint ; return dx as the random int
	mov word [endX], dx

.done:
	ret

;;; random number within a range (a:b)
;; @param: cx contains the absolute interval (b - a)
;; @param: bx contains the base (a)
;; @ret: dx, the random number
;; @reg: ax, bx, dx, cx
randint:
	.start:
		push bx
		push cx
	.timeInterrupt:
		xor ax, ax
		mov ah, 00h			; interrupts to get system time
		int 1ah				; CX:DX now hold number of clock ticks since midnight
	.processInterval:
		mov ax, dx
		xor dx, dx
		
		pop cx
		div cx

		pop bx
		add dx, bx

	.end:
		ret

;;; Print a rectangle
;; @param: Push the parameters onto stack
;; 1st push the end X
;; 2nd push the start X 
;; 3rd push end Y
;; 4th push initial Y
;; 5th push the color
;; @reg: ax, cx, bx, dx it also use a byte

printLine:
	push cx			; cx'll be used as a counter, so store the initial value of cx
.loop:				; print loop

	cmp cx, bx		; check if the cx has been exceeded	
	jae .nextRow		; if it it's, using a unsigned ge comparison, then compute next row
	
	push bx			; bx will be used at next interruption, so store it's value

	mov ah, 0ch		; Write graphics pixel -> AL = Color, BH = Page Number, CX = x, DX = y
	mov bh, 0
	int 10h			; call graphical interrupt
	
	pop bx			; restore bx value
	inc cx			; compute next coordinate

	jmp .loop		; do the loop again, printing next (x + 1, y) pixel
		
.nextRow:			; increment Y axis and set X axis to start value
	inc dx			; if you want to print more than one row in the screen, dx will be the next coordinate
	pop cx			; and the cx, the initial value of x axis was stored
	jmp .end
	
.end:
	ret

hangman_game:

	call clear_screen
	xor ax, ax		; reg init
	mov ds, ax 		; reg init
	mov es, ax 		; reg init	
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init

	mov cx, 4
	mov bx, 1
	call randint 		; randomly get a string

	cmp dx, 1
	je selectStr1

	cmp dx, 2
	je selectStr2

	cmp dx, 3
	je selectStr3

	cmp dx, 4
	je selectStr4

	jmp done

selectStr1:
	mov dx, str1
	call hangman
	jmp done
selectStr2:
	mov dx, str2
	call hangman
	jmp done
selectStr3:
	mov dx, str3
	call hangman
	jmp done
selectStr4:
	mov dx, str4
	call hangman
	jmp done

hangman:
	.start:
		mov [hangmanStr], dx
		mov si, [hangmanStr] 		; this will print the amount of chars
		call printHangMan
		call println

	.hangManLoop:

		call readLowerChar 		; read input

		mov si, [hangmanStr] 		; compute it
		mov di, [hangmanStr]
		call toLowerChar

		mov si, [hangmanStr]
		call printHangMan 		; display the string

		cmp dl, 0				; if the input isnt at the string, decrement a life
		je .decLive

		mov si, [hangmanStr]	; if there isn't any uppercase char in the string, then, the player won
		call isLower
		cmp dl, 0
		jne .win

		jmp .printLives			; print the current lives

	.decLive:
		dec byte [lives]		; the player lost one life
		cmp cl, byte [lives]	; check if he is dead
		je .lost

		jmp .printLives			; if not, print the current lives

	.printLives:
		
		mov ch, 0
		mov cl, byte [lives]	; cx will be used in a loop
		jmp .livesLoop			; go there

	.livesLoop:					; print <3 times 'lives' values
		mov ah, 0xe ; char print
		mov bh, 0 ; page number
		mov bl, 0xf ; white color
		
		mov al, ' '
		int 10h
		mov al, '<'
		int 10h ; visual interrupt
		mov al, '3'
		int 10h ; visual interrupt	

		loop .livesLoop

		call println
	 	jmp .hangManLoop

	.win:
		call println
		mov si, winStr
		jmp .done	

	.lost:
		call println

		mov si, [hangmanStr] 		; let the player know the string
		call printstr

		mov si, lostStr
		jmp .done

	.done:
		call printstr 				; print the endgame message

		call println
		ret

;;; Check if all letters of string are lowercase
;; @param: use si as string input
;; @ret: dl 0 if contains uppercase letters, 1 if not
;; @reg: dl, al, si
isLower:
	.start:
		mov dl, 1
	.loop:
		lodsb

		cmp al, 0
		je .done

		cmp al, 'A'
		jb .loop

		cmp al, 'Z'
		ja .loop

		jmp .thereIsUpper

	.thereIsUpper:
		mov dl, 0
		jmp .done

	.done:
		ret


;;; to lowercase all the uppercase chars in the string that matches with a char input
;; @param: al, the char (lowercase) ; si, the string
;; @ret: di, dl equals to 0 if nothing char was found
;; @reg: ax, dx, si, di
toLowerChar:
	.start:
		mov dl, 0
		mov dh, al
		mov ah, al
		sub ah, 32
		jmp .findLoop

	.findLoop:
		lodsb

		cmp al, 0
		je .done

		cmp al, ah
		je .toLower

		stosb
		jmp .findLoop

	.toLower:
		mov al, dh
		mov dl, 1
		stosb
		jmp .findLoop

	.done:
		mov al, 0
		stosb
		ret

;;; read (verbosely) a lower char, store it at al
;; @ret: al, the char
;; @reg: ax, bx
readLowerChar:
	.read:
		mov ah, 0 	; read keystroke
		int 16h		; keyboard interrupt

		; check if al is between (a, z) ;
		cmp al, 'a'
		jb .toLower

		cmp al, 'z'
		ja .toLower

		jmp .done  	; it it's

	.toLower:
		; check if al is between (A, Z) ;
		cmp al, 'A'
		jb .error

		cmp al, 'Z'
		ja .error

		add al, 32
		jmp .done 		; it it's

	.error:
		mov al, '*'		; al isn't a letter
		jmp .done

	.done:
		; mov ah, 0xe ; char print
		; mov bh, 0 ; page number
		; mov bl, 0xf ; white color
		; int 10h ; visual interrupt

		ret

;;; Print an array of chars, if the char is uppercase, then the output will be *
;; @param: use si as string input
printHangMan:
	.printLoop:

		lodsb 			; si -> al

		cmp al, 0		; check if al is end of string
		je .done

		; check if is al is lowercase
		cmp al, 'a'
		jb .hidePrint

		cmp al, 'z'
		ja .hidePrint

		jmp .print ; it it's


	.hidePrint:
		; check if al is uppercase
		cmp al, 'A'
		jb .error 		; if not, then al isn't a valid char

		cmp al, 'Z'
		ja .error

		mov al, '*'
		jmp .print 		; if it's, just print '*'

	.error:
		mov al, '#'		; error output
		jmp .print

	.print:
		mov ah, 0xe ; char print
		mov bh, 0 ; page number
		mov bl, 0xf ; white color
		int 10h ; visual interrupt
		jmp .printLoop

	.done:
		ret

;;; print line (\n)
;; @reg: ax, bx


done:
	jmp $