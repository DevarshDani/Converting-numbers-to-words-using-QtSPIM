# printing out the words for an entered number

.data # data section

	ask:		.asciiz"Do you want to continue (Y/y/N/n) ? "
	prompt1:	.asciiz"How many digits do you want to enter ? "
	prompt2:	.asciiz"Enter an integer with number of digits = "
	error:		.asciiz"Sorry!!! cannot accept more than 9 digits or the number of digits as 0"
	inc:		.asciiz"Incorrect option try again!!!"
	incorrect:	.asciiz"Input is not a numeric value "	
	msg:		.asciiz"The number in words is: "
	newline: 	.asciiz"\n"
	char:		.byte 'Y', 'y', 'N', 'n'

			.align 1

	table:		.word 0 
			.asciiz "  ZERO  "
#			.align 1
			.word 1 
			.asciiz "  ONE   "
#			.align 1
			.word 2 
			.asciiz "  TWO   "
#			.align 1
			.word 3 
			.asciiz "  THREE "
#			.align 1
			.word 4 
			.asciiz "  FOUR  "
#			.align 1
			.word 5
			.asciiz "  FIVE  "
#			.align 1
			.word 6
			.asciiz "  SIX   "
#			.align 1
			.word 7 
			.asciiz "  SEVEN "
#			.align 1
			.word 8
			.asciiz "  EIGHT "
#			.align 1
			.word 9
			.asciiz "  NINE  "
#			.align 1

	list:		.word 0
	length:		.word 0

.text # text section

.globl main # call main by SPIM

main:
	jal	NL
	addi	$t2,$zero,0
	addi	$s0,$zero,0

	addi	$t2,$t2,10
	addi	$s0,$s0,4

# Ask for how many digits

	li	$v0,4				# syscall 4 = message
	la	$a0,prompt1
	syscall

# take the integer in register

	li	$v0,5				# syscall 5 = read integer
	syscall

# store integer in temporary register

	move	$t6,$v0

	jal	NL


# Check if greater than or equal to 10

	bge	$t6,$t2,Error
	beq	$t6,$zero,Error

Find_Number:

# get the input number	

	li	$v0,4				# syscall 4 = message
	la	$a0,prompt2
	syscall

# number of digits

	li	$v0,1
	move	$a0,$t6
	syscall

	jal	NL

# take the integer in register

	li	$v0,5				# syscall 5 = read integer
	syscall

# store integer in temporary register

	move	$t1,$v0
	move	$s4,$t6
	sll	$s4,$s4,3
	addi	$s4,$s4,1

# allocate memory

	li	 $v0, 9				# syscall 9 = allocate memory
	add	 $a0,$s4,$zero
	syscall

	sw	$s4,length
	sw	$v0,list
	addi	$s4,$s4,-1	
	add	$v0,$v0,$s4

# Divide and include the modulus value(units place) at the end of memory allocation

Divide:

	beq	$t6,$zero,Print
	divu	$t1,$t2
	mflo	$t1
	mfhi	$t3
	bne	$t1,$t3,Load_Table
	beq	$t1,$zero,Print
Load_Table:
	la	$t0,table
	addi	$s1,$s1,10
Loop:	
	beq	$s1,$zero,PrintIncorrect
	lw	$t4,0($t0)
	bne	$t3,$t4,incr
	add	$v0,$v0,-8	
	lw	$t8,4($t0)
	sw	$t8,0($v0)
	lw	$t8,8($t0)
	sw	$t8,4($v0)
	add	$s1,$zero,$zero
	j	Divide	
	
incr:
	addi	$t0,$t0,16
	addi	$s1,$s1,-1
	j	Loop

Print:

	jal	NL

# print the message

	li	$v0,4				# syscall 4 = message
	la	$a0,msg
	syscall

# Print the number in words

Print_in_Word:

	li	$v0,4				# syscall 4 = message
	lw	$a0,list
	lw	$a1,length
	syscall

	jal	NL

# Do you want to continue ?
Continue:
	li	$v0,4				# syscall 4 = message
	la	$a0,ask
	syscall

# Read the Character and validate the input value by the user

	li	$v0,12				# syscall 5 = read char
	syscall

	la	$t4,char
	move	$t2,$v0
	lb	$s2,0($t4)
	beq	$t2,$s2,main
	lb	$s2,1($t4)
	beq	$t2,$s2,main
	lb	$s2,2($t4)
	beq	$t2,$s2,End
	lb	$s2,3($t4)
	beq	$t2,$s2,End

	jal	NL

# Incorrect option

	li	$v0,4				# syscall 4 = message
	la	$a0,inc
	syscall

	jal	NL
	
	j	Continue


# End of Program
End:
	li $v0, 10   			# syscall 10 = exit    
	syscall

# Print error cannot accept more than or equal to 10 digits
Error:
	li	$v0,4				# syscall 4 = message
	la	$a0,error
	syscall	
	
	j	main

# Print incorrect numeric value

PrintIncorrect:

	li	$v0,4				# syscall 4 = message
	la	$a0,incorrect
	syscall
	jal	NL

	j	Continue


# New Line

NL:

	li	$v0,4
	la	$a0,newline
	syscall
	jr	$ra			 