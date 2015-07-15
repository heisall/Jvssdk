//
//  JVCVideoDecoderHelper.m
//  CloudSEE_II
//  用于解码处理的助手类
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCVideoDecoderHelper.h"
#import "JVCVideoDecoderInterface.h"
#import <pthread.h>
#import "JVCDecoderMacro.h"

@interface JVCVideoDecoderHelper () {
    
    pthread_mutex_t        videoMutex;
    pthread_mutex_t        audioMutex;
    DecoderOutVideoFrame  *outVideoFrame;
    int                    nDecoderID;
}
@end

@implementation JVCVideoDecoderHelper
@synthesize nVideoWidth,nVideoHeight,dVideoframeFrate;
@synthesize isDecoderModel,isWaitIFrame;
@synthesize isExistStartCode,isOpenDecoder,isCaptureImage;
@synthesize IsOpenDecoderSound,nAudioCollectionType;
@synthesize IsEnableSceneImages;
@synthesize delegate;

char  captureImageBuffer[1280*720*3] ={0};

-(void)dealloc {
    
    pthread_mutex_destroy(&videoMutex);
    
    free(outVideoFrame);
    outVideoFrame = NULL;
    
    [super dealloc];
}

-(id)init{
    
    
    if (self=[super init]) {
        
        pthread_mutex_init(&videoMutex, nil);
        
        outVideoFrame = malloc(sizeof(DecoderOutVideoFrame));
        memset(outVideoFrame, 0, sizeof(DecoderOutVideoFrame));
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


#pragma mark 解码器相关的处理模块

/**
 *  打开解码器 包括H264和H265
 *
 *  @param nVideoDecodeID 解码器编号(0~15)
 */
-(void)openVideoDecoder:(int)nVideoDecodeID wVideoCodecID:(int)wVideoCodecID{
    
    
    if (!self.isOpenDecoder) {
        
        if (self.nVideoWidth > 0 && self.nVideoHeight > 0) {
            
            self.isOpenDecoder   = TRUE;
            nDecoderID = nVideoDecodeID;
            if (self.isDecoderModel) {
                //int codecID = 0;
                //                memset(outVideoFrame->decoder_y, 0, sizeof(outVideoFrame->decoder_y));
                //                memset(outVideoFrame->decoder_u, 0, sizeof(outVideoFrame->decoder_u));
                //                memset(outVideoFrame->decoder_v, 0, sizeof(outVideoFrame->decoder_v));
                
                if(wVideoCodecID == IPC_VIDEO_DECODER_H265)
                    JVD05_DecodeOpen(nVideoDecodeID, VIDEO_DECODER_H265);
                else
                    JVD05_DecodeOpen(nVideoDecodeID, VIDEO_DECODER_H264);
                
            }else {
                
                JVD04_DecodeOpen(self.nVideoWidth ,self.nVideoHeight ,nVideoDecodeID);
            }
            
        }
    }
    else {
        
        // DDLogError(@"%s---videoDecoder(解码器编号：%d) 打开失败，原因解码器已存在",__FUNCTION__,nVideoDecodeID);
    }
}

/**
 *  打开解码器 包括H264和H265
 *
 *  @param nVideoDecodeID 解码器编号(0~15)
 */
-(void)openVideoDecoderForMP4:(int)nVideoDecodeID wVideoCodecID:(int)wVideoCodecID{
    
    
    if (!self.isOpenDecoder) {
        
        if (self.nVideoWidth > 0 && self.nVideoHeight > 0) {
            
            self.isOpenDecoder   = TRUE;
            nDecoderID = nVideoDecodeID;
            if (self.isDecoderModel) {
                JVD05_DecodeOpen(nVideoDecodeID, wVideoCodecID);
                
            }else {
                
                JVD04_DecodeOpen(self.nVideoWidth ,self.nVideoHeight ,nVideoDecodeID);
            }
            
        }
    }
    else {
        
        // DDLogError(@"%s---videoDecoder(解码器编号：%d) 打开失败，原因解码器已存在",__FUNCTION__,nVideoDecodeID);
    }
}
/**
 *  关闭解码器
 *
 *  @param nVideoDecodeID 解码器编号
 */
-(void)closeVideoDecoder{
    
    if (self.isOpenDecoder) {
        
        //05版
        if (self.isDecoderModel) {
            
            [self videoLock];
            JVD05_DecodeClose(nDecoderID);
            [self VideoUnlock];
            
        }else{
            
            [self videoLock];
            JVD04_DecodeClose(nDecoderID);
            [self VideoUnlock];
        }
        
        self.isOpenDecoder = FALSE;
        self.isWaitIFrame  = FALSE;
        
    }else {
        
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
-(int)decodeOneVideoFrame:(frame *)videoFrame nSystemVersion:(int)nSystemVersion VideoOutFrame:(DecoderOutVideoFrame **)VideoOutFrame {
    
    int ndecoderStatus = -1;
    
    if (self.isOpenDecoder) {
        
        //等待I帧处理
        [self waitingIFrameByVideoFrameType:videoFrame->is_i_frame];
        
        if (self.isWaitIFrame) {
            
            if (self.isDecoderModel) {
                
                [self videoLock];
                
                
                ndecoderStatus = JVD05_DecodeOneFrame(nDecoderID,videoFrame->nSize,videoFrame->buf,&outVideoFrame->decoder_y,&outVideoFrame->decoder_u,&outVideoFrame->decoder_v,0,nSystemVersion,0,&outVideoFrame->nWidth,&outVideoFrame->nHeight);
                
                if (outVideoFrame->nWidth <=0 || outVideoFrame->nHeight <=0) {
                    
                    ndecoderStatus =  -1;
                    
                }else{
                    
                    if (self.isCaptureImage || self.IsEnableSceneImages) {
                        
                        if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(decoderModelCaptureImageCallBack:)]) {
                            
                            yuv_rgb(nDecoderID,(unsigned int*)(captureImageBuffer+66),nSystemVersion);
                            
                            CreateBitmap((unsigned char *)captureImageBuffer,outVideoFrame->nWidth,outVideoFrame->nHeight,nSystemVersion);
                            NSData *captureImageData=[NSData dataWithBytes:captureImageBuffer length:outVideoFrame->nWidth*outVideoFrame->nHeight*2+66];
                            
                            [self.delegate decoderModelCaptureImageCallBack:captureImageData];
                        }
                        
                        self.IsEnableSceneImages = FALSE;
                        self.isCaptureImage = FALSE;
                    }
                }
                
                [self VideoUnlock];
                
            }else {
                
                [self videoLock];
                
                outVideoFrame->nHeight = self.nVideoHeight;
                outVideoFrame->nWidth  = self.nVideoWidth;
                
                ndecoderStatus = JVD04_DecodeOneFrame(videoFrame->buf,videoFrame->nSize, &outVideoFrame->decoder_y,&outVideoFrame->decoder_u,&outVideoFrame->decoder_v,nDecoderID,videoFrame->nFrameType,nSystemVersion);
                
                if (self.isCaptureImage || self.IsEnableSceneImages) {
                    
                    if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(decoderModelCaptureImageCallBack:)]) {
                        
                        yuv_rgb_04(nDecoderID,(unsigned int*)(captureImageBuffer+66),nSystemVersion);
                        CreateBitmap_04((unsigned char *)captureImageBuffer,outVideoFrame->nWidth,outVideoFrame->nHeight,nSystemVersion);
                        
                        NSData *captureImageData=[NSData dataWithBytes:captureImageBuffer length:outVideoFrame->nWidth*outVideoFrame->nHeight*2+66];
                        
                        [self.delegate decoderModelCaptureImageCallBack:captureImageData];
                    }
                    
                    self.IsEnableSceneImages = FALSE;
                    self.isCaptureImage = FALSE;
                }
                
                [self VideoUnlock];
                
            }
        }
        
        //NSLog(@"%s-------outVideoFrame->nWidth=%d---outVideoFrame->nHeigh=%d",__FUNCTION__,outVideoFrame->nWidth,outVideoFrame->nHeight);
    }else{
        
        NSLog(@"%s----视频解码失败(解码器编号：%d)，原因解码器未打开",__FUNCTION__,nDecoderID);
    }
    
    *VideoOutFrame = outVideoFrame;
    
    return ndecoderStatus;
}


/**
 *  等待I帧处理
 *
 *  @param nvideoFrameType 一帧视频数据
 */
-(void)waitingIFrameByVideoFrameType:(BOOL)nvideoFrameType {
    
    if (!self.isWaitIFrame) {
        
        if (nvideoFrameType) {
            
            self.isWaitIFrame = YES;
        }
    }
}

@end
