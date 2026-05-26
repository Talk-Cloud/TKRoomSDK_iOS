//
//  VideosBlock.h
//  talkSDKDemo
//
//  Created by MAC-MiNi on 2018/7/6.
//  Copyright © 2018年 beijing. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <TKRoomSDK/TKRoomSDK.h>
@class VideoView;
#define VideosBlockChangePositionNoti @"VideosBlockChangePositionNoti"
#define SwitchDuaStreamNotifiaction @"SwitchDuaStreamNotifaction"
@interface VideosBlock : UIScrollView
- (instancetype)initWithFrame:(CGRect)frame rmg:(TKRoomManager *)rmg;
- (void)playVideoWithUser:(TKRoomUser *)user deviceId:(NSString *)deviceId;
- (void)unPlayVideoWithUser:(NSString *)peerID deviceId:(NSString *)deviceId;
- (void)addVideo:(VideoView *)view;
- (void)delVideo:(VideoView *)view;
- (void)clean;

- (int)playMeida:(NSString *)file progress:(TKLocalMediaProgress_block)block;


- (void)playVideo:(NSString *)peerId deviceId:(NSString *)deviceId;
@end
