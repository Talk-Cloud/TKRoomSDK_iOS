//
//  VideosBlock.m
//  talkSDKDemo
//
//  Created by MAC-MiNi on 2018/7/6.
//  Copyright © 2018年 beijing. All rights reserved.
//

#import "VideosBlock.h"
#import "VideoView.h"


#define kWidth [UIScreen mainScreen].bounds.size.width
#define kheight [UIScreen mainScreen].bounds.size.height
#define kVideoMax 4
@interface VideosBlock()<VideoViewClickEvent>
@property (strong, nonatomic) VideoView *view1;
@property (strong, nonatomic) VideoView *view2;
@property (strong, nonatomic) VideoView *view3;
@property (strong, nonatomic) VideoView *view4;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic) TKRoomUser *user;
@property (strong, nonatomic) TKRoomManager *rmg;
@property (strong, nonatomic) NSMutableDictionary *videos; 
@end


@implementation VideosBlock

- (instancetype)initWithFrame:(CGRect)frame rmg:(TKRoomManager *)rmg
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.width = frame.size.width;
        self.height = frame.size.height;
        self.rmg = rmg;
        self.videos = [NSMutableDictionary dictionary];
    }
    return self;
}

- (VideoView *)creatVideoViewWith:(TKRoomUser *)user deviceId:(NSString *)deviceId
{
    VideoView *view = [[VideoView alloc] initWithRoomMgr:self.rmg roomUser:user deviceId:deviceId];
    // 双击手势
    [view setEventDelegate:self];
//    [self addTapGR:view];
    
    NSString *key = user.peerID;
    if (deviceId && deviceId.length > 0) {
        key = [NSString stringWithFormat:@"%@:%@", key, deviceId];
    }
    [self.videos setObject:view forKey:key];
    [self refreshVideo];
    [view bringSubviewToFront:view.imageView];
    return view;
}

- (void)playVideoWithUser:(TKRoomUser *)user deviceId:(NSString *)deviceId
{
    if (!user) {
        return;
    }
    VideoView *videoView = [self getVideoViewWithPeerID:user.peerID deviceId:deviceId];
    if (![user.peerID isEqualToString:self.rmg.localUser.peerID]) {
        if (!videoView) {
            videoView = [self creatVideoViewWith:user deviceId:deviceId];
        }

        NSString *extesnsionId = user.peerID;
        NSArray *arr = [extesnsionId componentsSeparatedByString:@":"];
        TKVideoCanvas *canvas = [TKVideoCanvas new];
        canvas.view = videoView;
        canvas.renderMode = TKRenderMode_adaptive;
        if (arr.count > 1) {
            if ([arr[1] isEqualToString:@"screen"]) {
                canvas.renderMode = TKRenderMode_fit;
            }
        }
        
        [self.rmg playVideo:user.peerID canvas:canvas deviceId:deviceId completion:^(NSError *error) {
            if (error) {
                return ;
            }
            [self addSubview:videoView];
            [videoView sendSubviewToBack:videoView.imageView];
            [self refreshVideo];
            [videoView setViewsToFront]; 
        }];
    }
}

- (void)playVideo:(NSString *)peerId deviceId:(NSString *)deviceId
{
    if (!peerId) {
        return;
    }
    VideoView *videoView = [self getVideoViewWithPeerID:peerId deviceId:deviceId];
    if (![peerId isEqualToString:self.rmg.localUser.peerID]) {
        if (!videoView) {
            TKRoomUser *user = [[TKRoomUser alloc] initWithPeerId:peerId];
            videoView = [self creatVideoViewWith:user deviceId:deviceId];
        }
        
        NSString *extesnsionId = peerId;
        NSArray *arr = [extesnsionId componentsSeparatedByString:@":"];
        TKVideoCanvas *canvas = [TKVideoCanvas new];
        canvas.view = videoView;
        canvas.renderMode = TKRenderMode_adaptive;
        if (arr.count > 1) {
            if ([arr[1] isEqualToString:@"screen"]) {
                canvas.renderMode = TKRenderMode_fit;
            }
        }
        
        [self.rmg playVideo:peerId canvas:canvas deviceId:deviceId completion:^(NSError *error) {
            if (error) {
                return ;
            }
            [self addSubview:videoView];
            [videoView sendSubviewToBack:videoView.imageView];
            [self refreshVideo];
            [videoView setViewsToFront];
        }];
    }
}


- (int)playMeida:(NSString *)file progress:(TKLocalMediaProgress_block)block
{
    VideoView *videoView = [self getVideoViewWithPeerID:file deviceId:nil];
    if (!videoView) {
        TKRoomUser *user = [[TKRoomUser alloc] initWithPeerId:file];
        videoView = [self creatVideoViewWith:user deviceId:nil];
        [self addSubview:videoView];
        [videoView sendSubviewToBack:videoView.imageView];
        [self refreshVideo];
        [videoView setViewsToFront]; 
    }
    TKMediaFileParams *param = [[TKMediaFileParams alloc] init];
    param.filePath = file;
    param.window = videoView;
    param.loop = NO;
    return [self.rmg startPlayMediaFile:param progress:block];
}
- (void)unPlayVideoWithUser:(NSString *)peerID deviceId:(NSString *)deviceId
{
    if ([peerID isEqualToString:_rmg.localUser.peerID]) {
        return;
    }
    __block VideoView *videoView = [self getVideoViewWithPeerID:peerID deviceId:deviceId];
    if (!videoView) {
        return;
    }
    [self.rmg unPlayVideo:peerID deviceId:deviceId completion:^(NSError *error) {
        [videoView removeFromSuperview];
        NSString *key = peerID;
        if (deviceId && deviceId.length > 0) {
            key = [NSString stringWithFormat:@"%@:%@", key, deviceId];
        }
        [self.videos removeObjectForKey:key];
        videoView = nil;
        [self refreshVideo];
    }];
}

- (void)layoutSubviews
{
    [self refreshVideo];
}

- (VideoView *)getVideoViewWithPeerID:(NSString *)peerID deviceId:(NSString *)deviceId
{
    if (!peerID || peerID.length == 0) {
        return nil;
    }
    NSString *key = peerID;
    if (deviceId && deviceId.length > 0) {
        key = [NSString stringWithFormat:@"%@:%@", peerID, deviceId];
    }
    return self.videos[key];
}
- (void)refreshVideo
{
    CGFloat gap = 10;
    CGFloat videoW = (self.width - (kVideoMax + 1) * gap) / kVideoMax;
    CGFloat x = gap;
    if (self.videos.count == 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIView class]]) {
//                [view removeFromSuperview];
            }
        }
    }
    
    for (VideoView *view in self.videos.allValues) {
        view.frame = CGRectMake(x, 0, videoW, self.height);
        x += (videoW + gap);
        [self bringSubviewToFront:view];
    }
    self.contentSize = CGSizeMake(self.videos.allKeys.count * (videoW + gap) + gap, self.height);

}
#pragma mark - 双击放大
- (void)dTapAction:(UIGestureRecognizer *)sender {
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VideosBlockChangePositionNoti
                                                        object:sender.view
                                                      userInfo:nil];
}
- (void)addVideo:(VideoView *)view {
    
    if (view) {
        
        [self.videos setObject:view forKey:view.roomUser.peerID];
        [self addSubview:view];
        [self addTapGR:view];
        [self refreshVideo];
    }
    
    
}

- (void)delVideo:(VideoView *)view {
    
    [self.videos removeObjectForKey:view.roomUser.peerID];
    
}

- (void)addTapGR:(VideoView *)view {
    return;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dTapAction:)];
    gr.numberOfTapsRequired = 2;
    gr.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:gr];
}

- (void)clean
{
    NSArray *tmp = [self.videos.allKeys copy];
    for (NSString *peerID in tmp) {
        
        NSString *key = peerID;
        NSArray *arr = [peerID componentsSeparatedByString:@":"];
        if (arr && arr.count > 1) {
            key = arr[0];
        }
        [_rmg unPlayVideo:key completion:^(NSError *error) {
            VideoView *view = self.videos[peerID];
            if (view) {
                [view removeFromSuperview];
                view = nil;
            }
        }];
        [_rmg unPlayAudio:key completion:nil];
    }
    [self.videos removeAllObjects];
    [self setNeedsLayout];
}

- (void)clickEvent:(VideoView *)videoView deviceId:(NSString *)deviceId select:(BOOL)select
{
    TKVideoStreamType type = TKVideoStream_Big;
    if (!select) {
        type = TKVideoStream_Small;
    }

    if (!videoView.roomUser.peerID) {
        return;
    }
    NSDictionary *dic = @{@"type" : @(type)};

    [[NSNotificationCenter defaultCenter] postNotificationName:SwitchDuaStreamNotifiaction
                                                        object:nil
                                                      userInfo:dic];
    [self.rmg setRemoteVideoStreamType:type peerId:videoView.roomUser.peerID deviceId:deviceId];
}
@end
