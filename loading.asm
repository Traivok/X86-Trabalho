org 0x7c00
jmp 0x0000:start

initX dw 90
initY dw 200
endX dw 550
endY dw 270
color db 7

str1 db "Loading structures for the kernel...", 13, 10, 0
str2 db "Setting up protected mode...", 13, 10, 0
str3 db "Loading kernel in memory...", 13, 10, 0
str4 db "Loading a lot of other things...", 13, 10, 0
str5 db "Loading reasons to live...", 13, 10, 0
str6 db "Shovelling coal into the server...", 13, 10, 0
str7 db "Feel free to wait forever...", 13, 10, 0
str8 db "Spinning up the hamster...", 13, 10, 0
str9 db "It is a little tired today...", 13, 10, 0
str9 db "Are you still here?", 13, 10, 0
str10 db "Okay, lets go..."

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

	jmp done

done:
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55