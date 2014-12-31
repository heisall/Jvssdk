//
//  JVCRecordVideoHelper.h
//  CloudSEE
//
//  Created by chenzhenyang on 14-9-19.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCRecordVideoHelper : NSObject {

    BOOL      isRecordVideo;
    BOOL      isRecordVideoWaitingFrameI;
}

@property (nonatomic,assign) BOOL isRecordVideo;
@property (nonatomic,assign) BOOL isRecordVideoWaitingFrameI;

/**
 *  打开录像的编码器
 *
 *  @param strRecordVideoPath 录像的地址
 *  @param nRecordChannelID   录像的通道号
 *  @param nWidth             录像视频的宽
 *  @param nHeight            录像视频的高
 *  @param dRate              录像的帧率
 */
-(void)openRecordVideo:(NSString *)strRecordVideoPath nRecordChannelID:(int)nRecordChannelID nWidth:(int)nWidth nHeight:(int)nHeight dRate:(double)dRate;

/**
 *  录像一帧的方法
 *
 *  @param videoData     录像的视频数据
 *  @param isVideoDataI  是否是I帧
 *  @param isVideoDataB  是否是B帧
 *  @param videoDataSize 视频数据的大小
 */
-(void)saveRecordVideoDataToLocal:(char *)videoData isVideoDataI:(BOOL)isVideoDataI isVideoDataB:(BOOL)isVideoDataB videoDataSize:(int)videoDataSize;

/**
 *  停止录像
 */
-(void)stopRecordVideo;

@end
