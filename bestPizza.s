.text
.align 2
.globl main

main: 
	li $s7, 0
	j inputReader
	inputReader_ret:
	j sort 
	sortrtn:
	jal Print

	returnNull_ret:
	li $v0, 10
	syscall 

check: 
	addi $sp, $sp, -4
	sw $a0, ($sp)

	move $a0, $t5
	li $v0, 1
	syscall

	lw $a0, ($sp)
	addi $sp, $sp, 4

	jr $ra

sort:
	li $a0, 80
	li $v0, 9
	syscall
	move $s5, $v0 	#s5 = previous (tracker, does not change)
	sw $s0, 76($s5)	#previous.next = head  

	li $s6, 0
	loop1:
		beq $s6, $s7, exitloop1 
		move $a1, $s0 	#a1 = current, current = head
		move $a0, $s5
		loop2: 
			lw $a2, 76($a1)			#a2 = current.next 
			beq $a2, $0, exitloop2 	#if a2 = NULL, exit
			lw $t0, 72($a1)			#t0 = current.data
			lw $t1, 72($a2)			#t1 = current.next.data 
			
			li $t5, 0

			addi $sp, $sp, -8	#
			sw $a0, ($sp)		#stack housekeeping
			sw $a1, 4($sp)		#

			la $a0, ($a1)			#string1 = current.name
			la $a1, ($a2)			#string2 = current.next.name 
			beq $t0, $t1, strcmp 	#if current.data == current.next.data, strcmp

			lw $a1, 4($sp)		#
			lw $a0, ($sp)		#stack housekeeping
			addi $sp, $sp, 8	#

			beq $v0, $t3, true2 #if current.next.name < current.name (if v0 == 1), true 
			true2rtn: 
			#swap if true 

			slt $t2, $t0, $t1	
			li $t3, 1
			beq $t2, $t3, true1 #if current.data < current.next.data, true
			true1rtn:

			li $t3, 1
			beq $t5, $t3, swap
			swap_rtn:

			move $a0, $a1		#previous = current
			lw $a3, 76($a1)		#a3 = current.next
			move $a1, $a3		#current = current.next 
			j loop2

		exitloop2:
		addi $s6, $s6, 1
		j loop1
	exitloop1:
		jr sortrtn
true1: 
	addi $t5, $t5, 1
	jr true1rtn
true2:
	addi $t5, $t5, 1
	jr true2rtn
swap:
	#a0 = previous
	#a1 = current 
	beq $a1, $s0, headspecialcase
	move $t0, $a0	
	move $t1, $a1 
	#prev = $t0
	#current = #t1 
	lw $t3, 76($t1)
	move $t4, $t3
	sw $t3, 76($t0)
	#prev.next = current.next 
	lw $t3, 76($t1)
	lw $t3, 76($t3)
	sw $t3, 76($t1)
	#current.next = current.next.next
	move $t3, $t4
	sw $t1, 76($t3)
	#current.next.next = current 
	move $a1, $t3	
	jr swap_rtn 
headspecialcase: 
	move $t9, $s0 #preserve head node 
	move $t0, $a0	
	move $t1, $a1 
	#prev = $t0
	#current = #t1 
	lw $t3, 76($t1)
	move $t4, $t3
	sw $t3, 76($t0)
	#prev.next = current.next 
	lw $t3, 76($t1)
	lw $t3, 76($t3)
	sw $t3, 76($t1)
	#current.next = current.next.next
	move $t3, $t4
	sw $t1, 76($t3)
	#current.next.next = current 
	move $a1, $t3
	move $s0, $t3
	jr swap_rtn 

costiszero:
	l.s $f3, zerof
	s.s $f3, 72($s0)
	jr here
costiszero2:
	l.s $f3, zerof
	s.s $f3, 72($s0)
	jr here2

inputReader:
	li $a0, 80
	li $v0, 9
	syscall 						#malloc 80 bytes per struct
	move $s0, $v0					#$s0 points to current (head) node 

	li $v0, 4
	la $a0, promptName
	syscall 						#prompt name
	la $a0, 0($s0)
	li, $a1, 64
	li $v0, 8
	syscall 						#get name
	jal deletenln 					#deletenln in heap 
	la $a0, DONE
	la $a1, 0($s0)
	jal strcmp						#==DONE?
	beq $v0, $0, returnNull			#true, return NULL

	addi $s7, $s7, 1				#count = 1

	li $v0, 4
	la $a0, promptDiameter 
	syscall 						#prompt diameter
	li $v0, 6
	syscall 						 
	s.s $f0, 64($s0)				#store diameter in heap at 64($s0)

	li $v0, 4
	la $a0, promptCost 
	syscall 						#prompt cost
	li $v0, 6
	syscall 						 
	s.s $f0, 68($s0)				#store COST in heap at 68($s0)

	l.s $f1, 64($s0)	#diameter
	l.s $f2, 68($s0)	#cost

	#calculate pizza_per_dollar

	l.s $f3, zerof
	c.eq.s $f1, $f3
	bc1t costiszero
	c.eq.s $f2, $f3
	bc1t costiszero

	lwc1 $f0, two						
	div.s $f1, $f1, $f0 			#$f1 = diameter / 2 = r
	mul.s $f1, $f1, $f1 			#$f1 = r^2 
	lwc1 $f3, PI					
	mul.s $f1, $f1, $f3				#$f1 = area
	div.s $f3, $f1, $f2				#$f3 = pizza_per_dollar 
	s.s $f3, 72($s0)				#store pizza_per_dollar in heap at 72($s0)
	here:

	move $s2, $s0					#$s2 = node pointer, points to head 
	move $s1, $s0					#$s1 = head; design: $s1->next=$s2

	input_loop: 
		li $a0, 80						#$s1 = $s2 = previous 
		li $v0, 9
		syscall 						#malloc 80 bytes per struct
		sw $v0, 76($s2)					#previous.next -> current
		move $s2, $v0					#$s1 -> current

		li $v0, 4
		la $a0, promptName
		syscall 						#prompt name
		la $a0, 0($s2)
		li, $a1, 64
		li $v0, 8
		syscall 						#get name

		jal deletenln 					#deletenln in heap 

		la $a0, DONE
		la $a1, 0($s2)
		jal strcmp						#==DONE?

		beq $v0, $0, exit_input_loop	#true, exit loop; $s1 = previous, $s2 = current

		addi $s7, $s7, 1				#count++

		li $v0, 4
		la $a0, promptDiameter 
		syscall 						#prompt diameter
		li $v0, 6
		syscall 						 
		s.s $f0, 64($s2)				#store diameter in heap at 64($s0)

		li $v0, 4
		la $a0, promptCost 
		syscall 						#prompt cost
		li $v0, 6
		syscall 						 
		s.s $f0, 68($s2)				#store COST in heap at 68($s0)

		l.s $f1, 64($s2)	#diameter
		l.s $f2, 68($s2)	#cost

		lwc1 $f0, two						
		div.s $f1, $f1, $f0 			#$f1 = diameter / 2 = r
		mul.s $f1, $f1, $f1 			#$f1 = r^2 
		lwc1 $f3, PI					
		mul.s $f1, $f1, $f3				#$f1 = area
		div.s $f3, $f1, $f2				#$f3 = pizza_per_dollar 
		s.s $f3, 72($s2)				#store pizza_per_dollar in heap at 72($s0)

		l.s $f5, zerof
		div.s $f4, $f1, $f5
		c.eq.s $f4, $f3
		bc1t infdata 
		infdatartn:

		lw $s1, 76($s1)				#$s1 = $s1->next = current
		j input_loop

	exit_input_loop:
		sw $0, 76($s1)					#delete last DONE struct 
		jr inputReader_ret
infdata: 
	add.s $f3, $f5, $f5
	s.s $f3, 72($s2)			#if data = inf, then data = 0
	jr infdatartn

Print:
	move $t0, $s0
	testPrint_loop: 
		beq $t0, $0, exit_testPrint_loop 

		li $v0, 4
		la $a0, 0($t0)					
		syscall 						#print name

		li $v0, 4
		la $a0, space					
		syscall 

		li $v0, 2
		lwc1 $f12, 72($t0)
		syscall 						#print pizza_per_dollar

		li $v0, 4
		la $a0, nln
		syscall 

		lw $t0, 76($t0)

		j testPrint_loop 

	exit_testPrint_loop:
		jr $ra

strcmp: 
	#if string 1 = string 2, return 0
	#if string 1 < string 2, return 2
	#if string 1 > string 2, return 1 
	move $t8, $ra
	loop: 
		lb $t0, 0($a0)
		lb $t1, 0($a1)
		li $t3, 1
		slt $t7, $t0, $t1
		beq $t7, $t3, returntwo
		slt $t7, $t1, $t0
		beq $t7, $t3, returnone

		li $v0, 0
		bne $t0, $0, t0isnot0
		t0isnot0_ret:
		bne $t1, $0, t1isnot0
		t1isnot0_ret:

		beq $v0, $0, returnzero	#if both end, return 0
		li $t4, 1
		beq $v0, $t4, returnone	#if t1 ends t0 doesnt, return 1
		li $t4, 2
		beq $v0, $t4, returntwo	#if t0 ends t1 doesnt, return 2

		#else if both equal and none ends
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j loop 
	t0isnot0:
		addi $v0, $v0, 1
		jr t0isnot0_ret
	t1isnot0:
		addi $v0, $v0, 2
		jr t1isnot0_ret
	returnzero:
		li $v0, 0
		move $ra, $t8
		jr $ra
	returnone:
		li $v0, 1
		move $ra, $t8
		jr $ra
	returntwo: 
		li $v0, 2
		move $ra, $t8
		jr $ra

deletenln:
	move $t2, $a0
	li $t0, '\n'
	deletenlnloop:
		lb $t1, ($t2)
		beq $t1, $t0, exit_deletenlnloop
		addi $t2, $t2, 1
		j deletenlnloop
	exit_deletenlnloop:
		sb $0, 0($t2)
		jr $ra

returnNull:
	sw $0, ($s0)
	la $a0, emptyFile
	li $v0, 4
	syscall 
	jr returnNull_ret




.data
promptName:    	.asciiz "Pizza name:\t"
promptDiameter: .asciiz "Pizza diameter:\t"
promptCost: 	.asciiz "Pizza cost:\t"
DONE: 			.asciiz "DONE"
emptyFile:		.asciiz "PIZZA FILE IS EMPTY\n"
endoflist: 		.asciiz "end of loop!"
space: 			.asciiz " "
nln: 			.asciiz "\n"
buffer: 		.space 64 
PI: 			.float 3.14159265358979323846
two:			.float 2.0
zerof:			.float 0.0