org 0x7e00
jmp 0x0000:start

msg1 db "MENU", 0
compare dw 0
msg2 db "1 - Hangman Game", 0
msg3 db "2 - Animation", 0
jline db " ", 13, 10, 0
char times 1 db 0
initial db "Press any key", 0
inst1 db "Welcome to Hangman Game!", 0
inst2 db "Guess the hidden word by typing each letter at a time.", 0
inst3 db "But take care, you only have 10 hearts!", 10, 10, 13, 0

gameover db "GAME OVER! MAYBE NEXT TIME", 0
win db "CONGRATULATIONS, YOU WON!", 0
option1 db "1 - Play again", 0
option2 db "2 - EXIT", 0

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
str5 db "INTERRUPTION", 0
str6 db "SYSTEM", 0
str7 db "MAINFRAME", 0
str8 db "MULTIPROGRAMMING", 0
str9 db "MULTIPROCESSOR", 0
str10 db "MICROKERNEL", 0
str11 db "SCHEDULER", 0
str12 db "ADDRESS", 0

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
    mov al, 13h
    int 10h

    mov ah, 0xb
    mov bh, 0
    mov bl, 4
    int 10h

    mov dh, 8
    mov dl, 18
    call cur_pos

    mov si, msg1
    call print_string

    mov dh, 10
    mov dl, 13
    call cur_pos

    mov si, msg2
    call print_string

    mov dh, 12
    mov dl, 13
    call cur_pos

    mov si, msg3
    call print_string

.while: ; enquanto não apertar um valor válido
    mov di, char
    call read_character

    mov al, '1'

    cmp al, [char] ; caso tenha apertado 1 vai pro hangman game
    je .opt1

    mov al, '2'
    
    cmp al, [char] ; caso tenha apertado 2 vai para a animação
    je .opt2

    jmp .while ; else lê o caractere novamente

.opt1:
	call loading_screen
	call hangman_game
	call endScreen
	jmp .done

.opt2:
	call print_square
	jmp .done

.done:
	ret

;;;;;; end of menu 

;; Print the end screen
; si as the end string
endScreen:
	; setting video mode
	mov ah, 0
	mov al, 13h
	int 10h

	mov dh, 9 ; row
	mov dl, 8 ; column
	call cur_pos

	call printstr

	mov dh, 12 ; row
	mov dl, 11 ; column
	call cur_pos

	mov si, option1
	call printstr

	mov dh, 14 ; row
	mov dl, 11 ; column
	call cur_pos

	mov si, option2
	call printstr

.while: ; enquanto não apertar um valor válido
    mov di, char
    call read_character

    mov al, '1'

    cmp al, [char] ; caso tenha apertado 1 vai pro hangman game
    je .opt1

    mov al, '2'
    
    cmp al, [char] ; caso tenha apertado 2 fecha
    je .done

    jmp .while ; else lê o caractere novamente

.opt1:
	call loading_screen
	call hangman_game
	call endScreen
	jmp .done

.done:
	ret

;; end of endScreen

loading_screen:
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

	ret

; end loading_screen

print_string:

    lodsb      
    cmp al, 0  
    je .done
 
    mov ah, 0xe
    int 10h
    
    jmp print_string
 
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

;; Set cursor position
;; param: dh as row, dl as the column
;; reg: 
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

; printa retângulos aleatórios, de tamanhos aleatórios
print_square:
	mov ah, 0
	mov al, 12h
	int 10h
	mov ah, 0xb
	mov bh, 0
	mov bl, 15
	int 10h

.loop:

	call VerticalRand
	call HorizontalRand

	mov cx, 15
	xor bx, bx ; bx = 0
	call randint ; return dx as the random int
	mov byte [color], dl

	call printRect

	jmp .loop

	ret

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

; Funções do print_square
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

	mov dh, 1
	mov dl, 24
	call cur_pos
	mov si, inst1
	call printstr

	mov dh, 2
	mov dl, 13
	call cur_pos
	mov si, inst2
	call printstr

	mov dh, 3
	mov dl, 13
	call cur_pos
	mov si, inst3
	call printstr

.rand:
	mov cx, 12
	mov bx, 1
	call randint 		; randomly get a string

	cmp dx, [compare] ; assures that the new word will never be equal to the last one
	je .rand

	mov word [compare], dx

	cmp dx, 1
	je .selectStr1

	cmp dx, 2
	je .selectStr2

	cmp dx, 3
	je .selectStr3

	cmp dx, 4
	je .selectStr4

	cmp dx, 5
	je .selectStr5

	cmp dx, 6
	je .selectStr6

	cmp dx, 7
	je .selectStr7

	cmp dx, 8
	je .selectStr8

	cmp dx, 9
	je .selectStr9

	cmp dx, 10
	je .selectStr10

	cmp dx, 11
	je .selectStr11

	cmp dx, 12
	je .selectStr12

	jmp .done

.selectStr1:
	mov dx, str1
	call hangman
	jmp .done
.selectStr2:
	mov dx, str2
	call hangman
	jmp .done
.selectStr3:
	mov dx, str3
	call hangman
	jmp .done
.selectStr4:
	mov dx, str4
	call hangman
	jmp .done
.selectStr5:
	mov dx, str5
	call hangman
	jmp .done
.selectStr6:
	mov dx, str6
	call hangman
	jmp .done
.selectStr7:
	mov dx, str7
	call hangman
	jmp .done
.selectStr8:
	mov dx, str8
	call hangman
	jmp .done
.selectStr9:
	mov dx, str9
	call hangman
	jmp .done
.selectStr10:
	mov dx, str10
	call hangman
	jmp .done
.selectStr11:
	mov dx, str11
	call hangman
	jmp .done
.selectStr12:
	mov dx, str12
	call hangman
	jmp .done

.done:
	ret

; end of hangman_game

hangman:
	.start:

		mov byte [lives], 10

		mov [hangmanStr], dx
		mov si, [hangmanStr] 		; next will set all letters to upper
		mov di, [hangmanStr]
		call toUpper

		mov si, [hangmanStr]

		call printHangMan
		call println

	.hangManLoop:

		xor ax, ax

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
		call printstr
		mov si, win  ; will be used in the endScreen
		jmp .done	

	.lost:
		call println

		mov si, [hangmanStr] 		; let the player know the string
		call printstr
		call println

		mov si, lostStr
		call printstr
		mov si, gameover ; will be used in the endScreen
		jmp .done

	.done:
		ret

; end of hangman

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
		ret

;;; Set lowercase letters to uppercase
;; @param: si, the source string
;; @ret: di, the output string
;; @reg: al
toUpper:
	lodsb 			; get a char of input string
	
	cmp al, 0		; check if its the end of string
	je .done		; in case of that, go to done

	; checking if the char is in [a,z] interval
	cmp al, 'a'
	jb .store

	cmp al, 'z'
	ja .store 	; if it's, process it

	jmp .convert	; else, convert to upperCase

	.convert:
		add al, -32 	; a - A is 32, so subtract 32 from al
		jmp .store 		; and store it
	.store:
		stosb
		jmp toUpper
	.done:
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


done:
	; exits the program
	mov ax,0x5307
	mov bx,0x0001
	mov cx,0x0003
	int 0x15
	jmp $