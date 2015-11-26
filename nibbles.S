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
        pushl	$y
        call nib_put_scr
        addl    $12, %esp */

/*PLACE ALL APPLES HERE*/









/*RUN WORM WITH CONDITIONS HERE IN LOOP*/
        xorl    %ebx, %ebx
        xorl    %edx, %edx
        addl    $25, %ebx
        addl    $25, %edx
wLoop:  cmpl    $0, %ebx
        je      l
        #pushl  %ebx
        #pushl  $print_format
        #call   printf
        #addl   $8, %esp

        call    nib_poll_kbd
        movl    %eax, %edx
        addl    $4, %esp
        cmpl    $260, %eax #checks if left arrow has been pushed down
        je      kbd_polling_left
        pushl  $loopDelay
        call    usleep
        addl    $4, %esp
        jmp     wLoop
kbd_polling_left:
        decl    %ebx
        pushl	$char
        pushl	$25
        pushl	%edx
        call nib_put_scr
        addl    $12, %esp

        ret


l:
        ret
        /* Finishing calls */
        //call nib_end
        call exit
