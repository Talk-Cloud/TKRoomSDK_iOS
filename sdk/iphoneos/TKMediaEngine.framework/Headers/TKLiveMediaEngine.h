//
//  TKLiveMedia.h
//  TKMediaEngine
//
//  Created by 涂远友 on 2024/11/15.
//  Copyright © 2024 MAC-MiNi. All rights reserved.
//

#import <TKMediaEngine/TKMediaAbstractEngine.h>

NS_ASSUME_NONNULL_BEGIN




@interface TKLiveMediaEngine : TKMediaAbstractEngine

@property(nonatomic, readonly) dispatch_queue_t workerQueue;
@property(nonatomic, readonly, assign) BOOL playing;

- (int)startPlayFFMPEGStream:(TKMediaFileParams *)params onStart:(TKLocalMediaState_block_m)startBlock onComplete:(TKLocalMediaState_block_m)completeBlock onProgress:(TKLocalMediaProgress_block_m)progress connectionId:(NSString *)connectionId;
- (void)stopPlayFFMPEGStream:(int)playID;
- (void)setSpeed:(int)playID speed:(float)speed;
- (void)setMirror:(int)playID mirror:(BOOL)mirror;
- (void)muteFFmpegVideo:(int)playID mute:(BOOL)mute;
- (void)muteFFmpegAudio:(int)playID mute:(BOOL)mute;
- (void)setFFmpegRenderMode:(int)playID mode:(TKRenderMode_M)mode;
- (void)setFFMPEGRenderRotation:(int)playID rotation:(TKVideoRotation)rotation;
- (void)setFFMPEGRenderView:(int)playID window:(UIView * _Nullable)view;
- (void)snapshotForFFMPEGRender:(int)playID;

- (void)setWebrtcRenderMode:(NSString *)connectionId mode:(TKRenderMode_M)mode;
- (void)setWebRTCRenderRotation:(NSString *)connectionId rotation:(TKVideoRotation)rotation;

- (void)snapshotForWebrtcRender:(NSString *)connectionId;


+ (TKMediaFileInfo * _Nullable)getMediaInfo:(NSString *)filePath;
- (void)setVodStartPos:(CGFloat)startPos;
@end

NS_ASSUME_NONNULL_END
