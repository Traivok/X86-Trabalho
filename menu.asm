org 0x7c00        
jmp 0x0000:start

msg1 db "                                       MENU", 13, 10, 0
msg2 db "                                1 - Hangman Game", 13, 10, 0
msg3 db "                                2 - Genius", 13, 10, 0
jline db " ", 13, 10, 0
char times 1 db 0
initial db "Press any key", 0
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
    mov si, opti1
    call print_string
    ret

opt2:
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

done:
    jmp $      
 
times 510 - ($ - $$) db 0
dw 0xaa55