//
//  JVCCloudSEENetworkInterface.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCCloudSEENetworkInterface : NSObject


/*分控回调函数*/
typedef struct
{
    char chGroup[4];
    int  nYSTNO;
    int  nCardType;
    int  nChannelCount;
    char chClientIP[16];
    int  nClientPort;
    int  nVariety;
    char chDeviceName[100];
    BOOL bTimoOut;
    
    int  nNetMod;//例如 是否具有Wifi功能：nNetMod&NET_MOD_WIFI
    int  nCurMod;//例如 当前使用的（WIFI或有线）
    
}STLANSRESULT_01;

@end
