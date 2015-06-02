//
//  JVCMediaPlayerHelper.m
//  JVCCloudSEESDK
//
//  Created by Yale on 15/5/29.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import "JVCMediaPlayerHelper.h"
#import "JVCDecoderMacro.h"
#import "JVCMediaPlayer.h"

static JVCMediaPlayerHelper *helper = nil;

@implementation JVCMediaPlayerHelper{
    
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
+(JVCMediaPlayerHelper *)shareMediaPlayerHelper
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
- (void)MP4PlayerResourceInit:(int)videoWidth
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
    
    self.delegate                            = [JVCMediaPlayer shareMediaPlayer];
    
    //初始化解码输出帧
//    jvcOutVideoFrame = malloc(sizeof(DecoderOutVideoFrame));
//    
//    memset(jvcOutVideoFrame->decoder_y, 0, sizeof(jvcOutVideoFrame->decoder_y));
//    memset(jvcOutVideoFrame->decoder_u, 0, sizeof(jvcOutVideoFrame->decoder_u));
//    memset(jvcOutVideoFrame->decoder_v, 0, sizeof(jvcOutVideoFrame->decoder_v));
    
    [self openVideoDecoder];
    [self resetMediaPlayerVideoDecoderParam];
    [self startPopVideoDataThread];
}

//释放播放资源
- (void)MP4PlayerResourceRelease{
    
    [self exitQueue];
    
    [decodeModelObj release];
    [jvcQueueHelper release];
    [jvcAudioQueueHelper release];
//    free(jvcOutVideoFrame);
    
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
    
    //[self performSelectorOnMainThread:@selector(popVideoDataThread1) withObject:nil waitUntilDone:NO];
    [self popVideoDataThread1];
    
}

/**
 *  还原解码器参数
 */
-(void)resetVideoDecoderParam{
    
    [self.jvcQueueHelper clearEnqueueData];
    
    self.decodeModelObj.isWaitIFrame = FALSE;
}

-(void)popVideoDataThread1{
    
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
    
    if ( nDecoderStatus >= 0) {
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(MP4DecoderOutVideoFrameCallBack:nPlayBackFrametotalNumber:)]) {
            
            jvcOutVideoFrame->nLocalChannelID = nLocalChannel;
            
            [self.delegate MP4DecoderOutVideoFrameCallBack:jvcOutVideoFrame nPlayBackFrametotalNumber:-1];
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
-(void)resetMediaPlayerVideoDecoderParam{
    
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
    
    nDecoderStatus = [self.decodeModelObj decodeOneVideoFrame:videoFrame nSystemVersion:1 VideoOutFrame:&jvcOutVideoFrame];
    
    return nDecoderStatus;
}

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame       解码返回的数据
 *  @param nPlayBackFrametotalNumber  远程回放的总帧数
 *  @param isVideoType                YES：05 NO：04
 */
-(void)DecoderOutVideoFrameCallBack:(DecoderOutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber{
    NSLog(@"1221212");
}


@end
