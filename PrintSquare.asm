org 0x7c00
jmp 0x0000:start

initX dw 5
initY dw 0
endX dw 200
endY dw 250
color db 0xb

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

;; 1st push the end X
;; 2nd push the start X 
;; 3rd push end Y
;; 4th push initial Y
;; 5th push the color

	call printRect

	mov word [initX], 10
	mov word [initY], 20
	mov word [endX], 300
	mov word [endY], 400
	mov word [color], 4

	call printRect

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

done:
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55