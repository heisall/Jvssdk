
//
//  JVCCloudSEENetworkHelper.m
//  CloudSEE_II
//  和云视通网络库对接的中转助手类
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCCloudSEENetworkHelper.h"
#import "JVCCloudSEENetworkInterface.h"
#import "JVNetConst.h"
#import "JVCCloudSEENetworkGeneralHelper.h"
#import "JVCCloudSEESendGeneralHelper.h"
#import "JVCVideoDecoderHelper.h"
#import "JVCRemotePlayBackWithVideoDecoderHelper.h"
//#import "JVCLogHelper.h"
#import "GlView.h"
#import "JVCStruct2Dic.h"
#import "JVCVideoDecoderInterface.h"
#import "JVCAudioCodecInterface.h"
#import "Jmp4pkg.h"

@interface JVCCloudSEENetworkHelper () {

    NSMutableString *remoteDownSavePath;
    BOOL            isInitSdk;            //YES:已经初始化过
}

/**
 *  云视通连接的回调函数
 *
 *  @param nLocalChannel    连接的本地通道号 从1开始
 *  @param uchType          连接的返回值
 *  @param pMsg             连接返回的信息
 */
void ConnectMessageCallBack(int nLocalChannel, unsigned char  uchType, char *pMsg);

/**
 *  云视通连接的视频回调函数
 *
 *  @param nLocalChannel    连接的本地通道号 从1开始
 *  @param uchType          视频数据类型（I、B、P等）
 *  @param pBuffer          H264 视频数据或音频数据
 *  @param nSize            视频数据大小
 *  @param nWidth           视频数据的宽
 *  @param nHeight          视频数据的高
 */
void VideoDataCallBack(int nLocalChannel,unsigned char uchType, char *pBuffer, int nSize,int nWidth,int nHeight);


/**
 *  文本聊天的回调函数
 *
 *  @param nLocalChannel   连接的本地通道号 从1开始
 *  @param uchType         文本聊天的数据类型
 *  @param pBuffer         文本聊天的数据
 *  @param nSize           文本聊天的数据大小
 */
void TextChatDataCallBack(int nLocalChannel,unsigned char uchType, char *pBuffer, int nSize);

/**
 *  语音对讲的回调函数
 *
 *  @param nLocalChannel  连接的本地通道号 从1开始
 *  @param uchType        音频数据数据类型
 *  @param pBuffer        音频数据
 *  @param nSize          音频数据大小
 */
void VoiceIntercomCallBack(int nLocalChannel, unsigned char uchType, char *pBuffer, int nSize);


/**
 *  远程回放检索文件的回调函数
 *
 *  @param nLocalChannel  连接的本地通道号 从1开始
 *  @param pBuffer        回放文件集合数据
 *  @param nSize          回放文件集合数据大小
 */
void RemoteplaybackSearchCallBack(int nLocalChannel,char *pBuffer, int nSize);


/**
 *  远程回放的回调函数
 *
 *  @param nLocalChannel  连接的本地通道号 从1开始
 *  @param uchType        远程连接的通道号 从1开始
 *  @param pBuffer        回放的音视频数据
 *  @param nSize          回放的音视频数据大小
 *  @param nWidth         回放的视频数据宽
 *  @param nHeight        回放的视频数据高
 *  @param nTotalFrame    回放的视频数据的总帧数
 */
void RemotePlaybackDataCallBack(int nLocalChannel, unsigned char uchType, char *pBuffer, int nSize, int nWidth, int nHeight, int nTotalFrame);

/**
 *  远程下载文件接口
 *
 *  @param nLocalChannel 连接的本地通道号 从1开始
 *  @param uchType       帧类型
 *  @param pBuffer       下载数据
 *  @param nSize         下载的大小
 *  @param nFileLen
 */
void RemoteDownLoadCallback(int nLocalChannel, unsigned char uchType, char *pBuffer, int nSize, int nFileLen);

@end


@implementation JVCCloudSEENetworkHelper

@synthesize ystNWHDelegate;
@synthesize ystNWRODelegate;
@synthesize ystNWADelegate;
@synthesize ystNWRPVDelegate;
@synthesize ystNWTDDelegate;
@synthesize videoDelegate;
@synthesize jvcCloudSEENetworkHelperCaptureDelegate;
@synthesize jvcCloudSEENetworkHelperDownLoadDelegate;

BOOL          isRequestTimeoutSecondFlag;            //远程请求用于跳出请求的标志位 TRUE  :跳出
BOOL          isRequestRunFlag;                      //远程请求用于正在请求的标志位 FALSE :执行结束
static NSString const *kCheckHomeFlagKey = @"MobileCH";
static NSString const *kCheckHomeModeByMicStatusKey = @"ModeByMicStatus";
static NSString const *kBindAlarmFlagKey = @"$";

FILE *downloadHandle = NULL;

JVCCloudSEEManagerHelper *jvChannel[kJVCCloudSEENetworkHelperWithConnectMaxNumber];
NSMutableArray           *amOpenGLViews;       //存放的与个jvChannel相同数量的OpenGL对象

static const int                 kDisconnectTimeDelay     = 500;  //单位毫秒
static JVCCloudSEENetworkHelper *jvcCloudSEENetworkHelper = nil;

BOOL  isCancelDownload;   //是否取消下载

/**
 *  单例
 *
 *  @return 返回JVCCloudSEENetworkHelper 单例
 */
+ (JVCCloudSEENetworkHelper *)shareJVCCloudSEENetworkHelper
{
    @synchronized(self)
    {
        if (jvcCloudSEENetworkHelper == nil) {
            
            jvcCloudSEENetworkHelper = [[self alloc] init ];
        }
        
        return jvcCloudSEENetworkHelper;
    }
    
    return jvcCloudSEENetworkHelper;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (jvcCloudSEENetworkHelper == nil) {
            
            jvcCloudSEENetworkHelper = [super allocWithZone:zone];
            
            return jvcCloudSEENetworkHelper;
        }
    }
    
    return nil;
}

/**
 *  初始化SDK
 *
 *  @param strLogPath     日志的路径
 *  @param isEnableHelper 是否启用小助手连接
 */
-(void)initCloudSEESdk:(NSString *)strLogPath withEnableHelper:(BOOL)isEnableHelper {
    
    
    if (!isInitSdk) {
        
        BOOL isCheckLogPathState = strLogPath.length > 0 ? YES : FALSE;
        int nLocStartPort=9200;
        BOOL local=YES;
        if (local) {
            nLocStartPort=0;
        }
        JVC_InitSDK(nLocStartPort,  (char *)[isCheckLogPathState == YES ? strLogPath : @"" UTF8String]);
        JVC_EnableLog(isCheckLogPathState);
        JVD04_InitSDK();
        JVD05_InitSDK();
        InitDecode();      //板卡语音解码
        InitEncode();      //板卡语音编解]
        JP_InitSDK(32 * 1024, 1);
        NSString *mtuValue=[[NSUserDefaults standardUserDefaults] objectForKey:@"kMtuValue"];
        int mtuValueInt;
        if (mtuValue.length==0||mtuValue==nil) {
            mtuValueInt=20000;
        }else{
            mtuValueInt=[mtuValue intValue];
            JVC_SetMTU(mtuValueInt);
        }
        JVC_EnableHelp(isEnableHelper,3);  //手机端是3
        //注册各种回调函数
        JVC_RegisterCallBack(ConnectMessageCallBack,VideoDataCallBack,RemoteplaybackSearchCallBack,VoiceIntercomCallBack,TextChatDataCallBack,RemoteDownLoadCallback,RemotePlaybackDataCallBack);
        
        isInitSdk = YES;
        
        amOpenGLViews = [[NSMutableArray alloc] initWithCapacity:10];
        
        //初始化OpenGL 画布
        for (int i=0; i<1; i++) {
            
            GlView *glView = [[GlView alloc] init:320.0 withdecoderHeight:240.0 withDisplayWidth:320.0 withDisplayHeight:240.0];
            [amOpenGLViews addObject:glView];
            [glView release];
        }
    }
}



/**
 *  网络获取设备的通道数
 *
 *  @param ystNumber 云视通号
 *  @param nTimeOut  请求超时时间
 *
 *  @return 设备的通道数
 */
-(int)WanGetWithChannelCount:(NSString *)ystNumber nTimeOut:(int)nTimeOut{
    
    int i;
    
    for (i=0; i<ystNumber.length; i++) {
        
        unsigned char c=[ystNumber characterAtIndex:i];
        
        if (c<='9' && c>='0') {
            
            break;
        }
    }
    
    NSString *sGroup=[ystNumber substringToIndex:i];
    NSString *iYstNum=[ystNumber substringFromIndex:i];
    
    return JVC_WANGetChannelCount([sGroup UTF8String],[iYstNum intValue],nTimeOut);
}

/**
 *  返回当前窗口对应的 jvChannel数组中的下标索引
 *
 *  @param nLocalChannel jvChannel数组中的下标索引
 *
 *  @return jvChannel数组中的下标索引
 */
-(int)returnCurrentChannelBynLocalChannelID:(int)nLocalChannel{
    
    return (nLocalChannel -1) % kJVCCloudSEENetworkHelperWithConnectMaxNumber;
}

/**
 *  返回是否有当前通道的链接状态
 *
 *  @param nLocalChannel Channel号
 *
 *  @return yes 有  no 没有
 */
- (BOOL)returnCurrentLintState:(int)nLocalChannel
{
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nLocalChannel];

    if (currentChannelObj !=nil) {
        
        return YES;
    }
    
    return NO;
}

/**
 *  返回当前nLocalChannel对应的显示窗口的编号
 *
 *  @param nLocalChannel 本地通道
 *
 *  @return nLocalChannel对应的显示窗口的编号
 */
-(int)returnCurrentChannelNShowWindowIDBynLocalChannel:(int)nLocalChannel{
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    int                nshowWindowNumber  = nLocalChannel;
    
    if ( currentChannelObj != nil ) {
        
        nshowWindowNumber  = currentChannelObj.nShowWindowID + 1;
    }
    
    return nshowWindowNumber;
}

/**
 *  检测当前窗口连接是否已存在
 *
 *  @param nLocalChannel nLocalChannel description
 *
 *  @return YES:存在 NO:不存在
 */
-(BOOL)checknLocalChannelExistConnect:(int)nLocalChannel {
    
    JVCCloudSEEManagerHelper *currentChannelObj = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if ( currentChannelObj != nil ) {
        
        if (nLocalChannel == currentChannelObj.nShowWindowID + 1) {
            
            return YES;
            
        }else {
            
            return FALSE;
        }
    }
    
    return FALSE ;
}

/**
 *  检测当前窗口视频是否已经显示
 *
 *  @param nLocalChannel nLocalChannel description
 *
 *  @return YES:存在 NO:不存在
 */
-(BOOL)checknLocalChannelIsDisplayVideo:(int)nLocalChannel {
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if ( currentChannelObj != nil ) {
        
        return currentChannelObj.isDisplayVideo;
    }
    
    return FALSE ;
}

/**
 *  根据本地通道号返回对应的JVCCloudSEEManagerHelper
 *
 *  @param nLocalChannel 本地通道号
 *
 *  @return 本地通道号返回对应的JVCCloudSEEManagerHelper
 */
-(JVCCloudSEEManagerHelper *)returnCurrentChannelBynLocalChannel:(int)nLocalChannel{
    
    int nJvchannelID = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    return jvChannel [nJvchannelID];
}

#pragma mark －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－远程连接功能模块

/**
 *   云视通连接视频的函数 (子线程调用)
 *
 *  @param nLocalChannel  本地连接的通道号 >=1
 *  @param nRemoteChannel 连接设备的通道号
 *  @param strYstNumber   设备的云视通号
 *  @param strUserName    连接设备通道的用户名
 *  @param strPassWord    连接设备通道的密码
 *  @param nSystemVersion 当前手机的操作系统版本
 *  @param isConnectShowVideo 是否显示图像
 *  @param showVew            视频显示的父类
 *
 *  @return 成功返回YES  重复连接返回NO
 */
-(BOOL)ystConnectVideobyDeviceInfo:(int)nLocalChannel nRemoteChannel:(int)nRemoteChannel strYstNumber:(NSString *)strYstNumber strUserName:(NSString *)strUserName strPassWord:(NSString *)strPassWord nSystemVersion:(int)nSystemVersion isConnectShowVideo:(BOOL)isConnectShowVideo withConnectType:(int)nConnectType withShowView:(UIView *)showVew{
    
    
    JVCCloudSEEManagerHelper *currentChannelObj        = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    int               nJvchannelID             = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    int               nJVCCloudSEEManagerHelper        = nJvchannelID+1;
    
    if (currentChannelObj  == nil || currentChannelObj.nShowWindowID != nLocalChannel -1 ) {
        
        if (currentChannelObj != nil && currentChannelObj.nShowWindowID != nLocalChannel -1 ) {
            
            
            [self disconnect:nJVCCloudSEEManagerHelper];
            
        }
        
        int             nYstNumber             = -1 ;
        
        NSString *strYstGroup ;
        
        [[JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper] getYstGroupStrAndYstNumberByYstNumberString:strYstNumber.uppercaseString strYstgroup:&strYstGroup nYstNumber:&nYstNumber];
        
//        if(jvChannel[nJvchannelID])
//            [jvChannel[nJvchannelID] release];
        jvChannel[nJvchannelID]                = [[JVCCloudSEEManagerHelper alloc] init];
        
        JVCCloudSEEManagerHelper *newCurrentChannelObj = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
        
        newCurrentChannelObj.jvConnectDelegate   = self;
        newCurrentChannelObj.nLocalChannel       = nJVCCloudSEEManagerHelper;
        newCurrentChannelObj.nRemoteChannel      = nRemoteChannel;
        newCurrentChannelObj.linkModel           = NO;
        newCurrentChannelObj.strYstGroup         = strYstGroup;
        newCurrentChannelObj.nYstNumber          = nYstNumber;
        newCurrentChannelObj.strUserName         = strUserName;
        newCurrentChannelObj.strPassWord         = strPassWord;
        newCurrentChannelObj.nShowWindowID       = nLocalChannel -1;
        newCurrentChannelObj.nSystemVersion      = nSystemVersion;
        newCurrentChannelObj.isConnectShowVideo  = isConnectShowVideo;
        newCurrentChannelObj.nConnectType        = nConnectType;
        newCurrentChannelObj.showView            = showVew;
        
        [newCurrentChannelObj connectWork];
        
        return TRUE;
        
    }else {
        
//        DDLogCWarn(@"%s---- （%d）连接已存在",__FUNCTION__,nLocalChannel);
        
        return FALSE;
    }
}

/**
 *  IP连接视频的函数 (子线程调用)
 *
 *  @param nLocalChannel  本地连接的通道号 >=1
 *  @param strUserName    连接设备通道的用户名
 *  @param strPassWord    连接设备通道的密码
 *  @param strRemoteIP    IP直连的IP地址
 *  @param nRemotePort    IP直连的端口号
 *  @param nSystemVersion 当前手机的操作系统版本
 *  @param isConnectShowVideo 是否显示图像
 *  @param showVew            视频显示的父类
 *
 *  @return  @return 成功返回YES  重复连接返回NO
 */

int count = 0;
-(BOOL)ipConnectVideobyDeviceInfo:(int)nLocalChannel nRemoteChannel:(int)nRemoteChannel  strUserName:(NSString *)strUserName strPassWord:(NSString *)strPassWord strRemoteIP:(NSString *)strRemoteIP nRemotePort:(int)nRemotePort
    nSystemVersion:(int)nSystemVersion isConnectShowVideo:(BOOL)isConnectShowVideo withConnectType:(int)nConnectType
                     withShowView:(UIView *)showVew
                         tcpState:(BOOL)tcpState;
{
    
    
    JVCCloudSEEManagerHelper *currentChannelObj        = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    int               nJvchannelID             = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    int               nJVCCloudSEEManagerHelper        = nJvchannelID+1;
    
    if ( currentChannelObj  == nil || currentChannelObj.nShowWindowID != nLocalChannel -1 ) {
        
        if ( currentChannelObj != nil && currentChannelObj.nShowWindowID != nLocalChannel -1 ) {
            
            [self disconnect:nJVCCloudSEEManagerHelper];
        }
        
        
        NSLog(@"-----alloc time %d---------",count++);
        jvChannel [nJvchannelID]                = [[JVCCloudSEEManagerHelper alloc] init];
        
        JVCCloudSEEManagerHelper *newCurrentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
        newCurrentChannelObj.jvConnectDelegate = self;
        newCurrentChannelObj.nLocalChannel      = nJVCCloudSEEManagerHelper;
        newCurrentChannelObj.nRemoteChannel     = nRemoteChannel;
        newCurrentChannelObj.strRemoteIP        = strRemoteIP;
        newCurrentChannelObj.nRemotePort        = nRemotePort;
        newCurrentChannelObj.linkModel          = YES;
        newCurrentChannelObj.strUserName        = strUserName;
        newCurrentChannelObj.strPassWord        = strPassWord;
        newCurrentChannelObj.nShowWindowID      = nLocalChannel -1;
        newCurrentChannelObj.nSystemVersion     = nSystemVersion;
        newCurrentChannelObj.isConnectShowVideo = isConnectShowVideo;
        newCurrentChannelObj.nConnectType       = nConnectType;
        newCurrentChannelObj.showView           = showVew;
        newCurrentChannelObj.isTcp              = tcpState;
        
        [newCurrentChannelObj connectWork];
        
        return TRUE;
        
    }else {
        
//        DDLogCWarn(@"%s---- （%d）连接已存在",__FUNCTION__,nLocalChannel);
        
        return FALSE;
    }
}

#pragma mark  断开连接

/**
 *  断开连接（子线程调用）
 *
 *  @param nLocalChannel 本地视频窗口编号
 *
 *  @return YSE:断开成功 NO:断开失败
 */
-(BOOL)disconnect:(int)nLocalChannel{
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj  != nil) {
        
        currentChannelObj.isRunDisconnect = YES;
        
//         [[JVCLogHelper shareJVCLogHelper] writeDataToFile:[NSString stringWithFormat:@"%s--start nLocalChannel=%d",__FUNCTION__,nLocalChannel] fileType:LogType_OperationPLayLogPath];
        //断开远程连接
        [currentChannelObj disconnect];
        
//        [[JVCLogHelper shareJVCLogHelper] writeDataToFile:[NSString stringWithFormat:@"%s--end nLocalChannel=%d",__FUNCTION__,nLocalChannel] fileType:LogType_OperationPLayLogPath];
        
        int nJvchannelID = nLocalChannel -1;
        
        while (true) {
            
            if (jvChannel[nJvchannelID] != nil) {
                
                usleep(kDisconnectTimeDelay);
                
            }else{
                
                break;
            }
        }
        
        return YES;
    }
    
    return YES;
}

#pragma mark －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－视频连接的回调处理

/**
 *  云视通连接的回调函数
 *
 *  @param nLocalChannel    连接的本地通道号 从1开始
 *  @param uchType          连接的返回值
 *  @param pMsg             连接返回的信息
 */
void ConnectMessageCallBack(int nLocalChannel, unsigned char  uchType, char *pMsg){
    
    if (pMsg==NULL||pMsg==nil) {
        
        pMsg="";
    }
    
    NSString *connectResultInfo=[[NSString alloc] initWithCString:pMsg encoding:NSUTF8StringEncoding];
    
//    [[JVCLogHelper shareJVCLogHelper] writeDataToFile:[NSString stringWithFormat:@"%s--connectType=%d,connectInfo=%@,nlcalChannel=%d",__FUNCTION__,uchType,connectResultInfo,nLocalChannel] fileType:LogType_OperationPLayLogPath];
//    DDLogCWarn(@"%s--connectType=%d,connectInfo=%@,nlcalChannel=%d",__FUNCTION__,uchType,connectResultInfo,nLocalChannel);
    [jvcCloudSEENetworkHelper runConnectMessageCallBackMath:connectResultInfo nLocalChannel:nLocalChannel connectResultType:uchType];
    
    [connectResultInfo release];
}

/**
 *  C函数与UI层桥接的返回回调
 *
 *  @param connectCallBackInfo 连接的返回信息
 *  @param nlocalChannel       连接返回的本地通道
 *  @param connectResultType   连接的返回类型
 */
-(void)runConnectMessageCallBackMath:(NSString *)connectCallBackInfo nLocalChannel:(int)nlocalChannel connectResultType:(int)connectResultType{
    
    [connectCallBackInfo retain];
    
    
    int               nJvchannelID       = [self returnCurrentChannelBynLocalChannelID:nlocalChannel];
    
    int               nshowWindowNumber  = [self returnCurrentChannelNShowWindowIDBynLocalChannel:nlocalChannel];
    
    if (self.ystNWHDelegate != nil && [self.ystNWHDelegate respondsToSelector:@selector(ConnectMessageCallBackMath:nLocalChannel:connectResultType:)]) {
        
        [[JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper] getConnectFailedDetailedInfoByConnectResultInfo:connectCallBackInfo conenctResultType:&connectResultType];
        
        [self.ystNWHDelegate ConnectMessageCallBackMath:connectCallBackInfo nLocalChannel:nshowWindowNumber connectResultType:connectResultType];
    }
    
    if (CONNECTRESULTTYPE_Succeed != connectResultType) {
        
        if (jvChannel[nJvchannelID] != nil) {
            
            //设置OpenGL画布
            
            if (jvChannel[nJvchannelID].showView) {
                
                [self performSelectorOnMainThread:@selector(hiddenOpenGLView:) withObject:[NSString stringWithFormat:@"%d",nJvchannelID] waitUntilDone:YES];
            }
            
            NSLog(@"exitQueue connectResultType %d",connectResultType);
            
            [jvChannel[nJvchannelID] exitQueue];
            [jvChannel[nJvchannelID] closeVideoDecoder];
           
            [jvChannel[nJvchannelID] release];
            jvChannel[nJvchannelID]=nil;
            NSLog(@"jv");
        }
    }
    
    [connectCallBackInfo release];
}

/**
 *  隐藏OpenGL的显示
 *
 *  @param strChannelNumber 通道号
 */
-(void)hiddenOpenGLView:(NSString *)strChannelNumber{
    
    int nJvchannelID   = [strChannelNumber intValue];
    JVCCloudSEEManagerHelper  *currentChannelObj  = jvChannel[nJvchannelID];
    
    GlView *glView = (GlView *)[amOpenGLViews objectAtIndex:nJvchannelID];
    
    if (currentChannelObj.isDisplayVideo) {
        
        [glView clearVideo];
    }
    
    [glView hiddenWithOpenGLView];

}

#pragma mark  视频数据的回调函数

/**
 *  云视通连接的视频回调函数
 *
 *  @param nLocalChannel    连接的本地通道号 从1开始
 *  @param uchType          视频数据类型（I、B、P等）
 *  @param pBuffer          H264 视频数据或音频数据
 *  @param nSize            视频数据大小
 *  @param nWidth           视频数据的宽
 *  @param nHeight          视频数据的高
 */
void VideoDataCallBack(int nLocalChannel,unsigned char uchType, char *pBuffer, int nSize,int nWidth,int nHeight){
    
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
//    if (uchType==0x04) {
//        printf("data type: %d\n",uchType);
//    }
    JVCCloudSEENetworkGeneralHelper *ystNetworkHelperCMObj = [JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper];
    
    JVCCloudSEEManagerHelper                    *currentChannelObj         = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];

    [currentChannelObj retain];
    
    JVCVideoDecoderHelper                       *JVCVideoDecoderHelperObj  = currentChannelObj.decodeModelObj;
    JVCRemotePlayBackWithVideoDecoderHelper     *playBackDecoderObj        = currentChannelObj.playBackDecoderObj;
    int                                          nOpenGLIndex              = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    if (currentChannelObj.isRunDisconnect) {
        
        [currentChannelObj release];
        [pool release];
        return;
    }
    
    switch (uchType) {
            
        case JVN_DATA_O:{
            
            if (pBuffer[0]!=0) {
                [currentChannelObj release];
                [pool release];
                return;
            }
    
            int startCode   = -1;
            int width       = -1;
            int height      = -1;
            int nAudioType  = 0;
            int wVideoCodecID = 1;
            
            //获取startCode 、宽、高
            [ystNetworkHelperCMObj getBufferOInInfo:pBuffer startCode:&startCode videoWidth:&width videoHeight:&height];
            
            currentChannelObj.nConnectDeviceType = [ystNetworkHelperCMObj checkConnectDeviceModel:startCode];
            
            currentChannelObj.nConnectStartCode  =  startCode;
            currentChannelObj.isNvrDevice        = [ystNetworkHelperCMObj checkDeviceIsNvrDevice:pBuffer];
            
            
            if (width != JVCVideoDecoderHelperObj.nVideoWidth || height != JVCVideoDecoderHelperObj.nVideoHeight) {
                
                /**
                 *  处理解码器对象
                 */
                JVCVideoDecoderHelperObj.nVideoWidth          = width;
                JVCVideoDecoderHelperObj.nVideoHeight         = height;
                
                [jvcCloudSEENetworkHelper qualityChangeContinueRecoderVideo:nLocalChannel];
            }
            
            dispatch_async(dispatch_get_main_queue(),^{
                
                //设置OpenGL画布
                
                if (currentChannelObj.showView) {
                    
                    GlView *glView = (GlView *)[amOpenGLViews objectAtIndex:nOpenGLIndex];
                    [glView showWithOpenGLView];
                    [currentChannelObj.showView addSubview:glView._kxOpenGLView];
                    [glView updateDecoderFrame:currentChannelObj.showView.bounds.size.width displayFrameHeight:currentChannelObj.showView.bounds.size.height];
                }
            
            });
            
            
            JVCVideoDecoderHelperObj.dVideoframeFrate     = [ystNetworkHelperCMObj getPlayVideoframeFrate:startCode buffer_O:pBuffer buffer_O_size:nSize nAudioType:&nAudioType wVideoCodecID:&wVideoCodecID];
            
            JVCVideoDecoderHelperObj.isDecoderModel       = [ystNetworkHelperCMObj checkConnectDeviceEncodModel:startCode];
            
            JVCVideoDecoderHelperObj.isExistStartCode     = [ystNetworkHelperCMObj checkConnectVideoInExistStartCode:startCode buffer_O:pBuffer buffer_O_size:nSize];
            
            [currentChannelObj setAudioType:nAudioType];
            [currentChannelObj setVideoCodecID:wVideoCodecID];
            
            playBackDecoderObj.isDecoderModel    = JVCVideoDecoderHelperObj.isDecoderModel;
            playBackDecoderObj.isExistStartCode  = JVCVideoDecoderHelperObj.isExistStartCode;
            
            [currentChannelObj resetVideoDecoderParam];
            
            [currentChannelObj startPopVideoDataThread];
            
            if (jvcCloudSEENetworkHelper.ystNWHDelegate != nil && [jvcCloudSEENetworkHelper.ystNWHDelegate respondsToSelector:@selector(RequestTextChatCallback:withDeviceType:withIsNvrDevice:)]) {
                
                [jvcCloudSEENetworkHelper.ystNWHDelegate RequestTextChatCallback:currentChannelObj.nShowWindowID+1 withDeviceType:currentChannelObj.nConnectDeviceType withIsNvrDevice:currentChannelObj.isNvrDevice];
            }
            
            if (jvcCloudSEENetworkHelper.ystNWHDelegate != nil && [jvcCloudSEENetworkHelper.ystNWHDelegate respondsToSelector:@selector(RequestTextChatIs05DeviceCallback:withDeviceModel:)]) {
                
                [jvcCloudSEENetworkHelper.ystNWHDelegate RequestTextChatIs05DeviceCallback:currentChannelObj.nShowWindowID+1 withDeviceModel:JVCVideoDecoderHelperObj.isDecoderModel];
            }
            
        }
            break;
        case JVN_DATA_I:
        case JVN_DATA_B:
        case JVN_DATA_P:{
            
            
            if (currentChannelObj.isPlaybackVideo) {
                [currentChannelObj release];
                [pool release];
                return;
            }
            
            BOOL               isH264Data         = [ystNetworkHelperCMObj checkVideoDataIsH264:pBuffer];
            
            [currentChannelObj openVideoDecoder];
            
            if (isH264Data) {
                
                int bufferType = uchType;
                
                if (jvcCloudSEENetworkHelper.ystNWHDelegate != nil && [jvcCloudSEENetworkHelper.ystNWHDelegate respondsToSelector:@selector(H264VideoDataCallBackMath:withPlayBackFrametotalNumber:)]) {
                    
                    //偏移带帧头的数据和视频数据的大小以及获取当前的帧类型
                    [jvcCloudSEENetworkHelper videoDataInExistStartCode:&pBuffer isFrameOStartCode:JVCVideoDecoderHelperObj.isExistStartCode nbufferSize:&nSize nBufferType:&bufferType];
                
                    [currentChannelObj pushVideoData:(unsigned char *)pBuffer nVideoDataSize:nSize isVideoDataIFrame:bufferType==JVN_DATA_I isVideoDataBFrame:bufferType == JVN_DATA_B frameType:bufferType];
                    
                    //DDLogCInfo(@"%s---video",__FUNCTION__);
                    
                }else{
                    
//                    DDLogCVerbose(@"%s---H264VideoDataCallBackMath:imageBufferY:imageBufferU:imageBufferV:decoderFrameWidth:decoderFrameHeight:nPlayBackFrametotalNumber: callBack is Null",__FUNCTION__);
                }
                
                
            }else {
            
                unsigned int i_data =*(unsigned int *)(pBuffer+4);
                unsigned int uType = i_data & 0xF;
                
                if (uType < JVN_DATA_A) {
                    
                    unsigned int nLen = (i_data>>4) & 0xFFFFF;
                    
                    [currentChannelObj pushVideoData:(unsigned char *)pBuffer+8 nVideoDataSize:nLen isVideoDataIFrame:uType ==JVN_DATA_I isVideoDataBFrame:uType == JVN_DATA_B frameType:uType];
                    
                }
                
            }
        }
            break;
        case JVN_DATA_A:{
            
            if (!currentChannelObj.isAudioListening) {
                [currentChannelObj release];
                [pool release];
                return;
            }
                        
            [currentChannelObj pushAudioData:(unsigned char *)pBuffer nAudioDataSize:nSize];
        }
            break;
            
        default:
            break;
    }
    [currentChannelObj release];
    [pool release];
}

/**
 *  开启录像
 *
 *  @param nLocalChannel      连接的本地通道号
 *  @param saveLocalVideoPath 录像文件存放的地址
 */
-(void)openRecordVideo:(int)nLocalChannel saveLocalVideoPath:(NSString *)saveLocalVideoPath{
    
    JVCCloudSEEManagerHelper  *currentChannelObj = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    [currentChannelObj retain];
    [saveLocalVideoPath retain];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is null",__FUNCTION__,nLocalChannel);
        
        return;
    }
    [currentChannelObj openRecordVideo:saveLocalVideoPath];
    
    [saveLocalVideoPath release];
    [currentChannelObj release];
}

/**
 *  如果画质改变，正在录像重新打包继续录像
 */
-(void)qualityChangeContinueRecoderVideo:(int)nLocalChannel{
    
    JVCCloudSEEManagerHelper  *currentChannelObj = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is null",__FUNCTION__,nLocalChannel);
    }
    
    if (currentChannelObj.jvcRecodVideoHelper.isRecordVideo) {
        
        [self stopRecordVideo:nLocalChannel withIsContinueVideo:YES];
    }
}

/**
 *  关闭本地录像
 *
 *  @param nLocalChannel 本地连接的通道地址
 *  @param isContinue    是否停止后继续录像
 */
-(void)stopRecordVideo:(int)nLocalChannel withIsContinueVideo:(BOOL)isContinue{
    
    JVCCloudSEEManagerHelper  *currentChannelObj = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is null",__FUNCTION__,nLocalChannel);
        
        return;
    }
    
    [currentChannelObj stopRecordVideo];
    
    if (self.videoDelegate !=nil && [self.videoDelegate respondsToSelector:@selector(videoEndCallBack:)]) {
        
        [self.videoDelegate videoEndCallBack:isContinue];
    }
}


#pragma mark VideoDataCallBack 逻辑处理模块

/**
 *  判断视频数据是否包含帧头
 *
 *  @param videoBuffer       视频数据
 *  @param isFrameOStartCode O帧是否带帧头
 */
-(void)videoDataInExistStartCode:(char **)videoBuffer isFrameOStartCode:(int)isFrameOStartCode  nbufferSize:(int *)nbufferSize nBufferType:(int *)nBufferType{
    
    
    JVCCloudSEENetworkGeneralHelper *ystNetworkHelperCMObj = [JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper];
    
    char                                 *videdata              = *videoBuffer;
    
    int                                   bufferSize            = *nbufferSize;
    int                                   bufferType            = *nBufferType;
    
    if (! isFrameOStartCode || [ystNetworkHelperCMObj isKindOfBufInStartCode:videdata]) {
        
        if (!isFrameOStartCode ) {
            
            JVS_FRAME_HEADER *jvs_header = (JVS_FRAME_HEADER*)videdata;
            
            bufferSize = jvs_header->nFrameLens;
            bufferType = jvs_header->nFrameType;
            
        }else{
            
            bufferSize = bufferSize-8;
            
        }
        
        videdata   = videdata + 8;
    }
    
    *videoBuffer  = videdata;
    *nbufferSize  = bufferSize;
    *nBufferType  = bufferType;
}

#pragma mark 远程控制

/**
 *  远程控制指令
 *
 *  @param nLocalChannel          视频显示的窗口编号
 *  @param remoteOperationCommand 控制的命令
 */
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationCommand:(int)remoteOperationCommand{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper         *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
       // DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    
    switch (remoteOperationCommand) {
            
        case JVN_RSP_PLAYOVER:{
            
            [self RemotePlayBackVideoEndCallBack:remoteOperationCommand currentChannelObj:currentChannelObj];
            return;
        }
            break;
        case JVN_CMD_VIDEOPAUSE:
        case JVN_CMD_VIDEO:{
            
            BOOL isSendPlayVideoStatus = remoteOperationCommand == JVN_CMD_VIDEOPAUSE ; //YES 暂停
            
            BOOL isRemoteSend          = currentChannelObj.isVideoPause == isSendPlayVideoStatus; //如果已经是暂停状态就不发送了
            
            //注：当窗口每轮为最大16个 判断视频暂停和开始是当前窗口 currentChannelObj.nShowWindowID + 1 != nLocalChannel
            
            if (isRemoteSend || currentChannelObj.nShowWindowID + 1 != nLocalChannel) {
                
                return;
            }
            
            currentChannelObj.isVideoPause = isSendPlayVideoStatus;
            
            [currentChannelObj resetVideoDecoderParam];
            
        }
            break;
            
        case JVN_CMD_DOWNLOADSTOP:{
        
            isCancelDownload = TRUE;
        }
            break;
        default:
            break;
    }
    
    [ystRemoteOperationHelperObj RemoteOperationSendDataToDevice:currentChannelObj.nLocalChannel remoteOperationCommand:remoteOperationCommand];
}


/**
 *  远程控制指令(文本聊天)
 *
 *  @param nLocalChannel          视频显示的窗口编号
 *  @param dicCommand             控制的命令
 */
-(void)RemoteOperationAtTextChatSendDataToDevice:(int)nLocalChannel withDicCommand:(NSDictionary *)dicCommand{
    
    JVCCloudSEEManagerHelper         *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
        // DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    
   PAC m_stPacket = {0};
    
   [JVCStruct2Dic packetStrcutWithDic:dicCommand withStrcut:&m_stPacket];
    
    switch (m_stPacket.nPacketType) {
            
        case RC_EXTEND:{
            
             EXTEND *extend = (EXTEND *)m_stPacket.acData;
            
            JVC_SendData(currentChannelObj.nLocalChannel, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(extend->acData));
        
        }
            break;
        case EX_FIRMUP_REBOOT:{

              JVC_SendData(currentChannelObj.nLocalChannel, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_stPacket.acData));
            
        }
            break;
            
        default:{
        
            JVC_SendData(currentChannelObj.nLocalChannel, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 4+strlen(m_stPacket.acData));
        
        }
            break;
    }
}

/**
 *  远程控制指令
 *
 *  @param nLocalChannel          控制本地连接的通道号
 *  @param remoteOperationType    控制的类型
 *  @param remoteOperationCommand 控制的命令
 */
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommand:(int)remoteOperationCommand {
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    
    switch (remoteOperationType) {
            
        case RemoteOperationType_CaptureImage:{
            
            [currentChannelObj startWithCaptureImage];
        }
            break;
        case RemoteOperationType_SceneCapture:{
        
            [currentChannelObj startWithSceneImage];
        }
            break;
        case RemoteOperationType_AudioListening:{
            
            if (currentChannelObj.isAudioListening) {
                
                [currentChannelObj closeAudioDecoder];
                
            }else{
                [currentChannelObj openAudioDecoder];
            }
        }
        case RemoteOperationType_VoiceIntercom:{
            
            [ystRemoteOperationHelperObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommand:remoteOperationCommand];
           
            if (remoteOperationCommand == JVN_CMD_CHATSTOP) {
                
               // [self returnVoiceIntercomCallBack:currentChannelObj nVoiceInterStateType:VoiceInterStateType_End];
                [currentChannelObj closeVoiceIntercomDecoder];
            }
            
        }
            break;
        case RemoteOperationType_RemotePlaybackSEEK:
        case TextChatType_NetWorkInfo:
        case TextChatType_paraInfo:
        case TextChatType_ApList:
        case TextChatType_ApSetResult:
        case TextChatType_setStream:
        case TextChatType_setAlarmType:
        case TextChatType_getAlarmType:
        case TextChatType_EffectInfo:
        case TextChatType_StorageMode:
        case TextChatType_setOldStream:
        case TextChatType_setAlarm:
        case TextChatType_setMobileMonitoring:
        case TextChatType_setOldMainStream:
        case TextChatType_setDeviceAPMode:
        case TextChatType_setDeviceFlashMode:
        case TextChatType_setDevicePNMode:
        case TextChatType_setDeviceTimezone:
        case TextChatType_setDeviceNetTime:
        case TextChatType_setDeviceAlarmSound:
        case TextChatType_setDeviceBabyCry:
        case TextChatType_getDeviePTZSpeed:
        case TextChatType_Capture:{
            
            [ystRemoteOperationHelperObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommand:remoteOperationCommand];
        }
            break;
        case RemoteOperationType_TextChat:{
            
            [ystRemoteOperationHelperObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommand:remoteOperationCommand];
            
        }
            break;
        case TextChatType_setTalkModel:{
                        
            if (currentChannelObj.isVoiceIntercom) {
                
                 [currentChannelObj setVoiceIntercomMode:remoteOperationCommand];
                
                 [ystRemoteOperationHelperObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommand:remoteOperationCommand];
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark -设置设备时间和格式

-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandStr:(NSString *)remoteOperationCommand{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_setDeviceTimeFormat) {
        [ystRemoteOperationHelperObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommandStr:remoteOperationCommand];
    }

}
#pragma mark -格式化SD卡
-(void)FormatSDWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_FormatSD) {

        [ystRemoteOperationHelperObj FormatSDSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}


#pragma mark -停止录像

-(void)stopVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_stopVedio) {
        [ystRemoteOperationHelperObj stopVedioSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}
#pragma mark -停止旧设备录像

-(void)stopOldVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_stopOldVedio) {
        [ystRemoteOperationHelperObj stopOldVedioSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}
#pragma mark -开始旧设备录像

-(void)startOldVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_startOldVedio) {
        [ystRemoteOperationHelperObj startOldVedioSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}

#pragma mark -报警录像

-(void)AlarmVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_AlarmVedio) {
        [ystRemoteOperationHelperObj AlarmVedioSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}
#pragma mark -手动录像

-(void)ManualVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_ManualVedio) {
        [ystRemoteOperationHelperObj ManualVedioSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}


#pragma mark -获取SD卡信息

-(void)getSDInforWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_getDeviceSDCardInfo) {
        [ystRemoteOperationHelperObj SDSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}

#pragma mark -获取基本信息

-(void)getBasicInforWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_getBasicInfo) {
         [ystRemoteOperationHelperObj getBasicInfoRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}

#pragma mark -设置移动侦测灵敏度

-(void)remoteOperationSetSensitivityDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandStr:(NSString *)remoteOperationCommand{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_setSensitivity) {
        [ystRemoteOperationHelperObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommandSensitivityStr:remoteOperationCommand];
    }
    
}
#pragma mark -读取移动侦测灵敏度

-(void)remoteOperationReadSensitivityDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    if (remoteOperationType==TextChatType_readSensitivity) {
        [ystRemoteOperationHelperObj onlySendRemoteOperationSensitivity:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}







/**
 *  远程控制指令
 *
 *  @param nLocalChannel              视频显示的窗口编号
 *  @param remoteOperationType        控制的类型
 *  @param remoteOperationCommandData 控制的指令内容
 *  @param nRequestCount              请求的次数
 */
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandData:(char *)remoteOperationCommandData nRequestCount:(int)nRequestCount{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper         *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    
    while (isRequestRunFlag) {
        
        isRequestTimeoutSecondFlag = FALSE;
        usleep(500);
    }
    
    BOOL                      isTimeout       = FALSE;  //超时次数启用的标志位 YES:超时返回
    isRequestTimeoutSecondFlag                = TRUE;   //网路库返回结果跳出While 循环的标志 FALSE:跳出
    isRequestRunFlag                          = TRUE;
    
    while ( true ) {
        
        if (!isRequestTimeoutSecondFlag) {
            
            break;
        }
        
        if (nRequestCount > 0 ) {
            
            [ystRemoteOperationHelperObj remoteSendDataToDevice:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommandData:remoteOperationCommandData];
            
        }else {
            
            isTimeout =TRUE;
            break;
        }
        
        nRequestCount --;
        
        if (!isTimeout) {
            
            usleep(REQUESTTIMEOUTSECOND*1000*1000);
        }
    }
    
    isRequestRunFlag = FALSE;
    
    if (isTimeout) {
     
        
//        if (jvcCloudSEENetworkHelper.ystNWRPVDelegate != nil && [jvcCloudSEENetworkHelper.ystNWRPVDelegate respondsToSelector:@selector(remoteplaybackSearchFileListInfoCallBack:)]) {
//            
//            [jvcCloudSEENetworkHelper.ystNWRPVDelegate remoteplaybackSearchFileListInfoCallBack:nil];
//        }
    }
}

#pragma mark -----------------------------------------------------------－－－－－－－－语音对讲功能模块
/**
 *  语音对讲的回调函数
 *
 *  @param nLocalChannel  连接的本地通道号 从1开始
 *  @param uchType        音频数据数据类型
 *  @param pBuffer        音频数据
 *  @param nSize          音频数据大小
 */
void VoiceIntercomCallBack(int nLocalChannel, unsigned char uchType, char *pBuffer, int nSize){
    
    JVCCloudSEEManagerHelper  *currentChannelObj = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
//    NSLog(@"======111111111111111==========%s===%c==",__FUNCTION__,uchType);

    switch(uchType)
	{
        case JVN_REQ_CHAT:
            break;
            
        case JVN_RSP_CHATACCEPT:{
            
            [jvcCloudSEENetworkHelper returnVoiceIntercomCallBack:currentChannelObj nVoiceInterStateType:VoiceInterStateType_Succeed];
        }
            break;
            
        case JVN_CMD_CHATSTOP: {
            
            [jvcCloudSEENetworkHelper returnVoiceIntercomCallBack:currentChannelObj nVoiceInterStateType:currentChannelObj.isVoiceIntercom == YES?VoiceInterStateType_End:VoiceInterStateType_stop];
            
            break;
        }
        case JVN_RSP_CHATDATA:{
            
            if (!currentChannelObj.isVoiceIntercom) {
                
                return;
            }
            
            [currentChannelObj pushAudioData:(unsigned char *)pBuffer nAudioDataSize:nSize];
            
        }
        default:
            break;
	}
}

/**
 *  语音对讲回调处理
 *
 *  @param currentChannelObj    连接本地通道的对象
 *  @param nVoiceInterStateType 返回的类型
 */
-(void)returnVoiceIntercomCallBack:(JVCCloudSEEManagerHelper *)currentChannelObj nVoiceInterStateType:(int)nVoiceInterStateType{
    
    [currentChannelObj retain];
    
//    NSLog(@"\n================%s===%d==",__FUNCTION__,nVoiceInterStateType);
    
    if (self.ystNWADelegate !=nil && [self.ystNWADelegate respondsToSelector:@selector(VoiceInterComCallBack:)]) {
        
        [self.ystNWADelegate VoiceInterComCallBack:nVoiceInterStateType];
    }
    
    if (nVoiceInterStateType == VoiceInterStateType_Succeed) {
        
        [currentChannelObj openVoiceIntercomDecoder];
        
    }else{
        
        [currentChannelObj closeVoiceIntercomDecoder];
    }
    
    [currentChannelObj release];
}

#pragma mark －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－远程回放检索处理模块

/**
 *  远程回放检索文件的回调函数
 *
 *  @param nLocalChannel  连接的本地通道号 从1开始
 *  @param pBuffer        回放文件集合数据
 *  @param nSize          回放文件集合数据大小
 */
void RemoteplaybackSearchCallBack(int nLocalChannel,char *pBuffer, int nSize) {
    
    JVCCloudSEEManagerHelper  *currentChannelObj           = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
        return;
    }
    
    if (jvcCloudSEENetworkHelper.ystNWRPVDelegate != nil && [jvcCloudSEENetworkHelper.ystNWRPVDelegate respondsToSelector:@selector(remoteplaybackSearchFileListInfoCallBack:)]) {
        
        NSMutableArray   *mArrayRemotePlaybackFileList = [[NSMutableArray alloc] initWithCapacity:10];
        
        NSMutableArray *serachPlayBackListData = [currentChannelObj getRemoteplaybackSearchFileListInfoByNetworkBuffer:pBuffer remotePlaybackFileBufferSize:nSize];
        
        [serachPlayBackListData retain];
        [mArrayRemotePlaybackFileList addObjectsFromArray:serachPlayBackListData];
        [serachPlayBackListData release];
      //  isRequestRunFlag = true;
        [jvcCloudSEENetworkHelper.ystNWRPVDelegate remoteplaybackSearchFileListInfoCallBack:mArrayRemotePlaybackFileList];

        
        [mArrayRemotePlaybackFileList release];
    }
    
    isRequestTimeoutSecondFlag = FALSE;
}

#pragma mark －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－--远程回放处理模块

/**
 *  远程回放的回调函数
 *
 *  @param nLocalChannel  连接的本地通道号 从1开始
 *  @param uchType        远程连接的通道号 从1开始
 *  @param pBuffer        回放的音视频数据
 *  @param nSize          回放的音视频数据大小
 *  @param nWidth         回放的视频数据宽
 *  @param nHeight        回放的视频数据高
 *  @param nTotalFrame    回放的视频数据的总帧数
 */
void RemotePlaybackDataCallBack(int nLocalChannel, unsigned char uchType, char *pBuffer, int nSize, int nWidth, int nHeight, int nTotalFrame) {
    
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    
    JVCCloudSEENetworkGeneralHelper *ystNetworkHelperCMObj = [JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper];
    JVCCloudSEEManagerHelper                    *currentChannelObj     = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    JVCRemotePlayBackWithVideoDecoderHelper                *playBackDecoderObj    = currentChannelObj.playBackDecoderObj;
    
    if (currentChannelObj.isRunDisconnect) {
        
        [pool release];
        return;
    }

    switch (uchType) {
            
        case JVN_DATA_O:{
            
            int     width       = -1;
            int     height      = -1;
            double  frameRate   = 0 ;
            
            currentChannelObj.nConnectDeviceType         = currentChannelObj.nConnectDeviceType;
            
            playBackDecoderObj.nPlayBackFrametotalNumber = [ystNetworkHelperCMObj getRemotePlaybackTotalFrameAndframeFrate:pBuffer buffer_O_size:nSize videoWidth:&width videoHeight:&height dFrameRate:&frameRate];
            
            if (width != playBackDecoderObj.nVideoWidth || height != playBackDecoderObj.nVideoHeight) {
                
                /**
                 *  处理解码器对象
                 */
                playBackDecoderObj.nVideoWidth       = width;
                playBackDecoderObj.nVideoHeight      = height;
                [jvcCloudSEENetworkHelper qualityChangeContinueRecoderVideo:nLocalChannel];
            }
            
            playBackDecoderObj.dVideoframeFrate      = frameRate;
            
            [currentChannelObj resetVideoDecoderParam];
            currentChannelObj.isPlaybackVideo        = YES;
            ;
            
            [currentChannelObj startPopVideoDataThread];
            
            if (width > 0 && height >0) {
                
                if (jvcCloudSEENetworkHelper.ystNWRPVDelegate != nil && [jvcCloudSEENetworkHelper.ystNWRPVDelegate respondsToSelector:@selector(remoteplaybackState:)]) {
                    
                    [jvcCloudSEENetworkHelper.ystNWRPVDelegate remoteplaybackState:RemotePlayBackVideoStateType_Succeed];
                }
            }
        }
            break;
            
        case JVN_DATA_I:
        case JVN_DATA_B:
        case JVN_DATA_P:{
            
            
            if (!currentChannelObj.isPlaybackVideo) {
                //DDLogCVerbose(@"%s__stop",__FUNCTION__);
                
                [pool release];
                return;
            }
            
            BOOL               isH264Data      = [ystNetworkHelperCMObj checkVideoDataIsH264:pBuffer];
            
            [currentChannelObj openVideoDecoder];
            
            if (isH264Data) {
                
                int bufferType = uchType;
                
                if (jvcCloudSEENetworkHelper.ystNWHDelegate != nil && [jvcCloudSEENetworkHelper.ystNWHDelegate respondsToSelector:@selector(H264VideoDataCallBackMath:withPlayBackFrametotalNumber:)]) {
                    
                    //偏移带帧头的数据和视频数据的大小
                    [jvcCloudSEENetworkHelper videoDataInExistStartCode:&pBuffer isFrameOStartCode:playBackDecoderObj.isExistStartCode nbufferSize:&nSize nBufferType:&bufferType];
                    
                    [currentChannelObj pushVideoData:(unsigned char *)pBuffer nVideoDataSize:nSize isVideoDataIFrame:bufferType==JVN_DATA_I isVideoDataBFrame:bufferType==JVN_DATA_B frameType:uchType];
                    
                }else{
                    
//                    DDLogCVerbose(@"%s---H264VideoDataCallBackMath:imageBufferY:imageBufferU:imageBufferV:decoderFrameWidth:decoderFrameHeight:nPlayBackFrametotalNumber: callback is Null",__FUNCTION__);
                }
            }
            
        }
            break;
        case JVN_DATA_A:{
            
            if (!currentChannelObj.isAudioListening) {
                
                [pool release];
                return;
            }
            
            [currentChannelObj pushAudioData:(unsigned char *)pBuffer nAudioDataSize:nSize];
        }
            break;
        case JVN_RSP_PLAYE:
        case JVN_RSP_PLAYOVER:
        case JVN_RSP_PLTIMEOUT:{
        
            [jvcCloudSEENetworkHelper RemotePlayBackVideoEndCallBack:uchType currentChannelObj:currentChannelObj];
        }
            
        default:
            break;
    }
    
    [pool release];
}

/**
 *  远程回放请求文件视频
 *
 *  @param nLocalChannel           视频显示窗口编号
 *  @param requestPlayBackFileInfo 远程文件的信息
 *  @param requestPlayBackFileDate 远程文件的日期
 */
-(void)RemoteRequestSendPlaybackVideo:(int)nLocalChannel requestPlayBackFileInfo:(NSMutableDictionary *)requestPlayBackFileInfo  requestPlayBackFileDate:(NSDate *)requestPlayBackFileDate requestPlayBackFileIndex:(int)requestPlayBackFileIndex {
    
    [requestPlayBackFileInfo retain];
    [requestPlayBackFileDate retain];
    
   JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper                    *currentChannelObj               = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    char acBuff[150] = {0};
    
    //组合一条发送的远程回放文件的信息
    [currentChannelObj getRequestSendPlaybackVideoCommand:requestPlayBackFileInfo requestPlayBackFileDate:requestPlayBackFileDate nRequestPlayBackFileIndex:requestPlayBackFileIndex requestOutCommand:(char *)acBuff];
    
    [ystRemoteOperationHelperObj remoteSendDataToDevice:currentChannelObj.nLocalChannel remoteOperationType:JVN_REQ_PLAY remoteOperationCommandData:acBuff];
    
    [requestPlayBackFileDate release];
    [requestPlayBackFileInfo release];
}

/**
 *  远程回放请求文件视频
 *
 *  @param nLocalChannel           视频显示窗口编号
 *  @param withPlayBackPath        远程文件的路径
 */
-(void)RemoteRequestSendPlaybackVideo:(int)nLocalChannel withPlayBackPath:(NSString *)playBackVideoPath {
    
    [playBackVideoPath retain];
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper                    *currentChannelObj               = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    [ystRemoteOperationHelperObj remoteSendDataToDevice:currentChannelObj.nLocalChannel remoteOperationType:JVN_REQ_PLAY remoteOperationCommandData:(char *)[playBackVideoPath UTF8String]];
    
    [playBackVideoPath release];
}

/**
 *  回放结束的回调函数
 *
 *  @param nCallBackType     连接返回的类型
 */
-(void)RemotePlayBackVideoEndCallBack:(int)nCallBackType currentChannelObj:(JVCCloudSEEManagerHelper *)currentChannelObj{
    
    [currentChannelObj retain];
    
    [currentChannelObj resetVideoDecoderParam];
    currentChannelObj.isPlaybackVideo = FALSE;
    [currentChannelObj startPopVideoDataThread];
    
    int nRemotePlaybackVideoState = RemotePlayBackVideoStateType_End;
    
    switch (nCallBackType) {
            
        case JVN_RSP_PLAYE:
            nRemotePlaybackVideoState = RemotePlayBackVideoStateType_Failed;
            break;
        case JVN_RSP_PLTIMEOUT:
            nRemotePlaybackVideoState = RemotePlayBackVideoStateType_TimeOut;
            break;
            
        default:
            break;
    }
    
    if (self.ystNWRPVDelegate != nil && [self.ystNWRPVDelegate respondsToSelector:@selector(remoteplaybackState:)]) {
        
        [self.ystNWRPVDelegate remoteplaybackState:nRemotePlaybackVideoState];
    }
    
    [currentChannelObj release];
}

#pragma mark －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－--远程回放处理模块

/**
 *  文本聊天的回调函数
 *
 *  @param nLocalChannel   连接的本地通道号 从1开始
 *  @param uchType         文本聊天的数据类型
 *  @param pBuffer         文本聊天的数据
 *  @param nSize           文本聊天的数据大小
 */
void TextChatDataCallBack(int nLocalChannel,unsigned char uchType, char *pBuffer, int nSize){
    
    NSAutoreleasePool                    *pool             = [[NSAutoreleasePool alloc] init];
    
    JVCCloudSEENetworkGeneralHelper *ystNetworkHelperCMObj = [JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper];
       JVCCloudSEEManagerHelper     *currentChannelObj     = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    switch(uchType)
    {
        case JVN_RSP_TEXTACCEPT:
        case JVN_CMD_TEXTSTOP:{
            
            if (jvcCloudSEENetworkHelper.ystNWHDelegate != nil && [jvcCloudSEENetworkHelper.ystNWHDelegate respondsToSelector:@selector(RequestTextChatStatusCallBack:withStatus:)]) {
                
                [jvcCloudSEENetworkHelper.ystNWHDelegate RequestTextChatStatusCallBack:currentChannelObj.nShowWindowID+1 withStatus:uchType];
            }
        }
            break;
            
        case JVN_RSP_TEXTDATA:
        {
            
            if (nSize <=0) {
                
                [pool release];
                return;
            }
            
            PAC stpacket={0};
            
            memcpy(&stpacket, pBuffer, nSize);
          
            UInt32 packetAcDataOffset =0;
         
            if (stpacket.nPacketType == RC_LOADDLG) {
//                NSLog(@"*************1111111111111111*******");
                
                   memcpy(&packetAcDataOffset, stpacket.acData, 4);   //存放acData的偏移量目前只有pac包中nPacketType=RC_LOADDLG时需要做偏移操作
            }
            
            switch (stpacket.nPacketType) {
                case RC_GETPARAM:{
//                    NSLog(@"***============0010========");
                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                        NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData];
                        //                                NSMutableDictionary *params = [JVCStruct2Dic dicWithPacketStrcut:pBuffer withSize:nSize withOffset:packetAcDataOffset];
                        
                        [params retain];
                        
                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                        
                        [params release];
//                        NSLog(@"********params:%@******",params);
                    }

                }
                    break;
                case RC_LOADDLG:{
                    
                    switch (stpacket.nPacketID) {
                            
                        case IPCAM_NETWORK:{
                            
                            if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                
                                NSMutableDictionary *networkInfoMDic = [[NSMutableDictionary alloc] initWithCapacity:10];
                                
                                [networkInfoMDic addEntriesFromDictionary:[ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset]];
                                
                                [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_NetWorkInfo objYstNetWorkHelpSendData:networkInfoMDic];
                                
                                [networkInfoMDic release];
                            }
                        }
                            break;
                            
                        case IPCAM_STREAM:{
                            
                            if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                
                                NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];

                                [params retain];
                                
                                [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                                
                                [params release];
                            }
                            
                            if (jvcCloudSEENetworkHelper.ystNWRODelegate !=nil && [jvcCloudSEENetworkHelper.ystNWRODelegate respondsToSelector:@selector(deviceWithFrameStatus:withStreamType:withIsHomeIPC:withEffectType:withStorageType:withIsNewHomeIPC:withIsOldStreeamType:ytSpeed:MobileCH:ModeByMicStatus:deviceType:)]) {
                                
                                NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                                
                                [params retain];
                                
                                int  nStreamType    = -1;
                                BOOL isHomeIPC      = FALSE;
                                int  nEffectflag    = -1;
                                int  nStorageMode   = -1;
                                BOOL isNewHomeIPC   = FALSE;
                                int  nOldStreamType = -1;
                                
                                int  nPtzSpeedNum = -1;
                                
                                NSString *strDevice          = [[NSString alloc] initWithString:[ystNetworkHelperCMObj findBufferInExitValueToByKey:stpacket.acData+packetAcDataOffset nameBuffer:(char *)[kCheckHomeFlagKey UTF8String]]];
                                
                                int nMobileCh = MOBILECHDEFAULT;
                                
                                if (strDevice.intValue == MOBILECHSECOND) {
                                    
                                    nMobileCh = MOBILECHSECOND;
                                }
                                
//                                  NSLog(@"=======%@=====0001==",params);
                                
                                if ([params objectForKey:kDeviceHomeIPCFlag]) {
                                    
                                    nStreamType = [[params objectForKey:kDeviceMobileFrameFlagKey] intValue];
                                    isNewHomeIPC = YES;
                                    
                                }else{
                                    
                                    if ([params objectForKey:kDeviceFrameFlagKey]) {
                                        
                                        nStreamType = [[params objectForKey:kDeviceFrameFlagKey] intValue];
                                        
                                        if (nMobileCh == MOBILECHSECOND) {
                                            
                                            nStreamType = [jvcCloudSEENetworkHelper getOldHomeIPCStreamType: [ystNetworkHelperCMObj getFrameParamInfoByChannel:stpacket.acData+packetAcDataOffset nChannelValue:nMobileCh]];
                                        }
                                        
                                    }
                                }
                               
                                if ([params objectForKey:kCheckHomeFlagKey]) {
                                    
                                    int nMobileCH = [[params objectForKey:kCheckHomeFlagKey] intValue];
                                    
                                    if (nMobileCH == DEVICETYPE_HOME) {
                                        
                                        isHomeIPC = TRUE;
                                    }
                                }

                                if ([params objectForKey:KEFFECTFLAG]) {
                                        
                                    nEffectflag = [[params objectForKey:KEFFECTFLAG] intValue];
                                }
                                
                                if ([params objectForKey:KStorageMode]) {
                                    
                                    nStorageMode = [[params objectForKey:KStorageMode] intValue];
                                }
                                
                                if ([params objectForKey:kDeviceOldFrameFlagKey]) {
                                    
                                    nOldStreamType = [[params objectForKey:kDeviceOldFrameFlagKey] intValue];
                                }
                                
//                                currentChannelObj.isHomeIPC = isHomeIPC;
                                if(isHomeIPC)
                                {
                                    if ([params objectForKey:kDevicePTZSpeedFlagKey]) {
                                        
                                        nPtzSpeedNum = [[params objectForKey:kDevicePTZSpeedFlagKey] intValue];
                                    }else{
                                        
//                                        [ystNetworkHelperCMObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:TextChatType_getDeviePTZSpeed remoteOperationCommand:-1];

                                    
                                        [[JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper]  RemoteOperationSendDataToDevice:nLocalChannel remoteOperationType:TextChatType_getDeviePTZSpeed remoteOperationCommand:-1];

                                    }
                                }
                                
//                                [[JVCCloudSEENetworkHelper shareJVCCloudSEENetworkHelper]  RemoteOperationSendDataToDevice:nLocalChannel remoteOperationType:TextChatType_getDeviePTZSpeed remoteOperationCommand:-1];
                                int ModeByMicStatus=99;
                                int MobileCH=99;
                                if ([params objectForKey:kCheckHomeModeByMicStatusKey]) {
                                    ModeByMicStatus=[[params objectForKey:kCheckHomeModeByMicStatusKey] intValue];
                                }
                                if ([params objectForKey:kCheckHomeFlagKey]) {
                                    MobileCH=[[params objectForKey:kCheckHomeFlagKey] intValue];
                                }
                                isHomeIPC=currentChannelObj.nConnectDeviceType==4?YES:NO;
                                [jvcCloudSEENetworkHelper.ystNWRODelegate deviceWithFrameStatus:currentChannelObj.nShowWindowID+1 withStreamType:nStreamType withIsHomeIPC:isHomeIPC withEffectType:nEffectflag withStorageType:nStorageMode withIsNewHomeIPC:isNewHomeIPC withIsOldStreeamType:nOldStreamType ytSpeed:nPtzSpeedNum MobileCH:MobileCH ModeByMicStatus:ModeByMicStatus deviceType:currentChannelObj.nConnectDeviceType];
                                
                                [params release];
                                [strDevice release];
                                
                            }
                            
                        }
                            break;
                            
                    case IPCAM_PTZ:
                        {
//                            NSLog(@"================1111============");
                            
        
                                
                                if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                    
                                    NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                                    
                                    [params retain];
                                    
                                    [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                                    
                                    [params release];
                                }
                                
                                if (jvcCloudSEENetworkHelper.ystNWRODelegate !=nil && [jvcCloudSEENetworkHelper.ystNWRODelegate respondsToSelector:@selector(deviceWithFrameStatus:ytSpeed:)]) {
                                    
                                    NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                                    
                                    [params retain];
                                    
                                    int  nStreamType    = -1;
                                    BOOL isHomeIPC      = FALSE;
                                    int  nEffectflag    = -1;
                                    int  nStorageMode   = -1;
                                    BOOL isNewHomeIPC   = FALSE;
                                    int  nOldStreamType = -1;
                                    
                                    int  nPtzSpeedNum = -1;
                                    
                                    NSString *strDevice          = [[NSString alloc] initWithString:[ystNetworkHelperCMObj findBufferInExitValueToByKey:stpacket.acData+packetAcDataOffset nameBuffer:(char *)[kCheckHomeFlagKey UTF8String]]];
                                    
                                    int nMobileCh = MOBILECHDEFAULT;
                                    
                                    if (strDevice.intValue == MOBILECHSECOND) {
                                        
                                        nMobileCh = MOBILECHSECOND;
                                    }
                                    
//                                    NSLog(@"=======%@=====0002222==",params);
                                    
                                    if ([params objectForKey:kDeviceMobileFrameFlagKey]) {
                                        
                                        nStreamType = [[params objectForKey:kDeviceMobileFrameFlagKey] intValue];
                                        isNewHomeIPC = YES;
                                        
                                    }else{
                                        
                                        if ([params objectForKey:kDeviceFrameFlagKey]) {
                                            
                                            nStreamType = [[params objectForKey:kDeviceFrameFlagKey] intValue];
                                            
                                            if (nMobileCh == MOBILECHSECOND) {
                                                
                                                nStreamType = [jvcCloudSEENetworkHelper getOldHomeIPCStreamType: [ystNetworkHelperCMObj getFrameParamInfoByChannel:stpacket.acData+packetAcDataOffset nChannelValue:nMobileCh]];
                                            }
                                            
                                        }
                                    }
                                    
                                    if ([params objectForKey:kCheckHomeFlagKey]) {
                                        
                                        int nMobileCH = [[params objectForKey:kCheckHomeFlagKey] intValue];
                                        
                                        if (nMobileCH == DEVICETYPE_HOME) {
                                            
                                            isHomeIPC = TRUE;
                                        }
                                    }
                                    
                                    if ([params objectForKey:KEFFECTFLAG]) {
                                        
                                        nEffectflag = [[params objectForKey:KEFFECTFLAG] intValue];
                                    }
                                    
                                    if ([params objectForKey:KStorageMode]) {
                                        
                                        nStorageMode = [[params objectForKey:KStorageMode] intValue];
                                    }
                                    
                                    if ([params objectForKey:kDeviceOldFrameFlagKey]) {
                                        
                                        nOldStreamType = [[params objectForKey:kDeviceOldFrameFlagKey] intValue];
                                    }
                                    
                                    currentChannelObj.isHomeIPC = isHomeIPC;
                                    
                                    if(isHomeIPC)
                                    {
                                        if ([params objectForKey:kDeviceReGetPTZSpeedFlagKey]) {
                                            
                                            nPtzSpeedNum = [[params objectForKey:kDeviceReGetPTZSpeedFlagKey] intValue];
                                        }
                                    }
                                    
//                                    [jvcCloudSEENetworkHelper.ystNWRODelegate deviceWithFrameStatus:currentChannelObj.nShowWindowID+1 withStreamType:nStreamType withIsHomeIPC:isHomeIPC withEffectType:nEffectflag withStorageType:nStorageMode withIsNewHomeIPC:isNewHomeIPC withIsOldStreeamType:nOldStreamType ytSpeed:nPtzSpeedNum];
                                    
                                    [jvcCloudSEENetworkHelper.ystNWRODelegate  deviceWithFrameStatus:currentChannelObj.nShowWindowID+1 ytSpeed:nPtzSpeedNum];
                                    
                                    [params release];
                                    [strDevice release];
                                }
                                
                            
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                }
                    break;
                    
                case RC_EXTEND:{
                    
                    EXTEND *extend=(EXTEND*)stpacket.acData;
                    
                    switch (stpacket.nPacketCount) {
                        case RC_EX_MDRGN:{
                            switch (extend->nType) {
//                                case EX_MDRGN_SUBMIT:
//                                      if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)])
//                                      {
//                                    
//                                            [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_setSensitivity objYstNetWorkHelpSendData:nil];
//                                        }
//                                    break;
                                case EX_MDRGN_UPDATE:
                                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)])
                                    {
                                        NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:extend->acData+extend->nParam1];
                                        [params retain];

                                        
                                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_readSensitivity objYstNetWorkHelpSendData:params];
                                    }
                                    break;

                                    
                                default:
                                    break;
                            }
                            
                            


                            
                        }
                            break;
                        case RC_EX_NETWORK:{
                            
                            switch (extend->nType) {
                                    
                                case EX_WIFI_AP_CONFIG:{
                                    
                                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                        
                                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_ApSetResult objYstNetWorkHelpSendData:nil];
                                    }
                                    
                                }
                                    break;
                                case EX_WIFI_AP:{
                                    
                                    NSMutableArray *amAplistData          = [[NSMutableArray alloc] initWithCapacity:10];
                                    
                                    [amAplistData addObjectsFromArray:[jvcCloudSEENetworkHelper getDeviceNearApList:extend->nParam1 NearApListBuffer:extend->acData]];
                                    
                                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                        
                                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_ApList objYstNetWorkHelpSendData:amAplistData];
                                    }
                                    
                                    [amAplistData release];
                                }
                                    break;
                                    
                                default:
                                    break;
                            }
                        
                        }
                            break;
                        case RC_EX_ACCOUNT:
                        case RC_EX_FIRMUP:{
                            
                            if (jvcCloudSEENetworkHelper.ystNWTDDelegate !=nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(RemoteOperationAtTextChatResponse:withResponseDic:)]) {
                                
                                [jvcCloudSEENetworkHelper.ystNWTDDelegate RemoteOperationAtTextChatResponse:currentChannelObj.nShowWindowID+1  withResponseDic:[JVCStruct2Dic dicWithPacketStrcut:pBuffer withSize:nSize withOffset:packetAcDataOffset]];
                            }
                        
                        }
                            break;
                        
                        case RC_EX_FlashJpeg:{
                        
                            int imageLen=extend->nParam1;
                            
                            if (imageLen > 0) {
                                
                                NSData *imagedata=[NSData dataWithBytes:extend->acData length:imageLen];
                                
                                [jvcCloudSEENetworkHelper JVCCloudSEEManagerHelperCaptureImageData:imagedata withShowWindowID:currentChannelObj.nShowWindowID];
                            }
                        
                        }
                            break;
                        case RC_EX_STORAGE:{
//                            NSLog(@"***============0006========");
                            if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:extend->acData];
                                [params retain];
                                
                                [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                                
                                [params release];
//                                NSLog(@"********params:%@******",params);
                            }
                            
                        }
                            break;
                       
                        default:
                            break;
                    }
                }
                    break;
                case RC_GPIN_ADD:{
                    
                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                        
                        NSString *responseStr = [[NSString alloc] initWithUTF8String:stpacket.acData];
                        
                        NSMutableDictionary *alarmAddInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
                        
                        if (responseStr.length > 0) {
                            
                            [alarmAddInfo addEntriesFromDictionary:[ystNetworkHelperCMObj convertpBufferToMDictionary:(char *)[responseStr UTF8String]]];
                        }
                        
                        [responseStr release];

                          [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_setAlarmType objYstNetWorkHelpSendData:alarmAddInfo];
                        
                        [alarmAddInfo release];
                    }

                }
                    break;
                    
                case RC_GPIN_DEL:{
                    
                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                        
                        NSString *responseStr = [[NSString alloc] initWithUTF8String:stpacket.acData];
                        
                        NSMutableDictionary *alarmAddInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
                        
                        if (responseStr.length > 0) {
                            
                            [alarmAddInfo addEntriesFromDictionary:[ystNetworkHelperCMObj convertpBufferToMDictionary:(char *)[responseStr UTF8String]]];
                        }
                        
                        [responseStr release];
                        
                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_deleteAlarm objYstNetWorkHelpSendData:alarmAddInfo];
                        
                        [alarmAddInfo release];
                    }
                    
                }
                    break;
                case RC_GPIN_SET:{
                    
                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                        
                        NSString *responseStr = [[NSString alloc] initWithUTF8String:stpacket.acData];
                        
                        NSMutableDictionary *alarmAddInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
                        
                        if (responseStr.length > 0) {
                            
                            [alarmAddInfo addEntriesFromDictionary:[ystNetworkHelperCMObj convertpBufferToMDictionary:(char *)[responseStr UTF8String]]];
                        }
                        
                        [responseStr release];
                        
                         [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_editAlarm objYstNetWorkHelpSendData:alarmAddInfo];
                        
                        [alarmAddInfo release];
                    }
                    
                }
                    break;
                    
                case RC_GPIN_SELECT:
                {
                    
                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                        
                        
                        NSMutableArray *alarmInfo = [[NSMutableArray alloc] initWithCapacity:10];
                        
                        NSString *responseStr = [[NSString alloc] initWithUTF8String:stpacket.acData];
                        
                        NSArray *responseArry = [responseStr componentsSeparatedByString:(NSString *)kBindAlarmFlagKey];
                        
                        if (responseArry.count > 0) {
                            
                            for (int i=0; i<responseArry.count; i++) {
                                
                                NSString *singleInfo = [responseArry objectAtIndex:i];
                                
                                if (singleInfo.length > 0) {
                                    
                                    [alarmInfo addObject:[ystNetworkHelperCMObj convertpBufferToMDictionary:(char *)[singleInfo UTF8String]]];
                                }
                            }
                        }
                        
                        [responseStr release];
                        
                         [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1 withTextDataType:TextChatType_getAlarmType objYstNetWorkHelpSendData:alarmInfo];
                        
                        [alarmInfo release];
                    }
                    
                }
                    break;
                case RC_SETSYSTIME:
                {
//                    NSLog(@"=12345===");
                    
                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                        
                        NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                        
                        [params retain];
                        
                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                        
                        [params release];
                    }

                }
                    break;
                case RC_SETPARAM:
                {
//                    NSLog(@"=112233===");
                    
                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                        
                        NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                        
                        [params retain];
                        
                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                        
                        [params release];
                    }
                    
                }
                    break;
                default:
                    break;
            }
            
        }
        default:
            break;
    }
    
    [pool release];
}


/**
 *  根据老家用产品二码流参数信息，返回
 *
 *  @param mdStreamType 帧类型
 *
 *  @return 当前码流参数信息
 */
-(int)getOldHomeIPCStreamType:(NSMutableDictionary *)mdStreamTypeInfo{
    
    [mdStreamTypeInfo retain];
    
    NSString *strHeight = [mdStreamTypeInfo objectForKey:(NSString *)KOldHomeIPCHeight];
    NSString *strWidth  = [mdStreamTypeInfo objectForKey:(NSString *)KOldHomeIPCWidth];
    
    int       nheight   = 0;
    int       nWidth    = 0;
    
    if (strHeight) {
        
        nheight = strHeight.intValue;
    }
    
    if (strWidth) {
        
        nWidth  = strWidth.intValue;
    }
    
    [mdStreamTypeInfo release];
    
    if (nWidth >= JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1CheckWidth ) {
        
        return JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1;
    }
    
    return JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIF;
}

/**
 *  获取设备附近的WI-FI热点
 *
 *  @param nNearApListCount 返回的热点个数
 *  @param NearApListBuffer 返回的热点数据
 *
 *  @return 返回的是热点
 */
-(NSMutableArray *)getDeviceNearApList:(int)nNearApListCount NearApListBuffer:(char *)NearApListBuffer{
    
    NSMutableArray *amNearApList = [[NSMutableArray alloc] init];
    
    wifiap_t _wifer={0};
    
    for (int i=0; i<nNearApListCount; i++) {
        
        memset(&_wifer, 0, sizeof(wifiap_t));
        
        memcpy(&_wifer, NearApListBuffer+sizeof(wifiap_t)*i, sizeof(wifiap_t));
        
        NSMutableDictionary *apSingleInfo = [[NSMutableDictionary  alloc] initWithCapacity:10];
    
        NSString            *strApName = [[NSString alloc] initWithCString:_wifer.name encoding:NSUTF8StringEncoding];
        
        if (strApName) {
        
            [apSingleInfo setObject:strApName  forKey:AP_WIFI_USERNAME];
            
            [apSingleInfo setObject:[NSString stringWithFormat:@"%s",_wifer.passwd]  forKey:AP_WIFI_PASSWORD];
            [apSingleInfo setObject:[NSString stringWithFormat:@"%d",_wifer.quality] forKey:AP_WIFI_QUALITY];
            [apSingleInfo setObject:[NSString stringWithFormat:@"%d",_wifer.keystat] forKey:AP_WIFI_KEYSTAT];
            [apSingleInfo setObject:[NSString stringWithFormat:@"%s",_wifer.iestat]  forKey:AP_WIFI_IESTAT];
            
            unsigned int iauth=_wifer.iestat[0];
            unsigned int ienc=_wifer.iestat[1];
            
            [apSingleInfo setObject:[NSString stringWithFormat:@"%d",iauth] forKey:AP_WIFI_AUTH];
            [apSingleInfo setObject:[NSString stringWithFormat:@"%d",ienc]  forKey:AP_WIFI_ENC];
            
            [amNearApList addObject:apSingleInfo];
            
            [apSingleInfo release];

        }
        [strApName release];

    }
    
    return [amNearApList autorelease];
}

/**
 *  设置有线网络
 *
 *  @param nLocalChannel     本地连接的编号
 *  @param nIsEnableDHCP     是否启用自动获取 1:启用 0:手动输入
 *  ************以下参数手动输入时才生效*********************
 *  @param strIpAddress      ip地址
 *  @param strSubnetMaskIp   子网掩码
 *  @param strDefaultGateway 默认网关
 *  @param strDns            DNS服务器地址
 */
-(void)RemoteSetWiredNetwork:(int)nLocalChannel nIsEnableDHCP:(int)nIsEnableDHCP strIpAddress:(NSString *)strIpAddress strSubnetMask:(NSString *)strSubnetMask strDefaultGateway:(NSString *)strDefaultGateway strDns:(NSString *)strDns{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper            *currentChannelObj            = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    [ystRemoteOperationHelperObj RemoteSetWiredNetwork:currentChannelObj.nLocalChannel nIsEnableDHCP:nIsEnableDHCP strIpAddress:strIpAddress strSubnetMask:strSubnetMask strDefaultGateway:strDefaultGateway strDns:strDns];
}

/**
 *  配置设备的无线网络(老的配置方式)
 *
 *  @param nLocalChannel   本地连接的编号
 *  @param strSSIDName     配置的热点名称
 *  @param strSSIDPassWord 配置的热点密码
 *  @param strWifiAuth     热点的认证方式
 *  @param strWifiEncryp   热点的加密方式
 */
-(void)RemoteOldSetWiFINetwork:(int)nLocalChannel strSSIDName:(NSString *)strSSIDName strSSIDPassWord:(NSString *)strSSIDPassWord strWifiAuth:(NSString *)strWifiAuth strWifiEncrypt:(NSString *)strWifiEncrypt{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper            *currentChannelObj            = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    [ystRemoteOperationHelperObj RemoteOldSetWiFINetwork:currentChannelObj.nLocalChannel strSSIDName:strSSIDName strSSIDPassWord:strSSIDPassWord strWifiAuth:strWifiAuth strWifiEncrypt:strWifiEncrypt];
}

/**
 *  配置设备的无线网络(新的配置方式)
 *
 *  @param nLocalChannel   本地连接的编号
 *  @param strSSIDName     配置的热点名称
 *  @param strSSIDPassWord 配置的热点密码
 *  @param nWifiAuth       热点的认证方式
 *  @param nWifiEncryp     热点的加密方式
 */
-(void)RemoteNewSetWiFINetwork:(int)nLocalChannel strSSIDName:(NSString *)strSSIDName strSSIDPassWord:(NSString *)strSSIDPassWord nWifiAuth:(int)nWifiAuth nWifiEncrypt:(int)nWifiEncrypt{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper            *currentChannelObj            = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj != nil) {
        
        [ystRemoteOperationHelperObj  RemoteNewSetWiFINetwork:currentChannelObj.nLocalChannel strSSIDName:strSSIDName strSSIDPassWord:strSSIDPassWord nWifiAuth:nWifiAuth nWifiEncrypt:nWifiEncrypt];
    }
}

#pragma mark --------------------- JVCCloudSEEManagerHelper delegate

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame 解码返回的数据
 */
-(void)decoderOutVideoFrameCallBack:(DecoderOutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber {
    
    //fNSLog(@"networkhelper decoderOutVideoFrameCallBack");
    int nLocalChannel                           = decoderOutVideoFrame->nLocalChannelID;
    JVCCloudSEEManagerHelper *currentChannelObj = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    int                openGlViewIndex          = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if (amOpenGLViews.count > openGlViewIndex) {
        
            GlView *glView           = (GlView *)[amOpenGLViews objectAtIndex:openGlViewIndex];
            UIView *glShowView       = (UIView *)glView._kxOpenGLView;

            int     showViewHeight   = currentChannelObj.showView.frame.size.height;
            int     showViewWidth    = currentChannelObj.showView.frame.size.width;

            int     glShowViewHeight = glShowView.frame.size.height;
            int     glShowViewWidth  = glShowView.frame.size.width;
            
            if (decoderOutVideoFrame->decoder_y == NULL || decoderOutVideoFrame->decoder_u == NULL || decoderOutVideoFrame->decoder_v == NULL) {
                return;
            }
            
            if (showViewHeight != glShowViewHeight || showViewWidth  != glShowViewWidth) {
                
                [glView updateDecoderFrame:currentChannelObj.showView.bounds.size.width displayFrameHeight:currentChannelObj.showView.bounds.size.height];
            }
            
//            NSLog(@"==start====");

            [glView decoder:decoderOutVideoFrame->decoder_y imageBufferU:decoderOutVideoFrame->decoder_u imageBufferV:decoderOutVideoFrame->decoder_v decoderFrameWidth:decoderOutVideoFrame->nWidth decoderFrameHeight:decoderOutVideoFrame->nHeight];
//            NSLog(@"==end====");

            currentChannelObj.isDisplayVideo = YES;
        }
    
    });
    
    [self.ystNWHDelegate H264VideoDataCallBackMath:currentChannelObj.nShowWindowID+1  withPlayBackFrametotalNumber: nPlayBackFrametotalNumber];

}

/**
 *  更新视频显示的画布，用于视频显示窗口发生变化
 *
 *  @param nLocalChannel 本地显示窗口的编号
 *  @param nWidth        宽
 *  @param nHeight       高
 */
-(void)updateDecoderDisplayFrame:(int)nLocalChannel withDisplayWidth:(int)nWidth withDisplayHeight:(int)nHeight{


}

/**
 *  抓拍图片
 *
 *  @param captureOutImageData 抓拍的图片数据
 */
-(void)JVCCloudSEEManagerHelperCaptureImageData:(NSData *)captureOutImageData withShowWindowID:(int)nShowWindowID {
    
    [captureOutImageData retain];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nShowWindowID+1];
    JVCVideoDecoderHelper    *decoderObj          =  currentChannelObj.decodeModelObj;
 
    
    if (decoderObj.IsEnableSceneImages) {
        
        if (self.ystNWHDelegate != nil && [self.ystNWHDelegate respondsToSelector:@selector(sceneOutImageDataCallBack:withLocalChannel:)]) {
            
            [self.ystNWHDelegate sceneOutImageDataCallBack:captureOutImageData withLocalChannel:currentChannelObj.nShowWindowID+1];
        }
        
    }else{
    
        if (self.jvcCloudSEENetworkHelperCaptureDelegate != nil && [self.jvcCloudSEENetworkHelperCaptureDelegate respondsToSelector:@selector(captureImageCallBack:)]) {
            
            [self.jvcCloudSEENetworkHelperCaptureDelegate captureImageCallBack:captureOutImageData];
        }
    }
    
    [captureOutImageData release];
}

#pragma mark ------ 满帧和全帧的切换 针对所有视频所有视频

/**
 *  远程控制指令 发送所有连接的 全帧和I的切换
 *
 *  @param isOnltIFrame YES:只发I帧
 */
-(void)RemoteOperationSendDataToDeviceWithfullOrOnlyIFrame:(BOOL)isOnltIFrame{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    for (int i = 0 ; i< kJVCCloudSEENetworkHelperWithConnectMaxNumber; i++) {
        
        JVCCloudSEEManagerHelper *CloudSEEManagerHelperObj = jvChannel[i];
        [CloudSEEManagerHelperObj retain];
        if (nil != CloudSEEManagerHelperObj && CloudSEEManagerHelperObj.isDisplayVideo) {
            
            NSLog(@"JVCCloudSEE Manager %@",CloudSEEManagerHelperObj);
            
            BOOL checkSendFrameStatus =CloudSEEManagerHelperObj.isOnlyIState == isOnltIFrame;
            
            if (! checkSendFrameStatus) {
                
                [ystRemoteOperationHelperObj RemoteOperationSendDataToDevice:CloudSEEManagerHelperObj.nLocalChannel remoteOperationCommand:isOnltIFrame == YES ? JVN_CMD_ONLYI : JVN_CMD_FULL];
                
                CloudSEEManagerHelperObj.isOnlyIState                = isOnltIFrame;
                CloudSEEManagerHelperObj.jvcQueueHelper.isOnlyIFrame = isOnltIFrame;
            }
        }
        [CloudSEEManagerHelperObj release];
    }
}


#pragma mark ----------------------------- 网络库远程下载接口
/**
 *  远程下载文件接口
 *
 *  @param nLocalChannel 连接的本地通道号 从1开始
 *  @param uchType       帧类型
 *  @param pBuffer       下载数据
 *  @param nSize         下载的大小
 *  @param nFileLen
 */
void RemoteDownLoadCallback(int nLocalChannel, unsigned char uchType, char *pBuffer, int nSize, int nFileLen)
{
    JVCCloudSEEManagerHelper  *currentChannelObj     = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
//    NSLog(@"========000000000000000000=====%d=====",uchType);
    if (isCancelDownload) {
        
//        DDLogCVerbose(@"%s-----------download001====111",__FUNCTION__);
        return;
    }
//    DDLogCVerbose(@"%s-----------download001===22222",__FUNCTION__);

    if (currentChannelObj == nil) {
        
//        DDLogCVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
    }
    
    switch (uchType) {
            
        case JVN_RSP_DOWNLOADOVER: //文件下载完毕
        case JVN_CMD_DOWNLOADSTOP: //停止文件下载
        case JVN_RSP_DOWNLOADE:    //文件下载失败
        case JVN_RSP_DLTIMEOUT:{   //文件下载超时
            
//            DDLogCVerbose(@"%s---dataSizeCallBack=%d,uchtype=%d===001",__FUNCTION__,nSize,uchType);
            [jvcCloudSEENetworkHelper closeDownloadHandle:uchType];
            
            [jvcCloudSEENetworkHelper downloadProgressState:uchType==JVN_RSP_DOWNLOADOVER?JVCCloudSEENetworkDownLoadStateSucceed:JVCCloudSEENetworkDownLoadStateFailed];
            
        }
            break;
        case JVN_RSP_DOWNLOADDATA:{
        
           // DDLogCVerbose(@"%s---dataSize=%d,nFileLen=%d,uchtype=%d",__FUNCTION__,nSize,nFileLen,uchType);
            [jvcCloudSEENetworkHelper downloadProgress:nSize withTotalSize:nFileLen];
            [jvcCloudSEENetworkHelper openDownFileHandle:pBuffer withSaveBufferSize:nSize];
        }
            break;
        default:
            break;
    }
}

-(void)downloadProgress:(int)progress withTotalSize:(int)totalSize{

    if (self.jvcCloudSEENetworkHelperDownLoadDelegate !=nil && [self.jvcCloudSEENetworkHelperDownLoadDelegate respondsToSelector:@selector(playBackDownloadProgress:withTotalSize:)]) {
        
        [self.jvcCloudSEENetworkHelperDownLoadDelegate playBackDownloadProgress:progress withTotalSize:totalSize];
    }
}

-(void)downloadProgressState:(enum JVCCloudSEENetworkDownLoadState)state {

    if (self.jvcCloudSEENetworkHelperDownLoadDelegate !=nil && [self.jvcCloudSEENetworkHelperDownLoadDelegate respondsToSelector:@selector(playBackDownloadProgressState:withSavePath:)]) {
        
        [self.jvcCloudSEENetworkHelperDownLoadDelegate playBackDownloadProgressState:state withSavePath:remoteDownSavePath];
    }
}

/**
 *  打开文件写入流句柄并写入数据
 *
 *  @param buffer 写入的数据
 *  @param nSize  写入数据的大小
 */
-(void)openDownFileHandle:(const char *)buffer withSaveBufferSize:(int)nSize{
    
    if (NULL == downloadHandle) {
        
        downloadHandle = fopen([remoteDownSavePath UTF8String], "ab+");
    }

//    DDLogVerbose(@"%s====%@",__FUNCTION__,remoteDownSavePath);
    
    flockfile(downloadHandle);
    fwrite(buffer,1,nSize, downloadHandle);
    fflush(downloadHandle);
    funlockfile(downloadHandle);
}

/**
 *  关闭文件写入流句柄
 */
-(void)closeDownloadHandle:(int)downloadStatus{

    if (NULL != downloadHandle) {
        
        fclose(downloadHandle);
        
        downloadHandle = NULL;
    }
    
    if (self.ystNWRPVDelegate != nil && [self.ystNWRPVDelegate respondsToSelector:@selector(remoteDownLoadCallBack:withDownloadSavePath:)]) {
        
        [jvcCloudSEENetworkHelper.ystNWRPVDelegate remoteDownLoadCallBack:downloadStatus withDownloadSavePath:remoteDownSavePath];
    }
}

/**
 *  关闭写文件
 */
- (void)closeDownloadHandle
{
    if (NULL != downloadHandle) {
        
        fclose(downloadHandle);
        
        downloadHandle = NULL;
    }
    
}

/**
 *  设置远程下载的状态
 *
 *  @param downState 远程下载状态， yes 取消下载  no 默认值
 */
- (void)setDownState:(BOOL )downState
{
    isCancelDownload = downState;

}


/**
 *  远程下载命令
 *
 *  @param nLocalChannel 视频显示的窗口编号
 *  @param downloadPath  视频下载的地址
 *  @param SavePath      保存的路径
 */
-(void)RemoteDownloadFile:(int)nLocalChannel withDownLoadPath:(char *)downloadPath  withSavePath:(NSString *)SavePath{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        
        return;
    }
    
    if (remoteDownSavePath == nil) {
        
        remoteDownSavePath  = [[NSMutableString alloc] initWithCapacity:10];
        
    }else {
        
        [remoteDownSavePath deleteCharactersInRange:NSMakeRange(0, remoteDownSavePath.length)];
    }
    
    [remoteDownSavePath appendString:SavePath];
    
//    NSLog(@"======remoteDownSavePath============%@",remoteDownSavePath);
    
    [ystRemoteOperationHelperObj RemoteDownloadFile:currentChannelObj.nLocalChannel withDownloadPath:downloadPath];
}

/**
 *  远程下载命令
 *
 *  @param nLocalChannel 视频显示的窗口编号
 *  @param downloadPath  视频下载的地址
 *  @param SavePath      保存的路径
 */
-(void)RemoteDownloadFile:(int)nLocalChannel withSavePath:(NSString *)SavePath  requestPlayBackFileInfo:(NSMutableDictionary *)requestPlayBackFileInfo  requestPlayBackFileDate:(NSDate *)requestPlayBackFileDate requestPlayBackFileIndex:(int)requestPlayBackFileIndex{
        
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    
    if (remoteDownSavePath == nil) {
        
        remoteDownSavePath  = [[NSMutableString alloc] initWithCapacity:10];
        
    }else {
    
        [remoteDownSavePath deleteCharactersInRange:NSMakeRange(0, remoteDownSavePath.length)];
    }
    
    isCancelDownload = FALSE;
    
    [remoteDownSavePath appendString:SavePath];
    
    char acBuff[150] = {0};
    
    //组合一条发送的远程回放文件的信息
    [currentChannelObj getRequestSendPlaybackVideoCommand:requestPlayBackFileInfo requestPlayBackFileDate:requestPlayBackFileDate nRequestPlayBackFileIndex:requestPlayBackFileIndex requestOutCommand:(char *)acBuff];

    [ystRemoteOperationHelperObj RemoteDownloadFile:currentChannelObj.nLocalChannel withDownloadPath:acBuff];

}

#pragma mark ------------------ 门磁和手环报警设置

/**
 *  删除门磁和手环报警
 *
 *  @param nLocalChannel 本地连接通道号
 *  @param alarmType     报警的类型
 *  @param alarmGuid     报警的唯一标示
 */
-(void)RemoteDeleteDeviceAlarm:(int)nLocalChannel withAlarmType:(int)alarmType  withAlarmGuid:(int)alarmGuid {
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        
        return;
    }
    
    [ystRemoteOperationHelperObj RemoteDeleteAlarmDevice:currentChannelObj.nLocalChannel deviceType:alarmType deviceGuid:alarmGuid];

}

/**
 *  编辑门磁和手环报警
 *
 *  @param nLocalChannel 本地连接通道号
 *  @param alarmType     报警的类型
 *  @param alarmGuid     报警的唯一标示
 *  @param alarmEnable   报警是否开启
 *  @param alarmName     报警的别名
 */
-(void)RemoteEditDeviceAlarm:(int)nLocalChannel withAlarmType:(int)alarmType  withAlarmGuid:(int)alarmGuid withAlarmEnable:(int)alarmEnable withAlarmName:(NSString *)alarmName{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        
        return;
    }
    
    [ystRemoteOperationHelperObj RemoteSetAlarmDeviceStatus:currentChannelObj.nLocalChannel withAlarmEnable:alarmEnable withAlarmGuid:alarmGuid withAlarmType:alarmType withAlarmName:alarmName];
}

/**
 *  设置安全防护时间段
 *
 *  @param nLocalChannel  本地通道
 *  @param strBeginTime   开始时间
 *  @param strEndTime     结束时间
 */
-(void)RemoteSetAlarmTime:(int)nLocalChannel withstrBeginTime:(NSString *)strBeginTime withStrEndTime:(NSString *)strEndTime {
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        
        return;
    }
    
    [ystRemoteOperationHelperObj RemoteSetAlarmTime:currentChannelObj.nLocalChannel withstrBeginTime:strBeginTime withStrEndTime:strEndTime];
}

/**
 *  修改设备的用户名密码
 *
 *  @param nJVChannleID 本地连接的通道号
 *  @param userName     用户名
 *  @param passWord     密码
 */
- (void)RemoteSetToModifyDeviceInfo:(int)nLocalChannel  withUserName:(NSString *)userName withPassWord:(NSString *)passWord   describeString:(NSString *)describe
{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        
        return;
    }
    
    [ystRemoteOperationHelperObj RemoteModifyDeviceInfo:currentChannelObj.nLocalChannel withUserName:userName withPassWord:passWord describe:describe];

}

/**
 *  获取设备的用户详细信息
 *
 *  @param nLocalChannel 本地连接的通道号
 */
- (void)RemoteGetDeviceAccount:(int)nLocalChannel
{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
//        DDLogVerbose(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        
        return;
    }
    
    [ystRemoteOperationHelperObj getModifyDeviceList:nLocalChannel];
}

/**
 *  OpenGL 放大或缩小
 *
 *  @param nLocalChannel 远程本地
 *  @param x             缩放显示居中的x
 *  @param y             缩放显示居中的y
 *  @param isMaxScale    是否放大或缩小
 */
-(void)RemoteSetOpenGLScale:(int)nLocalChannel withCenterX:(float)x withCenterY:(float)y{

    JVCCloudSEEManagerHelper  *currentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
     int                 openGlViewIndex          = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    if (currentChannelObj != nil && currentChannelObj.isDisplayVideo) {
        
        GlView *glView           = (GlView *)[amOpenGLViews objectAtIndex:openGlViewIndex];
        [glView setScaleToLargestWithCenterX:x withCenterY:y];
        
    }
    
}

/**
 *  OpenGL 放大或缩小
 *
 *  @param nLocalChannel 远程本地
 */
-(void)RemoteRestoreGlViewFrame:(int)nLocalChannel{
    
    JVCCloudSEEManagerHelper  *currentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    int                 openGlViewIndex          = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    if (currentChannelObj != nil && currentChannelObj.isDisplayVideo) {
    
        GlView *glView           = (GlView *)[amOpenGLViews objectAtIndex:openGlViewIndex];
        [glView restoreGlViewFrame];
            
    }
}

/**
 *  OpenGL 改变窗口的大小
 *
 *  @param nLocalChannel 远程本地
 *  @param x             缩放显示居中的x
 *  @param y             缩放显示居中的y
 *  @param isMaxScale    是否放大或缩小
 */
-(void)RemoteSetGlViewFrame:(int)nLocalChannel{
    
    JVCCloudSEEManagerHelper  *currentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    int                 openGlViewIndex           = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    if (currentChannelObj != nil && currentChannelObj.isDisplayVideo) {
        
            
        GlView *glView           = (GlView *)[amOpenGLViews objectAtIndex:openGlViewIndex];
        UIView *glShowView       = (UIView *)glView._kxOpenGLView;
        
        int     showViewHeight   = currentChannelObj.showView.frame.size.height;
        int     showViewWidth    = currentChannelObj.showView.frame.size.width;
        
        int     glShowViewHeight = glShowView.frame.size.height;
        int     glShowViewWidth  = glShowView.frame.size.width;
        
        
        if (showViewHeight != glShowViewHeight || showViewWidth  != glShowViewWidth) {
            
            [glView updateDecoderFrame:currentChannelObj.showView.bounds.size.width displayFrameHeight:currentChannelObj.showView.bounds.size.height];
        }
        
    }
}

/**
 *  设置OpenGL画布是否允许手势交互
 *
 *  @param nLocalChannel 远程本地通道号
 *  @param enabled       YES：允许
 */
-(void)RemoteSetGlViewUserInteractionEnabled:(int)nLocalChannel withEnabled:(BOOL)enabled{

    JVCCloudSEEManagerHelper  *currentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    int                 openGlViewIndex           = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    if (currentChannelObj != nil && currentChannelObj.isDisplayVideo) {
        
        
        GlView *glView           = (GlView *)[amOpenGLViews objectAtIndex:openGlViewIndex];
        [glView setOpenGLViewUserInteractionEnabled:enabled];
        
    }
}

/**
 *  判断一个连接的设备录像是否是Mp4文件
 *
 *  @param nLocalChannel 远程本地通道号
 *
 *  @return YES：是
 */
-(BOOL)isMp4FileOfLoaclChannelID:(int)nLocalChannel{

    JVCCloudSEEManagerHelper  *currentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (nil == currentChannelObj) {
        
        return FALSE;
    }

    //JVC_ConnectRTMP(1,"http:://",rtmp_connectchange,rtmp_videoCallBack);
    return [currentChannelObj isMp4File];
}



void rtmp_connectchange(int nLocalChannel, unsigned char uchType, char *pMsg, int nPWData)
{
    
}//1:connect successa;  2  :connect failed； 3: disconnect success； 4 ：exception disconnect

void rtmp_videoCallBack(int nLocalChannel, unsigned char uchType, unsigned char *pBuffer, int nSize,int nTimestamp)
{
    
}

/**
 *  获取设备的类型
 *
 *  @param nLocalChannel 远程本地通道号
 *
 *  @return int：设备类型
 */
- (int)getDeviceType:(int)nLocalChannel
{
    int nDeviceType = -1;
    
    JVCCloudSEEManagerHelper  *currentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj != nil ) {
        
        nDeviceType = currentChannelObj.nConnectDeviceType;
        
    }
    return nDeviceType;
}


/**
 *  获取设备是否是nvr的类型
 *
 *  @param nLocalChannel 远程本地通道号
 *
 *  @return bool：NVR yes   ；no 不是nvr
 */
- (BOOL)getDeviceIsNVRType:(int)nLocalChannel
{
    BOOL nDeviceType = NO;
    
    JVCCloudSEEManagerHelper  *currentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj != nil ) {
        
        nDeviceType = currentChannelObj.isNvrDevice;
        
    }
    return nDeviceType;
}


/**
 *  远程控制指令
 *
 *  @param nLocalChannel          控制本地连接的通道号
 *  @param remoteOperationType    控制的类型
 *  @param remoteOperationCommand 控制的命令
 *  @param  speedValue            速度
 */
-(void)RemoteYTOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommand:(int)remoteOperationCommand speed:(int)speedValue
{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];

    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nLocalChannel];

    [ystRemoteOperationHelperObj onlySendYtOperaton:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommand:remoteOperationCommand speed:speedValue];
    
}

-(int)getCurrentChannelVideoDecoderID:(int)nLocalChannel{
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    return currentChannelObj.videoCodecID;
}

@end
