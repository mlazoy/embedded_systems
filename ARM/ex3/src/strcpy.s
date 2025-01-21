.text
.align 4 
.global strcpy 
.type strcpy, %function

strcpy:
    mov r3, r0                  @ push base address of dest
_cpy:
    ldrb r2, [r1], #1           @ source on r1
    strb r2, [r0], #1           @ dest on r0
    cmp r2, #0                  @ checks if '\0'
    bne _cpy
_end:
    mov r0, r3                  @ restore dest's base address 
    bx lr

.size strcpy, .-strcpy