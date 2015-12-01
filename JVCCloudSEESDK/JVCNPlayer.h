//
//  JVCNPlayer.h
//  CloudSEE_II
//
//  Created by Yale on 15/6/11.
//  Copyright (c) 2015年 Yale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCNPlayer : NSObject

@property(nonatomic,assign)BOOL isAec ;   // 是否开启回声一致 需要在initplayer之前设置
@property(nonatomic,assign)BOOL isDenoise;//是否开启降噪 需要在initplayer之前设置

typedef void (*fetchcb)(const unsigned char* data, size_t size, uint64_t ts);


/* 
    初始化方法最先调用*/
+(void)initCore;

/*
    卸载方法最后调用*/

+(void)deinitCore;

/*
    初始化播放器，开启回声抑制和降噪功能 */
-(void)initPlayer;

/*
   初始化播放器(带有回声抑制和降噪功能)
   @param rate 音频采样率
   @param size 缓冲区大小    */
-(void)initPlayerSampleRate:(int)rate frameSize:(int)size;

/*
   关闭播放器 */
-(void)stopPlayer;

/*
   追加音频播放数据帧，暂不支持解码，仅 PCM 原始数据 audioData 音频数据 frameSize 数据大 */
-(void)appendAudioData:(const unsigned char*)audioData size:(int)frameSize;

/*
   开始录音
   回调callback 返回数据  */
-(void)startRecordAudio:(fetchcb)callback;

/*
   停止录音  */
-(void)stopRecordAudio;

/*
  暂停音频  */
-(void)pauseAudio;

/*
  继续音频  */
-(void)resumeAudio;

@end
