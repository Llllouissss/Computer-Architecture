.data
  str1: .string	"This is HW1_2: With size "
  str2: .string	" * "
  str3: .string	"\nBefore:\n"
  str4: .string	"Result:\n"
  str5: .string	"\t"
  str6: .string	"\n"
 
# Modify here to change the size of testing case (Remember that the size you should submit is 128x128)
# 7*7 input
data_i: .dword 172, 47, 117, 192, 67, 251, 195
        .dword 103, 9, 211, 21, 242, 36, 87
        .dword 70, 216, 88, 140, 58, 193, 230
        .dword 39, 87, 174, 88, 81, 165, 25
        .dword 77, 72, 9, 148, 115, 208, 243
        .dword 197, 254, 79, 175, 192, 82, 99
        .dword 216, 177, 243, 29, 147, 147, 142
data_o: .dword 0:25 #initiate 25 dwords with value 0
data_size: .dword 7, 7
######

buffer: .dword 0:9

.globl main

.text

#----------------------------------------------------Do not modify below text----------------------------------------------------
main:
  # Main function loop parameters setting
  la t0, data_size
  ld s2, 0(t0)				# rows
  ld s3, 8(t0)				# cols

  # Print initiate
  li a7, 4
  la a0, str1
  ecall
  li a7, 1
  mv a0, s2
  ecall
  li a7, 4
  la a0, str2
  ecall
  li a7, 1
  mv a0, s3
  ecall
  li a7, 4
  la a0, str3
  ecall

  # Print function
  # a1 stores print address, a2 stores the row length, and a3 stores the col length
  la a1, data_i
  mv a2, s2					# data_i rows
  mv a3, s3					# data_i cols
  jal prints				# print data
#----------------------------------------------------Do not modify above text----------------------------------------------------
### Start your code here ###













#----------------------------------------------------Do not modify below text----------------------------------------------------
ends:
  # Print str4
  li a7, 4
  la a0, str4
  ecall
  # Print function
  # a1 stores print address, a2 stores the row length, and a3 stores the col length
  la a1, data_o
  addi a2, s2, -2			# data_o rows
  addi a3, s3, -2			# data_o cols
  jal prints				# print data

  # Done, terminate program
  li a7, 10				# terminate
  ecall					# system call

# Print function
prints:
  addi sp, sp, -32
  sd ra, 24(sp)
  sd s3, 16(sp)
  sd s2, 8(sp)
  sd s1, 0(sp)
  # a1 stores print address, a2 stores the row length, and a3 stores the col length
  mv s1, a1
  mv s2, a2
  mv s3, a3
  li t0, 0				# for(i=0)
printforloop1:
  bge t0, s2, printexit1		# if ( i>=row ) jump to printexit1
  li t1, 0				# for(j=0)
printforloop2:
  bge t1, s3, printexit2		# if ( j>=col ) jump to printexit2
  li a7, 1				# print_int
  ld t2, 0(s1)
  mv a0, t2
  ecall
  li a7 4
  la a0, str5
  ecall
  addi s1, s1, 8			# Move to next memory address(8 bytes)
  addi t1, t1, 1			# j = j + 1
  j printforloop2
printexit2:
  li a7, 4
  la a0, str6
  ecall
  addi t0, t0, 1			# i = i + 1
  j printforloop1
printexit1:
  ld s1, 0(sp)
  ld s2, 8(sp)
  ld s3, 16(sp)
  ld ra, 24(sp)
  addi sp, sp, 32
  jr ra
#----------------------------------------------------Do not modify above text----------------------------------------------------