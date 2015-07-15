//
//  JVCRecordVideoHelper.m
//  CloudSEE
//  本地录像处理模块
//  Created by chenzhenyang on 14-9-19.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import "JVCRecordVideoHelper.h"
#import "JVCRecordVideoInter.h"
#include "Jmp4pkg.h"

@interface JVCRecordVideoHelper (){
    
    int nRecordViddeoChannelID;
}

@end
@implementation JVCRecordVideoHelper
@synthesize isRecordVideo,isRecordVideoWaitingFrameI;

PKG_VIDEO_PARAM		VideoParam		= {0};
MP4_PKG_HANDLE 		pkgHandle 		= NULL;


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

        int				bWriteVideo	= 1;
        int				bWriteAudio = 0;
        
        char *pszPkgFile = (char*)[strRecordVideoPath UTF8String];
        //char *pszPkgJdx  = "../bin/22.jdx";
        char *pszPkgJdx  = NULL;
        
        int				iAVCodec		= 0;
        int				iVCodec		= JVS_VCODEC_H264;
        int				iACodec		= JVS_ACODEC_ALAW;
        iAVCodec = iVCodec;
        iAVCodec |= iACodec;
        
        VideoParam.iFrameWidth	= nWidth;
        VideoParam.iFrameHeight	= nHeight;
        VideoParam.fFrameRate	= (float) dRate;
        
        pkgHandle = JP_OpenPackage(&VideoParam, bWriteVideo, bWriteAudio, pszPkgFile, pszPkgJdx, iAVCodec, 0);
        
        if (pkgHandle == NULL)
        {
            printf( "JP_OpenPackage fail %s\n", pszPkgFile);
        }
        
    }else {
        
    }
    
    [strRecordVideoPath release];
}

/**
 *  录像一帧的方法
 *
 *  @param videoData     录像的视频数据
 *  @param isVideoDataI  是否是I帧
 *  @param isVideoData
 
 
 B  是否是B帧
 *  @param videoDataSize 视频数据的大小
 */
-(void)saveRecordVideoDataToLocal:(char *)videoData isVideoDataI:(BOOL)isVideoDataI isVideoDataB:(BOOL)isVideoDataB videoDataSize:(int)videoDataSize {
    
    
    if (self.isRecordVideo) {
        
        AV_PACKET avPkt	= {0};
        avPkt.pData = (unsigned char*)videoData;
        avPkt.iSize = videoDataSize;
        avPkt.iType = JVS_PKG_VIDEO;
        avPkt.iPts = 0;
        avPkt.iDts = 0;
        
        JP_PackageOneFrame(pkgHandle, &avPkt);
        
        if (self.isRecordVideoWaitingFrameI) {
            
            if (isVideoDataI) {
                
                self.isRecordVideoWaitingFrameI = FALSE;

            }
            
        }else{
            
            if (!isVideoDataB) {

                
            }else{
                
                unsigned char nullVideoData[videoDataSize];
                memset(nullVideoData, 0, videoDataSize);
                
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
        
        if(pkgHandle != NULL){
            JP_ClosePackage(pkgHandle);
        }
        
    }else{
        
    }
}

@end
