//
//  JVCRecordVideoInter.m
//  CloudSEE
//
//  Created by chenzhenyang on 14-9-19.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import "JVCRecordVideoInter.h"


extern "C"
{
    
    /***********
     本地录像
     *********************************************************/
    //    void *JP_OpenPackage(char *pszmp4file,int nlocalchannel,int fWidth,int fHeight,float fframeRate,int spsSize,int ppsSize);
    //
    //    void	JP_ClosePackage(int nlocalChannel);
    //
    //    int		JP_PackageOneFrame(unsigned char *h264Data,int nSize, int nlocalChannel);
    
    void 	JP_OpenPackage(char *pszmp4file,int nlocalchannel,BOOL bWriteVideo,BOOL bWriteAudio,int fWidth,int fHeight,double fframeRate,int iAcodec);
    void	JP_ClosePackage(int nlocalChannel);
    int JP_PackageOneFrame(unsigned char *h264Data,int nSize ,int nlocalChannel , int iPts,int iDts);
    
};

@implementation JVCRecordVideoInter

@end
