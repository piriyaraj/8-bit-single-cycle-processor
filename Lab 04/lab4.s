.text	@ instruction memory

	
	.global main
main:
	@ stack handling
	sub	sp, sp, #4     @ allocate stack 
	str	lr, [sp, #0]   @store the return address 
	sub	sp, sp, #4     @allocate stack for input


	@printf for enter the number of strings 
  	ldr	r0, =format1   
	bl	printf         

	@scanf for number of strings 
	ldr	r0, =formats1            
	mov	r1, sp                    
	bl	scanf	                 

	@copy number of strings from the stack to register r4
	ldr	r4, [sp,#0]                
	
	add	sp, sp, #4              
        
	cmp     r4,#0                                     
	blt     wrong                   
	beq     exit                    

	
	mov	r5, #0                  @counter for the loop               


@loop to take the all the strings 
@================================================== take strings one by one
loop:
	cmp r5,r4                      
    BGE exit                       

	sub	sp, sp, #200           @ allocate space 
	
    @print statement for enter the strings
	ldr    r0,=format2             
	mov    r1,r5                   
	bl	printf                 
	
	@scanf for string              
	ldr	r0, =formats3            
	mov	r1, sp                   
	bl	scanf	                  

	@function call 1
	mov	r0, sp                              
	bl	stringLen                  


	mov     r6,r0                   
	sub     r6,r6,#1               

	ldr	r0, =formatp4                
	mov     r1,r5                   
	bl printf                       
	
@============================================= print the string in reverse order
loop2:	 
	add     r7,r6,sp                
	LDRB    r1,[r7,#0]              

    @printf for print the characters
   	ldr	r0, =formatp2           
	bl printf                       

    sub     r6,r6,#1               @length=length-1   
    cmp r6,#0    		
	bge     loop2                  
	
       
    add     sp, sp, #200          
    add     r5,r5,#1              @i=i+1 
    B loop                        


@========================================= for less than 0 to string count
wrong:
	ldr r0,=formatp3                         
    bl printf                     @printf("Invalid Number\n")
	
@========================================== finish function and return address 
exit:  
	ldr	lr, [sp, #0]         
	add	sp, sp, #4           @release stack 
	mov	pc, lr               @return 	

@========================================================== find string length

stringLen:
	sub	sp, sp, #4
	str	lr, [sp, #0]

	mov	r1, #0	@ length counter

loop3:
	ldrb	r2, [r0, #0]
	cmp	r2, #0
	beq	endLoop

	add	r1, r1, #1	@ count length
	add	r0, r0, #1	@ move to the next element in the char array
	b	loop3

endLoop:
	mov	r0, r1		@ to return the length
	ldr	lr, [sp, #0]
	add	sp, sp, #4
	mov	pc, lr


.data	@ data memory
format1: .asciz "Enter the number of strings:\n"
format2: .asciz "\nEnter input string %d:\n"

formats1: .asciz "%d"

formats3: .asciz " %[^\n]s"

formatp2: .asciz "%c"
formatp3: .asciz "Invalid Number\n"
formatp4: .asciz "Output string %d is...\n"
