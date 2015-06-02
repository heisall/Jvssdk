//
//  JVCCloudSEESDK.h
//  JVCCloudSEESDK
//
//  Created by chenzhenyang on 14-12-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCCloudSEENetworkMacro.h"
#import <UIKit/UIKit.h>

static NSString const *kConfigWifiEnc    =  @"wifiEnc";
static NSString const *kConfigWifiAuth   =  @"wifiAuth";
static NSString const *kWifiUserName     =  @"wifiUserName";


@protocol JVCCloudSEESDKDelegate <NSObject>

@optional

/**
 *  连接视频状态回调
 *
 *  @param connectCallBackInfo 返回的连接信息
 *  @param nlocalChannel       本地通道连接从1开始
 *  @param connectType         连接返回的类型
 */
-(void)ConnectMessageCallBackMath:(NSString *)connectCallBackInfo nLocalChannel:(int)nlocalChannel connectResultType:(int)connectResultType;

/**
 *  视频数据的回调
 *
 *  @param nLocalChannel             本地连接的通道号
 *  @param nPlayBackFrametotalNumber 当nPlayBackFrametotalNumber >0 时正在远程回放 否则 为实时视频
 */
-(void)videoDataCallBackMath:(int)nLocalChannel  withPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber;

/**
 *  开始请求文本聊天的回调
 *
 *  @param nLocalChannel 本地显示窗口的编号
 *  @param nDeviceType   设备的类型
 *  @param isNvrDevice   是否是NVR设备
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

//远程回放协议
@protocol JVCRemotePlaybackVideoDelegate <NSObject>

@optional

/**
 *  远程回放状态回调
 *
 *  @param remoteplaybackState
 
 //远程回放的状态类型
 enum JVCRemotePlayBackVideoStateType {
 
 JVCRemotePlayBackVideoStateTypeSucceed = 100, //远程回放成功
 JVCRemotePlayBackVideoStateTypeStop    = 101, //远程回放停止
 JVCRemotePlayBackVideoStateTypeEnd     = 102, //远程回放结束
 JVCRemotePlayBackVideoStateTypeFailed  = 103, //远程回放失败
 JVCRemotePlayBackVideoStateTypeTimeOut = 104, //远程回放超时
 };
 */
-(void)remoteplaybackState:(int)remoteplaybackState;

/**
 *  获取远程回放检索文件列表的回调
 *
 *  @param playbackSearchFileListMArray 远程回放检索文件列表
 */
-(void)remoteplaybackSearchFileListInfoCallBack:(NSMutableArray *)playbackSearchFileListMArray;

@end

@protocol JVCAudioDelegate <NSObject>

@optional

/**
 *  语音对讲的回调
 *
 *  @param VoiceInterState 对讲的状态
 */
-(void)VoiceInterComCallBack:(int)VoiceInterState;

@end

@protocol  ystNetWorkHelpVideoDelegate <NSObject>

@optional

/**
 *   录像结束的回调函数
 *
 *  @param isContinue 是否结束后继续录像 YES：继续
 */
-(void)videoEndCallBack:(BOOL)isContinueVideo;

@end

@protocol jvcVideoSaveDelegate <NSObject>

- (void)saveLocalVideoPath:(NSString*)urlString albumName:(NSString *)albumName;

@end

//获取wifi列表的回调
@protocol JVCGetWifiListDelegate <NSObject>

- (void)getWifiListCallback:(NSMutableArray *)arrayWifi;

//点击设置wifi后的结果，此结果告诉只是设备告诉app，他收到命令了，配置成不成功，通过设备的声音提示来处理
- (void)getDeviceWifiResult:(BOOL)state;


@end

//透传协议
@protocol JVCnetTransparentDelegate <NSObject>

//透传协议的回调 buffer收到的数据
- (void)receiveTransparentdateCallback:(char *)buffer length:(int)dataLength;

@end

//AP模式回调
@protocol JVCAPModeDelegate <NSObject>

//AP模式回调 buffer收到的数据
- (void)receiveAPModedateCallback:(char *)buffer length:(int)dataLength;

@end

//STA模式回调
@protocol JVCSTAModeDelegate <NSObject>

//STA模式回调 buffer收到的数据
- (void)receiveSTAModedateCallback:(char *)buffer length:(int)dataLength;

@end

//设备网络信息回调
@protocol JVCDeviceNetsDelegate <NSObject>

//设备网络信息回调 buffer收到的数据
- (void)receiveDeviceNetsdateCallback:(char *)buffer length:(int)dataLength;

@end


@protocol JVCCloudSEENetworkHelperCaptureDelegate <NSObject>

/**
 *  抓拍图片的委托代理
 *
 *  @param imageData 图片的二进制数据
 */
-(void)captureImageCallBack:(NSData *)imageData;

@end

@protocol JVCModifyDeviceInfoDelegate <NSObject>

/**
 *  修改设备详细信息的回调
 *
 *  @param modifyResult yes修改成功
 */
- (void)modifyDeviceInfoSuccessCallBack;

@end


@protocol JVCLanSearchDelegate <NSObject>

/**
 *  广播的回调
 *
 *  @param arraySearchList 广播数据
 */
- (void)JVCLancSearchDeviceCallBack:(NSMutableArray *)arraySearchList;

@end

@interface JVCCloudSEESDK : NSObject

@property(nonatomic,assign)id <JVCCloudSEESDKDelegate>            jvcCloudSEESDKDelegate;         //视频、连接信息
@property(nonatomic,assign)id <JVCRemotePlaybackVideoDelegate>    jvcRemotePlaybackVideoDelegate; //远程回放
@property(nonatomic,assign)id <JVCAudioDelegate>                  jvcAudioDelegate;               //音频代理
@property(nonatomic,assign)id<jvcVideoSaveDelegate>                   jvcVideoDelegate;
@property(nonatomic,assign)id<JVCGetWifiListDelegate>             jvcWifiListDelegate;
@property(nonatomic,assign)id<JVCnetTransparentDelegate>             jvcTransParentDelegate;//透传的协议
@property(nonatomic,assign)id<JVCAPModeDelegate>             jvcAPModeDelegate;//AP模式
@property(nonatomic,assign)id<JVCSTAModeDelegate>             jvcSTAModeDelegate;//AP模式
@property(nonatomic,assign)id<JVCDeviceNetsDelegate>             jvcDeviceNetsDelegate;//设备网络
@property(nonatomic,assign) id <JVCCloudSEENetworkHelperCaptureDelegate>     jvcCloudSEENetworkHelperCaptureDelegate;  //抓拍
@property(nonatomic,assign)id<JVCModifyDeviceInfoDelegate>             jvcModifyDeviceDelegate;//修改设备的回调
@property(nonatomic,assign)id<JVCLanSearchDelegate >                   jvcLanSearchDelegate;//广播的回调
/**
 *  单例 (所有操作请先初始化SDK)
 *
 *  @return 返回JVCCloudSEENetworkHelper 单例
 */
+ (JVCCloudSEESDK *)shareJVCCloudSEESDK;

/**
 *  初始化SDK
 */
-(void)initCloudSEESdk;


/**
 *  检测当前窗口连接是否已存在
 *
 *  @param nLocalChannel nLocalChannel description
 *
 *  @return YES:存在 NO:不存在
 */
-(BOOL)checknLocalChannelExistConnect:(int)nLocalChannel;

/**
 *  检测当前窗口视频是否已经显示
 *
 *  @param nLocalChannel nLocalChannel description
 *
 *  @return YES:存在 NO:不存在
 */
-(BOOL)checknLocalChannelIsDisplayVideo:(int)nLocalChannel;

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
-(BOOL)ystConnectVideobyDeviceInfo:(int)nLocalChannel nRemoteChannel:(int)nRemoteChannel strYstNumber:(NSString *)strYstNumber strUserName:(NSString *)strUserName strPassWord:(NSString *)strPassWord nSystemVersion:(int)nSystemVersion isConnectShowVideo:(BOOL)isConnectShowVideo withConnectType:(int)nConnectType withShowView:(id)showVew;

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
                     withShowView:(id)showVew;


/**
 *  断开连接（子线程调用）
 *
 *  @param nLocalChannel 本地视频窗口编号
 *
 *  @return YSE:断开成功 NO:断开失败
 */
-(BOOL)disconnect:(int)nLocalChannel;

/**
 *  远程控制指令(请求)
 *
 *  @param nLocalChannel          视频显示的窗口编号
 *  @param remoteOperationType    控制的类型
 *  @param remoteOperationCommand 控制的命令
 */
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommand:(int)remoteOperationCommand;


/**
 *  远程控制指令
 *
 *  @param nLocalChannel          视频显示的窗口编号
 *  @param remoteOperationCommand 控制的命令
 */
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationCommand:(int)remoteOperationCommand;

/**
 *  远程控制指令
 *
 *  @param nLocalChannel              视频显示的窗口编号
 *  @param remoteOperationType        控制的类型
 *  @param remoteOperationCommandData 控制的指令内容
 */
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandData:(char *)remoteOperationCommandData;

/**
 *  远程回放请求文件视频
 *
 *  @param nLocalChannel            视频显示窗口编号
 *  @param requestPlayBackFileInfo  远程文件的信息
 *  @param requestPlayBackFileDate  远程文件的日期
 *  @param requestPlayBackFileIndex 请求文件的索引
 */
-(void)RemoteRequestSendPlaybackVideo:(int)nLocalChannel requestPlayBackFileInfo:(NSMutableDictionary *)requestPlayBackFileInfo  requestPlayBackFileDate:(NSDate *)requestPlayBackFileDate requestPlayBackFileIndex:(int)requestPlayBackFileIndex;

/**
 *  远程回放请求文件视频
 *
 *  @param nLocalChannel           视频显示窗口编号
 *  @param withPlayBackPath        远程文件的路径
 */
-(void)RemoteRequestSendPlaybackVideo:(int)nLocalChannel withPlayBackPath:(NSString *)playBackVideoPath;


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
-(BOOL)ApConnectVideobyDeviceInfo:(int)nLocalChannel
                   nRemoteChannel:(int)nRemoteChannel
                   nSystemVersion:(int)nSystemVersion
               isConnectShowVideo:(BOOL)isConnectShowVideo
                  withConnectType:(int)nConnectType
                     withShowView:(id)showVew
                         userName:(NSString *)userName
                         password:(NSString *)passWord;


/**
 *  创建制定相册
 *  @param albumName 相册名
 */
- (void)creatPhotoAlbum:(NSString *)albumName;

/**
 *  开启本地录像
 *
 *  @param buttonState yes 开启 no关闭
 *  @param channel     通道号
 */
-(void)operationPlayVideo:(BOOL)buttonState channel:(int )channel;



#pragma mark 获取设备的wifi数据
/**
 *  获取设备的wifi列表
 *
 *  @param nChannel 通道号
 */
- (void)getDeviceWifiList:(int)nChannel;

/**
 *  开始配置
 *
 *  @param strWifiEnc      wifi的加密方式
 *  @param strWifiAuth     wifi的认证方式
 *  @param strWifiSSid     配置WIFI的SSID名称
 *  @param strWifiPassWord 配置WIFi的密码
 */
-(void)runApSetting:(NSString *)strWifiEnc strWifiAuth:(NSString *)strWifiAuth strWifiSSid:(NSString *)strWifiSSid strWifiPassWord:(NSString *)strWifiPassWord channel:(int )connectDefaultchannel;


/**
 *  透传协议，
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendComtrans:(int)nJvChannelID
                  content:(const char *) acBuffer
            contentLength:(int)length;

/**
 *  玩具协议开启AP请求
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendOpenAPRequest:(int)nJvChannelID;

/**
 *  玩具协议开启AP
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendOpenAPCmd:(int)nJvChannelID;

/**
 *  玩具协议开启STA请求
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendOpenSTARequest:(int)nJvChannelID;

/**
 *  玩具协议开启STA
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param content         发送的内容
 */
-(void)RemoteSendOpenSTACmd:(int)nJvChannelID;

/**
 *  玩具协议获取wifi信息
 *
 *  @param nJvChannelID    本地连接的通道号
 */
-(void)RemoteSendRequestCurrentNetworkInfo:(int)nJvChannelID;

/**
 *  玩具协议设备搜索wifi热点
 *
 *  @param nJvChannelID    本地连接的通道号
 */
-(void)RemoteSendDeviceSearchAP:(int)nJvChannelID;

/**
 *  OSD显示问题
 *
 *  @param nPosition    显示位置
 *  @param nTimePosition  是否隐藏
 */
-(void)RemoteSendOSDOperationToDevice:(int)nJvChannelID
                        nTextPosition:(int) nPosition
                        nTimePosition:(int)nTimePosition;

/**
 *  修改设备的用户名密码
 *
 *  @param nJVChannleID 本地连接的通道号
 *  @param userName     用户名
 *  @param passWord     密码
 */
- (void)RemoteSetToModifyDeviceInfo:(int)nLocalChannel
                       withUserName:(NSString *)userName
                       withPassWord:(NSString *)passWord;

/**
 *  获取设备的用户详细信息
 *
 *  @param nLocalChannel 本地连接的通道号
 */
- (void)RemoteGetDeviceAccount:(int)nLocalChannel;


/**
 *  设置小助手
 *
 *  @param deviceDguid 设备号
 *  @param userName 用户名
 *  @param passWord 密码
 */
-(void)setDevicesHelper:(NSString *)deviceDguid  userName:(NSString *)userName  passWord:(NSString *)passWord;

/**
 *  设置广播  搜索局域网设备的函数(本网段)
 */
- (void)JVCLanSearchDevice;

/**
 *  设置对讲的开启方式
 *
 *  @param voiceType     VoiceType_Speaker =0,//扬声器   VoiceType_Liseten =1,//听筒
 */
- (void)setPlaySountType:(int)voiceType;

//搜索局域网设备的函数（本局域网）
- (void)jvcLanSearchAllDeviceNetWork;

/**
 *  播放器资源初始化
 *
 *  @param playerView 供显示的UIView
 */
- (void)MP4PlayerInit:(UIView *)playerView;

/**
 *  播放器资源释放
 *
 *  @param playerView 供显示的UIView
 */
- (void)MP4PlayerRelease;


/**
 *  播放MP4文件
 *
 *  @param fileName 文件路径
 */
- (void)playMP4File:(NSString *)fileName;



@end
