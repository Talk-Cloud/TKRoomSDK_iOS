//
//  VideoView.m
//  TalkSDKDemo
//
//  Created by MAC-MiNi on 2018/3/19.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import "VideoView.h" 


@interface VideoView()<UIGestureRecognizerDelegate>
@property (nonatomic) BOOL isViewHidden;
@property (nonatomic, weak) TKRoomManager *mgr;
@property (strong, nonatomic)  UILabel *nameLabel;



@end

#define kViewW self.frame.size.width
#define kViewH self.frame.size.height
#define kTipViewH (kViewH / 5)
#define kTipViewW kViewW
@implementation VideoView

- (instancetype)initWithRoomMgr:(TKRoomManager *)mgr roomUser:(TKRoomUser *)user deviceId:(NSString *)deviceId
{
    if ([super init]) {
        _mgr = mgr;
        _roomUser = user;
        _deviceId = deviceId;
//        self.backgroundColor = [UIColor redColor];
        [self createviews];
        
        
    }
    return self;
}
- (void)setVideoBackGroundColor:(UIColor *)color{
     self.imageView.backgroundColor = color;
}


- (void)createviews
{
//    CGFloat w = self.frame.size.width;
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_videoClose"]];
    imageView.backgroundColor = [UIColor colorWithRed:(47)/255.0f green:(47)/255.0f blue:(47)/255.0f alpha:1.0];
    [self addSubview:imageView];
    self.imageView = imageView;
    self.imageView.contentMode = UIViewContentModeCenter;
    
    _contentView = [[UIView alloc] init];
    [self addSubview:_contentView];
  
    _nameLabel = [[UILabel alloc] init];
    [self addSubview:_nameLabel];
    NSString *role = @"我";
    switch (_roomUser.role) {
        case 0:
            role = @"老师";
            break;
        case 1:
            role = @"助教";
            break;
        case 2:
            role = @"学生";
            break;
        case 3:
            role = @"旁听";
            break;
        case 4:
            break;
            
        default:
            break;
    }
    if (_mgr.localUser.peerID == _roomUser.peerID) {
        role = @"我";
    }
}

- (void)setViewsToFront
{
//    [self bringSubviewToFront:_imageView];
    [self bringSubviewToFront:_nameLabel];
}

- (void)layoutSubviews
{
    [_imageView setFrame:self.bounds];
    [_contentView setFrame:self.bounds];
}
@end
