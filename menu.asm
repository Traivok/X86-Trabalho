org 0x7c00        
jmp 0x0000:start

msg1 db "                   MENU", 13, 10, 0
msg2 db "            1 - Hangman Game", 13, 10, 0
msg3 db "            2 - Genius", 13, 10, 0
jline db " ", 13, 10, 0
char times 1 db 0
selection db "Select your option: ", 0
opti1 db "COMECAR JOGO 1", 13, 10, 0
opti2 db "COMECAR JOGO 2", 13, 10, 0

start:
    xor ax, ax
    mov cl, 0 
    mov ds, ax  
    mov es, ax
    

    call menu

    jmp done

menu:
    
    mov ah, 0
    mov bh, 13h
    int 10h

    mov ah, 0xb
    mov bh, 0
    mov bl, 4
    int 10h

    call jump_line

    mov si, msg1
    call print_string

    mov si, jline
    call print_string
    mov si, jline
    call print_string
    
    mov si, msg2
    call print_string

    mov si, jline
    call print_string

    mov si, msg3
    call print_string

    mov si, jline
    call print_string
    
    mov si, selection
    call print_string

    mov di, char
    call read_character

    mov si, char
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

jump_line:
    
    mov cx, 7
    
    L1:
        mov si, jline
        call print_string
    loop L1

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

done:
    jmp $      
 
times 510 - ($ - $$) db 0
dw 0xaa55