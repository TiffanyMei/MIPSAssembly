.text
.align 2
.globl main

main: 
	li $v0, 5				#syscall code for reading int is 5
	syscall 				#read an integer 


	move $t0, $v0			#$t0 = input = N

	li $t1, 0				#$t1 = count = 0

	li $t8, 13				#constant 13 

loop: 
	beq $t0, $t1, exit_loop	#exit loop if count = N 
	move $t2, $t1			#\
	addi $t2, $t2, 1		#/ $t2 = factor = count + 1 
	mul $t3 $t8, $t2

	li $v0, 1				#print number
	move $a0, $t3
	syscall 

	li $v0, 4				#print new line 
	la $a0, nln
	syscall 

	addi $t1, $t1, 1		#increment counter 
	j loop

exit_loop:					#Exit program 
	li $v0, 10
	syscall 


.data 
nln:
	.ascii "\n"


#read input 





#loop N times, print 13*N each time 
#exit on x = N + 1
#end program 

