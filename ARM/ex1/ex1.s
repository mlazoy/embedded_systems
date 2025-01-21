.text 
.global main 
.extern printf

main : 
        ldr r0, =input_msg
        bl printf 

        ldr r0, =0                  //stdout fd 
        ldr r1, =buff_in            // input buffer
        ldr r2, =32                 // max number of bytes read
        mov r7, #3                  // syscall number for read
        svc #0                      // trigger the syscall

        cmp r0, #2                  //check number of bytes read
        mov r5, r0                  //save bytes read in r5
        bne _transform              // if > 2 call transform

        ldrb r2, [r1]               //load first charachter 
        cmp r2, #0x71               // 'q' is pressed
        beq _quit
        cmp r2, #0x51                // 'Q' is pressed
        beq _quit 

_transform :  
              ldr r6, =buff_out

_loop :       ldrb r2, [r1], #1          //postindex 
              cmp r2, #0x30              //checks if <='0'
              bllt _store_res
              cmp r2, #0x39              // checks if <= '9'  
              blgt _is_upper   
              addlt r2,r2, #5            // + 5
              cmp r2, #0x39              // modulo trick
              subgt r2, #10
              bl _store_res

_is_upper:   cmp r2, #0x5A              // checks if <= 'Z'
             blge _is_lower
             cmp r2, #0x41              // checks if >= 'A'
             addge r2, #32              // converts to lowercase
             bl _store_res

_is_lower:    cmp r2, #0x7A              //checks if <= 'z'
              blge _store_res
              cmp r2, #0x61              //check if >= 'a'
              subge r2, #32              //converts to uppercase

_store_res :  strb r2, [r6], #1
              subs r0, r0, #1           // decr bytes & update flags
              beq _output               // r0 = 0 
              bl _loop                  // continue
                            

_output  :   mov r2 , #0x0A         // append newline
             strb r2, [r6], #1
             mov r2, #0             //append null terminator
             strb r2, [r6]          
             ldr r0, =trans_msg      
             bl printf
             ldr r0, =buff_out
             bl printf

            mov r0, r5        //restore bytes number
            subs r0, r0, #32
            bne main           //loop back in main 

            ldr r1, =buff_in
            mov r2, #32        //define max number of bytes again 
            mov r7, #3     
_discard:   svc #0   
            subs r0, r0, #32         
            bleq _discard       //read again until end of input
            bne main

_quit : ldr r0, =exit_msg 
        bl printf
        mov r7, #1                  // syscall for exiting
        svc #0

.data 
input_msg: .asciz "Input a string up to 32-bytes long\n"
exit_msg: .asciz "Exiting...\n"
trans_msg: .asciz "Transformig input string...\n"
buff_in:  .space 32 
buff_out: .space 32
