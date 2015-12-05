###
### Constants
###
.set	wormSize,	    3
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
Y:  .long 0
X:  .long 0
hit:    .long 0

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

        xorl    %eax, %eax
        leal    wormSize, %eax
        jmp     reset_worm_body


reset_worm_body:
        movl    $25, (%ebx, %edx, 8)
        movl    $25, 4(%ebx, %edx, 8)

        incl    %edx
        #jumps to next body part to initialize it.
        cmpl    %edx, %eax
        ja      reset_worm_body

        #else if whole body has been initiated
        jmp print_worm_middle

print_worm_middle:
        xorl    %edx, %edx

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

       # call    no_input

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
        #checks last known positis
        movl    $260, last_position
        #restores position of boundary counter
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx
###################################################
        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################



###################################################
        #restores the boundary counter value
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        #decrement X-coordinate
        decl    (%ebx)

        #decrement boundary counter
        decl    %ecx

        #saves counter before c-call
        movl    %ecx, 404(%ebx)
###################################################


#################PRINT TO SCREEN################
        ###################The y-coordinate gets corrupted, not sure why
        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        #pushl   $65
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################

#######################body collission detection##
        call body_hit_detection_init

        #restores the boundary counter value
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx
###################################################

####################body part update preparation#########

        #resets registry in preparation for worm body parts update
        call    reset_registry

        #loads total wormSize
        xorl    %edx, %edx
        movl    $wormSize, %edx

        #resets worm posCounter register
        movl    $0, 408(%ebx)
     
        #copies 0 to ecx
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        #increments ecx with +1
        incl    %ecx
        #copies ecx back to ebx register with 408 offset
        movl    %ecx, 408(%ebx)
###################################################

        #if the the worm really has a body part at pos 1 then it will start update
        cmpl    %ecx, %edx

        #update worm body positions if it has any body parts
        jge      update_body_parts_left

        #moves temporary value for boundary counter back into %ecx registry
        movl    404(%ebx), %ecx

        #jumps back to main loop
        jmp wLoop

update_body_parts_left:
        #copies wormCounter back to registry
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx

#removes old coordinates for current piece of worm tail
###################################################
        pushl   $32
        pushl   4(%ebx, %ecx, 8)
        pushl   (%ebx, %ecx, 8)
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################


        #loads variables into registry again for statement comparison
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        xorl    %edx, %edx
        leal    wormSize, %edx


        #clean eax
        xorl    %eax,%eax
        #fetches current pos
        movl    %ecx, %eax
        #subtracts 1 from current body part position
        decl    %eax

###################################################
        # currentPos-1 value + 1 


        xorl    %edx, %edx
        #fetches value of currentPos-1 to edx
        movl    (%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        incl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, (%ebx, %ecx, 8)
###################################################





################PRINT TO SCREEN##################
        pushl   $wormChar
        pushl    4(%ebx, %ecx, 8)
        pushl   %edx
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################



###################################################
        #increases wormSize counter and loop body parts preparation
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        incl    %ecx
        movl    %ecx, 408(%ebx)

        xorl    %edx, %edx
        movl    $wormSize, %edx
###################################################


        #if worm still has body parts to update, then it will loop again

        #maybe reverse these statements?
        cmpl    %ecx, %edx
        ja      update_body_parts_left

        #else, return back to last code
        jle      finish_body_part_update





kbd_polling_right:
        #checks last known positis
        movl    $261, last_position
        #restores position of boundary counter
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx
###################################################
        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################



###################################################
        #restores the boundary counter value
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        #increment X-coordinate
        incl    (%ebx)

        #increment boundary counter
        incl    %ecx

        #saves counter before c-call
        movl    %ecx, 404(%ebx)
###################################################


#################PRINT TO SCREEN################
        ###################The y-coordinate gets corrupted, not sure why
        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################

####################body part update preparation#########

        #resets registry in preparation for worm body parts update
        call    reset_registry

        #loads total wormSize
        xorl    %edx, %edx
        movl    $wormSize, %edx

        #resets worm posCounter register
        movl    $0, 408(%ebx)
     
        #copies 0 to ecx
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        #increments ecx with +1
        incl    %ecx
        #copies ecx back to ebx register with 408 offset
        movl    %ecx, 408(%ebx)
###################################################

        #if the the worm really has a body part at pos 1 then it will start update
        cmpl    %ecx, %edx

        #update worm body positions if it has any body parts
        jge      update_body_parts_right

        #moves temporary value for boundary counter back into %ecx registry
        movl    404(%ebx), %ecx

        #jumps back to main loop
        jmp wLoop





update_body_parts_right:
        #copies wormCounter back to registry
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx

#removes old coordinates for current piece of worm tail
###################################################
        pushl   $32
        pushl   4(%ebx, %ecx, 8)
        pushl   (%ebx, %ecx, 8)
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################


        #loads variables into registry again for statement comparison
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        xorl    %edx, %edx
        leal    wormSize, %edx


        #clean eax
        xorl    %eax,%eax
        #fetches current pos
        movl    %ecx, %eax
        #subtracts 1 from current body part position
        decl    %eax

###################################################
        # currentPos-1 value + 1 


        xorl    %edx, %edx
        #fetches value of currentPos-1 to edx
        movl    (%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        decl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, (%ebx, %ecx, 8)
###################################################





################PRINT TO SCREEN##################
        pushl   $wormChar
        pushl    4(%ebx, %ecx, 8)
        pushl   %edx
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################



###################################################
        #increases wormSize counter and loop body parts preparation
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        incl    %ecx
        movl    %ecx, 408(%ebx)

        xorl    %edx, %edx
        movl    $wormSize, %edx
###################################################


        #if worm still has body parts to update, then it will loop again
        #maybe reverse these statements?
        cmpl    %ecx, %edx
        ja      update_body_parts_right

        #else, return back to last code
        jle      finish_body_part_update


kbd_polling_up:

        #checks last known positis
        movl    $259, last_position
        #restores position of boundary counter
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx
###################################################
        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################



###################################################
        #restores the boundary counter value
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        #decrement Y-coordinate
        decl    4(%ebx)

        #decrement boundary counter
        decl    %ecx

        #saves counter before c-call
        movl    %ecx, 404(%ebx)
###################################################


#################PRINT TO SCREEN################
        ###################The y-coordinate gets corrupted, not sure why
        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################

####################body part update preparation#########

        #resets registry in preparation for worm body parts update
        call    reset_registry

        #loads total wormSize
        xorl    %edx, %edx
        movl    $wormSize, %edx

        #resets worm posCounter register
        movl    $0, 408(%ebx)
     
        #copies 0 to ecx
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        #increments ecx with +1
        incl    %ecx
        #copies ecx back to ebx register with 408 offset
        movl    %ecx, 408(%ebx)
###################################################

        #if the the worm really has a body part at pos 1 then it will start update
        cmpl    %ecx, %edx

        #update worm body positions if it has any body parts
        jge      update_body_parts_up

        #moves temporary value for boundary counter back into %ecx registry
        movl    404(%ebx), %ecx

        #jumps back to main loop
        jmp wLoop


update_body_parts_up:
       #copies wormCounter back to registry
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx

#removes old coordinates for current piece of worm tail
###################################################
        pushl   $32
        pushl   4(%ebx, %ecx, 8)
        pushl   (%ebx, %ecx, 8)
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################


        #loads variables into registry again for statement comparison
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        xorl    %edx, %edx
        leal    wormSize, %edx


        #clean eax
        xorl    %eax,%eax
        #fetches current pos
        movl    %ecx, %eax
        #subtracts 1 from current body part position
        decl    %eax

###################################################
        # currentPos-1 value + 1 


        xorl    %edx, %edx
        #fetches value of currentPos-1 to edx
        movl    4(%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        incl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, 4(%ebx, %ecx, 8)
###################################################





################PRINT TO SCREEN##################
        pushl   $wormChar
        pushl   %edx
        pushl   (%ebx, %ecx, 8)

        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################



###################################################
        #increases wormSize counter and loop body parts preparation
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        incl    %ecx
        movl    %ecx, 408(%ebx)

        xorl    %edx, %edx
        movl    $wormSize, %edx
###################################################


        #if worm still has body parts to update, then it will loop again
        #maybe reverse these statements?
        cmpl    %ecx, %edx
        ja      update_body_parts_up

        #else, return back to last code
        jle      finish_body_part_update


kbd_polling_down:


        #checks last known positis
        movl    $258, last_position
        #restores position of boundary counter
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx
###################################################
        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################



###################################################
        #restores the boundary counter value
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        #decrement Y-coordinate
        incl    4(%ebx)

        #decrement boundary counter
        incl    %ecx

        #saves counter before c-call
        movl    %ecx, 404(%ebx)
###################################################


#################PRINT TO SCREEN################
        ###################The y-coordinate gets corrupted, not sure why
        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################

####################body part update preparation#########

        #resets registry in preparation for worm body parts update
        call    reset_registry

        #loads total wormSize
        xorl    %edx, %edx
        movl    $wormSize, %edx

        #resets worm posCounter register
        movl    $0, 408(%ebx)
     
        #copies 0 to ecx
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        #increments ecx with +1
        incl    %ecx
        #copies ecx back to ebx register with 408 offset
        movl    %ecx, 408(%ebx)
###################################################

        #if the the worm really has a body part at pos 1 then it will start update
        cmpl    %ecx, %edx

        #update worm body positions if it has any body parts
        jge      update_body_parts_down

        #moves temporary value for boundary counter back into %ecx registry
        movl    404(%ebx), %ecx

        #jumps back to main loop
        jmp wLoop


update_body_parts_down:

       #copies wormCounter back to registry
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx

#removes old coordinates for current piece of worm tail
###################################################
        pushl   $32
        pushl   4(%ebx, %ecx, 8)
        pushl   (%ebx, %ecx, 8)
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################


        #loads variables into registry again for statement comparison
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        xorl    %edx, %edx
        leal    wormSize, %edx


        #clean eax
        xorl    %eax,%eax
        #fetches current pos
        movl    %ecx, %eax
        #subtracts 1 from current body part position
        decl    %eax

###################################################
        # currentPos-1 value + 1 


        xorl    %edx, %edx
        #fetches value of currentPos-1 to edx
        movl    4(%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        decl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, 4(%ebx, %ecx, 8)
###################################################





################PRINT TO SCREEN##################
        pushl   $wormChar
        pushl   %edx
        pushl   (%ebx, %ecx, 8)

        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################



###################################################
        #increases wormSize counter and loop body parts preparation
        xorl    %ecx, %ecx
        movl    408(%ebx), %ecx
        incl    %ecx
        movl    %ecx, 408(%ebx)

        xorl    %edx, %edx
        movl    $wormSize, %edx
###################################################


        #if worm still has body parts to update, then it will loop again
        #maybe reverse these statements?
        cmpl    %ecx, %edx
        ja      update_body_parts_down

        #else, return back to last code
        jle      finish_body_part_update





no_input:
        #restore counter
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        # about 1 second delay for worm position update
        pushl   $loopDelay
        call    usleep

        #cleanup stack
        addl    $4, %esp

        #restore counter
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        cmpl    $260, last_position
        je      kbd_polling_left

        cmpl    $261, last_position
        je      kbd_polling_right

        cmpl    $259, last_position
        je      kbd_polling_up

        cmpl    $258, last_position #checks if left arrow has been pushed down
        je      kbd_polling_down


        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx
        ret

save_counter:
        movl    $0, 404(%ebx)
        movl    %ecx, 404(%ebx)
        ret

restore_counter:
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx
        ret

reset_registry:
        xorl    %ecx, %ecx
        xorl    %edx, %edx
        xorl    %eax, %eax
        ret





finish_body_part_update:
        #resets the wormSize counter for future updates can be executed correctly
        call    reset_wormSize_counter

        #copies back the boundary counter to ecx
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        jmp     wLoop


body_hit_detection_init:
        #current body x
        xorl    %eax, %eax
        #current body y
        xorl    %esi, %esi
        #counter
        xorl    %edx, %edx
        #head x
        pushl   $X
        #head y
        pushl   $Y



        #loads counter into %edi for easier offset access in the upcoming loop
        leal    counter, %edx


    
        #copy X
        #mjau
        movl    (%ebx, %edx,8), %esp
        #copy Y
        movl    4(%ebx, %edx, 8), 4(%esp)

        #copy counter to registry
        leal    counter, %edx

        jmp collision_detect


#work in progress, compare head x, y against current body part x, y, add +1 to esi,
#if esi == 2, then quit program as then head is considered to
# have collided with its own body
##################body collission detection################################
collision_detect:
        movl    $0, hit
        pushl   $hit
        cmpl    %ecx, (%ebx, %edx, 8)
        je      add_hit  
collision_detect2:
        cmpl    %esi, 4(%ebx, %edx,8)
        je      add_hit2

continue:
        incl    counter
        popl    hit
        #if there's still body parts left to compare, the loop again
        cmpl    %edx, wormSize
        ja      collision_detect

        #else jump back to
        ret




add_hit:
        #pops hit from stack
        popl    hit
        #increments hit
        incl    hit
        #pushes update of hit to stack
        pushl   hit

        jmp     collision_detect2

add_hit2:
        incl    hit
        #compares if there are two hits
        cmpl    $2, 4(%esp)
        #if so, then finish program
        je      finish_loop
        #else, continue with checking
        jmp     continue

reset_hits:
        movl    $0, hit
        ret
##################################################


reset_counter:
        movl    $0, counter
        ret


#maybe unecessary
reset_wormSize_counter:
        movl    $0, 408(%ebx)
        ret

 finish_loop:
        popl    hit
        jmp exit_program

 exit_program:       
#         /* Finishing calls */
       call nib_end
        call exit
