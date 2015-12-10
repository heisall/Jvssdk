//
//  JVCCloudSEESendGeneralHelper.m
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCCloudSEESendGeneralHelper.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVCCloudSEENetworkInterface.h"
#import "JVNetConst.h"
#import  <Arpa/inet.h>

@implementation JVCCloudSEESendGeneralHelper

static JVCCloudSEESendGeneralHelper *jvcCloudSEESendGeneralHelper = nil;
/**
 *  单例
 *
 *  @return 返回JVCCloudSEESendGeneralHelper 单例
 */
+ (JVCCloudSEESendGeneralHelper *)shareJVCCloudSEESendGeneralHelper
{
    @synchronized(self)
    {
        if (jvcCloudSEESendGeneralHelper == nil) {
            
            jvcCloudSEESendGeneralHelper = [[self alloc] init ];
            
        }
        
        return jvcCloudSEESendGeneralHelper;
    }
    
    return jvcCloudSEESendGeneralHelper;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (jvcCloudSEESendGeneralHelper == nil) {
            
            jvcCloudSEESendGeneralHelper = [super allocWithZone:zone];
            
            return jvcCloudSEESendGeneralHelper;
        }
    }
    
    return nil;
}

/**
 *  远程发送的命令（仅仅发送 没有返回结果）
 *
 *  @param nJvChannelID           控制本地连接的通道号
 *  @param remoteOperayionType    控制的类型
 *  @param remoteOperayionCommand 控制的命令
 *  @param speedValue             云台控制速度
 */
- (void)onlySendYtOperaton:(int)nJvChannelID remoteOperationType:(int)remoteOperationType remoteOperationCommand:(int)remoteOperationCommand  speed:(int)speedValue
{
    [self remoteOperationYTO:nJvChannelID remoteOperationCommand:remoteOperationCommand speed:speedValue];
}

/**
 *  远程发送的命令（仅仅发送 没有返回结果）
 *
 *  @param nJvChannelID           控制本地连接的通道号
 *  @param remoteOperayionType    控制的类型
 *  @param remoteOperayionCommand 控制的命令
 */
-(void)onlySendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType remoteOperationCommand:(int)remoteOperationCommand{
    
    switch (remoteOperationType) {
            
        case RemoteOperationType_YTO:{
            
            [self remoteOperationYTO:nJvChannelID remoteOperationCommand:remoteOperationCommand];
        }
            break;
            
        case RemoteOperationType_TextChat:
        case RemoteOperationType_VoiceIntercom:{
            
            [self remoteOperationVoiceChat:nJvChannelID remoteOperationCommand:remoteOperationCommand];
        }
            break;
            
        case RemoteOperationType_RemotePlaybackSEEK:{
            
            [self remotePlaybackSEEK:nJvChannelID remoteOperationCommand:remoteOperationCommand];
        }
            break;
        case TextChatType_NetWorkInfo:{
            
            [self RemoteDeviceNetworkInfo:nJvChannelID];
        }
            break;
            
        case TextChatType_ApList:{
            
            [self RemoteDeviceAplistInfo:nJvChannelID];
            
        }
            break;
        case TextChatType_paraInfo:{
            
            [self RemoteWithDeviceGetFrameParam:nJvChannelID];
        }
            break;
        case TextChatType_getDeviePTZSpeed:
            
            [self RemoteWithDeviceGetYTSpeedParam:nJvChannelID];

            break;
            
        case  TextChatType_ApSetResult:{
            
            [self RemoteGetApOldsetResult:nJvChannelID];
        }
        case TextChatType_setStream:{
        
            [self RemoteWithDeviceSetFrameParam:nJvChannelID withStreamType:remoteOperationCommand];
        }
            break;
        case TextChatType_setOldStream:{
            
            [self RemoteWithOldDeviceSetFrameParam:nJvChannelID withStreamType:remoteOperationCommand];
        }
            break;
        case TextChatType_setOldMainStream:{
            
            [self RemoteWithOldDeviceSetMainFrameParam:nJvChannelID withStreamType:remoteOperationCommand];
        }
            break;
        case TextChatType_setAlarmType:{
            
            [self RemoteBindAlarmDevice:nJvChannelID withAddAlarmType:remoteOperationCommand];
        }
            break;
        case TextChatType_getAlarmType:{
            
            [self RemoteRequestAlarmDevice:nJvChannelID];
        }
            break;
        case TextChatType_EffectInfo:
           [self RemoteSetDeviceWithEffectModel:nJvChannelID withEffectType:remoteOperationCommand];
            break;
        case TextChatType_StorageMode:
            
            [self RemoteSetDeviceWithStorageMode:nJvChannelID withStorageMode:remoteOperationCommand];
            break;
        case TextChatType_setAlarm:{
        
            [self RemoteSetAlarmStatus:nJvChannelID withStatus:remoteOperationCommand];
        }
            break;
        case TextChatType_setMobileMonitoring:{
        
            [self RemoteSetMotionDetectingStatus:nJvChannelID withStatus:remoteOperationCommand];
        }
            
        case TextChatType_setDeviceBabyCry:{
            
            [self RemoteSetBabyCryStatus:nJvChannelID withStatus:remoteOperationCommand];
        }
            break;
        case TextChatType_setDeviceTimezone:{
        
            [self RemoteSetDeviceWithTimezone:nJvChannelID withTimezone:remoteOperationCommand];
        }
            break;
        case TextChatType_setDevicePNMode:{
            
            [self RemoteSetDeviceWithPNMode:nJvChannelID withPNMode:remoteOperationCommand];
        }
            break;
        case TextChatType_setDeviceFlashMode:{
            
            [self RemoteSetDeviceWithFlashMode:nJvChannelID withFlashMode:remoteOperationCommand];
        }
            break;
        case TextChatType_setDeviceAPMode:{
            
            [self RemoteSetDeviceWithAPMode:nJvChannelID withAPModel:remoteOperationCommand];
        }
            break;
            
        case TextChatType_Capture:{
            
            [self RemoteDeviceWithCapture:nJvChannelID];
        }
            break;
        case TextChatType_setDeviceAlarmSound:
            [self RemoteSetDeviceAlarmSoundStatus:nJvChannelID withStatus:remoteOperationCommand];
            break;
        case TextChatType_setDeviceNetTime:
            [self RemoteSetDeviceNetTimer:nJvChannelID
                               deviceType:remoteOperationType
                               deviceGuid:remoteOperationCommand];
            break;
        case TextChatType_setDeviceEmailStatus:{
            
            [self RemoteSetDeviceEmailStatus:nJvChannelID deviceType:remoteOperationType deviceGuid:remoteOperationCommand];
        }
            break;

        default:
            break;
    }
}
//设置设备时间
-(void)onlySendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType remoteOperationCommandStr:(NSString *)remoteOperationCommand{
    if (remoteOperationType==TextChatType_setDeviceTimeFormat) {
        [self RemoteSetDeviceTimerInfo:nJvChannelID timerSting:remoteOperationCommand];
    }
}

//设置移动侦测灵敏度
-(void)onlySendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType remoteOperationCommandSensitivityStr:(NSString *)remoteOperationCommand{
    if (remoteOperationType==TextChatType_setSensitivity) {
        [self RemoteSetSensitivity:nJvChannelID alarmSting:remoteOperationCommand];
    }
}
//读取移动侦测灵敏度
-(void)onlySendRemoteOperationSensitivity:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    if (remoteOperationType==TextChatType_readSensitivity) {
        [self RemoteReadSensitivity:nJvChannelID];
    }
}

//报警录像
-(void)AlarmVedioSendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    if (remoteOperationType==TextChatType_AlarmVedio) {
        [self RemoteAlarmVedio:nJvChannelID];
    }
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];

}
//手动录像
-(void)ManualVedioSendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    if (remoteOperationType==TextChatType_ManualVedio) {
        [self RemoteManualVedio:nJvChannelID];
    }
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];

}

//停止录像
-(void)stopVedioSendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    if (remoteOperationType==TextChatType_stopVedio) {
        [self RemoteStopVedio:nJvChannelID];
    }
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];

}
//旧设备停止录像
-(void)stopOldVedioSendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    if (remoteOperationType==TextChatType_stopOldVedio) {
        [self RemoteStopOldVedio:nJvChannelID];
    }
}
//旧设备开始录像
-(void)startOldVedioSendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    if (remoteOperationType==TextChatType_startOldVedio) {
        [self RemoteStartOldVedio:nJvChannelID];
    }
}

//格式化SD卡
-(void)FormatSDSendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
//     [[JVCAlertHelper shareAlertHelper] alertShowToastOnWindow];
    if (remoteOperationType==TextChatType_FormatSD) {
        [self RemoteFormatSD:nJvChannelID];
    }
}
//获取基本信息
-(void)getBasicInfoRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    if (remoteOperationType==TextChatType_getBasicInfo) {
        [self RemoteGetBasicInfo:nJvChannelID];
    }
}
//获取SD卡信息
-(void)SDSendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    if (remoteOperationType==TextChatType_getDeviceSDCardInfo) {
        [self RemoteGetSDInfo:nJvChannelID];
    }
}

#pragma mark 远程操作的函数

/**
 *  云台控制命令
 *
 *  @param nJvChannelID           控制本地连接的通道号
 *  @param remoteOperationCommand 云台命令
 */
-(void)remoteOperationYTO:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand{
    
    
    int num = 3;
   int remoteData = ((num & 0xffFFff) << 24) | (remoteOperationCommand & 0xff);
    unsigned char data[4]={0};
	memcpy(data,&remoteData,4);
    
	JVC_SendData(nJvChannelID, JVN_CMD_YTCTRL, (unsigned char *)data, 4);
}


/**
 *  云台控制命令
 *
 *  @param nJvChannelID           控制本地连接的通道号
 *  @param remoteOperationCommand 云台命令
 */
-(void)remoteOperationYTO:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand  speed:(int)speed
{
    int remoteData ;
    
    if (remoteOperationCommand<0) {
        return;
    }
    if (speed>=0) {
        
         remoteData = ((speed & 0xffFFff) << 24) | (remoteOperationCommand & 0xff);

    }else{
         remoteData =  remoteOperationCommand ;

    }
    unsigned char data[4]={0};
    memcpy(data,&remoteData,4);
    
    JVC_SendData(nJvChannelID, JVN_CMD_YTCTRL, (unsigned char *)data, 4);
}

/**
 *  远程发送音频数据
 *
 *  @param nJvChannelID  本地连接的通道号
 *  @param Audiodata     音频数据
 *  @param AudiodataSize 音频数据的大小
 */
-(void)SendAudioDataToDevice:(int)nJvChannelID Audiodata:(char *)Audiodata AudiodataSize:(int)AudiodataSize {
    
    JVC_SendData(nJvChannelID,JVN_RSP_CHATDATA,(unsigned char *)Audiodata,AudiodataSize);
    
   
}

/**
 *  远程控制指令
 *
 *  @param nJvChannelID           本地连接的通道号
 *  @param remoteOperationCommand 控制的命令
 */
-(void)RemoteOperationSendDataToDevice:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand {
    
    JVC_SendData(nJvChannelID, remoteOperationCommand, NULL, 0);
}

/**
 *  语音聊天
 *
 *  @param nJvChannelID           本地连接的通道号
 *  @param remoteOperayionCommand 控制的命令
 *
 */
-(void)remoteOperationVoiceChat:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand {
    
    JVC_SendData(nJvChannelID, remoteOperationCommand, NULL, 4);
}

/**
 *  远程发送的命令
 *
 *  @param nJvChannelID               控制本地连接的通道号
 *  @param remoteOperayionType        控制的类型
 *  @param remoteOperationCommandData 控制的内容
 */
-(void)remoteSendDataToDevice:(int)nJvChannelID remoteOperationType:(int)remoteOperationType remoteOperationCommandData:(char *)remoteOperationCommandData {
    
    JVC_SendData(nJvChannelID, remoteOperationType, (unsigned char *)remoteOperationCommandData, strlen(remoteOperationCommandData));
}

/**
 *  远程回放快进
 *
 *  @param nJvChannelID           本地连接的通道号
 *  @param remoteOperayionCommand 控制的命令
 */
-(void)remotePlaybackSEEK:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand{
    
    unsigned long frameNumber=remoteOperationCommand;
    
    JVC_SendData(nJvChannelID, JVN_CMD_PLAYSEEK, (Byte*)&frameNumber, 4);
}

/**
 *  获取设备的网络配置信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteDeviceNetworkInfo:(int)nJvChannelID{
    
    PAC	g_stPacket;
    
    memset(&g_stPacket, 0, sizeof(PAC));
    g_stPacket.nPacketType	= RC_LOADDLG;
    g_stPacket.nPacketID	= IPCAM_NETWORK;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&g_stPacket, 8);
}

/**
 *  获取设备附近的网络热点信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteDeviceAplistInfo:(int)nJvChannelID{
    
    PAC	g_stPacket;
    memset(&g_stPacket, 0, sizeof(PAC));
    g_stPacket.nPacketType	= RC_EXTEND;
    g_stPacket.nPacketCount	= RC_EX_NETWORK;//IPCAM_NETWORK;
    
    EXTEND *m_pstExt = (EXTEND*)g_stPacket.acData;
    m_pstExt->nType  = EX_WIFI_AP;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&g_stPacket, 8);
}
//获取基本信息
-(void)RemoteGetBasicInfo:(int)nJvChannelID{
    PAC	g_stPacket;
    memset(&g_stPacket, 0, sizeof(PAC));
    
    g_stPacket.nPacketType	= RC_GETPARAM;

    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&g_stPacket, 8);
}
/**
 *  格式化SD卡
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteFormatSD:(int)nJvChannelID{
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType	= RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_STORAGE;
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;
    m_pstExt->nType		= EX_STORAGE_FORMAT;
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC *)&m_stPacket, 20);
    
    
}

/**
 *  停止录像
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteStopVedio:(int)nJvChannelID{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_STORAGE;
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;

    m_pstExt->nType		= EX_STORAGE_REC;
//    char acBuffer[256]={0};
//    sprintf(acBuffer,"%s=%d;",[@"rebRecEnable" UTF8String],0);
//    sprintf(m_pstExt->acData, "%s",acBuffer);
    sprintf(m_pstExt->acData,
            "bRecEnable=%d;"
            "bRecAlarmEnable=%d;"
            ,0,0);
    //0是停止录像，1开启录像，如果只是停止录像的话，其他的字段可以不传
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC *)&m_stPacket, 20+strlen(m_pstExt->acData));
    [self RemoteGetBasicInfo:nJvChannelID];
    
}
/**
 *  停止旧设备录像
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteStopOldVedio:(int)nJvChannelID{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_STORAGE;
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;
    m_pstExt->nType		= EX_STORAGE_REC_OFF;

    //0是停止录像，1开启录像，如果只是停止录像的话，其他的字段可以不传
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC *)&m_stPacket, 20+strlen(m_pstExt->acData));
    
}
/**
 *  开始旧设备录像
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteStartOldVedio:(int)nJvChannelID{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_STORAGE;
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;
    m_pstExt->nType		= EX_STORAGE_REC_ON;
    
    //0是停止录像，1开启录像，如果只是停止录像的话，其他的字段可以不传
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC *)&m_stPacket, 20+strlen(m_pstExt->acData));
    
}

-(void)RemoteAlarmVedio:(int)nJvChannelID{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_STORAGE;
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;
    m_pstExt->nType		= EX_STORAGE_SWITCH;
    
    sprintf(m_pstExt->acData,
            "storageMode=%d;",2);
 
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC *)&m_stPacket, 20+strlen(m_pstExt->acData));
    
}
-(void)RemoteManualVedio:(int)nJvChannelID{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_STORAGE;
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;
    m_pstExt->nType		= EX_STORAGE_SWITCH;
    
    sprintf(m_pstExt->acData,
            "storageMode=%d;",1);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC *)&m_stPacket, 20+strlen(m_pstExt->acData));
    
}

/**
 *  修改设备时间
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteSetDeviceTimerInfo:(int)nJvChannelID timerSting:(NSString *)timerString{
    
    PAC	g_stPacket;
    memset(&g_stPacket, 0, sizeof(PAC));
    g_stPacket.nPacketType	= RC_SETSYSTIME;
    
    char acBuffer[256]={0};
    sprintf(acBuffer,"%s",[timerString UTF8String]);
      memcpy(g_stPacket.acData,acBuffer, strlen(acBuffer));
   JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&g_stPacket, 4+strlen(g_stPacket.acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];

}
/**
 *  获取SD卡信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteGetSDInfo:(int)nJvChannelID{
    
    
    //发送消息，刷新SD卡信息
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType	= RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_STORAGE;
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;
    
    m_pstExt->nType		= EX_STORAGE_REFRESH;
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20);
    
    
}
-(void)RemoteReadSensitivity:(int)nJvChannelID{
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType	= RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_MDRGN;//扩展包数量
    //扩展消息类型
    //
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;
    m_pstExt->nType	= EX_MDRGN_UPDATE;
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20);

}

/**
 * 设置移动侦测灵敏度
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteSetSensitivity:(int)nJvChannelID alarmSting:(NSString *)alarmString{
    static PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType	= RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_MDRGN;//扩展包数量
    
    EXTEND * m_pstExt = (EXTEND *)m_stPacket.acData;
    //数据
    int nOffset=0;
    char acBuffer[256]={0};
    sprintf(acBuffer, "%s",[alarmString UTF8String]);

    strcpy(m_pstExt->acData, acBuffer);
   // strcat(m_stPacket.acData+nOffset, acBuffer);
    
    //扩展消息类型
    //
    m_pstExt->nType	= EX_MDRGN_SUBMIT;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
  
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}


/**
 *  获取设备的码流信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteWithDeviceGetFrameParam:(int)nJvChannelID {
    
    PAC	g_stPacket;
    g_stPacket.nPacketType	   = RC_LOADDLG; //0x05
    g_stPacket.nPacketID	   = IPCAM_STREAM;
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&g_stPacket, 8);
}

/**
 *  获取设备的云台信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteWithDeviceGetYTSpeedParam:(int)nJvChannelID {
    
    PAC	g_stPacket;
    g_stPacket.nPacketType	   = RC_LOADDLG; //0x05
    g_stPacket.nPacketID	   = IPCAM_PTZ;
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&g_stPacket, 8);
}

/**
 *	改变主控画质
 *
 *	@param	nStreamType	1:高清 2:标清 3:流畅
 */
-(void)RemoteWithDeviceSetFrameParam:(int)nJvChannelID  withStreamType:(int)nStreamType{
    
    PAC	m_stPacket;
     memset(&m_stPacket, 0, sizeof(PAC));
    
    m_stPacket.nPacketType=RC_SETPARAM;
    
    int nOffset=0;
    char acBuffer[256]={0};

    sprintf(acBuffer, "%s=%d;",[kDeviceMobileFrameFlagKey UTF8String],nStreamType);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
}

/**
 *  老版本主控的码流切换
 *
 *  @param nJvChannelID 本地连接的通道
 *  @param nStreamType  nStreamType	 2:标清 3:流畅
 */
-(void)RemoteWithOldDeviceSetFrameParam:(int)nJvChannelID  withStreamType:(int)nStreamType {
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    
    m_stPacket.nPacketType=RC_SETPARAM;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "[CH2];");
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "width=%d;",nStreamType == JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIF ? JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFWidth:JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Width);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "height=%d;",nStreamType == JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIF ? JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFHeight:JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Height);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "framerate=%d;",nStreamType == JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1 ? JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Framerate : JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFFramerate);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "nMBPH=%d;",JVCCloudSEENetworkMacroOldHomeIPCStreamTypeMBPH);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
}

/**
 *  老版本主控的码流切换
 *
 *  @param nJvChannelID 本地连接的通道
 *  @param nStreamType  nStreamType	 2:标清 3:流畅
 */
-(void)RemoteWithOldDeviceSetMainFrameParam:(int)nJvChannelID  withStreamType:(int)nStreamType {
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    
    m_stPacket.nPacketType=RC_SETPARAM;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "[CH1];");
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    int nHeight     = 0;
    int nWidth      = 0;
    int nFramerate  = JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFFramerate;
    int nRcModel    = 1;
    int nMBPH       = JVCCloudSEENetworkMacroOldHomeIPCStreamTypeMBPH;
    
    switch (nStreamType) {
            
        case JVCCloudSEENetworkMacroOldHomeIPCStreamType720P:{
            
            nHeight    = JVCCloudSEENetworkMacroOldHomeIPCStreamType720PHeight;
            nWidth     = JVCCloudSEENetworkMacroOldHomeIPCStreamType720PWidth;
            nFramerate = JVCCloudSEENetworkMacroOldHomeIPCStreamType720PFramerate;
            nMBPH      = JVCCloudSEENetworkMacroOldHomeIPCStreamType720MBPH;
        }
             break;
        case JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1:{
            
            nHeight    = JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Height;
            nWidth     = JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Width;
            nFramerate = JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Framerate;
        }
            break;
            
        case JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIF:{
            
            nHeight    = JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFHeight;
            nWidth     = JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFWidth;
        }
            break;
            
        default:
            break;
    }
    
    sprintf(acBuffer, "width=%d;",nWidth);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "height=%d;",nHeight);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "framerate=%d;",nFramerate);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "nMBPH=%d;",nMBPH);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    
    sprintf(acBuffer, "rcMode=%d;",nRcModel);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
}


/**
 *  获取老的AP配置结果的信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteGetApOldsetResult:(int)nJvChannelID{
    
    PAC	m_stPacket;
    
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_NETWORK;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    
    m_pstExt->acData[0]=0;
   // m_pstExt->nType=EX_NW_GETRESULT;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_pstExt->acData));
}

/**
 *  远程下载文件接口
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param path         下载的路径
 */
-(void)RemoteDownloadFile:(int)nJvChannelID withDownloadPath:(char *)path{


    JVC_SendData(nJvChannelID,JVN_CMD_DOWNLOADSTOP, NULL, 0);
    
    JVC_SendData(nJvChannelID,JVN_REQ_DOWNLOAD, path, strlen(path));
}

/**
 *  设置设备的对讲模式
 *
 *  @param deviceTalkModelType 0:设备采集 不播放声音 1:设备播放声音，不采集声音
 */
-(void)RemoteSetDeviceWithTalkModel:(int)nJvChannelID  withDeviceTalkModel:(int)nModelType{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_SETPARAM;
    int nOffset=0;
    char acBuffer[256]={0};
    sprintf(acBuffer, "%s=%d;",[kDeviceTalkModelFlagKey UTF8String],nModelType);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
}

/**
 *  设置有线网络
 *
 *  @param nJvChannelID      本地连接的通道号
 *  @param nIsEnableDHCP     是否启用自动获取 1:启用 0:手动输入
 *  ************以下参数手动输入时才生效*********************
 *  @param strIpAddress      ip地址
 *  @param strSubnetMaskIp   子网掩码
 *  @param strDefaultGateway 默认网关
 *  @param strDns            DNS服务器地址
 */
-(void)RemoteSetWiredNetwork:(int)nJvChannelID nIsEnableDHCP:(int)nIsEnableDHCP strIpAddress:(NSString *)strIpAddress strSubnetMask:(NSString *)strSubnetMask strDefaultGateway:(NSString *)strDefaultGateway strDns:(NSString *)strDns{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_NETWORK;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->acData[0]=0;
    m_pstExt->nType=EX_NW_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "ACTIVED=%d;", NetWorkType_Wired);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "bDHCP=%d;", nIsEnableDHCP);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    if(!nIsEnableDHCP){
        
        u_int32_t _uip=inet_addr((const char*)[strIpAddress UTF8String]);
        
        sprintf(acBuffer, "nlIP=%d;", HTONL(_uip));
        strcat(m_pstExt->acData+nOffset, acBuffer);
        nOffset += strlen(acBuffer);
        
        u_int32_t _uNM=inet_addr((const char*)[strSubnetMask UTF8String]);
        
        sprintf(acBuffer, "nlNM=%d;",HTONL(_uNM));
        strcat(m_pstExt->acData+nOffset, acBuffer);
        nOffset += strlen(acBuffer);
        
        u_int32_t _uGW=inet_addr((const char*)[strDefaultGateway UTF8String]);
        
        sprintf(acBuffer, "nlGW=%d;",HTONL(_uGW));
        strcat(m_pstExt->acData+nOffset, acBuffer);
        nOffset += strlen(acBuffer);
        
        u_int32_t _uDns=inet_addr((const char*)[strDns UTF8String]);
        
        sprintf(acBuffer, "nlDNS=%d;",HTONL(_uDns));
        strcat(m_pstExt->acData+nOffset, acBuffer);
    }
//    DDLogVerbose(@"%s-----dadadadad-----%s",__FUNCTION__,m_pstExt->acData);
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
}

/**
 *  配置设备的无线网络(老的配置方式)
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param strSSIDName     配置的热点名称
 *  @param strSSIDPassWord 配置的热点密码
 *  @param strWifiAuth     热点的认证方式
 *  @param strWifiEncryp   热点的加密方式
 */
-(void)RemoteOldSetWiFINetwork:(int)nJvChannelID strSSIDName:(NSString *)strSSIDName strSSIDPassWord:(NSString *)strSSIDPassWord strWifiAuth:(NSString *)strWifiAuth strWifiEncrypt:(NSString *)strWifiEncrypt{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_NETWORK;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->acData[0]=0;
    m_pstExt->nType=EX_NW_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "ACTIVED=%d;", NetWorkType_WiFi);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "WIFI_ID=%s;", [strSSIDName UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "WIFI_PW=%s;",[strSSIDPassWord UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "WIFI_AUTH=%s;",[strWifiAuth UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "WIFI_ENC=%s;",[strWifiEncrypt UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
}

/**
 *  配置设备的无线网络(新的配置方式)
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param strSSIDName     配置的热点名称
 *  @param strSSIDPassWord 配置的热点密码
 *  @param nWifiAuth       热点的认证方式
 *  @param nWifiEncryp     热点的加密方式
 */
-(void)RemoteNewSetWiFINetwork:(int)nJvChannelID strSSIDName:(NSString *)strSSIDName strSSIDPassWord:(NSString *)strSSIDPassWord nWifiAuth:(int)nWifiAuth nWifiEncrypt:(int)nWifiEncrypt{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_NETWORK;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->acData[0]=0;
    m_pstExt->nType=EX_WIFI_AP_CONFIG;
    
    WIFI_INFO wifi_info;
    memset(&wifi_info, 0, sizeof(WIFI_INFO));
    
    snprintf(wifi_info.wifiSsid, sizeof(wifi_info.wifiSsid),"%s", [strSSIDName UTF8String]);
    snprintf(wifi_info.wifiPwd,  sizeof(wifi_info.wifiPwd),"%s" , [strSSIDPassWord UTF8String]);
    
    wifi_info.wifiAuth   = nWifiAuth;
    wifi_info.wifiEncryp = nWifiEncrypt;
    
    wifi_info.wifiChannel=0;
    wifi_info.wifiIndex=0;
    wifi_info.wifiRate=0;
    
    memcpy(m_pstExt->acData, &wifi_info, sizeof(WIFI_INFO));
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+sizeof(WIFI_INFO));
}

/**
 *  绑定门磁或者手环设备
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param alarmType   设备类型 1:门磁；2：手环
 */
-(void)RemoteBindAlarmDevice:(int)nJvChannelID  withAddAlarmType:(int)alarmType{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_GPIN_ADD;
    int nOffset=0;
    char acBuffer[256]={0};
    sprintf(acBuffer, "%s=%d;",[kDeviceAlarmType UTF8String],alarmType);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
}

/**
 *   设置门磁属性
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param alarmEnable  设备打开状态 1:开；0；关
 *  @param alarmGuid    报警的唯一标示
 *  @param alarmType    报警的类型
 */
-(void)RemoteSetAlarmDeviceStatus:(int)nJvChannelID withAlarmEnable:(int )alarmEnable withAlarmGuid:(int)alarmGuid withAlarmType:(int)alarmType withAlarmName:(NSString *)alarmName;
{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_GPIN_SET;
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "enable=%d;", alarmEnable);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "guid=%d;", alarmGuid);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "type=%d;", alarmType);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "name=%s;", [alarmName UTF8String]);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);

    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
}

/**
 *  查询当前设备绑定的所有门磁或者手环设备集合
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteRequestAlarmDevice:(int)nJvChannelID
{
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType  =RC_GPIN_SELECT;
//    *((int*)m_stPacket.acData) =0;
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
}

/**
 *  查询当前设备绑定的所有门磁或者手环设备集合
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteDeleteAlarmDevice:(int)nJvChannelID
                    deviceType:(int)deviceType
                    deviceGuid:(int)deviceGuid
{
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_GPIN_DEL;
    int nOffset=0;
    char acBuffer[256]={0};

    sprintf(acBuffer, "%s=%d;",[kDeviceAlarmType UTF8String], deviceType);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "guid=%d;", deviceGuid);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);

    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
}

#pragma mark ----------- 报警相关设置

/**
 *  移动侦测打开（关闭）
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param nStatus      1：开 0：关闭
 */
-(void)RemoteSetMotionDetectingStatus:(int)nJvChannelID withStatus:(int)nStatus {

    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    
    m_stPacket.nPacketType  = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_MD;
    
    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType = EX_MD_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "%s=%d;",[kDeviceMotionDetecting UTF8String], nStatus);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}

/**
 *  婴儿啼哭打开（关闭）
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param nStatus      1：开 0：关闭
 */
-(void)RemoteSetBabyCryStatus:(int)nJvChannelID withStatus:(int)nStatus {
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    
    m_stPacket.nPacketType=RC_SETPARAM;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "%s=%d;",[kDeviceBabyCry UTF8String], nStatus);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const   char*)&m_stPacket, 20+strlen(m_stPacket.acData));
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];}


/**
 *  设备报警声音打开（关闭）
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param nStatus      1：开 0：关闭
 */
-(void)RemoteSetDeviceAlarmSoundStatus:(int)nJvChannelID withStatus:(int)nStatus {
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    
    m_stPacket.nPacketType  = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_ALARM;
    
    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType = EX_MD_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "%s=%d;",[kDeviceAlarmSound UTF8String], nStatus);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];}

/**
 *  安全防护打开（关闭）
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param nStatus      1：开 0：关闭
 */
-(void)RemoteSetAlarmStatus:(int)nJvChannelID withStatus:(int)nStatus {
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    
    m_stPacket.nPacketType = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_ALARM;
    
    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType = EX_ALARM_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "%s=%d;",[kDeviceAlarm UTF8String], nStatus);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}

/**
 *  安全防护时间段
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param strBeginTime  起始的时间
 *  @param strEndTime    结束的时间
 */
-(void)RemoteSetAlarmTime:(int)nJvChannelID withstrBeginTime:(NSString *)strBeginTime withStrEndTime:(NSString *)strEndTime{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    
    m_stPacket.nPacketType = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_ALARM;
    
    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType = EX_ALARM_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "%s=%s:00-%s:59;",[kDeviceAlarmTime0 UTF8String],[strBeginTime UTF8String],[strEndTime UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}




#pragma mark 设置图像反转
-(void)RemoteSetDeviceWithEffectModel:(int)nJvChannelID withEffectType:(int)nEffectType
{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_SENSOR;
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->nType=EX_MD_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "%s=%d;",[KEFFECTFLAG UTF8String],nEffectType);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
    
}

/**
 *  设置报警录像和手动录像
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param storageMode  类别
 */
-(void)RemoteSetDeviceWithStorageMode:(int)nJvChannelID withStorageMode:(int)storageMode {

    PAC m_stPacket;
    EXTEND *m_pstExt;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_STORAGE;
    m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->acData[0]=0;
    m_pstExt->nType=EX_STORAGE_SWITCH;
    
    int nOffset=0;
    char acBuffer[256]= {0};
    
    sprintf(acBuffer, "%s=%d;",[KStorageMode UTF8String],storageMode);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    JVC_SendData(nJvChannelID,JVN_RSP_TEXTDATA, (unsigned char*)&m_stPacket, 20+strlen(m_pstExt->acData));
}

#pragma mark --------------  惠通设备的定制接口 （闪光灯 、AP/STA、时区，P/N制式切换）

/**
 *  设置设备的闪光灯
 *
 *  @param nJvChannelID 本地连接的通道号
 *  @param nFlashMode  闪光灯的类型
 
     enum JVCCloudSEENetworkDeviceFlashMode{
     
     JVCCloudSEENetworkDeviceFlashModeAuto  = 0,  //自动
     JVCCloudSEENetworkDeviceFlashModeOpen  = 1,  //打开
     JVCCloudSEENetworkDeviceFlashModeClose = 2   //关闭
     
     };
 */
-(void)RemoteSetDeviceWithFlashMode:(int)nJvChannelID withFlashMode:(int)nFlashMode{
    
    PAC	m_stPacket;
    
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_SETPARAM;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "%s=%d;",[kDeviceFlashMode UTF8String],nFlashMode);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_stPacket.acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}

/**
 *  设置AP的工作方式
 *
 *  @param nJvChannelID  本地连接的通道号
 *  @param nAPModel      STA/AP
 
     enum JVCCloudSEENetworkDeviceAPMode{
     
     JVCCloudSEENetworkDeviceAPModeSta = 0,  STA模式
     JVCCloudSEENetworkDeviceAPModeAP  = 1,  AP模式
     
     
     };
 */
-(void)RemoteSetDeviceWithAPMode:(int)nJvChannelID withAPModel:(int)nAPModel{
    
    PAC	m_stPacket;
    
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_SETPARAM;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "%s=%d;",[kDeviceApModeOn UTF8String],nAPModel);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_stPacket.acData));
    
}

/**
 *  设置设备时区
 *
 *  @param nJvChannelID  本地通道号
 *  @param nTimezone     设备的时区
 */
-(void)RemoteSetDeviceWithTimezone:(int)nJvChannelID withTimezone:(int)nTimezone{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_SETPARAM;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer,"%s=%d;",[kDeviceTimezone UTF8String],nTimezone);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer,"%s=1;",[@"bSntp" UTF8String]);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}

/**
 *  设置设备的画面制式
 *
 *  @param nJvChannelID  本地通道号
 *  @param nPNMode       设备画面的制式
 
     enum JVCCloudSEENetworkDevicePNModeType {
     
     JVCCloudSEENetworkDevicePNModeTypeP = 0, //P制式
     JVCCloudSEENetworkDevicePNModeTypeN = 1, //N
     };
 */
-(void)RemoteSetDeviceWithPNMode:(int)nJvChannelID withPNMode:(int)nPNMode{
    
    PAC	m_stPacket;
    
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_SETPARAM;
    
    int nOffset=0;
    char acBuffer[256]={0};
    sprintf(acBuffer,"%s=%d;",[kDevicePNMode UTF8String],nPNMode);
    strcat(m_stPacket.acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}

/**
 *  惠通闪光灯抓拍图片
 *
 *  @param nJvChannelID 本地通道号
 */
-(void)RemoteDeviceWithCapture:(int)nJvChannelID{

    PAC	m_stPacket;
    
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_FlashJpeg;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->acData[0]=0;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_pstExt->acData));

}

/**
 *  修改设备的用户名密码
 *
 *  @param nJVChannleID 本地连接的通道号
 *  @param userName     用户名
 *  @param passWord     密码
 */
- (void)RemoteModifyDeviceInfo:(int)nJVChannleID  withUserName:(NSString *)userName withPassWord:(NSString *)passWord describe:(NSString *)describe
{
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType  = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_ACCOUNT;

    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType = EX_ACCOUNT_MODIFY;
    m_pstExt->nParam1 = POWER_ADMIN;

    char acBuffer[SIZE_PW+SIZE_ID+SIZE_DESCRIPT]={0};
    
    memcpy(acBuffer, [userName UTF8String], SIZE_ID);
    memcpy(acBuffer+SIZE_ID, [passWord UTF8String], SIZE_PW);
    memcpy(acBuffer+SIZE_ID+SIZE_PW, [describe UTF8String], SIZE_DESCRIPT);

    
    memcpy(m_pstExt->acData, acBuffer,SIZE_PW+SIZE_ID+SIZE_DESCRIPT);

    JVC_SendData(nJVChannleID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+sizeof(acBuffer));
}

/**
 *  获取设备的用户名密码
 *
 *  @param nJVChannleID 本地的id
 */
- (void)getModifyDeviceList:(int)nJVChannleID
{
    PAC	m_stPacket;
    
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType  = RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_ACCOUNT;
    
    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType = EX_ACCOUNT_REFRESH;
    
    JVC_SendData(nJVChannleID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_pstExt->acData));
}


/**
 *  设置是否开启网络校时
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteSetDeviceNetTimer:(int)nJvChannelID
                    deviceType:(int)deviceType
                    deviceGuid:(int)deviceGuid
{
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_SETPARAM;
    char acBuffer[256]={0};
    sprintf(acBuffer, "bSntp=%d;", deviceGuid);
    strcat(m_stPacket.acData, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_stPacket.acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}
/**
 *  设置邮件报警开关
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteSetDeviceEmailStatus:(int)nJvChannelID
                       deviceType:(int)deviceType
                       deviceGuid:(int)deviceGuid
{
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_MD;
    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType = EX_MDRGN_SUBMIT;
    char acBuffer[256]={0};
    sprintf(acBuffer,"%s=%d;",[kDeviceEmailStatus UTF8String],deviceGuid);
    sprintf(m_pstExt->acData, "[ALL];%s",acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}
/**
 *  发送测试邮件
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteSendDeviceEmailInfo:(int)nJvChannelID dictInfo:(NSDictionary *)dictInfo{
    NSArray *array=[[NSArray alloc]initWithObjects:@"acMailSender",@"acSMTPServer",@"acSMTPUser",@"acSMTPPasswd",@"acSMTPort",@"acSMTPCrypto",@"acReceiver0",@"acReceiver1",@"acReceiver2",@"acReceiver3", nil];
    NSString *string = @"";
    for (int i=0; i<array.count; i++) {
        string=[string stringByAppendingString:array[i]];
        string=[string stringByAppendingFormat:@"=%@;",dictInfo[array[i]]];
    }
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType	= RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_ALARM;
    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType=EX_ALARM_TEST;
    sprintf(m_pstExt->acData, "[ALL];%s",[string UTF8String]);
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC *)&m_stPacket, 20+strlen(m_pstExt->acData));
    [array release];
    //    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}


/**
 *  设置报警邮件
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteSetDeviceEmailInfo:(int)nJvChannelID dictInfo:(NSDictionary *)dictInfo{
    NSArray *array=[[NSArray alloc]initWithObjects:@"acMailSender",@"acSMTPServer",@"acSMTPUser",@"acSMTPPasswd",@"acSMTPort",@"acSMTPCrypto",@"acReceiver0",@"acReceiver1",@"acReceiver2",@"acReceiver3", nil];
    NSString *string = @"";
    for (int i=0; i<array.count; i++) {
        string=[string stringByAppendingString:array[i]];
        string=[string stringByAppendingFormat:@"=%@;",dictInfo[array[i]]];
    }
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType	= RC_EXTEND;
    m_stPacket.nPacketCount = RC_EX_ALARM;
    EXTEND *m_pstExt = (EXTEND*) (m_stPacket.acData);
    m_pstExt->nType=EX_ALARM_SUBMIT;
    sprintf(m_pstExt->acData, "[ALL];%s",[string UTF8String]);
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC *)&m_stPacket, 20+strlen(m_pstExt->acData));
    [array release];
    [self RemoteWithDeviceGetFrameParam:nJvChannelID];
}

@end
