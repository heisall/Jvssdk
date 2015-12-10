//
//  JVCVoiceIntercomHelper.h
//  CloudSEE
//
//  Created by chenzhenyang on 14-9-17.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import "JVCPlaySoundHelper.h"
#import "AQSController.h"
//#import "JVCNPlayer.h"

@protocol JVCVoiceIntercomHelperDeleage <NSObject>

@optional

/**
 *  编码后采集的音频数据
 *
 *  @param encoderAudioData 编码的本地音频数据
 *  @param nSize            发送的数据大小
 */
-(void)sendRecordAudioData:(char *)encoderAudioData withAudioDataSize:(int)nSize;

@end
//extern JVCNPlayer *jvcNPlayer;
@interface JVCVoiceIntercomHelper : JVCPlaySoundHelper <receiveAudioDataDelegate>{

   int      nAudioCollectionType;     //语音对讲音频采集的类型
   BOOL     isTalkMode;               // FALSE:双向对讲 TRUE:单向对讲
    
    id <JVCVoiceIntercomHelperDeleage>  jvcVoiceIntercomHelperDeleage;
}

@property (nonatomic,assign) int  nAudioCollectionType;
@property (nonatomic,assign) BOOL isTalkMode;
@property (nonatomic,assign) BOOL isRecoderState; //YES:采集发送 NO:采集不发送
@property (nonatomic,assign) id<JVCVoiceIntercomHelperDeleage> jvcVoiceIntercomHelperDeleage;
//@property (nonatomic,assign) JVCNPlayer *audioNPlayer;
void fetchd(const unsigned char *data, size_t size, uint64_t ts);

/**
 *  打开语音对讲的采集模块
 *
 *  @param nConnectDeviceType       连接的设备类型
 *  @param isExistStartCode         设备是否包含新帧头
 *  @param nAudioBit                采集音频的位数 目前 8位或16位
 *  @param nAudioCollectionDataSize 采集音频的数据
 *
 *  @return 成功返回YES
 */
-(BOOL)getAudioCollectionBitAndDataSize:(int)nConnectDeviceType isExistStartCode:(BOOL)isExistStartCode nAudioBit:(int *)nAudioBit nAudioCollectionDataSize:(int *)nAudioCollectionDataSize;

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


@end
