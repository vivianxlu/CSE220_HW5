.data
space: .asciiz " "    # Space character for printing between numbers
.align 2
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

.text
.globl zeroOut 
.globl place_tile 
.globl printBoard 
.globl placePieceOnBoard 
.globl test_fit 

# Function: zeroOut
# Arguments: None
# Returns: void
zeroOut:
   	la $t0, board_width			# Load Address; Load address of board_width
    	lw $t1, 0($t0)					# Load Word; Load value of board_width into $t1
    	
    	la $t0, board_height			# Load Address; Load address of board_height
    	lw $t2, 0($t0)					# Load Word; Load value of board_height into $t2
    
    	li $t3, 0						# Load Immediate; Load 0 into $t3 to set row_index = 0
  
row_loop_zeroOut:
	# Check if we iterated through all the rows
	bge $t3, $t2, end_zeroOut
	
	li $t4, 0						# Load Immediate; Load 0 into $t4 to set col_index = 0
	
col_loop_zeroOut:
	# Check if we iterated through all the columns
	bge $t4, $t1, next_row_zeroOut	# If col_index >= board_width, continue to 'next_row_zeroOut'
	
	# Calculate the index of the current element: index = (row * board_width) + col
	mul $t5, $t3, $t1				# $t5 = (row * board_width)
	add $t5, $t5, $t4				# $t5 = (row * board_width) + col
	
	# Load the char from the array at board[index]
	la $t6, board					# Load Address; Load address of board
	add $t6, $t6, $t5				# Calculate the correct address of the index
	
	# Set the char from the array at board[index] to 0
	sb $0, 0($t6)					# Store Word; Store the value in $0 (0) into the address in $t6
	
	# Increment col_index
	addi $t4, $t4, 1
	
	# Return to the start of col_loop_zeroOut
	j col_loop_zeroOut				# Jump Register; Jump to the register stored in $ra

next_row_zeroOut:
	# Increment row_index
	addi $t3, $t3, 1
	
	j row_loop_zeroOut 				# Continue to the start of row_loop_zeroOut

end_zeroOut:
	# Return from `zeroOut`
   	# Return to the next instruction in `main`
    jr $ra

# Function: placePieceOnBoard
# Arguments: 
#   $a0 - address of piece struct
#   $a1 - ship_num
placePieceOnBoard:
	
	addi $sp, $sp, -28                            # Allocate memory on the stack
	
	# Load ship_num into $s1
	sw $s1, 0($sp)
	move $s1, $a1
	
	# Set the value of $s2 to 0
	sw $s2, 4($sp)
	move $s2, $0
	
	# Load piece fields (Each field is an integer (4 bytes), so the offsets will be multiples of 4)
	sw $s3, 8($sp)
	lw $s3, 0($a0)					# $s3 = piece_type 
	sw $s4, 12($sp)
	lw $s4, 4($a0)					# $s4 = piece_orientation
	sw $s5, 16($sp)
	lw $s5, 8($a0)					# $s5 = row_location
	sw $s6, 20($sp)
   	lw $s6, 12($a0) 				# $s6 = col_location
	
	sw $ra, 24($sp)
	
	# First switch on type
	li $t0, 1
   	beq $s3, $t0, piece_square
	li $t0, 2
	beq $s3, $t0, piece_line
	li $t0, 3
	beq $s3, $t0, piece_reverse_z
	li $t0, 4
	beq $s3, $t0, piece_L
   	li $t0, 5
	beq $s3, $t0, piece_z
	li $t0, 6
	beq $s3, $t0, piece_reverse_L
	li $t0, 7
	beq $s3, $t0, piece_T
	
	j piece_done 					# If $s2 == 0, go to 	piece_done'

piece_done:
	# Check $s2, the accumulated error value
	bnez $s2, invalid_piece_placement	# Branch Not Equal Zero; If $s2 != 0, then there is an error
	
	li $v0, 0						# Load Immediate; Load the return value, 0lw $s1, 0($sp)
	lw $s1, 0($sp)
	lw $s2, 4($sp)
	lw $s3, 8($sp)
	lw $s4, 12($sp)
	lw $s5, 16($sp)
	lw $s6, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
    	jr $ra

invalid_piece_placement:
	# Clear the board first
	jal zeroOut					# Jump and Link; Execute zeroOut, Return back here
	
	# Check if $s2 is equal to 1, 2, or 3
	li $t7, 1						# Load Immediate; Set $t7 = 1
	beq $s2, $t7, out_of_bounds_error	# Branch if Equals; If $s2 == 1 ($t7),  go to `out_of_bounds_error`
	li $t7, 2						# Load Immediate; Set $t7 = 2
	beq $s2, $t7, occupied_error		# Branch if Equals; If #$s2 == 2 ($t7), go to `occupied_error`
	li $t7, 3						# Load Immediate; Set $t7 = 3
	beq $s2, $t7, both_error			# Branch if Equals; If #$s2 == 3 ($t7), go to `both_error`

out_of_bounds_error:
	li $v0, 1						# Load Immediate; Load the return value, 1
	lw $s1, 0($sp)
	lw $s2, 4($sp)
	lw $s3, 8($sp)
	lw $s4, 12($sp)
	lw $s5, 16($sp)
	lw $s6, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra

occupied_error:
	li $v0, 2						# Load Immediate; Load the return value, 2
	lw $s1, 0($sp)
	lw $s2, 4($sp)
	lw $s3, 8($sp)
	lw $s4, 12($sp)
	lw $s5, 16($sp)
	lw $s6, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra
	
both_error:
	li $v0, 3						# Load Immediate; Load the return value, 3
	lw $s1, 0($sp)
	lw $s2, 4($sp)
	lw $s3, 8($sp)
	lw $s4, 12($sp)
	lw $s5, 16($sp)
	lw $s6, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra

# Function: printBoard
# Arguments: None (uses global variables)
# Returns: void
# Uses global variables: board (char[]), board_width (int), board_height (int)

printBoard:
	# Load the global variables
	la $t0, board_width			# Load Address; Load address of board_width
	lw $t1, 0($t0)				# Load Word; Load value of board_width into $t1
	
	la $t0, board_height		# Load Address; Load address of board_height
	lw $t2, 0($t0)				# Load Word; Load value of board_height into $t1
	
	# Initialize row_index to 0 (row_index will loop through the rows of the board)
	li $t3, 0                   # Load Immediate; Load 0 into $t3 to set row_index = 0
	
row_loop_printBoard:
	# Check if we iterated through all the rows
	bge $t3, $t2, end_printBoard 	# If row_index >= board_height, end row_loop
	
	# Initialize col_index to 0 (col_index will loop through the columns of the board)
	li $t4, 0					# Load Immediate; Load 0 into $t4 to set col_index = 0
	
col_loop_printBoard:
	# Check if we iterated through all the columns
	bge $t4, $t1, next_row_printBoard	# If col_index >= board_width, continue to the next row_index
	
	# Calculate the index of the current element: index = (row * board_width) + col
	mul $t5, $t3, $t1			# $t5 = (row * board_width)
	add $t5, $t5, $t4			# $t5 = (row * board_width) + col
	
	# Load the char from the array at board[index]
	la $t6, board				# Load Address; Load the base address of board
	add $t6, $t6, $t5			# Calculate the correct address of the index
	lb $t7, 0($t6)				# Load Byte; Load the byte (char) from the board into $t7
	
	# Print the ASCII value of the char
	li $v0, 1					# Load Immediate; Load the code for print_integer
	move $a0, $t7				# Move; Move the char from $t7 to $a0
	syscall						# Syscall; print_integer
	
	# Print a space after the ASCII value
	li $v0, 4					# Load Immediate; Load the code for print_string
	la $a0, space				# Load Address; Load the address of the space character
	syscall						# Syscall; print_string(space)
	
	# Increment col_index
	addi $t4, $t4 1				# Add Immediate; col_index = col_index + 1
	
	# Return to the start of col_loop
	j col_loop_printBoard
	
next_row_printBoard:
	# Print a new line before starting the next row
	li $v0, 4					# Load Immediate; Load the code for print_string
	la $a0, newline				# Load Address; Load the address of the newline character
	syscall						# Syscall; print_string(newline)
	
	# Increment row_index
	addi $t3, $t3, 1			# Add Immediate; row_index = row_index + 1
	
	# Continue to the start of row_loop
	j row_loop_printBoard

end_printBoard:
	# Print an extra newline at the end
	li $v0, 4					# Load Immediate; Load the code for print_string
	la $a0, newline				# Load Address; Load the address of the newline character
	syscall						# Syscall; print_string(newline)
	
   	# Return from `printBoard`
   	# Return to the next instruction in `main`
    	jr $ra					# Jump Register; Jump to the register stored in $ra


# Function: place_tile
# Arguments: 
#   $a0 - row
#   $a1 - col
#   $a2 - value
# Returns:
#   $v0 - 0 if successful, 1 if occupied, 2 if out of bounds
# Uses global variables: board (char[]), board_width (int), board_height (int)

place_tile:
	# Load the global variables
	la $t0, board_width				# Load Address; Load address of board_width
	lw $t1, 0($t0)					# Load Word; Load value of board_width into $t1
	
	la $t0, board_height			# Load Address; Load address of board_height
	lw $t2, 0($t0)					# Load Word; Load value of board_height into $t1
	
	# Check if the given row and/or column is out of bounds
	bge $a0, $t2, out_of_bounds    	# Branch if Greater/Equals; If row >= board_height, return an out_of_bounds value
	blt $a0, $0, out_of_bounds      # Branch if Less Than; If row < 0, return an out_of_bounds value
	
	bge $a1, $t1, out_of_bounds    	# Branch if Greater/Equals; If col >= board_width, return an out_of_bounds value
	blt $a1, $0, out_of_bounds 		# Branch if Less Than; If col < 0, return an out_of_bounds value
	
	# Calculate the index of the space specified by row,col: index = (row * board_width) + col
	mul $t3, $a0, $t1				# $t3 = (row * board_width)
	add $t3, $t3, $a1				# $t3 = (row * board_width) + col
	
	# Calculate the address of the space specified by row,col; Store the value of that space
	la $t4, board					# Load Address; Load address of board
	add $t4, $t4, $t3				# Calculate the correct address of the space
	lb $t5, 0($t4)					# Load Byte; Load the byte (char) from the board into #$t5
	
	# Check if the space indicated by row,col is occupied
	bnez $t5, occupied				# Branch if Not Equal Zero; If $t5 != 0, return an occupied value
	
	# If the space is not out of bounds or occupied, set the value of the space
	sb $a2, 0($t4)					# Store Byte; Store the value in $a2 into the address in $t4
	
	# Load the return value, 0
	li $v0, 0
	
	# Return from 'place_tile'
    jr $ra

out_of_bounds:
	# Load the return value, 2
	li $v0, 2
	
	# Return from 'out_of_bounds'/'place_tile'
	jr $ra
	
occupied:
	# Load the return value, 1
	li $v0, 1
	
	# Return from 'occupied'/'place_tile'
	jr $ra	

# Function: test_fit
# Arguments: 
#   $a0 - address of piece array (5 pieces)
test_fit:
	# Store the saved registers (and return address) into the stack
	addi $sp, $sp, -8					# Allocate memory in the stack
	sw $s0, 0($sp)
	sw $ra, 4($sp)

    	# Load the address of the (pieces)array
    	#move $t1, $a0						# Move; Move the address contained in $a0 to $t1
    	move $s0, $a0						# Move; Move the address contained in $a0 to $s1
    	
    	
    	li $t9, 0							# Load Immediate; Initialize $t9 = 0 ... Index to loop through the pieces of the array
    	j pieces_loop

pieces_loop:
	li $t2, 5							# Load Immediate; Initialize $t2 = 5 ... Number of pieces in the array
	bge $t9, $t2, finish_pieces_loop		# Branch Greater Equal; If $t9 >= $t2, then end the loop
	
	# Load the values for the current ship
	sll $t4, $t9, 4						# Shift Left Logical; Shift the value in $t9 to the left 4 times, Store in $t4
									# A.k.a. Multiply the index by 4
	# add $t5, $t1, $t4					# Calculate the address of the current piece; Add the multiple(of 4) to the starting address of the array
	add $t5, $s0, $t4
	
	lw $t6, 0($t5)						# Load Word, Load the piece type into $t6
	# Check if the type is within bounds (1-7)
	li $t7, 1							# Load Immediate; Load the smallest type (1) into $t7
	li $t8, 7							# Load Immediate; Load the largest type (7) into $t8
	blt $t6, $t7, type_orientation_error		# Branch Less Than; If $t6 (type) < $7 (1), branch to error
	bgt $t6, $t8, type_orientation_error		# Branch Greater Than; If $t6 (type) > $t8 (7), branch to error	
	
	lw $t6, 4($t5)						# Load Word; Load the piece orientation into $t6
	# Check if the orientation is within bounds (1-4)
	li $t7, 1							# Load Immediate; Load the smallest orientation (1) into $t7
	li $t8, 4							# Load Immedate; Load the largest orientation (4) into $t8
	blt $t6, $t7,  type_orientation_error		# Branch Less Than; If $t6 (orientation) < $t7 (1), branch to error
	bgt $t6, $t8, type_orientation_error		# Branch Greater Than; If $t6 (orientation) > $t8 (4), branch to error
	
	# If no error was found:
	addi $t9, $t9, 1						# Increment the index
	j pieces_loop						# Jump; Go back to the start of the loop

type_orientation_error:
	li $v0, 4							# Load Immediate; Load the error code
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8				# Remove memroy from the stack
	jr $ra							# Jump to #ra

finish_pieces_loop:
	li $t9, 0							# Reset $t9, our index, to place ships
	j place_pieces_loop
	
place_pieces_loop:
	li $t2, 5							# Load Immediate; Initialize $t2 = 0 (Every time we call this function, we need to set it again)
	
	bge $t9, $t2, finish_place_pieces_loop
	
    	sll $t4, $t9, 4						# Shift Left Logical; Shift the value in $t3 to the left 4 times, Store in $t4
									# A.k.a. Multiply the index by 4
	# add $t5, $t1, $t4					# Calculate the address of the current piece; Add the multiple(of 4) to the starting address of the array
	add $t5, $s0, $t4
    	
    	move $a0, $t5						# Move; Move the address of the piece from $t5 to $a0
    									# $a0 now stores the address of the piece struct
    	
    	addi $a1, $t9, 1					# Add Immediate; Take the value of the index ($t3) and add 1, Store into $a1
    									# $a1 now stores the ship_num
   
    	jal placePieceOnBoard				# Place the current  piece onto the board
    	
    	addi $t9, $t9, 1						# Add Immediate; Increment the index (After the piece has been placed)
    	j place_pieces_loop					# Jump to the top of the loop, Place the next piece
 	
 
 finish_place_pieces_loop:
 	lw $s0, 0($sp)
    	lw $ra, 4($sp)
	addi $sp, $sp, 8				# Remove memory from the stack
	jr $ra							# Jump to #ra


T_orientation4:
    # Study the other T orientations in skeleton.asm to understand how to write this label/subroutine
	move $a0, $s5		
	move $a1, $s6		
	move $a2, $s1		
	jal place_tile
	or $s2, $s2, $v0
	
	move $a0, $s5
	addi $a0, $a0, 1	# row + 1
	move $a1, $s6		# col
	move $a2, $s1		
	jal place_tile
	or $s2, $s2, $v0
	
	move $a0, $s5		
	addi $a0, $a0, 2	# row + 2
	move $a1, $s6		# col
	move $a2, $s1
	jal place_tile
	or $s2, $s2, $v0
	
	move $a0, $s5		
	addi $a0, $a0, 1	# row + 1
	move $a1, $s6		
	addi $a1, $a1, 1	# col + 1
	move $a2, $s1		
	jal place_tile
	or $s2, $s2, $v0
	j piece_done

.include "skeleton.asm"
