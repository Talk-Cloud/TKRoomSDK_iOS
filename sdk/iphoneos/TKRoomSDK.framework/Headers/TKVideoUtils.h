//
//  TKVideoUtils.h
//  TKRoomSDK
//
//  Created by tuyuanyou on 2023/6/16.
//  Copyright © 2023 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKRoomDefines.h"

NS_ASSUME_NONNULL_BEGIN
#define TKRenderView UIView

@class TKVideoFrame;
@class TKVideoCanvas;
@protocol TKRenderFrameDataDelegate<NSObject>
/// 渲染第一帧数据回调
- (void)onFirstVideoFrameWithRenderId:(NSString *)renderId width:(NSInteger)width height:(NSInteger)height;
/// 视频大小变化
- (void)videoViewDidChangeVideoSize:(CGSize)size renderId:(NSString *)renderId;
/// 视频渲染状态变化
- (void)onVideoStateChange:(NSString *)renderId videoState:(TKRenderState)state;
@end

@interface TKVideoRender : UIView
@property (nonatomic, assign) TKRenderMode renderMode;
@property (nonatomic, assign) BOOL mirror;
@property (nonatomic, strong) TKRenderView *renderView;
 

- (instancetype)initWithCanvas:(TKVideoCanvas *)canvas renderID:(NSString *)renderId delegate:(id<TKRenderFrameDataDelegate>)delegate;
- (void)setSize:(CGSize)size;
- (void)renderFrame:(nullable TKVideoFrame *)videoFrame;
@end





NS_ASSUME_NONNULL_END
