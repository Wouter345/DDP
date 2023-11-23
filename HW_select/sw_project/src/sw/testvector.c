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
alignas(128) uint32_t N[32]       = {0xbdcaa551, 0xa3fed5ec, 0x04c12020, 0x4ae9cacf, 0xecc4cb36, 0x0f6012d9, 0xee441baf, 0x403f7482, 0x3a3e80c9, 0x153ce2ae, 0x670db890, 0x007d88b9, 0x3a2db29d, 0x3a66adae, 0x795aeae9, 0xe81f9807, 0x4efaba62, 0xe8fd5167, 0x926449a2, 0xc0fa706f, 0x847f327f, 0xca94afa0, 0xedc7fdde, 0xf92e6e1d, 0x84e27d53, 0xf46b6ead, 0x6fd34a5d, 0xee69fe59, 0x032249f2, 0x0d066a2e, 0xd598e046, 0x8871ad3a};           
                                                                              
// encryption exponent                                                        
alignas(128) uint32_t e[32]       = {0x0000a6c9};            
alignas(128) uint32_t e_len       = 16;                                       
                                                                              
// decryption exponent, reduced to p and q                                    
alignas(128) uint32_t d[32]       = {0xe43d48f9, 0x72cce918, 0x7703e885, 0xd3893d24, 0xf4eadb23, 0x91ad0a2e, 0x975222e9, 0xfcf4a940, 0x85ab6865, 0x7132a842, 0x843ef407, 0xa2fba212, 0xe6913b51, 0x2ba7f728, 0x21df3725, 0xfb0c9519, 0x1d68c9e8, 0x2701b87d, 0xded64b1d, 0x24541619, 0xaf7c6065, 0x62940c55, 0xbe302afc, 0xcaf8f015, 0x542cce71, 0x18e9022b, 0x277a9995, 0x8b7c6a45, 0x1f9e48f4, 0x4e03ae8b, 0x28d839be, 0x49364643};           
alignas(128) uint32_t d_len       =  1023;    
                                                                              
// the message                                                                
alignas(128) uint32_t M[32]       = {0x5d20342a, 0x83930c41, 0x820425d1, 0x439c0857, 0x35e455cf, 0xf35ed093, 0xc85c1b4f, 0x123e8933, 0x822b05be, 0xc37e8cd5, 0x1e6e899a, 0x5ed8baac, 0xfbcb972e, 0x356f7ec8, 0x659f7cc9, 0xa19aa82e, 0x001c52bc, 0x517e85ec, 0xbabe8f21, 0x1f9fb7b3, 0xde8b214b, 0xdb9ca41e, 0xa73a4761, 0x77f9507d, 0x6c842e03, 0x9e39a1d7, 0x6d7ee865, 0x15c11824, 0x88343a87, 0xfcb0c4b9, 0x19b57d24, 0x84d06020};           
alignas(128) uint32_t Ct[32]      = {0x8a9093b6, 0xb7f1f337, 0xbe880200, 0x802dd5b8, 0xb4d430b7, 0xefeaf014, 0xba5dd264, 0x281b39f1, 0x0760cb4e, 0xb19217bd, 0x8f738d14, 0x72b4690f, 0x815f4b5f, 0xf62419d9, 0xddcfcf04, 0xda99650c, 0x8ca3b5ee, 0xff4c1b22, 0x6e34a315, 0xead43403, 0xf014caff, 0xd2537b90, 0x1b6858a6, 0xfc6636e3, 0xb53fa177, 0x6f13d817, 0x9eb21949, 0xb9f021c8, 0x4e849cb8, 0x74af86d3, 0x4a1d28f7, 0x130d6f82};          
                                                                              
// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32]     = {0x42355aaf, 0x5c012a13, 0xfb3edfdf, 0xb5163530, 0x133b34c9, 0xf09fed26, 0x11bbe450, 0xbfc08b7d, 0xc5c17f36, 0xeac31d51, 0x98f2476f, 0xff827746, 0xc5d24d62, 0xc5995251, 0x86a51516, 0x17e067f8, 0xb105459d, 0x1702ae98, 0x6d9bb65d, 0x3f058f90, 0x7b80cd80, 0x356b505f, 0x12380221, 0x06d191e2, 0x7b1d82ac, 0x0b949152, 0x902cb5a2, 0x119601a6, 0xfcddb60d, 0xf2f995d1, 0x2a671fb9, 0x778e52c5};        
alignas(128) uint32_t R2_N[32]    = {0x69c0fd33, 0xbb1b24ad, 0x2cb8ac75, 0x5d144fa7, 0xa5078797, 0x4f415d7b, 0xf3b38f17, 0x32a25bb6, 0x03c6597c, 0xa446761e, 0x430c6d63, 0x6e935bdd, 0xf0a44f79, 0x9ef42707, 0x0e5d9101, 0x14e105e0, 0x7d0e5aad, 0x11a1473f, 0x3bad1091, 0x016a3c84, 0x0086ae34, 0xdd539797, 0x871e72be, 0x4922c850, 0xbb58924c, 0x87fdb29c, 0x701b3d19, 0xff57094e, 0xf306fc38, 0x2782986b, 0xfd20abc3, 0x6ef7ff6b};        
