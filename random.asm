org 0x7c00
jmp 0x0000:start

start:
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init	


	
	jmp done
	


done:
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55
