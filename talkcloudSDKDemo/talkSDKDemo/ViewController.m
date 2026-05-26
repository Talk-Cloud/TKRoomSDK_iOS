//
//  ViewController.m
//  classdemo
//
//  Created by mac on 2017/4/28.
//  Copyright © 2017年 talkcloud. All rights reserved.
//

#import "ViewController.h"
#import "RoomController.h"
#include <netdb.h>
#include <arpa/inet.h>

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    NSFileHandle *_currentLogFileReadHandle;
    dispatch_source_t _currentLogFileReadVnode;
}
@property (weak, nonatomic) IBOutlet UITextField *host;
@property (nonatomic, assign) BOOL autoSubscribe;
@property (weak, nonatomic) IBOutlet UITextField *roomId;
@property (weak, nonatomic) IBOutlet UITextField *role;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (nonatomic, strong) NSString *web;

@property (assign, nonatomic) BOOL enableDua;

@property (strong, nonatomic) CTCallCenter *callcenter;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _autoSubscribe = YES;
    _enableDua = YES;
    NSString *str = [NSString stringWithFormat:@"%s", TKRoomSDKVersionString];

    NSLog(@"TKRoomSDK Version:%@", str);
    
    NSString *roomid = [[NSUserDefaults standardUserDefaults] objectForKey:@"roomid"];
    if (roomid) {
        _roomId.text = roomid;
    }
    NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
    if (host) {
        _host.text = host;
    }
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(willResignActive)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(didBecomeActive)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];

    
    NSNumber *number = [NSNumber numberWithBool:YES];
    
//    OSStatus re = AudioOutputUnitStart();
//    Failed to start audio unit.
    
    NSLog(@"number 1 = %@", [number class]);
    NSLog(@"number 2 = %@", [@(YES) class]);
    NSLog(@"number 3 = %@", [@(FALSE) class]);
    [self randomString:4];
    
    //1、得到当前屏幕的尺寸：
    CGRect rect_screen = [[UIScreen mainScreen] bounds];
    CGSize size_screen = rect_screen.size;

    //2、获得scale：iPhone5和iPhone6是2，iPhone6Plus是3
    CGFloat scale_screen = 2.6;//[UIScreen mainScreen].nativeScale;
    NSLog(@"scale_screen:%.f", scale_screen);

    //3.获取当前屏幕的分辨率
    CGFloat widthResolution = size_screen.width * scale_screen;
    CGFloat heightResolution = size_screen.height * scale_screen;
    NSLog(@"widthResolution 3 = %f， heightResolution = %f", widthResolution, heightResolution);
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    int a = [self getIntValueFromDic:@{@"room" : @{}} Key:@"result"];
    NSLog(@"a = %d", a);
}


- (int)getIntValueFromDic:(NSDictionary*)dic Key:(NSObject *)key
{
    if (!dic || !key) {
        return -2;
    }
    id value = [dic objectForKey:key];
    if (value && ([value isKindOfClass:[NSNumber class]]
                  || [value isKindOfClass:[NSString class]])) {
        return [value intValue];
    }
    
    return -2;
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



- (NSString *)randomString:(NSInteger)number {
    NSString *ramdom;
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i ; i ++) {
        int a = (arc4random() % 122);
        if ((a >= 65 && a <= 90) || a > 96||(a >=48 &&a<=57)) {
            char c = (char)a;
            [array addObject:[NSString stringWithFormat:@"%c",c]];
            if (array.count == number) {
                break;
            }
        } else continue;
    }
    ramdom = [array componentsJoinedByString:@""];
    return ramdom;
}


- (void)didBecomeActive {
//    NSLog(@"kkkkkk didBecomeActive");
}

- (void)willResignActive {
    NSLog(@"kkkkkk willResignActive");
}

- (void)viewDidLayoutSubviews {

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (BOOL)shouldAutorotate
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (IBAction)hostTextField:(UITextField *)sender
{
    if (sender.text && sender.text.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:sender.text forKey:@"host"];
    }
}

- (IBAction)roomIDTextField:(UITextField *)sender
{
    if (sender.text && sender.text.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:sender.text forKey:@"roomid"];
    }
}
- (IBAction)enableDuaStream:(UISwitch *)sender {
    self.enableDua = sender.isOn;
}

- (IBAction)onClickedStart:(UIButton *)sender {
//
    RoomController* pop = [[RoomController alloc] init];

    pop.roomid = self.roomId.text;
    if (!pop.roomid || pop.roomid.length == 0) {
        return;
    }

    pop.role = self.role.text;
    if (!pop.role || pop.role.length == 0) {
        return;
    }
    pop.host = self.name.text;
    pop.password = self.password.text;
    pop.enableDua = self.enableDua;
    pop.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pop animated:YES completion:nil];
    


}

@end
