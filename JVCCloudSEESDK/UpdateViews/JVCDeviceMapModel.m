//
//  JVCDeviceMapModel.m
//  CloudSEE_II
//
//  Created by David on 14/12/16.
//  Copyright (c) 2014年 David. All rights reserved.
//

#import "JVCDeviceMapModel.h"
#import "JVCDeviceMacro.h"

@implementation JVCDeviceMapModel
@synthesize aswitch,atime,dimols,dsls,dstypeint,dtype,dvlt,dvport,dwifi,isCustomLinkModel,dcs,bIpOrDomainAdd,dvtcp,csf,dbt;
@synthesize dguid,dname,dstype,dsv,dvip,dvpassword,dvusername,dpassword,dusername,streamingMediaUrl,dbtime;

- (void)dealloc
{
    [streamingMediaUrl release];
    [atime release];
    [dpassword release];
    [dusername release];
    [dguid release];
    [dname release];
    [dstype release];
    [dsv release];
    [dvip release];
    [dvpassword release];
    [dvusername release];
    [dbtime release];
    
    [super dealloc];
}

/**
 *  初始化设备
 *
 *  @param ystNum          云视通号
 *  @param deviceNickName  昵称
 *  @param deviceUserName  用户名
 *  @param devicePassWord  密码
 *  @param deviceIp        设备ip
 *  @param devicePort      设备端口号
 *  @param onlineState     在线状态
 *  @param linkType        连接模式
 *  @param hasWifiValue    wifi
 *  @param DeviceLickModel 用户修改状态
 *
 *  @return 设备对象
 */
- (id)initDeviceWithYstNum:(NSString *)ystNum
                  nickName:(NSString *)deviceNickName
            deviceUserName:(NSString *)deviceUserName
            devicePassWord:(NSString *)devicePassWord
                  deviceIP:(NSString *)deviceIp
                devicePort:(NSString *)devicePort
         deviceOnlineState:(int)onlineState
            deviceLinkType:(int)linkType
             deviceHasWifi:(int)hasWifiValue
  devicebICustomLinckModel:(BOOL)DeviceLickModel
                ipAddState:(BOOL)ipAddState
{
    self = [super init];
    
    if (self !=nil) {
        
        self.dguid  = ystNum;
        self.dname       = deviceNickName;
        self.dvusername       = deviceUserName;
        self.dvpassword       = devicePassWord;
        self.dsls    = onlineState;
        self.dwifi          = hasWifiValue;
        if (ipAddState) {
            self.dvip             = [[JVCSystemUtility shareSystemUtilityInstance] getIPAddressForHostString:deviceIp];
            self.dvlt       = CONNECTTYPE_IP;
            
        }else{
            self.dvip             = deviceIp;
            self.dvlt       = CONNECTTYPE_YST;
            
        }
        self.dvport           = devicePort.intValue;
        self.isCustomLinkModel = DeviceLickModel;
        self.bIpOrDomainAdd = ipAddState;
        
        NSDate *now = [NSDate date];
//        self.dbtime = [NSString stringWithFormat:@"%.0f",now.timeIntervalSince1970];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.dbtime = [dateFormatter stringFromDate:now];
//        NSLog(@"dbtime %@",self.dbtime);
    }
    
    return self;
}

/**
 *  初始化设备
 *  @param deviceUserName  用户名
 *  @param devicePassWord  密码
 *  @param deviceIp        设备ip
 *  @param devicePort      设备端口号
 *  @return 设备对象
 */
- (id)initDeviceWithIP:(NSString *)deviceIp
            devicePort:(NSString *)devicePort
        deviceUserName:(NSString *)deviceUserName
        devicePassWord:(NSString *)devicePassWord
              nickName:(NSString *)nickName
{
    self = [super init];
    
    if (self !=nil) {
        
        self.dguid  = deviceIp;
        self.dname       = nickName;
        self.dvusername       = deviceUserName;
        self.dvpassword       = devicePassWord;
        self.dvip             = [[JVCSystemUtility shareSystemUtilityInstance] getIpOrNetHostString:deviceIp];
        self.dvport           = devicePort.intValue;
        self.dsls    = DEVICESTATUS_ONLINE;
        self.dwifi        = DEVICESTATUS_OFFLINE;
        self.dvlt       = CONNECTTYPE_IP;
        self.isCustomLinkModel = 1;
        self.bIpOrDomainAdd = YES;
        NSDate *now = [NSDate date];
//        self.dbtime = [NSString stringWithFormat:@"%.0f",now.timeIntervalSince1970];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.dbtime = [dateFormatter stringFromDate:now];
    }
    
    return self;
}





@end
