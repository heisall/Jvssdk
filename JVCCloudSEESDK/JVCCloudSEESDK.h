//
//  JVCCloudSEESDK.h
//  JVCCloudSEESDK
//
//  Created by chenzhenyang on 14-12-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>


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


@interface JVCCloudSEESDK : NSObject

@property(nonatomic,assign)id <JVCCloudSEESDKDelegate>            jvcCloudSEESDKDelegate;         //视频、连接信息
@property(nonatomic,assign)id <JVCRemotePlaybackVideoDelegate>    jvcRemotePlaybackVideoDelegate; //远程回放
@property(nonatomic,assign)id <JVCAudioDelegate>                  jvcAudioDelegate;               //音频代理

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

@end
