//
//  TKRoomManager.h
//  TKRoomSDK
//
//  Created by MAC-MiNi on 2018/3/20.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKRoomDelegate.h"
#import "TKRoomDefines.h"

@class TKRoomUser;
@class RPSystemBroadcastPickerView;
@class TKDeviceManager;
@class TKRoomUserManager;
@class TKVideoCanvas;
@class TKAudioRecordInfo;
@class TKVideoProfile;
@class TKMediaFileParams;

NS_ASSUME_NONNULL_BEGIN

@interface TKRoomManager : NSObject
    ///-----------------------------------
    /// @name Properties
    ///-----------------------------------

/**
 本地用户对象
 */
@property (nonatomic, strong, readonly) TKRoomUser *localUser TK_Deprecated("Will deprecated!!! use TKRoomUserManager‘s localUser");


    ///-----------------------------------
    /// @name Methods
    ///-----------------------------------

/**
 单例
 @return TKRoomManager单例
 */
+ (instancetype)instance;

/**
 销毁TKRoomManager单例
 */
+ (void)destory;

/**
 设置打印SDK日志等级
 
 @param level 日志等级
 @param logPath 日志需要写入沙盒的路径; 默认路径为：nil。
 @param debug 是否时debug模式，debug模式：控制台打印，release模式：控制台不打印。
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setLogLevel:(TKLogLevel)level logPath:(NSString * _Nullable)logPath debugToConsole:(BOOL)debug;

#pragma mark 初始化
/**
 设置AppID
 需要调用此接口初始化房间信息
 @param appID   企业Key值，请在企业后台中查找key值
 @param config 房间扩展信息 相关字段详情见：TKRoomDefines.h文件中 房间初始化相关设置
 */
- (int)initWithAppID:(NSString *)appID optional:(TKRoomConfig *)config;
/**
 更改服务器
 
 @param serverName 更改服务器
 @return 0表示调用成功，非0表示调用失败
 */
- (int)changeCurrentServer:(NSString *)serverName;

- (int)changeCurrentLoaction:(NSString *)locationCode;

/**
 获取服务器列表
 
 @return 0表示调用成功，非0表示调用失败
 */
- (int)getServerList:(void (^)(NSArray *serverList, NSError * _Nullable error))callback;


/**
 设置TKRoomManagerDelegate 代理
 @param roomDelegate 实现了TKRoomManagerDelegate回调接口的对象
 @return 0表示调用成功，非0表示调用失败
 */
- (int)registerRoomManagerDelegate:(id<TKRoomManagerDelegate> _Nullable)roomDelegate;

/**
 设置音视频数据 TKMediaFrameDelegate的代理
 
 @param mediaDelegate 实现了TKMediaFrameDelegate回调接口的对象
 @return 0表示调用成功，非0表示调用失败
 */
- (int)registerMediaDelegate:(id<TKMediaFrameDelegate> _Nullable)mediaDelegate;

/// 设置场景
/// 默认场景：TKAppScene_Call
- (int)setRoomScene:(TKAppScene)scene;

#pragma mark 加入/离开房间

/**
 进入房间 
 */

- (int)joinRoom:(TKRoomParams *)param userParams:(TKUserParams *)userParams;

- (int)joinRoomEx:(TKRoomExParams *)param userParams:(TKUserParams *)userParams;

///// 加入分组
///// @param groupInfo 分组的Info，groupInfo内需要包含“groupId”的key
- (int)joinGroup:(NSDictionary *)groupInfo completion:(completion_block _Nullable)completion;
/**
 离开房间 异步退出房间
 
 @param completion 离开房间后的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)leaveRoom:(completion_block _Nullable)completion;

/**
 离开房间
 
 @param sync YES:同步退出 NO:退出
 @param completion 离开房间后的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)leaveRoom:(BOOL)sync Completion:(completion_block _Nullable)completion;

#pragma mark 房间属性
/**
 获取房间属性
 */
- (NSDictionary *)getRoomProperty;

- (NSDictionary *)getCheckRoomInfo;
/**
 获取房间用户
 @param peerId 用户ID
 @return TKRoomUser
 @return 0表示调用成功，非0表示调用失败
 */
- (TKRoomUser * _Nullable)getRoomUserWithUId:(NSString *)peerId TK_Deprecated("Will deprecated!!! use TKRoomUserManager - (TKRoomUser *)getUserWithPeerID:(NSString *)peerID;");

/**
 获取房间用户列表
 @param options 可以根据需求参数，获取相应的用户列表
    options = @{
             @"start": @(0),                               // 列表中起始坐标，小班课非大房间模式下不支持
             @"max" : @(200),                         // 最大结果个数，小班课非大房间模式下不支持
             @"roles" : @[@0, @1, @2],          // 用户角色数组
             @"nicknameScan" :  @"xxx",        // 用户昵称中的关键字，小班课非大房间模式下不支持
             @"order" :  @"xxx" ,                      // 排序规则，暂时不可用
            }
 @param callback    结果回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)getUserListWithOptions:(NSDictionary * _Nullable)options callback:(void (^)(NSArray <TKRoomUser *> *_Nullable userList, NSError *_Nullable error))callback;

#pragma mark change用户属性
/**
 修改某个用户的一个属性
 
 @param peerID 要修改的用户ID
 @param tellWhom 要将此修改通知给谁。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param key 要修改的用户属性名字，可以是您自定义的名字
 @param value 要修改的用户属性，可以是Number、String、NSDictionary或NSArray
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)changeUserProperty:(NSString *)peerID
                 tellWhom:(NSString *)tellWhom
                      key:(NSString *)key
                    value:(NSObject *)value
               completion:(completion_block _Nullable)completion;

/**
 修改某个用户的一个属性
 
 @param peerID 要修改的用户ID
 @param tellWhom 要将此修改通知给谁。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param data 更改的属性 NSDictionary
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)changeUserProperty:(NSString *)peerID
                 tellWhom:(NSString *)tellWhom
                     data:(NSDictionary *)data
               completion:(completion_block _Nullable)completion;

/**
 修改某个用户的一个属性
 
 @param peerID 要修改的用户ID
 @param tellWhom 要将此修改通知给谁。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param property 更改的属性 NSDictionary
 @param extensionJson  信令需要的携带扩展信息，可nil
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)changeUserProperty:(NSString *)peerID
                 tellWhom:(NSString *)tellWhom
                 property:(NSDictionary *)property
            extensionJson:(NSDictionary * _Nullable)extensionJson
               completion:(completion_block _Nullable)completion;


#pragma mark 发布音视频
/**
 发布自己的视频
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)publishVideo:(completion_block _Nullable)completion;
/**
 停止发布自己的视频
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)unPublishVideo:(completion_block _Nullable)completion;
/**
 发布自己的音频
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)publishAudio:(completion_block _Nullable)completion;

/**
 停止发布自己的视频
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)unPublishAudio:(completion_block _Nullable)completion;

#pragma mark 聊天消息
/**
 发送聊天信息功能函数
 @param message 发送的聊天消息文本 , 支持 NSString 、NSDictionary
 @param toID 发送给谁 , NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param extension 扩展的发送的聊天消息数据,例如：消息类型； 支持 NSString(JSON字符串string) 、NSDictionary
 @return 0表示调用成功，非0表示调用失败
 */
- (int)sendMessage:(NSObject *)message
              toID:(NSString *)toID
     extensionJson:(NSObject * _Nullable)extension;

#pragma mark 音频参数设置
- (BOOL)enableBuiltInAGC:(BOOL)enable;

#pragma mark 信令消息
/**
 发布自定义消息
 
 @param msgName 消息名字
 @param msgID ：消息id
 @param toID 要通知给哪些用户。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param data 消息数据，可以是Number、String、NSDictionary或NSArray
 @param save ：是否保存，详见3.5：自定义信令
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)pubMsg:(NSString *)msgName
        msgID:(NSString *)msgID
         toID:(NSString *)toID
         data:(NSObject * _Nullable)data
         save:(BOOL)save
   completion:(completion_block _Nullable)completion;

    //expires ：这个消息，多长时间结束，以秒为单位，是相对时间。一般用于classbegin，给定一个相对时间
- (int)pubMsg:(NSString *)msgName
        msgID:(NSString *)msgID
         toID:(NSString *)toID
         data:(NSObject * _Nullable)data
         save:(BOOL)save
associatedMsgID:(NSString * _Nullable)associatedMsgID
associatedUserID:(NSString * _Nullable)associatedUserID
      expires:(NSTimeInterval)expires
   completion:(completion_block _Nullable)completion;

- (int)pubMsg:(NSString *)msgName
        msgID:(NSString *)msgID
         toID:(NSString *)toID
         data:(NSObject *)data
         save:(BOOL)save
associatedMsgID:(NSString * _Nullable)associatedMsgID
associatedUserID:(NSString * _Nullable)associatedUserID
      expires:(NSTimeInterval)expires
extensionJson:(NSDictionary * _Nullable)extensionJson
   completion:(completion_block _Nullable)completion;

    //expendData:拓展数据，与msgName同级
- (int)pubMsg:(NSString *)msgName
        msgID:(NSString *)msgID
         toID:(NSString *)toID
         data:(NSObject * _Nullable)data
         save:(BOOL)save
extensionData:(NSDictionary * _Nullable)extensionData
   completion:(completion_block _Nullable)completion;

/**
 删除自定义消息
 @param msgName 消息名字
 @param msgID ：消息id
 @param toID 要通知给哪些用户。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param data 消息数据，可以是Number、String、NSDictionary或NSArray
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)delMsg:(NSString *)msgName
        msgID:(NSString *)msgID
         toID:(NSString *)toID
         data:(NSObject * _Nullable)data
   completion:(completion_block _Nullable)completion;

- (int)delMsg:(NSString *)msgName
        msgID:(NSString *)msgID
         toID:(NSString *)toID
         data:(NSObject * _Nullable)data
extensionJson:(NSDictionary * _Nullable)extensionJson
   completion:(completion_block _Nullable)completion;
#pragma mark 播放音视频
/**
 该方法设置本地视频镜像
 
 @param mode 镜像模式
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setLocalVideoMirrorMode:(TKVideoMirrorMode)mode;
/**
 设置编码器输出的画面镜像模式
 该接口不改变本地摄像头的预览画面，但会改变另一端用户看的画面效果
 @param mirror 是否开启远端镜像，YES: 远端画面镜像；NO：远端画面非镜像。默认值：NO；
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setVideoEncoderMirror:(BOOL)mirror;

/**
 开始预览本地视频， 可以调用多次此函数。当传入的view和上次传入的一致时，函数不执行任何操作，当传入的view和上次传入的不一致时，换用新的view播放该用户的视频
 须在主线程调用。
 @param canvas 视频窗口
 @param completion 设置用于播放视频的view的block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)previewLocalVideo:(TKVideoCanvas *)canvas completion:(void (^)(NSError *error))completion;

/**
 取消预览本地视频
 须在主线程调用。
 @param completion 设置用于播放视频的view的block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)cancelPreviewLocalVideo:(void (^)(NSError *error))completion;

/**
 对同一个用户，可以调用多次此函数。当传入的view和上次传入的一致时，函数不执行任何操作，直接返回成功；当传入的view和上次传入的不一致时，换用新的view播放该用户的视频
 须在主线程调用。
 @param peerID 用户Peerid
 @param renderType 视频渲染模式
 @param window 视频窗口
 @param completion 设置用于播放视频的view的block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)playVideo:(NSString *)peerID
      renderType:(TKRenderMode)renderType
          window:(UIView *)window
      completion:(completion_block _Nullable)completion;

/**
 播放用户 某一视频设备视频

 @param peerID 用户ID
 @param canvas 视频窗口
 @param deviceId 设备ID
 @param completion 设置用于播放视频的view的block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)playVideo:(NSString *)peerID
          canvas:(TKVideoCanvas *)canvas
        deviceId:(NSString *_Nullable)deviceId
      completion:(completion_block _Nullable)completion;

/**
 播放某个用户的音频
 
 @param peerID 用户Peerid
 @param completion 取消播放某个音频后的block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)playAudio:(NSString *)peerID completion:(completion_block _Nullable)completion;

/**
 停止播放某个用户的视频
 
 @param peerID 用户Peerid
 @param completion 取消播放某个视频后的block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)unPlayVideo:(NSString *)peerID completion:(completion_block _Nullable)completion;

/**
 停止播放用户 某一视频设备视频

 @param peerID 用户ID
 @param deviceId 设备ID
 @param completion 取消播放某个视频后的block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)unPlayVideo:(NSString *)peerID deviceId:(NSString *_Nullable)deviceId completion:(completion_block _Nullable)completion;
/**
 停止播放某个用户的音频
 
 @param peerID 用户Peerid
 @param completion 取消播放某个音频后的block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)unPlayAudio:(NSString *)peerID completion:(completion_block _Nullable)completion;

/**
 * 暂停/恢复播放所有远端用户的音频流
 *
 * 当您静音所有用户的远端音频时，SDK 会停止播放所有来自远端的音频流，同时也会停止拉取所有用户的音频数据。
 * @param mute YES：静音；NO：取消静音。
 * @note 在进入房间（joinRoom）之前或之后调用本接口均生效，静音状态在退出房间（leaveRoom）之后会被重置为 NO。
 */
- (int)muteAllRemoteAudio:(BOOL)mute;
#pragma mark - 是否禁用音视频设备
/**
 设置启用/禁用摄像头
 
 @param enable ：true：启用摄像头；false：禁用摄像头
 @return 0表示调用成功，非0表示调用失败
 */
- (int)enableLocalVideo:(BOOL)enable;


/**
 自己音频的开启关闭
 
 @param enable YES:开启 NO:关闭
 @return 0表示调用成功，非0表示调用失败
 */
- (int)enableLocalAudio:(BOOL)enable;

#pragma mark 发布流媒体
/**
 发布流媒体
 
 @param mediaPath 文件的url
 @param toID 发布媒体流给谁 NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param attributes 参数
 @param completion 发布媒体流后的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)startShareMediaFile:(NSString *)mediaPath
                   isVideo:(BOOL)isVideo
                      toID:(NSString *)toID
                attributes:(NSDictionary *)attributes
                     block:(completion_block _Nullable)completion;

/**
 取消媒体流
 
 @param completion  取消媒体流后的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)stopShareMediaFile:(completion_block _Nullable)completion;

#pragma mark 播放流媒体
/**
 播放媒体流
 须在主线程调用。
 @param peerId 用户id
 @param completion 播放后的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)playMediaFile:(NSString *)peerId
          renderType:(TKRenderMode)renderType
              window:(UIView *)window
          completion:(completion_block _Nullable)completion;
/**
 停止播放媒体流
 
 @param peerId 用户id
 @param completion 播放后的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)unPlayMediaFile:(NSString *)peerId completion:(completion_block _Nullable)completion;
/**
 暂停媒体流（自己共享的流媒体）
 
 @param pause 暂停
 @return 0表示调用成功，非0表示调用失败
 */
- (int)pauseMediaFile:(BOOL)pause;

/**
 设置进度
 
 @param pos 媒体流的位置
 @return 0表示调用成功，非0表示调用失败
 */
- (int)seekMediaFile:(NSTimeInterval)pos;

/**
 设置用户音量
 
 @param volume 音量 0.0 - 10.0
 @param peerId 用户ID
 @param type 视频类型 （包括摄像头采集的视频、共享的多媒体视频）
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setRemoteAudioVolume:(CGFloat)volume peerId:(NSString *)peerId type:(TKMediaType)type;

/**
 播放桌面共享
 须在主线程调用。
 @param peerID 共享桌面的用户id
 @param completion 播放共享桌面后的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)playScreen:(NSString *)peerID
       renderType:(TKRenderMode)renderType
           window:(UIView *)window
       completion:(completion_block _Nullable)completion;

/**
 关闭共享桌面
 
 @param peerID 共享桌面的用户id
 @param completion 关闭共享桌面的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)unPlayScreen:(NSString *)peerID completion:(completion_block _Nullable)completion;

- (NSDictionary *)getShareScreenAttributeWithPeerID:(NSString *)peerID;

/**
 播放电影
 须在主线程调用。
 @param peerID 共享电影文件的用户id
 @param completion 播放电影文件后的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)playFile:(NSString *)peerID
     renderType:(TKRenderMode)renderType
         window:(UIView *)window
     completion:(completion_block _Nullable)completion;

/**
 关闭电影
 
 @param peerID 共享电影文件的用户id
 @param completion 关闭共享电影文件的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)unPlayFile:(NSString *)peerID completion:(completion_block _Nullable)completion;

#pragma mark 服务器录制
/**
开始服务器录制
@param spec 录制参数
 「
    ---------------------------------standard模式---------------------------
    standard模式标准常规录制，为默认模式
    NSDictionary *spec = @{@"recordMode" : @"standard"};
 
    ---------------------------------mix模式----------------------------------
    mix模式自定义混流录制，需要传入以下参数
    可以针对用户对象进行自定义布局样式
     NSDictionary *userVideoLayout = @{
         @{@"uid": @"1131223463fff",    // 用户 ID，若为桌面共享的视频，此 ID 为'用户ID:screen'
           @"x_coord": @(0.1),  // 窗口x坐标，取值为相对于整个视频宽度百分比
           @"y_coord": @(0.1),  // 窗口y坐标，取值为相对于整个视频高度百分比
           @"width": @(0.18),    // 窗口宽，取值为相对于整个视频宽度百分比
           @"height": @(0.24),   // 窗口高，取值为相对于整个视频高度百分比
           @"alpha": @(1),  // 窗口透明度
           @"play_video" : @(YES),  //缺省值 YES；YES:显示视频窗口，NO:不显示视频窗口
           @"play_audio" : @(YES),  //缺省值 YES；YES:播放音频，NO:不播放音频
         }
     };
 
     NSMutableArray *videoLayoutList = [NSMutableArray array];
     [videoLayoutList addObject:userVideoLayout];
     NSDictionary *customConfigParams = @{
         @"noStreamTimeout_s" : @(30),   //开始混流后，房间中没有以下指定用户的流，30秒后停止混流
         @"backgroundColor" : @"#0d69fb",   //为兼容，若指定，则优先级高于外层背景色配置
         @"videoLayout" : videoLayoutList
     };
     NSDictionary *spec = @{@"recordMode" : @"mix",
                            @"mixStreamParams" : @{
                                @"template": @2,     // 必选，混流布局模板ID，0表示等分布局; 1表示画中画布局; 2表示自定义布局
                                @"backgroundColor": @"#0d69fb",     // 颜色值
                                @"customConfig": customConfigParams
                            }   // 若 template 为2，则自定义布局时生效，包括布局参数和其他附加参数；template 为2以外的其他值，此参数无效，可不填
     };
 」
    ⚠️ 注：spec 为 nil，默认standard模式
@param expiresabs expiresabs 录制时长
@param expires expires 结束录制时的时间戳
@return 0表示调用成功，非0表示调用失败
*/
- (int)startServerRecord:(NSDictionary<NSString *, id> *)spec
              expiresabs:(NSInteger)expiresabs
                 expires:(NSInteger)expires;

/**
 停止服务器录制
 @return 0表示调用成功，非0表示调用失败
 */
- (int)stopServerRecord;

- (int)pauseServerRecord;
- (int)resumeServerRecord; 

- (TKRecordState)getServerRecordState;

/**
 开始本地录制音频
 
 @param sandboxPath 有效的沙盒文件路径，如xxx/Library/Caches/audioRecord.mp3。
 注：
 1、保存音频文件为MP3格式；
 2、如果两次传入的路径相同，录制数据会覆盖；
 3、文件路径必须是有效路径，否则录制失败。例如：路径不存在或者不是文件路径（而是文件夹路径），则录制失败。
 @param recordInfo   默认参数 Default: sample_rate = 16000,  number_of_channels = 1,  fromat = TKSampleFormat_S16,  type = TKAudioRecordType_Only_Mic
    1、若recordInfo NULL时，采用默认参数。
    2、TKAudioRecordType_Only_Mic  ：仅录制麦克风的音频 ，TKAudioRecordType_MicAndSpeaker ：录制麦克风、扬声器的音频
 
 @return 0 设置成功, 非0 失败
 */
- (int)startAudioRecord:(NSString *)sandboxPath recordInfo:(TKAudioRecordInfo *)recordInfo;

- (int)startAudioRecord:(NSString *)sandboxPath TK_Deprecated("Did deprecated. Use - (int)startAudioRecord:type:  ");

/**
 暂停录制音频

 @param pause 是否暂停
 @return 0 设置成功, 非0 失败
 */
- (int)pauseAudioRecord:(BOOL)pause;

/**
 停止录制音频
 
 @return 0 设置成功, 非0 失败
 */
- (int)stopAudioRecord;


#pragma mark 房间功能
/**
 设置视频分辨率
 
 @param profile TKVideoProfile实例对象
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setVideoProfile:(TKVideoProfile *)profile;

/**
 切换纯音频教室
 
 @param isSwitch yes：纯音频教室。no：音视频教室
 @return 0表示调用成功，非0表示调用失败
 */
- (int)switchOnlyAudioRoom:(BOOL)isSwitch;

/**
 将一个用户踢出房间
 
 @param peerID 用户id
 @param reason 原因
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)evictUser:(NSString *)peerID evictReason:(NSNumber *)reason completion:(completion_block _Nullable)completion;

/**
 将一个用户踢出房间
 
 @param peerID 该用户的id
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)evictUser:(NSString *)peerID completion:(completion_block _Nullable)completion;

/**
 切换本地摄像头
 
 @param isFront  true：使用前置摄像头；false：使用后置摄像头
 @return 0表示调用成功，非0表示调用失败
 */
- (int)selectCameraPosition:(BOOL)isFront;

/**
 是否外放
 
 @param use YES:外放 NO:关闭
 @return 0表示调用成功，非0表示调用失败
 */
- (int)useLoudSpeaker:(BOOL)use;

/**
 设置所有音频静音
 
 @param enable  YES：静音， NO：非静音
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setPlayOutMute:(BOOL)enable;

/**
 设置视频方向
 
 @param orientation 设备取向
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setVideoOrientation:(UIDeviceOrientation)orientation;

/**
 开启/关闭 多码流

 @param enable 开启/关闭
 @return 0表示调用成功，非0表示调用失败
 */
- (int)enableDualStream:(BOOL)enable;

/**
 设置小流分辨率

 @param profile TKVideoProfile实例对象
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setSmallStreamParameter:(TKVideoProfile *)profile;

/**
 设置远端视频流默认类型，若不设置默认为TKVideoStream_Big

 @param streamType 视频流类型
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setRemoteDefaultVideoStreamType:(TKVideoStreamType)streamType;

/**
 设置某一用户（除自己之外）的某一视频设备的视频流类型

 @param streamType 视频流类型
 @param peerID 用户ID
 @param deviceID 视频设备ID
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setRemoteVideoStreamType:(TKVideoStreamType)streamType peerId:(NSString *)peerID deviceId:(NSString * _Nullable)deviceID;

#pragma mark 播放音频文件
/**
 开始播放
 @param filePath 本地文件路径 支持mp3、wav
 @param loop     是否循环
 @param progress 播放进度回调, audioID：播放音频标识, current：当前播放时间（单位：毫秒）, total：音频总时长（单位：毫秒）
 @return 返回播放音频标识, 若返回-1:表示播放失败.
 */

- (int)startPlayAudioFile:(NSString *)filePath loop:(BOOL)loop progress:(TKLocalMediaProgress_block _Nullable)progress;

/**
 停止播放
 @param audioId  playAudioFile接口返回的标识, 此参数为-1时，表示停止所有正在播放的音频
 @return 0 设置成功, -1 失败
 */

- (int)stopPlayAudioFile:(int)audioId;

/**
 暂停播放
 @param audioId  playAudioFile接口返回的标识
 @return 0 设置成功, -1 失败
 */

- (int)pauseAudioFile:(int)audioId;

/**
 恢复播放
 @param audioId  playAudioFile接口返回的标识
 @return 0 设置成功, -1 失败
 */

- (int)resumeAudioFile:(int)audioId;

/**
 设置播放音量
 @param volume   播放时混音音量 取值范围:0.0~1.0  默认1.0
 @param audioId  startPlayAudioFile接口返回的标识
 @return 0 设置成功, -1 失败
 */

- (BOOL)setAudioFileVolume:(CGFloat)volume soundId:(int)audioId;

#pragma mark 播放媒体音视频文件

/**
 开始播放媒体音视频

 @param params 播放参数
 @param startBlock 开始播放block
 @param progressBlock 播放进度
 @param completeBlock 播放完成block
 @return 返回一个播放ID, 如果播放失败返回-1.
 */
- (int)startPlayMediaFile:(TKMediaFileParams *)params
                  onStart:(TKLocalMediaState_block _Nullable)startBlock
               onProgress:(TKLocalMediaProgress_block _Nullable)progressBlock
               onComplete:(TKLocalMediaState_block _Nullable)completeBlock;
- (int)startPlayMediaFile:(TKMediaFileParams *)params progress:(TKLocalMediaProgress_block _Nullable)progress;

/**
 停止播放媒体音视频

 @param playID 播放ID startPlayMediaFile接口返回的播放标识ID, 此参数为-1时，表示停止所有正在播放文件
 @return 0 设置成功, -1 失败。
 */
- (int)stopPlayMediaFile:(int)playID;

/**
 暂停播放媒体音视频

 @param playID 播放ID
 @return 0 设置成功, -1 失败
 */
- (int)pausePlayMedia:(int)playID;
/**
 继续播放媒体音视频
 
 @param playID 播放ID
 @return 0 设置成功, -1 失败
 */
- (int)resumePlayMedia:(int)playID;
/**
 seek播放媒体音视频
 
 @param playID 播放ID
 @param pos seek时间位置(0.0 - 1.0)
 @return 0 设置成功, -1 失败
 */
- (int)seekPlayMedia:(int)playID pos:(double)pos;
/**
 设置播放媒体音视频的音量
 @param playID 播放ID
 @param volume 音量大小（0.0 - 1.0）
 @return 0 设置成功, -1 失败
 */
- (int)setPlayMedia:(int)playID volume:(CGFloat)volume;
 
/// 获取用户的上行音视频统计信息数据
/// @param peerId 用户ID
/// @param allStreams 是否获取房间中所有流的统计信息。若allStreams = NO，表示获取ID 为peerId的用户发布的所有音视频流的统计信息。若allStreams = YES，则获取房间中所有音视频流的统计信息
/// @param callback 回调
- (int)getStreamStats:(NSString *)peerId allStreams:(BOOL)allStreams callback:(void (^)(NSDictionary <NSString *, NSDictionary *>* stats, NSError * _Nullable error))callback;


#pragma mark 大规模房间相关接口
    //************************************************************************************************//
    //************************************* 大规模房间相关接口 ******************************************//
    //************************************************************************************************//
/**
 大规模房间时获取指定用户ID的用户
 在非大规模时使用- (TKRoomUser *)getRoomUserWithUId: 获取房间用户
 @param peerID 指定的用户ID
 @param callback 回调Block
 @return 0表示调用成功，非0表示调用失败
 */
- (int)getRoomUserWithPeerId:(NSString *)peerID callback:(void (^)(TKRoomUser *_Nullable user, NSError *_Nullable error))callback;

/**
 大规模教室时获取房间人数（可根据用户角色获取人数）
 
 @param role 用户角色
 @param callback 人数的callBack
 @return 0表示调用成功，非0表示调用失败
 */
- (int)getRoomUserNumberWithRole:(NSArray * _Nullable)role
                          search:(NSString * _Nullable)search
                        callback:(void (^)(NSInteger num, NSError *error))callback;

/**
 大规模教室时获取房间用户信息（用户列表）
 
 @param role 用户角色
 @param start 起始位置
 @param max 需要获取的人数
 @param callback 获取到的用户信息callback
 @return 0表示调用成功，非0表示调用失败
 */
- (int)getRoomUsersWithRole:(NSArray * _Nullable)role
                 startIndex:(NSInteger)start
                  maxNumber:(NSInteger)max
                     search:(NSString * _Nullable)search
                      order:(NSDictionary * _Nullable)order
                   callback:(void (^)(NSArray <TKRoomUser *>* _Nonnull users , NSError * _Nullable error) )callback;

/**
 批量改变指定了用户ID的用户属性（适用于高并发房间）
 
 @param peerIDs 指定了用户ID的用户ID数组
 @param tellWhom 要将此修改通知给谁。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param properties 要修改的属性
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)batchChangeUserPropertyByIds:(NSArray <NSString *>*)peerIDs
                           tellWhom:(NSString *)tellWhom
                           property:(NSDictionary *)properties
                         completion:(completion_block _Nullable)completion;

/**
 改变指定了角色的用户属性（适用于高并发房间）
 
 @param roles 指定的用户角色的数组
 @param tellWhom 要将此修改通知给谁。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param properties 要修改的属性
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)changeUserPropertyByRole:(NSArray *)roles
                       tellWhom:(NSString *)tellWhom
                       property:(NSDictionary *)properties
                     completion:(completion_block _Nullable)completion;

/**
 批量改变指定了用户ID的用户属性（适用于高并发房间）
 
 @param peerIDs 指定了用户ID的用户ID数组
 @param tellWhom 要将此修改通知给谁。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param properties 要修改的属性
 @param extensionJson 信令需要的携带扩展信息，可nil
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)batchChangeUserPropertyByIds:(NSArray<NSString *> *)peerIDs
                           tellWhom:(NSString *)tellWhom
                           property:(NSDictionary *)properties
                      extensionJson:(NSDictionary * _Nullable)extensionJson
                         completion:(completion_block _Nullable)completion;
/**
 改变指定了角色的用户属性（适用于高并发房间）
 
 @param roles 指定的用户角色的数组
 @param tellWhom 要将此修改通知给谁。NSString类型，详情见 TKRoomDefines.h 相关定义. 可以是某一用户ID，表示此信令只发送给该用户
 @param properties 要修改的属性
 @param extensionJson 信令需要的携带扩展信息，可nil
 @param completion 完成的回调
 @return 0表示调用成功，非0表示调用失败
 */
- (int)changeUserPropertyByRole:(NSArray *)roles
                       tellWhom:(NSString *)tellWhom
                       property:(NSDictionary *)properties
                  extensionJson:(NSDictionary * _Nullable)extensionJson
                     completion:(completion_block _Nullable)completion;

/// 根据用户属性获取用户
/// properties  用户属性，必须包含的字段有：key（属性名称）
///                           operator（详情 TKRoomDefines.h 中枚举定义 TKOperator）
///                           value（属性名称对应的值），
/// 可选字段有：start, max 等。
/// 例如：@{@"key" : @"publishstate", @"operator" : @“1”, @"value" : @”0“}
/// callback 回调
- (int)getUsersByProperty:(NSDictionary *)properties callback:(void (^)(NSArray<TKRoomUser *> *list, NSError * _Nullable error))callback;


#pragma mark - 屏幕录制
/**
 初始化系统RPSystemBroadcastPickerView，创建开启屏幕直播界面

 @param frame RPSystemBroadcastPickerView的frame
 @param preferredExtension RPSystemBroadcastPickerView需关联的扩展程序target 的Bundle Identifier
 @return RPSystemBroadcastPickerView对象
 */
- (RPSystemBroadcastPickerView *)createRPSystemBroadcastPickerViewWithFrame:(CGRect)frame preferredExtension:(NSString *)preferredExtension API_AVAILABLE(ios(12.0));

/**
 开始屏幕直播 （须在屏幕直播开启后调用）

 @param appGroup appGroup, 需要添加appGroup
 @return 0 设置成功, 非0 失败
 */
- (int)startScreenShare:(NSString *)appGroup;

/**
 停止屏幕直播

 @return 0 设置成功, 非0 失败
 */
- (int)stopScreenShare;

#pragma mark - 获取设备类
- (TKDeviceManager *)getDeviceManager;
#pragma mark - 用户管理类
- (TKRoomUserManager *)getUserManager;
 
#pragma mark deprecated
/**
 开始测速
 */
- (void)startNetworkTest TK_Deprecated("Did deprecated!!!");

/**
 停止测速
 */
- (void)stopNetworkTest TK_Deprecated("Did deprecated!!!");

/**
 设置发布音视频 属性
 
 @param attributes 属性
 @return 0表示调用成功，非0表示调用失败
 */
- (int)setAttributes:(NSDictionary *)attributes TK_Deprecated("Will deprecated!!!");

/**
 录制用户的视频流
 
 @param peerId 用户id
 @param convert 0 不转换, 1 webm, 2 mp4
 @param completion 回调block，第一个参数为0时，表示成功，非0表示失败；第二个参数为视频路径。
 @return 0表示调用成功，非0表示调用失败
 */
- (int)startRecordUser:(NSString *)peerId
               convert:(NSInteger)convert
            completion:(void (^)(NSInteger ret, NSString *path))completion TK_Deprecated("Will deprecated!!! use - (int)startServerRecord:convert:layout:expiresabs:expires: replaced");

/**
 结束用户的视频流录制
 
 @param peerId 用户id
 @param completion 回调block，参数为0，表示成功；非0表示失败。
 @return 0表示调用成功，非0表示调用失败
 */
- (int)stopRecordUser:(NSString *)peerId completion:(void (^)(NSInteger, NSString *path))completion TK_Deprecated("Will deprecated!!! use - (int)stopServerRecord replaced");

/**
 当前本地摄像头是否被启用
 
 @return true：摄像头可用；false：摄像头被禁用
 */
- (BOOL)isVideoEnabled TK_Deprecated("Will deprecated!!!");
/**
 当前本地音频设备是否被启用
 
 @return true：可用；false：被禁用
 */
- (BOOL)isAudioEnabled TK_Deprecated("Will deprecated!!!");

/**
 禁用音频设备
 */
//- (int)disableAudioDevice:(BOOL) isDisable;

/**
 禁用视频设备
 */
- (int)disableVideoDevice:(BOOL) isDisable;

@end
NS_ASSUME_NONNULL_END
