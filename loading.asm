org 0x7c00
jmp 0x0000:start

str1 db "Loading structures for the kernel...", 13, 10, 0
str2 db "Setting up protected mode...", 13, 10, 0
str3 db "Loading kernel in memory...", 13, 10, 0
str4 db "Loading a lot of other things...", 13, 10, 0
str5 db "Loading reasons to live... ERROR", 13, 10, 0
str6 db "Shovelling coal into the server...", 13, 10, 0
str7 db "Feel free to wait forever...", 13, 10, 0
str8 db "Spinning up the hamster...", 13, 10, 0
str9 db "It is a little tired today...", 13, 10, 0
str10 db "Are you still here?", 13, 10, 0
str11 db "Okay, lets go...", 13, 10, 0

start:
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init

	mov ah, 0
	mov al, 12h
	int 10h
	; mov ah, 0xb
	; mov bh, 0
	; mov bl, 4
	; int 10h

	mov si, str1
	call printstr

	mov si, str2
	call printstr

	mov si, str3
	call printstr

	mov si, str4
	call printstr

	mov si, str5
	call printstr

	mov si, str6
	call printstr

	mov si, str7
	call printstr

	mov si, str8
	call printstr

	mov si, str9
	call printstr

	mov si, str10
	call printstr

	mov si, str11
	call printstr
	jmp done

;; 1 second delay
delay:
	mov cx, 0fh
	mov dx, 4240h
	mov ah, 86h
	int 15h

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
			call delay
			ret

done:
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55