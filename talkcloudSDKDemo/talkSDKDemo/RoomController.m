//
//  RoomController.m
//  classdemo
//
//  Created by mac on 2017/4/28.
//  Copyright © 2017年 talkcloud. All rights reserved.
//

#import "RoomController.h"

//#import <TKRoomSDK/TKRoomSDK.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoView.h"
#import <AudioUnit/AudioUnit.h>
#import "TKVideoLayerView.h"
#import "VideosBlock.h"
#import "TKTableViewCell.h"
#import "MBProgressHUD.h"
#import "ChatView.h"

#define kMixerSource @"tkaudiomixertest"
static NSString *identifier = @"TKTableViewCell";

typedef NS_ENUM(NSInteger, PublishState) {
    PublishState_NONE           = 0,            //没有
    PublishState_AUDIOONLY      = 1,            //只有音频
    PublishState_VIDEOONLY      = 2,            //只有视频
    PublishState_BOTH           = 3,            //都有
    PublishState_NONE_ONSTAGE   = 4,            //音视频都没有但还在台上
};


typedef void (^ButtonAction)(UIButton* button);

@interface TKRoomManager(test)
- (void)setTestServer:(NSString*)ip Port:(NSString*)port;
@end

@interface RoomController() <TKRoomManagerDelegate,TKMediaFrameDelegate,UITableViewDelegate,UITableViewDataSource, TKAudioMixerOuputDelegate>
@property (nonatomic, strong) VideoView *publishView;
@property (strong, nonatomic) NSString *myID;
@property (nonatomic, strong) VideoView *playView;
@property (strong, nonatomic) VideosBlock *videoBlock;

@property (nonatomic, strong) TKVideoLayerView *layerView;
@property (nonatomic, strong) NSMutableDictionary* userViews;
@property (nonatomic, strong) NSMutableDictionary* userDic;

@property (nonatomic, strong) TKRoomManager *roomMgr;
@property (nonatomic, strong) NSArray *controlButtons;
@property (nonatomic, strong) NSArray *buttonDescrptions;
@property (nonatomic, copy) NSString *playing;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timerCount;
@property (strong, nonatomic) UITableView *showStats;
@property (strong, nonatomic) NSMutableArray *statsArray;
@property (strong, nonatomic) NSArray *funBtnDes;
@property (strong, nonatomic) NSArray *funBtns;
@property (strong, nonatomic) UIView *listView;
@property (nonatomic, strong) UIAlertController *alert;
@property (assign, nonatomic) BOOL isOnlyAuido;

@property (nonatomic, strong) ChatView *chatView;// 聊天视图

@property (strong, nonatomic) UIView *mediaView;
@property (assign, nonatomic) CFAbsoluteTime start;
@property (assign, nonatomic) BOOL clean;
@property (strong, nonatomic) UIImageView *bgView;

@end
/*
 流程 
 
 1. 调用joinRoomWithHost，加入课堂
 2.roomManagerRoomJoined回调，发布自己的音视频changeUserPublish
 3.roomManagerUserPublished ,播放用户视频
 4.roomManagerUserUnPublished,关闭用户视频
 5.roomManagerUserChanged回调，播放可以播放视频的用户
 */

@implementation RoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    _userViews      = [NSMutableDictionary dictionaryWithCapacity:6];
    _userDic        = [NSMutableDictionary dictionaryWithCapacity:6];
    
    _roomMgr = [TKRoomManager instance];
    [TKRoomManager setLogLevel:TKLog_Info logPath:nil debugToConsole:YES];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = (width - 5 * 10) / 4;
    self.videoBlock = [[VideosBlock alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - height - 10, width, height) rmg:self.roomMgr];
    [self.view addSubview:self.videoBlock];
    
    _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_videoClose"]];
    _bgView.backgroundColor = [UIColor colorWithRed:(47)/255.0f green:(47)/255.0f blue:(47)/255.0f alpha:1.0];
    [_bgView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:_bgView];
    self.bgView.contentMode = UIViewContentModeCenter;
    
    [self createLayerView];
    
    
    CGFloat y = self.view.frame.size.height - height - 75 - height;
    self.showStats = [[UITableView alloc] initWithFrame:CGRectMake(0, y, width, height) style:UITableViewStylePlain];
    [self.showStats setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.showStats.delegate = self;
    self.showStats.dataSource = self;
    self.showStats.rowHeight = 20;
//    self.showStats.scrollEnabled = NO;
    self.showStats.backgroundColor = [UIColor clearColor];
    [self.showStats registerNib:[UINib nibWithNibName:@"TKTableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
    [self.view addSubview:self.showStats];
    
//    [self.showStats reloadData];
    self.statsArray = [NSMutableArray array];

//    self.mediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    self.mediaView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:self.mediaView];
    
    [self initAVAndinitClass];
    
    [self ControlBtn];
    [self createAlert];
    
    [self createCommonBtn];
    [self creatTimer];
    
    // 双击处理方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeViewPosition:) name:VideosBlockChangePositionNoti object:nil];

}

- (void)creatTimer{
    _timerCount = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(timerFire) userInfo:nil repeats:true];
    [_timer setFireDate:[NSDate date]];
}
-(void)timerFire{
    _timerCount++;
    if (_timerCount > 8) {
        //隐藏控制按钮
//        for (UIView* button in _controlButtons) {
//            button.hidden = YES;
//        }
        self.showStats.hidden = YES;
        [_timer setFireDate:[NSDate distantFuture]];
    }
}
- (void)resetTimer{
//    for (UIView* button in _controlButtons) {
//        button.hidden = NO;
//    }
    self.showStats.hidden = NO;
    _timerCount = 0;
    [_timer setFireDate:[NSDate date]];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self resetTimer];

    if (_chatView.hidden == NO) {
        if ([self.funBtns.lastObject isKindOfClass:UIButton.class]) {
            UIButton *btn = (UIButton *)self.funBtns.lastObject;
            btn.selected = NO;
        }

        [_chatView hide];
    }
    
}

- (void)onNetworkQuality:(TKNetQuality)networkQuality delay:(NSInteger)delay {
    
    NSLog(@"networkQuality = %zd, delay = %ld", networkQuality , delay);
}
- (UIButton *)createCommonBtn
{
    __weak typeof(self) weakSelf = self;
    self.funBtnDes = @[
                       @{@"imageNomal":[UIImage imageNamed:@"switchCamera"],
                         @"imageSelect":[UIImage imageNamed:@"switchCamera"],
                         @"block":^(UIButton* button){
                             //切换摄像头2
                             if (!button.selected) {
                                 _timerCount = 0;
                                 [weakSelf.roomMgr selectCameraPosition:YES];
                             } else {
                                 _timerCount = 0;
                                 [weakSelf.roomMgr selectCameraPosition:NO];
                             }
                         }},
                       @{@"imageNomal":[UIImage imageNamed:@"AV"],
                         @"imageSelect":[UIImage imageNamed:@"onlyAudio"],
                         @"block":^(UIButton* button){
                             
                             //切换纯音频3
                             if (button.selected) {
                                 _timerCount = 0;
                                 [weakSelf.roomMgr switchOnlyAudioRoom:YES];
                                 
                             } else {
                                 _timerCount = 0;
                                 [weakSelf.roomMgr switchOnlyAudioRoom:NO];
                             }
                         }},
                       @{@"imageNomal":[UIImage imageNamed:@"videoProfile"],
                         @"imageSelect":[UIImage imageNamed:@"videoProfile"],
                         @"block":^(UIButton* button){
                             //设置分辨率4
                             UIPopoverPresentationController *popover = weakSelf.alert.popoverPresentationController;
                             if (popover) {
                                 popover.sourceView = button;
                                 popover.sourceRect = button.bounds;
                                 popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
                             }
                             [self presentViewController:weakSelf.alert animated:YES completion:nil];
                             
                         }},
                       @{@"imageNomal":[UIImage imageNamed:@"speaker"],
                         @"imageSelect":[UIImage imageNamed:@"receive"],
                         @"block":^(UIButton* button){
                             //扬声器
                             if (!button.selected) {
                                 _timerCount = 0;
                                 [weakSelf.roomMgr useLoudSpeaker:YES];
                             } else {
                                 _timerCount = 0;
                                 [weakSelf.roomMgr useLoudSpeaker:NO];
                             }
                         }},
                       // 聊天界面打开关闭 按钮
                       @{@"imageNomal":[UIImage imageNamed:@"talk_default"],
                         @"imageSelect":[UIImage imageNamed:@"talk_press"],
                         @"block":^(UIButton* button){
                             if (button.selected) {
                                 [weakSelf.chatView show];
                             }
                             else {
                                 [weakSelf.chatView hide];
                             }
                         }},
                       ];
    
    
    
    NSInteger count = self.funBtnDes.count;
    CGFloat kWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat gap = 10;
    CGFloat x = kWidth - 50 - gap;
    CGFloat y = 50;
    CGFloat width = 50;
    CGFloat height = count * (50 + gap);
    _listView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    _listView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_listView];
    
    NSInteger i = 0;
    NSMutableArray *bt = [NSMutableArray arrayWithCapacity:self.funBtnDes.count];
    for (NSDictionary* dic in _funBtnDes) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, i *(width + gap), width, width)];
        [button setSelected:false];
        UIImage *imageNomal = [dic objectForKey:@"imageNomal"];
        UIImage *imageSelect = [dic objectForKey:@"imageSelect"];
        [button setImage:imageNomal forState:(UIControlStateNormal)];
        [button setImage:imageSelect forState:(UIControlStateSelected)];
        [button setTag:bt.count];
        [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [button addTarget:self action:@selector(listViewBtn:) forControlEvents: UIControlEventTouchUpInside];
        button.hidden = YES;
        [bt addObject:button];
        [self.listView addSubview:button];
        i++;
    }
    self.funBtns = [bt copy];
    return nil;
}
- (void)listViewBtn:(UIButton *)button {
    
    [button setSelected:!button.isSelected];
    ButtonAction block = (ButtonAction)[((NSDictionary*)self.funBtnDes[button.tag]) objectForKey:@"block"];
    block(button);
}
- (void)createAlert
{
    _alert = [UIAlertController alertControllerWithTitle:@"设置分辨率" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [_alert addAction:cancelAction];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"80X60" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TKVideoProfile *videoProfile = [TKVideoProfile new];
        videoProfile.width = 80;
        videoProfile.height = 60;
        videoProfile.maxfps = 15;
        [_roomMgr setVideoProfile:videoProfile];
    }];
    [_alert addAction:action1];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"176X132" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TKVideoProfile *videoProfile = [TKVideoProfile new];
        videoProfile.width = 176;
        videoProfile.height = 132;
        videoProfile.maxfps = 15;
        [_roomMgr setVideoProfile:videoProfile];
    }];
    [_alert addAction:action2];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"320X240" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TKVideoProfile *videoProfile = [TKVideoProfile new];
        videoProfile.width = 320;
        videoProfile.height = 240;
        videoProfile.maxfps = 15;
        [_roomMgr setVideoProfile:videoProfile];
    }];
    [_alert addAction:action3];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"640X480" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TKVideoProfile *videoProfile = [TKVideoProfile new];
        videoProfile.width = 640;
        videoProfile.height = 480;
        videoProfile.maxfps = 15;
        [_roomMgr setVideoProfile:videoProfile];
    }];
    [_alert addAction:action4];
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"1280X720" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TKVideoProfile *videoProfile = [TKVideoProfile new];
        videoProfile.width = 1280;
        videoProfile.height = 720;
        videoProfile.maxfps = 15;
        [_roomMgr setVideoProfile:videoProfile];
    }];
    [_alert addAction:action5];
    UIAlertAction *action6 = [UIAlertAction actionWithTitle:@"1920X1080" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TKVideoProfile *videoProfile = [TKVideoProfile new];
        videoProfile.width = 1920;
        videoProfile.height = 1080;
        videoProfile.maxfps = 30;
        [_roomMgr setVideoProfile:videoProfile];
    }];
    [_alert addAction:action6];
}
- (void)viewDidLayoutSubviews {
    
//    [self layoutVideos];
    self.publishView.frame = self.view.bounds;
    
    [self layoutControlBtn];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = (width - 5 * 10) / 4;
    self.videoBlock.frame = CGRectMake(0, self.view.frame.size.height - height - 70, width, height);

}
- (void)btnTest {
#pragma mark - 测试按钮
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(10, 50, 50, 50);
//    [btn setTitle:@"测试按钮" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(btnTest) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    [_roomMgr stopNetworkTest];
    
}

#pragma mark - 获取摄像头麦克风权限以及初始化课堂
- (void)initAVAndinitClass
{
    [_roomMgr registerRoomManagerDelegate:self];
    [_roomMgr registerMediaDelegate:self];
    NSString *password = @"";
    if (self.password) {
        password = self.password;
    }
    if (!self.name || self.name.length == 0) {
        self.name = @"global.talk-cloud.net";
    }
//    self.name = @"demo.talk-cloud.net";
//    self.roomid = @"686149745";
   
    TKVideoProfile *profile = [TKVideoProfile new];
    profile.width = 640;
    profile.height = 480;
    profile.maxfps = 10;
    [_roomMgr setVideoProfile:profile];
    [_roomMgr joinRoomWithHost:self.name port:80 nickName:@"ios" roomParams:@{TKJoinRoomParamsRoomIDKey:self.roomid,TKJoinRoomParamsUserRoleKey:self.role, TKJoinRoomParamsPasswordKey : password,@"clientType":@(3), @"autoSubscribeAV" : @(YES)} userParams:nil];
    [_roomMgr setVideoOrientation:UIDeviceOrientationPortrait];
    [_roomMgr setLocalVideoMirrorMode:TKVideoMirrorModeAuto];
    
}
#pragma mark - 初始化课堂按钮
- (void)ControlBtn{
    
//    [self.view addSubview:self.layerView];
    
    //学生身份。在网页当老师时，（1）教室是自动上课／自动开启音视频时才可以看到其他人。（2）教室是自动开启音视频，此时需要老师点击上课按钮，才可以看到其他人（3）教室没有设置，需要其他人publish自己的视频，才可以看到（前两种情况的本质就是收到其他人publish自己的视频）。
    //老师身份。注意（1）老师只能进入一个。（2）只有其他人publish了自己的视频，才能看到彼此。具体看roomManagerRoomJoined函数（发布自己的音视频）
    //[_roomMgr joinRoomWithHost:@"global.talk-cloud.net" Port:443 NickName:@"ios" Params:@{@"serial":@"933643979",@"userrole":@(0),@"password":@(1)} Properties:nil];
    __weak typeof(self) weakSelf = self;
    _buttonDescrptions = @[@{@"imageNomal":[UIImage imageNamed:@"cameraoff"],
                             @"imageSelect":[UIImage imageNamed:@"cameraon"],
                             @"block":^(UIButton* button){
                                 if (!button.selected) {
                                     _timerCount = 0;
                                     [weakSelf.roomMgr publishVideo:nil];
                                 } else {
                                     _timerCount = 0;
                                     [weakSelf.roomMgr unPublishVideo:nil];
                                 }
                             }},
                           @{@"imageNomal":[UIImage imageNamed:@"mute"],
                             @"imageSelect":[UIImage imageNamed:@"unmute"],
                             @"block":^(UIButton* button){
                                 if (!button.selected) {
                                     _timerCount = 0;
                                     [weakSelf.roomMgr publishAudio:nil];
                                 } else {
                                     _timerCount = 0;
                                     [weakSelf.roomMgr unPublishAudio:nil];
                                 }
                             }},
                           @{@"imageNomal":[UIImage imageNamed:@"hangup"],
                             @"imageSelect":[UIImage imageNamed:@"hangup"],
                             @"block":^(UIButton* button){
                                 if (button.selected) {
                                     [weakSelf.roomMgr leaveRoom:nil];
                                     [TKRoomManager destory];
                                     weakSelf.roomMgr = nil;
                                 } else {
                                     button.enabled = NO;
                                 }
                             }},
 
                           ];
    
    
    NSMutableArray *bt = [NSMutableArray arrayWithCapacity:_buttonDescrptions.count];
    for (NSDictionary* dic in _buttonDescrptions) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        [button setSelected:false];
        UIImage *imageNomal = [dic objectForKey:@"imageNomal"];
        UIImage *imageSelect = [dic objectForKey:@"imageSelect"];
        [button setImage:imageNomal forState:(UIControlStateNormal)];
        [button setImage:imageSelect forState:(UIControlStateSelected)];
        [button setTag:bt.count];
        [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [button addTarget:self action:@selector(toggleButton:) forControlEvents: UIControlEventTouchUpInside];
        
        [bt addObject:button];
        [self.view addSubview:button];
    }
    _controlButtons = [NSArray arrayWithArray:bt]; 
}

// internal functions
- (void)layoutVideos {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_userViews];
    if ([_userViews objectForKey:_roomMgr.localUser.peerID]) {
       
        VideoView *videoView = (VideoView *)_userViews[_roomMgr.localUser.peerID];
        videoView.frame = CGRectMake(self.view.frame.size.width-self.view.frame.size.width/4-20, 20, self.view.frame.size.width/4, self.view.frame.size.width/3);
//        videoView.transform = CGAffineTransformMakeRotation(M_PI_2);
         [dict removeObjectForKey:_roomMgr.localUser.peerID];
    }
        
    for (VideoView *view in [dict allValues]) {
        view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)layoutControlBtn {
    
    self.layerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    CGFloat gap = (self.view.bounds.size.width-50*3)/4;
    CGFloat width = 50;
    CGFloat height = width;
    CGFloat x = gap;
    CGFloat y = self.view.bounds.size.height - height - 10;
    for (UIView* button in _controlButtons) {
        [button setFrame:CGRectMake(x, y, width, height)];
        [self.view bringSubviewToFront:button];
        x += width + gap;
    }
}

#pragma mark 播放（关闭）视频
- (void)setUI2Front
{
    [self.view bringSubviewToFront:self.videoBlock];
    [self.view bringSubviewToFront:self.showStats];
    [self.view bringSubviewToFront:self.listView];
//    [self.view bringSubviewToFront:self.mediaView];
}
- (void)playVideo:(TKRoomUser *)user deviceId:(NSString *)deviceId
{
    if ([user.peerID isEqualToString:_myID]) {
        if (!self.publishView) {
            self.publishView = [[VideoView alloc] initWithRoomMgr:_roomMgr roomUser:user deviceId:deviceId];
            [self.view addSubview:self.publishView];
        }
        __weak typeof(self) weakSelf = self;
        [_roomMgr playVideo:user.peerID renderType:TKRenderMode_adaptive window:self.publishView completion:^(NSError *error) {
            
            if (error) {
                return ;
            }
            [weakSelf.publishView sendSubviewToBack:weakSelf.publishView.imageView];
            [self viewDidLayoutSubviews];
            [self setUI2Front];
        }];
    
    } else {
        [self.videoBlock playVideoWithUser:user deviceId:deviceId];
        [self setUI2Front];
    }
}

- (void)unPlayVideo:(NSString *)peerID deviceId:(NSString *)deviceId
{
    if ([peerID isEqualToString:_myID]) {
        if (!self.publishView) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        [_roomMgr unPlayVideo:peerID completion:^(NSError *error) {
            [weakSelf.publishView removeFromSuperview];
            weakSelf.publishView = nil;
            
            [self viewDidLayoutSubviews];
        }];
    } else {
        [self.videoBlock unPlayVideoWithUser:peerID deviceId:deviceId];
    }
}

- (void)refreshUI{
    if ([_userViews objectForKey:_roomMgr.localUser.peerID]) {
        
        VideoView *videoView = (VideoView *)_userViews[_roomMgr.localUser.peerID];
        [self.view bringSubviewToFront:videoView];
    }
}

- (void)toggleButton:(UIButton *) button
{
    if (button.tag == 0 && self.isOnlyAuido && _roomMgr.localUser.publishState != 0) {
        return;
    }
    [button setSelected:!button.isSelected];
    ButtonAction block = (ButtonAction)[((NSDictionary*)_buttonDescrptions[button.tag]) objectForKey:@"block"];
    block(button);
}

#pragma mark - roomManager
- (void)roomManagerRoomJoined
{
    self.clean = NO;
    //第二步 加入课堂成功 发布自己的音视频
    for (UIButton *btn in self.funBtns) {
        btn.hidden = NO;
    }
    [_roomMgr publishVideo:nil];
    [_roomMgr publishAudio:nil];
    _myID = _roomMgr.localUser.peerID;
}

- (void)roomManagerDidOccuredError:(NSError *)error
{
    [self reportFail:error.code];
    NSString *log = [NSString stringWithFormat:@"💔error💔 code:%ld message:%@",error.code, error.localizedDescription];
    
    [self.statsArray addObject:log];
    [self resetTimer];
    [self.showStats reloadData];
    if (self.statsArray.count >= 2) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.statsArray.count - 1 inSection:0];
        [self.showStats scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
//    if (error.code == TKErrorCode_ConnectSocketError) {
//        if (!self.clean) {
//            [_videoBlock clean];
//        }
//        self.clean = YES;
//    }
    
}

- (void)roomManagerOnConnectionLost
{
    if (!self.clean) {
        [_videoBlock clean];
    }
    self.clean = YES;
}

- (void)roomManagerDidOccuredWaring:(TKRoomWarningCode)code
{
    if (code == TKRoomWarning_AudioRouteChange_Headphones || code == TKRoomWarning_AudioRouteChange_Bluetooth) {
    }
}
- (void)reportFail:(TKRoomErrorCode)ret
{
    NSString *alertMessage = nil; 
    switch (ret) {
        case 5001://checkroom成功
                alertMessage = @"checkRoom成功";
            return ;
        case TKErrorCode_CheckRoom_ServerOverdue: {//3001  服务器过期
                alertMessage = @"服务器过期";
        }
            break;
        case TKErrorCode_CheckRoom_RoomFreeze: {//3002  公司被冻结
                alertMessage = @"公司被冻结";
        }
            break;
        case TKErrorCode_CheckRoom_RoomDeleteOrOrverdue: //3003  房间被删除或过期
        case TKErrorCode_CheckRoom_RoomNonExistent: {//4007 房间不存在 房间被删除或者过期
                alertMessage = @"房间被删除或者过期";
        }
            break;
        case TKErrorCode_CheckRoom_RequestFailed:
                alertMessage = @"网络请求失败";
            break;
        case TKErrorCode_CheckRoom_PasswordError: {//4008  房间密码错误
                alertMessage = @"房间密码错误";
        }
            break;
            
        case TKErrorCode_CheckRoom_WrongPasswordForRole: {//4012  密码与角色不符
                alertMessage = @"密码与角色不符";
        }
            break;
            
        case TKErrorCode_CheckRoom_RoomNumberOverRun: {//4103  房间人数超限
                alertMessage = @"房间人数超限";
        }
            break;
            
        case TKErrorCode_CheckRoom_NeedPassword: {//4110  该房间需要密码，请输入密码
                alertMessage = @"该房间需要密码，请输入密码";
        }
            break;
            
        case TKErrorCode_CheckRoom_RoomPointOverrun: {//4112  企业点数超限
                alertMessage = @" 企业点数超限";
        }
            break;
        case TKErrorCode_CheckRoom_RoomAuthenError: {//4109
                alertMessage = @"认证错误";
        }
            break;

        default:
            return;
    }
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"💔Error💔" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_roomMgr leaveRoom:nil];
        
        
    }];
    [alertVC addAction:action1];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)roomManagerKickedOut:(NSDictionary *)reason
{
     NSLog(@"roomManagerSelfEvicted");
    [self.roomMgr leaveRoom:nil];
}
- (void)destory
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_videoBlock clean];
    [TKRoomManager destory];
    _roomMgr = nil;
    if (_chatView) {
        [_chatView removeFromSuperview];
        [_chatView destory];
    }
    
    _chatView = nil;
    _videoBlock = nil;
}
- (void)roomManagerRoomLeft {
    NSLog(@"roomManagerRoomLeft");
    
    [self destory];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (void)roomManagerOnUserAudioStatus:(NSString *)peerID state:(TKMediaState)state
{
    if (state == TKMedia_Pulished) {
        [_roomMgr playAudio:peerID completion:nil];
    } else {
        [_roomMgr unPlayAudio:peerID completion:nil];
    }
    if ([peerID isEqualToString:_myID]) {
        UIButton *audio = _controlButtons[1];
        audio.selected = !state;
    }
}
- (void)roomManagerOnUserVideoStatus:(NSString *)peerID state:(TKMediaState)state
{
    if (state == TKMedia_Pulished) {
        TKRoomUser *user = [_roomMgr getRoomUserWithUId:peerID];
        [self playVideo:user deviceId:nil];
    } else {
        [self unPlayVideo:peerID deviceId:nil];
    }
    if ([peerID isEqualToString:_myID]) {
        UIButton *video = _controlButtons[0];
        video.selected = !state;
    }
}

- (void)roomManagerOnUserVideoStatus:(NSString *)peerID deviceId:(NSString *)deviceId state:(TKMediaState)state
{
    if (state == TKMedia_Pulished) {
        TKRoomUser *user = [_roomMgr getRoomUserWithUId:peerID];
        [self playVideo:user deviceId:deviceId];
    } else {
        [self unPlayVideo:peerID deviceId:deviceId];
    }
    if ([peerID isEqualToString:_myID]) {
        UIButton *video = _controlButtons[0];
        video.selected = !state;
    }
}

- (void)roomManagerConnected:(dispatch_block_t)completion
{
    
}

- (void)roomManagerUserJoined:(NSString *)peerID inList:(BOOL)inList
{
 
    NSLog(@"roomManagerUserJoined %d %@", inList, peerID);
}

- (void)roomManagerUserLeft:(NSString *)peerID
{
    NSLog(@"roomManagerUserLeft %@", peerID);
}


- (void)roomManagerUserPropertyChanged:(NSString *)peerID
                            properties:(NSDictionary*)properties
                                fromId:(NSString *)fromId
{
    
}
#pragma mark 消息
- (void)roomManagerMessageReceived:(NSString *)message
                            fromID:(NSString *)peerID
                         extension:(NSDictionary *)extension
{
    NSString *tDataString = [NSString stringWithFormat:@"%@", message];
    NSData *tJsData = [tDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tDataDic = [NSJSONSerialization JSONObjectWithData:tJsData options:NSJSONReadingMutableContainers error:nil];
    NSString *msg = [tDataDic objectForKey:@"msg"];
    // 刷新聊天
    [self chatView];
    [_chatView receiveMessage:msg peerID:peerID];
}

- (void)roomManagerPlaybackMessageReceived:(NSString *)message
                                    fromID:(NSString *)peerID
                                        ts:(NSTimeInterval)ts
                                 extension:(NSDictionary *)extension
{
    
}

- (void)roomManagerOnRemotePubMsgWithMsgID:(NSString *)msgID
                                   msgName:(NSString *)msgName
                                      data:(NSObject *)data
                                    fromID:(NSString *)fromID
                                    inList:(BOOL)inlist
                                        ts:(long)ts
{
//    NSLog(@"roomManagerOnRemoteMsg %@ %@ %lu %@", msgID, msgName, ts, data);
    
}
- (void)roomManagerOnRemoteDelMsgWithMsgID:(NSString *)msgID
                                   msgName:(NSString *)msgName
                                      data:(NSObject *)data
                                    fromID:(NSString *)fromID
                                    inList:(BOOL)inlist
                                        ts:(long)ts
{
    if (msgName && [msgName isEqualToString:@"OnlyAudioRoom"]) {
        NSLog(@"roomManagerOnDelRemoteMsg %@ %@ %lu %@", msgID, msgName, ts, data);
        UIButton *btn = self.funBtns[1];
        btn.selected = NO;
    }
}
- (void)roomManagerOnAudioRoomSwitch:(NSString *)fromId onlyAudio:(BOOL)onlyAudio
{
    UIButton *btn = self.funBtns[1];
    btn.selected = onlyAudio;
    // 视频按钮
    UIButton *video = _controlButtons[0];
    // yes 关闭, no 开启
    video.selected = !(_roomMgr.localUser.publishState == TKUser_PublishState_VIDEOONLY ||
                        _roomMgr.localUser.publishState == TKUser_PublishState_BOTH);
    // 禁用/启动 视频按钮
    video.enabled = !onlyAudio;
    
    // 音频按钮
    UIButton *audio = _controlButtons[1];
    audio.selected = !(_roomMgr.localUser.publishState == TKUser_PublishState_AUDIOONLY ||
                     _roomMgr.localUser.publishState == TKUser_PublishState_BOTH);
    
    self.isOnlyAuido = onlyAudio;
    NSString *log = nil;
    
    if (onlyAudio) {
        log = @"💚房间已切换成纯音频房间💚";
        if (_roomMgr.localUser.publishState != 0) {
            if(_publishView) {
                [_publishView bringSubviewToFront:_publishView.imageView];
                [self unPlayVideo:_myID deviceId:nil];
            }
        }
    } else {
        log = @"💚房间已切换成音视频房间💚";
        if (_roomMgr.localUser.publishState == TKUser_PublishState_BOTH ||
            _roomMgr.localUser.publishState == TKUser_PublishState_VIDEOONLY)
        {
            [self playVideo:[_roomMgr getRoomUserWithUId:_myID] deviceId:nil];
            [_publishView sendSubviewToBack:_publishView.imageView];
        }
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.label.text = log;
    hud.mode = MBProgressHUDModeText;
    hud.minShowTime = 1;
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:1.5];
    
    [self.view addSubview:hud];
}

#pragma mark meidia
- (void)roomManagerOnShareMediaState:(NSString *)peerId
                               state:(TKMediaState)state
                    extensionMessage:(NSDictionary *)message
{
//    if (state == TKMedia_Pulished) {
//        [_roomMgr playMediaFile:peerId renderType:TKRenderMode_adaptive window:self.mediaView completion:^(NSError *error) {
//
//        }];
//    } else {
//        [_roomMgr unPlayMediaFile:peerId completion:^(NSError *error) {
//
//        }];
//    }
}

- (void)roomManagerUpdateMediaStream:(NSTimeInterval)duration
                                 pos:(NSTimeInterval)pos
                              isPlay:(BOOL)isPlay
{
    
}

- (void)roomManagerMediaLoaded
{
    
}

#pragma mark screen

- (void)roomManagerOnShareScreenState:(NSString *)peerId
                                state:(TKMediaState)state
                     extensionMessage:(NSDictionary *)message
{
    
}

- (void)roomManagerOnShareFileState:(NSString *)peerId
                              state:(TKMediaState)state
                   extensionMessage:(NSDictionary *)message
{
    
}

#pragma mark Playback

- (void)roomManagerReceivePlaybackDuration:(NSTimeInterval)duration{
    
}

- (void)roomManagerPlaybackUpdateTime:(NSTimeInterval)time{
    
}

- (void)roomManagerPlaybackClearAll{
    
}

- (void)roomManagerPlaybackEnd{
    
}
- (void)roomManagerOnAudioStatsReport:(NSString *)peerId stats:(TKAudioStats *)stats
{
//    TKRoomUser *user = [_roomMgr getRoomUserWithUId:peerId];
//
//    NSString *string = [NSString stringWithFormat:@"audio user:%@ bandwidth:%ld lost:%ld total:%ld delay:%ld jitter:%ld netLevel:%ld",user.nickName, (long)stats.bitsPerSecond, (long)stats.packetsLost, (long)stats.totalPackets, (long)stats.currentDelay, (long)stats.jitter, (long)stats.netLevel];
//    [self.statsArray addObject:string];
//    if (self.statsArray.count >= 2) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.statsArray.count - 2 inSection:0];
//        [self.showStats scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
//    [self.showStats reloadData];
//
}
- (void)roomManagerOnVideoStatsReport:(NSString *)peerId stats:(TKVideoStats *)stats
{
//    TKRoomUser *user = [_roomMgr getRoomUserWithUId:peerId];
//    NSString *string = [NSString stringWithFormat:@"video user:%@ bandwidth:%ld lost:%ld total:%ld delay:%ld netLevel:%ld",user.nickName, (long)stats.bitsPerSecond, (long)stats.packetsLost, (long)stats.totalPackets, (long)stats.currentDelay, (long)stats.netLevel];
//    [self.statsArray addObject:string];
//    if (self.statsArray.count >= 2) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.statsArray.count - 2 inSection:0];
//        [self.showStats scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
//    [self.showStats reloadData];
}
- (void)roomManagerOnFirstAudioFrameWithPeerID:(NSString *)peerID mediaType:(TKMediaType)type
{
    if ([peerID isEqualToString:_roomMgr.localUser.peerID]) {
//        NSLog(@"自己 OnFirstAudioFrame mediaType = %ld", type);
    } else {
//        NSLog(@"远端 OnFirstAudioFrame mediaType = %ld", type);
    }
}

- (void)roomManagerOnFirstVideoFrameWithPeerID:(NSString *)peerID width:(NSInteger)width height:(NSInteger)height mediaType:(TKMediaType)type
{
    if ([peerID isEqualToString:_roomMgr.localUser.peerID]) {
//        NSLog(@"自己 OnFirstVideoFrame width = %ld height = %ld mediaType = %ld",width, height, type);
    } else {
//        CFAbsoluteTime cur = CFAbsoluteTimeGetCurrent() - _start;
//        NSLog(@"远端 OnFirstVideoFrame 渲染时间%f", cur);
//        NSLog(@"远端 OnFirstVideoFrame width = %ld height = %ld mediaType = %ld",width, height, type);
    }
}
#pragma mark - TKMediaFrameDelegate

- (void)onCaptureAudioFrame:(TKAudioFrame *)frame sourceType:(TKMediaType)type
{
//    NSLog(@"自己 onCaptureAudioFrame = %@", frame);
}

- (void)onCaptureVideoFrame:(TKVideoFrame *)frame sourceType:(TKMediaType)type
{
//    NSLog(@"自己 onCaptureVideoFrame = %@", frame);
    
}

- (void)onRenderAudioFrame:(TKAudioFrame *)frame uid:(NSString *)peerId sourceType:(TKMediaType)type
{
//    NSLog(@"peerId= %@, onRenderAudioFrame = %@",peerId, frame);
}

- (void)onRenderVideoFrame:(TKVideoFrame *)frame uid:(NSString *)peerId sourceType:(TKMediaType)type
{
//    NSLog(@"peerId= %@, onRenderVideoFrame = %@",peerId, frame);
}
#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TKTableViewCell *cell = [self.showStats dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[TKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.statsArray.count > 0) {
         cell.showLabel.text = [self.statsArray objectAtIndex:indexPath.row];
    } 
    return cell;
}

- (void)createLayerView
{
    if (!_layerView) {
        self.layerView = [[TKVideoLayerView alloc]init];
        [self.view addSubview:self.layerView];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 双击交换位置
- (void)changeViewPosition:(NSNotification *)noti {
    if (![noti.object isKindOfClass: VideoView.class]) {
        return;
    }
    VideoView *view = noti.object;
    // 禁用
    if ([view isEqual:self.publishView]) {
        return;
    }
    // 2. 放大
    view.frame = self.publishView.bounds;
    [self.videoBlock delVideo:view];
    [self.view addSubview:view];
    
    if (view.roomUser.publishState > TKUser_PublishState_AUDIOONLY) {
        [self.view insertSubview:view aboveSubview:self.layerView];
    }
    else {
        [self.view insertSubview:view aboveSubview:self.bgView];
    }
    _myID = view.roomUser.peerID;
    
    // 1. 缩小
    [self.videoBlock addVideo:self.publishView];
    [self setUI2Front];
    
    self.publishView = view;
}
#pragma mark - 懒加载 聊天视图
- (ChatView *)chatView {
    if (!_chatView) {
        _chatView = [[ChatView alloc] initWithFrame:CGRectMake(0,
                                                               CGRectGetMaxY(_listView.frame) + 10,
                                                               self.view.width,
                                                               self.view.height - (CGRectGetMaxY(_listView.frame) + 10))];
        [[UIApplication sharedApplication].keyWindow addSubview:_chatView];
    }
    return _chatView;
}

- (void)dealloc {
    NSLog(@"dealloc!!!!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)mixedAudioOutput:(TKAudioMixer *)mixer ouput_data:(const void *)data audioInfo:(TKAudioInfo *)audioInfo
{
        //dosomething
}



@end
