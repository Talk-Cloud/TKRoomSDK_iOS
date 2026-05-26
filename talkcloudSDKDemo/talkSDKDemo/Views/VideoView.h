//
//  VideoView.h
//  TalkSDKDemo
//
//  Created by MAC-MiNi on 2018/3/19.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <TKRoomSDK/TKRoomSDK.h>

@class VideoView;
@protocol VideoViewClickEvent<NSObject>

- (void)clickEvent:(VideoView *)videoView deviceId:(NSString *)deviceId select:(BOOL)select;
@end

@interface VideoView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) TKRoomUser *roomUser;
@property (nonatomic, strong) UIView *contentView;
@property (strong, nonatomic) NSString *deviceId;
@property (assign, nonatomic) BOOL isBig;

- (instancetype)initWithRoomMgr:(TKRoomManager *)mgr roomUser:(TKRoomUser *)user deviceId:(NSString *)deviceId;
- (void)setVideoBackGroundColor:(UIColor *)color;
- (void)setViewsToFront;
- (void)setEventDelegate:(id<VideoViewClickEvent>)delegate;
@end
