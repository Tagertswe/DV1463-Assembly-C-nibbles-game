.data

.text

.globl	_start

.type _start,@function

_start:

pushl	$10	# length
pushl	$10	# nr of apples
pushl	$99	# crap push
	


#void _start(void)
#: The _start symbol, i.e.  
#the entry point of the program.  This function should in turn call the start_game function with reasonable parameters
