//
//  JVCCloudSEEIPCUpdate.m
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-12-29.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCCloudSEEIPCUpdate.h"
#import "JVCDeviceHelper.h"
#import "JVCPacketModel.h"


@interface JVCCloudSEEIPCUpdate (){

    NSMutableDictionary *mdUpdateInfo;
    NSMutableString     *strVersion;
    int                  nDeviceType;
    int                  nDeviceModelInt;
    NSMutableString     *strYstNumber;
    NSMutableString     *strLoginUserName;
    __block int          nDownloadSize;
    __block int          nWriteSize;
    __block BOOL         isCancelDownload;
    
    __block BOOL         isFirstCancel;
    __block BOOL         isCanceling;     //YES:正在取消
}

@property (nonatomic,copy) JVCCloudSEEIPCUpdateCheckVersionStatusBlock   homeIPCUpdateCheckVersionStatusBlock;

@end

@implementation JVCCloudSEEIPCUpdate
@synthesize homeIPCUpdateCheckVersionStatusBlock;
@synthesize jvcCloudSEEIPCUpdateDelegate;

static const int  kWriteSleepTime         = 1*1000*1000;   //烧写进度相等停顿的时间（毫秒级）



-(void)ConnectMessageCallBackMath:(NSString *)connectCallBackInfo nLocalChannel:(int)nlocalChannel connectResultType:(int)connectResultType{

    if (CONNECTRESULTTYPE_Succeed != connectResultType) {
        
        if (self.jvcCloudSEEIPCUpdateDelegate != nil && [self.jvcCloudSEEIPCUpdateDelegate respondsToSelector:@selector(JVCCloudSEEIPCUpdateConnectResult:)]) {
            
            [self.jvcCloudSEEIPCUpdateDelegate JVCCloudSEEIPCUpdateConnectResult:connectResultType];
        }
    }
}

/**
 *  初始化连接回调的助手类
 *
 *  @return 连接回调的助手类
 */
-(id)init:(int)deviceType withDeviceModelInt:(int)deviceModelInt withDeviceVersion:(NSString *)strDeviceVersion withYstNumber:(NSString *)ystNumber withLoginUserName:(NSString *)userName{
    
    if (self = [super init]) {
        
        mdUpdateInfo      = [[NSMutableDictionary alloc] initWithCapacity:10];
        strVersion        = [[NSMutableString alloc]     initWithCapacity:10];
        strYstNumber      = [[NSMutableString alloc]     initWithCapacity:10];
        strLoginUserName  = [[NSMutableString alloc]     initWithCapacity:10];
        nDeviceType       = deviceType;
        nDeviceModelInt   = deviceModelInt;
        [strVersion appendString:strDeviceVersion];
        [strYstNumber appendString:ystNumber];
        [strLoginUserName appendString:userName];
        
        isCancelDownload  = FALSE;
    }
    
    return self;
}

/**
 *  跟新设备信息
 *
 *  @param deviceString 最新后的升级设备
 */
- (void)updateDeviceVersion:(NSString *)deviceString
{
    [strVersion deleteCharactersInRange:(NSMakeRange(0, strVersion.length))];
    [strVersion appendString:deviceString];
}

/**
 *  检查当前的IPC版本是否有更新
 *
 *  @param jvcHomeIPCUpdateCheckVersionStatusBlock 检查更新的回调Block
 */
-(void)checkIpcIsNewVersion:(JVCCloudSEEIPCUpdateCheckVersionStatusBlock)jvcCloudSEEIPCUpdateCheckVersionStatusBlock{
    
    [mdUpdateInfo removeAllObjects];
    
    self.homeIPCUpdateCheckVersionStatusBlock = jvcCloudSEEIPCUpdateCheckVersionStatusBlock;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        JVCDeviceHelper *deviceHelperObj = [JVCDeviceHelper sharedDeviceLibrary];
        
        [mdUpdateInfo setValuesForKeysWithDictionary:[deviceHelperObj checkDeviceUpdateState:nDeviceType deviceModel:nDeviceModelInt deviceVersion:strVersion]];
        
        if (self.homeIPCUpdateCheckVersionStatusBlock) {
            
            NSDictionary     *updateInfoMDic = (NSDictionary *)[mdUpdateInfo objectForKey:CONVERTCHARTOSTRING(JK_UPDATE_FILE_INFO)];
            
            JVCSystemUtility *systemUtility  = [JVCSystemUtility shareSystemUtilityInstance];
            
            
            if (![systemUtility judgeDictionIsNil:updateInfoMDic]) {
                
                self.homeIPCUpdateCheckVersionStatusBlock([[JVCSystemUtility shareSystemUtilityInstance] JudgeGetDictionIsLegal:mdUpdateInfo] == YES ? JVCCloudSEEIPCUpdateCheckNewVersionNew : JVCCloudSEEIPCUpdateCheckNewVersionHighVersion,[updateInfoMDic objectForKey:CONVERTCHARTOSTRING(JK_UPGRADE_FILE_VERSION)]);
            }else{
            
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [[JVCAlertHelper shareAlertHelper] alertHidenToastOnWindow];
                    [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:LOCALANGER(@"REQ_RES_TIMEOUT")];
                });
            }
        }
        
        [self deallocWithCheckNewVersion];
        
    });
}

-(void)RequestTextChatCallback:(int)nLocalChannel withDeviceType:(int)nDeviceType withIsNvrDevice:(BOOL)isNvrDevice {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        JVCCloudSEENetworkHelper *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
        
        [ystNetWorkHelperObj RemoteOperationSendDataToDevice:nLocalChannel remoteOperationCommand:JVN_REQ_TEXT];
        
    });
}

/**
 *  下载更新
 *
 */
-(void)downloadUpdatePacket{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        JVCCloudSEENetworkHelper *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
        
        JVCPacketModel *packetModel = [[JVCPacketModel alloc] init];
        
        packetModel.packetType      = RC_EXTEND;
        packetModel.packetCount     = RC_EX_FIRMUP;
        
        JVCExtendModel *extendModel = [[JVCExtendModel alloc] init];
        
        extendModel.extendType      = EX_UPLOAD_START;
        extendModel.extendParam1    = FIRMUP_HTTP;
        
        packetModel.extendInfo      = extendModel;
        [extendModel release];

        [ystNetWorkHelperObj RemoteOperationAtTextChatSendDataToDevice:nConnectLocalChannel withDicCommand:[packetModel dicWithModel]];
        
        [packetModel release];
        
    });
}

/**
 *  取消更新
 *
 */
-(void)cancelUpdatePacket{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        JVCCloudSEENetworkHelper *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
        ystNetWorkHelperObj.ystNWTDDelegate           = self;
        
        JVCPacketModel *packetModel = [[JVCPacketModel alloc] init];
        
        packetModel.packetType      = RC_EXTEND;
        packetModel.packetCount     = RC_EX_FIRMUP;
        
        JVCExtendModel *extendModel = [[JVCExtendModel alloc] init];
        
        extendModel.extendType      = EX_UPLOAD_CANCEL;
        extendModel.extendParam1    = FIRMUP_HTTP;
        
        packetModel.extendInfo      = extendModel;
        [extendModel release];
        
        [ystNetWorkHelperObj RemoteOperationAtTextChatSendDataToDevice:nConnectLocalChannel withDicCommand:[packetModel dicWithModel]];
        
        [packetModel release];
        
        if (!isFirstCancel) {
            
            if (self.jvcCloudSEEIPCUpdateDelegate != nil && [self.jvcCloudSEEIPCUpdateDelegate respondsToSelector:@selector(JVCCloudSEEIPCUpdateFinshed:)]) {
                
                [self.jvcCloudSEEIPCUpdateDelegate JVCCloudSEEIPCUpdateFinshed:JVCCloudSEEIPCUpdateCancel];
            }
        }
        
    });
}

/**
 *  获取下载的进度
 */
-(void)downloadUpdatePacketWithProgress{
    
    gcd_async_background(^{
        
        usleep(kWriteSleepTime);
        
        JVCCloudSEENetworkHelper *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];

        JVCPacketModel *packetModel                   = [[JVCPacketModel alloc] init];

        packetModel.packetType                        = RC_EXTEND;
        packetModel.packetCount                       = RC_EX_FIRMUP;

        JVCExtendModel *extendModel                   = [[JVCExtendModel alloc] init];

        extendModel.extendType                        = EX_UPLOAD_DATA;
        extendModel.extendParam1                      = FIRMUP_HTTP;

        packetModel.extendInfo                        = extendModel;
        [extendModel release];

        [ystNetWorkHelperObj RemoteOperationAtTextChatSendDataToDevice:nConnectLocalChannel withDicCommand:[packetModel dicWithModel]];

        [packetModel release];

    });

}

/**
 *  下载更新包完成
 *
 */
-(void)downloadUpdatePacketWithSuccessful{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        JVCCloudSEENetworkHelper *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];

        JVCPacketModel *packetModel                   = [[JVCPacketModel alloc] init];

        packetModel.packetType                        = RC_EXTEND;
        packetModel.packetCount                       = RC_EX_FIRMUP;

        JVCExtendModel *extendModel                   = [[JVCExtendModel alloc] init];

        extendModel.extendType                        = EX_UPLOAD_OK;
        extendModel.extendParam1                      = FIRMUP_HTTP;

        packetModel.extendInfo                        = extendModel;
        [extendModel release];

        [ystNetWorkHelperObj RemoteOperationAtTextChatSendDataToDevice:nConnectLocalChannel withDicCommand:[packetModel dicWithModel]];

        [packetModel release];
        
    });
}

/**
 *  下载更新包完成
 *
 */
-(void)writeDownloadPacketWithDevice{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        JVCCloudSEENetworkHelper *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];

        JVCPacketModel *packetModel                   = [[JVCPacketModel alloc] init];

        packetModel.packetType                        = RC_EXTEND;
        packetModel.packetCount                       = RC_EX_FIRMUP;

        JVCExtendModel *extendModel                   = [[JVCExtendModel alloc] init];
        
        extendModel.extendType                        = EX_FIRMUP_START;
        packetModel.extendInfo                        = extendModel;
        [extendModel release];

        [ystNetWorkHelperObj RemoteOperationAtTextChatSendDataToDevice:nConnectLocalChannel withDicCommand:[packetModel dicWithModel]];

        [packetModel release];
        
    });
}

/**
 *  烧写更新包完成
 *
 */
-(void)writeDownloadPacketWithProgress{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        usleep(kWriteSleepTime);
        JVCCloudSEENetworkHelper *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
        
        JVCPacketModel *packetModel = [[JVCPacketModel alloc] init];
        
        packetModel.packetType      = RC_EXTEND;
        packetModel.packetCount     = RC_EX_FIRMUP;
        
        JVCExtendModel *extendModel = [[JVCExtendModel alloc] init];
        
        extendModel.extendType      = EX_FIRMUP_STEP;
        packetModel.extendInfo      = extendModel;
        [extendModel release];
        
        [ystNetWorkHelperObj RemoteOperationAtTextChatSendDataToDevice:nConnectLocalChannel withDicCommand:[packetModel dicWithModel]];
        
        [packetModel release];
        
    });
}

/**
 *  重启设备
 *
 */
-(void)resetDevice{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        usleep(kWriteSleepTime);
        JVCCloudSEENetworkHelper *ystNetWorkHelperObj = [JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper];
        
        JVCPacketModel *packetModel = [[JVCPacketModel alloc] init];
        
        packetModel.packetType      = RC_EXTEND;
        packetModel.packetCount     = RC_EX_FIRMUP;
        
        JVCExtendModel *extendModel = [[JVCExtendModel alloc] init];
        
        extendModel.extendType      = EX_FIRMUP_REBOOT;
        packetModel.extendInfo      = extendModel;
        [extendModel release];
        
        if (self.jvcCloudSEEIPCUpdateDelegate != nil && [self.jvcCloudSEEIPCUpdateDelegate respondsToSelector:@selector(JVCCloudSEEIPCUpdateResetFinshed:)]) {
            
            NSDictionary     *updateInfoMDic = (NSDictionary *)[mdUpdateInfo objectForKey:CONVERTCHARTOSTRING(JK_UPDATE_FILE_INFO)];
            
            JVCSystemUtility *systemUtility  = [JVCSystemUtility shareSystemUtilityInstance];
            
            if (![systemUtility judgeDictionIsNil:updateInfoMDic]) {
                
               [self.jvcCloudSEEIPCUpdateDelegate JVCCloudSEEIPCUpdateResetFinshed:[updateInfoMDic objectForKey:CONVERTCHARTOSTRING(JK_UPGRADE_FILE_VERSION)]];
            }
            
            
        }
        
        [ystNetWorkHelperObj RemoteOperationAtTextChatSendDataToDevice:nConnectLocalChannel withDicCommand:[packetModel dicWithModel]];
        
        [packetModel release];
        
        [self disconnect];
        
    });
}

-(void)RequestTextChatStatusCallBack:(int)nLocalChannel withStatus:(int)nStatus{
    
    switch (nStatus) {
            
        case JVN_RSP_TEXTACCEPT:{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                isFirstCancel = TRUE;
                isCanceling   = FALSE;
                
                [self cancelUpdatePacket];

            });
            
        }
            break;
        default:{
            
            DDLogVerbose(@"%s---------------------  主控忙碌",__FUNCTION__);
//            [self error:ErrorTypeReject];
            
        }
            break;
    }
}

#pragma mark ystNetWorkHelpTextDataDelegate

/**
 *  获取文本请求的回调
 *
 *  @param nLocalChannel 连接的通道
 *  @param dic           响应的字典
 */
-(void)RemoteOperationAtTextChatResponse:(int)nLocalChannel withResponseDic:(NSDictionary *)dic{
    
    JVCPacketModel *packetmodel = [JVCPacketModel modelWithDic:dic];
    
    if (packetmodel.packetType == RC_EXTEND) {
        
        JVCExtendModel *extend = (JVCExtendModel *)packetmodel.extendInfo;
        
        switch (packetmodel.packetCount) {
                
            case RC_EX_FIRMUP:{
                
                switch (extend.extendType) {
                        
                    case EX_UPLOAD_CANCEL:{
                        
                        if (isFirstCancel) {
                            
                            isFirstCancel = FALSE;
                            [self downloadUpdatePacket];
                            
                        }else{
                            
                            isCanceling = YES;
                            
                            if (self.jvcCloudSEEIPCUpdateDelegate != nil && [self.jvcCloudSEEIPCUpdateDelegate respondsToSelector:@selector(JVCCloudSEEIPCUpdateFinshed:)]) {
                                
                                [self.jvcCloudSEEIPCUpdateDelegate JVCCloudSEEIPCUpdateFinshed:JVCCloudSEEIPCUpdateCancel];
                            }
                        }
                        
                    }
                        break;
                        
                    case EX_UPLOAD_DATA:{
                        
                        if (!isCanceling) {
                            
                            if (self.jvcCloudSEEIPCUpdateDelegate != nil && [self.jvcCloudSEEIPCUpdateDelegate respondsToSelector:@selector(JVCCloudSEEIPCUpdateProgressCallBack:withType:)] ) {
                                
                                [self.jvcCloudSEEIPCUpdateDelegate JVCCloudSEEIPCUpdateProgressCallBack:extend.extendParam2 withType:JVCCloudSEEIPCUpdateDownload];
                            }
                            
                            if (extend.extendParam2<100) {
                                
                                [self downloadUpdatePacketWithProgress];
                                
                            }else{
                                
                                [self downloadUpdatePacketWithSuccessful];
                            }
                        }
                    };
                        break;
                    case EX_UPLOAD_OK:{
                        
                        if (!isCanceling) {
                            
                            if (self.jvcCloudSEEIPCUpdateDelegate != nil && [self.jvcCloudSEEIPCUpdateDelegate respondsToSelector:@selector(JVCCloudSEEIPCUpdateFinshed:)]) {
                                
                                [self.jvcCloudSEEIPCUpdateDelegate JVCCloudSEEIPCUpdateFinshed:JVCCloudSEEIPCUpdateDownload];
                            }
                            
                            [self writeDownloadPacketWithDevice];
                        }
                    }
                        break;
                    case EX_FIRMUP_START:{
                        
                        [self writeDownloadPacketWithProgress];
                    }
                        break;
                    case EX_FIRMUP_STEP:{
                        
                        if (self.jvcCloudSEEIPCUpdateDelegate != nil && [self.jvcCloudSEEIPCUpdateDelegate respondsToSelector:@selector(JVCCloudSEEIPCUpdateProgressCallBack:withType:)] ) {
                            
                            [self.jvcCloudSEEIPCUpdateDelegate JVCCloudSEEIPCUpdateProgressCallBack:extend.extendParam1 withType:JVCCloudSEEIPCUpdateWrite];
                        }
                        
                        [self writeDownloadPacketWithProgress];
                    }
                        break;
                    case EX_FIRMUP_OK:{
                        
                        if (self.jvcCloudSEEIPCUpdateDelegate != nil && [self.jvcCloudSEEIPCUpdateDelegate respondsToSelector:@selector(JVCCloudSEEIPCUpdateFinshed:)]) {
                            
                            [self.jvcCloudSEEIPCUpdateDelegate JVCCloudSEEIPCUpdateFinshed:JVCCloudSEEIPCUpdateWrite];
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                
                break;
                
            default:
                break;
        }
    }
    
    DDLogVerbose(@"%s----------------#890=%@",__FUNCTION__,[packetmodel dicWithModel]);
}

/**
 *  清除版本更新的block
 */
-(void)deallocWithCheckNewVersion{
    
    [homeIPCUpdateCheckVersionStatusBlock release];
    homeIPCUpdateCheckVersionStatusBlock =nil;
}

@end
