//
//  AQSController.h
//  AQS
//
//  Created by Midfar Sun on 2/3/12.
//  Copyright 2012 midfar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol receiveAudioDataDelegate <NSObject>

@optional
/**
 *  分发音频采集数据的协议
 *
 *  @param audionData    采集的音频数据
 *  @param audioDataSize 采集音频数据的大小
 */
-(void)receiveAudioDataCallBack:(char *)audionData audioDataSize:(long)audioDataSize;

@end

@interface AQSController : NSObject {

    id <receiveAudioDataDelegate>delegate;
}

@property (nonatomic,assign) id <receiveAudioDataDelegate>delegate;

/**
 *  单例
 *
 *  @return 返回AQSController 单例
 */
+ (AQSController *)shareAQSControllerobjInstance;

/**
 *  开启音频采集
 *
 *  @param cacheBufSize 采集的大小
 *  @param mchannelBit  采集的模式 8bit 16bit
 */
- (void)record:(int)cacheBufSize mChannelBit:(int)mchannelBit;

/**
 *  停止采集
 */
- (void)stopRecord;
/**
 *  接收音频采集的回调函数
 *
 *  @param audioData    采集的音频数据
 *  @param audioDataSize 采集的音频数据的大小
 */
-(void)receiveAudioData:(char *)audioData audioDataSize:(long)audioDataSize;

/**
 *  长按对讲函数
 *
 *  @param recordState YES:采集不发送 NO:采集发送
 */
- (void)changeRecordState:(BOOL)recordState;
@end
