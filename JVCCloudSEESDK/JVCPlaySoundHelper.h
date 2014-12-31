//
//  JVCPlaySoundHelper.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenALBufferViewcontroller.h"

@interface JVCPlaySoundHelper : NSObject {

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
 *   解码器打开
 *
 *  @param nConnectDeviceType 连接的设备类型
 *  @param isExistStartCode   是否包含新帧头
 *
 *  @return YES打开成功 NO：已存在
 */
-(BOOL)openAudioDecoder:(int)nConnectDeviceType isExistStartCode:(BOOL)isExistStartCode;

/**
 *  关闭音频解码器
 *
 *  @return YES:成功关闭 NO:不存在
 */
-(BOOL)closeAudioDecoder;

/**
 *  音频解码
 *
 *  @param nConnectDeviceType    连接的设备类型
 *  @param isExistStartCode      是否包含新帧头
 *  @param networkBuffer         音频数据
 *  @param nBufferSize           音频数据大小
 *
 *  @return YES 转换失败 NO:转换失败
 */
-(BOOL)convertSoundBufferByNetworkBuffer:(int)nConnectDeviceType isExistStartCode:(BOOL)isExistStartCode networkBuffer:(char *)networkBuffer nBufferSize:(int)nBufferSize;


@end
