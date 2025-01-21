.text
.align 4
.global strcmp
.type strcmp, %function

strcmp:
    mov r4, #0x0                @ initialize ret value
_match:
    ldrb r2, [r0], #1           @ load s1 character from r0
    ldrb r3, [r1], #1           @ load s2 character from r1
    cmp r2, r3
    bne _mismatch    
    cmp r2, #0                  @ checks if '\0'
    beq _end	                @ if s1 == s2 return 0
    b _match
     
_mismatch:
    movlt r4, #0xffffffff       @ if r2 < r3 return -1
    movgt r4, #0x1              @ if r2 > r3 return 1

_end: mov r0, r4                @ pass result
      bx lr

.size strcmp, .-strcmp