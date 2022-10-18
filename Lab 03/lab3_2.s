@ ARM Assembly - lab 3.2 
@ Group Number :

	.text 	@ instruction memory

	
@ Write YOUR CODE HERE	

@ ---------------------	
gcd:
	cmp		r1,#0      // compare b and 0
	moveq	pc,lr      // if equal return a
	mov		r2,r0       
	mov		r0,r1       
	
loop:                  // loop for find mod value r0 mod r1
	cmp		r2,r1       
	movlt	r1,r2      // if r2<r1 assign b=a
	subge	r2,r2,r1   // else subtract r1
	bge		loop       // else goto loop
	b		gcd        // if lessthan goto gcd








@ ---------------------	

	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #64 	@the value a 64
	mov r5, #24 	@the value b 24
	

	@ calling the mypow function
	mov r0, r4 	@the arg1 load
	mov r1, r5 	@the arg2 load
	bl gcd
	mov r6,r0
	

	@ load aguments and print
	ldr r0, =format
	mov r1, r4
	mov r2, r5
	mov r3, r6
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "gcd(%d,%d) = %d\n"

