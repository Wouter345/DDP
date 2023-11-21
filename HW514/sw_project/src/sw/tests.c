#include <stdint.h>                                              
#include <stdalign.h>                                            
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = 2025                    
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
alignas(128) uint32_t N[32]       = {0x1cc4bac9, 0x42279a9e, 0xbe3c466f, 0xac1745ab, 0x2331616e, 0x85b22cd9, 0x24edc72a, 0x2f51615f, 0x826ee902, 0xd993e796, 0x0d706aad, 0x4d0162f9, 0x0aa87b15, 0xc1bf5cec, 0xd734d596, 0xd058d642, 0x14aad918, 0xbe9e0d35, 0xd8a4588a, 0x23e4b6ea, 0x4adca974, 0x571104c3, 0xac3fef49, 0xbf83bc1d, 0xdd7a498a, 0xf011d641, 0xc68beee9, 0xb46e37c9, 0x526a03ee, 0x106be38a, 0xf5a6ae4f, 0x941f7645};           
                                                                              
// encryption exponent                                                        
alignas(128) uint32_t e[32]       = {0x0000bab5};            
alignas(128) uint32_t e_len       = 16;                                       
                                                                              
// decryption exponent, reduced to p and q                                    
alignas(128) uint32_t d[32]       = {0x52537bad, 0x57a27f20, 0xa7c7f66b, 0xa8e49b24, 0x02bf72be, 0xacaea30b, 0x5cf3e42a, 0xb4faf95d, 0xd9c4c987, 0x432173ea, 0x61001c0e, 0x0a97186f, 0xa40a8672, 0x5b065fe6, 0xae6b7893, 0x87fa4c75, 0xe55ad9a1, 0xec9dfd6c, 0xcadaf762, 0x00e880ee, 0x175f8806, 0x14d12979, 0x3569f50a, 0x512c249b, 0xf70958f6, 0xb634bb33, 0x12dc14e1, 0xfb3eebfc, 0xe4742bcf, 0x8fa16db3, 0x4432443d, 0x3d59098f};           
alignas(128) uint32_t d_len       =  1022;    
                                                                              
// the message                                                                
alignas(128) uint32_t M[32]       = {0x2d19f476, 0x6f0ae6eb, 0x30a411a5, 0x114b9c2f, 0xc7a95b45, 0xd975ceeb, 0xb6e3c4d9, 0xb6886b83, 0x3244d50b, 0x3eba3128, 0x6fafe513, 0x97b3fc43, 0x20f63f81, 0x71025b25, 0xfbb8b861, 0x5c2d821b, 0xb8b72f92, 0xdc058282, 0x97061177, 0xf09a674a, 0x349fd8c5, 0xb595e972, 0x6b39cfb5, 0x4291d720, 0xcefb39c0, 0x3718790c, 0xf78cf00e, 0xc046aa88, 0x339776c2, 0xf7ee99e8, 0x00df1893, 0x8e1c9a58};           
alignas(128) uint32_t Ct[32]      = {0x3c3ef060, 0x8c359aef, 0x53c8a17c, 0x4fa52051, 0x7ac52de6, 0x13616fbc, 0x63bf564e, 0x8df89e00, 0xf4c9ae3a, 0x6fd714d1, 0x0f4ad736, 0x205c624c, 0xa94b21e1, 0x4604184f, 0x1eb58f2a, 0xdfd14b8e, 0xa99e7ac8, 0xa8dfd00c, 0xc6ee917f, 0x5303992e, 0x2f561b7e, 0xad7e2134, 0xb4fcac0c, 0x42655020, 0x1b8df469, 0x2bbaf99d, 0xf493d397, 0x6386018f, 0xa813f446, 0x8b98a292, 0xdc52ca40, 0x1c5c3b0f};          
                                                                              
// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32]     = {0xe33b4537, 0xbdd86561, 0x41c3b990, 0x53e8ba54, 0xdcce9e91, 0x7a4dd326, 0xdb1238d5, 0xd0ae9ea0, 0x7d9116fd, 0x266c1869, 0xf28f9552, 0xb2fe9d06, 0xf55784ea, 0x3e40a313, 0x28cb2a69, 0x2fa729bd, 0xeb5526e7, 0x4161f2ca, 0x275ba775, 0xdc1b4915, 0xb523568b, 0xa8eefb3c, 0x53c010b6, 0x407c43e2, 0x2285b675, 0x0fee29be, 0x39741116, 0x4b91c836, 0xad95fc11, 0xef941c75, 0x0a5951b0, 0x6be089ba};        
alignas(128) uint32_t R2_N[32]    = {0x1f6ae52f, 0x3571876d, 0x543143c5, 0xee4baf4e, 0x41bc9458, 0x061fbf44, 0x96edee54, 0x0ea7d98b, 0x31f8084e, 0xf4454c74, 0xcf835903, 0x47b52c6e, 0x7ad526f1, 0x445a9003, 0x0f821437, 0x177375c1, 0x551e31de, 0xef03d070, 0xb35492f6, 0x173b9d72, 0x7a64ba83, 0xdf97542a, 0x232c900e, 0xbb4fc4a8, 0x63f10cba, 0x78d485b1, 0xb67da14b, 0x51c352a9, 0x3d8e3681, 0x97bb8367, 0x7f2ebddb, 0x8bea113c};        
