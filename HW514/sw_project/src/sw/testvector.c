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
                                                                 
alignas(128) uint32_t N[32] 	= { 0xc677823d, 0xc771a7c2, 0xd96e1505, 0xae99b304, 0x1d1b5b57, 0x74e5dab4, 0xab72ad57, 0x7eabd01a, 0x6443890a, 0x6d138a62, 0xd908ad14, 0xd74c5d5d, 0xdc4df7c0, 0xc0cbee16, 0xd9917d50, 0x95b65c8a, 0xd7bb9c75, 0x6a2fd6e7, 0x2419e74f, 0xb943a41b, 0x1530eb09, 0x0fb28dbf, 0xdb482e16, 0x154bdc9e, 0x2442b812, 0x72b890a3, 0xc59cd6df, 0xddc25e1e, 0x955c0aec, 0xbec377a8, 0x06082b0e, 0xa4e2010b };
alignas(128) uint32_t e[32] 	= { 0x000000eb };
alignas(128) uint32_t M[32] 	= { 0x7a6e75f5, 0x7a65f040, 0x0b537e7c, 0xae2ab026, 0x1df61006, 0x6eec116e, 0xdb4ffcbb, 0x61606436, 0x4aed030c, 0xe66c6e84, 0x01b93e63, 0x08fdf525, 0x0057075f, 0x846b5047, 0x38bfb937, 0xce30bc07, 0xfc8ae892, 0x81ac18e0, 0x8404ee9d, 0x3ad04559, 0xaec4e479, 0x80a47c1a, 0xb2b32f50, 0x24884a4e, 0x162be86a, 0x145e268c, 0x938b5cba, 0x2f6d9bb2, 0x7d55c70b, 0xd956c29d, 0x4b791291, 0xea132c16 };
alignas(128) uint32_t exp[32]  = { 0x14d4f5de, 0xc2aad492, 0x8b4fda1a, 0x61065d12, 0x57695121, 0x7d031ea4, 0x3d5bf503, 0xf297288f, 0x3a4d5167, 0x0ca0e6b0, 0xa460671c, 0xae46d52a, 0x9453dcca, 0x12124c86, 0x70b489b7, 0x92013432, 0x3268f570, 0x3198154d, 0x1bcb1aff, 0x0e5944cf, 0xeb8babd1, 0x4d5c57d5, 0x6edcb26e, 0x458b716f, 0xab947e93, 0x0d69f416, 0x40f1dccb, 0x9c5c19e2, 0x5b6df958, 0xe2ca3b1e, 0x421d34c4, 0x491240bb };

alignas(128) uint32_t e_len       = 8;
                                                                              
                                                                              

// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32] 	= { 0x39887dc3, 0x388e583d, 0x2691eafa, 0x51664cfb, 0xe2e4a4a8, 0x8b1a254b, 0x548d52a8, 0x81542fe5, 0x9bbc76f5, 0x92ec759d, 0x26f752eb, 0x28b3a2a2, 0x23b2083f, 0x3f3411e9, 0x266e82af, 0x6a49a375, 0x2844638a, 0x95d02918, 0xdbe618b0, 0x46bc5be4, 0xeacf14f6, 0xf04d7240, 0x24b7d1e9, 0xeab42361, 0xdbbd47ed, 0x8d476f5c, 0x3a632920, 0x223da1e1, 0x6aa3f513, 0x413c8857, 0xf9f7d4f1, 0x5b1dfef4 };
alignas(128) uint32_t R2_N[32] 	= { 0x7856d908, 0x985bce02, 0x6cb37e97, 0x9ac36b2f, 0x27255f75, 0x39986044, 0xda24d36d, 0x3130eb6f, 0xd8835764, 0x258af5fd, 0xe3c51e51, 0x7677f29a, 0x41fc93ca, 0x03ea5215, 0x9e2c64eb, 0xa1cec872, 0x30892e2c, 0x01dd79a7, 0xaa586a47, 0x7d3e6998, 0x97a4f6fa, 0x4759ede3, 0x8f836b86, 0xb8195963, 0x155cf364, 0x457dae49, 0xd56d521b, 0xadce671b, 0x9098098d, 0xc7439f68, 0x14a91171, 0x85f3b8aa };
