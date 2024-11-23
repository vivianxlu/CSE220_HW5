.data
space: .asciiz " "    # Space character for printing between numbers
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
   	la $t0, board_width				# Load Address; Load address of board_width
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
    # Function prologue

    # Load piece fields
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
    j piece_done       # Invalid type

piece_done:
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
    jr $ra

# Function: test_fit
# Arguments: 
#   $a0 - address of piece array (5 pieces)
test_fit:
    # Function prologue
    jr $ra


T_orientation4:
    # Study the other T orientations in skeleton.asm to understand how to write this label/subroutine
    j piece_done

.include "skeleton.asm"