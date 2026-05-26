//
//  GenerateUserSig.h
//  talkSDKDemo
//
//  Created by 涂远友 on 2025/1/9.
//  Copyright © 2025 beijing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GenerateUserSig : NSObject
+ (NSString *)AES128_CBCEncryptWithKey:(NSString *)keyString iv:(NSString *)ivString encrypt:(NSString *)encryptString;

@end

NS_ASSUME_NONNULL_END
