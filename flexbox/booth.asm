.model small
.stack 100h
.data
    multiplicand db -5     ; Example multiplicand (M)
    multiplier   db  3     ; Example multiplier (Q)
    result       dw  0     ; Final result will be stored here
.code
main:
    mov ax, @data
    mov ds, ax

    ; Load values
    mov al, multiplicand   ; Load M
    cbw                   ; Sign-extend AL to AX (AX = M)
    mov bx, ax            ; BX = M

    mov al, multiplier     ; Load Q
    cbw
    mov dx, ax            ; DX = Q

    xor ax, ax            ; Clear A (AX = 0)
    xor dl, dl            ; DL = Q-1 = 0

    mov cx, 8              ; 8 bits = 8 iterations

booth_loop:
    ; Check Q0 and Q-1
    mov si, dx             ; Copy Q (DX) to SI
    and si, 1              ; SI = Q0
    shl dl, 1              ; DL = Q-1 shifted to leftmost bit
    or  dl, si             ; DL now has [Q0 << 1 | Q-1] = 2 bits

    cmp dl, 1              ; Check if Q0 Q-1 = 01
    je add_multiplicand
    cmp dl, 2              ; Check if Q0 Q-1 = 10
    je sub_multiplicand
    jmp shift_right

add_multiplicand:
    add ax, bx             ; A = A + M
    jmp shift_right

sub_multiplicand:
    sub ax, bx             ; A = A - M
    jmp shift_right

shift_right:
    ; Combine A:Q into AX:DX and perform arithmetic shift right
    ; Save LSB of AX for Q-1
    shl dx, 1              ; Make room for new bit from AX
    rcr ax, 1              ; Arithmetic right shift AX (A)
    rcr dx, 1              ; Logical right shift DX (Q)
    rcr dl, 1              ; Save LSB of DX into DL (Q-1)
    
    loop booth_loop

    ; Final result is in AX:DX (A:Q), combine into SI
    ; For 16-bit result, DX contains lower bits (Q), AX upper (A)
    ; So shift AX left by 8 and combine
    mov si, dx             ; SI = lower 8 bits
    mov di, ax             ; DI = upper 8 bits
    shl di, 8
    or  si, di             ; Combine into SI

    ; Store result
    mov result, si

    ; End program
    mov ah, 4ch
    int 21h
end main
