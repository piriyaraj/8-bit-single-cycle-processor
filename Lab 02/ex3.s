@ ARM Assembly - exercise 3 
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
	@ a,b,i,j in r0,r1,r2,r3 respectively
	@	if (i>=j) f = a+b;
	@	else f = a-b;
	@ Use signed comparison
	@ Put f to r5

	@ ---------------------
	cmp r2,r3   //compare i,j
	blt true    // usihg signed compartion if false goto true lable 
	sub r5,r0,r1    //f=a+b

	true:        // else part
		add r5,r0,r1  //f=a-b


	
	
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
format: .asciz "The Answer is %d (Expect 15 if correct)\n"

