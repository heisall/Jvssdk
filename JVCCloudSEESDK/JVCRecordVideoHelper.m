//
//  JVCRecordVideoHelper.m
//  CloudSEE
//  本地录像处理模块
//  Created by chenzhenyang on 14-9-19.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import "JVCRecordVideoHelper.h"
#import "JVCRecordVideoInter.h"

@interface JVCRecordVideoHelper (){
    
    int nRecordViddeoChannelID;
}

@end
@implementation JVCRecordVideoHelper
@synthesize isRecordVideo,isRecordVideoWaitingFrameI;

-(void)dealloc{
    
    [super dealloc];
}

/**
 *  打开录像的编码器
 *
 *  @param strRecordVideoPath 录像的地址
 *  @param nRecordChannelID   录像的通道号
 *  @param nWidth             录像视频的宽
 *  @param nHeight            录像视频的高
 *  @param dRate              录像的帧率
 */
-(void)openRecordVideo:(NSString *)strRecordVideoPath nRecordChannelID:(int)nRecordChannelID nWidth:(int)nWidth nHeight:(int)nHeight dRate:(double)dRate{
    
    [strRecordVideoPath retain];

    if (!self.isRecordVideo) {
        
        self.isRecordVideo              = TRUE;
        self.isRecordVideoWaitingFrameI = TRUE;
        
        nRecordViddeoChannelID = nRecordChannelID;
        
        
        JP_OpenPackage((char*)[strRecordVideoPath UTF8String],nRecordChannelID,nWidth,nHeight,dRate,0,0);
        
    }else {
        
    }
    
    [strRecordVideoPath release];
}

/**
 *  录像一帧的方法
 *
 *  @param videoData     录像的视频数据
 *  @param isVideoDataI  是否是I帧
 *  @param isVideoDataB  是否是B帧
 *  @param videoDataSize 视频数据的大小
 */
-(void)saveRecordVideoDataToLocal:(char *)videoData isVideoDataI:(BOOL)isVideoDataI isVideoDataB:(BOOL)isVideoDataB videoDataSize:(int)videoDataSize {
    
    if (self.isRecordVideo) {
        
        if (self.isRecordVideoWaitingFrameI) {
            
            if (isVideoDataI) {
                
                self.isRecordVideoWaitingFrameI = FALSE;
                
                JP_PackageOneFrame((unsigned char*)videoData, videoDataSize,nRecordViddeoChannelID,0,0);
            }
            
        }else{
            
            if (!isVideoDataB) {
                
                JP_PackageOneFrame((unsigned char*)videoData, videoDataSize, nRecordViddeoChannelID,0,0);
                
            }else{
                
                unsigned char nullVideoData[videoDataSize];
                memset(nullVideoData, 0, videoDataSize);
                
                JP_PackageOneFrame(nullVideoData ,videoDataSize, nRecordViddeoChannelID,0,0);
            }
        }
        
    }else{
        
    }
}


/**
 *  停止录像
 */
-(void)stopRecordVideo{
    
    if (self.isRecordVideo) {
        
        self.isRecordVideo              = FALSE;
        self.isRecordVideoWaitingFrameI = FALSE;
        
        JP_ClosePackage(nRecordViddeoChannelID);
        
    }else{
        
    }
}

@end
