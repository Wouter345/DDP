import helpers
import HW
import SW

import sys




operation = 0
seed = "random"

seed = 2023
M = helpers.getModulus(1024)
A = helpers.getRandomInt(1024) % M
B = helpers.getRandomInt(1024) % M

C = SW.MontMul(A, B, M)
D = HW.MontMul(A, B, M)

e = (C - D)
print("in_a    <= 1024'h", str(hex(A))[2:], ";")  # 1024-bits
print("in_b    <= 1024'h", str(hex(B))[2:], ";")  # 1024-bits
print("in_m    <= 1024'h", str(hex(M))[2:], ";")  # 1024-bits
print("expected <= 1024'h", str(hex(D))[2:], ";")
print("(A*B*R^-1) mod M = ", hex(C))  # 102

print ("TEST VECTOR GENERATOR FOR DDP\n")

if len(sys.argv) in [2,3,4]:
  if str(sys.argv[1]) == "adder":           operation = 1
  if str(sys.argv[1]) == "subtractor":      operation = 2
  if str(sys.argv[1]) == "multiplication":  operation = 3
  if str(sys.argv[1]) == "exponentiation":  operation = 4
  if str(sys.argv[1]) == "rsa":             operation = 5

if len(sys.argv) in [3,4]:
  print ("Seed is: ", sys.argv[2], "\n")
  seed = sys.argv[2]
  helpers.setSeed(sys.argv[2])

if len(sys.argv) == 4:
  if (sys.argv[3].upper() == "NOWRITE"):
    print ("NOT WRITING TO TESTVECTOR.C FILE \n")

#####################################################

if operation == 0:
  print ("You should use this script by passing an argument like:")
  print (" $ python testvectors.py adder")
  print (" $ python testvectors.py subtractor")
  print (" $ python testvectors.py multiplication")
  print (" $ python testvectors.py exponentiation")
  print (" $ python testvectors.py rsa")
  print ("")
  print ("You can also set a seed for randomness to work")
  print ("with the same testvectors at each execution:")
  print (" $ python testvectors.py rsa 2023")
  print ("")
  print ("To NOT write to testvector.c file automatically: ")
  print (" $ python testvectors.py rsa 2023 nowrite")
  print ("")

#####################################################

if operation == 1:
  print ("Test Vector for Multi Precision Adder\n")

  A = helpers.getRandomInt(1027)
  B = helpers.getRandomInt(1027)
  C = HW.MultiPrecisionAddSub_1027(A,B,"add")

  print ("A                = ", hex(A))           # 1027-bits
  print ("B                = ", hex(B))           # 1027-bits
  print ("A + B            = ", hex(C))           # 1028-bits

#####################################################

if operation == 2:
  print ("Test Vector for Multi Precision Subtractor\n")

  A = helpers.getRandomInt(1027)
  B = helpers.getRandomInt(1027)
  C = HW.MultiPrecisionAddSub_1027(A,B,"subtract")

  print ("A                = ", hex(A))           # 1027-bits
  print ("B                = ", hex(B))           # 1027-bits
  print ("A - B            = ", hex(C))           # 1028-bits

#####################################################

if operation == 3:

  print ("Test Vector for Windoed Montgomery Multiplication\n")

  M = helpers.getModulus(1024)
  A = helpers.getRandomInt(1024) % M
  B = helpers.getRandomInt(1024) % M

  C = SW.MontMul(A, B, M)
  D = HW.MontMul(A, B, M)

  e = (C - D)

  print ("A                = ", hex(A))           # 1024-bits
  print ("B                = ", hex(B))           # 1024-bits
  print ("M                = ", hex(M))           # 1024-bits
  print ("(A*B*R^-1) mod M = ", hex(C))           # 1024-bits
  print ("(A*B*R^-1) mod M = ", hex(D))           # 1024-bits
  print ("error            = ", hex(e))

#####################################################

if operation == 4:

  print ("Test Vector for Montgomery Exponentiation\n")

  X = helpers.getRandomInt(1024)
  E = helpers.getRandomInt(8)
  M = helpers.getModulus(1024)
  C = HW.MontExp_MontPowerLadder(X, E, M)
  D = helpers.Modexp(X, E, M)
  e = C - D
  
  print("alignas(128) uint32_t N[32] 	= {", WriteConstants(M), "};")
  print("alignas(128) uint32_t e[32] 	= {", WriteConstants(E), "};") 
  print("alignas(128) uint32_t M[32] 	= {", WriteConstants(X), "};")
  print("alignas(128) uint32_t exp[32]  = {", WriteConstants(C), "};")


  print ("X                = ", hex(X))           # 1024-bits
  print ("E                = ", hex(E))           # 8-bits
  print ("M                = ", hex(M))           # 1024-bits
  print ("(X^E) mod M      = ", hex(C))           # 1024-bits
  print ("(X^E) mod M      = ", hex(D))           # 1024-bits

  print ("error            = ", hex(e))

#####################################################



print ("Test Vector for RSA\n")

target1 = open("../sw_project/src/sw/tests.c", 'w')
target1.truncate()
target1.write(
"#include <stdint.h>                                              \n" +
"#include <stdalign.h>                                            \n" +
"                                                                 \n" +)

target2 = open("../sw_project/src/sw/tests.h", 'w')
target2.truncate()
target2.write(
  "# ifndef tests_    \n" +
  "# define tests_    \n" +
  "# include <stdint.h>   \n")



loops = 50
for i in range(loops):
  seed = seed + i

  [p,q,N] = helpers.getModuli(1024)
  [e,d] = helpers.getRandomExponents(p,q)
  M     = helpers.getRandomMessage(1024,N)
  Ct = SW.MontExp(M, e, N)                        # 1024-bit exponentiation
  R    = 2**1024
  R_N  = R % N
  R2_N = (R*R) % N

  target1.write(
  "alignas(128) uint32_t N"+str(i)+"[32]       = {" + WriteConstants(N,32) + "};           \n" +
  "alignas(128) uint32_t e"+str(i)+"[32]       = {" + WriteConstants(e,1) + "};            \n" +
  "alignas(128) uint32_t e_len"+str(i)+"       = 16;                                       \n" +
  "alignas(128) uint32_t d"+str(i)+"[32]       = {" + WriteConstants(d,32) + "};           \n" +
  "alignas(128) uint32_t d_len"+str(i)+"       =  " + str(int(math.log(d, 2)) + 1) + ";    \n" +
  "alignas(128) uint32_t M"+str(i)+"[32]       = {" + WriteConstants(M,32) + "};           \n" +
  "alignas(128) uint32_t Ct"+str(i)+"[32]      = {" + WriteConstants(Ct,32) + "};          \n" +
  "alignas(128) uint32_t R_N"+str(i)+"[32]     = {" + WriteConstants(R_N ,32) + "};        \n" +
  "alignas(128) uint32_t R2_N"+str(i)+"[32]    = {" + WriteConstants(R2_N,32) + "};        \n" )

  target1.write(
  "extern uint32_t N"+str(i)+"[32];\n" +
  "extern uint32_t e"+str(i)+"[32];\n" +
  "extern uint32_t e_len"+str(i)+";\n" +
  "extern uint32_t d"+str(i)+"[32];\n" +
  "extern uint32_t d_len"+str(i)+";\n" +
  "extern uint32_t M"+str(i)+"[32];\n" +
  "extern uint32_t Ct"+str(i)+"[32];\n" +
  "extern uint32_t R_N"+str(i)+"[32];\n" +
  "extern uint32_t R2_N"+str(i)+"[32];\n" )

target1.write("uint32_t *listN["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("N"+str(i)+", ")
target1.write("N"+str(loops-1)+"};\n")

target1.write("uint32_t *liste["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("e"+str(i)+", ")
target1.write("e"+str(loops-1)+"};\n")

target1.write("uint32_t *liste_len["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("e_len"+str(i)+", ")
target1.write("e_len"+str(loops-1)+"};\n")

target1.write("uint32_t *listd["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("d"+str(i)+", ")
target1.write("d"+str(loops-1)+"};\n")

target1.write("uint32_t *listd_len["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("d_len"+str(i)+", ")
target1.write("d_len"+str(loops-1)+"};\n")

target1.write("uint32_t *listM["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("M"+str(i)+", ")
target1.write("M"+str(loops-1)+"};\n")

target1.write("uint32_t *listCt["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("Ct"+str(i)+", ")
target1.write("Ct"+str(loops-1)+"};\n")

target1.write("uint32_t *listR_N["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("R_N"+str(i)+", ")
target1.write("R_N"+str(loops-1)+"};\n")

target1.write("uint32_t *listR2_N["+str(loops)+"] = {")
for i in range(loops-1):
    target1.write("R2_N"+str(i)+", ")
target1.write("R2_N"+str(loops-1)+"};\n")

target2.write("extern uint32_t *listN["+str(loops)+"], *liste["+str(loops)+"], *liste_len["+str(loops)+"], *listd["+str(loops)+"], *listd_len["+str(loops)+"], *listM["+str(loops)+"], *listCt["+str(loops)+"], *listR_N["+str(loops)+"], *listR2_N["+str(loops)+"];")
target2.write( "\n# endif /* tests_ */    \n")

target1.close()
target2.close()





