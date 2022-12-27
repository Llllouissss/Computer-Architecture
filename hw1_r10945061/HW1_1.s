#----------------------------------------------------Do not modify below text----------------------------------------------------
.data
  str1: .string "This is HW1_1:\nBefore sorting: \n"
  str2: .string "\nAfter sorting:\n"
  str3: .string "  "
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
  li s2,0 #int i = 0
  li s3,9
  j loop2#jump to loop2

loop2:
  li s4,0 #int y = 0
  addi s2,s2,1 #else jump to i++ and jump to loop1
  beq a3,s2,exit2 #if a3 < i go to exit2
  j loop1
loop1:
  beq s3, s4 ,loop2 #if a3 == y go to loop2
  slli s8,s4,3 #s8 =  y * 8
  add s8,a2,s8 #s8 = y*8 + base address
  addi s4,s4,1 #y = y + 1
  ld s10,0(s8) #load s11 = box[y]
  ld s11,8(s8) #load s10 = box[y+1]
  ble s10,s11 ,loop1 # if box[y] < box[y+1] then pass, if not then swap
  sd s11,0(s8) #save s10 = box[y]
  sd s10,8(s8) #save s11 = box[y+1]
  j loop1
exit2:
  jr ra








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
