#include <stdint.h>                                              
#include <stdalign.h>                                            
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = 2023                    
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
alignas(128) uint32_t N[32]       = {0x912e1e2f, 0xc1f06b24, 0x8d3f9e56, 0xcef43abc, 0x253e440a, 0x3c3d2eb8, 0xdafd0041, 0xf900c8d5, 0x128231ba, 0xf0d8e538, 0x99f97a72, 0xfcf27ded, 0x6c0b751b, 0xa9b80afa, 0x3d357f44, 0xace43bc1, 0xf6f4e5ff, 0xcb7228f3, 0xe008a50e, 0x2b813ca2, 0xe7b04c6f, 0xa37e8f0e, 0x6eedf3d1, 0xab5e4270, 0xc8db9d8c, 0xc29972f1, 0x1bb5c5be, 0x73547e1f, 0xef2f2ad0, 0x8d8cda95, 0xa26f6aec, 0x88275122};           
                                                                              
// encryption exponent                                                        
alignas(128) uint32_t e[32]       = {0x0000b25b};            
alignas(128) uint32_t e_len       = 16;                                       
                                                                              
// decryption exponent, reduced to p and q                                    
alignas(128) uint32_t d[32]       = {0x2edc6c13, 0xb2aabb61, 0x33f01fdb, 0x1f15a11a, 0x4cc576bb, 0xd5640241, 0x408ac545, 0x7fdb1f7d, 0x5fd40a21, 0x5e68559c, 0x2d25ba29, 0xb48181bf, 0xf963341c, 0xaba93c2d, 0x168dda38, 0x2fe82277, 0x4e9fff6d, 0x68f2d98d, 0xb6152f52, 0x0020f2fa, 0x58454aa1, 0xdfe6cb93, 0x405ae6fc, 0xfa988080, 0xcf8c43b7, 0x965b6ad0, 0xca037764, 0x4a1598ed, 0x352d761c, 0xae4186f3, 0x81b913f1, 0x0a482541};           
alignas(128) uint32_t d_len       =  1020;    
                                                                              
// the message                                                                
alignas(128) uint32_t M[32]       = {0x8cfaf516, 0x1c00a4b3, 0x6d9dfbf4, 0x383b41d6, 0xd82ecd15, 0xb297ead2, 0xb98da1b8, 0xa908a8ce, 0xffdd1ac3, 0x198b399b, 0x0f7165db, 0x1d356cec, 0x2d77cb76, 0x889c1e65, 0x7a1be3af, 0xf0d6b5fe, 0x33919ac3, 0x2bcb2029, 0xe6d807b3, 0xdfca847a, 0xe1153ee9, 0x5d3893f2, 0x4e893d93, 0x7af925bc, 0xb1c38b99, 0xff602732, 0x36ac29be, 0x96762410, 0xf786757a, 0xcc67164e, 0x77db111e, 0x804e95f2};           
                                                                              
// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32]     = {0x6ed1e1d1, 0x3e0f94db, 0x72c061a9, 0x310bc543, 0xdac1bbf5, 0xc3c2d147, 0x2502ffbe, 0x06ff372a, 0xed7dce45, 0x0f271ac7, 0x6606858d, 0x030d8212, 0x93f48ae4, 0x5647f505, 0xc2ca80bb, 0x531bc43e, 0x090b1a00, 0x348dd70c, 0x1ff75af1, 0xd47ec35d, 0x184fb390, 0x5c8170f1, 0x91120c2e, 0x54a1bd8f, 0x37246273, 0x3d668d0e, 0xe44a3a41, 0x8cab81e0, 0x10d0d52f, 0x7273256a, 0x5d909513, 0x77d8aedd};        
alignas(128) uint32_t R2_N[32]    = {0x0731a102, 0xa4a4631e, 0xb0cce884, 0x271c2b60, 0xfae04600, 0x5df93b59, 0x56759703, 0xbc5ca3a2, 0x4354c707, 0x6ebd4dea, 0xbc4324aa, 0x726965ea, 0x5aa843a0, 0xa6a66802, 0x7d0f93f9, 0xb90c227e, 0x7ad501ec, 0xdc35be5f, 0x9272ebbf, 0x58b1fb17, 0xfdc212eb, 0x22c54049, 0xeb096b0b, 0xc59d3503, 0x1badd008, 0x2e8da771, 0xfc40eb69, 0xe4850545, 0x707d152a, 0xda26e7ad, 0x3b74e208, 0x7c4581b3};        
