//
//  JVCQueueHelper.h
//  CloudSEE
//
//  Created by chenzhenyang on 14-9-9.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCQueueMacro.h"

@protocol JVCQueueHelperDelegate <NSObject>

/**
 *  缓存队列的出队入口数据
 *
 *  @param bufferData 队列出队的Buffer
 *
 *  @return >=时数据生效
 */
-(int)popDataCallBack:(void *)bufferData;

@end

@interface JVCQueueHelper : NSObject{
    
    id<JVCQueueHelperDelegate> jvcQueueHelperDelegate;
    BOOL                       isOnlyIFrame;
}

@property (nonatomic,assign) id<JVCQueueHelperDelegate> jvcQueueHelperDelegate;
@property (nonatomic,assign) BOOL                       isOnlyIFrame;

/**
 *   初始化缓存队列对象
 *
 *  @param nLocalChannelID 当前本地通道编号
 *
 *  @return 缓存队列对象
 */
-(id)init:(int)nLocalChannelID;

/**
 *  设置O帧传来的默认帧率
 *
 *  @param frameRateValue 帧率
 *  @param enable         YES:启用跳帧
 */
-(void)setDefaultFrameRate:(float)frameRateValue withEnableJumpFrame:(BOOL)enable;

/**
 *  启动出队线程（消费者）
 */
-(void)startPopDataThread;


/**
 *  数据入队 （生产者）
 *
 *  @param data      入队的数据
 *  @param nSize     入队的数据大小
 *  @param isIFrame  是否是I帧（视频数据用的）
 *  @param isBFrame  是否是B帧
 *  @param frameType 帧类型
 *
 *  @return 成功返回 0, 队列满返回 －1
 */
-(int)offer:(unsigned char *)data withFrameSize:(int)nSize withIsIFrame:(BOOL)isIFrame withIsBFrame:(BOOL)isBFrame withFrameType:(int)frameType;

/**
 *  清空队列
 *
 *  @return 成功返回YES
 */
-(int)clearEnqueueData;

/**
 *  退出出队线程
 *
 *  @return 成功返回YES
 */
-(BOOL)exitPopDataThread;

@end
