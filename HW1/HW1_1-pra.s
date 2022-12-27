#----------------------------------------------------Do not modify below text----------------------------------------------------
.data
  str1: .string	"This is HW1_1:\nBefore sorting: \n"
  str2: .string	"\nAfter sorting:\n"
  str3: .string	"  "
  num: .dword  10, -2, 4, -7, 6, 9, 3, 1, -5, -8

.globl main

.text
main:
  # Print initiate
  li a7, 4
  la a0, str1
  ecall
  
  # a2 stores the num address, a3 stores the length of  num
  la a2, num
  li a3, 10
  jal prints
  
  la a2, num
  li a3, 10
  jal sort
  
  # Print result
  li a7, 4
  la a0, str2
  ecall

  la a2, num
  li a3, 10
  jal prints
  
  # End the program
  li a7, 10
  ecall
#----------------------------------------------------Do not modify above text----------------------------------------------------
sort:
### Start your code here ###

  
  addi a5,zero,0  # int i = 0
  jal zero, for1list # jump to loop1
  jr ra
  
  
for1list:
  addi a6, a5, 0 # int y = i
  ble a5, a3, for2list #if i >= size exit or i < exit and go to loop2
  addi a5,a5,1 # i = i + 1
  bgt a3,a5 for1list# another loop1

for2list:
  addi a7,a2,0 #s11 address
  bge a6, a3, exit2 #if y
  lw s5, 0(a7)#load string[y]
  lw s6, 8(a7)#load string[y+1]
  bge s6, s5, pass #if string[y+1] > string[y] then pass
  slli s9,a6,3 #address s9 = y*8
  add s9, a2 , s9 #s9 = a2 + s9
  sw s6,0(s9)
  sw s5,8(s9)
  addi a6,a6,1 #y = y + 1
  addi s11,s11, 8
  bge a3, a6, for2list #another loop2
pass:
  addi a6,a6,1
  jal ra,for2list
swap:
  slli s9,a6,3 # s9 = y * 8
  add s9, a2, s9# s9 = a2 + s9
  lw s11, 0(s9)
  lw s10, 8(s9)
  sw s6, 0(s9)
  sw s5, 8(s9)
  jal for2list
  
    
exit1:

exit2:



  
  




#----------------------------------------------------Do not modify below text----------------------------------------------------
# Print function	
prints:
  mv t0, zero # for(i=0)
  # a2 stores the num address, a3 stores the length of  num
  mv t1, a2 
  mv t2, a3
printloop:
  bge t0, t2, printexit # if ( i>=length of num ) jump to printexit 
  slli t4, t0, 3
  add t5, t1, t4
  lw t3, 0(t5)
  li a7, 1 # print_int
  mv a0, t3
  ecall
	
  li a7, 4
  la a0, str3
  ecall 
	
  addi t0, t0, 1 # i = i + 1
  j printloop
printexit:
  jr ra
#----------------------------------------------------Do not modify above text----------------------------------------------------
