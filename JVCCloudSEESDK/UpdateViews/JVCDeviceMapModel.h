//
//  JVCDeviceMapModel.h
//  CloudSEE_II
//
//  Created by David on 14/12/16.
//  Copyright (c) 2014年 David. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCDeviceMacro.h"

 enum  DevieOnLineState{
    
    DevieOnLineState_off = 0,//离线

    DevieOnLineState_on = 1,//设备服务器在线
     
    DevieOnLineState_LanOnLine = 2,//在线

};


@interface JVCDeviceMapModel : NSObject
{
    int         aswitch;    //安全防护开关状态
    int         dimols;     //设备服务器设备的在线状态
    int         dsls;       //设备在云视通服务器的在线状态
    int         dstypeint;  //设备型号的int编号
    int         dtype;      //设备的类型
    int         dvlt;       //设备的连接类型 （0:云视通 1：IP）
    int         dwifi;      //设备是否支持无线 1：支持
    int         dvport;    //设备的端口
    int         isCustomLinkModel;//是否被用户编辑过
    int         dcs;              //设备的通道个数
    int         bIpOrDomainAdd;   //是否是ip添加的设备
    int         dvtcp;//默认的都不是tcp连接，只有等于1的时候，才是tcp连接
    int         csf;//云存储开关   0：关 1：开 其他：不支持（不显示）
    int         dbt;//是否通道正确  0 正确  1错误，错误之后，需要在获取通道数，让后上传到服务器
    
    NSString    *dguid;     //设备的云视通号
    NSString    *atime;      //防护时间
    NSString    *dname;     //设备的昵称
    NSString    *dstype;    //设备的类型
    NSString    *dsv;       //设备的版本
    NSString    *dvip;      //设备的IP
    NSString    *dvpassword;//连接视频的密码
    NSString    *dvusername;//连接视频的用户名
    
    NSString    *dusername;//演示点的用户名
    NSString    *dpassword; //演示点的密码
    
    NSString    *streamingMediaUrl;//流媒体的url
    NSString    *dbtime;//设备添加时间dbtime
}

@property(nonatomic,assign)int         aswitch;
@property(nonatomic,assign)int         dimols;
@property(nonatomic,assign)int         dsls;
@property(nonatomic,assign)int         dstypeint;
@property(nonatomic,assign)int         dtype;
@property(nonatomic,assign)int         dvlt;
@property(nonatomic,assign)int         dwifi;
@property(nonatomic,assign)int         dvport;
@property(nonatomic,assign)int         isCustomLinkModel;
@property(nonatomic,assign)int         dcs;
@property(nonatomic,assign)int         bIpOrDomainAdd;
@property(nonatomic,assign)int         dvtcp;
@property(nonatomic,assign)int         csf;
@property(nonatomic,assign)int         dbt;

@property(nonatomic,retain)NSString    *atime;
@property(nonatomic,retain)NSString    *dguid;
@property(nonatomic,retain)NSString    *dname;
@property(nonatomic,retain)NSString    *dstype;
@property(nonatomic,retain)NSString    *dsv;
@property(nonatomic,retain)NSString    *dvip;
@property(nonatomic,retain)NSString    *dvpassword;
@property(nonatomic,retain)NSString    *dvusername;
@property(nonatomic,retain)NSString    *dusername;//演示点的用户名
@property(nonatomic,retain) NSString    *dpassword;//演示点的密码
@property(nonatomic,retain) NSString    *streamingMediaUrl;//流媒体的url
@property(nonatomic,retain)NSString     *dbtime;
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
                ipAddState:(BOOL)ipAddState;

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
              nickName:(NSString *)nickName;

@end
