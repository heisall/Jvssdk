//
//  JVCMediaPlayer.m
//  JVCCloudSEESDK
//
//  Created by Yale on 15/5/29.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import "JVCMediaPlayer.h"
#import "JVCQueueHelper.h"
#import "JVCVideoDecoderHelper.h"
#import "JVCAudioQueueHelper.h"
#import "JVCPlaySoundHelper.h"
#import "Jmp4pkg.h"
#import "JVCMediaPlayerHelper.h"
#import "JVCMP4Player.h"
#import "JVCDecoderMacro.h"
#import "JVCVideoDecoderHelper.h"

@interface JVCMediaPlayer  () {
    
    VideoFrame *bufferFrame;
    BOOL        isPlaying; //是否正在播放
    MP4_UPK_HANDLE		upkHandle;
    
    NSString *curTimeBeforeReadVideoFrame;//读取MP4数据之前记录下时间
    
    NSString *curTimeAfterShowVideoFrame;//显示MP4后记录下时间

}
@end

static JVCMediaPlayer *player = nil;

@implementation JVCMediaPlayer
@synthesize showView;
@synthesize glView;

/**
 *  单例
 *
 *  @return 对象
 */
+(JVCMediaPlayer *)shareMediaPlayer
{
    @synchronized(self)
    {
        if (player == nil) {
            
            player = [[self alloc] init];
            
        }
        
        return player;
    }
    
    return player;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (player == nil) {
            
            player = [super allocWithZone:zone];
            
            return player;
        }
    }
    
    return nil;
}

- (void)dealloc{
    
    [super dealloc];
    
}
/**
 *  播放器资源初始化
 *
 *  @param playerView 供显示的UIView
 */
- (void)MediaPlayerInit:(UIView *)playerView{
    
    curTimeAfterShowVideoFrame = nil;
    curTimeBeforeReadVideoFrame = nil;
    
    isPlaying = TRUE;
    
    self.showView = playerView;
    glView = [[GlView alloc] init:self.showView.bounds.size.width withdecoderHeight:self.showView.bounds.size.height withDisplayWidth:self.showView.bounds.size.width withDisplayHeight:self.showView.bounds.size.height];
    
    [glView showWithOpenGLView];
    [self.showView addSubview:glView._kxOpenGLView];
    [glView updateDecoderFrame:self.showView.bounds.size.width  displayFrameHeight:self.showView.bounds.size.height];
}

- (void)MediaPlayerRelease{
    
    isPlaying = false;
    if(glView){
        
        [glView clearVideo];
        glView = nil;
        self.showView = nil;
    }
    [[JVCMediaPlayerHelper shareMediaPlayerHelper] MediaPlayerResourceRelease];
    JP_CloseUnpkg(upkHandle);
}

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
 *  播放MP4文件
 *
 *  @param fileName 文件路径
 */
- (void)openMP4File:(NSString *)fileName
{
    upkHandle		= NULL;
    
    MP4_INFO			mp4Info			= {0};
    
    int vDecId, aDecId;
    
    const char *file = [fileName cStringUsingEncoding:NSASCIIStringEncoding];
    
    upkHandle = JP_OpenUnpkg((char *)file, &mp4Info, 0);
    
    NSLog(@"file ==== %s", file);
    
    NSLog(@"video type === %s, audio type === %s", mp4Info.szVideoMediaDataName, mp4Info.szAudioMediaDataName);
    
    if(strcmp(mp4Info.szVideoMediaDataName, "avc1") == 0){
        vDecId = VIDEO_DECODER_H264;
    }else if(strcmp(mp4Info.szVideoMediaDataName, "hev1") == 0){
        vDecId = VIDEO_DECODER_H265;
    }
    
    if(strcmp(mp4Info.szAudioMediaDataName, "samr") == 0){
        aDecId = AUDIO_DECODER_SAMR;
    }else if(strcmp(mp4Info.szAudioMediaDataName, "alaw")==0){
        aDecId = AUDIO_DECODER_ALAW;
    }else if(strcmp(mp4Info.szAudioMediaDataName, "ulaw")==0){
        aDecId = AUDIO_DECODER_ULAW;
    }
    
    //初始化播放帮助类
    [[JVCMediaPlayerHelper shareMediaPlayerHelper] MediaPlayerResourceInit:mp4Info.iFrameWidth videoHeight:mp4Info.iFrameHeight dVideoframeFrate:mp4Info.dFrameRate videoType:vDecId  audioType:aDecId];
    
    AV_UNPKT			VideoUnpkt			= {0};
    AV_UNPKT            AudioUnpkt          = {0};
    int sampleID;

    for(sampleID=1; sampleID<=mp4Info.iNumVideoSamples; sampleID++){
        
        if(!isPlaying)
            return;
        
        curTimeBeforeReadVideoFrame = [self getTimeNow];
        AudioUnpkt.iType = JVS_UPKT_AUDIO;
        AudioUnpkt.iSampleId	= sampleID;
        JP_UnpkgOneFrame(upkHandle, &AudioUnpkt);
        [self decodeAudioFrameAndPlay:AudioUnpkt];
        
        VideoUnpkt.iType = JVS_UPKT_VIDEO;
        VideoUnpkt.iSampleId	= sampleID;
        //解封装的帧数据放在AvUnpkt里面
        JP_UnpkgOneFrame(upkHandle, &VideoUnpkt);
        [self decodeVideoFrameAndPlay:VideoUnpkt];
        
        if(curTimeAfterShowVideoFrame != nil && curTimeBeforeReadVideoFrame != nil){
            NSLog(@"=======%.f", ([curTimeAfterShowVideoFrame doubleValue]-[curTimeBeforeReadVideoFrame doubleValue])*1000);
            msleep(40 - 3 - ([curTimeAfterShowVideoFrame doubleValue]-[curTimeBeforeReadVideoFrame doubleValue])*1000);
        }else
            msleep(40);
    }
}

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame       解码返回的数据
 *  @param nPlayBackFrametotalNumber  远程回放的总帧数
 *  @param isVideoType                YES：05 NO：04
 */
-(void)DecoderOutVideoFrameCallBack:(OutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber {
    
    if(isPlaying)
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
        });
    
}


- (void)decodeVideoFrameAndPlay:(AV_UNPKT )AvUnpkt{
    
    
    bufferFrame  = (VideoFrame *)malloc(AvUnpkt.iSize);
    memset(bufferFrame, 0, AvUnpkt.iSize);
    
    if (AvUnpkt.iSize > 0) {
        
        bufferFrame->nSize      = AvUnpkt.iSize;
        bufferFrame->is_i_frame = AvUnpkt.bKeyFrame?YES:NO;
        bufferFrame->is_b_frame = AvUnpkt.bKeyFrame?NO:YES;
        bufferFrame->nFrameType = AvUnpkt.bKeyFrame?0x01:0x02;
        
        bufferFrame->buf = (unsigned char *)malloc(sizeof(unsigned char)*AvUnpkt.iSize);
        
        memcpy(bufferFrame->buf, AvUnpkt.pData, AvUnpkt.iSize);
        
    }else{
        
        bufferFrame->nSize      = 0;
        bufferFrame->is_i_frame = FALSE;
        bufferFrame->buf = NULL;
        bufferFrame->is_b_frame = FALSE;
    }
    
    
    int status = [[JVCMediaPlayerHelper shareMediaPlayerHelper] MediaPlayerDecoderOneVideoFrame:bufferFrame];
    
    curTimeAfterShowVideoFrame =[self getTimeNow];
    
    if(status>-1)
        free(bufferFrame);
    
}

- (void)decodeAudioFrameAndPlay:(AV_UNPKT )AvUnpkt{
    
    [[JVCMediaPlayerHelper shareMediaPlayerHelper] MediaPlayerDecoderOneAudioFrame:(AvUnpkt.pData) nBufferSize:AvUnpkt.iSize];
    
}


- (NSString *)getTimeNow
{
    NSString *date = [NSString stringWithFormat:@"%f", (double)[[NSDate date] timeIntervalSince1970]];
    return  date;
}
@end

