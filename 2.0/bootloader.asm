[org 0x7C00]         ; Bootloader 0x7C00 adresine yerleştirilir

; Diskten kernel.bin yükle
load_kernel:
    mov ah, 0x02     ; Disk okuma servisi (0x13 BIOS interrupt)
    mov al, 8        ; 8 sektör oku (4 KB kernel, her sektör 512 byte)
    mov ch, 0        ; Silindir numarası (0)
    mov cl, 2        ; Sektör (2. sektörden başla)
    mov dh, 0        ; Başlık (başlangıç başlığı)
    mov dl, [boot_drive] ; Disk numarasını oku (boot_drive değeri)
    mov bx, 0x1000   ; Bellekte kernel'i yükleyeceğimiz adres (0x1000)
    int 0x13         ; Disk okuma işlemi

    jc disk_error    ; Hata durumunda error_msg'e git

; Kernel'i çalıştır (Yüklenen kernel adresine atla)
    jmp 0x1000       ; Bellekte yüklü olan kernel'e atla

disk_error:
    mov si, error_msg
    call print_string
    jmp $

print_string:
    mov ah, 0x0E     ; BIOS teletype yazdırma servisi
.next_char:
    lodsb            ; SI'dan bir byte al
    or al, al        ; Eğer null byte ise bitir
    jz .done
    int 0x10         ; Yazdır
    jmp .next_char
.done:
    ret

boot_drive db 0x80   ; Varsayılan disk numarası (80h, ilk sabit disk)
error_msg db 'Disk hatasi! Kernel bulunamadi. ', 0

; Bootloader'ın sonunda 512 byte'lık alanı doldur
times 510-($-$$) db 0
dw 0xAA55            ; Boot sektörü sihiri
