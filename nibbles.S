###
### Constants
###
.set	wormSize,	    1
.set    apple,		    42
.set 	x,	            25
.set	y,	            25
.set	wormChar,	    111
.set    loopDelay,      100000
.set    border,         43


.bss
#array:  .space 400
.data
array:  .space 410
counter: .long 0
last_position: .long 0
wormSize_counter: .long 0

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
        # xorl    %esi, %es0
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


#delete this, unecessary
setupWorm:
        #resets used registry
        xorl    %ebx, %ebx
        xorl    %ecx, %ecx
        xorl    %edx, %edx
        xorl    %eax, %eax
        jmp     setupBorders
/* add left, down, right borders in this one later!!!!! */
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


#rename this
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

        #temporarily try and add size+1 to the worm
        movl    $1, %edx
        movl    $25, (%ebx, %edx, 8)
        movl    $26, 4(%ebx, %edx, 8)
        xorl    %edx, %edx

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
        movl    %ecx, 404(%ebx)

        call    nib_poll_kbd
        cmpl    $260, %eax #checks if left arrow has been pushed down
        je      kbd_polling_left

        # cmpl    $261, %eax #checks if left arrow has been pushed down
        # je      kbd_polling_right

        # cmpl    $259, %eax #checks if left arrow has been pushed down
        # je      kbd_polling_up

        # cmpl    $258, %eax #checks if left arrow has been pushed down
        # je      kbd_polling_down

        call    restore_counter

        call    no_input

        # about 1 second delay for worm position update
        movl    %ecx, 404(%ebx)
        pushl   $loopDelay
        call    usleep

        #cleanup stack
        addl    $4, %esp

        #restores counter after c-call
        movl    404(%ebx), %ecx

        jmp     wLoop

kbd_polling_left:
        movl    $260, last_position

        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp

        #restores the counter value
        movl    404(%ebx), %ecx

        #decrements the counter value, as well as the X-coordinate
        decl    %ecx
        #X-coordinate
        decl    (%ebx)

        #saves counter before c-call
        movl    %ecx, 404(%ebx)


        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp


        #moves temporary value for counter back into %ecx registry
        movl    404(%ebx), %ecx

        #resets registry in preparation for worm body parts update
        call    reset_registry

        #loads variables into registry again for statement comparison
        leal    wormSize, %edx
        incl    408(%ebx)
        movl    408(%ebx), %ecx
        cmpl    408(%ebx), %edx
        #update worm body positions if it has any body parts
        call    update_body_parts_left

        #resets the wormSize counter for future updates can be executed correctly
        call    reset_wormSize_counter

        call    reset_registry
        #moves temporary value for counter back into %edx registry
        movl    404(%ebx), %ecx

        jmp wLoop


kbd_polling_right:
        movl    $261, last_position

        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp

        #restores the counter value
        movl    404(%ebx), %ecx

        #decrements the counter value, as well as the X-coordinate
        incl    %ecx
        #X-coordinate
        incl   (%ebx)

        #saves counter before c-call
        movl    %ecx, 404(%ebx)


        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp

        #moves temporary value for counter back into %edx registry
        movl    404(%ebx), %ecx

        jmp wLoop


kbd_polling_up:
        movl    $259, last_position

        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp

        #restores the counter value
        movl    404(%ebx), %ecx

        #decrements the counter value, as well as the X-coordinate
        decl    %ecx
        #X-coordinate
        decl   4(%ebx)

        #saves counter before c-call
        movl    %ecx, 404(%ebx)


        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp

        #moves temporary value for counter back into %edx registry
        movl    404(%ebx), %ecx

        jmp wLoop


kbd_polling_down:
        movl    $258, last_position

        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp

        #restores the counter value
        movl    404(%ebx), %ecx

        #decrements the counter value, as well as the X-coordinate
        incl    %ecx
        #X-coordinate
        incl   4(%ebx)

        #saves counter before c-call
        movl    %ecx, 404(%ebx)


        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp

        #moves temporary value for counter back into %edx registry
        movl    404(%ebx), %ecx

        jmp wLoop


no_input:
        #restore counter
        movl    404(%ebx), %ecx

        # about 1 second delay for worm position update
        #save counter
        movl    %ecx, 404(%ebx)
        pushl   $loopDelay
        call    usleep

        #cleanup stack
        addl    $4, %esp

        #restore counter
        movl    404(%ebx), %ecx

        cmpl    $260, last_position
        je      kbd_polling_left

        cmpl    $261, last_position
        je      kbd_polling_right

        cmpl    $259, last_position
        je      kbd_polling_up

        cmpl    $258, last_position #checks if left arrow has been pushed down
        je      kbd_polling_down

        movl    404(%ebx), %ecx
        # cmpl    $261, %eax
        # je      kbd_polling_right
        ret

save_counter:
        movl    $0, 404(%ebx)
        movl    %ecx, 404(%ebx)
        ret

restore_counter:
        movl    404(%ebx), %ecx
        ret
# update_worm_body_positions:

#         cmpl last_position, $260
#         je update_left

#         cmpl  last_position, $261
#         je  update_right

#         cmpl last_position, $259
#         je  update_up

#         cmpl last_position, $258
#         je update_down

#         ret

reset_registry:
        xorl    %ecx, %ecx
        xorl    %edx, %edx
        xorl    %eax, %eax
        ret

update_body_parts_left:

        #removes old coordinates for current piece of worm tail
        pushl   $32
        pushl   4(%ebx, %ecx, 8)
        pushl   (%ebx, %ecx, 8);
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp

        call    reset_registry
        #loads variables into registry again for statement comparison
        movl    408(%ebx), %ecx
        leal    wormSize, %edx


        #increments x-coordinate (moves left)
        incl    (%ebx, %ecx, 8)

        pushl   $wormChar
        pushl   4(%ebx, %ecx, 8)
        pushl   (%ebx, %ecx, 8)
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp


        #increases wormSize counter
        incl    408(%ebx)

        leal    wormSize, %edx
        movl    408(%ebx), %ecx
        #if worm still has body parts to update, then it will loop again
        #maybe reverse these statements?
        cmpl    408(%ebx), %edx
        ja      update_body_parts_left

        #else, return back to last code
        ret

#maybe unecessary
reset_wormSize_counter:
        movl    $0, 408(%ebx)
        ret

 finish_loop:
        jmp exit_program

 exit_program:       
#         /* Finishing calls */
       call nib_end
        call exit
