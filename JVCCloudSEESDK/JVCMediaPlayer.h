//
//  JVCMediaPlayer.h
//  JVCCloudSEESDK
//
//  Created by Yale on 15/5/29.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GlView.h"
#import "JVCRTMPMacro.h"
#import "GlView.h"
#import "JVCMediaPlayerHelper.h"

@interface JVCMediaPlayer : NSObject<JVCMP4PlayerHelperDelegate>
{
    UIView     *showView;             // 显示的视频窗口
    GlView     *glView;
    BOOL       isConning;             //是否还在连接
}

@property (nonatomic,retain) UIView  *showView;     // 显示的视频窗口
@property (nonatomic,retain) GlView  *glView;
@property (nonatomic)        BOOL    isConning;


/**
 *  单例
 *
 *  @return 对象
 */
+(JVCMediaPlayer *)shareMediaPlayer;

/**
 *  播放器资源初始化
 *
 *  @param playerView 供显示的UIView
 */
- (void)MediaPlayerInit:(UIView *)playerView;

/**
 *  播放器资源释放
 */
- (void)MediaPlayerRelease;

/**
 *  播放MP4文件
 *
 *  @param fileName 文件路径
 */
- (void)openMP4File:(NSString *)fileName;


@end
