
# alexis ugalde

.data
#;	System Service Codes
	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_FLOAT = 2
	SYSTEM_PRINT_STRING = 4
	
#;	Function Input Data
	squareRootValue1: .word 1742
	squareRootValue2: .word 4566
	floatSquareRootValue1: .float 15135.0
	floatSquareRootValue2: .float 911560.50
	floatTolerance1: .float 0.01
	floatTolerance2: .float 0.001
	
	printArray: .word 1, 1, 1, 1, 1, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 1, 1, 1, 1, 1
				.word 1, 1
	PRINT_ARRAY_LENGTH = 38
	
	arrayValues: .word	377, 148, 641, -486, 828, 456, 192, -742, -658, -139 
				 .word	801, -946, 325, 916, 982, 902, -809, 858, -510, -713
				 .word	-309, 515, 587, 320, 994, 528, -617, -515, -123, 294
				 .word	644, -339, 842, -441, -557, 58, 773, 694, 78, -744
				 .word	-350, -424, -514, -679, 402, -924, -178, 315, 509, 173
				 .word	44, -80, -340, 905, -840, -210, 671, -755, -809, 731
				 .word	-936, -414, 627, -565, -749, -804, -456, -236, 933, 961
				 .word	-675, -9, 653, 581, -567, 916, 738, 343, 684, -184
				 .word	-789, -400, -941, 145, 933, 230, -236, 880, 646, -926
				 .word	982, 221, -451, -783, 331, -157, 193, 940, -818, 270
	ARRAY_LENGTH = 100
	
#;	Labels
	endLabel: .asciiz ".\n"
	newLine: .asciiz "\n"
	space: .asciiz " "
	squareRootLabel1: .asciiz "The square root of 1742 is "
	squareRootLabel2: .asciiz "The square root of 4566 is "
	squareRootFloatLabel1: .asciiz "The square root of 15135.0 is "
	squareRootFloatLabel2: .asciiz "The square root of 911560.50 is "
	printArrayLabel: .asciiz "\nPrint Array Test:\n"
	unsortedLabel: .asciiz "\nUnsorted List:\n"
	sortedLabelAscending: .asciiz "\nSorted List (Ascending):\n"

.text
#;	Function 1: Integer Square Root Estimation
#;	Estimates the square root using Newton's Method
#;	Argument 1: Integer value to find the square root of
#;	Returns: The estimated square root as an integer
.globl estimateIntegerSquareRoot
.ent estimateIntegerSquareRoot
estimateIntegerSquareRoot:
#;	New Estimate = (Old + Value/Old)/2
	move $t0, $a0

	estLp:
		div $t1, $a0, $t0 		
		add $t1, $t1, $t0 
		div $t1, $t1, 2
		sub $t2, $t1, $t0 
		move $t0, $t1
		blt $t2, -1, estLp
		bgt $t2, 1, estLp

	move $v0, $t0 
	jr $ra 
.end estimateIntegerSquareRoot

#; Function 2: Float Square Root Estimation
#;	Estimates the square root using Netwon's Method
#;	Argument 1: Float value to find the square root of 			
#;	Argument 2: Float value representing the tolerance level to stop at
#;	Returns: The estimated square root as a float

#;	Floating Point Comparison
#;	Use c.lt.s FRsrc1, FRsrc2 to set the comparison flag
#;	Use bc1t label to branch if the comparison was true
#;	Example:
#;		c.lt.s $f0, $f1
#;		bc1t estimateLoop #; Branch if $f0 < $f1
#;	In this version of MIPS, there is no greater than comparisons

.globl estimateFloatSquareRoot
.ent estimateFloatSquareRoot
estimateFloatSquareRoot:
#;	New Estimate = (Old + Value/Old)/2

	# convert 2 to float and store into f4
	li $s0, 2
	mtc1 $s0, $f4
	cvt.s.w $f4, $f4

	# arg1 = f12 & f0 
	# arg2 = f14 & f1
	mov.s $f0, $f12 		# arg 1 = f0 
	mov.s $f1, $f14 		# arg 2 = f1	
	estFloatLp:
		div.s $f2, $f12, $f0	# div itself into f2 
		add.s $f2, $f2, $f0 	# add old + values 
		div.s $f2, $f2, $f4		# $f2 = estimate
		sub.s $f3, $f2, $f0		# difference in $f3
		mov.s $f0, $f2 			# estimate in $f0
		li $s1, 0				
		mtc1 $s1, $f5
		cvt.s.w $f5, $f5		# 0 in f5 for comparison
		mov.s $f6, $f3			# move difference to $f6
		c.lt.s $f6, $f5			# compare difference to 0
		bc1f doneLp
			neg.s $f6, $f6		# difference * -1
		doneLp:
			c.lt.s $f6, $f1		# compare calculation to second argument 
			bc1f estFloatLp		# < then re loop

	jr $ra
.end estimateFloatSquareRoot

#;	Function 3: Print Integer Array
#;	Prints the elements of the array to the terminal
#;	On each line, output a number of values equal to the 
#;	square root of the total number of elements
#;	Use estimateIntegerSquareRoot to determine how many 
#;	elements should be printed on each line
#;	Argument 1: Address of array to print A0
#;	Argument 2: Integer count of the number of elements in the array A1
.globl printIntegerArray
.ent printIntegerArray
printIntegerArray: 
#;	Remember to push and pop $ra for non-leaf functions
	# push ra 
	subu $sp, $sp 4
	sw $ra, ($sp)

	move $s1, $a0					# store arg1 (address of array) into a reg 
	move $s0, $a1 					# store arg2 (number of elements) of array into reg for fcn call 

	move $a0, $a1					# move num elements into a0 for function call
	jal estimateIntegerSquareRoot	# returns sqrt in $v0
	move $t0, $v0					# sqrt in $t0 

	li $t1, 0						
	printLp: 			# prints array
		# printing a number from array
		li $v0, SYSTEM_PRINT_INTEGER
		lw $a0, ($s1)
		syscall 

		# space between each number
		li $v0, SYSTEM_PRINT_STRING
		la $a0, space 
		syscall

		addu $t1, $t1, 1	# increment number of items printLpDone

		# t2 = calculate itemsPrinted ($t1) % sqrt ($t0) 
		# t0 = value from estIntSqrt 
		# t1 = counter 
		
		rem $t2, $t1, $t0
		beq $t2, 0, printNewLine 		# if == 0 then print newLine
		b printLpDone

	    printNewLine: 
            li $v0, SYSTEM_PRINT_STRING
            la $a0, newLine
            syscall

   		printLpDone:
        	addu $s1, $s1, 4
			bltu $t1, $s0, printLp			# compare number of items printed to arg 2 if less than, loop again else stop


	# pop ra 
	lw $ra, ($sp)
	addu $sp, $sp, 4

	jr $ra
.end printIntegerArray

#; Function 4: Integer Comb Sort (Ascending)
#;	Uses the comb sort algorithm to sort a list of integer values in ascending order
#; Argument 1: Address of array to sort 		a0
#;	Argument 2: Integer count of the number of elements in the array   A1
#;	Returns: Nothing
.globl sortList
.ent sortList
sortList:

	move $t0, $a1	# gapsize = length
	li $t8, 10
	li $t9, 13

	gapLp:
		mul $t0, $t0, $t8
		div $t0, $t0, $t9
		bgt $t0, 0, skipFloor
		li $t0, 1

		skipFloor:
			move $t1, $a1		# n 
			sub $t1, $t1, $t0	# n - gapsize
			li $t2, 0			# i
			li $t3, 0			# swapsDone

		combSortLp:
			mul $t7, $t2, 4
			add $a0, $a0, $t7
			lw $t4, ($a0)
			sub $a0, $a0, $t7 

			add $t2, $t2, $t0	# i + gapsize

			mul $t7, $t2, 4
			add $a0, $a0, $t7
			lw $t5, ($a0)
			sub $a0, $a0, $t7

			bgt $t4, $t5, swap

			sub $t2, $t2, $t0
			b swapDone

			swap:
				mul $t7, $t2, 4
				add $a0, $a0, $t7
				lw $t5, ($a0)
				sw $t4, ($a0)
				sub $a0, $a0, $t7

				sub $t2, $t2, $t0

				mul $t7, $t2, 4
				add $a0, $a0, $t7
				sw $t5, ($a0)
				sub $a0, $a0, $t7

				add $t3, $t3, 1
			
			swapDone:
				add $t2, $t2, 1
			
		sub $t1, $t1, 1
		bne $t1, 0, combSortLp

		bne $t0, 1, gapLp
		beq $t3, 0, combSortDone

	b gapLp

	combSortDone:

	jr $ra
.end sortList


#; ----------------------------------------------------------------------------------------
#;	------------------------------------DO NOT CHANGE MAIN----------------------------------
#; ----------------------------------------------------------------------------------------
.globl main
.ent main
main:
#;	Square Root Test 1
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootLabel1
	syscall

	lw $a0, squareRootValue1
	jal estimateIntegerSquareRoot

	move $a0, $v0
	li $v0, SYSTEM_PRINT_INTEGER
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall

#;	Square Root Test 2
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootLabel2
	syscall

	lw $a0, squareRootValue2
	jal estimateIntegerSquareRoot

	move $a0, $v0
	li $v0, SYSTEM_PRINT_INTEGER
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall
	
#;	Float Square Root Test 1
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootFloatLabel1
	syscall

	l.s $f12, floatSquareRootValue1
	l.s $f14, floatTolerance1
	jal estimateFloatSquareRoot

	li $v0, SYSTEM_PRINT_FLOAT
	mov.s $f12, $f0
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall

#;	Float Square Root Test 2
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootFloatLabel2
	syscall

	l.s $f12, floatSquareRootValue2
	l.s $f14, floatTolerance2
	jal estimateFloatSquareRoot

	li $v0, SYSTEM_PRINT_FLOAT
	mov.s $f12, $f0
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall
	
#;	Print Array Test
	li $v0, SYSTEM_PRINT_STRING
	la $a0, printArrayLabel
	syscall

	la $a0, printArray
	li $a1, PRINT_ARRAY_LENGTH
	jal printIntegerArray

#;	Print Unsorted Array
	li $v0, SYSTEM_PRINT_STRING
	la $a0, unsortedLabel
	syscall

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal printIntegerArray
	
#;	Print Sorted Array (Ascending)
	li $v0, SYSTEM_PRINT_STRING
	la $a0, sortedLabelAscending
	syscall

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal sortList

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal printIntegerArray
	
#;	End Program
	li $v0, SYSTEM_EXIT
	syscall
.end main
