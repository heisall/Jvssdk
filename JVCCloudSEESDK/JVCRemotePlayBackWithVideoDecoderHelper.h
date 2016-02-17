//
//  JVCRemotePlayBackWithVideoDecoderHelper.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCVideoDecoderHelper.h"

@interface JVCRemotePlayBackWithVideoDecoderHelper : JVCVideoDecoderHelper {
    
    int nPlayBackFrametotalNumber;  //远程回放的视频文件的总帧数
}

@property (nonatomic,assign) int  nPlayBackFrametotalNumber;

/**
 *  根据远程回放检索回调返回的Buffer 获取 远程回放文件列表信息
 *
 *  @param currentChannelObj            当前连接窗口对应的对象
 *  @param remotePlaybackFileBuffer     远程回放检索回调返回的Buffer
 *  @param remotePlaybackFileBufferSize 远程回放检索回调返回的Buffer的大小
 *  @param nRemoteChannel               连接的远程通道
 *
 *  @return 远程回放文件列表信息
 */
-(NSMutableArray *)convertRemoteplaybackSearchFileListInfoByNetworkBuffer:(int)nConnectDevcieType remotePlaybackFileBuffer:(char *)remotePlaybackFileBuffer remotePlaybackFileBufferSize:(int)remotePlaybackFileBufferSize ystGroup:(NSString*) ystGroup nRemoteChannel:(int)nRemoteChannel;

/**
 *  获取请求远程回放的一条命令
 *
 *  @param nConnectDevcieType        连接的设备类型
 *  @param requestPlayBackFileInfo   当前选中的远程回放的远程文件信息
 *  @param requestPlayBackFileDate   远程回放的日期
 *  @param requestPlayBackFileIndex  当前选中的远程文件列表的索引
 *  @param requestOutCommand         输出的发送命令
 */
-(void)getRequestSendPlaybackVideoCommand:(int)nConnectDevcieType requestPlayBackFileInfo:(NSMutableDictionary *)requestPlayBackFileInfo requestPlayBackFileDate:(NSDate *)requestPlayBackFileDate nRequestPlayBackFileIndex:(int)nRequestPlayBackFileIndex requestOutCommand:(char *)requestOutCommand;
@end
