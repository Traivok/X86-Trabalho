org 0x7c00
jmp 0x0000:start

string times 64 db 0 ;times 32 db 0

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init
	
	mov cx, 20
	mov bx, 1000
	call randint

	mov ax, dx
	mov di, string
	call tostring


	mov si, string
	call printstr

	jmp done
	
;;; random number within a range (a:b)
;; @param: cx contains the absolute interval (b - a)
;; @param: bx contains the base (a)
;; @ret: dx, the random number
;; @reg: ax, bx, dx, cx
randint:
	.start:
		push bx
		push cx
	.timeInterrupt:
		xor ax, ax
		mov ah, 00h			; interrupts to get system time
		int 1ah				; CX:DX now hold number of clock ticks since midnight
	.processInterval:
		mov ax, dx
		xor dx, dx
		
		pop cx
		div cx

		pop bx
		add dx, bx

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

;;; integer to string -- string	to_string(int*)
;; @param use ax as number input
;; @return di as string output
;; @reg: ax, bl, sp, di
tostring:
	
	push 0 			; push '\0' end of string

.convert:			; convert every digit of integer input into characters
	
	mov bl, 10		; let number = 123, then, after div, 12 will be al, and 3 will be ah
	div bl			; so, we need to push 3 onto stack and recursively convert (number/10) until the result be zero 
	add ah, '0'		; convert remainder to ascii...

	mov dl, ah		; (although the remainder is stored to ah, the stosb works with al)
	push dx			; ...and push it	

	cmp al, 0		; base case condition
	je .concat
	
	mov ah, 0		; the remainder was pushed onto stack, we dont need it anymore so AX = [3, 12] -> [0, 12]
	jmp .convert
	
.concat:			; concat every char of stack into a string
	
	pop ax			; get top of stack and pop it
	
	stosb			; store al at di
	
	cmp al, 0 		; if end of string
	je .done		; goto done
	jmp .concat
	
.done:
	ret


done:
	jmp $
	times 510-($-$$) db 0
	dw 0xaa55
