//
//  JVCCloudSEENetworkGeneralHelper.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCCloudSEENetworkGeneralHelper : NSObject

/**
 *  单例
 *
 *  @return 返回JVCCloudSEENetworkGeneralHelper单例
 */
+ (JVCCloudSEENetworkGeneralHelper *)shareJVCCloudSEENetworkGeneralHelper;

/**
 *  判断设备传来的O帧是新帧头还是旧帧头 新的返回TRUE
 *
 *  @param pBuffer O帧数据
 *  @param dwSize  大小
 *
 *  @return 新的返回TRUE
 */
-(bool)IsFILE_HEADER_EX:(void *)pBuffer dwSize:(uint32_t)dwSize;

/**
 *  判断是否带针头
 *
 *  @param buffer 视频数据
 *
 *  @return YES:存在 NO:FALSE
 */
-(BOOL)isKindOfBufInStartCode:(char*)buffer;


/**
 *  获取当前连接设备的StartCode、宽、高
 *
 *  @param buffer_O O 帧数据
 *
 */
-(void)getBufferOInInfo:(char *)buffer_O startCode:(int *)startCode videoWidth:(int *)videoWidth videoHeight:(int *)videoHeight;

/**
 *  获取当前连接设备是否是NVR设备
 *
 *  @param buffer_O O帧数据
 *
 *  @return YES：NVR NO:不是
 */
-(BOOL)checkDeviceIsNvrDevice:(char *)buffer_O;


/**
 *  判断连接的设备类型
 *
 *  @param startCode 设备编号
 *
 *  @return DEVICEMODEL枚举
 */
-(int)checkConnectDeviceModel:(int)startCode;

/**
 *  获取连接设备视频的帧速率
 *
 *  @param startCode     设备的编号
 *  @param buffer_O      O帧数据
 *  @param buffer_O_size O帧数据
 *
 *  @return 视频的帧速率
 */
-(double)getPlayVideoframeFrate:(int)startCode buffer_O:(char *)buffer_O buffer_O_size:(int)buffer_O_size nAudioType:(int *)nAudionType;

/**
 *  根据云视通号获取云视通组号和编号
 *
 *  @param YstNumberString 云视通号
 *  @param strYstgroup     云视通组号
 *  @param nYstNumber      云视通的编号
 */
-(void)getYstGroupStrAndYstNumberByYstNumberString:(NSString *)YstNumberString strYstgroup:(NSString **)strYstgroup nYstNumber:(int *)nYstNumber;

/**
 *  转换连接失败的详细情况
 *
 *  @param ConnectResultInfo 连接返回的信息
 *  @param conenctResultType 连接返回的类型
 */
-(void)getConnectFailedDetailedInfoByConnectResultInfo:(NSString *)ConnectResultInfo conenctResultType:(int *)conenctResultType;

/**
 *  判断当前连接设备视频中是否包含帧头（主控采用05版编码的才生效）
 *
 *  @param startCode     设备的编号
 *  @param buffer_O      O帧数据
 *  @param buffer_O_size O帧数据大小
 *
 *  @return 包含返回 YES 否则：NO
 */
-(BOOL)checkConnectVideoInExistStartCode:(int)startCode buffer_O:(char *)buffer_O buffer_O_size:(int)buffer_O_size;


/**
 *  判断当前主控采用的编码器版本 05或04
 *
 *  @param startCode     设备的编号
 *
 *  @return 05返回YES 否则返回NO
 */
-(BOOL)checkConnectDeviceEncodModel:(int)startCode;

/**
 *  判断传输的视频数据是否为标准的视频数据
 *
 *  @param videoBuffer 网络传输的视频数据
 *
 *  @return YES:标准 NO:非标准
 */
-(BOOL)checkVideoDataIsH264:(char *)videoBuffer;

/**
 *   获取远程回放视频的 帧速率 、总帧数 、宽、高
 *
 *  @param buffer_O      O帧数据
 *  @param buffer_O_size O帧数据大小
 *  @param videoWidth    视频的宽
 *  @param videoHeight   视频的高
 *  @param dFrameRate    远程文件的帧速率
 *
 *  @return 回放文件的总帧数
 */
-(int)getRemotePlaybackTotalFrameAndframeFrate:(char *)buffer_O buffer_O_size:(int)buffer_O_size videoWidth:(int *)videoWidth videoHeight:(int *)videoHeight dFrameRate:(double *)dFrameRate;

/**
 *  将网络库传的key-value的buffer数据转成字典
 *
 *  @param pBuffer key-value
 *
 *  @return key-value字典
 */
-(NSMutableDictionary *)convertpBufferToMDictionary:(char *)pBuffer;

/**
 *  将网络库传的key-value的buffer数据转成字典
 *
 *  @param pBuffer key-value
 *
 *  @return key-value字典
 */
-(NSMutableDictionary *)convertpBufferNoUtf8ToMDictionary:(char *)pBuffer;

/**
 *  将网络库传的key-value的buffer数据转成字典
 *
 *  @param pBuffer key-value
 *
 *  @return key-value字典
 */
-(NSMutableString *)findBufferInExitValueToByKey:(char *)pBuffer nameBuffer:(char *)nameBuffer;

/**
 *  获取指定通道的马流参数信息
 *
 *  @param pBuffer       配置信息
 *  @param nChannelValue 指定通道
 *
 *  @return 指定通道的参数信息
 */
-(NSMutableDictionary *)getFrameParamInfoByChannel:(char *)pBuffer nChannelValue:(int)nChannelValue;

/**
 *  将设备的链接用户名密码数组转成字典
 *
 *  @param pBuffer key-value
 *
 *  @return 存放的数组集合
 */
-(NSMutableArray *)convertAccountBufferToArray:(char *)pBuffer;

@end
