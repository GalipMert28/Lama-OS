section .data
    prompt db "Enter command: ", 0        ; Null byte added
    math_cmd db "math", 0                 ; Null byte added 
    exit_cmd db "exit", 0                 ; Null byte added
    info_cmd db "info", 0                 ; Null byte added
    newline db 0xA, 0                     ; Newline character
    error_msg db "Invalid command", 0     ; Null byte added
    math_bin db "math.bin", 0             ; Null byte added
    cpu_info db "CPU info: null", 0       ; CPU info string

section .bss
    input resb 100

section .text
    global _start

_start:
    ; Endless loop
.loop:
    ; Print the command prompt
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, prompt     ; message
    mov edx, 15         ; message length
    int 0x80            ; syscall

    ; Get user input
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, input      ; input buffer
    mov edx, 100        ; max characters
    int 0x80            ; syscall

    ; Check the command
    mov esi, input      ; get input start
    call trim_input     ; trim leading/trailing spaces

    ; Check for "math" command
    mov edi, math_cmd
    call compare_strings
    test eax, eax
    jne .run_math

    ; Check for "exit" command
    mov edi, exit_cmd
    call compare_strings
    test eax, eax
    jne .exit

    ; Check for "info" command
    mov edi, info_cmd
    call compare_strings
    test eax, eax
    jne .info

    ; Invalid command
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, 17
    int 0x80
    jmp .loop

.run_math:
    ; Execute math.bin using execve
    mov eax, 11         ; sys_execve
    lea ebx, [math_bin] ; path to math.bin
    xor ecx, ecx        ; no arguments
    xor edx, edx        ; no environment
    int 0x80            ; syscall
    jmp .loop

.exit:
    ; Shut down the computer (exit syscall)
    mov eax, 1          ; sys_exit
    xor ebx, ebx        ; exit status 0
    int 0x80            ; syscall

.info:
    ; PC information (simple example: CPU info)
    mov eax, 4
    mov ebx, 1
    lea ecx, [cpu_info]  ; address of cpu_info string
    mov edx, 21         ; message length (including null byte)
    int 0x80
    jmp .loop

; String comparison function
compare_strings:
    push edi
    push esi
    cld

.compare_loop:
    lodsb
    scasb
    jne .strings_not_equal
    cmp al, 0
    je .strings_equal_end

    jmp .compare_loop

.strings_not_equal:
    xor eax, eax
    pop esi
    pop edi
    ret

.strings_equal_end:
    mov eax, 1
    pop esi
    pop edi
    ret

; Trim input (remove leading and trailing spaces)
trim_input:
    cld
    mov edi, esi       ; edi = input start

.trim_start:
    lodsb              ; al = *esi, esi = esi + 1
    cmp al, ' '        ; is it a space?
    je .trim_start     ; if yes, go back to start

    dec esi            ; keep the character before the first space

.trim_end:
    lodsb              ; al = *esi, esi = esi + 1
    cmp al, 0          ; reached the end?
    je .trim_done      ; yes, we're done

    cmp al, ' '        ; is it a space?
    je .trim_end       ; if yes, skip it

    stosb              ; write al to [edi]
    jmp .trim_end      ; continue

.trim_done:
    stosb              ; add null byte at the end
    ret