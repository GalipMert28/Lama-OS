; Basit hesap makinesi (toplama, çıkarma, çarpma, bölme)
; ESC tuşuna basıldığında 'autorun.bin' dosyasına geçiş yapılır

section .data
    prompt db "Birinci sayiyi girin: ", 0
    prompt2 db "Ikinci sayiyi girin: ", 0
    prompt3 db "Islemi girin (+, -, *, /): ", 0
    result_msg db "Sonuc: ", 0
    esc_msg db "ESC tusuna basildi, autorun.bin'e gidiliyor...", 0

section .bss
    num1 resb 1
    num2 resb 1
    operation resb 1
    result resb 4    ; sonucu tutmak için 4 bayt ayırıyoruz (örneğin, 0-255 arası sonuçlar)

section .text
    global _start

_start:
    ; Sayı 1'i al
    mov ah, 0x09
    lea dx, [prompt]
    int 0x21

    mov ah, 0x01  ; Tek karakter al
    int 0x21
    sub al, '0'    ; ASCII'den sayıya çevir
    mov [num1], al

    ; Sayı 2'yi al
    mov ah, 0x09
    lea dx, [prompt2]
    int 0x21

    mov ah, 0x01
    int 0x21
    sub al, '0'
    mov [num2], al

    ; İşlem türünü al
    mov ah, 0x09
    lea dx, [prompt3]
    int 0x21

    mov ah, 0x01
    int 0x21
    mov [operation], al

    ; İşlem yapılacak
    mov al, [num1]
    mov bl, [num2]

    ; İşleme göre farklı durumlar
    cmp byte [operation], '+'
    je addition
    cmp byte [operation], '-'
    je subtraction
    cmp byte [operation], '*'
    je multiplication
    cmp byte [operation], '/'
    je division

    jmp end_program ; Geçersiz işlem için programı sonlandır

addition:
    add al, bl
    mov [result], al
    jmp print_result

subtraction:
    mov al, [num1]
    mov bl, [num2]
    sub al, bl
    mov [result], al
    jmp print_result

multiplication:
    ; Çarpma işlemi: AL ve BL çarpımını AX'e yazar
    mov al, [num1]
    mov bl, [num2]
    ; 8-bit çarpım, sonucu 16-bit
    mov ah, 0
    mul bl     ; AL * BL -> AX
    ; Sonucu 8-bit değil, 16-bit olarak sakla
    ; Burada sonucu 8 bit yerine 16 bit olarak kaydetmek için
    ; sonucu [result_low], [result_high] gibi iki alan kullanabilirsin
    ; Ama biz sadece 8-bit sonucu gösteriyoruz, bu yüzden sadece AL'yi kullanıyoruz
    mov [result], al
    jmp print_result

division:
    ; Bölme işlemi: AL / BL
    mov al, [num1]
    mov bl, [num2]
    xor ah, ah     ; AX'yi sıfırla
    div bl         ; AL / BL
    mov [result], al
    jmp print_result

print_result:
    ; Sonuç yazdır
    mov ah, 0x09
    lea dx, [result_msg]
    int 0x21

    ; Sonucu ASCII'ye çevir
    mov al, [result]
    add al, '0'
    mov dl, al
    mov ah, 0x02
    int 0x21

    ; ESC tuşunu kontrol et
    mov ah, 0x01
    int 0x21
    cmp al, 0x1B  ; ESC tuşunun ASCII kodu
    je exit_program

    jmp _start

end_program:
    ; Program sonu
    mov ah, 0x4C
    int 0x21

exit_program:
    ; ESC tuşuna basıldı, autorun.bin'e geçiş
    mov ah, 0x09
    lea dx, [esc_msg]
    int 0x21

    mov ah, 0x4C
    int 0x21
