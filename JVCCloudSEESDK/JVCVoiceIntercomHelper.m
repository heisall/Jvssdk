//
//  JVCVoiceIntercomHelper.m
//  CloudSEE
//  语音对讲中间层的处理类
//  Created by chenzhenyang on 14-9-17.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#import "JVCVoiceIntercomHelper.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVCAudioCodecInterface.h"
#import "JVCNPlayer.h"
#import <Foundation/Foundation.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <AVFoundation/AVFoundation.h>

@implementation JVCVoiceIntercomHelper


@synthesize   nAudioCollectionType;
@synthesize   jvcVoiceIntercomHelperDeleage;
@synthesize   isTalkMode;

AudioFrame    *audioFrame;
char          decodeAudioCache[76]     = {0};
char          pcmOutVoiceBuffer[1024]  = {0};

char          encodeAudioOutData[1024] = {0}; //语音对讲编码后的数据
JVCVoiceIntercomHelper *helperInstance = nil;
static JVCVoiceIntercomHelper *helper = nil;
JVCNPlayer* audiorecorder;

///**
// *  单例
// *
// *  @return 对象
// */
//+(JVCVoiceIntercomHelper *)shareJVCVoiceIntercomHelper
//{
//    @synchronized(self)
//    {
//        if (helper == nil) {
//
//            helper = [[self alloc] init];
//        }
//
//        return helper;
//    }
//
//    return helper;
//}
//
//+ (id)allocWithZone:(struct _NSZone *)zone
//{
//    @synchronized(self)
//    {
//        if (helper == nil) {
//
//            helper = [super allocWithZone:zone];
//
//            return helper;
//        }
//    }
//
//    return nil;
//}


-(id)init{
    
    if (self=[super init]) {
        
        audioFrame = (AudioFrame*)decodeAudioCache;
        audioFrame->iIndex=0;
    }
    
    return self;
}
-(void)stopDnoiseAudioRecord{
    [audiorecorder stopAudioPlayer];
    [audiorecorder release];
    audiorecorder = nil ;
    //    if (NULL != dummyFile2) {
    //        fclose(dummyFile2);
    //        dummyFile2 = NULL;
    //    }
}

-(BOOL)closeAudioDecoder{
    NSLog(@"closeAudioDecoder:voiceIntercomhelper........");
    BOOL result = [super closeAudioDecoder];
    
    if (result) {
        
        AQSController  *aqControllerobj = [AQSController shareAQSControllerobjInstance];
        
        [aqControllerobj stopRecord];
        aqControllerobj.delegate = nil;
    }
    [[OpenALBufferViewcontroller shareOpenALBufferViewcontrollerobjInstance] setNil];
    return result;
    
}

-(void)setHelperNil{
    helper = nil;
}

-(void)startDnoiseAudioRecord{
    if (audiorecorder) {
        [self stopDnoiseAudioRecord];
    }
    audiorecorder = [[JVCNPlayer alloc] init];
    [audiorecorder playerInit];
    [audiorecorder startRecordAudio:fetchd];
}
void fetchd(const unsigned char *data, size_t size, uint64_t ts) {
    printf("fetchd: %p, %ld, %llu\n", data, size, ts);
    
    //    NSData *audio_data = [NSData dataWithBytes:data length:size];
    //    [_library saveImageData:audio_data toAlbum:(NSString *)kKYCustomDownloadAlbumName metadata:nil completion:^(NSURL *assetURL, NSError *error) {
    //        NSLog(@"saveImageData success");
    //    } failure:^(NSError *error) {
    //        NSLog(@"saveImageData fail %@",error);
    //    }];
    
    [helperInstance receiveAudioDataCallBack:data audioDataSize:size];
    //    [[JVCVoiceIntercomHelper shareJVCVoiceIntercomHelper] receiveAudioDataCallBack:data audioDataSize:size];
}

- (void)dealAudioData:(const unsigned char *)data size:(int)size
{
    if (self.isTalkMode && !self.isRecoderState) {
        return;
    }
    
    //    if (NULL != dummyFile2) {
    //        fwrite(data, size, 1, dummyFile2);
    //    }
    
    if (self.jvcVoiceIntercomHelperDeleage != nil && [self.jvcVoiceIntercomHelperDeleage respondsToSelector:@selector(sendRecordAudioData:withAudioDataSize:)] ) {
        
        int nAudioSize = size;
        memset(encodeAudioOutData, 0, sizeof(encodeAudioOutData));
        BOOL isEncoderSuccessFul = [self encoderLocalRecorderData:data nEncodeAudioOutdataSize:&nAudioSize encodeOutAudioData:(char *)encodeAudioOutData encodeOutAudioDataSize:sizeof(encodeAudioOutData)];
        
        if (isEncoderSuccessFul) {
            
            [self.jvcVoiceIntercomHelperDeleage sendRecordAudioData:encodeAudioOutData withAudioDataSize:nAudioSize];
        }
    }
    
}

-(BOOL)openAudioDecoder:(int)nConnectDeviceType isExistStartCode:(BOOL)isExistStartCode{
    
    BOOL result = [super openAudioDecoder:nConnectDeviceType isExistStartCode:isExistStartCode];
    
    if (result) {
        AQSController *aqsControllerObj = [AQSController shareAQSControllerobjInstance];
        aqsControllerObj.delegate       = self;
        
        int nAudioBit                   = 0;
        int nAudioCollectionDataSize    = 0;
        
        [self getAudioCollectionBitAndDataSize:nConnectDeviceType isExistStartCode:isExistStartCode nAudioBit:&nAudioBit nAudioCollectionDataSize:&nAudioCollectionDataSize];
        [aqsControllerObj record:nAudioCollectionDataSize mChannelBit:nAudioBit];
        
    }
    
    return result;
}
/**
 *  设置音频采集的模式
 *
 *  @param state YES:采集发送 NO:采集不发送
 */
-(void)setRecordState:(BOOL)state{
    
    _isRecoderState = state;
    
    AQSController *aqsControllerObj = [AQSController shareAQSControllerobjInstance];
    
    [aqsControllerObj changeRecordState:_isRecoderState];
    
}

/**
 *  音频解码
 *
 *  @param nConnectDeviceType    连接的设备类型
 *  @param isExistStartCode      是否包含新帧头
 *  @param networkBuffer         音频数据
 *  @param nBufferSize           音频数据大小
 *
 *  @return YES 转换成功 NO:转换失败
 */
-(BOOL)convertSoundBufferByNetworkBuffer:(int)nConnectDeviceType isExistStartCode:(BOOL)isExistStartCode networkBuffer:(char *)networkBuffer nBufferSize:(int)nBufferSize  {
    
    if (self.isTalkMode && self.isRecoderState) {
        
        return FALSE;
    }
    int                                   nSize               = nBufferSize;
    
    BOOL                                  isDecoderAudioState = YES;
    BOOL                                  isAudioType         = YES;
    int                                   nAudioDataSize      = AudioSize_G711;
    
    switch (nConnectDeviceType) {
            
        case DEVICEMODEL_SoftCard:
        case DEVICEMODEL_HardwareCard_950:
        case DEVICEMODEL_HardwareCard_951:{
            
            int outLen;
            outLen = sizeof(pcmOutVoiceBuffer);
            
            DecodeAudioData(networkBuffer+16,nSize-16,pcmOutVoiceBuffer,&outLen);
            nAudioDataSize = outLen;
        }
            break;
        case DEVICEMODEL_DVR:{
            
            if (isExistStartCode) {
                
                unsigned char *audioPcmBuf = NULL;
                
                [self lock];
                JAD_DecodeOneFrame(0, networkBuffer,  &audioPcmBuf);
                [self unLock];
                
                memcpy(pcmOutVoiceBuffer, audioPcmBuf, AudioSize_G711);
                
            }else{
                
                memcpy(pcmOutVoiceBuffer, networkBuffer, AudioSize_G711);
                nAudioDataSize = nSize;
                isAudioType    = NO;
            }
        }
            break;
        case DEVICEMODEL_IPC:{
            
            if (isExistStartCode) {
                
                unsigned char *audioPcmBuf = NULL;
                
                [self lock];
                JAD_DecodeOneFrame(0, networkBuffer,  &audioPcmBuf);
                [self unLock];
                
                memcpy(pcmOutVoiceBuffer, audioPcmBuf, AudioSize_G711);
                
            }else{
                
                isDecoderAudioState = NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    /**
     *  语音对讲的播放函数
     */
    //    if (![self isHeadphone]) {
    //        return ;
    //    }
    if (isDecoderAudioState) {
        
        OpenALBufferViewcontroller *openAlObj = [OpenALBufferViewcontroller shareOpenALBufferViewcontrollerobjInstance];
        int                     playSoundType = isAudioType == YES ? playSoundType_8k16B : playSoundType_8k8B;
        switch (nConnectDeviceType) {
                
            case DEVICEMODEL_SoftCard:
            case DEVICEMODEL_HardwareCard_950:
            case DEVICEMODEL_HardwareCard_951:{
                for (int i=0; i<3; i++) {
                    
                    [openAlObj openAudioFromQueue:(short *)(pcmOutVoiceBuffer+i*320) dataSize:nAudioDataSize/3 playSoundType:playSoundType];
                }
                
            }
                break;
            case DEVICEMODEL_IPC:{
                BOOL isLongPressedStartTalk=[[NSUserDefaults standardUserDefaults] boolForKey:@"isLongPressedStartTalk"];
                BOOL isDoubleTalk=[[NSUserDefaults standardUserDefaults] boolForKey:@"isDoubleTalk"];
                if (!isDoubleTalk&&isLongPressedStartTalk) {
                    [openAlObj clear];
                }else{
                    [openAlObj clear];
                    [openAlObj openAudioFromQueue:(short *)pcmOutVoiceBuffer dataSize:nAudioDataSize playSoundType:playSoundType];
                }
            }
                break;
            default:{
                
                [openAlObj openAudioFromQueue:(short *)pcmOutVoiceBuffer dataSize:nAudioDataSize playSoundType:playSoundType];
            }
                break;
        }
    }
    
    return isDecoderAudioState;
}

#pragma mark -判断是否为耳机状态
- (BOOL)isHeadphone
{
    UInt32 propertySize = sizeof(CFStringRef);
    CFStringRef state = nil;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute
                            ,&propertySize,&state);
    //return @"Headphone" or @"Speaker" and so on.
    //根据状态判断是否为耳机状态
    if ([(NSString *)state isEqualToString:@"Headphone"] ||[(NSString *)state isEqualToString:@"HeadsetInOut"])
    {
        return YES;
    }
    else {
        return NO;
    }
}


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
-(BOOL)getAudioCollectionBitAndDataSize:(int)nConnectDeviceType isExistStartCode:(BOOL)isExistStartCode nAudioBit:(int *)nAudioBit nAudioCollectionDataSize:(int *)nAudioCollectionDataSize{
    
    
    BOOL result                    = TRUE;
    
    switch (nConnectDeviceType) {
            
        case DEVICEMODEL_SoftCard:
        case DEVICEMODEL_HardwareCard_950:
        case DEVICEMODEL_HardwareCard_951:{
            
            self.nAudioCollectionType = AudioType_AMR;
            
            *nAudioBit                           = AudioBit_AMR;
            *nAudioCollectionDataSize            = AudioSize_AMR;
        }
            break;
            
        case DEVICEMODEL_DVR:{
            
            if (isExistStartCode) {
                
                self.nAudioCollectionType = AudioType_G711;
                *nAudioBit                = AudioBit_G711;
                *nAudioCollectionDataSize = AudioSize_G711;
                
            }else{
                
                self.nAudioCollectionType = AudioType_PCM;
                *nAudioBit                = AudioBit_PCM;
                *nAudioCollectionDataSize = AudioSize_PCM;
            }
        }
            break;
        case DEVICEMODEL_IPC:{
            
            if (isExistStartCode) {
                
                self.nAudioCollectionType = AudioType_G711;
                *nAudioBit                = AudioBit_G711;
                *nAudioCollectionDataSize = AudioSize_G711;
                
            }else{
                
                result  = FALSE;
            }
        }
        default:
            break;
    }
    
    return result;
}

/**
 *  编码本地采集的音频数据
 *
 *  @param Audiodata               本地采集的音频数据
 *  @param nEncodeAudioOutdataSize 本地采集的音频数据大小，编码之后为编码的数据大小
 *  @param encodeOutAudioData      编码后的音频数据
 *
 *  @return 成功返回YES
 */
-(BOOL)encoderLocalRecorderData:(char *)Audiodata nEncodeAudioOutdataSize:(int *)nEncodeAudioOutdataSize encodeOutAudioData:(char *)encodeOutAudioData encodeOutAudioDataSize:(int)encodeOutAudioDataSize{
    
    BOOL isEncoderStatus  = TRUE;
    
    int  nAudiodataSize   =  *nEncodeAudioOutdataSize;
    
    switch (nAudiodataSize) {
            
        case AudioSize_PCM:{
            
            memcpy(encodeOutAudioData, Audiodata, AudioSize_PCM);
        }
            break;
            
        case AudioSize_G711:{
            
            [self lock];
            int nEncodeResultSize = JAD_EncodeOneFrame(0, (unsigned char*)Audiodata, encodeOutAudioData,AudioSize_G711);
            [self unLock];
            
            *nEncodeAudioOutdataSize = nEncodeResultSize;
        }
            break;
        case AudioSize_AMR:{
            
            int ndecoderAudioSize = encodeOutAudioDataSize;
            
            [self lock];
            EncodeAudioData(Audiodata,AudioSize_AMR,encodeOutAudioData,&ndecoderAudioSize);
            audioFrame->iIndex ++;
            memcpy(decodeAudioCache, audioFrame, sizeof(struct AudioFrame));
            //复制音频格式信息
            memcpy(decodeAudioCache + sizeof(struct AudioFrame),encodeOutAudioData,ndecoderAudioSize);
            
            memcpy(encodeOutAudioData, decodeAudioCache, ndecoderAudioSize +sizeof(struct AudioFrame));
            
            [self unLock];
            *nEncodeAudioOutdataSize = ndecoderAudioSize +sizeof(struct AudioFrame);
            
        }
            break;
            
        default:{
            
            isEncoderStatus = FALSE;
        }
            break;
    }
    
    return isEncoderStatus;
}



#pragma mark AQSController Deleage

-(void)receiveAudioDataCallBack:(char *)audionData audioDataSize:(long)audioDataSize{
    
    if (self.isTalkMode && !self.isRecoderState) {
        
        return;
    }
    
    if (self.jvcVoiceIntercomHelperDeleage != nil && [self.jvcVoiceIntercomHelperDeleage respondsToSelector:@selector(sendRecordAudioData:withAudioDataSize:)] ) {
        BOOL isLongPressedStartTalk=[[NSUserDefaults standardUserDefaults] boolForKey:@"isLongPressedStartTalk"];
        BOOL isDoubleTalk=[[NSUserDefaults standardUserDefaults] boolForKey:@"isDoubleTalk"];
        if (!isDoubleTalk&&!isLongPressedStartTalk) {
            return;
        }
        int nAudioSize = (int)audioDataSize;
        memset(encodeAudioOutData, 0, sizeof(encodeAudioOutData));
        BOOL isEncoderSuccessFul = [self encoderLocalRecorderData:audionData nEncodeAudioOutdataSize:&nAudioSize encodeOutAudioData:(char *)encodeAudioOutData encodeOutAudioDataSize:sizeof(encodeAudioOutData)];
        
        if (isEncoderSuccessFul) {
            
            [self.jvcVoiceIntercomHelperDeleage sendRecordAudioData:encodeAudioOutData withAudioDataSize:nAudioSize];
        }
    }
}

@end
