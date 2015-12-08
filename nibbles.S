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


#sets original position 25,25 for worm head
reset_worm_body:
        movl    $25, (%ebx, %edx, 8)
        movl    $25, 4(%ebx, %edx, 8)

       incl    %edx
       # jumps to next body part to initialize it.
       cmpl    %eax, %edx
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

        #sets direction depending on keyboard input if there are any
        call    setting_direction

        #checks input depending on what last_direction is set to
        call    check_input

        call    restore_counter

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
        cmpl    $260, last_position
        je      move

        cmpl    $261, last_position
        je      move

        cmpl    $259, last_position
        je      move

        cmpl    $258, last_position
        je      move
        ret

setting_direction:
        cmpl    $260, %eax
        je      set_direction_left

        cmpl    $261, %eax
        je      set_direction_right

        cmpl    $259, %eax
        je      set_direction_up

        cmpl    $258, %eax
        je      set_direction_down
        ret

set_direction_down:
        movl    $258, last_position
        ret
set_direction_up:
        movl    $259, last_position
        ret
set_direction_left:
        movl    $260, last_position
        ret
set_direction_right:
        movl    $261, last_position
        ret


direction_move:
        cmpl    $260, last_position
        je      left

        cmpl    $261, last_position
        je      right

        cmpl    $259, last_position
        je      up

        cmpl    $258, last_position
        je      down

        ret

left:
        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)

        decl    (%ebx)
        decl     %ecx
        decl    404(%ebx)
        movl    404(%ebx), %ecx
        ret
right:
        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)

        incl    (%ebx)
        incl    %ecx
        incl    404(%ebx)
        movl    404(%ebx), %ecx
        ret
up:
        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)
        
        decl    4(%ebx)
        decl    %ecx
        decl    404(%ebx)
        movl    404(%ebx), %ecx
        ret    

down:
        #make sure last_position is saved somewhere safe and can be restored later in the move
        #function
        xorl    %edx, %edx
        movl    last_position, %edx
        movl    %edx, 422(%ebx)
        
        incl    4(%ebx)
        incl    %ecx
        incl    404(%ebx)
        movl    404(%ebx), %ecx
        ret


print_space_if_not_zero_coords:
#print if both is not zero
###################################################
        #removes old worm position
        pushl   $32#$35#$32

        pushl   4(%ebx, %eax, 8)
        pushl   (%ebx, %eax, 8)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################
        ret

check_zero_coordinate:
        movl    $0, hit
        cmpl    $0, (%ebx, %eax,8)
        je      add_zero_coord_hit   
        cmpl    $0, 4(%ebx,%eax,8)
        je      add_zero_coord_hit

        cmpl    $2, hit
        jne      print_space_if_not_zero_coords  
        #else return
        ret 

add_zero_coord_hit:
        incl hit
        ret


#worm update: print whole worm and its body parts, for each total movement update,
#remove last body part position with printing a space

#from left to up: update each tail part with both X, Y coordinates from former part 
#for each move THIS SHOULD WORK, I think I only update only X for left/right, and
#only Y for up/down

update_tail:
#NEW CODE
#check if currentpos contains data, if so, then send to currentpos+1 (loop)
#if it doesn't, then copy from currentpos-1 --> currentpos


        #currentPos-1
        decl    %eax
       # fetches value of currentPos-1 X-coord to %edx
        xorl    %edx, %edx
        movl    (%ebx, %eax, 8), %edx
        #fetches value of currentPos-1 Y-coord to %ecx
        xorl    %ecx, %ecx
        movl    4(%ebx, %eax, 8), %ecx

        #save eax before nib put scr
        movl    $0, 440(%ebx)
        movl    %eax, 440(%ebx)

        #call    check_zero_coordinate

###################################################
        #removes old worm position
        pushl   $32#$35#$32

        pushl   4(%ebx, %eax, 8)
        pushl   (%ebx, %eax, 8)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################

      
        # #restore eax here
        movl    440(%ebx), %eax


        #sets eax to currentPos again
        movl    counter, %eax

        #copies X, Y from currentPos-1 to currentPos
        movl    %edx, (%ebx, %eax, 8)
        movl    %ecx, 4(%ebx, %eax, 8)

# ################PRINT TO SCREEN##################
#         pushl   $wormChar
#         pushl    4(%ebx, %ecx, 8)
#         pushl   %edx
#         # pushl   430(%ebx)
#         # pushl   434(%ebx)
#         call    nib_put_scr

#         #cleanup stack
#         addl    $12, %esp
# ###################################################

        decl    counter

        #as long as counter != 0 then loop again, so the whole tail is updated.
        cmpl    $0, counter
        ja    update_tail
        #else return
        ret


print_tail:
       # xorl    %edx, %edx
       # fetches value of currentPos X-coord to edx
        #movl    (%ebx, %eax, 8), %edx

        #saves  tail counter
        movl    %eax, 440(%ebx)

        #call    check_zero_coordinate
# ################PRINT TO SCREEN##################
#         pushl   $wormChar
#         pushl   4(%ebx, %eax, 8)
#         pushl   (%ebx, %eax, 8)

#         call    nib_put_scr

#         #cleanup stack
#         addl    $12, %esp
# ###################################################

        #restore  tail counter
        movl    440(%ebx), %eax

        incl    %eax

        #fetches wormSize value to edx for registry comparison
        movl    $wormSize, %edx

        #if currentPos < wormSize
        #then loop again, else return
        cmpl    %edx, %eax
        jb      print_tail
        ret




move:
        #restores position of boundary counter
        xorl    %ecx, %ecx
        movl    404(%ebx), %ecx

        #saves return value into offset 418 for ebx so we know the certain arrow key pressed.
        movl    %eax,418(%ebx)

################removes old worm position########
        pushl   $32#$32
        pushl   4(%ebx)
        pushl   (%ebx)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################


        #restores boundary counter
        call    restore_counter

        #restores last_position
        xorl    %eax, %eax
        movl    418(%ebx), %eax

################update_tail#######################
        movl    $0, counter

        xorl    %eax, %eax
        #position 1 (first body part)
        incl    %eax
        #moves position 1 (first body part) to counter
        movl    %eax, counter

        #updates the tail coordinates for the worm
        call    update_tail
###################################################

############Moves in a set direction by the arrow keys########
        call    direction_move


#################PRINT NEW MOVE COORDINATES TO SCREEN################
        pushl   $wormChar
        pushl   4(%ebx)
        pushl   (%ebx)
        #pushl   $65
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
########################################################


#######################body collission detection##
        call body_hit_detection_init

        #restores the boundary counter value
        xorl    %ecx, %ecx
        xorl    %eax, %eax
        movl    404(%ebx), %ecx
###################################################


####################body part update preparation#########

        #set eax to start at position 1.
        xorl    %eax, %eax
        incl    %eax

###################################################

        #loads total wormSize
        xorl    %edx, %edx
        movl    $wormSize, %edx

        #if the the worm really has a body part at pos 1 then it will start update
       # cmpl    %eax, %edx

        #update worm body positions if it has any body parts
       # ja      print_tail


        #moves temporary value for boundary counter back into %ecx registry
        movl    404(%ebx), %ecx

        #makes sure last_position gets the value that has been set after a key press.
        xorl    %edx, %edx
        movl    422(%ebx), %edx
        movl    %edx, last_position

        #jumps back to main loop
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

        ret

##################body collission detection################################
body_hit_detection_init:
        #clear counter
        xorl    %edx, %edx
        #uses edx for storing the counter for iteration through the body parts 
        #for x, y coord checking.

        #uses offset 416 for storing the number of hits for each iteration through the worm body
        movl    $0, 416(%ebx)
  
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
