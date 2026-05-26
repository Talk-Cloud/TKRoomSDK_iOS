//
//  TKMediaDefines.h
//  TKMediaEngine
//
//  Created by tuyuanyou on 2024/5/23.
//  Copyright © 2024 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
#import <TKMediaEngine/TKLogMacros.h>
#import <TKMediaEngine/TKSDKCode.h>


NS_ASSUME_NONNULL_BEGIN
#
#pragma mark - 点播播放器 事件 （点播播放器专用）
#
typedef NS_ENUM(NSInteger, TKVodPlayEventID) {
    TKVodPlay_Event_OK                                 = 0,
    TKVodPlay_Event_Open_File_Succ                     = 111,     ///< 播放事件: 成功打开播放文件
    TKVodPlay_Event_Find_Stream_Info_Succ              = 112,     ///< 播放事件: 成功获取到点播文件的信息
    TKVodPlay_Event_Stream_Prepared                    = 113,     ///< 播放事件: 视频加载完毕
    
    TKVodPlay_Event_Open_File_Failed                   = -101,    ///< 点播错误: 播放文件不存在
    TKVodPlay_Event_File_Data_Exception                = -102,
    TKVodPlay_Event_Find_Stream_Info_Failed            = -103,    ///< 点播错误: 播放文件不存在
    TKVodPlay_Event_Read_Fream_Failed                  = -104,
    TKVodPlay_Event_VCodec_Send_Data_Failed            = -105,
    TKVodPlay_Event_VCodec_Receive_Data_Failed         = -106,
    TKVodPlay_Event_ACodec_Send_Data_Failed            = -107,
    TKVodPlay_Event_ACodec_Receive_Data_Failed         = -108,
    TKVodPlay_Event_Convert_Aduio_Data_Failed          = -109,
    TKVodPlay_Event_Create_VideoToolBox_Decoder_Failed = -110, //创建H264硬解码器失败
};

typedef NS_ENUM(NSInteger, TKIceConnectionState) {
    TKIceConnectionStateNew,
    TKIceConnectionStateChecking,
    TKIceConnectionStateConnected,
    TKIceConnectionStateCompleted,
    TKIceConnectionStateFailed,
    TKIceConnectionStateDisconnected,
    TKIceConnectionStateClosed,
    TKIceConnectionStateCount,
};

typedef NS_ENUM(NSInteger, TKVideoRotation) {
    TKVideoRotation_0 = 0,
    TKVideoRotation_90 = 90,
    TKVideoRotation_180 = 180,
    TKVideoRotation_270 = 270,
};

#
#pragma mark - TKAudioQuality 声音音质
#
typedef NS_ENUM(NSInteger, TKAudioQuality) {
    ///人声模式：比如在线会议，语音通话等。
    TKAudioQualitySpeech = 1,
    ///默认模式：SDK 默认档位，推荐选择。
    TKAudioQualityDefault = 2,
    ///音乐模式：比如在线K歌、音乐直播等。
    TKAudioQualityMusic = 3,
};

#
#pragma mark - TKMediaType 媒体类型
#
typedef NS_ENUM(NSInteger, TKMediaType_M) {
    TKMediaSourceType_unknow_m    = -1,
    TKMediaSourceType_camera_m    = 0,      //视频
    TKMediaSourceType_mic_m      = 11,
    TKMediaSourceType_file_m      = 101,    //本地电影共享
    TKMediaSourceType_screen_m    = 102,    //屏幕共享
    TKMediaSourceType_media_m     = 103,    //媒体文件 mp4、mp3
};

#
#pragma mark - TKRenderMode 渲染模式
#
typedef NS_ENUM(NSInteger, TKRenderMode_M) {
    TKRenderMode_fit_m       = 0,  //等比拉伸
    TKRenderMode_adaptive_m  = 1,  //等比拉伸，并占满全屏
};

#
#pragma mark - TKVideoStreamType 视频流类型
#
typedef NS_ENUM(NSInteger, TKVideoStreamType_M) {
    TKVideoStream_Big_m   = 0,  //
    TKVideoStream_Small_m = 1,    //小流
};

#
#pragma mark - TKVideoMirrorMode 视频渲染镜像模式
#
typedef NS_ENUM(NSUInteger, TKVideoMirrorMode_M) {
    TKVideoMirrorModeAuto_m      = 0,  //默认设置，前置摄像头时开启镜像模式，后置摄像头时不开启镜像
    TKVideoMirrorModeEnabled_m   = 1,  //前置和后置均开启镜像模式
    TKVideoMirrorModeDisabled_m   = 2,  //前置和后置均不开启镜像模式
};


typedef NS_ENUM(NSInteger, TKNetQuality_M) {
    TKNetQuality_Excellent_m  = 1, //优
    TKNetQuality_Good_m,          //良
    TKNetQuality_Accepted_m,      //中
    TKNetQuality_Bad_m,           //差
    TKNetQuality_VeryBad_m,       //极差
    TKNetQuality_Down_m,
};

typedef NS_ENUM(NSInteger, TKSampleFormat_M) {

    TKSampleFormat_None_m = -1,
    TKSampleFormat_U8_m,          ///< unsigned 8 bits
    TKSampleFormat_S16_m,         ///< signed 16 bits
    TKSampleFormat_S32_m,         ///< signed 32 bits
    TKSampleFormat_FLT_m,         ///< float
    TKSampleFormat_DBL_m,         ///< double
    
    TKSampleFormat_U8P_m,         ///< unsigned 8 bits, planar
    TKSampleFormat_S16P_m,        ///< signed 16 bits, planar
    TKSampleFormat_S32P_m,        ///< signed 32 bits, planar
    TKSampleFormat_FLTP_m,        ///< float, planar
    TKSampleFormat_DBLP_m,        ///< double, planar
    TKSampleFormat_S64_m,         ///< signed 64 bits
    TKSampleFormat_S64P_m,        ///< signed 64 bits, planar
    
    TKAVSampleFormat_NB_m           ///< Number of sample formats. DO NOT USE if linking dynamically
};

#
#pragma mark - TKRenderState
#
typedef NS_ENUM(NSInteger, TKRenderState_M) {
    TKRenderState_Interruption_M  = 0,   //中断
    TKRenderState_Resumption_M   = 1,   //恢复
};


typedef NS_ENUM(NSInteger, TKAudioRecordType) {
    TKAudioRecordType_Only_Mic            = 1, //仅录制麦克风的音频
    TKAudioRecordType_MicAndSpeaker        = 2, //录制麦克风、扬声器的音频
};

typedef NS_ENUM(NSInteger, TKLocalMediaPlayingStateCode_M) {
    TKLocalMediaPlayingState_Playing_m = 710,
    TKLocalMediaPlayingState_Paused_m = 711,
    TKLocalMediaPlayingState_Stopped_m = 713,
    TKLocalMediaPlayingState_Failed_m = 714,
};

typedef void (^TKLocalMediaProgress_block_m)(int playID, int64_t current, int64_t total);
typedef void (^TKLocalMediaState_block_m)(int playID, NSInteger stateCode);

#pragma mark - TKMediaFileParams 本地媒体属性
#
@interface TKLoggerExtends : NSObject
@property (copy, nonatomic) NSString *roomID;
@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *thirdID;
@property (copy, nonatomic) NSString *reportUrl;
@end

#pragma mark - TKLogInfo 日志
#
@interface TKLogInfo : NSObject
///日志等级
@property (assign, nonatomic) TKLoggerLevel level;
///日志需要写入沙盒的路径; 默认路径为：nil，表示不写入
@property (strong, nonatomic) NSString *_Nullable logPath;
///是否时debug模式，debug模式：控制台打印，release模式：控制台不打印。
@property (assign, nonatomic) BOOL isDebug;
@end

#pragma mark - TKMediaFileParams 本地媒体属性
#
@interface TKMediaFileParams : NSObject
/// 文件地址或者路径
@property (copy, nonatomic) NSString *filePath;
/// 是否循环播放
@property (assign, nonatomic) BOOL loop;
/// 若是 视频文件，表示 视频渲染窗口
/// 若是音频文件，传nil即可
@property (strong, nonatomic) UIView * _Nullable window;

/// 若是 视频文件，表示 视频渲染模式
@property (assign, nonatomic) TKRenderMode_M renderMode;
/// header 需要的参数和值
/// AS：NSDictionary *header = @{@“user_agent" : @"xxx"}; 表示播放时header需要添加 user_agent
@property (strong, nonatomic) NSDictionary *header;
@end

#
#pragma mark - TKMediaFileInfo 媒体文件信息
#
@interface TKMediaFileInfo : NSObject
@property (assign, nonatomic) NSInteger duration;
@property (assign, nonatomic) int width;
@property (assign, nonatomic) int height;
@property (assign, nonatomic) int fps;
@property (assign, nonatomic) BOOL video;
@property (assign, nonatomic) BOOL audio;
@end


#
#pragma mark - TKVideoFrame 视频数据
#
@interface TKVideoFrame : NSObject

/**
 width of video frame
 */
@property (assign, nonatomic) NSInteger width;

/**
 height of video frame
 */
@property (assign, nonatomic) NSInteger height;

/**
 stride of Y data buffer
 */
@property (assign, nonatomic) NSInteger yStride;

/**
 stride of U data buffer
 */
@property (assign, nonatomic) NSInteger uStride;

/**
 stride of V data buffer
 */
@property (assign, nonatomic) NSInteger vStride;

/**
 Y data buffer
 */
@property (nonatomic) void *yBuffer;

/**
 U data buffer
 */
@property (nonatomic) void *uBuffer;

/**
 V data buffer
 */
@property (nonatomic) void *vBuffer;

/**
 rotation of this frame (0, 90, 180, 270)
 */
@property (assign, nonatomic) NSInteger rotation;

@end


#
#pragma mark - TKAudioFrame 音频数据
#
@interface TKAudioFrame : NSObject
/**
 number of samples in this frame
 */
@property (assign, nonatomic) NSInteger samples;

/**
 number of bytes per sample: 2 for PCM16
 */
@property (assign, nonatomic) NSInteger bytesPerSample;

/**
 number of channels (data are interleaved if stereo)
 */
@property (assign, nonatomic) NSInteger channels;

/**
 sampling rate
 */
@property (assign, nonatomic) NSInteger samplesPerSec;

@property (assign, nonatomic) TKSampleFormat_M format;

/**
 data buffer
 */
@property (nonatomic) void *buffer;
@end


#
#pragma mark - TKVideoProfile 视频属性
#
@interface TKVideoProfile : NSObject
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
/// 视频帧率
@property (nonatomic, assign) NSInteger maxfps;

- (BOOL)isEqual:(TKVideoProfile *)pro;
- (void)reSet:(TKVideoProfile *)pro;
@end

#
#pragma mark - TKVideoCanvas 视频属性
#
@interface TKVideoCanvas : NSObject

@property (strong, nonatomic) UIView *view;// 视频渲染窗口
@property (assign, nonatomic) TKRenderMode_M renderMode;//渲染模式
@property (assign, nonatomic) BOOL isMirror;// 是否是镜像
@end



@interface TKAudioRecordInfo : NSObject
/// 采样率 Default: 16000
@property (nonatomic, assign) int sample_rate;
/// Default:  1 （单声道 ）
@property (nonatomic, assign) int number_of_channels;
/// Default: TKSampleFormat_S16
@property (nonatomic, assign) TKSampleFormat_M fromat;
/// Default: TKAudioRecordType_Only_Mic
@property (nonatomic, assign) TKAudioRecordType type;
@end

#
#pragma mark - TKAudioStats 音频统计数据
#
@interface TKAudioStats : NSObject
/**
 带宽 bps
 */
@property (assign, nonatomic) NSInteger bitsPerSecond;

/**
 总字节数
 */
@property (assign, nonatomic) int64_t totalBytes;
/**
 丢包数
 */
@property (assign, nonatomic) NSInteger packetsLost;

/**
 总包数
 */
@property (assign, nonatomic) NSInteger totalPackets;

/**
 延迟 毫秒
 */
@property (assign, nonatomic) NSInteger currentDelay;

/**
 抖动
 */
@property (assign, nonatomic) NSInteger jitter;

/**
 网络质量
 */
@property (assign, nonatomic) TKNetQuality_M netLevel;
@property (assign, nonatomic) NSTimeInterval timeStamp;

@end
//丢包率  packetsLost/totalPackets  0~1% 优 1%~3% 良 3%~5% 中等 5~10%差  >10% 极差
//延迟                              80ms   120ms    300ms      800ms   >800ms
#
#pragma mark - TKVideoStats 视频统计数据
#
@interface TKVideoStats : NSObject

/**
 带宽 bps
 */
@property (assign, nonatomic) NSInteger bitsPerSecond;

/**
 总字节数
 */
@property (assign, nonatomic) int64_t totalBytes;

/**
 丢包数
 */
@property (assign, nonatomic) NSInteger packetsLost;

/**
 总包数
 */
@property (assign, nonatomic) NSInteger totalPackets;

//@property (assign, nonatomic) NSInteger firsCount;
//@property (assign, nonatomic) NSInteger plisCount;

/**
 延迟
 */
@property (assign, nonatomic) NSInteger currentDelay;

/**
 帧率
 */
@property (assign, nonatomic) NSInteger frameRate;

/**
 视频宽
 */
@property (assign, nonatomic) NSInteger frameWidth;

/**
 视频高
 */
@property (assign, nonatomic) NSInteger frameHeight;
/**
 网络质量
 */
@property (assign, nonatomic) TKNetQuality_M netLevel;

@property (assign, nonatomic) NSTimeInterval timeStamp;
@end




// 、TKVideoStats、 TKAudioStats
//、TKMediaFileInfo
NS_ASSUME_NONNULL_END
