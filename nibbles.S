###
### Constants
###
.set	wormSize,	5
.set    apple,		42
.set 	x,	        10
.set	y,	        20
.set	char,	        35
.set    loopDelay,      1000000
.data
print_format:   .asciz "Value of printout: %d \n"
.text

.globl start_game
.type start_game,@function
start_game:
/*Procedure for pushing to the stack, three parameters*/
/*Calls a function afterwards */
/*First parameter is the last one in the C-function call */
        call	nib_init
/*        pushl	$char
        pushl	$x
        pushl	$ygit
        call nib_put_scr
        addl    $12, %esp*/

/*PLACE ALL APPLES HERE*/









/*RUN WORM WITH CONDITIONS HERE IN LOOP*/
        xorl    %eax, %eax
        addl    $25, %eax
wLoop:  cmpl   $0, %eax
        pushl   %eax
        pushl   $print_format
        call    printf
        addl    $8, %esp
        pushl   $loopDelay
        decl    %eax
        call    usleep
        jmp     wLoop
        ret




        /* Finishing calls */
        //call nib_end
        call exit
