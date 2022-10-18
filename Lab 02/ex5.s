@ ARM Assembly - exercise 5
@ Group Number :10

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values
	mov r0, #10
	mov r1, #5
	mov r2, #7
	mov r3, #-8

	
	@ Write YOUR CODE HERE
	
	@ j=0;
	@ for (i=0;i<10;i++)
	@ 		j+=i;	
	
	@ Put final j to r5

	@ ---------------------
	mov r6,#0  //i=0
	loop:          // for loop
		cmp r6,r0  // compare i=10
		bne l1     // if i not equal 10 go to lable l1
		B exit     // if i equal go to exit lable
		
	l1:
		add r5,r5,r6  // j=j+i
		add r6,r6,#1  // i++
		
		B loop        // go to lable loop 
	exit:
	
	
	
	
	@ ---------------------
	
	
	@ load aguments and print
	ldr r0, =format
	mov r1, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "The Answer is %d (Expect 45 if correct)\n"

