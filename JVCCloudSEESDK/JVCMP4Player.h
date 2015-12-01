//
//  JVCMP4Player.h
//  JVCCloudSEESDK
//
//  Created by Yale on 15/6/2.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#ifndef JVCCloudSEESDK_JVCMP4Player_h
#define JVCCloudSEESDK_JVCMP4Player_h

#import "JVCDecoderMacro.h"

//#define VIDEO_TYPE_COUNT 2
//struct // decided by mp4-upk
//{
//    char upk[8];	// mp4-upk
//    int	 enc;		// dec
//}vDecMediaType[VIDEO_TYPE_COUNT] =
//{
//    {"avc1", VIDEO_DECODER_H264},
//    {"hev1", VIDEO_DECODER_H265}
//};
//
//#define AUDIO_TYPE_COUNT 3
//
//struct // decided by mp4-upk
//{
//    char upk[8];	// mp4-upk
//    int	 enc;		// dec
//}aDecMediaType[AUDIO_TYPE_COUNT] =
//{
//    {"samr", JVS_ACODEC_SAMR},
//    {"alaw", JVS_ACODEC_ALAW},
//    {"ulaw", JVS_ACODEC_ULAW}
//};


typedef struct VideoFrame{
    
    unsigned char * buf;
    int             nSize;
    bool            is_i_frame; //是否是I帧
    bool            is_b_frame; //是否是B帧
    int             nFrameType;
    
}VideoFrame;


//解码一帧视频帧的输出结构体
typedef struct OutVideoFrame{
    unsigned char *decoder_y;       //解码出来的YUV数据 y
    unsigned char *decoder_u;       //解码出来的YUV数据 u
    unsigned char *decoder_v;
    int  nLocalChannelID;           //连接的本地通道号
    int  nWidth;                    //解码出来的宽
    int  nHeight;                   //解码出来的高
    
}OutVideoFrame;



#endif
