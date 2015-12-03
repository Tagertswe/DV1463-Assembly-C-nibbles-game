###
### Constants
###
.set	wormSize,	5
.set    apple,		42
.set 	x,		0
.set	y,		0
.set	char,		35


.data
message: .asciz "x-cord %d y-cord %d\n"
nrOfApples: 		.long	20	# One iteration creates x-cord second y-cord, means 20 iterations = 10 apples.
counter: 		.long	0
index:			.long	0
appleCord:		.space 400	# (x,y) cordinates where the apples has been placed on screen
tempSpace:		.space 8	# will be putting one random cordinates in this space

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

#jmp	printOneApple

############################### Print apples to screen  ##################################################

	movl	$0,counter	# set counter to zero
	xorl 	%ebx,%ebx
	xorl	%edx,%edx
	xorl	%ecx,%ecx
	leal	appleCord,%ebx
	#leal	x,%edx
	#leal	y,%ecx	

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
	#decl 	counter		
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


################### TEST prints all apples (x,y) plus one new #################
#	movl 	$0,counter
#	xorl	%ebx,%ebx
#	leal	appleCord,%ebx
test:

#	pushl	(%ebx)
#	addl	$4,%ebx
#	pushl	(%ebx)
#	addl	$4,%ebx
#	pushl	$message
#	call	printf
#	addl	$12,%esp

#	incl	counter
	
#	cmpl	$11,counter		## 
#	jne 	test			## jne = jump if not equal	
#############################################################################

	pushl	$15
	call 	sleep
	addl	$4,%esp

	call nib_end	
	call 	exit
	



/*RUN WORM WITH CONDITIONS HERE IN LOOP*/






        /* Finishing calls */
        //call nib_end
        call exit
