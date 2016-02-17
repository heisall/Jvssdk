//
//  JVCQueueHelper.m
//  CloudSEE
//  视频数据的缓冲队列
//  Created by chenzhenyang on 14-9-9.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import "JVCQueueHelper.h"
#import "data_queue.h"
#include <sys/time.h>

@interface JVCQueueHelper (){
    
    DataQueue      *dqueue;
    pthread_mutex_t mutex;
    long long       lastTime;
    int             nDefaultFrameFps;
    BOOL            bm_exit;
    BOOL            playThreadExit;
    BOOL            isEnable; //是否开启跳帧模式
}

typedef struct queueServiceUtilityClassParam
{
    //float video_frame_rate;
    int   video_frame_seconds_rec_dataSize;
    int   video_frame_decoder_count;
    float video_frame_fps;
    int   video_frame_display_count;
    int   video_frame_Display_Time;
    int   video_frame_decoder_Time;
    
    int   audio_type;
    int   audio_sample_rate;
    int   audio_bit;
    int   audio_channel;
    int   audio_total_count;
    int   audio_decoder_time;
    
}queueServiceUtilityClassParam;


@end

@implementation JVCQueueHelper

@synthesize jvcQueueHelperDelegate;
@synthesize isOnlyIFrame;

queueServiceUtilityClassParam  *param;

static const int  KFrameQueueMinCriticalValue = 2;                  //缓存帧的加快播放临界值最小
static const int  KFrameQueueMaxCriticalValue = 5;                  //缓存帧的加快播放临界值最大
static NSString * const kVideoQueueSemNameDefaultHead  = @"video";  //队列的名称前缀

/**
 * 毫秒级的睡觉
 *
 */
void msleep(int millisSec) {
    
    if (millisSec > 0) {
        
        struct timeval tt;
        tt.tv_sec = 0;
        tt.tv_usec = millisSec * 1000;
        select(0, NULL, NULL, NULL, &tt);
    }
}

/**
 * 秒级的睡觉
 *
 */
void ssleep(int Sec) {
    
    if (Sec > 0) {
        
        struct timeval tt;
        tt.tv_sec = Sec;
        tt.tv_usec = 0;
        select(0, NULL, NULL, NULL, &tt);
    }
}

/**
 * 获取当前时间，单位是毫秒
 *
 */
long long currentMillisSec() {
    
    long long result = 0l;
    
    struct timeval t;
    
    gettimeofday(&t, NULL);
    result = (long long) t.tv_sec * 1000 + t.tv_usec / 1000;
    
    return result;
}

/**
 *   初始化缓存队列对象
 *
 *  @param nLocalChannelID 当前本地通道编号
 *
 *  @return 缓存队列对象
 */
-(id)init:(int)nLocalChannelID{
    
    if (self = [super init]) {
        
        NSString *strQueueSemName = [NSString stringWithFormat:@"%@%d",kVideoQueueSemNameDefaultHead,nLocalChannelID];
        
        dqueue = new DataQueue((char *)[strQueueSemName UTF8String]);
        
        size_t size                = sizeof(queueServiceUtilityClassParam);
        
        param                      = (queueServiceUtilityClassParam *)malloc(size);
        
        /*init the queue_mutex*/
        int ret = pthread_mutex_init(&mutex, NULL);
        
        if (ret != 0) {
            
            printf("%s:pthread_mutex_init error:%s(%d) at %s, line %d.", __func__, strerror(errno), ret, __FILE__, __LINE__);
        }
        
    }
    
    return self;
}

/**
 *  设置O帧传来的默认帧率
 *
 *  @param frameRateValue 帧率
 *  @param enable         YES:启用跳帧
 */
-(void)setDefaultFrameRate:(float)frameRateValue withEnableJumpFrame:(BOOL)enable{
    
    nDefaultFrameFps       = frameRateValue;
    
    //[self Lock];
    param->video_frame_fps = frameRateValue;
    //NSLog(@"%s-----------------%lf",__FUNCTION__,frameRateValue);
    //[self Unlock];
    isEnable               = enable;
}

/**
 *  启动出队线程（消费者）
 */
-(void)startPopDataThread {
    
    NSLog(@"exit %d",bm_exit);
    
    if (!bm_exit) {
        
        [NSThread detachNewThreadSelector:@selector(popDataCallBack) toTarget:self withObject:nil];
    }
}

/**
 *  出队数据的回调
 */
-(void)popDataCallBack{
    
    
    NSLog(@"queuer start pop video thread");

    playThreadExit = TRUE;
    bm_exit = TRUE;
    
    long long timeStamp = currentMillisSec();
    int  needDelay      = 0;
    bool need_jump      = true;
    BOOL isFastPlay     = FALSE;
    
    
    while (TRUE) {
        
        if (!bm_exit) {
            
            break;
        }
        
        //获取当前缓存队列中当前帧的个数
        int queueFrameCount = [self GetEnqueueDataCount];
        
        float queue_fps = param->video_frame_fps;
        
        //当缓存区达到临界值时开启加速播放模式，如果依然排解不了拥堵现象启用跳帧模式
        if (queueFrameCount > KFrameQueueMinCriticalValue && queueFrameCount <= KFrameQueueMaxCriticalValue) {
            
            if (!isFastPlay) {
                
                isFastPlay = TRUE;
                
                queue_fps = param->video_frame_fps + queueFrameCount;
                
                [self Lock];
                param->video_frame_fps = queue_fps;
                [self Unlock];
                
            }
            
        }else{
            
            if (isFastPlay) {
                
                queue_fps   = nDefaultFrameFps;
                
                [self Lock];
                param->video_frame_fps = queue_fps;
                [self Unlock];
                isFastPlay  = FALSE;
            }
            
        }
        
        int full_delay = 1000 / queue_fps;
        
        frame *frameBuffer = (frame * )dqueue->PopData();
        
        if (NULL == frameBuffer) {
            
            continue;
        }
        
        int decoderStatus = -1;
        
        //开启跳帧模式
        if(queueFrameCount > queue_fps && isEnable) {
            
            need_jump = true;
        }
        
        if(need_jump && !frameBuffer->is_i_frame) {
            
//             NSLog(@"%s----need_jump %d queueFrameCount=%d",__FUNCTION__,need_jump,queueFrameCount);
            
        }else {
            
            if(frameBuffer->is_i_frame && need_jump && queueFrameCount < queue_fps) {
                
                //结束跳帧模式，启用正常播放模式
                need_jump = false;
            }
            
//            NSLog(@" jvcQueueHelperDelegate %@",self.jvcQueueHelperDelegate);
            if (self.jvcQueueHelperDelegate !=nil && [self.jvcQueueHelperDelegate respondsToSelector:@selector(popDataCallBack:)]) {
                
                decoderStatus = [self.jvcQueueHelperDelegate popDataCallBack:frameBuffer];
            }
            
            if (!self.isOnlyIFrame && decoderStatus>=0 ) {
                
                needDelay = full_delay - (int) (currentMillisSec() - timeStamp);
                msleep(needDelay);
                timeStamp = currentMillisSec();
                
            }
        }
        
        free(frameBuffer->buf);
        free(frameBuffer);
        
    }

    playThreadExit = FALSE;
}

-(void)dealloc
{
    dqueue->ClearQueue();
    
    delete dqueue;
    
    pthread_mutex_destroy(&mutex);
    
    [super dealloc];
}

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
-(int)offer:(unsigned char *)data withFrameSize:(int)nSize withIsIFrame:(BOOL)isIFrame withIsBFrame:(BOOL)isBFrame withFrameType:(int)frameType
{
    if (dqueue==NULL || !bm_exit)
        return  OPERATION_TYPE_ERROR;
    
    size_t size                = sizeof(frame);
    
    frame *bufferFrame      = (frame *)malloc(size);
    memset(bufferFrame, 0, size);
    
    if (nSize > 0) {
        
        bufferFrame->nSize      = nSize;
        bufferFrame->is_i_frame = isIFrame;
        bufferFrame->is_b_frame = isBFrame;
        bufferFrame->nFrameType = frameType;
        
        bufferFrame->buf = (unsigned char *)malloc(sizeof(unsigned char)*nSize);
        
        memcpy(bufferFrame->buf, data, nSize);
        
    }else{
        
        bufferFrame->nSize      = 0;
        bufferFrame->is_i_frame = FALSE;
        bufferFrame->buf = NULL;
        bufferFrame->is_b_frame = FALSE;
    }
    
    int result = dqueue->PushData(bufferFrame);
    
    if (result == 0) {
        
        //        [self Lock];
        //
        //        param.video_frame_fps ++;
        //
        //        param.video_frame_seconds_rec_dataSize += nSize;
        //
        //        [self Unlock];
    }
    
    sem_post(dqueue->dataqueue_sem_);
    
    return result;
}

/**
 *  获取队列中的数据个数
 *
 *  @return 队列中的数据个数
 */
-(int)GetEnqueueDataCount{
    
    if (dqueue==NULL)
        return  OPERATION_TYPE_ERROR;
    
    int result = dqueue->GetQueueDataSize();
    return result;
}

/**
 *  判断队列是否为空
 *
 *  @return YES空 NO:不为空
 */
-(BOOL) isQueueEmpty{
    
    if (dqueue==NULL)
        return  OPERATION_TYPE_ERROR;
    
    bool result = dqueue->IsQueueEmpty();
    
    return result;
}

/**
 *  清空队列
 *
 *  @return 成功返回 0
 */
-(int)clearEnqueueData{
    
    if (dqueue==NULL)
        return  OPERATION_TYPE_ERROR;
    
    int result = dqueue->ClearQueue();
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
    sem_post(dqueue->dataqueue_sem_);
    
    while (TRUE) {
        
        if (playThreadExit) {
            
            msleep(40);
            
        }else{
            
            result = true;
            break;
        }
    }
    
    return result;
}

/**
 *  上锁
 */
-(void)Lock
{
    pthread_mutex_lock(&mutex);
}

/**
 *  下锁
 */
-(void)Unlock
{
    pthread_mutex_unlock(&mutex);
}

/**
 *  每秒统计当前的码率bps等
 */
-(void)refreshParam{
    
    //    while (true) {
    //
    //        [self Lock];
    //
    //        long long currentTime = currentMillisSec();
    //
    //        long delayed     = currentTime - lastTime;
    //
    //        int netWorkSingleFrameTime = delayed / param->video_frame_fps;
    //        int decoderSingleFrameTime = param->video_frame_decoder_Time / param->video_frame_decoder_count;
    //        int displaySingleFrameTime = param->video_frame_Display_Time / param->video_frame_display_count;
    //
    //        int audioSingePlayTime     = param->audio_decoder_time       / param->audio_total_count;
    //
    //        // printf("currentTime = %lld-lastTime=%lld---delayed=%ld video: Bps=%d videoNetCount=%d videoNetSingleFrmae=%d,videoDecodeCount=%d,videoDecodeSingleTime=%d,displayCount=%d,displaySingleTime=%d audio: audioCount=%d,audioSingleTime=%d\n",currentTime,lastTime,delayed,playChannel.video_frame_seconds_total/1024,playChannel.video_frame_net_count,netWorkSingleFrameTime,playChannel.video_frame_decoder_count,decoderSingleFrameTime,playChannel.video_frame_display_count,displaySingleFrameTime,playChannel.audio_total_count,audioSingePlayTime);
    //
    //        param->video_frame_decoder_count        = 0;
    //        //param.video_frame_rate                 = 0;
    //        param->video_frame_seconds_rec_dataSize = 0;
    //        param->video_frame_decoder_count        = 0;
    //        param->video_frame_fps                  = 0;
    //        param->video_frame_display_count        = 0;
    //        param->video_frame_Display_Time         = 0;
    //        param->video_frame_decoder_Time         = 0;
    //
    //        param->audio_type                = 0;
    //        param->audio_sample_rate         = 0;
    //        param->audio_bit                 = 0;
    //        param->audio_channel             = 0;
    //        param->audio_total_count         = 0;
    //        param->audio_decoder_time        = 0;
    //        
    //        lastTime         =  currentTime;
    //        
    //        [self Unlock];
    //        
    //        ssleep(1);
    //        
    //    }
}

@end
