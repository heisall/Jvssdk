//
//  JVCVideoDecoderHelper.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCQueueHelper.h"

@protocol JVCVideoDecoderHelperDelegate <NSObject>

/**
 *  设备抓拍的图片
 *
 *  @param captureOutImageData 输出的二进制图片数据
 */
-(void)decoderModelCaptureImageCallBack:(NSData *)captureOutImageData;

@end;

@interface JVCVideoDecoderHelper : NSObject {
    
    int      nVideoWidth;	           //实时视频宽
	int      nVideoHeight;	           //实时视频高
    double   dVideoframeFrate;         //实时视频的帧速率
    BOOL     isDecoderModel;           //解码器的类别             YES:05版      NO:04版
    BOOL     isWaitIFrame;             //等待I帧标志              YES:等待      NO:继续解码
    BOOL     isExistStartCode;         //视频数据是否存在StartCode YES:存在      NO:不存在 存在时解码视频数据需要偏移视频数据＋8
    BOOL     isOpenDecoder;            //视频解码器是否打开        YES:打开      NO:没打开
    BOOL     isCaptureImage;           //是否抓拍                 YES:抓拍      NO:不抓拍
    BOOL     IsOpenDecoderSound;       //音频解码器是否打开         YES:打开      NO: 未打开
    int      nAudioCollectionType;     //语音对讲音频采集的类型
    BOOL     IsEnableSceneImages;      //是否启用场景图连接         YES启用       NO:关闭
    
    id       <JVCVideoDecoderHelperDelegate> delegate; // 抓拍的委托
}

//解码一帧视频帧的输出结构体
typedef struct DecoderOutVideoFrame{
    unsigned char *decoder_y;       //解码出来的YUV数据 y
    unsigned char *decoder_u;       //解码出来的YUV数据 u
    unsigned char *decoder_v;
    int  nLocalChannelID;           //连接的本地通道号
    int  nWidth;                    //解码出来的宽
    int  nHeight;                   //解码出来的高
    
}DecoderOutVideoFrame;


//解码一帧视频帧的输出结构体
typedef struct DecoderOutVideoFrame2{
    
    //
    char *decoder_y;      //解码出来的YUV数据 y
    char *decoder_u;        //解码出来的YUV数据 u
    char *decoder_v;
    
    int  nLocalChannelID;           //连接的本地通道号
    int  nWidth;                    //解码出来的宽
    int  nHeight;                   //解码出来的高
    
}DecoderOutVideoFrame2;


//解码一帧视频帧的输入结构体
typedef struct DecoderVideoFrame{
    
    unsigned char * buf;           //视频帧H264数据
    int             nSize;         //视频数据的大小
    bool            is_i_frame;    //是否是I帧
    
}DecoderVideoFrame;

@property (nonatomic,assign) int     nVideoWidth,nVideoHeight;
@property (nonatomic,assign) double  dVideoframeFrate;
@property (nonatomic,assign) BOOL    isDecoderModel;
@property (nonatomic,assign) BOOL    isWaitIFrame;
@property (nonatomic,assign) BOOL    isExistStartCode;
@property (nonatomic,assign) BOOL    isOpenDecoder;
@property (nonatomic,assign) BOOL    isCaptureImage;
@property (nonatomic,assign) BOOL    IsOpenDecoderSound;
@property (nonatomic,assign) int     nAudioCollectionType;
@property (nonatomic,assign) BOOL    IsEnableSceneImages;
@property (nonatomic,assign) id      <JVCVideoDecoderHelperDelegate> delegate; // 抓拍的委托



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
 *  打开解码器
 *
 *  @param nVideoDecodeID 解码器编号(0~15)
 */
-(void)openVideoDecoderForMP4:(int)nVideoDecodeID wVideoCodecID:(int)wVideoCodecID;

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
-(int)decodeOneVideoFrame:(frame *)videoFrame nSystemVersion:(int)nSystemVersion VideoOutFrame:(DecoderOutVideoFrame **)VideoOutFrame;

@end
