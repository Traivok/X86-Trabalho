org 0x500
jmp 0x0000:start

str1 db "Loading structures for the kernel...", 0
str2 db "Setting up protected mode...", 0
str3 db	"Loading kernel in memory...", 0
stringAmount dw 4
initX dw 90
initY dw 200
endX dw 550
endY dw 270
color db 7
	
start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, str1
    call displayLoad
    mov si, str2
    call displayLoad
    mov si, str3
    call displayLoad
	
    mov ax, 0x7e0 ;0x7e0<<1 = 0x7e00 (início de kernel.asm)
    mov es, ax
    xor bx, bx    ;posição es<<1+bx
	
    jmp reset

reset:
	mov ah, 00h ;reseta o controlador de disco
    mov dl, 0   ;floppy disk
    int 13h

    jc reset    ;se o acesso falhar, tenta novamente	
	
    jmp load

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

	
load:
    mov ah, 02h ;lê um setor do disco
    mov al, 20  ;quantidade de setores ocupados pelo kernel
    mov ch, 0   ;track 0
    mov cl, 3   ;sector 3
    mov dh, 0   ;head 0
    mov dl, 0   ;drive 0
    int 13h

    jc load     ;se o acesso falhar, tenta novamente

    jmp 0x7e00  ;pula para o setor de endereco 0x7e00 (start do boot2)

;; Set cursor position
;; param: dh as row, dl as the column
;; reg: 
cur_pos:
	; setting cursor position
	mov ah, 02h
	int 10h
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

displayLoad:
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

	call printstr

	call printRect
	; mov byte [color], 0x8
	; call printRect
	; mov byte [color], 0x7
	; call printRect
	; mov byte [color], 0x8
	; call printRect
	; mov byte [color], 0x7
	; call printRect

	ret
