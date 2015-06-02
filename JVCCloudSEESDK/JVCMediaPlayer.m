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

static JVCMediaPlayer *player = nil;

@implementation JVCMediaPlayer{
    
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

/**
 *  播放器资源初始化
 *
 *  @param playerView 供显示的UIView
 */
- (void)MediaPlayerInit:(UIView *)playerView{
    
    self.showView = playerView;
    glView = [[GlView alloc] init:self.showView.bounds.size.width withdecoderHeight:self.showView.bounds.size.height withDisplayWidth:self.showView.bounds.size.width withDisplayHeight:self.showView.bounds.size.height];
    
    [glView showWithOpenGLView];
    [self.showView addSubview:glView._kxOpenGLView];
    [glView updateDecoderFrame:self.showView.bounds.size.width  displayFrameHeight:self.showView.bounds.size.height];
}

- (void)MediaPlayerRelease{
    
    if(glView){
        
        [glView clearVideo];
        glView = nil;
        self.showView = nil;
        
        [JVCMediaPlayerHelper shareMediaPlayerHelper].delegate =nil;
        [[JVCMediaPlayerHelper shareMediaPlayerHelper] MP4PlayerResourceRelease];
    }
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
    MP4_UPK_HANDLE		upkHandle		= NULL;
    
    MP4_INFO			mp4Info			= {0};
    
    const char *file = [fileName cStringUsingEncoding:NSASCIIStringEncoding];
    
    upkHandle = JP_OpenUnpkg((char *)file, &mp4Info, 0);
    
    NSLog(@"file ==== %s", file);
    
    //初始化播放帮助类
    [[JVCMediaPlayerHelper shareMediaPlayerHelper] MP4PlayerResourceInit:mp4Info.iFrameWidth videoHeight:mp4Info.iFrameHeight dVideoframeFrate:mp4Info.dFrameRate];
    
    AV_UNPKT			AvUnpkt			= {0};

    AvUnpkt.iType = JVS_UPKT_VIDEO;
    
    int sampleID;

    for(sampleID=1; sampleID<=mp4Info.iNumVideoSamples; sampleID++){
        AvUnpkt.iSampleId	= sampleID;
        //解封装的帧数据放在AvUnpkt里面
        int ret = JP_UnpkgOneFrame(upkHandle, &AvUnpkt);
        
        NSLog(@"sampleID === %d, itype == %d, nsize == %d", sampleID, AvUnpkt.iType, AvUnpkt.iSize);
        sleep(1/25);
        //放到缓存队列里面
        if(AvUnpkt.iType == JVS_UPKT_VIDEO){
            if(AvUnpkt.bKeyFrame){
                [[JVCMediaPlayerHelper shareMediaPlayerHelper] pushVideoData:AvUnpkt.pData nVideoDataSize:AvUnpkt.iSize isVideoDataIFrame:YES isVideoDataBFrame:NO frameType:0x01];
            }else{
                [[JVCMediaPlayerHelper shareMediaPlayerHelper] pushVideoData:AvUnpkt.pData nVideoDataSize:AvUnpkt.iSize isVideoDataIFrame:NO isVideoDataBFrame:YES frameType:0x02];
            }
 
        }
    }
}

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame       解码返回的数据
 *  @param nPlayBackFrametotalNumber  远程回放的总帧数
 *  @param isVideoType                YES：05 NO：04
 */
-(void)MP4DecoderOutVideoFrameCallBack:(DecoderOutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber {
    
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

