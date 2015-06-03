//
//  JVCAudioCodecInterface.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCAudioCodecInterface : NSObject

//extern "C"
//{
    void JAD_DecodeOneFrame(int localChannel, unsigned char *pszAMRBuf, unsigned char **ppszPCMBuf);
    void JAD_DecodeClose(int localChannel);
    
    //----板卡发0 05版DVR和IPC 发1

/**********************************************************************************
 Function:		JAD_DecodeOpen
 Description:	打开解码器和JAD_DecodeClose成对使用
 Param:
 int iACodec;	// 解码输入，音频类型 samr=0, alaw=1, ulaw=2
 
 Return:			返回解码器句柄,	NULL,表示失败,否则表示成功
 **********************************************************************************/
    void JAD_DecodeOpen(int localChannel,int iACodec);
    
    //-------g711编码
    int		JAD_EncodeOneFrame(int localChannel, unsigned char *pszAMRBuf, unsigned char *ppszPCMBuf,int nlen);
    
    //-------板卡的语音对讲
    void InitDecode();
    void InitEncode();
    BOOL EncodeAudioData(char *pin,int len,char *pout,int *lenr);
    
    BOOL DecodeAudioData(char *pin,int len,char *pout,int *lenr);
//};


@end
