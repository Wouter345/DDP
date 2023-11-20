#include <stdint.h>                                              
#include <stdalign.h>                                            
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = 5                    
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
alignas(128) uint32_t N[32]       = {0x7be27301, 0xcf753be0, 0x7e1ff69f, 0xa6a56faf, 0x8fe319d5, 0x75968442, 0x64a982ad, 0x146e959d, 0x7ac28727, 0xbc57f003, 0xcf2178f0, 0x7394e6ff, 0x4d8e059a, 0x488296c0, 0x225fc45a, 0x781a8909, 0xb94f9751, 0x66f08a12, 0xae6aa880, 0x4bb954cf, 0xcce4974b, 0x5039b2fb, 0x73a80fad, 0xa8acdfaf, 0x00d8431c, 0x03459733, 0xcf6bd6a5, 0xdc61f6b4, 0x637f7fcf, 0xddca8251, 0x02cc548f, 0xa830bb48};           
                                                                              
// encryption exponent                                                        
alignas(128) uint32_t e[32]       = {0x0000d265};            
alignas(128) uint32_t e_len       = 16;                                       
                                                                              
// decryption exponent, reduced to p and q                                    
alignas(128) uint32_t d[32]       = {0x8f2f132d, 0x773a0d89, 0x33044e7f, 0x5a68be95, 0xc199c595, 0x763a816f, 0x1bf41d8b, 0x7598a5c3, 0x150866b0, 0x10a8641c, 0xf25e6ed3, 0x892813ae, 0x7b2b8329, 0x05d0ee94, 0x90cd4eba, 0x8e5f0a6a, 0xb67ef421, 0xc5abebd1, 0x8bc028f7, 0xb3098367, 0x7b7c636a, 0xf8da276e, 0x481d0896, 0x37396cc2, 0xce77a20b, 0xadcf6e57, 0x4519131a, 0x832736c0, 0x6915b7f3, 0x6574efa2, 0x117029a9, 0x5e3ed499};           
alignas(128) uint32_t d_len       =  1023;    
                                                                              
// the message                                                                
alignas(128) uint32_t M[32]       = {0x67e47e3c, 0x07adbfd4, 0x110bdd5b, 0x0d7803f2, 0xbbad2e2a, 0xfc71e15e, 0xb54968e7, 0xabc270a0, 0x0f48ed7a, 0x02c2876d, 0xf35a434d, 0xf79522c6, 0xae653700, 0xbc8c99bb, 0x6e2bf205, 0x3e09e51b, 0xbccff9a1, 0x6f1da9b2, 0x0936a448, 0x0163d155, 0xcbc8ce9a, 0x4df63edf, 0xff9bf394, 0x6215457d, 0xa173a795, 0xb01af73a, 0xf7418a4d, 0x25b1f5b3, 0x6f67ffff, 0x6cf28757, 0xa9bacaca, 0x9ef48c97};           
                                                                              
// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32]     = {0x841d8cff, 0x308ac41f, 0x81e00960, 0x595a9050, 0x701ce62a, 0x8a697bbd, 0x9b567d52, 0xeb916a62, 0x853d78d8, 0x43a80ffc, 0x30de870f, 0x8c6b1900, 0xb271fa65, 0xb77d693f, 0xdda03ba5, 0x87e576f6, 0x46b068ae, 0x990f75ed, 0x5195577f, 0xb446ab30, 0x331b68b4, 0xafc64d04, 0x8c57f052, 0x57532050, 0xff27bce3, 0xfcba68cc, 0x3094295a, 0x239e094b, 0x9c808030, 0x22357dae, 0xfd33ab70, 0x57cf44b7};        
alignas(128) uint32_t R2_N[32]    = {0x8b8c99f2, 0xe8111b6f, 0x77fbce09, 0x75fddfd8, 0xe3fe8cf5, 0x119a833b, 0x72d49ed9, 0x1d9132f8, 0x64ed76e7, 0x01f8c153, 0x1434442f, 0xbddb44e5, 0xab9254f5, 0x03494c5a, 0xf9ecc577, 0xb84b1ed9, 0x5107bf02, 0x4a2b2429, 0x3ad31f82, 0x73ccb679, 0x2e4dff28, 0x180e5b50, 0xfae1bcb6, 0xfae6d340, 0x790ad245, 0x4c68c24f, 0x97310d0d, 0x673f4b26, 0xa71ef683, 0xebd26c8e, 0x3e954b42, 0x3c002a04};        
