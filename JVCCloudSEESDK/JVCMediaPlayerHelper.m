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
#import "JVCCloudSEENetworkMacro.h"

#import "JVCMP4Player.h"

@interface JVCMediaPlayerHelper () {
    
    OutVideoFrame  *jvcOutVideoFrame;
}
@end

static JVCMediaPlayerHelper *helper = nil;

@implementation JVCMediaPlayerHelper

@synthesize videoDecoder, audioDecoder;
@synthesize delegate;

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

- (void)dealloc{
    
    [super dealloc];
}

//初始播放化资源，包括解码器，队列等
- (void)MediaPlayerResourceInit:(int)nVideoWidth
             videoHeight:(int)nVideoHeight
        dVideoframeFrate:(double)dVideoframeFrate
                    videoType:(int)nVideoType
                    audioType:(int)nAudioType{
    
    if(!self.delegate)
        self.delegate = [JVCMediaPlayer shareMediaPlayer];
    //初始化视频解码器
    videoDecoder = [[JVCMediaVideoDecoder alloc] init];
    [videoDecoder openVideoDecoder:0 wVideoCodecID:nVideoType];
    
    //初始化音频解码器
    audioDecoder = [[JVCMediaAudioDecoder alloc] init];
    [audioDecoder openAudioDecoder:nAudioType];
    
    
}

//释放播放资源
- (void)MediaPlayerResourceRelease{
    
    [videoDecoder closeVideoDecoder];
    [videoDecoder dealloc];
    
    [audioDecoder closeAudioDecoder];
    [audioDecoder dealloc];
}


/**
 *  解码一帧视频
 *
 *  @param videoFrame    <#videoFrame description#>
 *  @param VideoOutFrame <#VideoOutFrame description#>
 *
 *  @return return value description
 */
- (int)MediaPlayerDecoderOneVideoFrame:(VideoFrame *)videoFrame
{
    if(videoDecoder.isOpenDecoder){
        
        int nDecoderStatus =  [videoDecoder decodeOneVideoFrame:videoFrame nSystemVersion:1 VideoOutFrame:&jvcOutVideoFrame];
        
        if (nDecoderStatus >= 0) {
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(DecoderOutVideoFrameCallBack:nPlayBackFrametotalNumber:)]) {
                
                jvcOutVideoFrame->nLocalChannelID = nLocalChannel;
                
                [self.delegate DecoderOutVideoFrameCallBack:jvcOutVideoFrame nPlayBackFrametotalNumber:-1];
            }
        }
        
        return nDecoderStatus;
    }
    
    return -1;
}


/**
 *  解码一帧音频
 *
 *  @param audioBuffer <#audioBuffer description#>
 *  @param nBufferSize <#nBufferSize description#>
 */
- (void)MediaPlayerDecoderOneAudioFrame:( unsigned char *)audioBuffer nBufferSize:(int)nBufferSize
{
    if(audioDecoder.isOpenDecoder){
        [audioDecoder convertSoundBufferByNetworkBuffer:audioBuffer nBufferSize:nBufferSize];
    }
}


@end
