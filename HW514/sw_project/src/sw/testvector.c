#include <stdint.h>                                              
#include <stdalign.h>                                            
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = 1                    
//                                                               
//  The variables are defined for the RSA                        
// encryption and decryption operations. And they are assigned   
// by the script for the generated testvector. Do not create a   
// new variable in this file.                                    
//                                                               
// When you are submitting your results, be careful to verify    
// the test vectors created for seeds from 2023.1, to 2023.5     
// To create them, run your script as:                           
//   $ python testvectors.py rsa 2023.1                          
                                                                 
// modulus                                                       
alignas(128) uint32_t N[32]       = {0x3e2f45f5, 0x452ad0e8, 0x677fde03, 0x3f8eb8d4, 0x3221ca48, 0xa2ec8644, 0xdcdf4eb5, 0x8684489a, 0x225dbf12, 0x064ab43b, 0x0b1f8357, 0x8d67e83c, 0xf4a4bc7f, 0xd0753167, 0x31b2aacf, 0xc6ee42ce, 0x5c2e04d1, 0xa945c284, 0xbf33a9e5, 0x64d22cd1, 0x8169d97f, 0xb6c4e5a3, 0x1a436c47, 0xc6e438e3, 0xfecea9e2, 0x23b8b961, 0xa4809d2f, 0x8a98bd7d, 0x4dac96c0, 0x7448a711, 0x344a1298, 0xacb9027a};           
                                                                              
// encryption exponent                                                        
alignas(128) uint32_t e[32]       = {0x0000c49d};            
alignas(128) uint32_t e_len       = 16;                                       
                                                                              
// decryption exponent, reduced to p and q                                    
alignas(128) uint32_t d[32]       = {0xfcdbeded, 0x5200baaf, 0xedfebb26, 0xe8dd4968, 0xc370e966, 0xf50f8f1e, 0xe3fd13e6, 0x76e772c1, 0x1ba49712, 0xeb6f7684, 0x7dd2d1db, 0x619af549, 0x239c560d, 0xdb676c9d, 0x410efbc2, 0x5f2d8daa, 0x2e7b0a74, 0x15d8b745, 0xe9a83c93, 0xec088d87, 0xd20a694a, 0x6a557ad6, 0x62fd50fa, 0xd226a110, 0xaa2c7ea9, 0x6cc3f9c7, 0xd50ede62, 0xafcc794a, 0xa4ce0823, 0xf981e537, 0xa0f0b750, 0x04d6ab8d};           
alignas(128) uint32_t d_len       =  1019;    
                                                                              
// the message                                                                
alignas(128) uint32_t M[32]       = {0x26194661, 0x2ac08b73, 0xdb3aa464, 0x009d07c8, 0x0afc7d82, 0x2a30a776, 0x36b71b43, 0xc5da963d, 0x8513bbc9, 0xba37ed96, 0x276857c7, 0xda73e6d5, 0x50e85b3d, 0x87360fa9, 0x6b8d17e5, 0x22d8268e, 0x1d08210e, 0x14aa7141, 0x2b4446da, 0x6a05c8b6, 0x16a76b1f, 0x1a7710cc, 0xf4a35c61, 0xd5c1d270, 0x7d96a773, 0x1b60c8a9, 0x38cfed5f, 0xb8a151cc, 0xf7b49b29, 0xe26f0760, 0x1e76d7c6, 0x9b100bc2};           
                                                                              
// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32]     = {0xc1d0ba0b, 0xbad52f17, 0x988021fc, 0xc071472b, 0xcdde35b7, 0x5d1379bb, 0x2320b14a, 0x797bb765, 0xdda240ed, 0xf9b54bc4, 0xf4e07ca8, 0x729817c3, 0x0b5b4380, 0x2f8ace98, 0xce4d5530, 0x3911bd31, 0xa3d1fb2e, 0x56ba3d7b, 0x40cc561a, 0x9b2dd32e, 0x7e962680, 0x493b1a5c, 0xe5bc93b8, 0x391bc71c, 0x0131561d, 0xdc47469e, 0x5b7f62d0, 0x75674282, 0xb253693f, 0x8bb758ee, 0xcbb5ed67, 0x5346fd85};        
alignas(128) uint32_t R2_N[32]    = {0xb3bb74c3, 0xcbf8b2b7, 0x61fe52c8, 0xb521970b, 0xb9dcafdc, 0x1a414b89, 0xaeffdeb7, 0x4900d61c, 0xdb828575, 0x781ece83, 0xd229fdc2, 0xfd7481cd, 0x2d9e3346, 0x06a79212, 0x08a50277, 0x50909458, 0xb885bf30, 0xc38a2ca0, 0x4d1fef32, 0x9ceffdba, 0x5ce21446, 0xeaf0c22e, 0x93ddaf39, 0xdabb21f4, 0x1b357248, 0x62975ddf, 0xf9d3cb7e, 0x8e3fe612, 0x7f5ff718, 0x2fcf320e, 0xb9113bcb, 0x4fed4e9a};        
