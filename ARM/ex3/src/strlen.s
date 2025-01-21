.text
.align 4
.global strlen
.type strlen, %function

strlen:
    mov r2, r0                  @ push base address
_cnt:
    ldrb r1, [r0], #1           @ string on r0
    cmp r1, #0                  @ checks if '\0'
    bne _cnt
_end:
    sub r0, r0, r2              @ len = (final offset - base offset)
    sub r0, r0, #1
    bx lr                       @return from func

.size strlen, .-strlen