###
### Constants
###
.set	wormSize,	5
.set    apple,		42
.set 	x,	10
.set	y,	20
.set	char,	35

.data
.text

.globl start_game
.type start_game,@function
start_game:
/*Procedure for pushing to the stack, three parameters*/
/*Calls a function afterwards */
/*First parameter is the last one in the C-function call */
        call	nib_init
        pushl	$char
        pushl	$x
        pushl	$y
        call nib_put_scr
        addl    $12, %esp

/*PLACE ALL APPLES HERE*/









/*RUN WORM WITH CONDITIONS HERE IN LOOP*/






        /* Finishing calls */
        //call nib_end
        call exit
