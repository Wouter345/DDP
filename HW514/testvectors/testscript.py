import helpers
import HW
import SW

import sys

def WriteConstants(number):

    wordLenInBits = 32

    charlen = wordLenInBits >> 2

    text   = hex(number)

    # Remove unwanted characters 0x....L
    if text[-1] == "L":
        text = text[2:-1]
    else:
        text = text[2:]
 
    while (len(text)%4):
        text = "0"+text
    
    
    # Split the number into word-bit chunks
    text   = text.zfill(len(text) + len(text) % charlen)  
    # result = ' '.join("0x"+text[i: i+charlen]+"," for i in range(0, len(text), charlen)) 
    result = ' '.join("0x"+text[i: i+charlen]+"," for i in reversed(range(0, len(text), charlen))) 

    # Remove the last comma
    result = result[:-1]

    return result


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
"                                                                 \n" +);

loops = 50;
for i in range(loops)


[p,q,N] = helpers.getModuli(1024)
[e,d] = helpers.getRandomExponents(p,q)
M     = helpers.getRandomMessage(1024,N)
Ct = SW.MontExp(M, e, N)                        # 1024-bit exponentiation
R    = 2**1024
R_N  = R % N
R2_N = (R*R) % N










"// modulus                                                       \n" +
"alignas(128) uint32_t N[32]       = {" + WriteConstants(N,32) + "};           \n" +
"                                                                              \n" +
"// encryption exponent                                                        \n" +
"alignas(128) uint32_t e[32]       = {" + WriteConstants(e,1) + "};            \n" +
"alignas(128) uint32_t e_len       = 16;                                       \n" +
"                                                                              \n" +
"// decryption exponent, reduced to p and q                                    \n" +
"alignas(128) uint32_t d[32]       = {" + WriteConstants(d,32) + "};           \n" +
"alignas(128) uint32_t d_len       =  " + str(int(math.log(d, 2)) + 1) + ";    \n" +    
"                                                                              \n" +
"// the message                                                                \n" +
"alignas(128) uint32_t M[32]       = {" + WriteConstants(M,32) + "};           \n" +
"alignas(128) uint32_t Ct[32]      = {" + WriteConstants(Ct,32) + "};          \n" +
"                                                                              \n" +
"// R mod N, and R^2 mod N, (R = 2^1024)                                       \n" +
"alignas(128) uint32_t R_N[32]     = {" + WriteConstants(R_N ,32) + "};        \n" +
"alignas(128) uint32_t R2_N[32]    = {" + WriteConstants(R2_N,32) + "};        \n" )

target.close()





