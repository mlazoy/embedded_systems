.text
.align 4
.global strcat
.type strcat, %function


strcat:
    mov r4, r0              @ push dest's base address
_consume:
    ldrb r2, [r0], #1       @ dest on r0
    cmp r2, #0              @ checks for '\0' in dest
    bne _consume            @ consume bytes
    sub r0, #1              @ overwrite '\0'
_concat:
    ldrb r3, [r1], #1       @ src on r1
    strb r3, [r0], #1       @ append 
    cmp r3, #0              @ checks for '\0' in src 
    bne _concat
_end:
    mov r0, r4              @ restore dest's base address
    bx lr

.size strcat, .-strcat
