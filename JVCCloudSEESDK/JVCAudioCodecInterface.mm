//
//  JVCAudioCodecInterface.m
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCAudioCodecInterface.h"

extern "C"
{
    void JAD_DecodeOneFrame(int localChannel, unsigned char *pszAMRBuf, unsigned char **ppszPCMBuf);
    void JAD_DecodeClose(int localChannel);
    
    //----板卡发0 05版DVR和IPC 发1
    void JAD_DecodeOpen(int localChannel,int iACodec);
    
    //-------g711编码
    int		JAD_EncodeOneFrame(int localChannel, unsigned char *pszAMRBuf, unsigned char *ppszPCMBuf,int nlen);
    
    //-------板卡的语音对讲
    void InitDecode();
    void InitEncode();
    BOOL EncodeAudioData(char *pin,int len,char *pout,int *lenr);
    
    BOOL DecodeAudioData(char *pin,int len,char *pout,int *lenr);
};

@implementation JVCAudioCodecInterface

@end
