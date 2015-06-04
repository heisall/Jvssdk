//
//  JVCMediaAudioDecoder.h
//  JVCCloudSEESDK
//
//  Created by Yale on 15/6/3.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCMediaAudioDecoder : NSObject{
    
    int    nAudioType;           //音频编码的类别
    BOOL   isOpenDecoder;        //解码器是否打开   YES:打开
}

@property (nonatomic,assign)int   nAudioType;
@property (nonatomic,assign)BOOL  isOpenDecoder;

/**
 *  上锁
 */
-(void)lock;

/**
 *  解锁
 */
-(void)unLock;


/**
 *   打开播放器的音频解码器
 */
-(void)openAudioDecoder:(int)AudioType;

/**
 *  关闭音频解码器
 *
 *  @return YES:成功关闭 NO:不存在
 */
-(BOOL)closeAudioDecoder;


/**
 *  音频解码
 *
 *  @param networkBuffer         音频数据
 *  @param nBufferSize           音频数据大小
 *
 *  @return YES 转换失败 NO:转换失败
 */
-(BOOL)convertSoundBufferByNetworkBuffer:(unsigned char *)audioBuffer nBufferSize:(int)nBufferSize;


@end
