//
//  JVCCloudSEENetworkHelper.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCCloudSEEManagerHelper.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVNetConst.h"

@protocol ystNetWorkHelpDelegate <NSObject>

@optional

/**
 *  连接的回调代理
 *
 *  @param connectCallBackInfo 返回的连接信息
 *  @param nlocalChannel       本地通道连接从1开始
 *  @param connectType         连接返回的类型
 */
-(void)ConnectMessageCallBackMath:(NSString *)connectCallBackInfo nLocalChannel:(int)nlocalChannel connectResultType:(int)connectResultType;

/**
 *  OpenGL显示的视频回调函数
 *
 *  @param nLocalChannel             本地显示窗口的编号
 *  @param nPlayBackFrametotalNumber 回放的视频帧数
 */
-(void)H264VideoDataCallBackMath:(int)nLocalChannel  withPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber;

/**
 *  设备场景图片的代理
 *
 *  @param imageData      输出的图片
 *  @param nShowWindowID  显示视频的窗口ID
 */
-(void)sceneOutImageDataCallBack:(NSData *)imageData withLocalChannel:(int)nLocalChannel;

/**
 *  开始请求文本聊天的回调
 *
 *  @param nLocalChannel 本地显示窗口的编号
 *  @param nDeviceType   设备的类型
 *  @param isNvrDevice   是否是NVR设备
 */
-(void)RequestTextChatCallback:(int)nLocalChannel withDeviceType:(int)nDeviceType withIsNvrDevice:(BOOL)isNvrDevice;

/**
 *  开始请求文本聊天的回调
 *
 *  @param nLocalChannel 本地显示窗口的编号
 *  @param nDeviceModel  设备的类型 （YES：05）
 */
-(void)RequestTextChatIs05DeviceCallback:(int)nLocalChannel withDeviceModel:(BOOL)nDeviceModel;

/**
 *  文本聊天请求的结果回调
 *
 *  @param nLocalChannel 本地本地显示窗口的编号
 *  @param nStatus       文本聊天的状态
 */
-(void)RequestTextChatStatusCallBack:(int)nLocalChannel withStatus:(int)nStatus;

/**
 *  0帧解码成功，消失
 */
- (void)decodeIFrameSuccess;


@end

@protocol ystNetWorkAudioDelegate <NSObject>

@optional


/**
 *  语音对讲的回调
 *
 *  @param VoiceInterState 对讲的状态
 */
-(void)VoiceInterComCallBack:(int)VoiceInterState;

@end

@protocol ystNetWorkHelpRemoteOperationDelegate <NSObject>

@optional

/**
 *  获取当前连接通道的码流参数以及是否是家用IPC
 *
 *  @param nLocalChannel 本地连接通道编号
 *  @param nStreamType   码流类型  1:高清 2：标清 3：流畅 0:默认不支持切换码流
 *  @param isHomeIPC     YES是家用IPC
 *  @param effectType    图像翻转标志
 *  @param storageType   小于0不支持
 *  @param isNewHomeIPC  YES：新的家用IPC(MobileQuality这个字段做区分)
 */
-(void)deviceWithFrameStatus:(int)nLocalChannel withStreamType:(int)nStreamType withIsHomeIPC:(BOOL)isHomeIPC withEffectType:(int)effectType withStorageType:(int)storageType withIsNewHomeIPC:(BOOL)isNewHomeIPC withIsOldStreeamType:(int)nOldStreamType ytSpeed:(int)speed MobileCH:(int)MobileCH ModeByMicStatus:(int)ModeByMicStatus deviceType:(int)deviceType;

- (void)deviceWithFrameStatus:(int)nLocalChannel ytSpeed:(int)speed;

@end

@protocol ystNetWorkHelpRemotePlaybackVideoDelegate <NSObject>

@optional

/**
 *  远程回放状态回调
 *
 *  @param remoteplaybackState
 
     enum RemotePlayBackVideoStateType {
     
     RemotePlayBackVideoStateType_Succeed = 100, //远程回放成功
     RemotePlayBackVideoStateType_Stop    = 101, //远程回放停止
     RemotePlayBackVideoStateType_End     = 102, //远程回放结束
     RemotePlayBackVideoStateType_Failed  = 103, //远程回放失败
     RemotePlayBackVideoStateType_TimeOut = 104, //远程回放超时
     };
 */
-(void)remoteplaybackState:(int)remoteplaybackState;

/**
 *  获取远程回放检索文件列表的回调
 *
 *  @param playbackSearchFileListMArray 远程回放检索文件列表
 */
-(void)remoteplaybackSearchFileListInfoCallBack:(NSMutableArray *)playbackSearchFileListMArray;


/**
 *  远程下载文件的回调
 *
 *  @param downLoadStatus 下载的状态 
 
      JVN_RSP_DOWNLOADOVER  //文件下载完毕
      JVN_CMD_DOWNLOADSTOP  //停止文件下载
      JVN_RSP_DOWNLOADE     //文件下载失败
      JVN_RSP_DLTIMEOUT     //文件下载超时
 
 *  @param path           下载保存的路径
 */
-(void)remoteDownLoadCallBack:(int)downLoadStatus withDownloadSavePath:(NSString *)savepath;

@end

@protocol ystNetWorkHelpTextDataDelegate <NSObject>

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

@protocol  ystNetWorkHelpVideoDelegate <NSObject>

@optional

/**
 *   录像结束的回调函数
 *
 *  @param isContinue 是否结束后继续录像 YES：继续
 */
-(void)videoEndCallBack:(BOOL)isContinueVideo;

@end

@protocol JVCCloudSEENetworkHelperCaptureDelegate <NSObject>

/**
 *  抓拍图片的委托代理
 *
 *  @param imageData 图片的二进制数据
 */
-(void)captureImageCallBack:(NSData *)imageData;


@end

@protocol JVCCloudSEENetworkHelperDownLoadDelegate <NSObject>


/**
 *  远程文件下载的状态回调
 *
 *  @param downloadType 见枚举定义
 *  @param savePath     保存的路径
 */
-(void)playBackDownloadProgressState:(enum JVCCloudSEENetworkDownLoadState)downloadType withSavePath:(NSString *)savePath;

/**
 *  远程回放下载的进度
 *
 *  @param progress 进度值
 */

/**
 *  远程回放下载的进度
 *
 *  @param progress  每次回调的进度增值
 *  @param totalSize 文件的总大小
 */
-(void)playBackDownloadProgress:(int)progress withTotalSize:(int)totalSize;

@end

@interface JVCCloudSEENetworkHelper : NSObject <JVCCloudSEEManagerHelperDelegate>{

    id <ystNetWorkHelpDelegate>                      ystNWHDelegate;     //视频
    id <ystNetWorkHelpRemoteOperationDelegate>       ystNWRODelegate;    //远程请求操作
    id <ystNetWorkAudioDelegate>                     ystNWADelegate;     //音频
    id <ystNetWorkHelpRemotePlaybackVideoDelegate>   ystNWRPVDelegate;   //远程回放
    id <ystNetWorkHelpTextDataDelegate>              ystNWTDDelegate;    //文本聊天
    id <ystNetWorkHelpVideoDelegate>                 videoDelegate;      //录像
    id <JVCCloudSEENetworkHelperCaptureDelegate>     jvcCloudSEENetworkHelperCaptureDelegate;  //抓拍
    id <JVCCloudSEENetworkHelperDownLoadDelegate>    jvcCloudSEENetworkHelperDownLoadDelegate; //远程回放下载的
}

enum DEVICETYPE {
    
    DEVICETYPE_HOME  = 2,
    
};

enum DEVICETALKMODEL {
    
    DEVICETALKMODEL_Talk   = 1, // 1:设备播放声音，不采集声音
    DEVICETALKMODEL_Notalk = 0, // 0:设备采集 不播放声音
};

@property(nonatomic,assign)id <ystNetWorkHelpDelegate>                      ystNWHDelegate;
@property(nonatomic,assign)id <ystNetWorkHelpRemoteOperationDelegate>       ystNWRODelegate;
@property(nonatomic,assign)id <ystNetWorkAudioDelegate>                     ystNWADelegate;
@property(nonatomic,assign)id <ystNetWorkHelpRemotePlaybackVideoDelegate>   ystNWRPVDelegate;
@property(nonatomic,assign)id <ystNetWorkHelpTextDataDelegate>              ystNWTDDelegate;
@property(nonatomic,assign)id <ystNetWorkHelpVideoDelegate>                 videoDelegate;
@property(nonatomic,assign)id <JVCCloudSEENetworkHelperCaptureDelegate>     jvcCloudSEENetworkHelperCaptureDelegate; //抓拍
@property(nonatomic,assign)id <JVCCloudSEENetworkHelperDownLoadDelegate>    jvcCloudSEENetworkHelperDownLoadDelegate;

/**
 *  单例
 *
 *  @return 返回JVCCloudSEENetworkHelper 单例
 */
+ (JVCCloudSEENetworkHelper *)shareJVCCloudSEENetworkHelper;

/**
 *  初始化SDK
 *
 *  @param strLogPath     日志的路径
 *  @param isEnableHelper 是否启用小助手连接
 */
-(void)initCloudSEESdk:(NSString *)strLogPath withEnableHelper:(BOOL)isEnableHelper;

/**
 *  网络获取设备的通道数
 *
 *  @param ystNumber 云视通号
 *  @param nTimeOut  请求超时时间
 *
 *  @return 设备的通道数
 */
-(int)WanGetWithChannelCount:(NSString *)ystNumber nTimeOut:(int)nTimeOut;

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
-(BOOL)ystConnectVideobyDeviceInfo:(int)nLocalChannel nRemoteChannel:(int)nRemoteChannel strYstNumber:(NSString *)strYstNumber strUserName:(NSString *)strUserName strPassWord:(NSString *)strPassWord nSystemVersion:(int)nSystemVersion isConnectShowVideo:(BOOL)isConnectShowVideo withConnectType:(int)nConnectType withShowView:(UIView *)showVew;

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
                     withShowView:(UIView *)showVew
                         tcpState:(BOOL)tcpState;

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
//获得SD卡信息
-(void)getSDInforWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
//获取基本信息
-(void)getBasicInforWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
//设置移动侦测灵敏度
-(void)remoteOperationSetSensitivityDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandStr:(NSString *)remoteOperationCommand;
//读取移动侦测灵敏度
-(void)remoteOperationReadSensitivityDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
//停止录像
-(void)stopVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
-(void)stopOldVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
-(void)startOldVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
//报警录像
-(void)AlarmVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
//手动录像
-(void)ManualVedioWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
//格式化sd
-(void)FormatSDWith:(int)nLocalChannel remoteOperationType:(int)remoteOperationType;
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandStr:(NSString *)remoteOperationCommand;
/**
 *  远程控制指令(文本聊天)
 *
 *  @param nLocalChannel          视频显示的窗口编号
 *  @param dicCommand             控制的命令
 */
-(void)RemoteOperationAtTextChatSendDataToDevice:(int)nLocalChannel withDicCommand:(NSDictionary *)dicCommand;

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
 *  @param nRequestCount              请求的次数
 */
-(void)RemoteOperationSendDataToDevice:(int)nLocalChannel remoteOperationType:(int)remoteOperationType remoteOperationCommandData:(char *)remoteOperationCommandData nRequestCount:(int)nRequestCount;

/**
 *  开启录像
 *
 *  @param nLocalChannel      连接的本地通道号
 *  @param saveLocalVideoPath 录像文件存放的地址
 */
-(void)openRecordVideo:(int)nLocalChannel saveLocalVideoPath:(NSString *)saveLocalVideoPath;

/**
 *  关闭本地录像
 *
 *  @param nLocalChannel 本地连接的通道地址
 *  @param isContinue    是否停止后继续录像
 */
-(void)stopRecordVideo:(int)nLocalChannel withIsContinueVideo:(BOOL)isContinue;


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
-(void)RemoteSetWiredNetwork:(int)nLocalChannel nIsEnableDHCP:(int)nIsEnableDHCP strIpAddress:(NSString *)strIpAddress strSubnetMask:(NSString *)strSubnetMask strDefaultGateway:(NSString *)strDefaultGateway strDns:(NSString *)strDns;

/**
 *  配置设备的无线网络(老的配置方式)
 *
 *  @param nLocalChannel   本地连接的编号
 *  @param strSSIDName     配置的热点名称
 *  @param strSSIDPassWord 配置的热点密码
 *  @param strWifiAuth     热点的认证方式
 *  @param strWifiEncryp   热点的加密方式
 */
-(void)RemoteOldSetWiFINetwork:(int)nLocalChannel strSSIDName:(NSString *)strSSIDName strSSIDPassWord:(NSString *)strSSIDPassWord strWifiAuth:(NSString *)strWifiAuth strWifiEncrypt:(NSString *)strWifiEncrypt;


/**
 *  配置设备的无线网络(新的配置方式)
 *
 *  @param nLocalChannel   本地连接的编号
 *  @param strSSIDName     配置的热点名称
 *  @param strSSIDPassWord 配置的热点密码
 *  @param nWifiAuth       热点的认证方式
 *  @param nWifiEncryp     热点的加密方式
 */
-(void)RemoteNewSetWiFINetwork:(int)nLocalChannel strSSIDName:(NSString *)strSSIDName strSSIDPassWord:(NSString *)strSSIDPassWord nWifiAuth:(int)nWifiAuth nWifiEncrypt:(int)nWifiEncrypt;

#pragma mark ------ 满帧和全帧的切换 针对所有视频所有视频

/**
 *  远程控制指令 发送所有连接的 全帧和I的切换
 *
 *  @param isOnltIFrame YES:只发I帧
 */
-(void)RemoteOperationSendDataToDeviceWithfullOrOnlyIFrame:(BOOL)isOnltIFrame;

/**
 *  远程下载命令
 *
 *  @param nLocalChannel 视频显示的窗口编号
 *  @param downloadPath  视频下载的地址
 *  @param SavePath      保存的路径
 */
-(void)RemoteDownloadFile:(int)nLocalChannel withDownLoadPath:(char *)downloadPath  withSavePath:(NSString *)SavePath;

/**
 *  返回是否有当前通道的链接状态
 *
 *  @param nLocalChannel Channel号
 *
 *  @return yes 有  no 没有
 */
- (BOOL)returnCurrentLintState:(int)nLocalChannel;

/**
 *  删除门磁和手环报警
 *
 *  @param nLocalChannel 本地连接通道号
 *  @param alarmType     报警的类型
 *  @param alarmGuid     报警的唯一标示
 */
-(void)RemoteDeleteDeviceAlarm:(int)nLocalChannel withAlarmType:(int)alarmType  withAlarmGuid:(int)alarmGuid;

/**
 *  编辑门磁和手环报警
 *
 *  @param nLocalChannel 本地连接通道号
 *  @param alarmType     报警的类型
 *  @param alarmGuid     报警的唯一标示
 *  @param alarmEnable   报警是否开启
 *  @param alarmName     报警的别名
 */
-(void)RemoteEditDeviceAlarm:(int)nLocalChannel withAlarmType:(int)alarmType  withAlarmGuid:(int)alarmGuid withAlarmEnable:(int)alarmEnable withAlarmName:(NSString *)alarmName;

/**
 *  设置安全防护时间段
 *
 *  @param nLocalChannel  本地通道
 *  @param strBeginTime   开始时间
 *  @param strEndTime     结束时间
 */
-(void)RemoteSetAlarmTime:(int)nLocalChannel withstrBeginTime:(NSString *)strBeginTime withStrEndTime:(NSString *)strEndTime;

/**
 *  修改设备的用户名密码
 *
 *  @param nJVChannleID 本地连接的通道号
 *  @param userName     用户名
 *  @param passWord     密码
 */
- (void)RemoteSetToModifyDeviceInfo:(int)nLocalChannel  withUserName:(NSString *)userName withPassWord:(NSString *)passWord   describeString:(NSString *)describe;

/**
 *  获取设备的用户详细信息
 *
 *  @param nLocalChannel 本地连接的通道号
 */
- (void)RemoteGetDeviceAccount:(int)nLocalChannel;

/**
 *  OpenGL 放大或缩小(主线程)
 *
 *  @param nLocalChannel 远程本地编号
 *  @param x             缩放显示居中的x
 *  @param y             缩放显示居中的y
 *  @param isMaxScale    是否放大或缩小
 */
-(void)RemoteSetOpenGLScale:(int)nLocalChannel withCenterX:(float)x withCenterY:(float)y;


/**
 *  OpenGL 放大还原（主线程）
 *
 *  @param nLocalChannel 远程本地编号
 */
-(void)RemoteRestoreGlViewFrame:(int)nLocalChannel;

/**
 *  OpenGL 改变窗口的大小（主线程）
 *
 *  @param nLocalChannel 远程本地编号
 */
-(void)RemoteSetGlViewFrame:(int)nLocalChannel;

/*
 *  设置OpenGL画布是否允许手势交互
 *
 *  @param nLocalChannel 远程本地通道号
 *  @param enabled       YES：允许
 */
-(void)RemoteSetGlViewUserInteractionEnabled:(int)nLocalChannel withEnabled:(BOOL)enabled;

#pragma mark 远程回放下载
-(void)RemoteDownloadFile:(int)nLocalChannel withSavePath:(NSString *)SavePath  requestPlayBackFileInfo:(NSMutableDictionary *)requestPlayBackFileInfo  requestPlayBackFileDate:(NSDate *)requestPlayBackFileDate requestPlayBackFileIndex:(int)requestPlayBackFileIndex;

/**
 *  判断一个连接的设备录像是否是Mp4文件
 *
 *  @param nLocalChannel 远程本地通道号
 *
 *  @return YES：是
 */
-(BOOL)isMp4FileOfLoaclChannelID:(int)nLocalChannel;

/**
 *  关闭写文件
 */
- (void)closeDownloadHandle;

/**
 *  设置远程下载的状态
 *
 *  @param downState 远程下载状态， yes 取消下载  no 默认值
 */
- (void)setDownState:(BOOL )downState;


/**
 *  获取设备的类型
 *
 *  @param nLocalChannel 远程本地通道号
 *
 *  @return int：设备类型
 */
- (int)getDeviceType:(int)nLocalChannel;

/**
 *  获取设备是否是nvr的类型
 *
 *  @param nLocalChannel 远程本地通道号
 *
 *  @return bool：NVR yes   ；no 不是nvr
 */
- (BOOL)getDeviceIsNVRType:(int)nLocalChannel;

/**
 *  远程控制指令
 *
 *  @param nLocalChannel          控制本地连接的通道号
 *  @param remoteOperationType    控制的类型
 *  @param remoteOperationCommand 控制的命令
 *  @param  speedValue            速度
 */
-(void)RemoteYTOperationSendDataToDevice:(int)nLocalChannel
                     remoteOperationType:(int)remoteOperationType
                  remoteOperationCommand:(int)remoteOperationCommand
                                   speed:(int)speedValue;


-(int)getCurrentChannelVideoDecoderID:(int)nLocalChannel;
-(JVCCloudSEEManagerHelper *)returnCurrentChannelBynLocalChannel:(int)nLocalChannel;
@end
