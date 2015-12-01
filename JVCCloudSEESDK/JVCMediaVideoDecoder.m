//
//  JVCMediaVideoDecoder.m
//  JVCCloudSEESDK
//
//  Created by Yale on 15/6/3.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import "JVCMediaVideoDecoder.h"
#import <pthread.h>
#import "JVCVideoDecoderInterface.h"
#import "JVCMP4Player.h"

@interface JVCMediaVideoDecoder () {
    
    pthread_mutex_t        videoMutex;
    OutVideoFrame  *outVideoFrame;
}

@end

@implementation JVCMediaVideoDecoder
@synthesize isOpenDecoder,nVideoType;

-(void)dealloc {
    
    pthread_mutex_destroy(&videoMutex);
    
    free(outVideoFrame);
    outVideoFrame = NULL;
    
    [super dealloc];
}


-(id)init{
    
    
    if (self=[super init]) {
        
        pthread_mutex_init(&videoMutex, nil);
        
        outVideoFrame = malloc(sizeof(OutVideoFrame));
        memset(outVideoFrame, 0, sizeof(OutVideoFrame));
        
    }
    
    return self;
}

/**
 *  视频解码上锁，防止解码时关闭解码器
 */
-(void)videoLock
{
    pthread_mutex_lock(&videoMutex);
}

/**
 *  视频解完码解锁
 */
-(void)VideoUnlock
{
    pthread_mutex_unlock(&videoMutex);
}

/**
 *  打开解码器 包括H264和H265
 *
 *  @param nVideoDecodeID 解码器编号(0~15)
 */
-(void)openVideoDecoder:(int)nVideoDecodeID wVideoCodecID:(int)wVideoCodecID{
    
    if(!isOpenDecoder){
        
        JVD05_DecodeOpen(nVideoDecodeID, wVideoCodecID);
        isOpenDecoder = TRUE;
    }else{
        NSLog(@"already open decoder type %d", wVideoCodecID);
    }
    
}

/**
 *  关闭解码器
 *
 */
-(void)closeVideoDecoder
{
    if(self.isOpenDecoder){
        
        [self videoLock];
        JVD05_DecodeClose(0);
        [self VideoUnlock];
        
        isOpenDecoder = FALSE;
    }

}

/**
 *  解码一帧
 *
 *  @param videoFrame      视频帧数据
 *  @param nSystemVersion  当前手机系统的版本
 *  @param VideoOutFrame   解码返回的结构
 *
 *  @return 解码成功返回 0 否则失败
 */
-(int)decodeOneVideoFrame:(VideoFrame *)videoFrame nSystemVersion:(int)nSystemVersion VideoOutFrame:(OutVideoFrame **)VideoOutFrame
{
    int ndecoderStatus = -1;
    
    [self videoLock];
    
    if (self.isOpenDecoder) {
        ndecoderStatus = JVD05_DecodeOneFrame(0,videoFrame->nSize,videoFrame->buf,&outVideoFrame->decoder_y,&outVideoFrame->decoder_u,&outVideoFrame->decoder_v,0,1,0,&outVideoFrame->nWidth,&outVideoFrame->nHeight);
    }
    
    [self VideoUnlock];
    
    if (outVideoFrame->nWidth <=0 || outVideoFrame->nHeight <=0) {
        
        ndecoderStatus =  -1;
        
    }
    
    *VideoOutFrame = outVideoFrame;
    
    return ndecoderStatus;
}


@end
