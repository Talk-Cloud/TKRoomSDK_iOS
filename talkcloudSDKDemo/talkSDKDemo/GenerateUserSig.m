//
//  GenerateUserSig.m
//  talkSDKDemo
//
//  Created by 涂远友 on 2025/1/9.
//  Copyright © 2025 beijing. All rights reserved.
//

#import "GenerateUserSig.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation GenerateUserSig
+ (NSString *)AES128_CBCEncryptWithKey:(NSString *)keyString iv:(NSString *)ivString encrypt:(NSString *)encryptString {
    if (!encryptString || encryptString.length == 0) {
        return nil;
    }
    NSData *iv = [ivString dataUsingEncoding:kCFStringEncodingUTF8];
    NSData *key = [keyString dataUsingEncoding:kCFStringEncodingUTF8];
    NSData *encryptData = [encryptString dataUsingEncoding:kCFStringEncodingUTF8];
    
    if (key.length != 16) {
        NSLog(@"Error:AES-128密钥长度必须为16位");
        return nil;
    }
    if (ivString.length != 16) {
        NSLog(@"Error:IV向量长度必须为16位");
        return nil;
    }
    
    NSString *result = nil;
    size_t bufferSize = encryptData.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    if (!buffer) return nil;
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key.bytes,
                                          key.length,
                                          iv.bytes,
                                          encryptData.bytes,
                                          encryptData.length,
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        NSData *tmp = [[NSData alloc] initWithBytes:buffer length:encryptedSize];
        result = [tmp base64EncodedStringWithOptions:0];
        free(buffer);
        return result;
    } else {
        free(buffer);
        return nil;
    }
}
@end
