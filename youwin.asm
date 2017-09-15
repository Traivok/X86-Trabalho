org 0x7c00
jmp 0x0000:start

str1 db "CONGRATULATIONS, YOU WON!", 0
str2 db "1 - Play again", 0
str3 db "2 - EXIT", 0


start:

	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init

	; setting video mode
	mov ah, 0
	mov al, 13h
	int 10h

	mov dh, 9 ; row
	mov dl, 8 ; column
	call cur_pos

	; ; backgroud color
	; mov ah, 0xb
	; mov bh, 0
	; mov bl, 0
	; int 10h

	mov si, str1
	call printstr

	mov dh, 12 ; row
	mov dl, 11 ; column
	call cur_pos

	mov si, str2
	call printstr

	mov dh, 14 ; row
	mov dl, 11 ; column
	call cur_pos

	mov si, str3
	call printstr

	jmp done

;; Set cursor position
;; param: dh as row, dl as the column
;; reg: 
cur_pos:
	; setting cursor position
	mov ah, 02h
	int 10h
	ret 

;; Print char with color
;; Param: al as the char to be printed
;; bl as the color
;; cx as the number of times it will be printed
;; Video mode has to be 12h
;; Does not change the cursor position
colorChar:
	mov ah, 09h
	int 10h
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

done:
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55
