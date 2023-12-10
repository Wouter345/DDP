#include <stdint.h>                                              
#include <stdalign.h>                                            
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = 2023.1                    
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
alignas(128) uint32_t N[32]       = {0x136ba197, 0x5cc8c1f0, 0x7c1acca5, 0x9142c2a6, 0x828b555e, 0xf78598fe, 0x36c8b5ac, 0x99eed4d4, 0xa56ae76d, 0x67dfee41, 0xe75322e4, 0xbbae7a62, 0x7899a396, 0x8be331bb, 0x15009df1, 0xf1ed3d2f, 0x0e10f2b4, 0xeed54fd2, 0x665ebcae, 0x8447604d, 0x0008cc62, 0xd158b14e, 0xc2c34c74, 0x439fc610, 0xac868316, 0x590fe5ba, 0x27e13f29, 0xb951d50f, 0xd9b41178, 0x08c3de09, 0x646359ec, 0x8fe1855a};           
                                                                              
// encryption exponent                                                        
alignas(128) uint32_t e[32]       = {0x0000cb99};            
alignas(128) uint32_t e_len       = 16;                                       
                                                                              
// decryption exponent, reduced to p and q                                    
alignas(128) uint32_t d[32]       = {0xaa5dd901, 0x64170500, 0x13aaee79, 0x1c65949b, 0x43780419, 0x825dc182, 0x07f0ca91, 0x4b0cbeac, 0xd737c077, 0x818e2f92, 0xf2b4021a, 0x4205bd33, 0xf67beab8, 0xf2c12718, 0x16316213, 0xeb92d82b, 0xd46be298, 0xc0a24e86, 0x4821f61c, 0x36dd4891, 0x168e019c, 0x971b14e6, 0xed2c2873, 0x4b646436, 0xde7c7ad5, 0x4490a9f6, 0x71cc0a9d, 0x447f5fbe, 0x96f4ee89, 0xb792e35e, 0x400b7a9f, 0x5407037f};           
alignas(128) uint32_t d_len       =  1023;    
                                                                              
// the message                                                                
alignas(128) uint32_t M[32]       = {0x53f761aa, 0xd12e0e25, 0x46086c4c, 0x9d1fdda1, 0x4fcc7120, 0x25a9552d, 0xfc322064, 0x355a86aa, 0x63792f6a, 0x49bcc17f, 0xaa5b92b2, 0x16935911, 0xfc59253d, 0xd91a79b1, 0x38c02076, 0x2ec4be4c, 0x696dc333, 0x0485cd50, 0xf9f43b76, 0xd3328ab5, 0x9b00b297, 0xf668703e, 0x65897b32, 0xfe50c0eb, 0xd94d52d4, 0x04d96aa4, 0xee41d4cd, 0xda14bfc4, 0xa106171a, 0x09e772f3, 0x038245d8, 0x8a436cd2};           
alignas(128) uint32_t Ct[32]      = {0x82af12e9, 0x7468da88, 0x080948d4, 0x60c25781, 0xff9fab46, 0xe8abfbc7, 0x161efc54, 0x7b544cac, 0xef4cd919, 0x2c5b3e81, 0x9d000d5b, 0x6396e51f, 0x9cbbba61, 0xa299dcc4, 0x9330a6d7, 0xb227e9db, 0x76e5d3d6, 0x44b149fb, 0x0913ca5b, 0x839e1d41, 0x3f726281, 0x5ef8fe85, 0x27602e8a, 0x1137cc85, 0x7a01bf58, 0xc888fb0e, 0xbfdd0ae3, 0x035ac74a, 0x13e42820, 0xcb699718, 0xd621f287, 0x8ca56468};          
                                                                              
// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32]     = {0xec945e69, 0xa3373e0f, 0x83e5335a, 0x6ebd3d59, 0x7d74aaa1, 0x087a6701, 0xc9374a53, 0x66112b2b, 0x5a951892, 0x982011be, 0x18acdd1b, 0x4451859d, 0x87665c69, 0x741cce44, 0xeaff620e, 0x0e12c2d0, 0xf1ef0d4b, 0x112ab02d, 0x99a14351, 0x7bb89fb2, 0xfff7339d, 0x2ea74eb1, 0x3d3cb38b, 0xbc6039ef, 0x53797ce9, 0xa6f01a45, 0xd81ec0d6, 0x46ae2af0, 0x264bee87, 0xf73c21f6, 0x9b9ca613, 0x701e7aa5};        
alignas(128) uint32_t R2_N[32]    = {0x8d625b41, 0xb1bfeefc, 0x36c792c9, 0x4e0d8b2c, 0xc036690c, 0x46691034, 0xbacd2873, 0xc344d31f, 0x851f9bb9, 0xee5f796f, 0xefbab701, 0x731a36e1, 0x90a02ed1, 0x716b65ed, 0x6e95cfd9, 0x7435645c, 0xa6b64c69, 0x2adf23e2, 0xe6d98c4e, 0x3f052494, 0x63a273f2, 0xf790a186, 0x1e17283a, 0x007cea91, 0x27832edb, 0xce4f8847, 0x62a51e91, 0x887d268b, 0x8e5929f8, 0x14899dfe, 0x62f2b574, 0x349c6426};        
