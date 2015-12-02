###
### Constants
###
.set	wormSize,	    5
.set    apple,		    42
.set 	x,	            25
.set	y,	            25
.set	wormChar,	    111
.set    loopDelay,      1000000
.set    border,         43


.bss
#array:  .space 400
.data
array:  .space 410

print_format:   .asciz "Value of printout: %d \n"
.text

.globl start_game
.type start_game,@function
start_game:
/*Procedure for pushing to the stack, three parameters*/
/*Calls a function afterwards */
/*First parameter is the last one in the C-function call */
        call	nib_init
        call    setupWorm
       # call    resetArray
        # call    setupBorders
        # call    resetValues
        # call    exit_program
       # call    exit_program

        # call    finish_program
        # xorl    %ebx, %ebx
        # xorl    %esi, %esi
     #    xorl    %eax, %eax
     #    movl    $25, %edx
     # #   movl    $25, %eax
     #    pushl	$wormChar
     #    pushl	$edx
     #    pushl	$ebx
     #    call nib_put_scr
     #    addl    $12, %esp

/*PLACE ALL APPLES HERE*/








/*RUN WORM WITH CONDITIONS HERE IN LOOP*/

# resetArray: cmpl    $400, %ebx
#             je      ret
#             addl    $4, %ebx
#             movl    $0, %ebx(array)

setupWorm:
        #resets used registry
        xorl    %ebx, %ebx
        xorl    %ecx, %ecx
        xorl    %edx, %edx
        xorl    %eax, %eax
        jmp     setupBorders

setupBorders: cmpl      $50, %ebx
        je      resetValues
        pushl   %ecx # 0
        pushl   $border # 4
        pushl   %edx # 8
        pushl   %ecx # 12
        call    nib_put_scr

        popl    %ecx # pops 12
        popl    %edx # pops 8
        addl    $4, %esp #pops 4
        popl    %ecx #pops 0


        #increments counter
        incl    %ebx
        #increments x axis value
        incl    %ecx

        jmp     setupBorders

resetValues:
        xorl    %ebx, %ebx
        xorl    %edx, %edx
        xorl    %eax, %eax
        xorl    %ecx, %ecx

        #load array into a registry
        leal    array, %ebx

        # popl  %destination registry
        movl    $25, (%ebx)
        movl    $25, 4(%ebx)

        jmp print_worm_middle

print_worm_middle:
        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call    nib_put_scr

        #stack cleanup
        addl    $12, %esp

        #assigns counter to 25.
        movl    $25, %ecx

        jmp wLoop

        #checks if counter value is 0 or 50, then it will quit the loop 
        #(hitting the wall simulation)
wLoop:  cmpl    $0, %ecx
        je      finish_loop
        cmpl    $50, %ecx
        je      finish_loop

        #saves counter in registry ecx due to edx corruption during kbd call.
        # xorl    %ecx, %ecx
        # movl    %edx, %ecx
        movl    %ecx, 404(%ebx)
        call    nib_poll_kbd
        cmpl    $260, %eax #checks if left arrow has been pushed down
        je      kbd_polling_left
        call    no_input

        cmpl    $261, %eax #checks if left arrow has been pushed down
        je      kbd_polling_right
        call    no_input


       # # #  #sets loop delay to around 1 second
        # pushl   %ecx
        # pushl  $loopDelay
        # call    usleep

        # addl    $4, %esp
        # popl    %ecx

        

        jmp     wLoop


kbd_polling_left:
        #restores the counter value to edx
        # xorl    %edx, %edx
        # movl    %ecx, %edx
        movl    404(%ebx), %ecx
        #movl    $0, 8(%ebx)

        #decrements the counter value, as well as the X-coordinate
        decl    %ecx
        movl    %ecx, 8(%ebx)
        #X-coordinate
        decl    (%ebx)

        # pushl   %edx
        # pushl   %edx
        pushl	  $wormChar
        pushl	  4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
        # popl    %edx
        # popl    %edx

        # pushl   %edx
        # pushl   print_format
        # call    printf
        # addl    $8, %esp

        #moves temporary value for counter back into %edx registry
        movl    404(%ebx), %ecx

        jmp     wLoop


kbd_polling_right:
        #restores the counter value to edx
        # xorl    %edx, %edx
        # movl    %ecx, %edx
        movl    404(%ebx), %ecx
        #movl    $0, 8(%ebx)

        #decrements the counter value, as well as the X-coordinate
        incl   %ecx
        movl    %ecx, 404(%ebx)
        #X-coordinate
        incl    (%ebx)

        # pushl   %edx
        # pushl   %edx
        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
        # popl    %edx
        # popl    %edx

        # pushl   %edx
        # pushl   print_format
        # call    printf
        # addl    $8, %esp

        #moves temporary value for counter back into %edx registry
        movl    404(%ebx), %ecx

        jmp     wLoop


no_input:
        movl    404(%ebx), %ecx
        #jmp     wLoop
        ret

 finish_loop:
        jmp exit_program

 exit_program:       
#         /* Finishing calls */
       call nib_end
        call exit
