//
//  JVCMediaPlayerHelper.h
//  JVCCloudSEESDK
//
//  Created by Yale on 15/5/29.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCQueueHelper.h"
#import "JVCVideoDecoderHelper.h"
#import "JVCAudioQueueHelper.h"
#import "JVCPlaySoundHelper.h"

@protocol JVCMP4PlayerHelperDelegate <NSObject>

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame       解码返回的数据
 *  @param nPlayBackFrametotalNumber  远程回放的总帧数
 *  @param isVideoType                YES：05 NO：04
 */
-(void)MP4DecoderOutVideoFrameCallBack:(DecoderOutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber ;


@end

@interface JVCMediaPlayerHelper : NSObject<JVCQueueHelperDelegate,JVCVideoDecoderHelperDelegate,
JVCAudioQueueHelperDelegate>{
    
    JVCVideoDecoderHelper                   * decodeModelObj;       //解码器属性类
    JVCQueueHelper                          * jvcQueueHelper;       //缓存队列对象
    id<JVCMP4PlayerHelperDelegate>          delegate;
    JVCAudioQueueHelper                     * jvcAudioQueueHelper;  //音频的缓存队列
    JVCPlaySoundHelper                      * jvcPlaySound;        //音频监听处理对象
    
    int                                     videoWidth;
    int                                     videoHeight;
    double                                  frameRate;
}

@property (nonatomic,retain) JVCVideoDecoderHelper              *decodeModelObj;
@property (nonatomic,retain) JVCQueueHelper                     *jvcQueueHelper;
@property (nonatomic,assign) id<JVCMP4PlayerHelperDelegate>    delegate;
@property (nonatomic,retain) JVCPlaySoundHelper                 * jvcPlaySound;
@property (nonatomic,retain) JVCAudioQueueHelper                *jvcAudioQueueHelper;    //音频的缓存队列
@property (nonatomic) int                                videoWidth;
@property (nonatomic) int                                videoHeight;
@property (nonatomic) double                             frameRate;


/**
 *  单例
 *
 *  @return 对象
 */
+(JVCMediaPlayerHelper *)shareMediaPlayerHelper;

//初始播放化资源，包括解码器，队列等
- (void)MP4PlayerResourceInit:(int)videoWidth
             videoHeight:(int)videoHeight
        dVideoframeFrate:(double)dVideoframeFrate;

//释放播放资源
- (void)MP4PlayerResourceRelease;





/**
 *  连接的工作线程
 */
-(void)connectWork;

/**
 *  退出缓存队列
 */
-(void)exitQueue;

/**
 *  断开远程连接
 */
-(void)disconnect;

#pragma mark ----------------  JVCQueueHelper 处理模块

/**
 *  启动缓存队列出队线程
 */
-(void)startPopVideoDataThread;

/**
 *  缓存队列的入队函数 （视频）
 *
 *  @param videoData         视频帧数据
 *  @param nVideoDataSize    数据数据大小
 *  @param isVideoDataIFrame 视频是否是关键帧
 *  @param isVideoDataBFrame 视频是否是B帧
 *  @param frameType         视频数据类型
 */
-(void)pushVideoData:(unsigned char *)videoData nVideoDataSize:(int)nVideoDataSize isVideoDataIFrame:(BOOL)isVideoDataIFrame isVideoDataBFrame:(BOOL)isVideoDataBFrame frameType:(int)frameType;



#pragma mark  解码处理模块

/**
 *  打开解码器
 */
-(void)openVideoDecoder;

/**
 *  关闭解码器
 *
 *  @param nVideoDecodeID 解码器编号
 */
-(void)closeVideoDecoder;

/**
 *  还原解码器参数
 */
-(void)resetVideoDecoderParam;

/**
 *  抓拍图像
 */
-(void)startWithCaptureImage;

/**
 *  场景图像
 */
-(void)startWithSceneImage;

@end
