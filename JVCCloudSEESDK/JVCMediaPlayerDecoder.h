//
//  JVCMediaPlayerDecoder.h
//  JVCCloudSEESDK
//
//  Created by Yale on 15/6/3.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCMP4Player.h"

@interface JVCMediaPlayerDecoder : NSObject


/**
 *  视频解码上锁，防止解码时关闭解码器
 */
-(void)videoLock;

/**
 *  视频解完码解锁
 */
-(void)VideoUnlock;


#pragma mark 解码器相关的处理模块

/**
 *  打开解码器
 *
 *  @param nVideoDecodeID 解码器编号(0~15)
 */
-(void)openVideoDecoder:(int)nVideoDecodeID wVideoCodecID:(int)wVideoCodecID;


/**
 *  关闭解码器
 *
 */
-(void)closeVideoDecoder;

/**
 *  解码一帧
 *
 *  @param videoFrame      视频帧数据
 *  @param nSystemVersion  当前手机系统的版本
 *  @param VideoOutFrame   解码返回的结构
 *
 *  @return 解码成功返回 0 否则失败
 */
-(int)decodeOneVideoFrame:(videoFrame *)videoFrame nSystemVersion:(int)nSystemVersion VideoOutFrame:(OutVideoFrame **)VideoOutFrame;

@end
