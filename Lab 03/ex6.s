@ ARM Assembly - exercise 6 
@ Group Number :

	.text 	@ instruction memory
	
	
@ Write YOUR CODE HERE	

@ ---------------------	
fact:
	mov r1,#1
	mov r2,#1
	b loop
loop:
	cmp r0,#1
	movlt r0,r2
	movlt pc,lr
	mul r2,r0
	sub r0,r0,#1
	b loop



@ ---------------------	

.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #8 	@the value n

	@ calling the fact function
	mov r0, r4 	@the arg1 load
	bl fact
	mov r5,r0
	

	@ load aguments and print
	ldr r0, =format
	mov r1, r4
	mov r2, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "Factorial of %d is %d\n"

