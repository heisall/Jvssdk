//
//  JVCCloudSEEManagerHelper.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCQueueHelper.h"
#import "JVCVideoDecoderHelper.h"
#import "JVCAudioQueueHelper.h"
#import "JVCRecordVideoHelper.h"
#import "JVCVoiceIntercomHelper.h"

@class JVCRemotePlayBackWithVideoDecoderHelper;
@class JVCPlaySoundHelper;

@protocol JVCCloudSEEManagerHelperDelegate <NSObject>

/**
 *  解码返回的数据
 *
 *  @param decoderOutVideoFrame       解码返回的数据
 *  @param nPlayBackFrametotalNumber  远程回放的总帧数
 *  @param isVideoType                YES：05 NO：04
 */
-(void)decoderOutVideoFrameCallBack:(DecoderOutVideoFrame *)decoderOutVideoFrame nPlayBackFrametotalNumber:(int)nPlayBackFrametotalNumber ;

/**
 *  抓拍图片
 *
 *  @param captureOutImageData 抓拍的图片数据
 *  @param nShowWindowID       显示视频窗口的编号
 */
-(void)JVCCloudSEEManagerHelperCaptureImageData:(NSData *)captureOutImageData withShowWindowID:(int)nShowWindowID;

@end

@interface JVCCloudSEEManagerHelper : NSObject <JVCQueueHelperDelegate,JVCVideoDecoderHelperDelegate,
JVCAudioQueueHelperDelegate,JVCVoiceIntercomHelperDeleage>{
    
    int                    nLocalChannel;       //本地连接的通道号与显示视频窗口的编号对应(每轮1～16)
    NSString             * strYstGroup;	        //云视通编组号
	int                    nYstNumber;	        //云视通号码
    NSString             * strRemoteIP;         //远程ip地址
	int                    nRemotePort;	        //远程端口
	int                    nRemoteChannel;      //连接设备的通道号（大于0有效）
	NSString             * strUserName;         //用户名
	NSString             * strPassWord;         //密码
    BOOL                   linkModel;           //YES:IP直连 NO:YST
    int                    nConnectDeviceType;  //连接的设备类型
    BOOL                   isRunDisconnect;     //是否断开标志 YES:断开连接，不解码 NO:正常连接
    int                    nShowWindowID;       //连接显示的窗口编号 -1用于回调处理
    BOOL                   isAudioListening;    //是否在音频监听   YES：正在音频监听
    BOOL                   isVoiceIntercom;     //YES:正在语音对讲 NO:未开启
    BOOL                   isPlaybackVideo;     //YES:正在远程回放
    int                    nConnectStartCode;   //设备的StartCode
    BOOL                   isDisplayVideo;      //是否已经显示过图像 YES:显示过
    int                    nSystemVersion;      //当前手机的操作系统版本
    BOOL                   isTcp;               //是否tcp连接 1 tcp  0 UDp

    BOOL                   isOnlyIState;        //是否是只发I帧状态 YES:是
    BOOL                   isVideoPause;        //视频是否暂停过    YES:是
    BOOL                   isConnectShowVideo;  //连接是否显示视频 默认显示
    int                    nConnectType;        //连接类型
    BOOL                   isHomeIPC;           //是否是家用IPC YES: 是
    BOOL                   isTextChat;          //YES正在文本聊天
    int                    videoCodecID;         //视频格式
    
    JVCVideoDecoderHelper                   * decodeModelObj;      //解码器属性类
    JVCRemotePlayBackWithVideoDecoderHelper * playBackDecoderObj;  //远程回放解码器属性类
    JVCQueueHelper                          * jvcQueueHelper;      //缓存队列对象
    id<JVCCloudSEEManagerHelperDelegate>      delegate;
    JVCPlaySoundHelper                      * jvcPlaySound;        //音频监听处理对象
    JVCAudioQueueHelper                     * jvcAudioQueueHelper; //音频的缓存队列
    JVCVoiceIntercomHelper                  * jvcVoiceIntercomHelper; //语音对讲处理模块
    JVCRecordVideoHelper                    * jvcRecodVideoHelper;    //本地录像处理模块
    BOOL                  isNvrDevice;          //是否是NVR设备
    
    UIView                *showView;     // 显示的视频窗口
}

@property (nonatomic,assign) int                      nLocalChannel;
@property (nonatomic,retain) NSString               * strYstGroup;
@property (nonatomic,assign) int                      nYstNumber;
@property (nonatomic,retain) NSString               * strRemoteIP;
@property (nonatomic,assign) int                      nRemotePort;
@property (nonatomic,assign) int                      nRemoteChannel;
@property (nonatomic,retain) NSString               * strUserName;
@property (nonatomic,retain) NSString               * strPassWord;
@property (nonatomic,assign) BOOL                     linkModel;
@property (nonatomic,assign) int                      nConnectDeviceType;
@property (nonatomic,assign) int                      nShowWindowID;
@property (nonatomic,assign) BOOL                     isRunDisconnect;
@property (nonatomic,assign) BOOL                     isAudioListening;
@property (nonatomic,assign) BOOL                     isVoiceIntercom;
@property (nonatomic,assign) BOOL                     isPlaybackVideo;
@property (nonatomic,assign) int                      nConnectStartCode;
@property (nonatomic,assign) BOOL                     isDisplayVideo;
@property (nonatomic,assign) int                      nSystemVersion;
@property (nonatomic,assign) BOOL                     isOnlyIState;
@property (nonatomic,assign) BOOL                     isVideoPause;
@property (nonatomic,assign) BOOL                     isConnectShowVideo;
@property (nonatomic,assign) int                      nConnectType;
@property (nonatomic,assign) BOOL                     isHomeIPC;
@property (nonatomic,assign) BOOL                     isTcp;
@property (nonatomic,assign) int                      videoCodecID;
@property (nonatomic,retain) JVCVideoDecoderHelper                     * decodeModelObj;
@property (nonatomic,retain) JVCRemotePlayBackWithVideoDecoderHelper   * playBackDecoderObj;
@property (nonatomic,retain) JVCQueueHelper                            * jvcQueueHelper;
@property (nonatomic,retain) JVCQueueHelper                            * jvcRemoteQueueHelper;
@property (nonatomic,assign) id<JVCCloudSEEManagerHelperDelegate>        jvConnectDelegate;
@property (nonatomic,retain) JVCPlaySoundHelper                        * jvcPlaySound;
@property (nonatomic,retain) JVCAudioQueueHelper                       * jvcAudioQueueHelper;    //音频的缓存队列
@property (nonatomic,retain) JVCVoiceIntercomHelper                    * jvcVoiceIntercomHelper; //语音对讲处理模块
@property (nonatomic,retain) JVCRecordVideoHelper                      * jvcRecodVideoHelper;    //本地录像处理模块
@property (nonatomic,assign) BOOL                     isNvrDevice;
@property (nonatomic,retain) UIView                   *showView;     // 显示的视频窗口

/**
 *  连接的工作线程
 */
-(void)connectWork;

/**
 *  退出缓存队列
 */
-(void)exitQueue;

/**
 *  断开远程连接
 */
-(void)disconnect;

#pragma mark ----------------  JVCQueueHelper 处理模块

/**
 *  启动缓存队列出队线程
 */
-(void)startPopVideoDataThread;

/**
 *  开启音频数据出队线程
 */
-(void)startPopAudioDataThread;

/**
 *  缓存队列的入队函数 （视频）
 *
 *  @param videoData         视频帧数据
 *  @param nVideoDataSize    数据数据大小
 *  @param isVideoDataIFrame 视频是否是关键帧
 *  @param isVideoDataBFrame 视频是否是B帧
 *  @param frameType         视频数据类型
 */
-(void)pushVideoData:(unsigned char *)videoData nVideoDataSize:(int)nVideoDataSize isVideoDataIFrame:(BOOL)isVideoDataIFrame isVideoDataBFrame:(BOOL)isVideoDataBFrame frameType:(int)frameType;



#pragma mark  解码处理模块

/**
 *  打开解码器
 */
-(void)openVideoDecoder;


/**
 *  根据视频的宽高 初始化frame大小
 *
 *  @param width  <#width description#>
 *  @param height height description
 */
-(void)initFrameSizeByWidth:(int)width ByHeight:(int) height;

/**
 *  关闭解码器
 *
 *  @param nVideoDecodeID 解码器编号
 */
-(void)closeVideoDecoder;

/**
 *  还原解码器参数
 */
-(void)resetVideoDecoderParam;

/**
 *  抓拍图像
 */
-(void)startWithCaptureImage;

/**
 *  场景图像
 */
-(void)startWithSceneImage;

#pragma mark 远程回放处理模块

/**
 *  根据远程回放检索回调返回的Buffer 获取 远程回放文件列表信息
 *
 *  @param remotePlaybackFileBuffer     远程回放检索回调返回的Buffer
 *  @param remotePlaybackFileBufferSize 远程回放检索回调返回的Buffer的大小
 *
 *  @return 远程回放文件列表信息
 */
-(NSMutableArray *)getRemoteplaybackSearchFileListInfoByNetworkBuffer:(char *)remotePlaybackFileBuffer remotePlaybackFileBufferSize:(int)remotePlaybackFileBufferSize;

/**
 *  获取请求远程回放的一条命令
 *
 *  @param requestPlayBackFileInfo   当前选中的远程回放的远程文件信息
 *  @param requestPlayBackFileDate   远程回放的日期
 *  @param requestPlayBackFileIndex  当前选中的远程文件列表的索引
 *  @param requestOutCommand         输出的发送命令
 */
-(void)getRequestSendPlaybackVideoCommand:(NSMutableDictionary *)requestPlayBackFileInfo requestPlayBackFileDate:(NSDate *)requestPlayBackFileDate nRequestPlayBackFileIndex:(int)nRequestPlayBackFileIndex requestOutCommand:(char *)requestOutCommand;

/**
 *  判断录像文件是否是Mp4文件
 *
 *  @param nConnectDevcieType 链接的设备类型
 *
 *  @return YES：是 NO:不是
 */
-(BOOL)isMp4File;


#pragma mark 音频监听处理模块

/**
 *  设置音频类型
 *
 *  @param nAudioType 音频的类型
 */
-(void)setAudioType:(int)nAudioType;

/**
 *   打开音频解码器
 */
-(void)openAudioDecoder;

/**
 *  关闭音频解码
 */
-(void)closeAudioDecoder;

#pragma mark 音频缓存队列处理模块

/**
 *  缓存队列的入队函数(音频)
 *
 *  @param videoData         视频帧数据
 *  @param nVideoDataSize    数据数据大小
 *  @param isVideoDataIFrame 视频是否是关键帧
 */
-(void)pushAudioData:(unsigned char *)audioData nAudioDataSize:(int)nAudioDataSize;

#pragma mark 语音对讲处理

/**
 *   打开音频解码器
 */
-(void)openVoiceIntercomDecoder;

/**
 *  设置采集模块大工作模式
 *
 *  @param type YES:采集不发送（针对家用） NO:采集发送
 */
-(void)setVoiceIntercomMode:(BOOL)type;

/**
 *  打开语音对讲的采集模块
 *
 *  @param nAudioBit                采集音频的位数 目前 8位或16位
 *  @param nAudioCollectionDataSize 采集音频的数据
 *
 *  @return 成功返回YES
 */
-(BOOL)getAudioCollectionBitAndDataSize:(int *)nAudioBit nAudioCollectionDataSize:(int *)nAudioCollectionDataSize;

/**
 *  编码本地采集的音频数据
 *
 *  @param Audiodata               本地采集的音频数据
 *  @param nEncodeAudioOutdataSize 本地采集的音频数据大小，编码之后为编码的数据大小
 *  @param encodeOutAudioData      编码后的音频数据
 *
 *  @return 成功返回YES
 */
-(BOOL)encoderLocalRecorderData:(char *)Audiodata nEncodeAudioOutdataSize:(int *)nEncodeAudioOutdataSize encodeOutAudioData:(char *)encodeOutAudioData encodeOutAudioDataSize:(int)encodeOutAudioDataSize;

/**
 *  关闭音频解码
 */
-(void)closeVoiceIntercomDecoder;

#pragma mark 录像处理模块

/**
 *  打开录像的编码器
 *
 *  @param strRecordVideoPath 录像的地址
 *  @param nRecordChannelID   录像的通道号
 *  @param nWidth             录像视频的宽
 *  @param nHeight            录像视频的高
 *  @param dRate              录像的帧率
 */
-(void)openRecordVideo:(NSString *)strRecordVideoPath;

/**
 *  停止录像
 */
-(void)stopRecordVideo;


@end
