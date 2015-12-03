###
### Constants
###
.set	wormSize,	5
.set    apple,		42
.set 	x,		0
.set	y,		0
.set	char,		35


.data
message: .asciz "Hello world!, x-cord %d  y-cord %d\n"
nrOfApples: 		.long	20	# One iteration creates x-cord second y-cord, means 20 iterations = 10 apples.
counter: 		.long	0
index:			.long	0
appleCord:		.space 400	# (x,y) cordinates where the apples has been placed on screen

.text

.globl start_game
.type start_game,@function
start_game:
call	nib_init

jmp	getRandVal


putScr:
/*Procedure for pushing to the stack, three parameters*/
/*Calls a function afterwards */
/*First parameter is the last one in the C-function call */
      
	pushl	$char
      	pushl	$x
      	pushl	$y
	call nib_put_scr
	addl    $12, %esp
	ret


getRandVal:

	call 	rand			## The random value is in register eax brought from the rand call.

	############# Modulo ##################
	xorl 	%edx,%edx		## zero out register
	movl	$50,%ecx		## modulo with value 50
	divl	%ecx			## result = eax  , rest = edx  (eax/värde)
	###################################### 
	

	######---Print out current randomValue---#######
	#pushl  	%edx			## push the remainder value
	#pushl	$message
	#call	printf
	#addl 	$4,%esp			
	#########################################
	
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

	movl	%ebx,%edx	# to x cord
	addl	$4,%ebx
	movl	%ebx,%ecx	# to y cord
	addl	$4,%ebx

	incl	counter

	pushl	$char
      	pushl	(%edx)
      	pushl	(%ecx)
	call nib_put_scr
	addl    $12, %esp
		
	cmpl	$10,counter			## loop 10 times, = nr of apples to be put on the screen		
	jne 	getApples			## jne = jump if not equal

##########################################################################################################

	call exit
	
	







/*RUN WORM WITH CONDITIONS HERE IN LOOP*/






        /* Finishing calls */
        //call nib_end
        call exit
