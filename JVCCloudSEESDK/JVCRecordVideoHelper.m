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
#import <pthread.h>
/**IOS支持的最大分辨率 1920*1080，超过这个分辨率的视频将不能移动到相册**/

#define IOS_MAX_RESOLUTION_WIDTH   1920
#define IOS_MAX_RESOLUTION_HEIGHT  1080
@interface JVCRecordVideoHelper (){
    
    int nRecordViddeoChannelID;
}

@end
@implementation JVCRecordVideoHelper
@synthesize isRecordVideo,isRecordVideoWaitingFrameI;

PKG_VIDEO_PARAM		VideoParam		= {0};
MP4_PKG_HANDLE 		pkgHandle 		= NULL;
pthread_mutex_t rec_mutex;


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
-(void)openRecordVideo:(NSString *)strRecordVideoPath nRecordChannelID:(int)nRecordChannelID nWidth:(int)nWidth nHeight:(int)nHeight dRate:(double)dRate audiotype:(int)audioType{
    
    [strRecordVideoPath retain];
    
    if (!self.isRecordVideo) {
        
        self.isRecordVideo              = TRUE;
        self.isRecordVideoWaitingFrameI = TRUE;
        
        nRecordViddeoChannelID = nRecordChannelID;
        
        if(nWidth > IOS_MAX_RESOLUTION_WIDTH)
            nWidth = IOS_MAX_RESOLUTION_WIDTH;
        if(nHeight > IOS_MAX_RESOLUTION_HEIGHT)
            nHeight = IOS_MAX_RESOLUTION_HEIGHT;
        
        int				bWriteVideo	= 1;
        int				bWriteAudio = 1;
        
        char *pszPkgFile = (char*)[strRecordVideoPath UTF8String];
        //char *pszPkgJdx  = "../bin/22.jdx";
        char *pszPkgJdx  = NULL;
        
        int				iAVCodec		= 0;
        int				iVCodec		= JVS_VCODEC_H264;
        int				iACodec		= JVS_ACODEC_ULAW;
        iAVCodec = iVCodec;
        switch (audioType) {
            case JVS_AUDIOCODECTYPE_AMR:
                iACodec = 0;
                self.isMP4AudioType = FALSE;
                break;
            case JVS_AUDIOCODECTYPE_G711_alaw:
                iACodec = JVS_ACODEC_ALAW;
                self.isMP4AudioType = TRUE;
                break;
            case JVS_AUDIOCODECTYPE_G711_ulaw:
                iACodec = JVS_ACODEC_ULAW;
                self.isMP4AudioType = TRUE;
                break;
            default:
                self.isMP4AudioType = FALSE;
                break;
        }
        iAVCodec |= iACodec;
        
        
        VideoParam.iFrameWidth	= nWidth;
        VideoParam.iFrameHeight	= nHeight;
        VideoParam.fFrameRate	= (float) dRate;
        
        pthread_mutex_init(&rec_mutex, NULL);
        pkgHandle = JP_OpenPackage(&VideoParam, bWriteVideo, bWriteAudio, pszPkgFile, pszPkgJdx, iAVCodec, 0);
        
        
        //        JP_OpenPackage((char*)[strRecordVideoPath UTF8String],nRecordChannelID,nWidth,nHeight,dRate,0,0);
        
//        DDLogVerbose(@"%s---OpenPackage-------localPath=%@ height=%d,width=%d  VideoframeFrate=%lf pkghandle %p",__FUNCTION__,strRecordVideoPath,nWidth,nHeight,dRate,pkgHandle);
    }else {
        
//        DDLogVerbose(@"%s---OpenPackage existing",__FUNCTION__);
    }
    
    [strRecordVideoPath release];
}

/**
 * 封一帧MP4的音频
 *
 */
-(void)saveMP4AudioData:(char *)audioData size:(int)audioSize{
    
    if (self.isRecordVideo&&self.isMP4AudioType) {
        
        //        NSLog(@"save mp4 audio size %d",audioSize);
        AV_PACKET avPkt	= {0};
        avPkt.pData = (unsigned char*)audioData;
        avPkt.iSize = audioSize;
        avPkt.iType = JVS_PKG_AUDIO;
        avPkt.iPts = 0;
        avPkt.iDts = 0;
        
        //        NSLog(@"audio data %x %x %x %x %x",avPkt.pData[0],avPkt.pData[1],avPkt.pData[2],avPkt.pData[3],avPkt.pData[4]);
        
        if (pkgHandle) {
            pthread_mutex_lock(&rec_mutex);
            JP_PackageOneFrame(pkgHandle, &avPkt);
            pthread_mutex_unlock(&rec_mutex);
        }else{
            NSLog(@"pkghandle is null !!");
        }
        
        //        if (audiofile) {
        //            fwrite(audioData, 1, audioSize, audiofile);
        //        }
    }
    
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
