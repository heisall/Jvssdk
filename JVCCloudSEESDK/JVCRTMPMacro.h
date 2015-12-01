//
//  JVCRTMPMacro.h
//  CloudSEE_II
//
//  Created by Yale on 15/4/29.
//  Copyright (c) 2015年 Yale. All rights reserved.
//

#ifndef CloudSEE_II_JVCRTMPMacro_h
#define CloudSEE_II_JVCRTMPMacro_h


#define RTMP_TYPE_META		0x00
#define RTMP_TYPE_H264_I	0x01
#define RTMP_TYPE_H264_BP	0x02
#define RTMP_TYPE_ALAW		0x11
#define RTMP_TYPE_ULAW		0x12


#define RTMP_CONN_SCCUESS	(0x01)
#define RTMP_CONN_FAILED	(0x02)
#define RTMP_DISCONNECTED	(0x03)
#define RTMP_EDISCONNECT	(0x04)

typedef struct _JVRTMP_Metadata_t {
    int nVideoWidth;
    int nVideoHeight;
    int nVideoFrameRateNum;
    int nVideoFrameRateDen;
    int nAudioDataType;
    int nAudioSampleRate;
    int nAudioSampleBits;
    int nAudioChannels;
} JVRTMP_Metadata_t;

#endif
