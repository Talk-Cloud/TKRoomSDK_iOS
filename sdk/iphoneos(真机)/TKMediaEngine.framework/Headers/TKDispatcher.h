//
//  TKDispatcher.h
//  TKMediaEngine
//
//  Created by 涂远友 on 2024/12/3.
//  Copyright © 2024 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
NS_ASSUME_NONNULL_BEGIN

@interface TKDispatcher : NSObject


- (instancetype)init NS_UNAVAILABLE;


/** Dispatch the block asynchronously on the Main Queue.
 *  @param block The block to dispatch asynchronously.
 */
+ (void)dispatchAsyncOnMainQueue:(dispatch_block_t)block;

/** Dispatch the block synchronously on the Main Queue.
 *  @param block The block to dispatch synchronously.
 */
+ (void)dispatchSyncOnMainQueue:(dispatch_block_t)block;

/** Dispatch the block asynchronously on the targetQueue..
 *  @param targetQueue The queue to dispatch on.
 *  @param block The block to dispatch asynchronously.
 */
+ (void)dispatchAsyncOnTargetQueue:(dispatch_queue_t)targetQueue block:(dispatch_block_t)block;

/** Dispatch the block synchronously on the targetQueue..
 *  @param targetQueue The queue to dispatch on.
 *  @param block The block to dispatch synchronously.
 */
+ (void)dispatchSyncOnTargetQueue:(dispatch_queue_t)targetQueue block:(dispatch_block_t)block;


/** Returns YES if run on targetQueue,  otherwise NO.
 *  Useful for asserting that a method is run on a correct queue.
 */
+ (BOOL)isOnTargetQueue:(dispatch_queue_t)targetQueue;
@end

NS_ASSUME_NONNULL_END
