org 0x7c00
jmp 0x0000:start

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
	mov bl, 15
	int 10h

	mov al, 0xf
	mov cx, 0
	mov bx, 512
	mov dx, 256
	call printLine
	
	jmp done
	
;;; Print a line of pixels
;; @param: al will be the color
;; @param: cx the start X value, bx the end X value
;; @param: dx the Y value
;; @ret: dx will be the next Y value, and cx, dx will be restored
;; @reg: ax, cx, bx
printLine:
	push cx			; cx'll be used as a counter, so store the initial value of cx
.loop:				; print loop

	cmp cx, bx		; check if the cx has been exceeded	
	jae .nextRow		; if it it's, using a unsigned ge comparison, then compute next row
	
	push bx			; bx will be used at next interruption, so store it's value

	mov al, 0xf
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


done:
jmp $
times 510-($-$$) db 0
dw 0xaa55
