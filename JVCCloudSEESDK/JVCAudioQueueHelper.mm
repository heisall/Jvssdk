//
//  JVCAudioQueueHelper.m
//  CloudSEE
//
//  Created by chenzhenyang on 14-9-17.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import "JVCAudioQueueHelper.h"
#import "data_queue.h"
#include <sys/time.h>
#import  "JVCQueueMacro.h"

@interface JVCAudioQueueHelper (){
    
    DataQueue      *audioqueue;
    BOOL            bm_exit;
    BOOL            playThreadExit;
    
}

@end
@implementation JVCAudioQueueHelper
@synthesize jvcAudioQueueHelperDelegate;

static NSString const * kAudioQueueSemNameDefaultHead = @"audio";

/**
 *  初始化缓存队列对象
 *
 *  @param nLocalChannelID 本地连接通道编号
 *
 *  @return 缓存队列对
 */
-(id)init:(int)nLocalChannelID{
    
    if (self = [super init]) {
        
        NSString *strAudioQueueName = [NSString stringWithFormat:@"%@%d",kAudioQueueSemNameDefaultHead,nLocalChannelID];
        
        audioqueue = new DataQueue((char *)[strAudioQueueName UTF8String]);
    }
    
    return self;
}

-(void)dealloc
{
    audioqueue->ClearQueue();
    delete audioqueue;
    
    NSLog(@"%s",__FUNCTION__);
    
    [super dealloc];
}

/**
 *  数据入队 （生产者）
 *
 *  @param data       入队的数据
 *  @param nSize      入队的数据大小
 *  @param is_i_frame 是否是I帧（视频数据用的）
 *
 *  @return 成功返回 0, 队列满返回 －1
 */
-(int)jvcAudioOffer:(unsigned char *)data nSize:(int)nSize
{
    if (audioqueue==NULL || !bm_exit)
        return  OPERATION_TYPE_ERROR;
    
    int result = 0;
    
    if (nSize > 0) {
        
        size_t size                = sizeof(frame);
        
        frame *bufferFrame      = (frame *)malloc(size);
        memset(bufferFrame, 0, size);
        
        bufferFrame->nSize      = nSize;
        bufferFrame->buf = (unsigned char *)malloc(sizeof(unsigned char)*nSize);
        
        memcpy(bufferFrame->buf, data, nSize);
        
        result = audioqueue->PushData(bufferFrame);
        
        sem_post(audioqueue->dataqueue_sem_);
        
    }
    
    return result;
}

/**
 *  启动出队线程（消费者）
 */
-(void)startAudioPopDataThread {
    
    if (!bm_exit) {
        
        NSLog(@"%s-090909",__FUNCTION__);
        
        [NSThread detachNewThreadSelector:@selector(popAudioDataCallBack) toTarget:self withObject:nil];
    }
}

/**
 *  出队数据的回调
 */
-(void)popAudioDataCallBack{
    
    playThreadExit = TRUE;
    bm_exit = TRUE;
    
    NSLog(@"%s-----start popDataCallBack",__FUNCTION__);
    
    while (TRUE) {
        
        if (!bm_exit) {
            
            break;
        }
        
        frame *frameBuffer = (frame * )audioqueue->PopData();
        // DDLogInfo(@"%s-----audio",__FUNCTION__);
        
        if (NULL == frameBuffer) {
            
            continue;
        }
        
        //DDLogInfo(@"%s-----audioCount=%d",__FUNCTION__,audioCount);
        if (self.jvcAudioQueueHelperDelegate != nil && [self.jvcAudioQueueHelperDelegate respondsToSelector:@selector(popAudioDataCallBack:)]) {
            
            [self.jvcAudioQueueHelperDelegate popAudioDataCallBack:frameBuffer];
        }
        free(frameBuffer->buf);
        free(frameBuffer);
    }
    
    NSLog(@"%s----playThread---end",__FUNCTION__);
    playThreadExit = FALSE;
}

/**
 * 毫秒级的睡觉
 *
 */
void jvcAudioQueueMsleep(int millisSec) {
    
    if (millisSec > 0) {
        
        struct timeval tt;
        tt.tv_sec = 0;
        tt.tv_usec = millisSec * 1000;
        select(0, NULL, NULL, NULL, &tt);
    }
}

/**
 *  清空队列
 *
 *  @return 成功返回 0
 */
-(int)clearEnqueueData{
    
    if (audioqueue == NULL)
        return  OPERATION_TYPE_ERROR;
    
    int result = audioqueue->ClearQueue();
    return result;
}

/**
 *  退出出队线程
 *
 *  @return 成功返回YES
 */
-(BOOL)exitPopDataThread
{
    
    [self clearEnqueueData];
    
    BOOL result = FALSE;
    bm_exit = FALSE;
    sem_post(audioqueue->dataqueue_sem_);
    
    while (TRUE) {
        
        if (playThreadExit) {
            
            jvcAudioQueueMsleep(40);
            
        }else{
            
            result = true;
            break;
        }
    }
    
    NSLog(@"%s----exit--successful",__FUNCTION__);
    
    return result;
}

@end
