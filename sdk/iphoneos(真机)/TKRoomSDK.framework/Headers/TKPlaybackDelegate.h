//
//  TKPlaybackDelegate.h
//  TKRoomSDK
//
//  Created by MAC-MiNi on 2018/10/19.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#ifndef TKPlaybackDelegate_h
#define TKPlaybackDelegate_h

#import "TKRoomDelegate.h"

@protocol TKPlaybackManagerDelegate<TKRoomManagerDelegate>

@optional
/**
 获取到回放总时长的回调
 @param duration 回放的总时长
 */
- (void)roomManagerReceivePlaybackDuration:(NSTimeInterval)duration;

/**
 回放时接收到从服务器发来的回放进度变化
 @param time 变化的时间进度
 */
- (void)roomManagerPlaybackUpdateTime:(NSTimeInterval)time;

/**
 回放时清理
 */
- (void)roomManagerPlaybackClearAll;

/**
 回放播放完毕
 */
- (void)roomManagerPlaybackEnd;

@end

#endif /* TKPlaybackDelegate_h */
