#  SDK版本说明：
        1、可以支持armv7、arm64、i386、x86_64等CPU架构；
        2、支持iOS9.0及以上系统版本运行。
        3、Installation with CocoaPods
            Podfile
            platform:ios,'9.0'
            pod 'TKRoomSDK', '~> 3.2.15'
#  SDK版本更新说明
时间：2020.03.19
版本号：3.2.15
1、添加服务器录制接口;
2、修复bug;

时间：2019.12.24
版本号：3.2.11
1、修复录制 音视频同步问题;
2、修复webRtc 引发的崩溃问题;

时间：2019.11.11
版本号：3.2.10
1、修复弱网下 joinRoom 问题;
2、修复回放下 视频丢失问题;
3、添加自动录制;

时间：2019.07.12
版本号：3.2.9
1、修复杀死进程 崩溃的问题;
2、playVideo 加入镜像模式;

时间：2019.06.17
版本号：3.2.8
1、添加 课件预加载逻辑;
2、修复播放音频线程卡死的问题;

时间：2019.04.1
版本号：3.2.7
1、添加 大小码流;

时间：2019.02.22
版本号：3.2.6
1、修复socket 关闭可能引发的崩溃问题;

时间：2019.02.19
版本号：3.2.5
1、添加 音视频播放时中断回调;

时间：2019.01.11
版本号：3.2.4
1、修复媒体链路断开后未能重新发布问题;

时间：2019.01.26
版本号：3.2.3
1、修复停止录音偶现崩溃问题；

时间：2019.01.11
版本号：3.2.2
1、修复切到后台模式，openGLES视频渲染偶现崩溃问题；
2、添加本地录制音频接口；
3、优化sdk音视频发布.

时间：2018.12.14
版本号：3.2.0

1、添加加入即时房间接口；
2、添加播放媒体音视频接口（本地和网络均可）；
3、优化sdk音视频发布.

时间：2018.10.19
版本号：3.1.0

1、添加日志上传；
2、添加混音接口；
3、深度优化SDK.

时间：2018.10.19
版本号：3.0.1


1、添加支持SDK播放多流视频
2、优化SDK接口；
3、优化SDK媒体链路；


时间：2018.08.31
版本号：2.2.12

1、优化播放媒体共享网络链路
2、优化兼容32位机型设备
3、优化接口文件


时间：2018.08.27
版本号：2.2.11

1、sdk去swift，优化网络层;
2、优化设置视频分辨率.
3、添加网络掉线回调- (void)roomManagerOnConnectionLost;

时间：2018.08.20
版本号：2.2.10

1、优化自动选择服务器;
2、添加进入房间时，http重连机制;
3、修复bug，优化sdk.
        
版本号：2.2.9
时间：2018.07.30
1、添加TKRoomManagerDelegate代理回调函数

    1.1、添加播放视频时第一帧回调 
    - (void)roomManagerOnFirstVideoFrameWithPeerID:(NSString *)peerID width:(NSInteger)width height:(NSInteger)height mediaType:(TKMediaType)type;
    1.2、添加播放音频时第一帧回调
    - (void)roomManagerOnFirstAudioFrameWithPeerID:(NSString *)peerID mediaType:(TKMediaType)type;
    
2、修改TKRoomManager接口函数

        2.1、添加设置日志等级接口参数：
         参数debug表示： debug模式：控制台打印，release模式：控制台不打印。
        + (int)setLogLevel:(TKLogLevel)level logPath:(NSString * _Nullable)logPath debugToConsole:(BOOL)debug;
        
3、优化自动选择服务器 ，修复SDK bug，优化接口。


版本号：2.2.8
时间：2018.07.20

1、修改TKRoomManager 接口函数

    1.1、修改 + (int)setLogLevel:(TKLogLevel)level logPath:(NSString *)logPath;完善将日志写入沙盒功能。默认路径为：沙盒Documents/TKLog
    1.2、添加 - (int)initWithAppKey:(NSString *)appKey optional:(NSDictionary * _Nullable)optional; 设置appID以及设置房间扩展信息。
    即将废弃 - (int)registerAppKey:(NSString *)appKey;接口。

版本号：2.2.7
时间：2018.07.17

1、添加sdk工具类TKUtils

    1.1、+ (NSInteger)getCPUCores; 获取cpu核数
    1.2、+ (NSString *)getCPUType; 获取cpu类型
    1.3、+ (NSString *)getCPUUsage;获取cpu使用率
    1.4、+ (NSUInteger)getTotalMemory; 获取总物理内存
    1.5、+ (NSUInteger)getResidentMemory; 获取当前App内存使用
2、添加TKRoomManagerDelegate回调函数

    2.1添加 纯音频 与音视频 教室切换的回调
    - (void)roomManagerOnAudioRoomSwitch:(NSString *)fromId onlyAudio:(BOOL)onlyAudio;


版本号：2.2.6
时间：2018.07.13
1、添加TKRoomManagerDelegate回调函数

    1.1、添加视频数据统计回调  
        - (void)roomManagerOnVideoStatsReport:(NSString *)peerId stats:(TKVideoStats *)stats;
    1.2、添加音频数据统计回调
        - (void)roomManagerOnAudioStatsReport:(NSString *)peerId stats:(TKAudioStats *)stats;

版本号：2.2.5
时间：2018.07.05
1、修改TKRoomManager 接口函数

    1.1、添加 - (int)setLogLevel:(TKLogLevel)level logPath:(NSString *)logPath;设置sdk日志打印等级和写入沙盒文件
2、修复bug

    2.1、修复SDK请求 摄像头 和 麦克风 授权，以及授权失败的回调，- (void)roomManagerDidOccuredWaring:(TKRoomWarningCode)code; code码参照TKRoomWarningCode中TKRoomWarning_RequestAccessForVideo_Failed和TKRoomWarning_RequestAccessForAudio_Failed；授权失败亦可进入房间。
    2.2、修复测试bug。


版本号：2.2.4
时间：2018.06.25
1、添加音视频数据回调函数代理 protocol：TKMediaFrameDelegate

    - (void)onCaptureAudioFrame:(TKAudioFrame *)frame sourceType:(TKMediaType)type;

    - (void)onCaptureVideoFrame:(TKVideoFrame *)frame sourceType:(TKMediaType)type;

    - (void)onRenderAudioFrame:(TKAudioFrame *)frame uid:(NSString *)peerId sourceType:(TKMediaType)type;

    - (void)onRenderVideoFrame:(TKVideoFrame *)frame uid:(NSString *)peerId sourceType:(TKMediaType)type;
    接口详情说明见，TKRoomDelegate.h 头文件注释；

2、修改TKRoomManagerDelegate回调接口

    2.1 删去TKRoomManagerDelegate代理回调 - (void)roomManagerRoomJoined(NSError *error)接口中error参数，更新后接口为 - (void)roomManagerRoomJoined;
    2.2 添加 - (void)roomManagerOnAudioVolumeWithPeerID:(NSString *)peeID volume:(int)volume;关于音频音量的实时回调接口；

3、修改TKRoomManager 接口函数

    3.1 修改 - (int)registerRoomWhiteBoardDelegate:(id<TKRoomManagerDelegate> _Nullable)roomDelegate andWB:(BOOL)notifyWB;
    关于修改白板代理设置参数说明：
    如需要接受白板消息，notifyWB设置为YES，并且监听TKRoomWhiteBoardNotification.h头文件中的白板相关的通知；
    否则可以设置notifyWB为NO，并且不会收到TKRoomWhiteBoardNotification相关的白板消息通知；
    
    3.2 添加 - (int)registerMediaDelegate:(id<TKMediaFrameDelegate> _Nullable)mediaDelegate;
    设置音视频数据回调的代理；
    
    3.3 添加 - (int)setVideoOrientation:(UIDeviceOrientation)orientation; 设置视频采集方向；

    3.4 添加 - (int)registerAppKey:(NSString *)appKey;设置AppID，留以后扩展使用；
    3.5 修复插入耳机进房间，音频可以切换到耳机模式；
    3.6 修改 - (int)enableAudio:(BOOL)enable;接口不能关闭自己音频问题；
    
4、SDK添加支持模拟器调试，可以支持armv7、arm64、i386、x86_64 。

版本号：2.2.0
时间：历史版本
