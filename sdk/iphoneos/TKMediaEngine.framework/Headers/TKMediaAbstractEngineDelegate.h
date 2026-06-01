//
//  TKMediaDelegate.h
//  TKMedia
//
//  Created by MAC-MiNi on 2018/9/1.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TKMediaEngine/TKMediaDefines.h>
@class TKMediaAbstractEngine;

@protocol TKMediaAbstractEngineDelegate<NSObject>

@optional
- (void)mediaEngine:(TKMediaAbstractEngine *)mediaEngine
onPeerConnectionError:(NSError *)error
       connectionId:(NSString *)connectionId;
 
- (void)mediaEngine:(TKMediaAbstractEngine *)mediaEngine
   onOfferGenerated:(NSString *)sdp
       connectionId:(NSString *)connectionId;

- (void)mediaEngine:(TKMediaAbstractEngine *)mediaEngine
     onIceCandidate:(NSString *)sdp
                mid:(NSString *)mid
              mline:(NSInteger)mline
       connectionId:(NSString *)connectionId;

- (void)mediaEngine:(TKMediaAbstractEngine *)mediaEngine
 onIceStatusChanged:(TKIceConnectionState)state
       connectionId:(NSString *)connectionId;

- (void)mediaEngine:(TKMediaAbstractEngine *)mediaEngine onRemoteStreamAdded:(NSString *)connectionId;
- (void)mediaEngine:(TKMediaAbstractEngine *)mediaEngine onRemoteStreamRemoved:(NSString *)connectionId;

//第一帧视频
- (void)mediaEngine:(TKMediaAbstractEngine *)media
  onFirstVideoFrame:(NSString *)connectionId
           deviceId:(NSString *)deviceId
               type:(TKMediaType_M)type
              width:(NSInteger)width
             height:(NSInteger)height;


//视频画面状态回调
- (void)mediaEngine:(TKMediaAbstractEngine *)media
       onVideoState:(NSString *)connectionId
           deviceId:(NSString *)deviceId
               type:(TKMediaType_M)type
              state:(TKRenderState_M)state;

//第一帧音频
- (void)mediaEngine:(TKMediaAbstractEngine *)media
  onFirstAudioFrame:(NSString *)connectionId
               type:(TKMediaType_M)type;


//远端音频状态回调
- (void)mediaEngine:(TKMediaAbstractEngine *)media
       onAudioState:(NSString *)connectionId
               type:(TKMediaType_M)type
              state:(TKRenderState_M)state;

// 远端音量大小
- (void)mediaEngine:(TKMediaAbstractEngine *)media
onRemoteAudioVolume:(NSInteger)vol
               type:(TKMediaType_M)type
       connectionId:(NSString *)connectionId;

- (void)mediaEngine:(TKMediaAbstractEngine *)media onWarning:(TKRoomWarningCode)code;
- (void)mediaEngine:(TKMediaAbstractEngine *)media onError:(NSError *)error;


- (void)mediaEngine:(TKMediaAbstractEngine *)media
   videoSizeChanged:(NSString *)connectionId
           deviceId:(NSString *)deviceId
               type:(TKMediaType_M)type
              newSize:(CGSize)size;
- (void)mediaEngine:(TKMediaAbstractEngine *)media onSnapshotComplete:(NSString *)connectionId iamge:(UIImage *)image;

// 点播播放器专用
- (void)mediaEngine:(TKMediaAbstractEngine *)media onPlayEvent:(TKVodPlayEventID)event;

@end

@protocol TKMediaEngineDelegate<TKMediaAbstractEngineDelegate>
@optional
/// 本地采集音频数据
- (void)mediaEngine:(TKMediaAbstractEngine *)media
onCaptureVideoFrame:(TKVideoFrame *)packet
               type:(TKMediaType_M)type;
/// 本地采集视频数据
- (void)mediaEngine:(TKMediaAbstractEngine *)media
onCaptureAudioFrame:(TKAudioFrame *)packet
               type:(TKMediaType_M)type;

/// 远端视频数据
- (void)mediaEngine:(TKMediaAbstractEngine *)media
 onRenderVideoFrame:(TKVideoFrame *)packet
           deviceId:(NSString *)deviceId
               type:(TKMediaType_M)type
       connectionId:(NSString *)connectionId;

/// 远端音频数据
- (void)mediaEngine:(TKMediaAbstractEngine *)media
 onRenderAudioFrame:(TKAudioFrame *)packet
               type:(TKMediaType_M)type
       connectionId:(NSString *)connectionId;
// 本地音量大小
- (void)mediaEngine:(TKMediaAbstractEngine *)media onMicVolumeReport:(NSInteger)volume;

//播放媒体共享视频时，画面开始加载回调
- (void)mediaEngineForShareMediaHasLoaded:(TKMediaAbstractEngine *)media;

//混音output
- (void)mixedAudioOutput:(void *)data bits_per_sample:(int)bits_per_sample sample_rate:(int)sample_rate num_channels:(size_t)num_channels num_frames:(size_t)num_frames;

- (void)muteStreamWithExtensionId:(NSString *)extensionId muteVideo:(BOOL)video muteAudio:(BOOL)audio;

@end





