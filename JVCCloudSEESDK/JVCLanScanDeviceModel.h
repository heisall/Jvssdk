//
//  JVCLanScanDeviceModel.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-10-13.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCLanScanDeviceModel : NSObject{
    
    NSString    *dguid;     //设备的云视通号
    int         dcs;              //设备的通道个数
    NSString    *dvip;      //设备的IP
    int         dvport;    //设备的端口
    int         dwifi;      //设备是否支持无线 1：支持
    int         dsls;        //设备是否在线
    int         dvlt;        //设备连接模式  0：云视通  1：ip连接
    
    //暂时没有用到的字段
    int       iDeviceVariety;      //设备的种类
    int       iTimeOut;            //是否超时，广播超时时间之后返回的数据
    BOOL      iCurMod;             //YES:WIFI NO:有钱
    NSString *strDeviceName;       //设备的名称
//    BOOL      iNetMod;             //YES：WIFI功能
//    NSString    *dname;     //设备的昵称

    int  timer_count;

}

@property(nonatomic,retain)NSString *dguid;
@property(nonatomic,assign)int       dcs;
@property(nonatomic,retain)NSString *dvip;
@property(nonatomic,assign)int      dvport;
@property(nonatomic,assign)int      dwifi;
@property(nonatomic,assign)int      dsls;
@property(nonatomic,assign)int      dvlt;

@property(nonatomic,assign)int       iDeviceVariety;
//@property(nonatomic,assign)BOOL      iNetMod;
@property(nonatomic,assign)BOOL      iCurMod;
@property(nonatomic,assign)int       iTimeOut;
@property(nonatomic,retain)NSString *strDeviceName;
@property(nonatomic,assign)int timer_count;
@end
