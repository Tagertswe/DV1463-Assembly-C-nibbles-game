###
### Constants
###
.set	wormSize,	    5
.set    apple,		    42
.set 	x,	            10
.set	y,	            20
.set	wormChar,	    111
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
       # call    wLoop
       # call    exit_program

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
       # movl    $25, %eax
        jmp wLoop


        #checks if counter value is 0 or 50, then it will quit the loop 
        #(hitting the wall simulation)
wLoop:  cmpl    $0, %ebx
        je      finish_loop
        cmpl    $50, %ebx
        je      finish_loop

 #       pushl   %ebx
#        pushl   %eax
       # pushl   %ebx
      #  pushl   %ebx
        pushl   %ebx
        pushl   $wormChar
        # Y coord
        pushl   %ebx
        # X coord
        pushl   %ebx
        call    nib_put_scr

        popl    %ebx
        popl    %ebx
        addl    $8, %esp
        popl    %ebx
     #   popl    %ebx
    #    popl    %ebx
        # Clean up stack
                #saves edx value back to the eax registry
        # popl    %edx
        # #saves eax value back to edx registry
        # popl    %eax
        # #pops stack
        # addl    $8, %esp
        # popl    %eax
        # popl    %edx




        #pushes eax to stack before calling function
       #  pushl   %eax
       # #måste slänga EDX på stacken före varje call och kopiera tillbaka till registret!
       #  pushl   %edx
       #  #pushes eax to stack before calling function
       #  pushl   %eax
       # #måste slänga EDX på stacken före varje call och kopiera tillbaka till registret!
       # pushl   %edx
       # pushl    %edx


       #  call    nib_poll_kbd
       #  cmpl    $260, %eax #checks if left arrow has been pushed down
       #  je      kbd_polling_left

       #  # cmpl    $261, %eax #checks if right arrow has been pushed down
       #  # je      kbd_polling_right

       #  # cmpl    $259, %eax #checks if up arrow has been pushed down
       #  # je      kbd_polling_up

       #  # cmpl    $258, %eax #checks if down arrow has been pushed down
       #  # je      kbd_polling_down

       #  #save registry values on stack before call
       #  # pushl   %edx
       #  # pushl   %edx
       #  # pushl   %edx
       # #  pushl   %edx
       #  pushl    %ebx
       #  pushl    %ebx
       #  pushl    %ebx
       # #  #sets loop delay to around 1 second
        pushl  $loopDelay
        call    usleep

        addl    $12, %esp
        # popl    %ebx
        # popl    %ebx    
        # popl    %ebx
        #popl    %ebx
       # popl    %ebx

       #  #  # Clean up stack
       #  addl    $4, %esp
       #  popl    %edx
 

        jmp     wLoop


# kbd_polling_left:
#         #moves eax value from stack to registry EAX
#         #moves edx value from stack to registry edx
#         # and pops.
#         popl    %edx

#         #decrements counter, since now the worm moves to the left in X-axis
#         decl    %ebx
#         #assigns new X-axis value to the X-value registry
#       #  movl    %ebx, %edx
#         #saves edx on stack
#         pushl   %edx
#         pushl	$wormChar
#         pushl	$25
#       #  pushl	%ebx
#         pushl   $25
#         call nib_put_scr

#         #Clean up stack
#         #popl    %ebx
#         addl    $12, %esp
#         addl    $8, %esp
#         addl    $4, %esp
#         popl    %edx


#         jmp     wLoop

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




 finish_loop:
        ret

 exit_program:       
#         /* Finishing calls */
        call nib_end
      #  ret
        call exit
        ret
