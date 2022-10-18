@ ARM Assembly - exercise 4
@ Group Number :10

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values
	mov r0, #3
	mov r1, #5
	mov r2, #7
	mov r3, #-8

	
	@ Write YOUR CODE HERE
	@ if (i>5) f = 70;
	@ else if (i>3) f=55;
	@ else f = 30;
	@ i  in r0
	@ Put f to r5
	@ Hint : Use MOV instruction
	@ MOV r5,#70 makes r5=70

	@ ---------------------
	cmp r0,#5; //compare i=5
	blt L1     // if i<5 go to lable L1
	mov r5,#70 // else f=70
	
	L1:
		cmp r0,#3  // compare i=3
		blt L2     // if i<3 go to lable L2
		mov r5,#55  // else f=55
	L2:
		mov r5,#30; // f=30	
	
	
	
	
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
format: .asciz "The Answer is %d (Expect 30 if correct)\n"

