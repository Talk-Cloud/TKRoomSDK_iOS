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
@property (nonatomic, assign) BOOL autoSubscribe;
@property (weak, nonatomic) IBOutlet UITextField *roomId;
@property (weak, nonatomic) IBOutlet UITextField *role;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *name;


@end
#define YY_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _autoSubscribe = YES;

    NSString *str = [NSString stringWithFormat:@"%s", TKRoomSDKVersionString];
    for (int i = 0; i < 50; i++) {
        
        NSInteger reconn_made = MIN(i, 15);//protect the pow result to be too big.
        NSLog(@"reconn_made = %d", (int)reconn_made);
        CGFloat time = MIN(powf(1.5, i), 30);
        NSLog(@"time = %f", time);
    }
    
}

- (void)viewDidLayoutSubviews {
    //[_button setFrame:CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 200, 50)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"device":@"1",@"UserName":@"abc123",@"UserPwd":@"abcdef"} options:NSJSONWritingPrettyPrinted error:nil];;
//    NSString *msg =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    [_enc sendMessageToJS:msg key1:@"ecpex" key1:@"yph" key1:@"app"];
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
