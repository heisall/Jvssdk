//
//  GlView.h
//  GlView
//
//  Created by jovision on 13-12-14.
//  Copyright (c) 2013年 jovision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlView : NSObject{

    id _kxOpenGLView;
}

@property(nonatomic,retain) id _kxOpenGLView;


-(id)init:(int)decoderWidth withdecoderHeight:(int)decoderHeight withDisplayWidth:(int)width withDisplayHeight:(int)height;

/**
 *	解码一针之后 YUV显示的方法
 *
 *	@param	imageBufferY	     解码一针之后Y数据
 *	@param	imageBufferU	     解码一针之后U数据
 *	@param	imageBufferV	     解码一针之后V数据
 *	@param	decoderFrameWidth	 解码一针之后的宽
 *	@param	decoderFrameHeight	 解码一针之后的宽
 */
-(void)decoder:(char*)imageBufferY imageBufferU:(char*)imageBufferU imageBufferV:(char*)imageBufferV decoderFrameWidth:(int)decoderFrameWidth decoderFrameHeight:(int)decoderFrameHeight;

/**
 *	屏幕旋转之后更新画布
 *
 *	@param	displayFrameWidth	更新画布的高
 *	@param	displayFrameHeight	更新画布的宽
 */
-(void)updateDecoderFrame:(int)displayFrameWidth displayFrameHeight:(int)displayFrameHeight;


/**
 *  隐藏OpenGL画布
 */
-(void)hiddenWithOpenGLView;

/**
 *  显示OpenGL画布
 */
-(void)showWithOpenGLView;

/**
 *  清除画布
 *
 */
- (void)clearVideo;
@end
