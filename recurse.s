.text
.align 2
.globl main

main: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)			#set up exit $ra 

	li $v0, 5
	syscall 				#read an int 
	move $a0, $v0			#$a0 = input 

	bltz $a0, inputerror	#if input < 0, inputerror 
	
	jal recurse 

	move $a0, $v0
    li  $v0, 1
    syscall					#print output

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra 					#exit program 

inputerror:
	li $v0, 4
	la $a0, msg				#print error message
	syscall 

	li $v0, 10
	syscall					#exit

recurse: 
	#build stack
	addi $sp, $sp, -12 
	sw $ra, 0($sp)
	sw $s0, 4($sp)			#$s0 stores passed value
	sw $s1, 8($sp)			#$s1 stores first returned recursive call 

	#store $a0 (input) in $s0
	move $s0, $a0

	#base case 
	li $t0, 1 
	beq $s0, $zero, return2
	beq $s0, $t0, return5

	#first recursive call
	addi $a0, $s0, -1
	jal recurse
	li $t1, 3
	mul $s1, $t1, $v0		#$s1 = 3*recursion(N-1)

	#second recursive call
	addi $a0, $s0, -2
	jal recurse
	li $t1, 2
	mul $v0, $t1, $v0		#$v0 = 2*recursion(N-1)
	add $v0, $v0, $s1		#$v0 = 2*recursion(N-1) + $s1
	addi $v0, $v0, 1		#$v0 = $v0 + $s1 + 1

	exitrecurse: 
		#collapse stack 
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		addi $sp, $sp, 12
		jr $ra 

	return2: 
		li $v0, 2
		j exitrecurse

	return5: 
		li $v0, 5
		j exitrecurse

.data
msg:    .asciiz "Input does not meet greater-than-zero requirement.\n"