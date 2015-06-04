//
//  JVCMediaPlayerHelper.h
//  JVCCloudSEESDK
//
//  Created by Yale on 15/5/29.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCMediaVideoDecoder.h"
#import "JVCMediaAudioDecoder.h"

@protocol MediaPlayerVideoDelegate <NSObject>

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame       解码返回的数据
 *  @param nPlayBackFrametotalNumber  远程回放的总帧数
 *  @param isVideoType                YES：05 NO：04
 */
-(void)DecoderOutVideoFrameCallBack:(OutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber ;


@end

@interface JVCMediaPlayerHelper : NSObject{
    JVCMediaVideoDecoder                    *videoDecoder;
    JVCMediaAudioDecoder                    *audioDecoder;
    id<MediaPlayerVideoDelegate>            delegate;
}

@property (nonatomic,retain) JVCMediaVideoDecoder              *videoDecoder;
@property (nonatomic,retain) JVCMediaAudioDecoder              *audioDecoder;
@property (nonatomic,assign) id<MediaPlayerVideoDelegate>    delegate;

/**
 *  单例
 *
 *  @return 对象
 */
+(JVCMediaPlayerHelper *)shareMediaPlayerHelper;


/**
 *  //初始播放化资源，包括解码器
 *
 *  @param videoWidth       <#videoWidth description#>
 *  @param videoHeight      <#videoHeight description#>
 *  @param dVideoframeFrate <#dVideoframeFrate description#>
 *  @param videoType        <#videoType description#>
 *  @param audioType        <#audioType description#>
 */
- (void)MediaPlayerResourceInit:(int)videoWidth
             videoHeight:(int)videoHeight
        dVideoframeFrate:(double)dVideoframeFrate
                    videoType:(int)videoType
                    audioType:(int)audioType;


/**
 *  释放播放资源
 */
- (void)MediaPlayerResourceRelease;


/**
 *  解码一帧视频
 *
 *  @param videoFrame    <#videoFrame description#>
 *  @param VideoOutFrame <#VideoOutFrame description#>
 *
 *  @return <#return value description#>
 */
- (int)MediaPlayerDecoderOneVideoFrame:(VideoFrame *)videoFrame  ;


/**
 *  解码一帧音频
 *
 *  @param audioBuffer <#audioBuffer description#>
 *  @param nBufferSize <#nBufferSize description#>
 */
- (void)MediaPlayerDecoderOneAudioFrame:(unsigned char *)audioBuffer nBufferSize:(int)nBufferSize;



@end
