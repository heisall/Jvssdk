//
//  JVCAudioQueueHelper.h
//  CloudSEE
//
//  Created by chenzhenyang on 14-9-17.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JVCAudioQueueHelperDelegate <NSObject>

/**
 *  缓存队列的出队入口数据
 *
 *  @param bufferData 队列出队的Buffer
 *
 */
-(void)popAudioDataCallBack:(void *)bufferData;

@end;

@interface JVCAudioQueueHelper : NSObject{

    id<JVCAudioQueueHelperDelegate> jvcAudioQueueHelperDelegate;

}

@property (nonatomic,assign) id<JVCAudioQueueHelperDelegate> jvcAudioQueueHelperDelegate;

/**
 *  初始化缓存队列对象
 *
 *  @param nLocalChannelID 本地连接通道编号
 *
 *  @return 缓存队列对
 */
-(id)init:(int)nLocalChannelID;

/**
 *  启动出队线程（消费者）
 */
-(void)startAudioPopDataThread;

/**
 *  数据入队 （生产者）
 *
 *  @param data       入队的数据
 *  @param nSize      入队的数据大小
 *  @param is_i_frame 是否是I帧（视频数据用的）
 *
 *  @return 成功返回 0, 队列满返回 －1
 */
-(int)jvcAudioOffer:(unsigned char *)data nSize:(int)nSize;

/**
 *  退出出队线程
 *
 *  @return 成功返回YES
 */
-(BOOL)exitPopDataThread;

/**
 *  清空队列
 *
 *  @return 成功返回 0
 */
-(int)clearEnqueueData;

@end
