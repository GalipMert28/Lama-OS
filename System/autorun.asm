section .text
    global _start

_start:
    ; Ekranı temizle
    call clear_screen

    ; Mesajı yazdır
    mov dx, msg
    call print_string

    ; Kullanıcıdan bir tuşa basmasını bekle
    call wait_for_key

    ; kernel.bin dosyasını çalıştır
    mov ax, 0x4B00      ; Programı yükle
    lea dx, [kernel_file]  ; Dosya ismini yükle
    int 0x21

    ; Çıkış
    mov ax, 0x4C00
    int 0x21

; Mesajı yazdırma
print_string:
    mov ah, 0x09
    int 0x21
    ret

; Bir tuşa basmayı bekleme
wait_for_key:
    xor ah, ah
    int 0x16         ; Klavye ile girdi oku
    ret

; Ekranı temizleme
clear_screen:
    mov ah, 0x00
    int 0x10
    ret

section .data
msg db 'PROGRAM TAMAMLANDI! DEVAM ETMEK İÇİN HERHANGİ BİR TUŞA BASIN!$'
kernel_file db 'kernel.bin', 0
