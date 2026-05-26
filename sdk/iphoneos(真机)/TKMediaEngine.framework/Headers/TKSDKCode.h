//
//  TKRoomCode.h
//  TKRoomSDK
//
//  Created by tuyuanyou on 2024/3/28.
//  Copyright © 2024 MAC-MiNi. All rights reserved.
//

#ifndef TKRoomCode_h
#define TKRoomCode_h
#
#pragma mark - TKRoomWarningCode 警告码
#
typedef NS_ENUM(NSInteger, TKRoomWarningCode) {
    TKRoomWarning_UnKnow,
    
    TKRoomWarning_ADM_Session_Began_Interrruption = 105,    //音频采集被系统中断，如系统来电，闹钟等
    TKRoomWarning_ADM_Session_Ended_Interrruption = 106,    //音频采集系统中断恢复
    TKRoomWarning_ADM_Record_Audio_Low_Volume = 107,        //录音设备采集到的音量过低
    TKRoomWarning_ADM_PlayOut_Audio_Low_Volume = 108,       //扬声器音量设置过低或被静音
    
    TKRoomWarning_AudioRouteChange_Headphones = 121,   //耳机
    TKRoomWarning_AudioRouteChange_BuiltInReceiver,    //听筒模式（手机靠近耳边）
    TKRoomWarning_AudioRouteChange_BuiltInSpeaker,     // 内置扬声器（外放）
    TKRoomWarning_AudioRouteChange_Bluetooth,          // 蓝牙
    
    TKRoomWarning_VDM_Session_Began_Interrrupted = 154,    //视频采集被系统中断。如 App 进入后台，启动其他使用视频的 App 等
    TKRoomWarning_VDM_Session_Ended_Interrrupted = 155,     //视频采集系统中断恢复
    
    TKRoomWarning_CheckRoom_Completed                   = 1001,    //CheckRoom 成功
    TKRoomWarning_GetConfig_Completed                   = 1002,    //GetConfig 成功
    
    
    TKRoomWarning_Stream_Connected                      = 1101,
    TKRoomWarning_Stream_Failed                         = 1102,
    TKRoomWarning_Stream_Closed                         = 1103,
    TKRoomWarning_Stream_Disconnected                   = 1104,   // 媒体链路断开，会重新连接

    TKRoomWarning_ReConnectSocket_ServerChanged         = 5002,   //切换了服务器
    TKRoomWarning_DevicePerformance_Low                 = 5003,   //设备性能过低
    
    
    TKRoomWarning_ADM_Category_Not_PlayAndRecord = 1520,    //在通话过程中，Audio Session 的 category 必须设置成 AVAudioSessionCategoryPlayAndRecord，SDK 会监控这个属性值。当这个值被修改成其他值的时候会触发这个告警，并强制设置回 AVAudioSessionCategoryPlayAndRecord。
    TKRoomWarning_VDM_Session_Began_Interrrupted_InBackground = 1521,    //App 进入后台，视频采集被中断
    TKRoomWarning_VDM_VideoFormat_Exceeded = 1522,   // 设置本地视频分辨率超过设备支持的最大分辨率
    TKRoomWarning_VDM_Session_Began_Interrrupted_MultipleForegroundApps = 1523,    //开启多任务导致相机中断

    
    TKRoomWarning_Network_VPN_ON  = 1526,     // 监测到网络开启VPN
    TKRoomWarning_Network_VPN_OFF  = 1527,    // 监测到网络未开启VPN
};

#
#pragma mark - TKRoomErrorCode 错误码
#
typedef NS_ENUM(NSInteger, TKRoomErrorCode) {
    TKErrorCode_UnKnow              = -2,
    TKErrorCode_Internal_Exception  = -1,
    TKErrorCode_OK                  = 0,//isUnusualNetwork
    
    TKErrorCode_SentMsg_ContentTooLong              = 61,      //聊天消息内容过长
    TKErrorCode_SentMsg_HighFrequency               = 62,      //发送聊天消息频率太快
    TKErrorCode_JoinRoom_WrongParam                 = 63,      // join room 参数错误
    TKErrorCode_JoinRoom_Student_Limit_Exceed       = 64,      // join room 学生人数超限
    TKErrorCode_JoinGroup_Failed                    = 65,      // join group 失败
    TKErrorCode_JoinGroup_Repeated                  = 66,      // 前一次加入未完成时，重复调用join group
    TKErrorCode_JoinGroup_TimeOut                   = 67,       //joinGroup 超时
    TKErrorCode_JoinRoom_TeacherAlreadyExists,                  //教室中已有老师,不允许其他老师进入
     
    TKErrorCode_Network_Unusual     = 100,
    TKErrorCode_Not_Initialized     = 101,
    TKErrorCode_Bad_Parameters      = 102, // 参数错误
    

    TKErrorCode_Play_StateError = 104,     // 播放状态错误
    TKErrorCode_RenderView_ReUsed = 156,     //渲染视图已被使用
    
    TKErrorCode_Publish_NoAck                    = 401,
    TKErrorCode_Publish_RoomNotExist             = 402,
    TKErrorCode_Publish_RoomMaxVideoLimited      = 403,//媒体链路超限
    TKErrorCode_Publish_ErizoJs_Timeout          = 404,
    TKErrorCode_Publish_Agent_Timeout            = 405,
    TKErrorCode_Publish_UndefinedRPC_Timeout     = 406,
    TKErrorCode_Publish_AddingInput_Error        = 407,
    TKErrorCode_Publish_DuplicatedExtensionId    = 408,
    TKErrorCode_Publish_Unauthorized             = 409,
    TKErrorCode_Publish_Failed                   = 410,//发布失败，自动重新发布
    TKErrorCode_Publish_Timeout                  = 411,//发布失败，自动重新发布
    
    TKErrorCode_Subscribe_RoomNotExist           = 501,
    TKErrorCode_Subscribe_StreamNotDefine        = 502,
    TKErrorCode_Subscribe_MediaRPC_Timeout       = 503,
    TKErrorCode_Subscribe_Fail                   = 504,//订阅失败，自动重新订阅
    TKErrorCode_Subscribe_Timeout                = 505,//订阅超时，自动重新订阅
    
    TKErrorCode_ConnectSocketError               = 601,
    TKErrorCode_ConnectSocketFailed              = 602, // 链接socket失败

    
    
    TKErrorCode_CheckRoom_RequestFailed          = 801,    //CheckRoom 请求失败
    TKErrorCode_GetConfig_RequestFailed          = 802,    //getconfig 请求失败
    
    TKErrorCode_Room_StateError     = 1500,
    TKErrorCode_Stream_StateError   = 1501,
    TKErrorCode_Stream_NotFound = 1502,
    TKErrorCode_FilePath_NotExist = 1503,                //文件路劲不存在
    TKErrorCode_CreateFile_Failed = 1504,                //创建文件失败
    
    TKErrorCode_VDM_Camera_Runtime_Error = 1505,            //相机运行出错
    TKErrorCode_ADM_AudioUnit_Initialize_Error = 1506,      // 音频设备初始化失败
    TKErrorCode_ADM_AudioUnit_Start_Error = 1507,           // 音频设备开启失败
    
    TKErrorCode_ADM_Recording_Device_Not_Allowd = 1508,    //麦克风没有授权
    TKErrorCode_VDM_Camera_Not_Allowed = 1509,             //相机没有授权
    
    
    TKErrorCode_ServerRecord_ing     = 1510,     //正在录制中
    TKErrorCode_ServerRecord_paused    = 1511,     //暂停录制
    TKErrorCode_ServerRecord_stoped    = 1512,     //未开始录制
    
    TKErrorCode_JoinRoom_Failed                  = 2507,   //joinroom 失败
    
    TKErrorCode_CheckRoom_ServerOverdue          = 3001,    //服务器过期
    TKErrorCode_CheckRoom_RoomFreeze             = 3002,    // 公司被冻结
    TKErrorCode_CheckRoom_RoomDeleteOrOrverdue   = 3003,    //房间已删除或过期
    TKErrorCode_CheckRoom_CompanyHasEnded         = 3004,    //公司试用已结束

    TKErrorCode_CheckRoom_CompanyNotExist        = 4001,    //该公司不存在
    TKErrorCode_CheckRoom_RoomNonExistent        = 4007,    //房间不存在
    TKErrorCode_CheckRoom_PasswordError          = 4008,    //房间密码错误
    TKErrorCode_CheckRoom_WrongPasswordForRole   = 4012,    //密码与身份不符
    TKErrorCode_CheckRoom_RoomNumberOverRun      = 4103,    //房间人数超限
    TKErrorCode_CheckRoom_RoomAuthenError        = 4109,    //认证错误
    TKErrorCode_CheckRoom_NeedPassword           = 4110,    //该房间需要密码，请输入密码
    TKErrorCode_CheckRoom_RoomPointOverrun       = 4112,    //企业点数超限
    TKErrorCode_CheckRoom_RoomNSF                 = 4113,    //余额不足
    TKErrorCode_CheckRoom_RoomCancelled             = 4020,     //课程已取消
    
    TKErrorCode_NotAllowed_JoinTheRoom              = 4117,  // 暂不可进入教室
    TKErrorCode_NotAllowed_JoinLiveRoomForOnlooker = 5300,   // 旁听者不能进入大班课
    
};


#endif /* TKRoomCode_h */
