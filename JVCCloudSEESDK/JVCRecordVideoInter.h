//
//  JVCRecordVideoInter.h
//  CloudSEE
//
//  Created by chenzhenyang on 14-9-19.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCRecordVideoInter : NSObject


void 	JP_OpenPackage(char *pszmp4file,int nlocalchannel,int fWidth,int fHeight,double fframeRate,int iAcodec, int tempID);
void	JP_ClosePackage(int nlocalChannel);
int JP_PackageOneFrame(unsigned char *h264Data,int nSize ,int nlocalChannel , int iPts,int iDts);

@end
