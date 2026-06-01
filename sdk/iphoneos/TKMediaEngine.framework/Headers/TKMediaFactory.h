//
//  TKMediaFactory.h
//  TKMediaEngine
//
//  Created by 涂远友 on 2024/9/2.
//  Copyright © 2024 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TKMediaEngine/TKMediaAbstractEngineDelegate.h>
NS_ASSUME_NONNULL_BEGIN

@class TKDeviceManager;
@class TKMediaEngine;
@class TKLiveMediaEngine;

@class TKMediaFactory;
@protocol TKMediaFactoryDelegate <NSObject>



@end

@interface TKMediaFactory : NSObject
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shareInstance;
+ (BOOL)destroy;

@end

@interface TKMediaFactory(TKMediaEngine)

- (TKMediaEngine *)createMediaEngineWithMediaDelegate:(id<TKMediaEngineDelegate>)mediaDelegate;
- (TKMediaEngine *)mediaEngine;
- (void)destroyMediaEngine;

@end

@interface TKMediaFactory(TKLiveEngine)

- (TKLiveMediaEngine *)createLiveEngineWithDelegate:(id<TKMediaAbstractEngineDelegate>)delegate;
- (TKLiveMediaEngine *)getLiveEngine:(NSString *)engineUniqueID;
- (void)destroyLiveEngine:(NSString *)engineUniqueID;

@end

@interface TKMediaFactory(TKDevice)
- (TKDeviceManager *)deviceManager;

@end

@interface TKMediaFactory(TKLog)
- (void)uploadLogServiceWithExtends:(TKLoggerExtends *)extends;
- (void)setLogInfo:(TKLogInfo *)logInfo;
@end

NS_ASSUME_NONNULL_END
