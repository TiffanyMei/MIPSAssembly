.text
.align 2
.globl main

main: 
	li $v0, 5
	syscall 

	move $a0, $v0 

	jal recurse

	move $a0, $v0
	li $v0, 1
	syscall 

	li $v0, 10
	syscall 


recurse: 
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)		#saves first recursive call returned value = recurse(n-1)
	sw $s1, 8($sp)		#saves passed value 

	move $s1, $a0 

	li $t0, 1
	li $t1, 2
	beq $s1, $t0, return1
	beq $s1, $t1, return1

	addi $a0, $s0, -1
	jal recurse 
	move $s0, $v0

	addi $a0, $s0, -2
	jal recurse

	add $v0, $v0, $s0 	#return recurse(n-1)+recurse(n-2)

	j exitrecurse

	return1: 
		li $v0, 1
		j exitrecurse 

	exitrecurse: 
		lw $s1, 8($sp)
		lw $s0, 4($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 12 
		jr $ra 



