.data  
filein: 		.asciiz "C:\Users\knigh\Desktop\55.txt"      # filename for input
fileout: 		.asciiz "C:\Users\knigh\Desktop\55.txt"
buffer: 	.space 500
number:		.space 500
count:		.asciiz "\nCount number: "
showSort:	.asciiz "\nBubble Sort: "
msg:		.asciiz	" "
string_Done: .asciiz "\nBubbleSort Done!"

.text
main:
#open a file for writing
		li   	$v0, 13       		# system call for open file
		la   	$a0, filein     	# board file name	
		li   	$a1, 0         		# Open for reading flag
		li   	$a2, 0              # mode = 0
		syscall            			# open a file (file descriptor returned in $v0)
		move 	$s6, $v0      		# save the file descriptor 

#read from file
		li   	$v0, 14       		# system call for read from file
		move 	$a0, $s6      		# file descriptor 
		la   	$a1, buffer   		# address of buffer to which to read
		li   	$a2, 500      		# hardcoded buffer length
		syscall            			# read from file

# Close the file 
		li   	$v0, 16       		# system call for close file
		move 	$a0, $s6      		# file descriptor to close
		syscall            			# close file

#write from read file
		li 	 	$v0, 4              # system call for wait to write file
		la 	 	$a0, buffer         
		syscall						

#initial
		addi 	$t0, $zero, 0 		#$t0 = 0 
		addi 	$t1, $zero, 10		#$t1 = 10  #keep to mul
		addi 	$t2, $zero, 32		#$t2 = 32 (spacebar)
		la   	$t3, buffer			#$t3 = base address of buffer
		la 	 	$t4, number			#$t4 = base address of number
		addi 	$t6, $zero, 0		#$t6 = 0 (count number of array number)

split:
		lb	 	$t5, 0($t3)			#$t5 = char in buffer
		beq  	$t5, $0, endSplit	#if $t5 = NULL go to endSplit
		beq	 	$t5, $t2, spacebar 	#if $t5 = spacebar back to split 
		addi 	$t5, $t5, -48		#convert char to integer
		mul  	$t0, $t0, $t1 		#$t0 = 10*$t0
		add  	$t0, $t0, $t5		#$t0 = (10*$t0) + $t5
		addi 	$t3, $t3, 1 		#next char in buffer
		j 		split

spacebar:
		sw		$t0, 0($t4)			#store number in array number

		addi	$t3, $t3, 1 		#next char in buffer
		addi	$t4, $t4, 4 		#next char in array number
		addi	$t0, $zero, 0		#clear $t0
		addi	$t6	, $t6, 1   		#$t6 +=1
		j 		split

endSplit:
		
		sw		$t0, 0($t4)			#store number in array number
					
		addi	$t3, $t3, 1 		#next char in buffer
		addi	$t4, $t4, 4 		#next char in array number
		addi	$t0, $zero,0		#clear $t0
		addi	$t6, $t6, 1   		#$t6 +=1
		li		$v0, 4
		la      $a0, count
		syscall				 		#print string "count number"
		li 		$v0, 1
		move	$a0, $t6
		syscall						#print integer "count number : "
		addi 	$s6, $t6, 0			#$s6 = $t6 = count
		addi 	$s7, $s6, -1 		#$s7 = $s6-1 = count = count - 1
		####### SORT  #######
		 		jal 	sort 				#go to sort and comeback
		####### \SORT #######
		li 		$v0, 4 	
		la 		$a0, showSort	    # showSort show number bubble
		syscall						#print string Bubblesort " "
		la 		$t0, number 		#load address number to $t0
		add 	$t1,$zero,$zero 	#$t1=0

printArray:
		lw 		$a0, 0($t0) 		#a0 =[number of $t0]
		li 		$v0, 1
		syscall						#print integer
		li 		$v0, 4
		la 		$a0, msg
		syscall 					#print " " (spacebar between num)
		addi 	$t0, $t0, 4 		#next int in array
		addi 	$t1, $t1, 1 		#$t1+=1
		slt 	$t2, $s7, $t1 		# $t2 = 0 if $s7 < $t1
		beq 	$t2, $zero,printArray #$t2 = $zero go to printArray
		j 		endSort

sort: 
		la 		$a0, number 		#copy array number into $a0
		addi 	$a1, $s6, 0			#a1 = n
		addi 	$t0, $zero, 0		#i = 0

outerLoop:
		addi 	$t0, $t0, 1 		#i++
		bgt 	$t0, $a1, exit1		#if i>n go to exit1
		add 	$t1, $a1, $zero 	#j = n
innerLoop:
		bge 	$t0, $t1, outerLoop	#if i>=j go to outerLoop 
		addi	$t1, $t1, -1 		#j--
		mul 	$t4, $t1, 4 		#$t4 = j*4
		addi 	$t3, $t4, -4 		#$t3 = (j*4)-4
		add 	$t7, $t4, $a0 		#$t7 = &number[j]
		add 	$t8, $t3, $a0 		#$t8 = &number[j-1]
		lw 		$t5, 0($t7)			#$t5 = number[j]
		lw 		$t6, 0($t8)			#$t6 = number[j-1]
		bgt 	$t5, $t6, innerLoop #if $t5 > $t6 go to innerLoop
		sw 		$t5, 0($t8)			#$t8 = $t5  #swap
		sw 		$t6, 0($t7)			#$t7 = $t6  #swap
		j 		innerLoop

exit1:
		jr $ra

endSort:
        addi    $v0, $0, 13          	#$v0 = 13 open file
        la      $a0, fileout		    #address of null-terminated string containing outputfilename
        addi    $a1, $0, 1           	#$a1 = flags = 1 (1 for write-only)
        addi    $a2, $0, 0         		#$a2 = mode = 0
        syscall
        add     $s0, $v0, $0            #$s0 = $v0
        addi    $t6, $0, 10             #$t6 = 10
        addi    $t7, $0, 32            	#$t7 = 32 (spacebar)
        la      $t0, number             #load adress of array number to $t0
        mul 	$s6, $s6, 4 			#shift element 
        add     $t0, $t0, $s6           #move to last element
        la      $t5, number             #load adress of array to $t5
        addi    $sp, $sp, -1            #allocate stack pointer = 1 byte
        add     $s1, $sp, $0            #Keep $sp in $s1 so we can count number of item in stack
        sb      $0,  0($sp)             #write \0 to buffer

 
divide:
        beq     $t0, $t5,endDivide      #if(position after last element == number[i]) go to endDivide:
        addi    $sp, $sp, -1 			#allocate stack pointer = 1 byte
        sb      $t7, 0($sp)             #add space to stack pointer
        addi    $t0, $t0, -4            #go to previous element
        lw      $t1, 0($t0)

divideInner:          
        div     $t1, $t6                #$t1/10
        mflo    $t2						#$t2 = div 
        mult    $t2, $t6				#$t2 = (div*10)
        mflo    $t3						#$t3 = sum of div*10
        sub     $t4, $t1, $t3 			#$t4 = $t1- $t3(div*10)
        add     $t1, $0, $t2			#$t1 = $t2
        addi    $t4, $t4, 48 			#change integer to char 
        addi    $sp, $sp, -1 			#allocate stack pointer = 1 byte
        sb      $t4, 0($sp)				#save to stack
        beq     $t1, $0, divide         #if $t1(div) = 0 go to divide
        j       divideInner
 
endDivide:
        sub     $t0, $s1, $sp           # $t0 = $s1 - $sp
        addi    $v0, $0, 15             # $v0 = 15 (write to file)
        add     $a0, $0, $s0            # $a0 = file descriptor (drive:\...txt)
        add     $a1, $0, $sp            # $a1 = address of output buffer
        add     $a2, $0, $t0            # $a2 = number of characters to write
        syscall

        li   	$v0, 16       			# system call for close file
		syscall
		# Print Done!
        addi    $v0, $0, 4              # $v0 = 4 print string
        la      $a0, string_Done        # print BubbleSort Done!
        syscall   

Exit:
        
        addi    $v0, $0, 10             # exit (terminate execution)
        syscall