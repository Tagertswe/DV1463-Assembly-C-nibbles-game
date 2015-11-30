###
### Constants
###
.set	wormSize,	5
.set    apple,		42
.set 	x,	        10
.set	y,	        20
.set	wormChar,	111
.set    loopDelay,      1000000
.set    border,         43
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
       # call    setupWorm
        # call     wLoop

        # call    finish_program
        # xorl    %ebx, %ebx
        # xorl    %esi, %esi
     #    xorl    %eax, %eax
     #    movl    $25, %edx
     # #   movl    $25, %eax
     #    pushl	$wormChar
     #    pushl	$edx
     #    pushl	$ebx
     #    call nib_put_scr
     #    addl    $12, %esp

/*PLACE ALL APPLES HERE*/









/*RUN WORM WITH CONDITIONS HERE IN LOOP*/
setupWorm:
        #resets used registry
        xorl    %ebx, %ebx
        xorl    %ecx, %ecx
        xorl    %edx, %edx

setupBorders: cmpl      $50, %ebx
        je      resetValues
        pushl   %ecx # 0
        pushl   $border # 4
        pushl   %edx # 8
        pushl   %ecx # 12
        call    nib_put_scr

        popl    %ecx # pops 12
        popl    %edx # pops 8
        addl    $4, %esp #pops 4
        popl    %ecx #pops 0


        #increments counter
        incl    %ebx
        #increments x axis value
        incl    %ecx

        jmp     setupBorders

resetValues:
        xorl    %ebx, %ebx
        xorl    %edx, %edx
        xorl    %eax, %eax
 #       xorl    %ecx, %ecx
        movl    $25, %ebx
        movl    $25, %edx
     #   movl    $25, %ecx
        movl    $25, %eax

        #checks if counter value is 0 or 50, then it will quit the loop 
        #(hitting the wall simulation)
wLoop:  cmpl    $0, %ebx
        je      finish_program
        cmpl    $50, %ebx
        je      finish_program

        pushl   %edx
        pushl   %eax
        pushl   $wormChar
        # Y coord
        pushl   %eax
        # X coord
        pushl   %edx
        call    nib_put_scr

        */ Clean up stack /*
        #saves edx value back to the eax registry
        popl    %edx
        #saves eax value back to edx registry
        popl    %eax
        #pops stack
        addl    $4, %esp
        popl    %eax
        popl    %edx




        #pushes eax to stack before calling function
        pushl   %eax

       #måste slänga EDX på stacken före varje call och kopiera tillbaka till registret!
        pushl   %edx


        call    nib_poll_kbd
        cmpl    $260, %eax #checks if left arrow has been pushed down
        je      kbd_polling_left

        # cmpl    $261, %eax #checks if right arrow has been pushed down
        # je      kbd_polling_right

        # cmpl    $259, %eax #checks if up arrow has been pushed down
        # je      kbd_polling_up

        # cmpl    $258, %eax #checks if down arrow has been pushed down
        # je      kbd_polling_down


        pushl   %eax
        pushl   %edx

        #sets loop delay to around 1 second
        pushl  $loopDelay
        call    usleep

        #saves values to registry again after function call.
        movl    4(%esp), %eax
        movl    8(%esp), %edx

        #pops stack
        addl    $12, %esp

        jmp     wLoop


kbd_polling_left:
        #moves eax value from stack to registry EAX
        #moves edx value from stack to registry edx
        # and pops.
        popl    %edx
        popl    %eax

        #decrements counter, since now the worm moves to the left in X-axis
        decl    %ebx
        #assigns new X-axis value to the X-value registry
        movl    %ebx, %edx
        pushl	$wormChar
        pushl	$25
        pushl	$edx
        call nib_put_scr

        #saves value to edx registry from stack after call.
        movl    12(%esp), %edx
        #saves value from edx back to counter (may not be needed, but just in case)
        movl    %edx, %eax
        #pops stack
        addl    $12, %esp

        jmp     wLoop

# # kbd_polling_right:
# #         incl    %ebx
# #         pushl   $wormChar
# #         pushl   $25
# #         pushl   %ebx
# #         call nib_put_scr
# #         addl    $12, %esp
# #         ret

# # kbd_polling_up:
# #         decl    %edx
# #         pushl   $wormChar
# #         pushl   %edx
# #         pushl   $25
# #         call nib_put_scr
# #         addl    $12, %esp
# #         ret

# # kbd_polling_down:
# #         incl    %edx
# #         pushl   $wormChar
# #         pushl   %edx
# #         pushl   $25
# #         call nib_put_scr
# #         addl    $12, %esp
# #         ret




 finish_program:
     #   ret
#         /* Finishing calls */
      #  call nib_end
      #  ret
        call exit
        ret
