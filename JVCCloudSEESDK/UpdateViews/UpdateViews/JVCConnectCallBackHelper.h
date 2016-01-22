//
//  JVCConnectCallBackHelper.h
//  CloudSEE_II
//  与云视通交互的UI层连接（主要针对业务 网络设置、报警设置等）
//  Created by chenzhenyang on 14-11-12.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCCloudSEESDK.h"
//#import "JVCDeviceModel.h"
#import "JVCDeviceMapModel.h"
@protocol DeviceUpdateDelegate <NSObject>
- (void)deviceUpdateSuccess;
@end
@interface JVCConnectCallBackHelper : NSObject <JVCCloudSEESDKDelegate> {

     int nConnectLocalChannel;  //连接的本地通道号
    id<DeviceUpdateDelegate> deviceupdateDelegate;
}
/**
 *  连接设备的函数
 *
 *  @param model         连接的model
 *  @param nChannel      连接设备的通道
 *  @param nLocalChannel 本地连接的通道
 */
-(void)connectVideoWithDeviceModel:(JVCDeviceMapModel *)model withChannel:(int)nChannel withLocalChannel:(int)nLocalChannel;

/**
 *  断开本窗口的连接
 */
-(void)disconnect;

/**
 *  云视通连接的回调函数
 *
 *  @param connectCallBackInfo 连接的返回信息
 *  @param nlocalChannel       对应的本地通道
 *  @param connectResultType   连接返回的状态
 */
-(void)ConnectMessageCallBackMath:(NSString *)connectCallBackInfo nLocalChannel:(int)nlocalChannel connectResultType:(int)connectResultType;

/**
 *  开始请求文本聊天的回调
 *
 *  @param nLocalChannel 本地显示窗口的编号
 *  @param nDeviceType   设备的类型
 */
-(void)RequestTextChatCallback:(int)nLocalChannel withDeviceType:(int)nDeviceType withIsNvrDevice:(BOOL)isNvrDevice;

/**
 *  文本聊天请求的结果回调
 *
 *  @param nLocalChannel 本地本地显示窗口的编号
 *  @param nStatus       文本聊天的状态
 */
-(void)RequestTextChatStatusCallBack:(int)nLocalChannel withStatus:(int)nStatus;

@end
