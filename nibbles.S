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
        movl    $25, 4(%ebx, %edx, 8)
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

        movl    404(%ebx), %ecx

        #removes old worm position
        pushl   $32
        pushl   $25
      #  pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp

        #restores the counter value
        movl    404(%ebx), %ecx

        #X-coordinate
        decl    (%ebx)

        #increase boundary counter
        decl    %ecx

        #saves counter before c-call
        movl    %ecx, 404(%ebx)

        xorl    %eax, %eax
        movl    4(%ebx), %eax

        ###################The y-coordinate gets corrupted, not sure why
        pushl   $wormChar
        pushl   $25
       # pushl   4(%ebx)
        pushl   (%ebx)
        #pushl   $65
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp


        #moves temporary value for counter back into %ecx registry
        movl    404(%ebx), %ecx

        #resets registry in preparation for worm body parts update
        call    reset_registry

        #loads variables into registry again for statement comparison
        #loads body size
        xorl    %edx, %edx
        movl    $wormSize, %edx
        #increments to body position 1
        movl    $0, 408(%ebx)
     
        #moves body pos 1 to ecx
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        incl    %ecx
        movl    %ecx, 408(%ebx)
        #if the the worm really has a body part at pos 1 then it will start update
        cmpl    %ecx, %edx
        #update worm body positions if it has any body parts
        jge      update_body_parts_left

        #moves temporary value for counter back into %ecx registry
        movl    404(%ebx), %ecx

        jmp wLoop


# kbd_polling_right:
#         movl    $261, last_position

#         #removes old worm position
#         pushl   $32
#         pushl   4(%ebx)
#         pushl   (%ebx)
#         call nib_put_scr

#         #Clean up stack
#         addl    $12, %esp

#         #restores the counter value
#         movl    404(%ebx), %ecx

#         #X-coordinate
#         incl    (%ebx)

#         #increase boundary counter
#         incl    %ecx

#         #saves counter before c-call
#         movl    %ecx, 404(%ebx)


#         pushl   $wormChar
#         pushl   4(%ebx)
#         pushl   (%ebx)
#         call nib_put_scr

#         #Clean up stack
#         addl    $12, %esp


#         #moves temporary value for counter back into %ecx registry
#         movl    404(%ebx), %ecx

#         #resets registry in preparation for worm body parts update
#         call    reset_registry

#         #loads variables into registry again for statement comparison
#         #loads body size
#         movl    $wormSize, %edx
#         #increments to body position 1

#         incl    408(%ebx)
#         #moves body pos 1 to ecx
#         movl    408(%ebx), %ecx
#         #if the the worm really has a body part at pos 1 then it will start update
#         cmpl    408(%ebx), %edx
#         #update worm body positions if it has any body parts
#         jge      update_body_parts_right

#         #moves temporary value for counter back into %ecx registry
#         movl    404(%ebx), %ecx

#         jmp wLoop


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

        # cmpl    $261, last_position
        # je      kbd_polling_right

        # cmpl    $259, last_position
        # je      kbd_polling_up

        # cmpl    $258, last_position #checks if left arrow has been pushed down
        # je      kbd_polling_down

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
    #    pushl   4(%ebx, %ecx, 8)
        pushl   $25
        pushl   (%ebx, %ecx, 8);
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp



        call    reset_registry
        #loads variables into registry again for statement comparison
        movl    408(%ebx), %ecx
        xorl    %edx, %edx
        leal    wormSize, %edx





        #clean eax
        xorl    %eax,%eax
        #fetches current pos
        movl    %ecx, %eax
        #subtracts 1 from current body part position
        decl    %eax


        /* currentPos-1 value + 1 */


        movl    $0, %edx
        #fetches element of currentPos-1
        movl    (%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        # (base case 25+1 for body part 1)
        incl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, (%ebx, %ecx, 8)







        pushl   $wormChar
                pushl   $25
       # pushl    4(%ebx, %ecx, 8)
       # pushl   $27
       # pushl   (%ebx, %ecx, 8)
        pushl   %edx
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp

        #increases wormSize counter
        movl    408(%ebx), %ecx
        incl    %ecx
        movl    %ecx, 408(%ebx)



        xorl    %edx, %edx
        movl    $wormSize, %edx
       # movl    408(%ebx), %ecx
        #if worm still has body parts to update, then it will loop again
        #maybe reverse these statements?
        cmpl    %ecx, %edx
        ja      update_body_parts_left

        #else, return back to last code
        je      finish_body_part_update







# update_body_parts_right:

#         #removes old coordinates for current piece of worm tail
#         pushl   $32
#         pushl   4(%ebx, %ecx, 8)
#         pushl   (%ebx, %ecx, 8);
#         call    nib_put_scr

#         #cleanup stack
#         addl    $12, %esp

#         call    reset_registry
#         #loads variables into registry again for statement comparison
#         movl    408(%ebx), %ecx
#         leal    wormSize, %edx


#         #updates position of worm body
#         xorl    %eax,%eax
#         #fetches current pos
#         movl    %ecx, %eax
#         #subtracts 1 from current body part position
#         subl    $1, %eax


#         /* currentPos-1 value - 1 */
#         #head = 25
#         #svans = 24 (25-1 = 24)
#         #svans2 = 23 (24-1 = 23)


#         movl    $0, %edx
#         #fetches element of currentPos-1
#         movl    (%ebx, %eax, 8), %edx

#         # head x-coord value - currentPos-1 element minus 1
#         # (base case 25-1 for body part 1)
#         decl    %edx
#         movl    %edx, (%ebx, %ecx, 8)

#      #   subl   $1, (%ebx, %ecx, 8)

#         pushl   $wormChar
#         pushl    4(%ebx, %ecx, 8)
#        # pushl   (%ebx, %ecx, 8)
#         pushl   %edx
#         call    nib_put_scr

#         #cleanup stack
#         addl    $12, %esp


#         #increases wormSize counter
#         incl    408(%ebx)

#         xorl    %edx, %edx
#         movl    $wormSize, %edx
#        # movl    408(%ebx), %ecx
#         #if worm still has body parts to update, then it will loop again
#         #maybe reverse these statements?
#         cmpl    408(%ebx), %edx
#         ja      update_body_parts_right

#         #else, return back to last code
#         je      finish_body_part_update





finish_body_part_update:
        #resets the wormSize counter for future updates can be executed correctly
        call    reset_wormSize_counter

        call    reset_registry
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx
        jmp     wLoop



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
