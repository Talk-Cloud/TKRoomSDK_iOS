//
//  TKAudioUtils.h
//  TKRoomSDK
//
//  Created by tuyuanyou on 2022/10/20.
//  Copyright © 2022 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKRoomDefines.h"
NS_ASSUME_NONNULL_BEGIN

@class TKAudioFrame;
@interface TKAudioInfo : NSObject
@property (nonatomic, assign) int bytes_per_sample;
@property (nonatomic, assign) int sample_rate;
@property (nonatomic, assign) int number_of_channels;
@property (nonatomic, assign) int number_of_frames;
@property (nonatomic, assign) TKSampleFormat format;
@end

@class TKAudioMixer;
@protocol TKAudioMixerOuputDelegate<NSObject>
-(void)mixedAudioOutput:(TKAudioMixer *)mixer outAudioFrame:(TKAudioFrame *)audioFrame;

@end

@interface TKAudioMixer : NSObject
- (instancetype)initWithDelegate:(id<TKAudioMixerOuputDelegate>)delegate audioInfo:(TKAudioInfo *)audioInfo;
- (int)addSource:(NSString *)sid;
- (int)removeSource:(NSString *)sid;
- (int)receiveData:(NSString *)sid audioFrame:(TKAudioFrame *)audioFrame;
@end




NS_ASSUME_NONNULL_END
