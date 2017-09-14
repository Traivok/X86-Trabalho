org 0x7c00
jmp 0x0000:start

initX dw 90
initY dw 200
endX dw 550
endY dw 270
color db 7

string db "                            Loading... Please wait", 0

start:
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

	mov cx, 10
	call enterR

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

	jmp done

;;Print CX lines
enterR:
	call println
	dec cx
	cmp cx, 0
	je .done
	jmp enterR

.done:
	ret

;;; Print a column of pixels
;; @param: al will be the color
;; @param: dx the start Y value, bx the end Y value
;; @param: cx the X value
;; @ret: cx will be the next X value
;; @red: ax, cx, dx, bx
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

;;; Print a rectangle
;; @param: Push the parameters onto stack
;; 1st push the end X
;; 2nd push the start X 
;; 3rd push end Y
;; 4th push initial Y
;; 5th push the color
;; @reg: ax, cx, bx, dx it also use a byte
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
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55