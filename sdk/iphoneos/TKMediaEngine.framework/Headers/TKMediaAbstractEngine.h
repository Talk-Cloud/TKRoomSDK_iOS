//
//  TKMediaEngine.h
//  TKMediaEngine
//
//  Created by 涂远友 on 2024/11/15.
//  Copyright © 2024 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <TKMediaEngine/TKMediaDefines.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TKOfferType) {
    TKOfferType_Send,
    TKOfferType_Receive
};
typedef NSString *TKEngineUniqueID;

@interface TKMediaAbstractEngine : NSObject
@property (nonatomic, copy) TKEngineUniqueID uniqueID;
- (instancetype)init NS_UNAVAILABLE;

- (void)generateOffer:(NSString *)connectionId type:(TKOfferType)type streamId:(NSString *)streamId;
- (void)processAnswer:(NSString *)connectionId sdpDes:(NSString *)sdp;

- (void)deleteConnection:(NSString *)connectionId;

- (BOOL)enableAudio:(NSString *)connectionId;
- (BOOL)enableVideo:(NSString *)connectionId;
- (void)enableAudio:(NSString *)connectionId enable:(BOOL)enable;
- (void)enableVideo:(NSString *)connectionId  enable:(BOOL)enable;
- (void)setVolume:(NSString *)connectionId volume:(CGFloat)volume;


- (int)playVideo:(NSString *)connectionId canvas:(TKVideoCanvas *)canvas enableDualStream:(BOOL)enable completion:(void (^)(NSError *error))completion;
- (void)unplayVideo:(NSString *)connectionId enableDualStream:(BOOL)enable completion:(void (^)(NSError *error))completion;

- (void)playAudio:(NSString *)connectionId enableDualStream:(BOOL)enable;
- (void)unplayAudio:(NSString *)connectionId enableDualStream:(BOOL)enable;


//播放媒体音视频文件
- (int)startPlayMediaFile:(NSString *)filePath
                   window:(UIView *)window
                     loop:(BOOL)loop
                userAgent:(NSString * _Nullable)useragent
                 progress:(TKLocalMediaProgress_block_m _Nullable)progress;
- (int)startPlayMediaFile:(TKMediaFileParams *)mediaParam
                userAgent:(NSString * _Nullable)useragent
                  onStart:(TKLocalMediaState_block_m _Nullable)startBlock
               onProgress:(TKLocalMediaProgress_block_m _Nullable)progressBlock
               onComplete:(TKLocalMediaState_block_m _Nullable)completeBlock;
- (void)stopPlayMediaFile:(int)playID;
- (int)pausePlayMedia:(int)playID;
- (int)resumePlayMedia:(int)playID;
- (int)seekPlayMedia:(int)playID pos:(double)pos;
- (int)setPlayMediaVolume:(CGFloat)volume playID:(int)playID;

- (void)createAIAuioPlayer:(NSString *)player_extID;
- (void)writeAIAuioDataAndPlay:(NSString *)player_extID audioDataInfo:(NSDictionary *)audioDataInfo;
- (void)AIAudioPlayerStopPlay:(NSString *)player_extID immediate:(BOOL)immediate;

- (void)getStatsForTrack:(void (^_Nullable)(TKVideoStats * _Nullable vStats, TKAudioStats * _Nullable aStats, NSDictionary * _Nullable googRemoteAddress, NSString * _Nullable extensionId, BOOL videoEnable))completionHandler;

- (void)destroy;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
