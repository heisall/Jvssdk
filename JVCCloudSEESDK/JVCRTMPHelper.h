//
//  JVCRTMPHelper.h
//  CloudSEE_II
//
//  Created by Yale on 15/4/29.
//  Copyright (c) 2015年 Yale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCRTMPMacro.h"
#import "GlView.h"
#import "JVCRTMPPlayerHelper.h"

@interface JVCRTMPHelper : NSObject<JVCRTMPPlayerHelperDelegate>{
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
+(JVCRTMPHelper *)shareRtmpHelper;

- (void)ResourceInit:(UIView *)playerView;

- (void)ResourceRelease;
/**
 *  播放rtmp地址
 */
- (void)connRtmpUrl:(NSString *)rtmpUrl
         nChannelID:(int)nChannelID
         playerView:(UIView *)playerView;


@end
