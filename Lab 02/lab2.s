@ ARM Assembly - lab 2
@ Group Number : 10

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values
	mov r0, #0
	mov r1, #5
	mov r2, #0
	mov r3, #0

	
	@ Write YOUR CODE HERE
	
	@	Sum = 0;
	@	for (i=0;i<10;i++){
	@			for(j=5;j<15;j++){
	@				if(i+j<10) sum+=i*2
	@				else sum+=(i&j);	
	@			}	
	@	} 
	@ Put final sum to r5


	@ ---------------------
	loop1:           // 1st for loop
		cmp r0,#10   // compare i=10
		bne loop2    // else go lable loop2
		B exit       // if coditon true 
	
	loop2:           // 2nd for loop
		cmp r1,#15   // ccopare j=15
		bne if1      // else go lable if1
		add r0,#1    // if coditon true r0++ > i++
		mov r1,#5    // reassign r1 as initial value r1=5
		B loop1      // go loop1 when loop2 finshed
		
	if1:             
		add r2,r1,r0 // r2=r1+r0 >i+j
		cmp r2,#10   // compare i+j=10
		blt l1       // if not go to lable l1
		mov r4,r0    // if true r4=r0,
		and r4,r1    // r4=r4&r0 > i&j
		add r5,r5,r4 // f=f+(i&j)
		add r1,#1    // r1++ > j++
		B loop2      // go loop2
		
	l1:               // else part of compartion
		add r3,r0,r0  // r3=r0+r0 >i*2
		add r5,r5,r3  // f=f+(i*2)
		add r1,#1     // j++
		B loop2       // go loop2
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
format: .asciz "The Answer is %d (Expect 300 if correct)\n"

