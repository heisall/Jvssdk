//
//  JVCRTMPHelper.m
//  CloudSEE_II
//
//  Created by Yale on 15/4/29.
//  Copyright (c) 2015年 Yale. All rights reserved.
//

#import "JVCRTMPHelper.h"
#import "JVCQueueHelper.h"
#import "JVCVideoDecoderHelper.h"
#import "JVCAudioQueueHelper.h"
#import "JVCPlaySoundHelper.h"

static JVCRTMPHelper *helper = nil;

@implementation JVCRTMPHelper{
    
    DecoderOutVideoFrame  *jvcOutVideoFrame;
}

@synthesize showView;
@synthesize glView;
@synthesize isConning;
/**
 *  单例
 *
 *  @return 对象
 */
+(JVCRTMPHelper *)shareRtmpHelper
{
    @synchronized(self)
    {
        if (helper == nil) {
            
            helper = [[self alloc] init];
            
        }
        
        return helper;
    }
    
    return helper;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (helper == nil) {
            
            helper = [super allocWithZone:zone];
            
            return helper;
        }
    }
    
    return nil;
}

- (void)ResourceInit:(UIView *)playerView{
    
    self.showView = playerView;
    glView = [[GlView alloc] init:self.showView.bounds.size.width withdecoderHeight:self.showView.bounds.size.height withDisplayWidth:self.showView.bounds.size.width withDisplayHeight:self.showView.bounds.size.height];
    
    [glView showWithOpenGLView];
    [self.showView addSubview:glView._kxOpenGLView];
    [glView updateDecoderFrame:self.showView.bounds.size.width  displayFrameHeight:self.showView.bounds.size.height];
    
    [JVCRTMPPlayerHelper shareRtmpPlayerHelper].delegate =self;
}

- (void)ResourceRelease{
    
    if(glView){
        
        [glView clearVideo];
        glView = nil;
        self.showView = nil;
        
        [JVCRTMPPlayerHelper shareRtmpPlayerHelper].delegate =nil;
        [[JVCRTMPPlayerHelper shareRtmpPlayerHelper] RtmpResourceRelease];
    }
}


- (void) connRtmpUrl:(NSString *)rtmpUrl nChannelID:(int)nChannelID playerView:(UIView *)playerView
{
    [self ResourceInit:playerView];
    
    JVC_ConnectRTMP(nChannelID,[rtmpUrl UTF8String],jvcrtmp_connectchange,jvcrtmp_videoCallBack);
}

/**
 *  RTMP连接状态的回调
 *
 *  @param nLocalChannel    连接的本地通道号 从1开始
 *  @param uchType          1:connect successa;
 *                          2:connect failed；
 *                          3:disconnect success；
 *                          4:exception disconnect
 *  @param pMsg             连接状态的信息
 *  @param nPWData          视频数据大小
 */

void jvcrtmp_connectchange(int nLocalChannel, unsigned char uchType, char *pMsg, int nPWData)
{
    switch (uchType) {
        case 1:{
        }
            break;
        case 2:
            //[[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"RTMP连接失败"];
            
            break;
        case 3:{
             //[[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"RTMP断开成功"];
        }
            
            break;
        case 4:
            //[[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"RTMP出现异常"];
            break;
        default:
            break;
    }
}

/**
 *  RTMP的视频回调函数
 *
 *  @param nLocalChannel    连接的本地通道号 从1开始
 *  @param uchType          视频数据类型（I、B、P等）
 *  @param pBuffer          H264 视频数据或音频数据
 *  @param nSize            视频数据大小
 *  @param nTimestamp       时间戳
 */

void jvcrtmp_videoCallBack(int nLocalChannel, unsigned char uchType, unsigned char *pBuffer, int nSize,int nTimestamp)
{
    
    switch (uchType) {
            
        case RTMP_TYPE_META:
        {                        //O帧
            JVRTMP_Metadata_t* rtmp_meta = (JVRTMP_Metadata_t*) pBuffer;
            NSLog(@"rtmp_meta->nAudioChannels = %d", rtmp_meta->nAudioChannels);
            NSLog(@"rtmp_meta->nAudioDataType =%d", rtmp_meta->nAudioDataType);
            NSLog(@"rtmp_meta->nAudioSampleBits =%d", rtmp_meta->nAudioSampleBits);
            NSLog(@"rtmp_meta->nAudioSampleRate =%d", rtmp_meta->nAudioSampleRate);
            NSLog(@"rtmp_meta->nVideoFrameRateDen =%d", rtmp_meta->nVideoFrameRateDen);
            NSLog(@"rtmp_meta->nVideoFrameRateNum =%d", rtmp_meta->nVideoFrameRateNum);
            NSLog(@"rtmp_meta->nVideoHeight =%d", rtmp_meta->nVideoHeight);
            NSLog(@"rtmp_meta->nVideoWidth =%d", rtmp_meta->nVideoWidth);
            [[JVCRTMPPlayerHelper shareRtmpPlayerHelper] RtmpResourceInit:rtmp_meta->nVideoHeight videoHeight:rtmp_meta->nVideoWidth dVideoframeFrate:rtmp_meta->nVideoFrameRateNum / rtmp_meta->nVideoFrameRateDen];
        }
            break;
        case RTMP_TYPE_H264_I:                      //I帧
        case RTMP_TYPE_H264_BP:                     //BP帧
            //放到缓存队列里面
            [[JVCRTMPPlayerHelper shareRtmpPlayerHelper] pushVideoData:pBuffer nVideoDataSize:nSize isVideoDataIFrame:uchType==RTMP_TYPE_H264_I?YES:NO isVideoDataBFrame:uchType==RTMP_TYPE_H264_BP?YES:NO frameType:uchType];
            break;
        case RTMP_TYPE_ALAW:                        //音频
            
            break;
        case RTMP_TYPE_ULAW:                        //音频
            
            break;
        default:
            break;
    }
    
}

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame       解码返回的数据
 *  @param nPlayBackFrametotalNumber  远程回放的总帧数
 *  @param isVideoType                YES：05 NO：04
 */
-(void)rtmpDecoderOutVideoFrameCallBack:(DecoderOutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber {
    
    dispatch_sync(dispatch_get_main_queue(), ^{

        UIView *glShowView       = (UIView *)self.glView._kxOpenGLView;
        
        int     showViewHeight   = self.showView.frame.size.height;
        int     showViewWidth    = self.showView.frame.size.width;
        int     glShowViewHeight = glShowView.frame.size.height;
        int     glShowViewWidth  = glShowView.frame.size.width;
        
        if (showViewHeight != glShowViewHeight || showViewWidth  != glShowViewWidth) {
            
            [glView updateDecoderFrame:self.showView.bounds.size.width displayFrameHeight:self.showView.bounds.size.height];
        }

        [glView decoder:decoderOutVideoFrame->decoder_y imageBufferU:decoderOutVideoFrame->decoder_u imageBufferV:(char*)decoderOutVideoFrame->decoder_v decoderFrameWidth:decoderOutVideoFrame->nWidth decoderFrameHeight:decoderOutVideoFrame->nHeight];
//            //            NSLog(@"==end====");
//            
//            currentChannelObj.isDisplayVideo = YES;
        
    });

}
@end
