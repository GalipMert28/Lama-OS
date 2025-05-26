section .data
    matrix      db 80*25 dup(?),'$' ; 25 satır, 80 kolon
    matrix_2  db 22 dup(?)        ;   
    row       db 2                ; navigasyon satır
    column    db 0                ; navigasyon kolon
    curr_line db 2                ; satır
    curr_char db 0                ; karakter pozisyon

    deco1     db '  =================================================$'
    deco2     db '||     L-EDIT Command Line Text Editor             ||$'
    deco3     db '||                                                 ||$'
    deco4     db '||         ESC = Exit || CTRL+S = Save File        ||$'
    deco5     db '||              ARROW KEYS = Navigate              ||$'
    deco6     db '  =================================================$'
    docPrompt db 'Enter Document Name (.txt): $'
    docName   dw 50 dup(?),'$'
    openPrompt db 'Enter Document Name to Open: $'
    HANDLE    dw ? 
    header    db 80 dup('='),'$'    

section .bss
    ; boş alanlar gerekirse

section .text
    global _start

_start:
    ; Sistem başlangıcı
    ; (İşte temel giriş ve ana döngü burada)

    ; Sistem ayarları (örneğin ekran temizleme)
    ; (İşte burada başlangıç ayarları: ekran temizleme vb.)
    mov ah, 01h
    mov cx, 07h
    int 10h  ; cursor şekli ayarı
    call clrScrn
    call start_menu
    call upper_bar
    mov si, offset matrix
    mov di, offset matrix_2
    mov row, 2
    mov column, 0
    mov curr_line, 2
    mov curr_char, 0
    mov row, 2
    mov column, 0
    goto_pos 2, 0

main_loop:
    ; Girişleri al
    mov ah, 00h
    int 16h
    ; AH, klavye scan kodu
    cmp ah, 1Bh    ; ESC tuşu
    je exit_program
    cmp al, 13h    ; Enter (newline)
    je handle_enter
    cmp al, 08h    ; Backspace
    je handle_backspace
    cmp ah, 48h    ; Up arrow
    je move_up
    cmp ah, 50h    ; Down arrow
    je move_down
    cmp ah, 4Bh    ; Left arrow
    je move_left
    cmp ah, 4Dh    ; Right arrow
    je move_right
    cmp ah, 1Ch    ; Ctrl+S (save)
    je save_file
    ; Herhangi başka bir karakter ise yaz
    mov dl, al
    mov ah, 02h
    int 21h

    ; Karakterleri kaydet
    mov [si], al
    inc si
    inc curr_char
    inc column
    goto_pos row, column
    jmp main_loop

exit_program:
    ; Sistemden çıkış
    mov ax, 4C00h
    int 21h

handle_enter:
    ; Enter ile yeni satıra geç
    call newline
    mov [si], 10
    inc si
    mov dl, curr_char
    mov [di], dl
    inc di
    inc curr_line
    mov curr_char, 0
    mov row, curr_line
    mov column, 0
    goto_pos row, 0
    jmp main_loop

handle_backspace:
    ; Geri alma
    cmp curr_line, 2
    je go_back_line
    cmp curr_char, 0
    je go_back_line
    dec si
    dec curr_char
    dec column
    mov [si], 0
    remove
    goto_pos row, column
    jmp main_loop

go_back_line:
    ; Önceki satıra dön
    dec curr_line
    dec row
    dec di
    mov dl, [di]
    mov column, dl
    goto_pos curr_line, dl
    mov dl, [di]
    mov curr_char, dl
    jmp main_loop

move_up:
    cmp row, 2
    je main_loop
    dec curr_line
    dec row
    goto_pos row, column
    jmp main_loop

move_down:
    inc curr_line
    inc row
    goto_pos row, column
    jmp main_loop

move_left:
    dec column
    goto_pos row, column
    jmp main_loop

move_right:
    inc column
    goto_pos row, column
    jmp main_loop

save_file:
    ; Dos ile kaydet
    mov ah, 3Ch
    mov cx, 0
    mov dx, offset docName
    int 21h
    mov [HANDLE], ax
    mov ah, 40h
    mov bx, [HANDLE]
    mov cx, 2000
    mov dx, offset matrix
    int 21h
    ; Dos dosyasını kapat (opsiyonel)
    mov ah, 3Eh
    mov bx, [HANDLE]
    int 21h
    jmp main_loop

start_menu:
    ; Ana menü
    goto_pos 5, 12
    mov dx, offset deco1
    mov ah, 9
    int 21h
    goto_pos 6, 12
    mov dx, offset deco2
    mov ah, 9
    int 21h
    goto_pos 7, 12
    mov dx, offset deco3
    mov ah, 9
    int 21h
    goto_pos 8, 12
    mov dx, offset deco4
    mov ah, 9
    int 21h
    goto_pos 9, 12
    mov dx, offset deco5
    mov ah, 9
    int 21h
    goto_pos 10, 12
    mov dx, offset deco6
    mov ah, 9
    int 21h
    goto_pos 13, 12
    mov dx, offset docPrompt
    mov ah, 9
    int 21h

    ; Document name giriş
    mov cx, 0
    mov si, offset docName
input_docname:
    mov ah, 1
    int 21h
    cmp al, 13h
    je start_editor
    cmp al, 08h
    je remove_char
    inc cx
    mov [si], al
    inc si
    jmp input_docname

remove_char:
    cmp cx, 0
    je input_docname
    dec cx
    dec si
    mov [si], 0
    mov dl, 32
    mov ah, 2
    int 21h
    mov dl, 8
    int 21h
    jmp input_docname

start_editor:
    ; Dos dosyasını aç veya yeni oluştur
    mov ah, 3Dh
    mov al, 2 ; okuma
    mov dx, offset docName
    int 21h
    mov [HANDLE], ax
    ; Dos dosyasını oku
    mov ah, 3Fh
    mov bx, [HANDLE]
    mov cx, 1760
    mov dx, offset matrix
    int 21h
    ; Dos dosyasını kapat
    mov ah, 3Eh
    mov bx, [HANDLE]
    int 21h
    ; Texti ekrana yaz
    mov dx, offset matrix
    mov ah, 9
    int 21h
    jmp main_loop

; Yardımcı prosedürler
newline:
    mov dl, 10
    mov ah, 2
    int 21h
    mov dl, 13
    mov ah, 2
    int 21h
    ret

remove:
    ; Karakter silme
    mov dl, 8
    mov ah, 2
    int 21h
    mov dl, 32
    mov ah, 2
    int 21h
    mov dl, 8
    mov ah, 2
    int 21h
    ret

goto_pos:
    ; ekran pozisyon ayarı (row, col)
    ; row ve col registerlar kullanılacak
    push ax
    push dx
    mov ah, 02h
    mov dh, [row]
    mov dl, [column]
    int 10h
    pop dx
    pop ax
    ret

upper_bar:
    goto_pos 0, 0
    mov dx, offset docName
    mov ah, 9
    int 21h
    goto_pos 1, 0
    mov dx, offset header
    mov ah, 9
    int 21h
    ret

clrScrn:
    ; ekran temizleme
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    ret
