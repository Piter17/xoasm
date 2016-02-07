section .data


string_m1: db '   |   |   ', 0xa, 0
string_m2: db ' %c | %c | %c ', 0xa, 0
string_m3: db '-----------', 0xa, 0
string_fmt: db '%s', 0xa, 0
string_emptyline: db 0xa, 0
int_fmt: db '%3.i', 0xa, 0
turn_fmt: db 'tura: %c', 0xa, 0
hello_txt: db 'Kolko i krzyzyk', 0 
win_txt: db 'Wygral gracz %c', 0xa, 0
tie_txt: db 'Remis', 0xa, 0
int_c: dd 0
int_i: dd 0
int_turns: dd 0
map_ptr: dd ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
int_turn: dd 'o'
int_chacter: dd 0

section .text


extern exit
extern _getch
extern putchar
extern printf

;main
global Start
Start:
    push hello_txt
    push string_fmt
    call printf
    add esp, 8

;głowna pętla
    l:
        ;jeśli było już 9 tur -> remis
        cmp dword [int_turns], 9
        jge Tie
        push dword [int_turn]
        push turn_fmt
        call printf
        add esp, 8
    
        push map_ptr
        call DrawMap
        add esp, 4
        
        push string_emptyline
        call printf
        add esp, 4
    
;brak poprawnego wejścia -> skok tutaj
    l2:

        call _getch
        cmp eax, 'q'
        je exitGame
        sub eax, '1'
        cmp eax, 9
        jge l2
        
;zamiana przycisków 1,2,3 na 7,8,9 i na odwrót
        cmp eax, 2
        jle rev1
        cmp eax, 6
        jge rev2
        jmp revpost
        rev1:
        add eax, 6
        jmp revpost
        rev2:
        sub eax, 6
        revpost:
        
;sprawdzenie czy pole jest puste
        cmp dword [map_ptr+4*eax], ' '
        jne l2
        
;narysowanie znaku na mapie i inkrementacja licznika
        add dword [int_turns], 1
        mov ecx, [int_turn]
        mov dword [map_ptr+4*eax], ecx
        
;sprawdzenie czy ktoś wygrał
        push map_ptr
        call WhoWon
        add esp, 4
        cmp eax, 0
        jne won        
        
;zmiana tury
        cmp dword [int_turn], 'o'
        je setx
        mov dword [int_turn], 'o'
        jmp l
        
        setx:
        mov dword [int_turn], 'x'         
        jmp l
    end_loop:
    ;zwycięstwo
    won:
    push eax
    push map_ptr
    call DrawMap
    add esp, 4
    pop eax
    
    push eax
    push win_txt
    call printf
    add esp, 8
    
    ;wyjście
    exitGame:
    xor eax, eax
    push eax
    call exit
    ret
    
    ;remis
    Tie:
    push map_ptr
    call DrawMap
    add esp, 4
    
    push tie_txt
    call printf
    add esp, 4
    jmp exitGame
    
;funkcja sprawdza czy ktoś wygrał
;WhoWon(map)
WhoWon:
    ;FindPattern(map, 'o')
    mov ecx, [esp+4]
    push dword 'o'
    push ecx
    call FindPattern
    add esp, 8
    cmp eax, 1
    je reto
    
    ;FindPattern(map, 'x')
    push dword 'x'
    push ecx
    call FindPattern
    add esp, 8
    cmp eax, 1
    je retx
    
    ;nikt jeszcze nie wygrał
    mov eax, 0
    ret
    
    ;zwracam kto wygrał
    reto:
    mov dword eax, 'o'
    ret
    retx:
    mov dword eax, 'x'
    ret
    
FindPattern: ; FindPattern(map, player)
    mov ecx, [esp+4]
    mov ebx, [esp+8]
    
    ;if(map[0+eax*3]+map[1+eax*3]+map[2+eax*3]==player*3)
    ;    jmp Found
    ;---
    lea ebx, [ebx*3]
    xor eax, eax
    F1:
        xor edx, edx
        lea esi, [eax * 3]
        lea esi, [ecx + esi * 4]
        add edx, [esi + 0]
        add edx, [esi + 4]
        add edx, [esi + 8]
        cmp edx, ebx
        je Found
        cmp eax, 2
        je F1E
        inc eax
        jmp F1
    F1E:
        xor eax, eax
        
    ;if(map[eax]+map[eax+3]+map[eax+6]==player*3)
    ;    jmp Found
    F2:
        ;|||
        xor edx, edx
        add edx, [ecx + eax * 4 + 0]
        add edx, [ecx + eax * 4 + 12]
        add edx, [ecx + eax * 4 + 24]
        cmp edx, ebx
        je Found
        cmp eax, 2
        je F2E
        inc eax
        jmp F2
    F2E:
        ;if(map[0]+map[4]+map[8]==player*3)
        ;jmp Found
        ;\\\
        xor eax, eax
        xor edx, edx
        add edx, [ecx + 0]    
        add edx, [ecx + 16]
        add edx, [ecx + 32]
        cmp edx, ebx
        je Found
        ;if(map[2]+map[4]+map[6]==player*3)
        ;jmp Found
        ;///
        xor edx, edx
        add edx, [ecx + 8]
        add edx, [ecx + 16]
        add edx, [ecx + 24]
        cmp edx, ebx
        je Found
        jmp NotFound        
    
    Found:
    mov eax, 1    
    ret
    
    NotFound:
    xor eax, eax
    ret
    

;DrawMap(map)
DrawMap:
    push string_m1
    call printf                 ;   |   |   
    add esp, 4
    mov ecx, [esp+4]
    push dword [ecx+2*4]
    push dword [ecx+1*4]
    push dword [ecx+0*4]
    push string_m2
    call printf                 ; %c | %c | %c  
    add esp, 4*4
    push string_m1
    call printf                 ;   |   |   
    add esp, 4
    
    push string_m3
    call printf                 ;-----------
    add esp, 4
    
    push string_m1
    call printf                 ;   |   |  
    add esp, 4
    mov ecx, [esp+4]
    push dword [ecx+5*4]
    push dword [ecx+4*4]
    push dword [ecx+3*4]
    push string_m2  
    call printf                 ; %c | %c | %c  
    add esp, 4*4
    push string_m1              ;   |   |  
    call printf
    add esp, 4
    
    push string_m3
    call printf                 ;-----------
    add esp, 4
    
    push string_m1
    call printf                 ;   |   |  
    add esp, 4
    mov ecx, [esp+4]
    push dword [ecx+8*4]
    push dword [ecx+7*4]
    push dword [ecx+6*4]
    push string_m2
    call printf                 ; %c | %c | %c  
    add esp, 4*4
    push string_m1              ;   |   |  
    call printf
    add esp, 4
    ret