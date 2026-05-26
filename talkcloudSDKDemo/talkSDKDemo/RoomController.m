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
#import <ReplayKit/ReplayKit.h>
#import <TKMediaEngine/TKLogMacros.h>
#import "GenerateUserSig.h"

#define kMixerSource @"tkaudiomixertest"
#define kSecureSocket 1

//static NSString * const kAppkey = <#AppKey#>;
static NSString * const kAppkey = @"Fa2rW7TPACmxgbqZ";
static NSString *const companyDomain = @"tutu";
//LNIWjlgmvqwbt4hy
static NSString *identifier = @"TKTableViewCell";

static NSString * const kAppGroup = @"group.com.talkcloud.sdkDemo";

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

@interface RoomController() <TKRoomManagerDelegate,TKMediaFrameDelegate,UITableViewDelegate,UITableViewDataSource,RPBroadcastActivityViewControllerDelegate>
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

@property (assign, nonatomic) BOOL startScreenRecord;

@property (strong, nonatomic) NSTimer *testtimer;

@property (strong, nonatomic) RPBroadcastActivityViewController *broadcastAVC;
@property (strong, nonatomic) RPBroadcastController *broadcastController;

@property (nonatomic, assign) NSInteger ID;

@property (nonatomic, strong) RPSystemBroadcastPickerView *broadcastView;
@property (nonatomic, assign) NSInteger autoSpeechRecognitionCount;
@property (nonatomic, strong) NSMutableDictionary *tmp;

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
    _autoSpeechRecognitionCount = 0;
    
    [self initView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    NSLog(@"state1 = %zd", state);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    NSLog(@"state2 = %zd", state);
}


- (void)initView
{
    [self.view setBackgroundColor:[UIColor blackColor]];
    _userViews      = [NSMutableDictionary dictionaryWithCapacity:6];
    _userDic        = [NSMutableDictionary dictionaryWithCapacity:6];
    
    
    _roomMgr = [TKRoomManager instance];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinroomfailed:) name:TKRoomManagerJoinRoomFailedNotification object:nil];
    [self initAVAndinitClass];

    // 底部按钮
    [self ControlBtn];
    [self createAlert];
    
    // 右侧按钮
    [self createCommonBtn];
    [self creatTimer];
    
        // 双击处理方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeViewPosition:) name:VideosBlockChangePositionNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchDuaStream:) name:SwitchDuaStreamNotifiaction object:nil];
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    broadcastStarted,
                                    CFSTR("ScreenbroadcastStarted"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenRecordStartedNotification:) name:@"ScreenRecordStarted" object:nil];
    
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    broadcastFinished,
                                    CFSTR("ScreenbroadcastFinished"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenRecordFinishedNotification:) name:@"ScreenRecordFinished" object:nil];
        //    _slider = [[UISlider alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
}

- (void)joinroomfailed:(NSNotification *)noti {
    NSLog(@"!!!!!!");
}
void broadcastStarted(CFNotificationCenterRef center,
                      void *observer, CFStringRef name,
                      const void *object, CFDictionaryRef
                      userInfo)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScreenRecordStarted" object:nil];
    });
}

void broadcastFinished(CFNotificationCenterRef center,
                      void *observer, CFStringRef name,
                      const void *object, CFDictionaryRef
                      userInfo)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScreenRecordFinished" object:nil];
    });
}

- (void)handleScreenRecordStartedNotification:(NSNotification *)notify
{
    _startScreenRecord = YES;
    [self.roomMgr startScreenShare:kAppGroup];
}

- (void)handleScreenRecordFinishedNotification:(NSNotification *)notify
{
//    UIButton *btn = self.funBtns[4];
//    btn.selected = NO;
    _startScreenRecord = NO;
    [self.roomMgr stopScreenShare];
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
//                             //扬声器
                             if (!button.selected) {
                                 _timerCount = 0;
                                 [weakSelf.roomMgr useLoudSpeaker:YES];
                             } else {
                                 _timerCount = 0;
                                 [weakSelf.roomMgr useLoudSpeaker:NO];
                             }
                             
                         }},
                       // 开始或停止音频录制
                       @{@"imageNomal":[UIImage imageNamed:@"recordAudio_start"],
                         @"imageSelect":[UIImage imageNamed:@"recordAudio_stop"],
                         @"block":^(UIButton* button){
//                             NSDictionary *dic = @{@"convert" : @1,
//                                                   @"mixStreamParams" : @{
//                                                           @"template": @2, // 必选，混流布局模板ID，0等分布局; 1画中画布局; 2自定义布局
//                                                           @"backgroundColor": @"#0d69fb", // 颜色值
//                                                           @"customConfig": @{
//                                                                   @"videoLayout": @[
//                                                                           @{
//                                                                               @"uid": @"1131223463fff", // 用户 ID，若为桌面共享的视频，此 ID 为'用户ID:screen'
//                                                                               @"x_coord": @(0.1), // 窗口x坐标，取值为相对于整个视频宽度百分比
//                                                                               @"y_coord": @(0.1), // 窗口y坐标，取值为相对于整个视频高度百分比
//                                                                               @"width": @(0.18), // 窗口宽，取值为相对于整个视频宽度百分比
//                                                                               @"height": @(0.24), // 窗口高，取值为相对于整个视频高度百分比
//                                                                               @"alpha": @(1), // 窗口透明度
//                                                                           }
//                                                                   ]
//                                                           } // 若 template 为2则必选，自定义布局时生效，包括布局参数和其他附加参数；template 为2以外的其他值，此参数无效，可不填
//                                                   }};
//
//                             [self.roomMgr startServerRecord:dic expiresabs:0 expires:0];
                            _timerCount = 0;
                             if (button.selected) {
                                 NSArray *cachesPathArr = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                 NSString *cachesPath = cachesPathArr.firstObject;
                                 NSString *path = [cachesPath stringByAppendingPathComponent:@"audioRecord.mp3"];
                                 BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
                                 if (!exist) {
                                     [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
                                 }
                                 [self.roomMgr startAudioRecord:path];
                             } else {
                                 [self.roomMgr stopAudioRecord];
                             }
                         }},
                       //开启或停止屏幕共享
//                       @{@"imageNomal":[UIImage imageNamed:@"startshare"],
//                         @"imageSelect":[UIImage imageNamed:@"stopshare"],
//                         @"block":^(UIButton* button){
//                            _timerCount = 0;
//                             if (button.selected) {
//                                 if (_startScreenRecord) {
//                                     [self.roomMgr startScreenShare:kAppGroup];
//                                 } else {
//                                     NSString *msg = @"1 >iOS12.0以下系统：需要在设置->控制中心->自定控制->添加屏幕录制。然后从手机底部上划，推出系统控制中心，长按屏幕录制按键，选择TKScreenRecord。\n2 >iOS12.0及以上系统：可以点击屏幕右侧开启屏幕直播按钮开启直播（从下往上数第二个按钮）；也可以选择1>的方式开启录制。\n然后点击开始直播按钮，3秒后，系统会自动开启屏幕录制（屏幕顶端出现红条即表示已开启屏幕录制）";
//                                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"屏幕直播未开启" message:msg preferredStyle:UIAlertControllerStyleAlert];
//                                     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//                                     [alertController addAction:cancelAction];
//                                     [self presentViewController:alertController animated:YES completion:nil];
//                                     button.selected = !button.selected;
//                                 }
//                             } else {
//                                 if (_startScreenRecord) {
//                                     [self.roomMgr stopScreenShare];
//                                         //通知屏幕采集进程 停止屏幕直播
//                                     CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
//                                                                          CFSTR("stopScreenRecord"),NULL,nil,YES);
//                                     _startScreenRecord = NO;
//                                 } else {
//                                     button.selected = !button.selected;
//                                 }
//                             }
//                         }},
                       @{@"imageNomal":[UIImage imageNamed:@"open_small"],
                         @"imageSelect":[UIImage imageNamed:@"close_small"],
                         @"block":^(UIButton* button){
                            _timerCount = 0;
                            [self.roomMgr enableDualStream:button.selected];
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
                       @{@"screen":@(YES),
                         @"imageNomal":[UIImage imageNamed:@"startshare"],
                         @"imageSelect":[UIImage imageNamed:@"stopshare"],
                         @"block":^(UIButton* button) {
                             if (@available(iOS 12.0, *)) {
                                 UIButton *btn = [self findButtonFromSupperView:_broadcastView];
                                 [btn sendActionsForControlEvents:UIControlEventAllTouchEvents];
                             } else {
                                 NSString *msg = @"当前系统版本低于iOS 12.0，暂不能使用屏幕直播功能。可以选择升级设备系统版本至iOS 12.0及以上版本，以便使用屏幕直播功能。";
                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"未能开启屏幕直播" message:msg preferredStyle:UIAlertControllerStyleAlert];
                                 UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                                 [alertController addAction:cancelAction];
                                 [self presentViewController:alertController animated:YES completion:nil];
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
        id screen = [dic objectForKey:@"screen"];
        if (!screen) {
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
        } else {
            if (@available(iOS 12.0, *)) {
//                RPSystemBroadcastPickerView *broadcastView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, i *(width + gap), width, width)];
//                broadcastView.preferredExtension = @"com.talkcloud.sdkDemo.TKScreenRecord";
//                broadcastView.showsMicrophoneButton = NO;
//                broadcastView.backgroundColor = [UIColor redColor];
//                broadcastView.alpha = 0.5;
//                [self.listView addSubview:broadcastView];
                _broadcastView = [_roomMgr createRPSystemBroadcastPickerViewWithFrame:CGRectMake(0, i *(width + gap), width, width) preferredExtension:@"com.talkcloud.sdkDemo.TKScreenRecord"];
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, i *(width + gap), width, width)];
                [button setSelected:false];
                UIImage *imageNomal = [dic objectForKey:@"imageNomal"];
//                UIImage *imageSelect = [dic objectForKey:@"imageSelect"];
                [button setImage:imageNomal forState:(UIControlStateNormal)];
                [button setImage:imageNomal forState:(UIControlStateSelected)];
                [button setTag:bt.count];
                button.hidden = YES;
                [bt addObject:button];
                [button addTarget:self action:@selector(listViewBtn:) forControlEvents: UIControlEventTouchUpInside];
                [self.listView addSubview:button];
                 i++;
            }
        }
    }
    self.funBtns = [bt copy];
    return nil;
}

- (UIButton *)findButtonFromSupperView:(UIView *)view {
    if(!_broadcastView.subviews.count) {
        return nil;
    }
    UIButton *btn = nil;
    if ([view isKindOfClass:[UIButton class]]) {
        btn = (UIButton *)view;
        return btn;
    }
    for(UIView *subView in view.subviews) {
        UIView *desView = [self findButtonFromSupperView:subView];
        if (desView) {
            btn = (UIButton *)desView;
            break;
        }
    }
    return btn;
}

- (void)listViewBtn:(UIButton *)button {
    
    [button setSelected:!button.isSelected];
    ButtonAction block = (ButtonAction)[((NSDictionary*)self.funBtnDes[button.tag]) objectForKey:@"block"];
    if (block) {
        block(button);
    }
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
//        [_roomMgr setSmallStreamParameter:videoProfile];
    }];
    [_alert addAction:action1];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"176X132" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TKVideoProfile *videoProfile = [TKVideoProfile new];
        videoProfile.width = 176;
        videoProfile.height = 132;
        videoProfile.maxfps = 15;
        [_roomMgr setVideoProfile:videoProfile];
//        [_roomMgr setSmallStreamParameter:videoProfile];
    }];
    [_alert addAction:action2];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"320X240" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TKVideoProfile *videoProfile = [TKVideoProfile new];
        videoProfile.width = 320;
        videoProfile.height = 240;
        videoProfile.maxfps = 15;
        [_roomMgr setVideoProfile:videoProfile];
//        [_roomMgr setSmallStreamParameter:videoProfile];
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
//    self.broadcastView.frame = CGRectMake(0, 100, 200,50);
}

#pragma mark - 获取摄像头麦克风权限以及初始化课堂

#define kAppId  @"tkpaastx"//@"bo" // <#企业domain#>
#define kAuthkey @"oY5VHQ7QSwRGVJO1"//@"M6FPPO1lJYTx4iX1" // <#企业Authkey#>
- (void)initAVAndinitClass
{
    if (!self.host || self.host.length == 0) {
        self.host = @"global.talk-cloud.net";
    }
    [_roomMgr setLogLevel:TKLogLevelInfo logPath:nil debugToConsole:YES];
    TKRoomConfig *config = [[TKRoomConfig alloc] init];
    config.tk_use_secure_socket = YES;
    config.tk_host = self.host;
    config.tk_port = config.tk_use_secure_socket ? @"443" : @"80";
    config.autoRecvAudio = YES;
    [_roomMgr initWithAppID:kAppId optional:config];
    [_roomMgr registerRoomManagerDelegate:self];
    [_roomMgr registerMediaDelegate:self];
    NSString *password = @"";
    if (self.password) {
        password = self.password;
    }
    NSString *userid = @"xxabcdef1235";
    TKRoomParams *roomParams = [[TKRoomParams alloc] init];
    roomParams.roomId = self.roomid;
    roomParams.userPwd = password;
    TKUserParams *userParams = [[TKUserParams alloc] init];
    userParams.userId = userid;
    userParams.roleId = [self.role integerValue];
    userParams.nickName = @"iost2";
    [_roomMgr joinRoom:roomParams userParams:userParams];
    
    TKRoomExParams *roomExParams = [[TKRoomExParams alloc] init];
    roomExParams.roomId = @"2567856";//self.roomid;
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *val = [[NSString alloc] initWithFormat:@"appId=%@&thirdRoomId=%@&userId=%@&ts=%.0f&expireTs=%d", kAppId, roomExParams.roomId, userid, ts, 7 * 3600];
    NSString *token = [GenerateUserSig AES128_CBCEncryptWithKey:kAuthkey iv:kAuthkey encrypt:val];
    roomExParams.token = token;
    roomExParams.roomType = 1;
//    [_roomMgr joinRoomEx:roomExParams userParams:userParams];
    [_roomMgr setVideoOrientation:UIDeviceOrientationPortrait];
    [_roomMgr setLocalVideoMirrorMode:TKVideoMirrorModeAuto];
    TKUILogInfo(@"initAVAndinitClass = %@", _roomid);
    
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
    if ([_userViews objectForKey:[_roomMgr getUserManager].myID]) {
       
        VideoView *videoView = (VideoView *)_userViews[[_roomMgr getUserManager].myID];
        videoView.frame = CGRectMake(self.view.frame.size.width-self.view.frame.size.width/4-20, 20, self.view.frame.size.width/4, self.view.frame.size.width/3);
//        videoView.transform = CGAffineTransformMakeRotation(M_PI_2);
         [dict removeObjectForKey:[_roomMgr getUserManager].myID];
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
    for (NSString *uid in self.tmp) {
        UILabel *label = self.tmp[uid];
        [self.view bringSubviewToFront:label];
    }
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

- (void)toggleButton:(UIButton *) button
{
    if (button.tag == 0 && self.isOnlyAuido && [_roomMgr getUserManager].localUser.publishState != 0) {
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
    
    if (_startScreenRecord) {
//        [self.roomMgr startScreenShare:kAppGroup];
    }
    _myID = [_roomMgr getUserManager].myID;
//    [self playVideo:_roomMgr.localUser deviceId:nil];
    
    
}

- (void)roomManagerDidOccuredError:(NSError *)error
{
    NSLog(@"roomManagerDidOccuredError = %@", error);
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
//        [_videoBlock clean];
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
       int ret = [_roomMgr leaveRoom:NO Completion:^(NSError *error) {
            if (error) {
                NSLog(@"leave room error:%@", error);
            }
        }];
        
        
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
//    [TKPlaybackManager destory];
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
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         CFSTR("stopScreenRecord"),NULL,nil,YES);
//    [self initView];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
//    [_roomMgr unPlayAudio:@"" completion:nil];
}

- (void)roomManagerOnUserAudioStatus:(NSString *)peerID state:(TKMediaState)state
{
    if ([peerID isEqualToString:_myID]) {
        UIButton *audio = _controlButtons[1];
        audio.selected = !state;
    }
//    if (state == TKMedia_Pulished) {
//        [_roomMgr playAudio:peerID completion:nil];
//    } else {
//        [_roomMgr unPlayAudio:peerID completion:nil];
//    }
}

- (void)roomManagerOnUserVideoStatus:(NSString *)peerID state:(TKMediaState)state
{
    NSLog(@"roomManagerOnUserVideoStatus");
    if ([peerID isEqualToString:_myID]) {
        UIButton *video = _controlButtons[0];
        video.selected = !state;
            //        [self.roomMgr leaveRoom:nil];
//        return;
    }
    if (state == TKMedia_Pulished) {
        TKRoomUser *user = [[_roomMgr getUserManager] getUserWithPeerID:peerID];
        
//        [self.roomMgr setRemoteDefaultVideoStreamType:TKVideoStream_Small];
        [self playVideo:user deviceId:nil];
    } else {
        [self unPlayVideo:peerID deviceId:nil];
    }
    
}

- (void)roomManagerOnUserVideoStatus:(NSString *)peerID deviceId:(NSString *)deviceId state:(TKMediaState)state
{
    if ([peerID isEqualToString:_myID]) {
        UIButton *video = _controlButtons[0];
        video.selected = !state;
        
//         return;
    }
    if (state == TKMedia_Pulished) {
        TKRoomUser *user = [[_roomMgr getUserManager] getUserWithPeerID:peerID];
        [self playVideo:user deviceId:deviceId];
    } else {
        [self unPlayVideo:peerID deviceId:deviceId];
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
    
    if ([msgName isEqualToString:@"TK_SpeechToText"]) {
        NSArray *tmp = (NSArray * )data;
        for (NSDictionary *dic in tmp) {
            NSString *uid = dic[@"userId"];
            if (!uid) {
                continue;
            }
            TKRoomUser *user = [_roomMgr getRoomUserWithUId:uid];
            UILabel *autoSpeechRecognitionLabel = self.tmp[uid];
            if (autoSpeechRecognitionLabel) {
                autoSpeechRecognitionLabel.text = [NSString stringWithFormat:@"%@ : %@", user.nickName? user.nickName : uid, dic[@"text"]];
            } else {
                autoSpeechRecognitionLabel = [self createLabel];
                autoSpeechRecognitionLabel.text = [NSString stringWithFormat:@"%@ : %@", user.nickName? user.nickName : uid, dic[@"text"]];
                [self.tmp setObject:autoSpeechRecognitionLabel forKey:uid];
            }
        }
    }
}

- (UILabel *)createLabel {
    NSInteger width = self.view.bounds.size.width;
    UILabel *autoSpeechRecognitionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 50 + _autoSpeechRecognitionCount * 30, width, 30)];
    autoSpeechRecognitionLabel.textAlignment = NSTextAlignmentLeft;
    autoSpeechRecognitionLabel.textColor = UIColor.orangeColor;
    autoSpeechRecognitionLabel.backgroundColor = UIColor.clearColor;
    autoSpeechRecognitionLabel.text = @"自动语音文本翻译";
    [self.view addSubview:autoSpeechRecognitionLabel];
    
    _autoSpeechRecognitionCount++;
    [self.view bringSubviewToFront:autoSpeechRecognitionLabel];
    return autoSpeechRecognitionLabel;
}

- (NSMutableDictionary *)tmp {
    if (!_tmp) {
        _tmp = [NSMutableDictionary dictionary];
    }
    return _tmp;
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
    video.selected = !([_roomMgr getUserManager].localUser.publishState == TKUser_PublishState_VIDEOONLY ||
                       [_roomMgr getUserManager].localUser.publishState == TKUser_PublishState_BOTH);
    // 禁用/启动 视频按钮
    video.enabled = !onlyAudio;
    
    // 音频按钮
    UIButton *audio = _controlButtons[1];
    audio.selected = !([_roomMgr getUserManager].localUser.publishState == TKUser_PublishState_AUDIOONLY ||
                       [_roomMgr getUserManager].localUser.publishState == TKUser_PublishState_BOTH);
    
    self.isOnlyAuido = onlyAudio;
    NSString *log = nil;
    
    if (onlyAudio) {
        log = @"💚房间已切换成纯音频房间💚";
        if ([_roomMgr getUserManager].localUser.publishState != 0) {
            if(_publishView) {
                [_publishView bringSubviewToFront:_publishView.imageView];
                [self unPlayVideo:_myID deviceId:nil];
            }
        }
    } else {
        log = @"💚房间已切换成音视频房间💚";
        if ([_roomMgr getUserManager].localUser.publishState == TKUser_PublishState_BOTH ||
            [_roomMgr getUserManager].localUser.publishState == TKUser_PublishState_VIDEOONLY)
        {
            [self playVideo:[[_roomMgr getUserManager] getUserWithPeerID:_myID] deviceId:nil];
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

- (void)roomManagerOnAudioVolumeWithPeerID:(NSString *)peeID volume:(int)volume {
//    NSLog(@"roomManagerOnAudioVolumeWithPeerID peerID = %@, volume = %d", peeID, volume);
}

#pragma mark meidia
- (void)roomManagerOnShareMediaState:(NSString *)peerId
                               state:(TKMediaState)state
                    extensionMessage:(NSDictionary *)message
{
//    if (state == TKMedia_Pulished) {
//        if (!self.publishView) {
//            self.publishView = [[VideoView alloc] initWithRoomMgr:_roomMgr roomUser:_roomMgr.localUser   deviceId:nil];
//            [self.view addSubview:self.publishView];
//        }
//        [_roomMgr playMediaFile:peerId renderType:TKRenderMode_adaptive window:self.publishView completion:^(NSError *error) {
//        }];
//        [self.roomMgr setRemoteAudioVolume:1 peerId:peerId type:TKMediaSourceType_media];
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
{
    if ([peerId isEqualToString:self.myID]) {
        return;
    }
    NSString *extensionId = [NSString stringWithFormat:@"%@:screen", peerId];
    if (state == TKMedia_Pulished) {
        [self playVideo:[[TKRoomUser alloc] initWithPeerId:extensionId] deviceId:nil];
    } else {
        [self unPlayVideo:extensionId deviceId:nil];
    }
}

- (void)roomManagerOnShareFileState:(NSString *)peerId
                              state:(TKMediaState)state
                   extensionMessage:(NSDictionary *)message
{
    if (state == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [self.view addSubview:view];
        [_roomMgr playFile:peerId renderType:TKRenderMode_fit window:view completion:^(NSError *error) {
                
        }];
    } else {
        NSLog(@"2222");
    }
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

- (void)roomManagerOnRtcStatsReport:(TKRtcStats *)stats
{
    
}


- (void)roomManagerOnFirstAudioFrameWithPeerID:(NSString *)peerID mediaType:(TKMediaType)type
{
    if ([peerID isEqualToString:[_roomMgr getUserManager].myID]) {
//        NSLog(@"自己 OnFirstAudioFrame mediaType = %ld", type);
    } else {
//        NSLog(@"远端 OnFirstAudioFrame mediaType = %ld", type);
    }
}

- (void)roomManagerOnFirstVideoFrameWithPeerID:(NSString *)peerID width:(NSInteger)width height:(NSInteger)height mediaType:(TKMediaType)type
{
    if ([peerID isEqualToString:[_roomMgr getUserManager].myID]) {
//        NSLog(@"自己 OnFirstVideoFrame width = %ld height = %ld mediaType = %ld",width, height, type);
    } else {
//        CFAbsoluteTime cur = CFAbsoluteTimeGetCurrent() - _start;
//        NSLog(@"远端 OnFirstVideoFrame 渲染时间%f", cur);
//        NSLog(@"远端 OnFirstVideoFrame width = %ld height = %ld mediaType = %ld",width, height, type);
    }
}

//视频画面状态回调
- (void)roomManagerOnVideoStateChange:(NSString *)peerId
                             deviceId:(NSString *)deviceId
                           videoState:(TKRenderState)state
                            mediaType:(TKMediaType)type
{
    NSLog(@"videostate peerId = %@, state = %zd", peerId, state);
}


#pragma mark - TKMediaFrameDelegate

- (void)onCaptureAudioFrame:(TKAudioFrame *)frame sourceType:(TKMediaType)type
{
//    NSLog(@"自己 onCaptureAudioFrame = %@", frame);
}

- (void)onCaptureVideoFrame:(TKVideoFrame *)packet sourceType:(TKMediaType)type
{
//    NSLog(@"自己 onCaptureVideoFrame width = %ld, height = %zd", (long)packet.width, packet.height);
//    memset(packet.uBuffer, 128, packet.uStride * packet.height / 2);
//    memset(packet.vBuffer, 128, packet.vStride * packet.height / 2);
//    memset(packet.yBuffer, 128, packet.yStride * packet.height);
    
}

- (void)onRenderAudioFrame:(TKAudioFrame *)frame uid:(NSString *)peerId sourceType:(TKMediaType)type
{
//    NSLog(@"peerId= %@, onRenderAudioFrame = %@",peerId, frame);
}

- (void)onRenderVideoFrame:(TKVideoFrame *)packet uid:(NSString *)peerId sourceType:(TKMediaType)type
{
//    NSLog(@"peerId= %@, onRenderVideoFrame = %@",peerId, frame);
//    NSLog(@"onRenderVideoFrame width = %ld, height = %zd", (long)packet.width, packet.height);
//    memset(packet.uBuffer, 128, packet.uStride * packet.height / 2);
//    memset(packet.vBuffer, 128, packet.vStride * packet.height / 2);
//    memset(packet.yBuffer, 128, packet.yStride * packet.height);
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

//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait;
//}

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
//    _myID = view.roomUser.peerID;
    
    // 1. 缩小
    [self.videoBlock addVideo:self.publishView];
    [self setUI2Front];
    
    self.publishView = view;
}

- (void)switchDuaStream:(NSNotification *)notify
{
    NSDictionary *dic = notify.userInfo; 
    TKVideoStreamType type = (TKVideoStreamType)[dic[@"type"] integerValue];
    NSString *msg = @"已切换成大流";
    if (type == TKVideoStream_Small) {
        msg = @"已切换成小流";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confAction];
    [self presentViewController:alertController animated:YES completion:nil]; 
}
#pragma mark - 懒加载 聊天视图
- (ChatView *)chatView {
//    CGRectGetMaxY(_listView.frame) + 10
//     self.view.height - (CGRectGetMaxY(_listView.frame) + 10)
    if (!_chatView) {
        _chatView = [[ChatView alloc] initWithFrame:CGRectMake(0,
                                                               self.view.height * 2 / 3,
                                                               self.view.width,
                                                               self.view.height / 3)];
        [[UIApplication sharedApplication].keyWindow addSubview:_chatView];
    }
    return _chatView;
}

- (void)dealloc {
    NSLog(@"dealloc!!!!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error API_AVAILABLE(ios(10.0), tvos(10.0))
{
    [self.broadcastAVC dismissViewControllerAnimated:YES completion:nil];
    
    self.broadcastController = broadcastController;
    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
//            self.liveButton.selected = YES;
        } else {
            NSLog(@"startBroadcastWithHandler error: %@", error);
        }
    }];
}

@end
