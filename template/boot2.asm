org 0x500
jmp 0x0000:start

str1 db 10, "Loading structures for the kernel...", 0
str2 db 13, 10, 10, "Setting up protected mode...", 0
str3 db 13, 10, 10, "Loading kernel in memory...", 0
str4 db 13, 10, 10, "Loading a lot of other things...", 0
str5 db 13, 10, 10, "Loading reasons to live... ERROR", 0
str6 db 13, 10, 10, "Shovelling coal into the server...", 0
str7 db 13, 10, 10, "Feel free to wait forever...", 0
str8 db 13, 10, 10, "Spinning up the hamster...", 0
str9 db 13, 10, 10, "It is a little tired today...", 0
str10 db 13, 10, 10, "Are you still here?", 0
str11 db 13, 10, 10, "Okay, lets go...", 0
	
start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; setting text mode
	mov ax, 0003h
 	int 10h

	;call message
	
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

message:
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

	ret

;; 1 < x < 2 second delay
delay:
	mov cx, 0fh
	mov dx, 9999h
	mov ah, 86h
	int 15h
	mov cx, 0ah
	mov dx, 0
	mov ah, 86h
	int 15h
	ret

;;; print string with delay at the end
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
	
load:
    mov ah, 02h ;lê um setor do disco
    mov al, 20  ;quantidade de setores ocupados pelo kernel
    mov ch, 0   ;track 0
    mov cl, 5   ;sector 3
    mov dh, 0   ;head 0
    mov dl, 0   ;drive 0
    int 13h

    jc load     ;se o acesso falhar, tenta novamente

    jmp 0x7e00  ;pula para o setor de endereco 0x7e00 (start do boot2)