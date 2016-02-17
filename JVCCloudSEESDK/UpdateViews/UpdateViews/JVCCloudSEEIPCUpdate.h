//
//  JVCCloudSEEIPCUpdate.h
//  CloudSEE_II
//  走云视通的一键远程升级
//  Created by chenzhenyang on 14-12-29.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCConnectCallBackHelper.h"

/**
 *   检查当前的版本是否可以更新
 *
 *  @param nStatus       JVCHomeIPCUpdateCheckNewVersionStatus
 *  @param strNewVersion 最新版本
 */
typedef void (^JVCCloudSEEIPCUpdateCheckVersionStatusBlock)(int nStatus,NSString *strNewVersion);

@protocol JVCCloudSEEIPCUpdateDelegate <NSObject>

/**
 *  连接的回调函数
 *
 *  @param connectResultType 连接信息的回调函数
 */
-(void)JVCCloudSEEIPCUpdateConnectResult:(int)connectResultType;

/**
 *  下载（烧写）进度的回调
 *
 *  @param value 进度值
 *  @param nType 烧写或下载
 */
-(void)JVCCloudSEEIPCUpdateProgressCallBack:(int)value withType:(int)nType;


/**
 *   下载、烧写、取消、重置完成的回调
 *
 *  @param nType 完成的类型
 */
-(void)JVCCloudSEEIPCUpdateFinshed:(int)nType;


/**
 *  重启设备成功的回调
 *
 *  @param strVersion 设备的新版本
 */
-(void)JVCCloudSEEIPCUpdateResetFinshed:(NSString *)strVersion;


@end

@interface JVCCloudSEEIPCUpdate : JVCConnectCallBackHelper <YstNetWorkHelpTextDataDelegate>{

    id <JVCCloudSEEIPCUpdateDelegate> jvcCloudSEEIPCUpdateDelegate;

}

@property (nonatomic,assign)id <JVCCloudSEEIPCUpdateDelegate> jvcCloudSEEIPCUpdateDelegate;


enum JVCCloudSEEIPCUpdateCheckNewVersionStatus{
    
    JVCCloudSEEIPCUpdateCheckNewVersionNew          = 0,  //存在新版本
    JVCCloudSEEIPCUpdateCheckNewVersionHighVersion  = 1,  //已经是最新版本
};

enum JVCCloudSEEIPCUpdateType{
    
    JVCCloudSEEIPCUpdateDownload            = 0,  //下载
    JVCCloudSEEIPCUpdateWrite               = 1,  //烧写
    JVCCloudSEEIPCUpdateCancel              = 2,  //取消下载
    JVCCloudSEEIPCUpdateReset               = 3,  //重启设备
};


/**
 *  初始化连接回调的助手类
 *
 *  @return 连接回调的助手类
 */
-(id)init:(int)deviceType withDeviceModelInt:(int)deviceModelInt withDeviceVersion:(NSString *)strDeviceVersion withYstNumber:(NSString *)ystNumber withLoginUserName:(NSString *)userName;

/**
 *  检查当前的IPC版本是否有更新
 *
 *  @param jvcHomeIPCUpdateCheckVersionStatusBlock 检查更新的回调Block
 */
-(void)checkIpcIsNewVersion:(JVCCloudSEEIPCUpdateCheckVersionStatusBlock)jvcCloudSEEIPCUpdateCheckVersionStatusBlock;

/**
 *  取消更新
 *
 */
-(void)cancelUpdatePacket;

/**
 *  烧写更新包完成
 *
 */
-(void)resetDevice;

/**
 *  跟新设备信息
 *
 *  @param deviceString 最新后的升级设备
 */
- (void)updateDeviceVersion:(NSString *)deviceString;


@end
