###
### Constants
###
.set	wormSize,	5
.set    apple,		42
.set 	x,		0
.set	y,		0
.set	char,		35


.data
message: 	.asciz "x-cord %d y-cord %d\n"
cmpMessage1: 	.asciz "Worm head cordinate x,y (%d,%d)\n"
cmpMessage2: 	.asciz "Apple cordinate x,y (%d,%d)\n"
counterValue:	.asciz "Counter value is: %d\n"

nrOfApples: 		.long	20	# One iteration creates x-cord second y-cord, means 20 iterations = 10 apples.
counter: 		.long	0
index:			.long	0
appleCord:		.space 	400	# (x,y) cordinates where the apples has been placed on screen
tempSpace:		.space 	8	# will be putting one random cordinates in this space
borderSize:		.long	50

.text

.globl start_game
.type start_game,@function
start_game:
#jmp	getRandVal
call	nib_init
      



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

#jmp	acd

############################### Print apples to screen  ##################################################

	movl	$0,counter	# set counter to zero
	xorl 	%ebx,%ebx
	xorl	%edx,%edx
	xorl	%ecx,%ecx
	leal	appleCord,%ebx

getApples:

	xorl	%edx,%edx
	xorl	%ecx,%ecx	

	#pushl	(%ebx)
	#addl	$4,%ebx
	#pushl	(%ebx)
	#addl	$4,%ebx
	#pushl	$message
	#call	printf
	#addl	$12,%esp
	
	incl	counter

	########## print to screen ###############
	pushl	$char
	pushl	(%ebx)
	addl	$4,%ebx
	pushl	(%ebx)
	addl	$4,%ebx
	call nib_put_scr
	addl    $12, %esp
	
	cmpl	$10,counter			## loop 10 times, = nr of apples to be put on the screen	
	jne 	getApples			## jne = jump if not equal


##########################################################################################################


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
	#pushl	$char
      	#pushl	%ebx
      	#pushl	%ecx
	#call nib_put_scr
	#addl    $12, %esp

	### test prints the new apple (x,y)
	#pushl	%ecx
	#pushl	%ebx
	#pushl	$message
	#call	printf
	#addl	$12,%esp


################### TEST prints all apples (x,y) plus one new #################
	#movl 	$0,counter
	#xorl	%ebx,%ebx
	#leal	appleCord,%ebx
#test:

	#pushl	(%ebx)
	#addl	$4,%ebx
	#pushl	(%ebx)
	#addl	$4,%ebx
	#pushl	$message
	#call	printf
	#addl	$12,%esp

	#incl	counter
	
	#cmpl	$11,counter		## 
	#jne 	test			## jne = jump if not equal	
#############################################################################



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


	



##################### Apple collision detection #########################

acd:	
	xorl	%ebx,%ebx	
	xorl	%ecx,%ecx
	xorl	%edx,%edx
	movl 	$0,counter

	
	########## Set fake (x,y) cordinates just for testing
	leal	tempSpace,%ebx
	movl	$36,(%ebx)
	addl	$4,%ebx
	movl	$42,(%ebx)
	subl	$4,%ebx	
	
	#pushl	(%ebx)
	#push	4(%ebx)
	#pushl	$message
	#call	printf
	#addl	$12,%esp
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

loop1:
	
	incl	counter
	pushl	%eax			## push index value to stack

	### compare x cords
	xorl	%edx,%edx
	movl	(%ecx),%edx		## move worm x cord to %edx
	cmpl	(%ebx),%edx		## compare apple x with worm x
	jne	iterate			## jump if not equal, if both x is not the same jump to iterate.
	
	### compare y cords
	xorl	%edx,%edx
	movl	4(%ecx),%edx		## move worm y cord to %edx
	cmpl	4(%ebx),%edx		## compare apple y with worm y
	jne	iterate			## jump if not equal, if both y is not the same jump to iterate.
	
	###### if here then its a hit!! ###### 

	
	### print blank to screen
	pushl	$43				# char (+)
      	pushl	$4(%ebx)			# y cord
      	pushl	$(%ebx)				# x cord
	call nib_put_scr
	addl    $12, %esp

	#pushl	4(%ebx)
	#pushl	(%ebx)
	#pushl	$cmpMessage2
	#call	printf
	#addl	$12,%esp

	## zeroing the cordinates
	movl	$0,(%ebx)	
	movl	$0,4(%ebx)

	#pushl	counter
	#pushl	$counterValue
	#call	printf
	#addl	$8,%esp
	jmp	end	

		

iterate:
	addl	$8,%ebx			## move 8 bytes forward in apple array
	popl	%eax			## pop back index value to stack
	cmpl	%eax,counter			
	jne 	loop1			## jne = jump if not equal

end:
	##ret


################################################
 	/* Finishing calls */

	pushl	$8
	call 	sleep
	addl	$4,%esp

	call 	nib_end	
	call 	exit

  
       
