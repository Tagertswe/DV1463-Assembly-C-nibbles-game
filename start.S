###
### Constants
###
.set	wormSize,	5
.set    apple,		42
.set 	x,	10
.set	y,	20
.set	char,	35

.data
s1: .string "5"
.text

.globl	_start

.type _start,@function

_start:
        call	nib_init
  	pushl	$char
	pushl	$x
	pushl	$y
	call nib_put_scr
	//call nib_end
	call exit






//  (int x, int y, int ch)
