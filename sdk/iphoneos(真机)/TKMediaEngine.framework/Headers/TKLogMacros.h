// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2018, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.

// Disable legacy macros

#import <Foundation/Foundation.h>

#ifndef TK_LEGACY_MACROS
    #define TK_LEGACY_MACROS 0
#endif
 

/**
 * The constant/variable/method responsible for controlling the current log level.
 **/
#undef LOG_LEVEL_DEF
#ifndef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF TKLoggerLevelAll
#endif

/**
 * Whether async should be used by log messages, excluding error messages that are always sent sync.
 **/
#ifndef LOG_ASYNC_ENABLED
    #define LOG_ASYNC_ENABLED YES
#endif

NS_ASSUME_NONNULL_BEGIN
/**
 *  Flags accompany each log. They are used together with levels to filter out logs.
 */
typedef NS_OPTIONS(NSUInteger, TKLogFlag) {
    /**
     *  0...00001 TKLogFlagError
     */
    TKLogFlagError      = (1 << 0),
    
    /**
     *  0...00010 TKLogFlagWarning
     */
    TKLogFlagWarning    = (1 << 1),
    
    /**
     *  0...00100 TKLogFlagInfo
     */
    TKLogFlagInfo       = (1 << 2),
    
    /**
     *  0...01000 TKLogFlagDebug
     */
    TKLogFlagDebug      = (1 << 3),
    
    /**
     *  0...10000 TKLogFlagVerbose
     */
    TKLogFlagVerbose    = (1 << 4)
};

/**
 *  Log levels are used to filter out logs. Used together with flags.
 */
typedef NS_ENUM(NSUInteger, TKLoggerLevel){
    /**
     *  No logs
     */
    TKLoggerLevelOff       = 0,
    
    /**
     *  Error logs only
     */
    TKLoggerLevelError     = (TKLogFlagError),
    
    /**
     *  Error and warning logs
     */
    TKLoggerLevelWarning   = (TKLoggerLevelError   | TKLogFlagWarning),
    
    /**
     *  Error, warning and info logs
     */
    TKLoggerLevelInfo      = (TKLoggerLevelWarning | TKLogFlagInfo),
    
    /**
     *  Error, warning, info and debug logs
     */
    TKLoggerLevelDebug     = (TKLoggerLevelInfo    | TKLogFlagDebug),
    
    /**
     *  Error, warning, info, debug and verbose logs
     */
    TKLoggerLevelVerbose   = (TKLoggerLevelDebug   | TKLogFlagVerbose),
    
    /**
     *  All logs (1...11111)
     */
    TKLoggerLevelAll       = NSUIntegerMax
};

@interface TKLog : NSObject
/**
 * Logging Primitive.
 *
 * This method is used by the macros or logging functions.
 * It is suggested you stick with the macros as they're easier to use.
 *
 *  @param asynchronous YES if the logging is done async, NO if you want to force sync
 *  @param level        the log level
 *  @param flag         the log flag
 *  @param context      the context (if any is defined)
 *  @param file         the current file
 *  @param function     the current function
 *  @param line         the current code line
 *  @param tag          potential tag
 *  @param format       the log format
 */
+ (void)log:(BOOL)asynchronous
      level:(TKLoggerLevel)level
       flag:(TKLogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id __nullable)tag
     format:(NSString *)format, ... NS_FORMAT_FUNCTION(9,10);

+ (void)log:(BOOL)asynchronous
    message:(NSString *)message
      level:(TKLoggerLevel)level
       flag:(TKLogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id __nullable)tag;

@end


#define TKSDKPrefix @"tk-sdk"
#define TKUIPrefix @"tk-ui"
#define TKLivePrefix @"tk-Live"
/**
 * These are the two macros that all other macros below compile into.
 * These big multiline macros makes all the other macros easier to read.
 **/
#define LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [TKLog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]

#define LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { if(lvl & flg) LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

/**
 * Ready to use log macros with no context or tag.
 * SDK Log
 **/
#define TKSDKLogError(prefix, frmt, ...)   \
{NSString *sdk_errorStr = [NSString stringWithFormat:@"%@ %@", prefix, frmt];\
LOG_MAYBE(NO,                LOG_LEVEL_DEF, TKLogFlagError,   0, nil, __PRETTY_FUNCTION__, sdk_errorStr, ##__VA_ARGS__);}\

#define TKSDKLogWarn(prefix, frmt, ...)    \
{NSString *sdk_warnStr = [NSString stringWithFormat:@"%@ %@", prefix, frmt];\
LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, TKLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, sdk_warnStr, ##__VA_ARGS__);}\

#define TKSDKLogInfo(prefix, frmt, ...)    \
{NSString *sdk_infoStr = [NSString stringWithFormat:@"%@ %@", prefix, frmt];\
LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, TKLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, sdk_infoStr, ##__VA_ARGS__);}\

#define TKSDKLogDebug(prefix, frmt, ...)   \
{NSString *sdk_debugStr = [NSString stringWithFormat:@"%@ %@", prefix, frmt];\
LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, TKLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, sdk_debugStr, ##__VA_ARGS__);}\

#define TKSDKLogVerbose(prefix, frmt, ...) \
{NSString *sdk_verboseStr = [NSString stringWithFormat:@"%@ %@", prefix, frmt];\
LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, TKLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, sdk_verboseStr, ##__VA_ARGS__);}\

#define TKSDKLogFlush(prefix, frmt, ...) \
{NSString *sdk_verboseStr = [NSString stringWithFormat:@"%@ %@", prefix, frmt];\
LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, TKLogFlagInfo, 0, @"flush", __PRETTY_FUNCTION__, sdk_verboseStr, ##__VA_ARGS__);}\

#define TKSDKLogErrorFlush(prefix, frmt, ...) \
{NSString *sdk_verboseStr = [NSString stringWithFormat:@"%@ %@", prefix, frmt];\
LOG_MAYBE(NO,                  LOG_LEVEL_DEF, TKLogFlagError, 0, @"flush", __PRETTY_FUNCTION__, sdk_verboseStr, ##__VA_ARGS__);}\

#ifdef DEBUG
#define TKRTCNSLog(...) NSLog(__VA_ARGS__)
#else
#define TKRTCNSLog(...)
#endif

// TKRoomSDK logMacors
#define TKLogError(frmt, ...)   TKSDKLogError(TKSDKPrefix, frmt, ##__VA_ARGS__)
#define TKLogWarn(frmt, ...)    TKSDKLogWarn(TKSDKPrefix, frmt, ##__VA_ARGS__)
#define TKLogInfo(frmt, ...)    TKSDKLogInfo(TKSDKPrefix, frmt, ##__VA_ARGS__)
#define TKLogDebug(frmt, ...)   TKSDKLogDebug(TKSDKPrefix, frmt, ##__VA_ARGS__)
#define TKLogVerbose(frmt, ...) TKSDKLogVerbose(TKSDKPrefix, frmt, ##__VA_ARGS__)
#define TKLogFlush(frmt, ...)   TKSDKLogFlush(TKSDKPrefix, frmt, ##__VA_ARGS__)
#define TKLogErrorFlush(frmt, ...) TKSDKLogErrorFlush(TKSDKPrefix, frmt, ##__VA_ARGS__)

// TKLivePlayer logMacors
#define TKLiveLogError(frmt, ...)   TKSDKLogError(TKLivePrefix, frmt, ##__VA_ARGS__)
#define TKLiveLogWarn(frmt, ...)    TKSDKLogWarn(TKLivePrefix, frmt, ##__VA_ARGS__)
#define TKLiveLogInfo(frmt, ...)    TKSDKLogInfo(TKLivePrefix, frmt, ##__VA_ARGS__)
#define TKLiveLogDebug(frmt, ...)   TKSDKLogDebug(TKLivePrefix, frmt, ##__VA_ARGS__)
#define TKLiveLogVerbose(frmt, ...) TKSDKLogVerbose(TKLivePrefix, frmt, ##__VA_ARGS__)
#define TKLiveLogFlush(frmt, ...)   TKSDKLogFlush(TKLivePrefix, frmt, ##__VA_ARGS__)
#define TKLiveLogErrorFlush(frmt, ...) TKSDKLogErrorFlush(TKLivePrefix, frmt, ##__VA_ARGS__)

// TKUISDK logMacors
#define TKUILogError(frmt, ...)   TKSDKLogError(TKUIPrefix, frmt, ##__VA_ARGS__)
#define TKUILogWarn(frmt, ...)    TKSDKLogWarn(TKUIPrefix, frmt, ##__VA_ARGS__)
#define TKUILogInfo(frmt, ...)    TKSDKLogInfo(TKUIPrefix, frmt, ##__VA_ARGS__)
#define TKUILogDebug(frmt, ...)   TKSDKLogDebug(TKUIPrefix, frmt, ##__VA_ARGS__)
#define TKUILogVerbose(frmt, ...) TKSDKLogVerbose(TKUIPrefix, frmt, ##__VA_ARGS__)
#define TKUILogFlush(frmt, ...)   TKSDKLogFlush(TKUIPrefix, frmt, ##__VA_ARGS__)
#define TKUILogErrorFlush(frmt, ...) TKSDKLogErrorFlush(TKUIPrefix, frmt, ##__VA_ARGS__)


NS_ASSUME_NONNULL_END
