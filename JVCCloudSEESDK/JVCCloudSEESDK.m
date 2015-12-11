//
//  JVCCloudSEESDK.m
//  JVCCloudSEESDK
//
//  Created by chenzhenyang on 14-12-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCCloudSEESDK.h"

#import "JVCCloudSEENetworkInterface.h"
#import "JVNetConst.h"
#import "JVCCloudSEENetworkGeneralHelper.h"
#import "JVCCloudSEESendGeneralHelper.h"
#import "JVCVideoDecoderHelper.h"
#import "JVCRemotePlayBackWithVideoDecoderHelper.h"
#import "GlView.h"
#import "JVCStruct2Dic.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVNetConst.h"
#import "JVCConstansALAssetsMathHelper.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "JVCLANScanWithSetHelpYSTNOHelper.h"
#import "JVCLanScanDeviceModel.h"
#import "JVCVideoDecoderInterface.h"
#import "JVCAudioCodecInterface.h"
#import "JVCMediaPlayer.h"
#import "Jmp4pkg.h"
//#import "JVCNPlayer.h"


static const NSString      *kRecoedVideoFileFormat  = @".mp4";                             //保存录像的单个文件后缀

enum DEVICE_AP_LEVEL {
    
    DEVICE_AP_OLD = 0,
    DEVICE_AP_NEW = 1,
    
};

//@protocol ystNetWorkHelpDelegate <NSObject>
//
//@optional
//
///**
// *  设备场景图片的代理
// *
// *  @param imageData      输出的图片
// *  @param nShowWindowID  显示视频的窗口ID
// */
//-(void)sceneOutImageDataCallBack:(NSData *)imageData withShowWindowID:(int)nShowWindowID;
//
///**
// *  开始请求文本聊天的回调
// *
// *  @param nLocalChannel 本地显示窗口的编号
// *  @param nDeviceType   设备的类型
// *  @param isNvrDevice   是否是NVR设备
// */
//-(void)RequestTextChatCallback:(int)nLocalChannel withDeviceType:(int)nDeviceType withIsNvrDevice:(BOOL)isNvrDevice;
//
///**
// *  开始请求文本聊天的回调
// *
// *  @param nLocalChannel 本地显示窗口的编号
// *  @param nDeviceModel  设备的类型 （YES：05）
// */
//-(void)RequestTextChatIs05DeviceCallback:(int)nLocalChannel withDeviceModel:(BOOL)nDeviceModel;
//
///**
// *  文本聊天请求的结果回调
// *
// *  @param nLocalChannel 本地本地显示窗口的编号
// *  @param nStatus       文本聊天的状态
// */
//-(void)RequestTextChatStatusCallBack:(int)nLocalChannel withStatus:(int)nStatus;
//
//
//@end


@protocol YstNetWorkHelpTextDataDelegate <NSObject>

@optional

/**
 *  文本聊天返回的回调
 *
 *  @param nYstNetWorkHelpTextDataType 文本聊天的状态类型
 *  @param objYstNetWorkHelpSendData   文本聊天返回的内容
 */
-(void)ystNetWorkHelpTextChatCallBack:(int)nLocalChannel withTextDataType:(int)nYstNetWorkHelpTextDataType objYstNetWorkHelpSendData:(id)objYstNetWorkHelpSendData;

/**
 *  远程控制指令(文本聊天)
 *
 *  @param nLocalChannel          视频显示的窗口编号
 *  @param dic                    返回的内容
 */
-(void)RemoteOperationAtTextChatResponse:(int)nLocalChannel withResponseDic:(NSDictionary *)dic;

@end




//@protocol JVCCloudSEENetworkHelperCaptureDelegate <NSObject>
//
///**
// *  抓拍图片的委托代理
// *
// *  @param imageData 图片的二进制数据
// */
//-(void)captureImageCallBack:(NSData *)imageData;
//
//
//@end

@interface JVCCloudSEESDK () <JVCCloudSEEManagerHelperDelegate>{
    
    NSMutableString *remoteDownSavePath;
    BOOL            isInitSdk;            //YES:已经初始化过
    
        
//    id <ystNetWorkHelpDelegate>                      ystNWHDelegate;   //视频
//    id <ystNetWorkHelpRemoteOperationDelegate>       ystNWRODelegate;    //远程请求操作
    id <ystNetWorkHelpRemoteOperationDelegate>   ystNWRPVDelegate; //远程回放
    
//    id <JVCCloudSEENetworkHelperCaptureDelegate>     jvcCloudSEENetworkHelperCaptureDelegate; //抓拍
    
    NSMutableString  *savePath;
    NSMutableString *saveAlbum;

    BOOL isPause;

}


//@property(nonatomic,assign)id <JVCCloudSEENetworkHelperCaptureDelegate>     jvcCloudSEENetworkHelperCaptureDelegate; //抓拍

enum DEVICETYPE {
    
    DEVICETYPE_HOME  = 2,
    
};

enum DEVICETALKMODEL {
    
    DEVICETALKMODEL_Talk   = 1, // 1:设备播放声音，不采集声音
    DEVICETALKMODEL_Notalk = 0, // 0:设备采集 不播放声音
};

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


@implementation JVCCloudSEESDK
{
   int  nRepeatRequestCount;
}

@synthesize jvcCloudSEESDKDelegate;
@synthesize ystNWRODelegate;
@synthesize jvcAudioDelegate;
@synthesize jvcRemotePlaybackVideoDelegate;
@synthesize ystNWTDDelegate;
@synthesize videoDelegate;
@synthesize jvcVideoDelegate;
@synthesize jvcWifiListDelegate;
@synthesize jvcCloudSEENetworkHelperCaptureDelegate;
@synthesize jvcTransParentDelegate;
@synthesize jvcAPModeDelegate;
@synthesize jvcSTAModeDelegate;
@synthesize jvcDeviceNetsDelegate;
@synthesize jvcModifyDeviceDelegate;
@synthesize jvcLanSearchDelegate;

BOOL          isRequestTimeoutSecondFlag;            //远程请求用于跳出请求的标志位 TRUE  :跳出
BOOL          isRequestRunFlag;                      //远程请求用于正在请求的标志位 FALSE :执行结束
static NSString const *kCheckHomeFlagKey = @"MobileCH";
static NSString const *kBindAlarmFlagKey = @"$";
static NSString const *kConnectDefaultIP             = @"10.10.0.1";
static const  int      kConnectDefaultPort           = 9101;
FILE *downloadHandle = NULL;

JVCCloudSEEManagerHelper *jvChannel[kJVCCloudSEENetworkHelperWithConnectMaxNumber];
NSMutableArray           *amOpenGLViews;       //存放的与个jvChannel相同数量的OpenGL对象

static const int          kDisconnectTimeDelay     = 500;  //单位毫秒
static JVCCloudSEESDK *jvcCloudSEENetworkHelper    = nil;

/**
 *  单例
 *
 *  @return 返回JVCCloudSEENetworkHelper 单例
 */
+ (JVCCloudSEESDK *)shareJVCCloudSEESDK
{
    @synchronized(self)
    {
        if (jvcCloudSEENetworkHelper == nil) {
            
            jvcCloudSEENetworkHelper = [[self alloc] init];
            [jvcCloudSEENetworkHelper initSdkParams];
            
            
        }
        
        return jvcCloudSEENetworkHelper;
    }
    
    return jvcCloudSEENetworkHelper;
}

- (void)initSdkParams
{
    saveAlbum = [[NSMutableString alloc] init];
    savePath = [[NSMutableString alloc] init];
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (jvcCloudSEENetworkHelper == nil) {
            
            jvcCloudSEENetworkHelper = [super allocWithZone:zone];
            jvcCloudSEENetworkHelper.ystNWTDDelegate=self;
            return jvcCloudSEENetworkHelper;
        }
    }
    
    return nil;
}

/**
 *  初始化SDK
 *
 */
-(void)initCloudSEESdk {
    
    if (!isInitSdk) {
        
        JVC_InitSDK(9200,  (char *)[@"" UTF8String]);
        JVC_EnableLog(FALSE);
        JVD04_InitSDK();
        JVD05_InitSDK();
        JP_InitSDK(32 * 1024, 1);
        InitDecode();      //板卡语音解码
        InitEncode();      //板卡语音编解]
        JVC_EnableHelp(true,3);  //手机端是3
//        [JVCNPlayer initCore];
        //注册各种回调函数
        JVC_RegisterCallBack(ConnectMessageCallBack,VideoDataCallBack,RemoteplaybackSearchCallBack,VoiceIntercomCallBack,TextChatDataCallBack,RemoteDownLoadCallback,RemotePlaybackDataCallBack);
        
        isInitSdk = YES;
        
        amOpenGLViews = [[NSMutableArray alloc] initWithCapacity:10];
        
        //初始化OpenGL 画布
        for (int i=0; i<kJVCCloudSEENetworkHelperWithConnectMaxNumber; i++) {
            
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
        
        
        jvChannel [nJvchannelID]                = [[JVCCloudSEEManagerHelper alloc] init];
        
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
-(BOOL)ipConnectVideobyDeviceInfo:(int)nLocalChannel nRemoteChannel:(int)nRemoteChannel  strUserName:(NSString *)strUserName strPassWord:(NSString *)strPassWord strRemoteIP:(NSString *)strRemoteIP nRemotePort:(int)nRemotePort
                   nSystemVersion:(int)nSystemVersion isConnectShowVideo:(BOOL)isConnectShowVideo withConnectType:(int)nConnectType
                     withShowView:(UIView *)showVew{
    
    
    JVCCloudSEEManagerHelper *currentChannelObj        = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    int               nJvchannelID             = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    int               nJVCCloudSEEManagerHelper        = nJvchannelID+1;
    
    if ( currentChannelObj  == nil || currentChannelObj.nShowWindowID != nLocalChannel -1 ) {
        
        if ( currentChannelObj != nil && currentChannelObj.nShowWindowID != nLocalChannel -1 ) {
            
            [self disconnect:nJVCCloudSEEManagerHelper];
        }
        
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
        
        [newCurrentChannelObj connectWork];
        
        return TRUE;
        
    }else {
        
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
        //断开远程连接
        [currentChannelObj disconnect];
        
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
    
    if (self.jvcCloudSEESDKDelegate != nil && [self.jvcCloudSEESDKDelegate respondsToSelector:@selector(ConnectMessageCallBackMath:nLocalChannel:connectResultType:)]) {
        
        [[JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper] getConnectFailedDetailedInfoByConnectResultInfo:connectCallBackInfo conenctResultType:&connectResultType];
        
        [self.jvcCloudSEESDKDelegate ConnectMessageCallBackMath:connectCallBackInfo nLocalChannel:nshowWindowNumber connectResultType:connectResultType];
    }
    
    if (CONNECTRESULTTYPE_Succeed != connectResultType) {
        
        if (jvChannel[nJvchannelID] != nil) {
            
            //设置OpenGL画布
            
            if (jvChannel[nJvchannelID].showView) {
                
                [self performSelectorOnMainThread:@selector(hiddenOpenGLView) withObject:nil waitUntilDone:YES];
            }
            
            [jvChannel[nJvchannelID] exitQueue];
            [jvChannel[nJvchannelID] closeVideoDecoder];
            
            [jvChannel[nJvchannelID] release];
            jvChannel[nJvchannelID]=nil;
        }
    }
    
    [connectCallBackInfo release];
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
    
    JVCCloudSEENetworkGeneralHelper *ystNetworkHelperCMObj = [JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper];
    JVCCloudSEEManagerHelper                    *currentChannelObj         = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    JVCVideoDecoderHelper                       *JVCVideoDecoderHelperObj  = currentChannelObj.decodeModelObj;
    JVCRemotePlayBackWithVideoDecoderHelper     *playBackDecoderObj        = currentChannelObj.playBackDecoderObj;
    int                                          nOpenGLIndex              = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    if (currentChannelObj.isRunDisconnect) {
        
        [pool release];
        return;
    }
    
    switch (uchType) {
            
        case JVN_DATA_O:{
            
            if (pBuffer[0]!=0) {
                
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
            
            playBackDecoderObj.isDecoderModel    = JVCVideoDecoderHelperObj.isDecoderModel;
            playBackDecoderObj.isExistStartCode  = JVCVideoDecoderHelperObj.isExistStartCode;
            
            [currentChannelObj resetVideoDecoderParam];
            
            [currentChannelObj startPopVideoDataThread];
            
            
            if (jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate != nil && [jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate respondsToSelector:@selector(RequestTextChatCallback:withDeviceType:withIsNvrDevice:)]) {
                
                [jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate RequestTextChatCallback:currentChannelObj.nShowWindowID+1 withDeviceType:currentChannelObj.nConnectDeviceType withIsNvrDevice:currentChannelObj.isNvrDevice];
            }
            
//            if (jvcCloudSEENetworkHelper.ystNWHDelegate != nil && [jvcCloudSEENetworkHelper.ystNWHDelegate respondsToSelector:@selector(RequestTextChatIs05DeviceCallback:withDeviceModel:)]) {
//                
//                [jvcCloudSEENetworkHelper.ystNWHDelegate RequestTextChatIs05DeviceCallback:currentChannelObj.nShowWindowID+1 withDeviceModel:JVCVideoDecoderHelperObj.isDecoderModel];
//            }
        }
            break;
        case JVN_DATA_I:
        case JVN_DATA_B:
        case JVN_DATA_P:{
            
            if (currentChannelObj.isPlaybackVideo) {
                
                [pool release];
                return;
            }
            
            BOOL               isH264Data         = [ystNetworkHelperCMObj checkVideoDataIsH264:pBuffer];
            
            [currentChannelObj openVideoDecoder];
            
            if (isH264Data) {
                
                int bufferType = uchType;
                
                if (jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate != nil && [jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate respondsToSelector:@selector(videoDataCallBackMath:withPlayBackFrametotalNumber:)]) {
                    
                    //偏移带帧头的数据和视频数据的大小以及获取当前的帧类型
                    [jvcCloudSEENetworkHelper videoDataInExistStartCode:&pBuffer isFrameOStartCode:JVCVideoDecoderHelperObj.isExistStartCode nbufferSize:&nSize nBufferType:&bufferType];
                    
                    [currentChannelObj pushVideoData:(unsigned char *)pBuffer nVideoDataSize:nSize isVideoDataIFrame:bufferType==JVN_DATA_I isVideoDataBFrame:bufferType == JVN_DATA_B frameType:bufferType];
                    
                    
                }else{
                    
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
                
                [pool release];
                return;
            }
            
            [currentChannelObj pushAudioData:(unsigned char *)pBuffer nAudioDataSize:nSize];
        }
            break;
            
        default:
            break;
    }
    
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
        
        return;
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
        
        return;
    }
    
    [currentChannelObj stopRecordVideo];
    
    if (self.videoDelegate !=nil && [self.videoDelegate respondsToSelector:@selector(videoEndCallBack)]) {
        
        [self.videoDelegate videoEndCallBack];
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
        
        return;
    }
    
    PAC m_stPacket = {0};
    
    [JVCStruct2Dic packetStrcutWithDic:dicCommand withStrcut:&m_stPacket];
    
    switch (m_stPacket.nPacketType) {
            
        case RC_EXTEND:{
            
            EXTEND *extend = (EXTEND *)m_stPacket.acData;
            
            JVC_SendData(currentChannelObj.nLocalChannel, JVN_RSP_TEXTDATA, (unsigned char *)&m_stPacket, 20+(int)strlen(extend->acData));
            
        }
            break;
            
        default:{
            
            JVC_SendData(currentChannelObj.nLocalChannel, JVN_RSP_TEXTDATA, (unsigned char *)&m_stPacket, 4+(int)strlen(m_stPacket.acData));
            
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
            
//            if (remoteOperationCommand == JVN_CMD_CHATSTOP) {
//                
//                [self returnVoiceIntercomCallBack:currentChannelObj nVoiceInterStateType:VoiceInterStateType_End];
//            }
            
        }
            break;
        case RemoteOperationType_YTO:
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
        case TextChatType_setDeviceNetTime:

        case TextChatType_setDevicePNMode:
        case TextChatType_setDeviceTimezone:
        case TextChatType_setDeviceAlarmSound:
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
/**
 *  远程控制指令
 *
 *  @param nLocalChannel              视频显示的窗口编号
 *  @param remoteOperationType        控制的类型
 *  @param remoteOperationCommandData 控制的指令内容
 */
-(void)remoteOperationDeviceInfo:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandStr:(NSString *)remoteOperationCommand{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
        return;
    }
    
    switch (remoteOperationType) {
            
        case TextChatType_setSensitivity:{
            
            [ystRemoteOperationHelperObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:TextChatType_setSensitivity remoteOperationCommandSensitivityStr:remoteOperationCommand];
            
            //            if (remoteOperationCommand == JVN_CMD_CHATSTOP) {
            //
            //                [self returnVoiceIntercomCallBack:currentChannelObj nVoiceInterStateType:VoiceInterStateType_End];
            //            }
            
        }
            break;
        default:
            break;
    }

}
/**
 *  远程控制指令
 *
 *  @param nLocalChannel              视频显示的窗口编号
 *  @param remoteOperationType        控制的类型
 *  @param remoteOperationCommandData 控制的指令内容
 */
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandData:(char *)remoteOperationCommandData{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper         *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
        return;
    }
    
    
    [ystRemoteOperationHelperObj remoteSendDataToDevice:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommandData:remoteOperationCommandData];
}

#pragma mark -设置设备时间和格式

-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandStr:(NSString *)remoteOperationCommand{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    if (remoteOperationType==TextChatType_setDeviceTimeFormat) {
        [ystRemoteOperationHelperObj onlySendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommandStr:remoteOperationCommand];
    }
    
}

#pragma mark -获取SD卡信息

-(void)getSDInforWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    if (remoteOperationType==TextChatType_getDeviceSDCardInfo) {
        [ystRemoteOperationHelperObj SDSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}

#pragma mark -获取基本信息
-(void)getBasicInfoRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    if (remoteOperationType==TextChatType_getBasicInfo) {
        [ystRemoteOperationHelperObj getBasicInfoRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:TextChatType_getBasicInfo];
    }
}

#pragma mark -格式化SD卡
-(void)FormatSDWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (remoteOperationType==TextChatType_FormatSD) {
        [ystRemoteOperationHelperObj FormatSDSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }
    
}


#pragma mark -改变录像模式
-(void)changeVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    if (remoteOperationType==TextChatType_stopVedio) {
        [ystRemoteOperationHelperObj stopVedioSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType];
    }else if(remoteOperationType==TextChatType_ManualVedio){
        [ystRemoteOperationHelperObj ManualVedioSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:TextChatType_ManualVedio];
    }else if (remoteOperationType==TextChatType_AlarmVedio){
        [ystRemoteOperationHelperObj AlarmVedioSendRemoteOperation:currentChannelObj.nLocalChannel remoteOperationType:TextChatType_AlarmVedio];
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
    
    switch(uchType)
    {
        case JVN_REQ_CHAT:
            break;
            
        case JVN_RSP_CHATACCEPT:{
            
            [jvcCloudSEENetworkHelper returnVoiceIntercomCallBack:currentChannelObj nVoiceInterStateType:VoiceInterStateType_Succeed];
        }
            break;
            
        case JVN_CMD_CHATSTOP://"终止语音"
            
            [jvcCloudSEENetworkHelper returnVoiceIntercomCallBack:currentChannelObj nVoiceInterStateType:VoiceInterStateType_End];
            
            break;
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
    
    if (self.jvcAudioDelegate !=nil && [self.jvcAudioDelegate respondsToSelector:@selector(VoiceInterComCallBack:)]) {
        
        [self.jvcAudioDelegate VoiceInterComCallBack:nVoiceInterStateType];
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
    
    if (jvcCloudSEENetworkHelper.jvcRemotePlaybackVideoDelegate != nil && [jvcCloudSEENetworkHelper.jvcRemotePlaybackVideoDelegate respondsToSelector:@selector(remoteplaybackSearchFileListInfoCallBack:)]) {
        
        NSMutableArray   *mArrayRemotePlaybackFileList = [[NSMutableArray alloc] initWithCapacity:10];
        
        NSMutableArray *serachPlayBackListData = [currentChannelObj getRemoteplaybackSearchFileListInfoByNetworkBuffer:pBuffer remotePlaybackFileBufferSize:nSize];
        
        [serachPlayBackListData retain];
        [mArrayRemotePlaybackFileList addObjectsFromArray:serachPlayBackListData];
        [serachPlayBackListData release];
        
        [jvcCloudSEENetworkHelper.jvcRemotePlaybackVideoDelegate remoteplaybackSearchFileListInfoCallBack:mArrayRemotePlaybackFileList];
        
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
            
            [currentChannelObj startPopVideoDataThread];
            
            if (width > 0 && height >0) {
                
                if (jvcCloudSEENetworkHelper.jvcRemotePlaybackVideoDelegate != nil && [jvcCloudSEENetworkHelper.jvcRemotePlaybackVideoDelegate respondsToSelector:@selector(remoteplaybackState:)]) {
                    
                    [jvcCloudSEENetworkHelper.jvcRemotePlaybackVideoDelegate remoteplaybackState:RemotePlayBackVideoStateType_Succeed];
                }
            }
        }
            break;
            
        case JVN_DATA_I:
        case JVN_DATA_B:
        case JVN_DATA_P:{
            
            
            if (!currentChannelObj.isPlaybackVideo) {
                
                [pool release];
                return;
            }
            
            BOOL               isH264Data      = [ystNetworkHelperCMObj checkVideoDataIsH264:pBuffer];
            
            [currentChannelObj openVideoDecoder];
            
            if (isH264Data) {
                
                int bufferType = uchType;
                
                if (jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate != nil && [jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate respondsToSelector:@selector(videoDataCallBackMath:withPlayBackFrametotalNumber:)]) {
                    
                    //偏移带帧头的数据和视频数据的大小
                    [jvcCloudSEENetworkHelper videoDataInExistStartCode:&pBuffer isFrameOStartCode:playBackDecoderObj.isExistStartCode nbufferSize:&nSize nBufferType:&bufferType];
                    
                    [currentChannelObj pushVideoData:(unsigned char *)pBuffer nVideoDataSize:nSize isVideoDataIFrame:bufferType==JVN_DATA_I isVideoDataBFrame:bufferType==JVN_DATA_B frameType:uchType];
                    
                }else{
                    
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
    
    if (self.jvcRemotePlaybackVideoDelegate != nil && [self.jvcRemotePlaybackVideoDelegate respondsToSelector:@selector(remoteplaybackState:)]) {
        
        [self.jvcRemotePlaybackVideoDelegate remoteplaybackState:nRemotePlaybackVideoState];
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
    
    NSLog(@"TextChatDataCallBack ================================ pBuffer===");
    NSAutoreleasePool                    *pool             = [[NSAutoreleasePool alloc] init];
    
    JVCCloudSEENetworkGeneralHelper *ystNetworkHelperCMObj = [JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj     = [jvcCloudSEENetworkHelper returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    switch(uchType)
    {
        case JVN_RSP_TEXTACCEPT:
        case JVN_CMD_TEXTSTOP:{
            
            if (jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate != nil && [jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate respondsToSelector:@selector(RequestTextChatStatusCallBack:withStatus:)]) {
                
                [jvcCloudSEENetworkHelper.jvcCloudSEESDKDelegate RequestTextChatStatusCallBack:currentChannelObj.nShowWindowID+1 withStatus:uchType];
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
                
                memcpy(&packetAcDataOffset, stpacket.acData, 4);   //存放acData的偏移量目前只有pac包中nPacketType=RC_LOADDLG时需要做偏移操作
            }
            
            switch (stpacket.nPacketType) {
                case RC_GETPARAM:{
//                    NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                        
                        NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                        
                        [params retain];
                        NSLog(@"设备基本信息:%@",params);
                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                        
                        [params release];
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
                                
//                                self.jvcWifiListDelegate
                                [networkInfoMDic release];
                            }
                            
                        }
                            break;
                            
                        case IPCAM_STREAM:{
                            if (jvcCloudSEENetworkHelper.ystNWTDDelegate !=nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(RemoteOperationAtTextChatResponse:withResponseDic:)]) {
                                NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];

                                [params retain];
                                [jvcCloudSEENetworkHelper.ystNWTDDelegate RemoteOperationAtTextChatResponse:currentChannelObj.nShowWindowID+1  withResponseDic:params];
                                [params release];

                            }
                            if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                
                                NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                                
                                [params retain];
                                
                                [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                                
                                [params release];
                            }
                            
                            if (jvcCloudSEENetworkHelper.ystNWRODelegate !=nil && [jvcCloudSEENetworkHelper.ystNWRODelegate respondsToSelector:@selector(deviceWithFrameStatus:withStreamType:withIsHomeIPC:withEffectType:withStorageType:withIsNewHomeIPC:withIsOldStreeamType:)]) {
                                
                                NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stpacket.acData+packetAcDataOffset];
                                
                                [params retain];
                                
                                int  nStreamType    = -1;
                                BOOL isHomeIPC      = FALSE;
                                int  nEffectflag    = -1;
                                int  nStorageMode   = -1;
                                BOOL isNewHomeIPC   = FALSE;
                                int  nOldStreamType = -1;
                                
                                NSString *strDevice          = [[NSString alloc] initWithString:[ystNetworkHelperCMObj findBufferInExitValueToByKey:stpacket.acData+packetAcDataOffset nameBuffer:(char *)[kCheckHomeFlagKey UTF8String]]];
                                
                                int nMobileCh = MOBILECHDEFAULT;
                                
                                if (strDevice.intValue == MOBILECHSECOND) {
                                    
                                    nMobileCh = MOBILECHSECOND;
                                }
                                
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
                                
                                [jvcCloudSEENetworkHelper.ystNWRODelegate deviceWithFrameStatus:currentChannelObj.nShowWindowID+1 withStreamType:nStreamType withIsHomeIPC:isHomeIPC withEffectType:nEffectflag withStorageType:nStorageMode withIsNewHomeIPC:isNewHomeIPC withIsOldStreeamType:nOldStreamType];
                                
                                [params release];
                                
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
                            
                        case RC_EX_NETWORK:{
                            
                            switch (extend->nType) {
                                case EX_NW_REFRESH:
                                {
                                    NSLog(@"刷新当前的网络信息");
                                    [[JVCCloudSEESDK shareJVCCloudSEESDK] receiveDeviceNetsdateCallback:extend->acData length:extend->nParam2];

                                }
                                    break;
                                case EX_START_AP:{
                                    switch (extend->nParam1) {
                                        case -1: //若pstExt->nParam1=-1，则不支持wifi;
                                        {
                                            NSLog(@"不支持wifi");
                                        }
                                            break;
                                        case 1:  //若pstExt->nParam1=1，说明AP模式已经开启；
                                        {
                                            NSLog(@"AP模式已经开启");
                                        }
                                            break;
                                        case 2:  //若pstExt->nParam1=0或pstExt->nParam1=2，则可以开启AP
                                        {
                                            NSLog(@"可以开启AP模式");
                                            [[JVCCloudSEESDK shareJVCCloudSEESDK] receiveAPModedateCallback:extend->acData length:extend->nParam3];

                                        }
                                            break;
                                        default:
                                            break;
                                    }
                                    
                                }
                                    break;

//                                case EX_START_STA:{
//                                    switch (extend->nParam1) {
//
//                                        case -1: //若pstExt->nParam1=-1，则不支持wifi；
//                                            NSLog(@"则不支持wifi");
//                                            break;
//                                        case 0:  //若pstExt->nParam1=0，说明目前尚未配置wifi，无法开启STA（开启了也没用）；
//                                            NSLog(@"目前尚未配置wifi");
//                                            break;
//                                        case 1:  //若pstExt->nParam1=1，说明STA模式已经开启；
//                                            NSLog(@"STA模式已经开启");
//                                            break;
//                                        case 2:  //若pstExt->nParam1=2，则可以开启STA。
//                                        {
//                                             NSLog(@"可以开启STA");
//                                            [[JVCCloudSEESDK shareJVCCloudSEESDK] receiveSTAModedateCallback:extend->acData length:extend->nParam3];
//                                        }
//                                            break;
//                                        default:
//                                            break;
//                                    }
//                                                                        
//                                }
//                                    break;
                                    
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
                            
                            switch (stpacket.nPacketType) {
                                    
                                case RC_EXTEND:{
                                    
                                    EXTEND *extend=(EXTEND*)stpacket.acData;

                                    switch (stpacket.nPacketCount) {
                                            
                                        case RC_EX_ACCOUNT:{
                                            
                                            switch (extend->nType) {
                                                    
                                                case EX_ACCOUNT_REFRESH:{
//                                                    JVCMonitorConnectionSingleImageView *singleView = [self singleViewAtIndex:nLocalChannel-1];
//                                                    singleView.bModifyDeviceInfo =  [packetModel checkoutAccountAuthority];
//                                                    if (singleView.bModifyDeviceInfo) {
//                                                        singleView.strAccountDescribe = [packetModel checkoutAccountDestribt];
//                                                        
//                                                    }
                                                }
                                                    break;
                                                case EX_ACCOUNT_MODIFY:
                                                {
                                                    if (jvcCloudSEENetworkHelper.jvcModifyDeviceDelegate !=nil && [jvcCloudSEENetworkHelper.jvcModifyDeviceDelegate respondsToSelector:@selector(modifyDeviceInfoSuccessCallBack)]) {
                                                        
                                                        [jvcCloudSEENetworkHelper.jvcModifyDeviceDelegate modifyDeviceInfoSuccessCallBack ];
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
                                    break;
                                default:
                                    break;
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
                            
//                        case  RC_EX_COMTRANS:
//                            
//                            switch (extend->nType) {
//                                case  EX_COMTRANS_RESV:
//                                    
//                                    [[JVCCloudSEESDK shareJVCCloudSEESDK] receiveNetTransparentdateCallback:extend->acData length:extend->nParam3];
//                                    
//                                    break;
//                                    
//                                default:
//                                    break;
//                            }
//                            break;
                        case RC_EX_STORAGE:
                            switch (extend->nType) {
                                case EX_STORAGE_REFRESH:
                                {
                                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                        NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:extend->acData];
                                        [params retain];
                                        
                                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                                        
                                        [params release];
                                        NSLog(@"********params:%@******",params);
                                    }
                                }
                                    break;
#warning 格式化SD卡
                                case EX_STORAGE_FORMAT:
                                {
                                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
                                        NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:extend->acData];
                                        [params retain];
                                        
                                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
                                        
                                        [params release];
                                        NSLog(@"********params:%@******",params);
                                    }
                                }
                                    break;
//                                case EX_STORAGE_SWITCH:
//                                {
//                                    if (jvcCloudSEENetworkHelper.ystNWTDDelegate != nil && [jvcCloudSEENetworkHelper.ystNWTDDelegate respondsToSelector:@selector(ystNetWorkHelpTextChatCallBack:withTextDataType:objYstNetWorkHelpSendData:)]) {
//                                        NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:extend->acData];
//                                        [params retain];
//                                        
//                                        [jvcCloudSEENetworkHelper.ystNWTDDelegate ystNetWorkHelpTextChatCallBack:currentChannelObj.nShowWindowID+1  withTextDataType:TextChatType_paraInfo objYstNetWorkHelpSendData:params];
//                                        
//                                        [params release];
//                                        NSLog(@"********params:%@******",params);
//                                    }
//                                }
//                                    break;
                                default:
                                    break;
                            }

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
    

    if (isPause) {
        return;
    }
    
    int nLocalChannel                           = decoderOutVideoFrame->nLocalChannelID;
    JVCCloudSEEManagerHelper *currentChannelObj = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    int                openGlViewIndex          = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if (amOpenGLViews.count > openGlViewIndex) {
            
            GlView *glView         = (GlView *)[amOpenGLViews objectAtIndex:openGlViewIndex];
            UIView *glShowView     = (UIView *)glView._kxOpenGLView;
            
            int     showViewHeight = currentChannelObj.showView.frame.size.height;
            int     showViewWidth  = currentChannelObj.showView.frame.size.width;
            
            int     glShowViewHeight = glShowView.frame.size.height;
            int     glShowViewWidth  = glShowView.frame.size.width;
            
            
            if (decoderOutVideoFrame->decoder_y == NULL || decoderOutVideoFrame->decoder_u == NULL || decoderOutVideoFrame->decoder_v == NULL) {
                return;
            }
            
            if (showViewHeight != glShowViewHeight || showViewWidth  != glShowViewWidth) {

                [glView updateDecoderFrame:currentChannelObj.showView.bounds.size.width displayFrameHeight:currentChannelObj.showView.bounds.size.height];
            }
            
            [glView decoder:decoderOutVideoFrame->decoder_y imageBufferU:decoderOutVideoFrame->decoder_u imageBufferV:(char*)decoderOutVideoFrame->decoder_v decoderFrameWidth:decoderOutVideoFrame->nWidth decoderFrameHeight:decoderOutVideoFrame->nHeight];
            
            currentChannelObj.isDisplayVideo = YES;
        }
        
    });
    

    [self.jvcCloudSEESDKDelegate videoDataCallBackMath:currentChannelObj.nShowWindowID+1 withPlayBackFrametotalNumber:nPlayBackFrametotalNumber];
    
}

-(void)pauseVideo:(int)nLocalChannel{
    isPause = true;
}

-(void)resumeVideo:(int)nLocalChannel{
    isPause = false;
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
        
//        if (self.ystNWHDelegate != nil && [self.ystNWHDelegate respondsToSelector:@selector(sceneOutImageDataCallBack:withShowWindowID:)]) {
//            
//            [self.ystNWHDelegate sceneOutImageDataCallBack:captureOutImageData withShowWindowID:currentChannelObj.nShowWindowID+1];
//        }
        
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
        
        if (CloudSEEManagerHelperObj != nil && CloudSEEManagerHelperObj.isDisplayVideo) {
            
            BOOL checkSendFrameStatus =CloudSEEManagerHelperObj.isOnlyIState == isOnltIFrame;
            
            if (! checkSendFrameStatus) {
                
                [ystRemoteOperationHelperObj RemoteOperationSendDataToDevice:CloudSEEManagerHelperObj.nLocalChannel remoteOperationCommand:isOnltIFrame == YES ? JVN_CMD_ONLYI : JVN_CMD_FULL];
                
                CloudSEEManagerHelperObj.isOnlyIState                = isOnltIFrame;
                CloudSEEManagerHelperObj.jvcQueueHelper.isOnlyIFrame = isOnltIFrame;
            }
        }
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
    
    if (currentChannelObj == nil) {
        
        return;
    }
    
    switch (uchType) {
            
        case JVN_RSP_DOWNLOADOVER: //文件下载完毕
        case JVN_CMD_DOWNLOADSTOP: //停止文件下载
        case JVN_RSP_DOWNLOADE:    //文件下载失败
        case JVN_RSP_DLTIMEOUT:{   //文件下载超时
            
            [jvcCloudSEENetworkHelper closeDownloadHandle:uchType];
            
            
        }
            break;
        case JVN_RSP_DOWNLOADDATA:{
            
            [jvcCloudSEENetworkHelper openDownFileHandle:pBuffer withSaveBufferSize:nSize];
        }
            break;
        default:
            break;
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
    
    if (self.jvcRemotePlaybackVideoDelegate != nil && [self.jvcRemotePlaybackVideoDelegate respondsToSelector:@selector(remoteDownLoadCallBack:withDownloadSavePath:)]) {
        
        [jvcCloudSEENetworkHelper.jvcRemotePlaybackVideoDelegate remoteDownLoadCallBack:downloadStatus withDownloadSavePath:remoteDownSavePath];
    }
    
}

/**
 *  远程下载命令
 *
 *  @param nLocalChannel 视频显示的窗口编号
 *  @param downloadPath  视频下载的地址
 *  @param SavePath      保存的路径
 */
-(void)RemoteDownloadFile:(int)nLocalChannel withDownLoadPath:(char *)downloadPath withSavePath:(NSString *)SavePath {
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
        return;
    }
    
    if (remoteDownSavePath == nil) {
        
        remoteDownSavePath  = [[NSMutableString alloc] initWithCapacity:10];
        
    }else {
        
        [remoteDownSavePath deleteCharactersInRange:NSMakeRange(0, remoteDownSavePath.length)];
    }
    
    [remoteDownSavePath appendString:SavePath];
    
    [ystRemoteOperationHelperObj RemoteDownloadFile:currentChannelObj.nLocalChannel withDownloadPath:downloadPath];
    
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
        
        return;
    }
    
    [ystRemoteOperationHelperObj RemoteSetAlarmTime:currentChannelObj.nLocalChannel withstrBeginTime:strBeginTime withStrEndTime:strEndTime];
}

/**
 *  Ap连接设备
 *
 *  @param nLocalChannel      通道号
 *  @param nRemoteChannel     channel
 *  @param nSystemVersion     版本号
 *  @param isConnectShowVideo 
 *  @param nConnectType       连接模式
 *  @param showVew            是否显示
 *
 *  @return <#return value description#>
 */
-(BOOL)ApConnectVideobyDeviceInfo:(int)nLocalChannel nRemoteChannel:(int)nRemoteChannel nSystemVersion:(int)nSystemVersion isConnectShowVideo:(BOOL)isConnectShowVideo withConnectType:(int)nConnectType
withShowView:(id)showVew userName:(NSString *)userName password:(NSString *)passWord{
    
    JVCCloudSEEManagerHelper *currentChannelObj        = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    int               nJvchannelID             = [self returnCurrentChannelBynLocalChannelID:nLocalChannel];
    int               nJVCCloudSEEManagerHelper        = nJvchannelID+1;
    
    if ( currentChannelObj  == nil || currentChannelObj.nShowWindowID != nLocalChannel -1 ) {
        
        if ( currentChannelObj != nil && currentChannelObj.nShowWindowID != nLocalChannel -1 ) {
            
            [self disconnect:nJVCCloudSEEManagerHelper];
        }
        
        jvChannel [nJvchannelID]                = [[JVCCloudSEEManagerHelper alloc] init];
        
        JVCCloudSEEManagerHelper *newCurrentChannelObj  = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
        newCurrentChannelObj.jvConnectDelegate = self;
        newCurrentChannelObj.nLocalChannel      = nJVCCloudSEEManagerHelper;
        newCurrentChannelObj.nRemoteChannel     = nRemoteChannel;
        newCurrentChannelObj.strRemoteIP        = (NSString *)kConnectDefaultIP;
        newCurrentChannelObj.nRemotePort        = kConnectDefaultPort;
        newCurrentChannelObj.linkModel          = YES;
        newCurrentChannelObj.strUserName        = userName;
        newCurrentChannelObj.strPassWord        = passWord;
        newCurrentChannelObj.nShowWindowID      = nLocalChannel -1;
        newCurrentChannelObj.nSystemVersion     = nSystemVersion;
        newCurrentChannelObj.isConnectShowVideo = isConnectShowVideo;
        newCurrentChannelObj.nConnectType       = nConnectType;
        newCurrentChannelObj.showView           = showVew;
        
        [newCurrentChannelObj connectWork];
        
        return TRUE;
        
    }else {
        
        return FALSE;
    }
}

/**
 *  创建制定相册
 *  @param albumName 相册名
 */
- (void)creatPhotoAlbum:(NSString *)albumName
{
    JVCConstansALAssetsMathHelper *alassert = [[JVCConstansALAssetsMathHelper alloc] init];
    
    [alassert checkAlbumNameIsExist:(NSString *)albumName];
    
    [alassert release];
}

/**
 *   录像结束的回调函数
 *
 *  @param isContinue 是否结束后继续录像 YES：继续
 */
-(void)videoEndCallBack:(BOOL)isContinueVideo{
    
    [self saveLocalVideo:savePath albumName:(NSString *)saveAlbum];
    
}

#pragma mark 开启本地录像
/**
 *  开启本地录像
 *
 *  @param buttonState yes 开启 no关闭
 *  @param channel     通道号
 */
-(void)operationPlayVideo:(BOOL)buttonState channel:(int )channel{
    
    JVCCloudSEESDK *jvcCloudObj = [JVCCloudSEESDK shareJVCCloudSEESDK];
    if (buttonState) {
        
        /**
         *  保存录像的回调
         */
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            
            if ([myerror.localizedDescription rangeOfString:NSLocalizedString(@"userDefine", nil)].location!=NSNotFound) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self showAletWithTitle:@"未授权"];
                });
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAletWithTitle:@"保存失败"];
                });
                
            }
            
        };
        
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group,BOOL *stop){
            
            NSString *documentPaths = NSTemporaryDirectory();
            
            [savePath deleteCharactersInRange:NSMakeRange(0, savePath.length)];
            
            NSString *filePath = [documentPaths stringByAppendingPathComponent:(NSString *)saveAlbum];
            
            if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"YYYYMMddHHmmssSSSS"];
            NSString *videoPath =[NSString stringWithFormat:@"%@/%@%@",filePath,[df stringFromDate:[NSDate date]],kRecoedVideoFileFormat];
            [df release];
            [savePath appendString:videoPath];
            
            
            [jvcCloudObj openRecordVideo:channel  saveLocalVideoPath:videoPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.videoDelegate!=nil&&[self.videoDelegate respondsToSelector:@selector(videoStartCallBack)]) {
                    [self.videoDelegate videoStartCallBack];
                }
            });
            
        };
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSUInteger groupTypes =ALAssetsGroupFaces;
        [library enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureblock];
        
    }else{
        
        [jvcCloudObj stopRecordVideo:channel  withIsContinueVideo:NO];
    }
}


#pragma mark 保存本地录像的文件
- (void)saveLocalVideo:(NSString*)urlString albumName:(NSString *)albumName {
    
    [saveAlbum deleteCharactersInRange:NSMakeRange(0, saveAlbum.length)];
    [saveAlbum appendString:albumName];
    

    
   
    //    NSLog(@"%s===保存的录像文件==%@==",__FUNCTION__,urlString);
    if (urlString) {
        
        if ((jvcVideoDelegate !=nil) &&[jvcVideoDelegate respondsToSelector:@selector(saveLocalVideoPath:albumName:)]) {
            
            [jvcVideoDelegate saveLocalVideoPath:urlString albumName:albumName];
        }
    }
    
    return;
}

- (void)showAletWithTitle:(NSString *)title
{
    UIAlertView *aleret = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil
                                           cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [aleret show];
    [aleret release];
}


#pragma mark 获取设备的wifi数据
/**
 *  获取设备的wifi列表
 *
 *  @param nChannel 通道号
 */
- (void)getDeviceWifiList:(int)nChannel
{
    
    jvcCloudSEENetworkHelper.ystNWTDDelegate = self;
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];

//    [ystRemoteOperationHelperObj RemoteOperationSendDataToDevice:nChannel remoteOperationCommand:JVN_CMD_VIDEOPAUSE];
    
//    [self RemoteOperationSendDataToDevice:nChannel remoteOperationType:TextChatType_NetWorkInfo remoteOperationCommand:-1];
    
    [self RemoteOperationSendDataToDevice:nChannel remoteOperationType:TextChatType_ApList remoteOperationCommand:-1];

}

/**
 *  开始配置
 *
 *  @param strWifiEnc      wifi的加密方式
 *  @param strWifiAuth     wifi的认证方式
 *  @param strWifiSSid     配置WIFI的SSID名称
 *  @param strWifiPassWord 配置WIFi的密码
 */
-(void)runApSetting:(NSString *)strWifiEnc strWifiAuth:(NSString *)strWifiAuth strWifiSSid:(NSString *)strWifiSSid strWifiPassWord:(NSString *)strWifiPassWord channel:(int )connectDefaultchannel
{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];

    [ystRemoteOperationHelperObj RemoteNewSetWiFINetwork:connectDefaultchannel strSSIDName:strWifiSSid strSSIDPassWord:strWifiPassWord nWifiAuth:strWifiAuth.intValue nWifiEncrypt:strWifiEnc.intValue];

}




/**
 *  文本聊天返回的回调
 *
 *  @param nYstNetWorkHelpTextDataType 文本聊天的状态类型
 *  @param objYstNetWorkHelpSendData   文本聊天返回的内容
 */
-(void)ystNetWorkHelpTextChatCallBack:(int)nLocalChannel withTextDataType:(int)nYstNetWorkHelpTextDataType objYstNetWorkHelpSendData:(id)objYstNetWorkHelpSendData
{
    switch (nYstNetWorkHelpTextDataType) {
            
        case TextChatType_NetWorkInfo:{
            
////            [self performSelectorOnMainThread:@selector(stopRepeatRequestTimer) withObject:nil waitUntilDone:NO];
//            NSMutableDictionary *networkInfo = (NSMutableDictionary *)objYstNetWorkHelpSendData;
//            
//            if (networkInfo) {
//                
//                int deviceAPFlag = [[networkInfo objectForKey:kHomeIPCOldFlag] intValue];
//                
//                if (deviceAPFlag == DEVICE_AP_NEW) {
//                    
//                    [self gotoApConfigDevice:networkInfo];
//                    
//                }else{
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [self showOldHomeIPCUpdateAlert];
//                        
//                    });
//                    
//                }
//            }
        }
            break;
        case TextChatType_ApList:{
            
            NSMutableArray *networkInfo = (NSMutableArray *)objYstNetWorkHelpSendData;
            
            if (self.jvcWifiListDelegate !=nil &&[self.jvcWifiListDelegate respondsToSelector:@selector(getWifiListCallback:)]) {
                [self.jvcWifiListDelegate getWifiListCallback:objYstNetWorkHelpSendData];
            }
        }
            break;
            
        case TextChatType_ApSetResult:{
            
            if (self.jvcWifiListDelegate !=nil &&[self.jvcWifiListDelegate respondsToSelector:@selector(getDeviceWifiResult:)]) {
                [self.jvcWifiListDelegate getDeviceWifiResult:YES];
            }

        }
            break;
        default:
            break;
    }

}


/**
 *  透传协议，
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendComtrans:(int)nJvChannelID
                  content:(const char *) acBuffer
            contentLength:(int)length
{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    //    [ystRemoteOperationHelperObj onlySendYtOperaton:currentChannelObj.nLocalChannel remoteOperationType:remoteOperationType remoteOperationCommand:remoteOperationCommand speed:speedValue];
    [ystRemoteOperationHelperObj RemoteComtrans:currentChannelObj.nLocalChannel content:acBuffer contentLength:length];
}
/**
 *  玩具协议开启AP请求
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendOpenAPRequest:(int)nJvChannelID
{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    [ystRemoteOperationHelperObj RemoteSendOpenAPRequest:nJvChannelID];
  
}

/**
 *  玩具协议开启AP
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendOpenAPCmd:(int)nJvChannelID
{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    [ystRemoteOperationHelperObj RemoteSendOpenAPCmd:nJvChannelID];
    
}

- (void)receiveAPModedateCallback:(char *)buffer length:(int)dataLenght
{
    if (jvcAPModeDelegate !=nil &&[jvcAPModeDelegate respondsToSelector:@selector(receiveAPModedateCallback:length:)]) {
        [jvcAPModeDelegate receiveAPModedateCallback:buffer length:dataLenght];
    }
}

/**
 *  玩具协议开启STA请求
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendOpenSTARequest:(int)nJvChannelID
{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    [ystRemoteOperationHelperObj RemoteSendOpenSTARequest:nJvChannelID];
    
}

- (void)receiveSTAModedateCallback:(char *)buffer length:(int)dataLenght
{
    if (jvcSTAModeDelegate !=nil &&[jvcSTAModeDelegate respondsToSelector:@selector(receiveSTAModedateCallback:length:)]) {
        [jvcSTAModeDelegate receiveSTAModedateCallback:buffer length:dataLenght];
    }
}

/**
 *  玩具协议开启STA
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendOpenSTACmd:(int)nJvChannelID
{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    [ystRemoteOperationHelperObj RemoteSendOpenSTACmd:nJvChannelID];
    
}

/**
 *  玩具协议获取wifi信息
 *
 *  @param nJvChannelID    本地连接的通道号
 */
-(void)RemoteSendRequestCurrentNetworkInfo:(int)nJvChannelID
{
    
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    [ystRemoteOperationHelperObj RemoteSendRequestCurrentNetworkInfo:nJvChannelID];
    
}

//设备网络信息回调 buffer收到的数据
- (void)receiveDeviceNetsdateCallback:(char *)buffer length:(int)dataLength
{
    if (jvcDeviceNetsDelegate !=nil &&[jvcDeviceNetsDelegate respondsToSelector:@selector(receiveDeviceNetsdateCallback:length:)]) {
        [jvcDeviceNetsDelegate receiveDeviceNetsdateCallback:buffer length:dataLength];
    }
}


/**
 *  玩具协议设备搜索wifi热点
 *
 *  @param nJvChannelID    本地连接的通道号
 */
-(void)RemoteSendDeviceSearchAP:(int)nJvChannelID
{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    [ystRemoteOperationHelperObj RemoteSendDeviceSearchAP:nJvChannelID];
}

/**
 *  OSD显示问题
 *
 *  @param nPosition    显示位置
 *  @param nTimePosition  是否隐藏
 */
-(void)RemoteSendOSDOperationToDevice:(int)nJvChannelID
                            nTextPosition:(int) nPosition
                        nTimePosition:(int)nTimePosition
{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    
    JVCCloudSEEManagerHelper *currentChannelObj   = [self returnCurrentChannelBynLocalChannel:nJvChannelID];
    
    [ystRemoteOperationHelperObj RemoteSendOSDOperation:currentChannelObj.nLocalChannel nPosition:nPosition nTimePosition:nTimePosition];
}


- (void)receiveNetTransparentdateCallback:(char *)buffer length:(int)dataLenght
{
    if (jvcTransParentDelegate !=nil &&[jvcTransParentDelegate respondsToSelector:@selector(receiveTransparentdateCallback:length:)]) {
        [jvcTransParentDelegate receiveTransparentdateCallback:buffer length:dataLenght];
    }
}



/**
 *  修改设备的用户名密码
 *
 *  @param nJVChannleID 本地连接的通道号
 *  @param userName     用户名
 *  @param passWord     密码
 */
- (void)RemoteSetToModifyDeviceInfo:(int)nLocalChannel  withUserName:(NSString *)userName withPassWord:(NSString *)passWord   
{
    JVCCloudSEESendGeneralHelper *ystRemoteOperationHelperObj = [JVCCloudSEESendGeneralHelper shareJVCCloudSEESendGeneralHelper];
    JVCCloudSEEManagerHelper     *currentChannelObj           = [self returnCurrentChannelBynLocalChannel:nLocalChannel];
    
    if (currentChannelObj == nil) {
        
        NSLog(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        return;
    }
    
    [ystRemoteOperationHelperObj RemoteModifyDeviceInfo:nLocalChannel
                                           withUserName:userName
                                           withPassWord:passWord describe:@""];
    
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
        
        NSLog(@"%s---JVCCloudSEEManagerHelper(%d) is Null",__FUNCTION__,currentChannelObj.nLocalChannel-1);
        
        
        return;
    }
    
    [ystRemoteOperationHelperObj getModifyDeviceList:nLocalChannel];
}


/**
 *  设置小助手
 *
 *  @param deviceDguid 设备号
 *  @param userName 用户名
 *  @param passWord 密码
 */
-(void)setDevicesHelper:(NSString *)deviceDguid  userName:(NSString *)userName  passWord:(NSString *)passWord{
    if (userName.length==0) {
        userName=@"";
    }
    if (passWord.length==0) {
        passWord=@"";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        unsigned char bBuffer[1*sizeof(STBASEYSTNO)];
        
        
            NSString *ystDguid =deviceDguid;
            
            int kk;
            
            for (kk=0; kk<ystDguid.length; kk++) {
                
                unsigned char c=[ystDguid characterAtIndex:kk];
                
                if (c<='9' && c>='0') {
                    
                    break;
                }
            }
            
            NSString *sGroup=[ystDguid substringToIndex:kk];
            NSString *iYstNum=[ystDguid substringFromIndex:kk];
            STBASEYSTNO stinfo;
            
            if ([sGroup isEqualToString:NULL]||[sGroup isEqualToString:nil]||[iYstNum intValue]<=0) {
                
                return;
            }
            
            memset(stinfo.chGroup, 0, 4);
            memcpy(stinfo.chGroup, [sGroup UTF8String], strlen([sGroup UTF8String]));
            
            stinfo.nYSTNO         = [iYstNum intValue];
            stinfo.nChannel       =1 ;
            stinfo.nConnectStatus = 0;
            
            memset(stinfo.chPName, 0, MAX_PATH_01);
            memcpy(stinfo.chPName, [userName UTF8String], strlen([userName UTF8String]));
            
            memset(stinfo.chPWord, 0, MAX_PATH_01);
            memcpy(stinfo.chPWord, [passWord UTF8String], strlen([passWord UTF8String]));
            
            if (YES) {
                
                memcpy(bBuffer, &stinfo, sizeof(STBASEYSTNO));
                
            }else{
                
//                memcpy(&bBuffer[i*sizeof(STBASEYSTNO)], &stinfo, sizeof(STBASEYSTNO));
            }
        
        NSLog(@"=%s=%@===",__FUNCTION__,[[NSString alloc] initWithCString:bBuffer encoding:NSUTF8StringEncoding]);
        
        JVC_SetHelpYSTNO((unsigned char *)bBuffer,1*sizeof(STBASEYSTNO));
        
        
    });
}

//设置广播 搜索局域网设备的函数(本网段)
- (void)JVCLanSearchDevice
{
    JVCLANScanWithSetHelpYSTNOHelper *jvcLANScanWithSetHelpYSTNOHelperObj=[JVCLANScanWithSetHelpYSTNOHelper sharedJVCLANScanWithSetHelpYSTNOHelper];
    jvcLANScanWithSetHelpYSTNOHelperObj.delegate = self;
    
    [jvcLANScanWithSetHelpYSTNOHelperObj SerachAllDevicesAsynchronousRequestWithDeviceListData];

}

//搜索局域网设备的函数（本局域网）
- (void)jvcLanSearchAllDeviceNetWork
{
    JVCLANScanWithSetHelpYSTNOHelper *jvcLANScanWithSetHelpYSTNOHelperObj=[JVCLANScanWithSetHelpYSTNOHelper sharedJVCLANScanWithSetHelpYSTNOHelper];
    jvcLANScanWithSetHelpYSTNOHelperObj.delegate = self;
    
    [jvcLANScanWithSetHelpYSTNOHelperObj SerachLANAllDevicesAsynchronousRequestWithDeviceListData];
    
}

/**
 *  局域网扫描之后的回调
 *
 *  @param SerachLANAllDeviceList 扫描出来的所有设备
 */
-(void)SerachLANAllDevicesAsynchronousRequestWithDeviceListDataCallBack:(NSMutableArray *)SerachLANAllDeviceList {
    
//    NSLog(@"==1111==%s===%@___",__FUNCTION__,[SerachLANAllDeviceList description]);

    [SerachLANAllDeviceList  retain];
    
    NSMutableArray *arrayLanSearch = [[NSMutableArray alloc] init];
    
    static  NSString  * const kkeyDeviceNum              = @"LandeviceNum";   //局域网搜索的云视通号
    static  NSString  * const kkeyDeviceIP               = @"landeviceIP";    //局域网搜索的IP
    static  NSString  * const kkeyDevicePort             = @"port";           //局域网搜索的port
    
    for (JVCLanScanDeviceModel *model in SerachLANAllDeviceList) {
    
        NSMutableDictionary *tdicModel = [[NSMutableDictionary alloc] init];
        if (model.dguid.length>0) {
            
            [tdicModel setObject:model.dguid forKey:(NSString *)kkeyDeviceNum];
        }
        if (model.dvip.length>0) {
            [tdicModel setObject:model.dvip forKey:(NSString *)kkeyDeviceIP];

        }
        if (model.dvport >0) {
            [tdicModel setObject:[NSString stringWithFormat:@"%d",model.dvport] forKey:(NSString *)kkeyDevicePort];
            
        }
        
//        NSLog(@"==2222==%s===%@___",__FUNCTION__,[tdicModel description]);

        
        [arrayLanSearch addObject:tdicModel];
        [tdicModel release];
    }

    [SerachLANAllDeviceList release];
    
//    NSLog(@"==333==%s===%@___",__FUNCTION__,[arrayLanSearch description]);

    if (self.jvcLanSearchDelegate !=nil&&[self.jvcLanSearchDelegate respondsToSelector:@selector(JVCLancSearchDeviceCallBack:)]) {
        
//        NSLog(@"==444==%s===%@___",__FUNCTION__,[arrayLanSearch description]);

        [self.jvcLanSearchDelegate JVCLancSearchDeviceCallBack:arrayLanSearch];
    }

    [arrayLanSearch release];
}

/**
 *  设置对讲的开启方式
 *
 *  @param voiceType     VoiceType_Speaker =0,//扬声器   VoiceType_Liseten =1,//听筒
 */
- (void)setPlaySountType:(int)voiceType
{
//    if(voiceType == 1)
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"VOICETYPE"];
//    }else{
//    
//        [[NSUserDefaults standardUserDefaults] setObject:@"listen" forKey:@"VOICETYPE"];
//
//    }
}


/**
 *  播放器资源初始化
 *
 *  @param playerView 供显示的UIView
 */
- (void)MP4PlayerInit:(UIView *)playerView
{
    [[JVCMediaPlayer shareMediaPlayer] MediaPlayerInit:playerView];
}

/**
 *  播放器资源释放
 *
 *  @param playerView 供显示的UIView
 */
- (void)MP4PlayerRelease
{
    [[JVCMediaPlayer shareMediaPlayer] MediaPlayerRelease];
}
/**
 *  播放MP4文件
 *
 *  @param fileName 文件路径
 */
- (void)playMP4File:(NSString *)fileName
{
    [[JVCMediaPlayer shareMediaPlayer] openMP4File:fileName];
}
/**
 *  隐藏OpenGL的显示
 *
 *  @param strChannelNumber 通道号
 */
-(void)hiddenOpenGLView{
    
    int nJvchannelID   = 0;
    JVCCloudSEEManagerHelper  *currentChannelObj  = jvChannel[nJvchannelID];
    
    GlView *glView = (GlView *)[amOpenGLViews objectAtIndex:nJvchannelID];
    
    if (currentChannelObj.isDisplayVideo) {
        
        [glView clearVideo];
    }
    
    [glView hiddenWithOpenGLView];
    
}
/**
 *  隐藏OpenGL的显示
 *
 *  @param strChannelNumber 通道号
 */
-(void)showOpenGLView{

    [self showOpenGLViewAtView:nil];
}

/**
 *  隐藏OpenGL的显示
 *
 *  @param strChannelNumber 通道号
 *  @param view 显示的view
 */
-(void)showOpenGLViewAtView:(UIView *)view{
    int nJvchannelID   = 0;
    JVCCloudSEEManagerHelper  *currentChannelObj  = jvChannel[nJvchannelID];
    GlView *glView = (GlView *)[amOpenGLViews objectAtIndex:nJvchannelID];
    [glView showWithOpenGLView];

    if ([glView._kxOpenGLView superview]) {
        [glView._kxOpenGLView removeFromSuperview];
    }
    if (view) {
        [view addSubview:glView._kxOpenGLView];
    }else
    {

        [currentChannelObj.showView addSubview:glView._kxOpenGLView];
    }
    [glView updateDecoderFrame:currentChannelObj.showView.bounds.size.width displayFrameHeight:currentChannelObj.showView.bounds.size.height];

}


/**
<<<<<<< HEAD
=======
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

/**
>>>>>>> master
 * 设置本地的服务器
 * @param pGroup
 * @param pServer
 * @return   0:成功         其他：失败
 */
//-(int)setSelfServerWithGroup:(NSString *)pGroup service:(NSString *)pServer{
//    int result=JVC_SetSelfServer_I((char*) [pGroup UTF8String],(char*) [pServer UTF8String]);
//    //    int result=JVC_EnableHelp(true,3);
//    return result;
//}

@end
