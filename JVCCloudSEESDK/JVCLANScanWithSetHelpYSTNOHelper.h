//
//  JVCLANScanWithSetHelpYSTNOHelper.h
//  CloudSEE_II
//  广播
//  Created by chenzhenyang on 14-10-13.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCLanScanDeviceModel.h"
#import "JVCLocalCacheModel.h"

@protocol JVCLANScanWithSetHelpYSTNOHelperDelegate <NSObject>

/**
 *  返回的所有广播搜到的设备
 *
 *  @param SerachLANAllDeviceList 返回的设备数组
 */
-(void)SerachLANAllDevicesAsynchronousRequestWithDeviceListDataCallBack:(NSMutableArray *)SerachLANAllDeviceList;

@end

@interface JVCLANScanWithSetHelpYSTNOHelper : NSObject {

    id <JVCLANScanWithSetHelpYSTNOHelperDelegate> delegate ;

}

@property (nonatomic,assign)  id <JVCLANScanWithSetHelpYSTNOHelperDelegate> delegate;

/**
 *  获取云视通网络库广播和设置设备小助手的助手类
 *
 *  @return 云视通网络库逻辑类
 */
+(JVCLANScanWithSetHelpYSTNOHelper *)sharedJVCLANScanWithSetHelpYSTNOHelper;

/**
 *  搜索局域网设备的函数（本局域网）
 */
-(void)SerachLANAllDevicesAsynchronousRequestWithDeviceListData;

/**
 *  搜索局域网设备的函数(本网段)
 */
-(void)SerachAllDevicesAsynchronousRequestWithDeviceListData;

/**
 *  查询局域网设备的通道数，根据广播获取
 *
 *  @param strYstNumber 云视通号
 *
 *  @return 设备的通道数 大于0 有效 <子线程调用>
 */
-(int)queryLanDeviceChannelCount:(NSString *)strYstNumber;


/**
 *  设置小助手
 *
 *  @param devicesMArray devicesMArray
 */
-(void)setDevicesHelper:(NSArray *)devicesMArray;

@end
