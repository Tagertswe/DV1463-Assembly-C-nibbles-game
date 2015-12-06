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

/*PLACE ALL APPLES HERE*/
#had no time to merge the apple deploy and collision detection code that my group mate had done







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

        # xorl    %eax, %eax
        # leal    last_position, %eax

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

      # movl    $261, last_position
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
        call    check_input

        call    restore_counter

        #currently automated direction input doesnt work, based on last key arrow press
        #call    no_input

        # about 1 second delay for worm position update
        #movl    %ecx, 404(%ebx)
        pushl   $loopDelay
        call    usleep

        #cleanup stack
        addl    $4, %esp

        #restores counter after c-call
        call    restore_counter

        jmp     wLoop

check_input:
        cmpl    $260, %eax
        je      move

        cmpl    $261, %eax
        je      move

        cmpl    $259, %eax
        je      move

        cmpl    $258, %eax
        je      move
        ret

no_input:   
        #move left
        cmpl    $260, last_position
        je      move_no_input

        #move right
        cmpl    $261, last_position
        je      move_no_input

        #move up
        cmpl    $259, last_position
        je      move_no_input

        #move down
        cmpl    $258, last_position
        je      move_no_input
        ret

pre_direction:
        #checks for possible arrow key input, if no input, then it will fall through and check
        #last_position for the last arrow key that was pushed down.
        cmpl    $260, %eax
        je      left

        cmpl    $261, %eax
        je      right

        cmpl    $259, %eax
        je      up

        cmpl    $258, %eax
        je      down
        ret

pre_direction_no_input:

        # about 1 second delay for worm position update
        # pushl   $loopDelay
        # call    usleep

        # #cleanup stack
        # addl    $4, %esp


        cmpl    $260, last_position
        je      left

        cmpl    $261, last_position
        je      right

        cmpl    $259, last_position
        je      up

        cmpl    $258, last_position
        je      down

        jmp     wLoop

left:
        movl    $260, last_position

        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)

        decl    (%ebx)
        decl     %ecx
        decl    404(%ebx)
        ret
right:
        movl    $261, last_position
        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)

        incl    (%ebx)
        incl    %ecx
        incl    404(%ebx)
        ret
up:
        movl    $259, last_position
        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)
        
        decl    4(%ebx)
        decl    %ecx
        decl    404(%ebx)
        ret    

down:
        movl    $258, last_position
        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)
        
        incl    4(%ebx)
        incl    %ecx
        incl    404(%ebx)
        ret


update_tail_init:
        #left
        cmpl    $260, last_position
        je      update_tail_left
        #right
        cmpl    $261, last_position
        je      update_tail_right

        #up
        cmpl    $259, last_position
        je      update_tail_up
        #down
        cmpl    $258, last_position
        je      update_tail_down

        
        pushl   $loopDelay
        call    usleep

        #cleanup stack
        addl    $4, %esp

        ret


update_tail_left:

        xorl    %edx, %edx
        #fetches value of currentPos-1 to edx
        movl    (%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        incl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, (%ebx, %ecx, 8)

################PRINT TO SCREEN##################
        pushl   $wormChar
        pushl    4(%ebx, %ecx, 8)
        pushl   %edx
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################
        ret

update_tail_right:
        xorl %eax, %eax
        movl    426(%ebx), %eax
        xorl    %edx, %edx
        #fetches value of currentPos-1 to edx
        movl    (%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        decl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, (%ebx, %ecx, 8)

################PRINT TO SCREEN##################
        pushl   $wormChar
        pushl    4(%ebx, %ecx, 8)
        pushl   %edx
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################
        # xorl    %ecx, %ecx
        # movl    404(%ebx), %ecx
        ret

        movl    $260, last_position
        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)

        ret

update_tail_up:
        xorl    %edx, %edx
        #fetches value of currentPos-1 to edx
        movl    4(%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        incl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, 4(%ebx, %ecx, 8)

################PRINT TO SCREEN##################
        pushl   $wormChar
        pushl   %edx
        pushl   (%ebx, %ecx, 8)
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################
        ret

update_tail_down:
        xorl    %edx, %edx
        #fetches value of currentPos-1 to edx
        movl    4(%ebx, %eax, 8), %edx

        # head x-coord value - currentPos-1 element plus 1
        decl    %edx
        #saves decremented coord back to the current tail position.
        movl    %edx, 4(%ebx, %ecx, 8)

################PRINT TO SCREEN##################
        pushl   $wormChar
        pushl   %edx
        pushl   (%ebx, %ecx, 8)
        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
###################################################
        ret


move:
        #set last known position to LEFT
       # movl    $260, last_position
        #restores position of boundary counter
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        #saves return value into offset 418 for ebx so we know the certain arrow key pressed.
        movl    %eax,418(%ebx)
###################################################
        #removes old worm position
        pushl   $32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################


        movl    418(%ebx), %eax
############CALL different functions depending on direction########
        call    pre_direction

###################################################


#################PRINT TO SCREEN################
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
        xorl    %eax, %eax
        movl    404(%ebx), %ecx

        #set last known position to LEFT
      #  movl    $260, last_position
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
        jge      update_body_parts




        #moves temporary value for boundary counter back into %ecx registry
        movl    404(%ebx), %ecx

        #makes sure last_position gets the value that has been set after a key press.
        xorl    %edx, %edx
        movl    422(%ebx), %edx
        movl    %edx, last_position

        #jumps back to main loop
        jmp wLoop




move_no_input:
        #set last known position to LEFT
       # movl    $260, last_position
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



############CALL different functions depending on direction########
        call    pre_direction_no_input

###################################################


#################PRINT TO SCREEN################
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
        xorl    %eax, %eax
        movl    404(%ebx), %ecx

        #set last known position to LEFT
      #  movl    $260, last_position
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

        xorl    %eax, %eax
        movl    $0, %eax
###################################################

        #if the the worm really has a body part at pos 1 then it will start update
        cmpl    %ecx, %edx

        #update worm body positions if it has any body parts
        jge     update_body_parts




        #moves temporary value for boundary counter back into %ecx registry
        movl    404(%ebx), %ecx

        #jumps back to main loop
       # jmp wLoop
        jmp     check_input



update_body_parts:
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
        #temporarily saves eax
        movl    %eax, 426(%ebx)
###################################################
        # currentPos-1 value + 1 


        # xorl    %edx, %edx
        # #fetches value of currentPos-1 to edx
        # movl    (%ebx, %eax, 8), %edx

        # # head x-coord value - currentPos-1 element plus 1
        # incl    %edx

        #updates each body part with the formula currentPos-1 element +/- 1 
        #depending on going left/right or up/down
        call    update_tail_init


        #saves decremented coord back to the current tail position.
       # movl    %edx, (%ebx, %ecx, 8)
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
        ja      update_body_parts

        #else, return back to last code
        jle      finish_body_part_update






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

##################body collission detection################################
body_hit_detection_init:
        #clear counter
        xorl    %edx, %edx
        #uses edx for storing the counter for iteration through the body parts 
        #for x, y coord checking.

        #uses offset 416 for storing the number of hits for each iteration through the worm body
        movl    $0, 416(%ebx)

        #loads wormSize into offset 412 of ebx
        # movl    $0, 412(%ebx)
        # leal    wormSize, 412(%ebx)
    
        #copy head X
        xorl    %eax, %eax
        movl   (%ebx, %edx,8), %eax
        #copy head Y 
        xorl    %ecx, %ecx
        movl   4(%ebx, %edx, 8), %ecx

        #sets body counter to 1, for first body part comparison
        movl    $1, %edx


        jmp collision_detect

#compares X coordinate
collision_detect:
        #set hit to 0
        movl    $0, 416(%ebx)

        #if X coordinates are on the same spot, go to add_hit and increment hit number
        cmpl    %eax, (%ebx, %edx, 8)
        je      add_hit
#compares Y coordinate  
collision_detect2:
        #if Y cooridnates are on the same spot, go to add_hit2 and increment hit number
        cmpl    %ecx, 4(%ebx, %edx,8)
        je      add_hit2
#go back here and continue loop if hit != 2.
continue:
        #increments counter
        incl    %edx

        #if there's still body parts left to compare, if it is, then loop again
        #wormSize = 412(%ebx), counter = %edx
        cmpl    $wormSize, %edx
        ja      collision_detect

        #by some wierd reason, the last_position variable gets reset inside the body_collision
        #function call, so I have to replace it just before jumping out
        xorl    %edx, %edx
        movl    422(%ebx), %edx
        movl    %edx, last_position
        #else jump back to function body_hit_detection_init was called from
        ret


add_hit:

        #increments hit
        incl    416(%ebx)

        jmp     collision_detect2

add_hit2:

        #increments hit
        incl    416(%ebx)

        #compares if there are two hits
        cmpl    $2, 416(%ebx)
        #if so, then finish program
        je      body_collide
        #else, continue with checking
        jmp     continue

reset_hits:
        movl    $0, 416(%ebx)
        ret
##################################################

#finish body collission detection of both x and y coordinates are the same with head as
#one of the body parts it collides with.
body_collide:
        jmp     exit_program

reset_counter:
        movl    $0, 412(%ebx)
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
