//
//  JVCRTMPPlayerHelper.m
//  CloudSEE_II
//
//  Created by lay on 15/4/20.
//  Copyright (c) 2015年 lay. All rights reserved.
//

#import "JVCRTMPPlayerHelper.h"
#import "JVCDecoderMacro.h"

static JVCRTMPPlayerHelper *helper = nil;

@implementation JVCRTMPPlayerHelper{
    
    DecoderOutVideoFrame  *jvcOutVideoFrame;
}

@synthesize decodeModelObj;
@synthesize jvcQueueHelper;
@synthesize delegate;
@synthesize jvcAudioQueueHelper;
@synthesize videoHeight,videoWidth,frameRate;


char          pcmBuffer[1024] ={0};
int           nLocalChannel   = 1;


/**
 *  单例
 *
 *  @return 对象
 */
+(JVCRTMPPlayerHelper *)shareRtmpPlayerHelper
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

//初始播放化资源，包括解码器，队列等
- (void)RtmpResourceInit:(int)videoWidth
             videoHeight:(int)videoHeight
        dVideoframeFrate:(double)dVideoframeFrate{
    
    self.videoWidth                          =  videoWidth;
    self.videoHeight                         =  videoHeight;
    self.frameRate                           =  dVideoframeFrate;
    
    //初始化解码器
    JVCVideoDecoderHelper    * decodemodel   =  [[JVCVideoDecoderHelper alloc] init];
    decodemodel.nVideoWidth                  =  videoWidth;
    decodemodel.nVideoHeight                 =  videoHeight;
    decodemodel.dVideoframeFrate             =  dVideoframeFrate;
    decodemodel.isDecoderModel               =  TRUE;                       //05版解码器
    self.decodeModelObj                      =  decodemodel;
    decodeModelObj.delegate                  =  self;
    [decodemodel release];
    
    //初始化解码输出帧
    jvcOutVideoFrame = malloc(sizeof(DecoderOutVideoFrame));
    
    memset(jvcOutVideoFrame->decoder_y, 0, sizeof(jvcOutVideoFrame->decoder_y));
    memset(jvcOutVideoFrame->decoder_u, 0, sizeof(jvcOutVideoFrame->decoder_u));
    memset(jvcOutVideoFrame->decoder_v, 0, sizeof(jvcOutVideoFrame->decoder_v));
    
    [self openVideoDecoder];
    [self resetRtmpVideoDecoderParam];
    [self startPopVideoDataThread];
}

//释放播放资源
- (void)RtmpResourceRelease{
    
    [self exitQueue];
    
    [decodeModelObj release];
    [jvcQueueHelper release];
    [jvcAudioQueueHelper release];
    free(jvcOutVideoFrame);
    
}



/**
 *  退出缓存队列
 */
-(void)exitQueue{
    
    self.jvcQueueHelper.jvcQueueHelperDelegate = nil;
    [self.jvcQueueHelper exitPopDataThread];
}

/**
 *  启动缓存队列出队线程
 */
-(void)startPopVideoDataThread{
    
    if (!self.jvcQueueHelper) {
        
        JVCQueueHelper      *jvcQueueHelperObj     = [[JVCQueueHelper alloc] init:nLocalChannel];
        jvcQueueHelperObj.jvcQueueHelperDelegate   = self;
        self.jvcQueueHelper                        = jvcQueueHelperObj;
        [jvcQueueHelperObj release];
    }
    
    //设置帧率
    [self.jvcQueueHelper setDefaultFrameRate:self.frameRate withEnableJumpFrame:NO];
    
    [self performSelectorOnMainThread:@selector(popVideoDataThread) withObject:nil waitUntilDone:NO];
    
}

/**
 *  还原解码器参数
 */
-(void)resetVideoDecoderParam{
    
    [self.jvcQueueHelper clearEnqueueData];
    
    self.decodeModelObj.isWaitIFrame = FALSE;
}

-(void)popVideoDataThread{
    
    [self.jvcQueueHelper startPopDataThread];
}

/**
 *  缓存队列的入队函数 （视频）
 *
 *  @param videoData         视频帧数据
 *  @param nVideoDataSize    数据数据大小
 *  @param isVideoDataIFrame 视频是否是关键帧
 *  @param isVideoDataBFrame 视频是否是B帧
 *  @param frameType         视频数据类型
 */
-(void)pushVideoData:(unsigned char *)videoData nVideoDataSize:(int)nVideoDataSize isVideoDataIFrame:(BOOL)isVideoDataIFrame isVideoDataBFrame:(BOOL)isVideoDataBFrame frameType:(int)frameType{
    
    [self.jvcQueueHelper offer:videoData withFrameSize:nVideoDataSize withIsIFrame:isVideoDataIFrame withIsBFrame:isVideoDataBFrame withFrameType:frameType];
    
}

/**
 *  缓存队列的出队回调（协议）
 *
 *  @param bufferData 缓存队列的出队参数
 */
-(int)popDataCallBack:(void *)bufferData {
    
    
    frame *decodervideoFrame = (frame *)bufferData;
    
    int nDecoderStatus = [self decodeOneVideoFrame:decodervideoFrame VideoOutFrame:jvcOutVideoFrame];
    
    if ( nDecoderStatus >= -1) {
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(rtmpDecoderOutVideoFrameCallBack:nPlayBackFrametotalNumber:)]) {
            
            jvcOutVideoFrame->nLocalChannelID = nLocalChannel;
            
            [self.delegate rtmpDecoderOutVideoFrameCallBack:jvcOutVideoFrame nPlayBackFrametotalNumber:-1];
        }
    }
    
    return nDecoderStatus;
}


#pragma mark 解码处理模块

/**
 *  打开解码器
 */
-(void)openVideoDecoder{
    
    int nDecoderID  = nLocalChannel -1 ;
    
    [self.decodeModelObj openVideoDecoder:nDecoderID wVideoCodecID:IPC_VIDEO_DECODER_H264];
}

/**
 *  关闭解码器
 *
 *  @param nVideoDecodeID 解码器编号
 */
-(void)closeVideoDecoder{
    
    [self.jvcQueueHelper clearEnqueueData];
    
    [self.decodeModelObj closeVideoDecoder];
}

/**
 *  还原解码器参数
 */
-(void)resetRtmpVideoDecoderParam{
    
    [self.jvcQueueHelper clearEnqueueData];
    
    self.decodeModelObj.isWaitIFrame = FALSE;
}

/**
 *  解码一帧
 *
 *  @param nLocalChannel   连接的本地通道编号
 *  @param videoFrame      视频帧数据
 *  @param nSystemVersion  当前手机系统的版本
 *  @param VideoOutFrame   解码返回的结构
 *
 *  @return 解码成功返回 0 否则失败
 */
-(int)decodeOneVideoFrame:(frame *)videoFrame VideoOutFrame:(DecoderOutVideoFrame *)VideoOutFrame{
    
    int nDecoderStatus  = -1 ;
    
    nDecoderStatus = [self.decodeModelObj decodeOneVideoFrame:videoFrame nSystemVersion:1 VideoOutFrame:jvcOutVideoFrame];
    
    return nDecoderStatus;
}

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame       解码返回的数据
 *  @param nPlayBackFrametotalNumber  远程回放的总帧数
 *  @param isVideoType                YES：05 NO：04
 */
-(void)rtmpDecoderOutVideoFrameCallBack:(DecoderOutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber{
    NSLog(@"1221212");
}


#pragma mark 音频监听处理模块

///**
// *  设置音频类型
// *
// *  @param nAudioType 音频的类型
// */
//-(void)setAudioType:(int)nAudioType{
//    
//    self.jvcPlaySound.nAudioType            = nAudioType;
//}
//
///**
// *   打开音频解码器
// */
//-(void)openAudioDecoder{
//    
//    [self.jvcPlaySound openAudioDecoder:self.nConnectDeviceType isExistStartCode:self.decodeModelObj.isExistStartCode];
//    self.isAudioListening = self.jvcPlaySound.isOpenDecoder;
//    
//    if (!self.jvcAudioQueueHelper) {
//        
//        JVCAudioQueueHelper *jvcAudioQueueObj         = [[JVCAudioQueueHelper alloc] init:self.nLocalChannel];
//        self.jvcAudioQueueHelper                      = jvcAudioQueueObj;
//        [jvcAudioQueueObj release];
//    }
//    self.jvcAudioQueueHelper.jvcAudioQueueHelperDelegate  = self;
//    [self performSelectorOnMainThread:@selector(popAudioDataThread) withObject:nil waitUntilDone:NO];
//}
//
//-(void)popAudioDataThread{
//    
//    [self.jvcAudioQueueHelper startAudioPopDataThread];
//}
//
///**
// *  关闭音频解码
// */
//-(void)closeAudioDecoder{
//    
//    self.jvcAudioQueueHelper.jvcAudioQueueHelperDelegate = nil;
//    [self.jvcAudioQueueHelper exitPopDataThread];
//    
//    [self.jvcPlaySound closeAudioDecoder];
//    self.isAudioListening = self.jvcPlaySound.isOpenDecoder;
//}
//
//#pragma mark 音频缓存队列处理模块
//
///**
// *  缓存队列的入队函数(音频)
// *
// *  @param videoData         视频帧数据
// *  @param nVideoDataSize    数据数据大小
// *  @param isVideoDataIFrame 视频是否是关键帧
// */
//-(void)pushAudioData:(unsigned char *)audioData nAudioDataSize:(int)nAudioDataSize {
//    
//    [self.jvcAudioQueueHelper jvcAudioOffer:audioData nSize:nAudioDataSize];
//}
//
///**
// *  缓存队列的出队入口数据
// *
// *  @param bufferData 队列出队的Buffer
// *
// */
//-(void)popAudioDataCallBack:(void *)bufferData{
//    
//    frame *decoderAudioFrame = (frame *)bufferData;
//    
//    BOOL isConvertStatus =  FALSE;
//    
//    if (!self.isVoiceIntercom) {
//        
//        isConvertStatus= [self.jvcPlaySound convertSoundBufferByNetworkBuffer:self.nConnectDeviceType isExistStartCode:self.decodeModelObj.isExistStartCode networkBuffer:(char *)decoderAudioFrame->buf nBufferSize:decoderAudioFrame->nSize];
//    }else {
//        
//        isConvertStatus= [self.jvcVoiceIntercomHelper convertSoundBufferByNetworkBuffer:self.nConnectDeviceType isExistStartCode:self.decodeModelObj.isExistStartCode networkBuffer:(char *)decoderAudioFrame->buf nBufferSize:decoderAudioFrame->nSize];
//    }
//    
//    if (isConvertStatus) {
//        
//        // DDLogVerbose(@"%s--------",__FUNCTION__);
//    }
//}
//
///**
// *  关闭音频解码
// */
//-(void)closeVoiceIntercomDecoder{
//    
//    self.jvcAudioQueueHelper.jvcAudioQueueHelperDelegate = nil;
//    [self.jvcAudioQueueHelper exitPopDataThread];
//    
//    [self.jvcVoiceIntercomHelper closeAudioDecoder];
//    self.isVoiceIntercom = self.jvcVoiceIntercomHelper.isOpenDecoder;
//}







@end
