//
//  JVCConnectCallBackHelper.m
//  CloudSEE_II
//  
//  Created by chenzhenyang on 14-11-12.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCConnectCallBackHelper.h"

@implementation JVCConnectCallBackHelper

/**
 *  初始化连接回调的助手类
 *
 *  @return 连接回调的助手类
 */
-(id)init{

    if (self = [super init]) {
        
        JVCCloudSEENetworkHelper *networkObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
        networkObj.ystNWHDelegate            = self;
    }
    
    return self;
}

-(void)dealloc{

    JVCCloudSEENetworkHelper *networkObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
    networkObj.ystNWHDelegate            = nil;
    
    DDLogVerbose(@"%s--------------------------------",__FUNCTION__);
    [super dealloc];
}

/**
 *  连接设备的函数
 *
 *  @param model         连接的model
 *  @param nChannel      连接设备的通道
 *  @param nLocalChannel 本地连接的通道
 */
-(void)connectVideoWithDeviceModel:(JVCDeviceMapModel *)model withChannel:(int)nChannel withLocalChannel:(int)nLocalChannel{
    
    nConnectLocalChannel = nLocalChannel;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [model retain];
        
        JVCCloudSEENetworkHelper            *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
        BOOL                                 connectStatus       = [ystNetWorkHelperObj checknLocalChannelExistConnect:nLocalChannel];
        
        //重复连接
        if (!connectStatus) {
            
            if (model.dvlt == CONNECTTYPE_IP) {
                
                connectStatus = [ystNetWorkHelperObj ipConnectVideobyDeviceInfo:nLocalChannel nRemoteChannel:nChannel  strUserName:model.dvusername strPassWord:model.dvpassword strRemoteIP:model.dvip nRemotePort:model.dvport nSystemVersion:IOS_VERSION isConnectShowVideo:NO withConnectType:TYPE_3GMO_UDP withShowView:nil tcpState:model.dvtcp];
                
            }else{
                
                connectStatus = [ystNetWorkHelperObj ystConnectVideobyDeviceInfo:nLocalChannel nRemoteChannel:nChannel strYstNumber:model.dguid strUserName:model.dvusername strPassWord:model.dvpassword nSystemVersion:IOS_VERSION isConnectShowVideo:NO withConnectType:TYPE_3GMO_UDP withShowView:nil];
            }
        }
        
        [model release];
        
    });
//    [deviceupdateDelegate deviceUpdateSuccess];
}


/**
 *  断开本窗口的连接
 */
-(void)disconnect{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        JVCCloudSEENetworkHelper  *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
        
        [ystNetWorkHelperObj disconnect:nConnectLocalChannel];
        
    });
}

#pragma mark -------------- ystNetworkDelegate
/**
 *  云视通连接的回调函数
 *
 *  @param connectCallBackInfo 连接的返回信息
 *  @param nlocalChannel       对应的本地通道
 *  @param connectResultType   连接返回的状态
 */
-(void)ConnectMessageCallBackMath:(NSString *)connectCallBackInfo nLocalChannel:(int)nlocalChannel connectResultType:(int)connectResultType {
    
    DDLogVerbose(@"%s--------001",__FUNCTION__);
}

/**
 *  开始请求文本聊天的回调
 *
 *  @param nLocalChannel 本地显示窗口的编号
 *  @param nDeviceType   设备的类型
 */
-(void)RequestTextChatCallback:(int)nLocalChannel withDeviceType:(int)nDeviceType withIsNvrDevice:(BOOL)isNvrDevice{
    
    DDLogVerbose(@"%s--------002",__FUNCTION__);
}

/**
 *  文本聊天请求的结果回调
 *
 *  @param nLocalChannel 本地本地显示窗口的编号
 *  @param nStatus       文本聊天的状态
 */
-(void)RequestTextChatStatusCallBack:(int)nLocalChannel withStatus:(int)nStatus{
    
    DDLogVerbose(@"%s--------003",__FUNCTION__);
}

@end
