org 0x7e00
jmp 0x0000:start

msg1 db "                                       MENU", 13, 10, 0
msg2 db "                                1 - Hangman Game", 13, 10, 0
msg3 db "                                2 - Genius", 13, 10, 0
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
	call loading_screen
    mov si, opti1
    call print_string
    ret

opt2:
	call loading_screen
    mov si, opti2
    call print_string
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

loading_screen:
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

	ret

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


done:
	jmp $