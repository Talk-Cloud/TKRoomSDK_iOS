//
//  TKMedia.h
//  TKMedia
//
//  Created by MAC-MiNi on 2018/8/31.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <TKMediaEngine/TKMediaAbstractEngine.h>
@class TKRender;

NS_ASSUME_NONNULL_BEGIN
@interface TKMediaEngine : TKMediaAbstractEngine
@property (strong, nonatomic) TKVideoProfile *videoProfile;
@property (assign, nonatomic) BOOL audioHighQuality;

- (instancetype)init NS_UNAVAILABLE;
- (void)configAudioExt;
- (void)disableEncryption:(BOOL)disableEncryption;
// 设置 speaker 静音
- (int)setSpeakerMute:(BOOL)enable;
- (void)setLocalID:(NSString *)localId;
// 录制音频
- (int)startAudioRecord:(NSString *)sandboxPath recordInfo:(TKAudioRecordInfo *)recordInfo;
- (int)pauseAudioRecord:(BOOL)pause;
- (int)stopAudioRecord;

- (void)selectCameraPosition:(BOOL)isFront;
- (void)setLocalVideoProfile:(TKVideoProfile *)profile completeBlock:(void (^)(BOOL isChange))completeBlock;
- (void)setScreenRecordProfile:(TKVideoProfile *)profile;

//- (void)configFieldTrial;
//- (BOOL)enableBuiltInAGC:(BOOL)enable;
//- (BOOL)bypassVoiceProcessing:(BOOL)bypass;
//- (BOOL)enableAEC:(BOOL)enable;
//- (BOOL)enableNS:(BOOL)enable;
//- (BOOL)setNSLevel:(int)level;

- (int)setRemoteVideoMirror:(BOOL)mirror extensionId:(NSString *)extensionId;

//多码流 
- (void)openSmallStream;
- (void)closeSmallStream;
- (void)setSmallVideoProfile:(TKVideoProfile *)profile;
- (void)setRemoteDefaultVideoStreamType:(TKVideoStreamType_M)streamType;
- (void)setRemoteVideoStreamType:(TKVideoStreamType_M)streamType extensionId:(NSString *)extensionId completion:(void(^)(TKVideoStreamType_M type))completion;
- (void)updateStreamTypeToBigWithPeerId:(NSString *)peerId audioId:(NSString *)audioId;
- (void)updateStreamTypeToSmallWithExtensionId:(NSString *)extensionId audioId:(NSString *)audio_extensionId;

//todo
- (void)setLocalVideoMirrorMode:(TKVideoMirrorMode_M)mode;
- (void)startVideoTest:(TKVideoCanvas *)canvas isFront:(BOOL)isFront;
- (void)stopVideoTest;
- (void)pauseMediafile:(NSString *)extensionId pause:(BOOL)pause;

- (int)previewLocalVideo:(TKVideoCanvas *)canvas completion:(void (^)(NSError *error))completion;
- (void)cancelPreviewLocalVideo:(void (^)(NSError *error))completion;

- (void)publishStream;
- (void)unpublishStream;

- (void)updateStreamForVideo:(BOOL)video audio:(BOOL)audio;


- (BOOL)isCreatePeerConnection:(NSString *)connectionId;
- (NSArray *)getAllPeerConnectionIDs;

- (int)setVideoCapturerOrientation:(UIDeviceOrientation)orientation;



- (void)disableLocalVideo:(BOOL)disable;
- (void)disableLocalAudio:(BOOL)disable;
- (BOOL)isEnableVideoForConnection:(NSString *)connectionId;
- (BOOL)isEnableAudioForConnection:(NSString *)connectionId;

//播放mp3文件
- (int)startPlayAudioFile:(NSString *)filePath loop:(BOOL)loop progress:(TKLocalMediaProgress_block_m)progress;
- (void)stopPlayAudioFile:(int)audioId;
- (int)pauseAudioFile:(int)audioId;
- (int)resumeAudioFile:(int)audioId;
- (BOOL)setAudioFileVolume:(CGFloat)volume soundId:(int)audioId;


- (void)startShareScreen;
- (void)stopShareScreen;
- (void)pushScreenSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end


@interface TKMediaEngine (RTC)
 
- (void)setVideoMaxBitrateBps:(NSInteger)maxBitrateBps;
- (void)setVideoMinBitrateBps:(NSInteger)minBitrateBps;
- (void)setScreenMaxBitrateBps:(NSInteger)maxBitrateBps;

@end

NS_ASSUME_NONNULL_END
