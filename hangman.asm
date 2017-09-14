org 0x7c00
jmp 0x0000:start

str1 db "BOOTLOADER", 0
str2 db "BIOS", 0
str3 db "PROCESS", 0
str4 db "DEADLOCK", 0

hangmanStr dw 0
lostStr db "You lost ", 0
winStr db "You win ", 0
lives db 10

start:
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


;;; print string
;; @param: use si to print
;; @reg: ax, bx
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
		mov ah, 00h	; interrupts to get system time
		int 1ah	; CX:DX now hold number of clock ticks since midnight
	.processInterval:
		mov ax, dx
		xor dx, dx
		pop cx
		div cx
		pop bx
		add dx, bx
	.end:
		ret
	
	
done:
	jmp $ 			; infinity jump

times 510-($-$$) db 0   ; Pad remainder of boot sector with 0s
dw 0xAA55               ; The standard PC boot signature