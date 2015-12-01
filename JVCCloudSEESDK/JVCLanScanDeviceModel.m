//
//  JVCLanScanDeviceModel.m
//  CloudSEE_II
//  局域网扫描的设备的Model类
//  Created by chenzhenyang on 14-10-13.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCLanScanDeviceModel.h"

@implementation JVCLanScanDeviceModel

@synthesize dguid,dcs,dvip,dvlt,dsls;
@synthesize iDeviceVariety,strDeviceName,iTimeOut,dwifi,iCurMod,dvport;


/**
 *  释放方法
 */
-(void)dealloc{
    
    [dguid release];
    [dvip release];
    [strDeviceName release];
    [super dealloc];
    
}

@end
