.text
.align 4 
.global main
.extern tcsetattr
.extern printf

main:
        ldr r0, =serial_port                        // device path 
        ldr r1, =0x102                              // (O_RDWR | O_NOCTTY)
        mov r7, #5                                  // open syscall
        svc #0 

        mov r6, r0                                  // save fd 

        mov r0, r6 
        ldr r2, =options                            
        mov r1, #0 
        bl tcsetattr                                //apply configuration settings 

        mov r0, r6                                  //set fd
        ldr r1, =input                          
        mov r2, #64                                 //max bytes read
        mov r7, #3                                  //read syscall
        svc #0


            ldr r2, =freqs                          //holds base address 

_count :    ldrb r3, [r1], #1                       //postindex increment 
            cmp r3, #10                             //checks for EOF
            beq _find_max
            cmp r3, #32                             //check if space
            beq _count                              //skip
            ldrb r4, [r2, r3]
            add r4, r4, #1
            strb r4, [r2, r3] 
            b _count


_find_max:  mov r0, #0                               //init counter
            mov r1, #0                               //init offset
            mov r2, #0                               //init max value
            ldr r3, =freqs

_loop :      ldrb r4, [r3], #1                       //postindex
             cmp r2, r4 
             movlt r1, r0                             //new offset 
             movlt r2, r4                             //new max value

            add r0, r0, #1
            cmp r0, #255
            bne _loop 

            ldr r0, =output  
            strb r1, [r0]                            //save offset
            strb r2, [r0, #1]                        //save max value

            mov r0, r6                               // fd 
            ldr r1, =output
            ldr r2, =len_out                  
            mov r7, #4                               // write syscall
            svc #0

            mov r0, r6                               // fd
            mov r7, #6                               // close syscall
            svc #0

            mov r0, #0
            mov r7, #1                               // exit syscall
            svc #0


.data
    options: .word 0x00000000 /* c_iflag */
             .word 0x00000000 /* c_oflag */
             .word 0x000008BD /* c_cflag: CLOCAL | CS8 | CREAD */
             .word 0x00000002 /* c_lflag : ICANON */
             .byte 0x00       /* c_line */
             .word 0x00000000 /* c_cc[0-3] */
             .word 0x00010000 /* c_cc[4-7] */
             .word 0x00000000 /* c_cc[8-11] */
             .word 0x00000000 /* c_cc[12-15] */
             .word 0x00000000 /* c_cc[16-19] */
             .word 0x00000000 /* c_cc[20-23] */
             .word 0x00000000 /* c_cc[24-27] */
             .word 0x00000000 /* c_cc[28-31] */
             .byte 0x00       /* padding */
             .hword 0x0000    /* padding */
             .word 0x00001002 /* c_ispeed 115200*/
             .word 0x00001002 /* c_ospeed 115200*/

serial_port: .asciz "/dev/ttyAMA0"
input: .space 64
/*holds a counter for every ascii charachter*/
freqs: .ascii "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"                   
output:  .asciz "cc\n"
len_out = . - output
