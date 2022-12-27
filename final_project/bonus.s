.data
    n: .word 11
.text
.globl __start


jal x0, __start
#----------------------------------------------------Do not modify above text----------------------------------------------------
FUNCTION:
# Todo: Define your own function
# We store the input n in register a0, and you should store your result in register a1
   addi t6,x0,11
   addi t4,x0,0 
   addi t3,x0,2
resc:
    addi t4,t4,1
    addi sp, sp, -12
    sw x1, 4(sp)
    sw x10, 0(sp)
    sw x13, 8(sp)
    slti x5, x10, 1
    beq x5, x0, testpart
    
testpart:
    bge x10,t6,MoreThanTen
    beq x10,x0,LT
    jal OneToNine
LT:
    addi x10, x0, 7
    jal LAST
    
MoreThanTen:
    addi t5,x10,0
    slli x13,x10,3  #x13= 0.875n-137
    sub  x13,x13,x10
    srai x13,x13,3
    addi x13,x13,-137
    
    slli x10,x10,2
    sub  x10,x10,t5
    srai x10,x10,2
   
    jal x1, resc
    
    
OneToNine:
    addi x10,x10,-1
    add  x13,x0,x0
    jal x1, resc
    
LAST:addi x6, x10, 0
    addi t3,t3,1
    lw x10, 0(sp)
    lw x1, 4(sp)
    lw x13, 8(sp)
    addi sp, sp, 12
    slli x10, x6, 1
    add  x10,x10,x13
    bge t4,t3,LAST
    add a1,a0,x0
    jal END
    
  
END:
    auipc x6, 0
    jalr x0, x6, 24
    







#----------------------------------------------------Do not modify below text----------------------------------------------------
__start:
    la   t0, n
    lw   a0, 0(t0)
    jal  x1, FUNCTION
    la   t0, n
    sw   a1, 4(t0)
    li a7, 10
    ecall
