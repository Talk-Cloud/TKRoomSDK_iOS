//
//  TKDeviceManager.h
//  TKRoomSDK
//
//  Created by tuyuanyou on 2022/8/19.
//  Copyright © 2022 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <TKMediaEngine/TKMediaDefines.h>

NS_ASSUME_NONNULL_BEGIN
@class TKVideoCanvas;

@interface TKAudioDeviceProfile : NSObject
@property (nonatomic, assign) BOOL disableAGC;
@property (nonatomic, assign) TKAudioQuality audioQuality;
@end

@interface TKDeviceManager : NSObject
@property (nonatomic, strong, readonly) TKAudioDeviceProfile *defaultAudioProfile;
@property (nonatomic, assign) BOOL enableSimulatedCapture;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

- (void)requestAduioDeviceAuthorizationWithCompletionHandler:(void (^)(BOOL granted))handler;
- (void)requestVideoDeviceAuthorizationWithCompletionHandler:(void (^)(BOOL granted))handler;
- (void)destroy;

@end

@interface TKDeviceManager(TKAudioDevice)

- (void)configAudioDeviceProfile:(TKAudioDeviceProfile *)audioDeviceProfile;
- (void)startActive;
- (void)setLoudSpeaker:(BOOL)loud;
- (BOOL)isEnableLoudSpeaker;

- (void)checkAudioVolume;

+ (AVAudioSessionPortDescription *)getCurrentAudioInputRoute;
+ (AVAudioSessionPortDescription *)getCurrentAudioOutputRoute;

+ (CGFloat)outputVolume;

@end

@interface TKDeviceManager(TKVideoDevice)
/// 是否支持缩放
@property (nonatomic, assign, readonly) BOOL isCameraZoomSupported;
/// 最小缩放值
@property (nonatomic, assign, readonly) CGFloat minZoomFactor;
/// 最大缩放值
@property (nonatomic, assign, readonly) CGFloat maxZoomFactor;

/// 获取当前相机名称
- (NSString *)getCurrentVideoInput;

/**
 * 设置摄像头缩放比例
 *
 * @param zoomFactor 摄像头缩放比例。取值范围从 1.0 到最大缩放比例；你可以通过 maxZoomFactor 方法获取设备支持的最大缩放比例。
 * @note 如果retrun值 返回-1，表示失败。
 */
- (int)setCameraZoomFactor:(CGFloat)zoomFactor;

/**
 * 测试视频设备
 *
 * @param canvas  承载视频画面的控件
 * @param frontCamera YES：前置摄像头；NO：后置摄像头。
 * @note 如果retrun值 返回-2，表示多次调用startVideoTest，需在startVideoTest之前调用stopVideoTest。
 */
- (int)startVideoTest:(TKVideoCanvas *)canvas isFront:(BOOL)frontCamera;
- (void)stopVideoTest;
@end

NS_ASSUME_NONNULL_END

