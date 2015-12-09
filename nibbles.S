###
### Constants
###
.set    apple,		    	42
.set 	x,	            	25
.set	y,	            	25
.set	wormChar,	    	111
.set    loopDelay,      	190000
.set	char,			35
.set    border,         	43


.bss
.data

array:  		.space 410
counter: 		.long 0
last_position: 		.long 0
wormSize_counter: 	.long 0
Y:  			.long 0
X:  			.long 0
hit:    		.long 0


wormSize:		.long 0
print_format:   	.asciz "Value of printout: %d \n"

message: 		.asciz "x-cord %d y-cord %d\n"
cmpMessage1: 		.asciz "Worm head cordinate x,y (%d,%d)\n"
cmpMessage2: 		.asciz "Apple cordinate x,y (%d,%d)\n"
counterValue:		.asciz "Counter value is: %d\n"
parMessage:		.asciz	"Snakelength: %d and nrOfApples: %d\n"

nrOfApples: 		.long	0	# One iteration creates x-cord second y-cord, means 20 iterations = 10 apples.
index:			.long	0
appleCord:		.space 	4000	# (x,y) cordinates where the apples has been placed on screen
tempSpace:		.space 	8	# will be putting one random cordinates in this space
borderSize:		.long	50

.text

.globl start_game
.type start_game,@function


start_game:

	popl	%ebx 	# crap pop
	popl	%ecx	#  snake length
	popl	%edx	#  nr of apples

	imull $2,%edx	# multiply with 2
	movl	%edx,nrOfApples
	movl	%ecx,wormSize

	#pushl	nrOfApples
	#pushl	wormSize
	#pushl	$parMessage
	#call	printf
	#addl	$12,%esp

        call	nib_init
   	
################################################## load random values ##########################################################
getRandVal:

	call 	rand			## The random value is in register eax brought from the rand call.

	############# Modulo ##################
	xorl 	%edx,%edx		## zero out register
	movl	$50,%ecx		## modulo with value 50
	divl	%ecx			## result = eax  , rest = edx  (eax/värde)
	###################################### 
	
	
	################# Put (x,y) cordinates to Array #######################
	#popl	%edx			## remainder value do pop only if print is before
	xorl	%ebx,%ebx
	leal	appleCord,%ebx		# Load array address to register	
	xorl	%ecx,%ecx		# Zero out reg %ecx
	movl	index,%ecx		# move index to ecx
	movl	%edx,(%ebx,%ecx,4)	# on Every 4 bytes on each index on value: i1 Ycord = 4, i2 Xcord = 8 
	incl	index
	########################################################################

	xorl	%ecx,%ecx
	movl 	nrOfApples,%ecx		## move nr Of apples to be printed to screen
	incl	counter			## increase counter value with 1
	cmpl	counter,%ecx		## comparison is based on  nrOfApples - counter
	jne 	getRandVal		## jne = jump if not equal


#################################################################################################################


############################### Print apples to screen  ##################################################

	movl	$0,counter	# set counter to zero
	xorl 	%ebx,%ebx
	xorl	%edx,%edx
	xorl	%ecx,%ecx

	movl 	nrOfApples,%eax		## move nr Of apples to be printed to screen
	############# Modulo #################
	movl	$2,%ecx			## modulo with value 2
	divl	%ecx			## result = eax  , rest = edx  (eax/värde)
	###################################### 

	leal	appleCord,%ebx
	movl 	%eax,%ecx		## move nr Of apples to be printed to screen
	xorl	%eax,%eax

getApples:
	pushl	%ecx
	xorl	%edx,%edx
	xorl	%ecx,%ecx	
	incl	counter

	#pushl	(%ebx)
	#addl	$4,%ebx
	#pushl	(%ebx)
	#addl	$4,%ebx
	#pushl	$message
	#call	printf
	#addl	$12,%esp

	########## print to screen ###############
	pushl	$char
	pushl	(%ebx)
	addl	$4,%ebx
	pushl	(%ebx)
	addl	$4,%ebx
	call nib_put_scr
	addl    $12, %esp
	
	popl	%ecx
	cmpl	%ecx,counter			## loop 10 times, = nr of apples to be put on the screen	
	jne 	getApples			## jne = jump if not equal

##########################################################################################################

############################### Set borders ##############################################

	movl	$0,counter
floor:
	########## print to screen ###############
	pushl	$45				# char (-)
      	pushl	borderSize			# y cord
      	pushl	counter				# x cord
	call nib_put_scr
	addl    $12, %esp
	incl	counter				# increment

	cmpl	$50,counter			## 
	jne 	floor				## jne = jump if not equal	

	movl	$0,counter
rWall:
	########## print to screen ###############
	pushl	$124				# char (|)
      	pushl	counter				# y cord
      	pushl	borderSize			# x cord
	call nib_put_scr
	addl    $12, %esp
	incl	counter				# increment

	cmpl	$50,counter			## 
	jne 	rWall				## jne = jump if not equal
	

	movl	$0,counter
lWall:
	########## print to screen ###############
	pushl	$124				# char (|)
      	pushl	counter				# y cord
      	pushl	$0				# x cord
	call nib_put_scr
	addl    $12, %esp
	incl	counter				# increment

	cmpl	$50,counter			## 
	jne 	lWall				## jne = jump if not equal
	


	movl	$0,counter
roof:
	########## print to screen ###############
	pushl	$45				# char (-)
      	pushl	$0				# y cord
      	pushl	counter				# x cord
	call nib_put_scr
	addl    $12, %esp
	incl	counter				# increment

	cmpl	$50,counter			## 
	jne 	roof				## jne = jump if not equal


#######################################################################

jmp setupWorm

######################################## Print one apple to screen  ######################################
printOneApple:

	movl	$0,counter		# set counter to zero
	xorl	%ecx,%ecx
	xorl	%ebx,%ebx

loop:

	call 	rand			## The random value is in register eax brought from the rand call

	############# Modulo ##################
	xorl 	%edx,%edx		## zero out register
	movl	$50,%ecx		## modulo with value 50
	divl	%ecx			## result = eax  , rest = edx  (eax/värde)
	###################################### 


	xorl	%ebx,%ebx
	leal	appleCord,%ebx		# Load array address to register	
	xorl	%ecx,%ecx		# Zero out reg %ecx
	movl	index,%ecx		# move index to ecx
	movl	%edx,(%ebx,%ecx,4)	# on Every 4 bytes on each index on value: i1 Ycord = 4, i2 Xcord = 8 
	incl	index
	
	pushl	%edx			## push cordinates to the stack

	incl	counter	
	cmpl	$2,counter		## loop 2 times, = get x and y values
	jne 	loop			## jne = jump if not equal
	#######################################

	xorl	%ecx,%ecx
	xorl	%ebx,%ebx
	
	popl	%ecx			# pop x cord
	popl	%ebx			# pop y cord

	########## print to screen ###############
	pushl	$char
      	pushl	%ebx
      	pushl	%ecx
	call nib_put_scr
	addl    $12, %esp

	### test prints the new apple (x,y)
	#pushl	%ecx
	#pushl	%ebx
	#pushl	$message
	#call	printf
	#addl	$12,%esp

	ret
####################################################################################################



##################### Apple collision detection #########################

acd:
	movl 	$0,counter
	xorl	%ecx,%ecx
	xorl	%edx,%edx
	####################################################

	### Division  index/2 = nr of apples. (x,y) cords ######
	movl	index,%eax
	movl	$2,%ecx			## modulo with value 2
	divl	%ecx			## result = eax  , rest = edx  (eax/värde)
	### the result from the division is in reg eax

	xorl	%ecx,%ecx
	movl	%ebx,%ecx		## snake head cords is in %ecx
	leal	appleCord,%ebx		## apple cords is now in %ebx
	xorl	%edx,%edx

	#pushl	%ebx
	#pushl	%ecx
	#pushl	4(%ecx)
	#pushl	(%ecx)
	#pushl	$cmpMessage2
	#call	printf
	#addl	$12,%esp
	#popl	%ecx
	#popl	%ebx
loop1:
	
	incl	counter
	pushl	%eax			## push index value to stack

	### compare x cords
	xorl	%edx,%edx
	movl	4(%ecx),%edx		## move worm x cord to %edx
	cmpl	(%ebx),%edx		## compare apple x with worm x
	jne	iterate			## jump if not equal, if both x is not the same jump to iterate

	### compare y cords
	xorl	%edx,%edx
	movl	(%ecx),%edx		## move worm y cord to %edx
	cmpl	4(%ebx),%edx		## compare apple y with worm y
	jne	iterate			## jump if not equal, if both y is not the same jump to iterate.
	
	###### if here then its a hit!! ###### 


	pushl	%ecx
	pushl	counter
	pushl	%ebx
	pushl	%edx
	pushl	%eax
	call printOneApple
	popl	%eax
	popl	%edx
	popl	%ebx
	popl	counter
	popl	%ecx
	incl	wormSize
	
	##### print blank to screen
	pushl	$43				# char (+)
      	pushl	(%ebx)				# y cord
      	pushl	4(%ebx)				# x cord
	call nib_put_scr
	addl    $12, %esp

	#pushl	(%ebx)
	#pushl	4(%ebx)
	#pushl	$cmpMessage2
	#call	printf
	#addl	$12,%esp

	## zeroing the cordinates
	movl	$0,(%ebx)	
	movl	$0,4(%ebx)
	popl	%eax
	ret
		

iterate:
	addl	$8,%ebx			## move 8 bytes forward in apple array
	popl	%eax			## pop back index value to stack
	cmpl	%eax,counter			
	jne 	loop1			## jne = jump if not equal
	ret

#####################################################################################





#delete this, unecessary
setupWorm:
        #resets used registry
	movl	$0,counter
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

        #sets default coordinates
        movl    $25, (%ebx)
        movl    $25, 4(%ebx)


        xorl    %edx, %edx

        xorl    %eax, %eax
        movl    wormSize, %eax

       # jmp     reset_worm_body
       jmp      print_worm_middle


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
        jle     finish_loop
        cmpl    $50, %ecx
        jae      finish_loop
        #saves counter in registry ecx due to edx corruption during kbd call.
        movl    %ecx, 404(%ebx)

        call    nib_poll_kbd

        #sets direction depending on keyboard input if there are any
        call    setting_direction

        #checks input depending on what last_direction is set to
        call    check_input

        call    restore_counter

        # about 1 second delay for worm position update
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

        #restores counter after c-call
        call    restore_counter

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

        xorl    %ecx, %ecx
        #restores %ecx boundary value 
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
        xorl    %ecx, %ecx
        #restores %ecx boundary value 
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
        xorl    %ecx, %ecx
        #restores %ecx boundary value 
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
        xorl    %ecx, %ecx
        #restores %ecx boundary value 
        movl    404(%ebx), %ecx
        ret


print_space_if_not_zero_coords:
#print if both is not zero
###################################################
        #removes old worm position
        pushl   $32

        pushl   4(%ebx, %eax, 8)
        pushl   (%ebx, %eax, 8)
        call nib_put_scr

        #Clean up stack
        addl    $12, %esp
###################################################
        ret

####################checks if coordinates 0,0 is detected, if so,
#### then no space will be printed###
check_zero_coordinate:
        movl    $0, hit
        cmpl    $0, (%ebx, %eax,8)
        je      add_zero_coord_hit
back:   
        cmpl    $0, 4(%ebx,%eax,8)
        je      add_zero_coord_hit2

back2:
        cmpl    $2, hit
        jne      print_space_if_not_zero_coords  
        #else return
        ret 

add_zero_coord_hit:
        incl    hit
        jmp     back

add_zero_coord_hit2:
        incl    hit
        jmp     back2

#########################################################

########checks if coordinates 0,0 is detected, if so,
#### then no space will be printed###########

check_zero_coordinate_for_print:
        movl    $0, hit
        cmpl    $0, (%ebx, %eax,8)
        je      add_zero_coord_hit3
back3:   
        cmpl    $0, 4(%ebx,%eax,8)
        je      add_zero_coord_hit4

back4:
        cmpl    $2, hit
        jne      print_coords
        #else return
        ret 

add_zero_coord_hit3:
        incl    hit
        jmp     back3

add_zero_coord_hit4:
        incl    hit
        jmp     back4


print_coords:
################PRINT TO SCREEN##
        pushl   $wormChar
        pushl   4(%ebx, %eax, 8)
        pushl   (%ebx, %eax, 8)

        call    nib_put_scr

        #cleanup stack
        addl    $12, %esp
##############################
        ret

#########################################################

#this algorithm goes from the last body part of the worm, and forward in the array
#it fetches element from currentPos-1 to currentPos
update_tail:

        #currentPos-1
        decl    %eax
       # fetches value of currentPos-1 X-coord to %edx
        xorl    %edx, %edx
        movl    (%ebx, %eax, 8), %edx
        #fetches value of currentPos-1 Y-coord to %ecx
        xorl    %ecx, %ecx
        movl    4(%ebx, %eax, 8), %ecx

        #sets eax to currentPos again
        xorl    %eax, %eax
        movl    counter, %eax

        #copies X, Y from currentPos-1 to currentPos
        movl    %edx, (%ebx, %eax, 8)
        movl    %ecx, 4(%ebx, %eax, 8)


        #save eax before nib put scr
        movl    $0, 440(%ebx)
        movl    %eax, 440(%ebx)

        # #restore eax here
        movl    440(%ebx), %eax

        decl    counter
        decl    %eax
        #as long as counter != 0 then loop again, so the whole tail is updated.
        cmpl    $0, counter
        ja    update_tail
        #else return
        ret

print_tail:
        #saves  tail counter
        movl    %eax, 440(%ebx)

        call    check_zero_coordinate_for_print

        #restore  tail counter
        movl    440(%ebx), %eax

        #restore  tail counter
        movl    440(%ebx), %eax


        incl    %eax

        #fetches wormSize value to edx for registry comparison
        xorl    %edx, %edx
        movl    wormSize, %edx

        #if currentPos < wormSize
        #then loop again, else return
        cmpl    %edx, %eax
        jb      print_tail
        ret



print_tail_space:

        #saves  tail counter
        movl    %eax, 440(%ebx)

        call    check_zero_coordinate

        #restore  tail counter
        movl    440(%ebx), %eax


        #restore  tail counter
        movl    440(%ebx), %eax


        incl    %eax

        #fetches wormSize value to edx for registry comparison
        xorl    %edx, %edx
        movl    wormSize, %edx

        #if currentPos < wormSize
        #then loop again, else return
        cmpl    %edx, %eax
        jb      print_tail_space
        ret

update_tail_init:
        xorl    %eax, %eax
        movl    wormSize, %eax

        #position wormSize-1 (last body part)
        decl    %eax

        #moves wormSize-1 to counter
        movl    %eax, counter

        #compare and checks if %eax is bigger than 0
        cmpl    $0, %eax
        ja      update_tail
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

#####REMOVE OLD TAIL WITH PRINTING SPACES##########
        call    print_tail_space
###################################################



###################################################
        #restores boundary counter
        call    restore_counter

        #restores last_position
        xorl    %eax, %eax
        movl    418(%ebx), %eax

################update_tail#######################
        movl    $0, counter

        xorl    %eax, %eax

        #checks first if wormsize is bigger than 1, if so, then tail will be updated
        call    update_tail_init

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


	pushl	%ecx
	pushl	counter
	pushl	%ebx
	pushl	%edx
	pushl	%eax
	call 	acd
	popl	%eax
	popl	%edx
	popl	%ebx
	popl	counter
	popl	%ecx

	

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
        movl    wormSize, %edx

        #if the the worm really has a body part at pos 1 then it will start update
        cmpl    %eax, %edx

        #update worm body positions if it has any body parts
        ja      print_tail


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
        #resets hit
        movl    $0, hit

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
        cmpl    wormSize, %edx
        jb      collision_detect

        #by some wierd reason, the last_position variable gets reset inside the body_collision
        #function call, so I have to replace it just before jumping out
        xorl    %edx, %edx
        movl    422(%ebx), %edx
        movl    %edx, last_position
        #else jump back to function body_hit_detection_init was called from
        ret

add_hit:
        #increments hit
        #incl    416(%ebx)
        incl    hit

        jmp     collision_detect2

add_hit2:
        #increments hit
        #incl    416(%ebx)
        incl     hit

        #compares if there are two hits
        cmpl    $2, hit
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

	call 	nib_end