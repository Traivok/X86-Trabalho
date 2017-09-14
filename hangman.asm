org 0x7c00
jmp 0x0000:start

teststr times 32 db 0 
hangmanStr db "BOOTLOADER", 0
winStr db "You win ", 0
lostStr db "You lost ", 0
lives db 10

start:
	xor ax, ax		; reg init
	mov ds, ax 		; reg init
	mov es, ax 		; reg init	
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init

	call hangman

	jmp done

hangman:
	.hangManLoop:
		mov al, byte [lives]
		cmp al, 0
		jl .lost

		call readLowerChar

		mov si, hangmanStr
		mov di, hangmanStr
		call toLowerChar
		call printstr

		cmp dl, 0
		je .decLive

	 	mov cx, byte [lives]
		jmp .printLives

	.decLive:
		dec byte [lives]
		jmp .hangManLoop

	.printLives:

	 	jmp .hangManLoop

	.win:
		mov si, winStr
		jmp .done	

	.lost:
		mov si, lostStr
		jmp .done

	.done:
		call printstr

		mov si, hangmanStr
		call printstr

		call println
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

		jmp .print  	; it it's

	.toLower:
		; check if al is between (A, Z) ;
		cmp al, 'A'
		jb .error

		cmp al, 'Z'
		ja .error

		add al, 32
		jmp .print 		; it it's

	.error:
		mov al, '*'		; al isn't a letter
		jmp .print

	.print:
		mov ah, 0xe ; char print
		mov bh, 0 ; page number
		mov bl, 0xf ; white color
		int 10h ; visual interrupt

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


		
	
done:
	jmp $ 			; infinity jump

times 510-($-$$) db 0   ; Pad remainder of boot sector with 0s
dw 0xAA55               ; The standard PC boot signature