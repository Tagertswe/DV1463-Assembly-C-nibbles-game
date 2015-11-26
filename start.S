.set	MAX_ITER,	5

###
### Global variables
###


.data
wormSize:   .long 0
apple:     .long 42

.text

.globl	_start

.type _start,@function

_start:
        call	nib_init
        pushl   $25
        pushl   $25
        pushl   wormSize
        call    nib_put_scr
        addl    $12, %esp


/*        movl	4(%esp), %ecx	# no of iterations
        cmpl	$MAX_ITER, %ecx	# just a check...
        jle	ok
        ret
        ok:
        xorl	%eax, %eax	# set the result register to zero
        oloop:	movl	4(%esp), %ebx	# start outer loop, init the no iter in iloop
        iloop:	incl	%eax		# start inner loop, increment the result
        decl	%ebx
        jnz	iloop		# end of inner loop
        loop	oloop		# end of outer loop
        movl	%eax, result	# store the result*/
        call	nib_end
        ret
