//
//  JVCMP4PlayerInter.h
//  JVCCloudSEESDK
//
//  Created by Yale on 15/5/29.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCMP4PlayerInter : NSObject

// 在JP_UnpkgOneFrame 会比较avUnpkt.type
#define  JVS_UPKT_VIDEO		1			// 解封视频类型
#define  JVS_UPKT_AUDIO		2			// 解音视频类型

// 打开解封器返回mp4文件信息,由调用者维持此结构体
typedef struct _MP4_INFO
{
    char				szVideoMediaDataName[8];	// 视频编码名字 "avc1"/"hev1"/"hvc1"
    unsigned int		iFrameWidth;				// 视频宽度
    unsigned int		iFrameHeight;				// 视频高度
    unsigned int		iNumVideoSamples;			// VideoSample个数
    double				dFrameRate;					// 帧速
    
    char				szAudioMediaDataName[8];	// 音频编码名字 "samr" "alaw" "ulaw"
    unsigned int		iNumAudioSamples;			// AudioSample个数
    
    
}MP4_INFO, *PMP4_INFO;

// 解封过程中输入(视频或音频),由调用者维持此结构体
typedef struct _AV_UNPKT
{
    unsigned int		iType;			// 解封类型	(输入)
    unsigned int		iSampleId;		// 解封Sample ID (输入) (1 -- iNumVideoSamples)
    unsigned char *		pData;			// 解封输出数据指针 解封器只维持一次调用的数据
    unsigned int		iSize;			// 解封输出数据大小
    uint64_t			iSampleTime;	// 解封输出时间戳 (以毫秒为单位) 0 40 80...
    BOOL				bKeyFrame;		// 是否为关键帧(输出)
}AV_UNPKT, *PAV_UNPKT;

typedef struct _MP4_UPK *		MP4_UPK_HANDLE;	// 解封句柄 由open返回


/**********************************************************************************
 Function:		JP_OpenUnpkg
 Description:	打开解封器和JP_CloseUnpkg成对使用
 Param:
 char *			pszmp4file		// 要解封的文件名
 PMP4_INFO		pMp4Info		// 输出的AudioSample、AudioSample个数
 unsigned int 	iBufSize		// setvbuf参数
 // linux dvr中使用(若为0, 64kB)
 
 Return:			返回解封器句柄, NULL, 表示失败,否则表示成功
 **********************************************************************************/
MP4_UPK_HANDLE  JP_OpenUnpkg	(char *pszmp4file, PMP4_INFO pMp4Info, unsigned int iBufSize);


@end
