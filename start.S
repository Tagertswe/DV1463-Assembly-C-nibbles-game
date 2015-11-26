###
### Constants
###
.set	wormSize,	5
.set    apple,		42

.data

.text

.globl	_start

.type _start,@function

_start:
        call	nib_init
	
	movl	$wormSize,%ecx	
	movl	$apple,%edx
	pushl	%ecx
  	pushl	%edx

	call nib_put_scr
	call exit

