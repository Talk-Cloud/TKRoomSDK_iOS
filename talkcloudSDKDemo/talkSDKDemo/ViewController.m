//
//  ViewController.m
//  classdemo
//
//  Created by mac on 2017/4/28.
//  Copyright © 2017年 talkcloud. All rights reserved.
//

#import "ViewController.h"
#import "RoomController.h"

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

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _autoSubscribe = YES;

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

- (IBAction)onClickedStart:(UIButton *)sender {

    RoomController* pop = [[RoomController alloc] init];
    
    pop.roomid = self.roomId.text;
    if (!pop.roomid || pop.roomid.length == 0) {
        return;
    }
    
    pop.role = self.role.text;
    if (!pop.role || pop.role.length == 0) {
        return;
    }
    pop.name = self.name.text;
    pop.password = self.password.text;
    [self presentViewController:pop animated:YES completion:nil];
}

@end
