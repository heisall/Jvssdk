//
//  JVCPlaySoundHelper.m
//  CloudSEE_II
//  音频监听的助手类 用于处理网路库的数据进行解码播放
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCPlaySoundHelper.h"
#import "JVCAudioCodecInterface.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVCCloudSEENetworkGeneralHelper.h"
#import "JVNetConst.h"
#import <pthread.h>

@interface JVCPlaySoundHelper () {
    
   pthread_mutex_t  mutex;
}

@end

@implementation JVCPlaySoundHelper
@synthesize nAudioType,isOpenDecoder;
char          pcmOutBuffer[1024] = {0};
FILE *audiofile;

-(void)dealloc{
    
    pthread_mutex_destroy(&mutex);
    [super dealloc];
}

-(id)init{
    
    
    if (self=[super init]) {
        
        pthread_mutex_init(&mutex, nil);
    }
    
    return self;
}

/**
 *  上锁
 */
-(void)lock
{
	pthread_mutex_lock(&mutex);
}

/**
 *  解锁
 */
-(void)unLock
{
	pthread_mutex_unlock(&mutex);
}

/**
 *   解码器打开
 *
 *  @param nConnectDeviceType 连接的设备类型
 *  @param isExistStartCode   是否包含新帧头
 *
 *  @return YES打开成功 NO：已存在
 */
-(BOOL)openAudioDecoder:(int)nConnectDeviceType isExistStartCode:(BOOL)isExistStartCode {
    
    BOOL result = YES;
    
    if (!self.isOpenDecoder) {
        
        self.isOpenDecoder = TRUE;
        
        switch (nConnectDeviceType) {
                
            case DEVICEMODEL_DVR:
            case DEVICEMODEL_IPC:
                
                if (isExistStartCode) {
                    
                    [self lock];
                    JAD_DecodeOpen(0,self.nAudioType);
                    [self unLock];
                }
                
                break;
                
            default:
                
                if (isExistStartCode) {
                    
                    [self lock];
                    JAD_DecodeOpen(0,1);
                    [self unLock];
                }
                
                break;
        }
        
        [[OpenALBufferViewcontroller shareOpenALBufferViewcontrollerobjInstance] initOpenAL];
        
    }else{
        
        result = FALSE;
//        DDLogCVerbose(@"%s----audio is open",__FUNCTION__);
    }
    
    NSString *documentPaths = NSTemporaryDirectory();
    NSString      *kRecoedVideoFileFormat  = @".pcm";
    static const NSString      *kRecoedVideoFileName    = @"LocalValue";
    
    NSString *filePath = [documentPaths stringByAppendingPathComponent:(NSString *)kRecoedVideoFileName];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYYMMddHHmmssSSSS"];
    NSString *videoPath =[NSString stringWithFormat:@"%@/%@%@",filePath,[df stringFromDate:[NSDate date]],kRecoedVideoFileFormat];
    [df release];
    
    audiofile = fopen((char *)[videoPath UTF8String], "w+");
    
    return result;
}

/**
 *  关闭音频解码器
 *
 *  @return YES:成功关闭 NO:不存在
 */
-(BOOL)closeAudioDecoder{
    
    BOOL result = YES;
    
    if (self.isOpenDecoder) {
        
        self.isOpenDecoder = FALSE;
        [self lock];
        JAD_DecodeClose(0);
        [self unLock];
        
        OpenALBufferViewcontroller *openAL = [OpenALBufferViewcontroller shareOpenALBufferViewcontrollerobjInstance];
        
        [openAL stopSound];
        [openAL cleanUpOpenALMath];
        
    }else {
    
        result = FALSE;
    }
    fclose(audiofile);
    return result;
}

/**
 *  音频解码
 *
 *  @param nConnectDeviceType    连接的设备类型
 *  @param isExistStartCode      是否包含新帧头
 *  @param networkBuffer         音频数据
 *  @param nBufferSize           音频数据大小
 *
 *  @return YES 转换失败 NO:转换失败
 */
-(BOOL)convertSoundBufferByNetworkBuffer:(int)nConnectDeviceType isExistStartCode:(BOOL)isExistStartCode networkBuffer:(char *)networkBuffer nBufferSize:(int)nBufferSize {
    
    
    JVCCloudSEENetworkGeneralHelper  *ystNetworkHelperCMObj   = [JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper];
    int                                   nSize               = nBufferSize;
    
    BOOL                                  isDecoderAudioState = YES;
    BOOL                                  isAudioType         = YES;
    int                                   nAudioDataSize      = AudioSize_G711;
    
    if (!self.isOpenDecoder) {
        
//        DDLogVerbose(@"%s-----audio is not open!",__FUNCTION__);
        return NO;
    }
    
    switch (nConnectDeviceType) {
            
        case DEVICEMODEL_SoftCard:
        case DEVICEMODEL_HardwareCard_950:
        case DEVICEMODEL_HardwareCard_951:{
            
            if(isExistStartCode) {
                
                unsigned char *audioPcmBuf = NULL;
                
                [self lock];
                
                JAD_DecodeOneFrame(0, (unsigned char *)networkBuffer,  &audioPcmBuf);
                memcpy(pcmOutBuffer, audioPcmBuf, AudioSize_PCM);
                
                JAD_DecodeOneFrame(0, (unsigned char *)networkBuffer+21,  &audioPcmBuf);
                memcpy(pcmOutBuffer+AudioSize_PCM, audioPcmBuf, AudioSize_PCM);
                
                [self unLock];
                
                
            }else{
                
                if ([ystNetworkHelperCMObj isKindOfBufInStartCode:(char *)networkBuffer]) {
                    
                    int startCode = 0;
                    memcpy(&startCode, networkBuffer, 4);
                    
                    if (!startCode==JVN_DSC_9800CARD) {
                        
                        isAudioType   = NO;
                    }
                    
                    memcpy(pcmOutBuffer, networkBuffer + 8, nSize - 8);
                    nAudioDataSize = nSize   - 8;
                }
            }
        }
            break;
        case DEVICEMODEL_DVR:{
            
            if (isExistStartCode) {
                
                unsigned char *audioPcmBuf = NULL;
                
                [self lock];
                JAD_DecodeOneFrame(0, (unsigned char *)networkBuffer,  &audioPcmBuf);
                [self unLock];
                
                memcpy(pcmOutBuffer, audioPcmBuf, AudioSize_G711);
                
            }else{
                
                memcpy(pcmOutBuffer, networkBuffer + 8, nSize-8);
                nAudioDataSize = nSize   - 8;
                isAudioType    = NO;
            }
        }
            break;
        case DEVICEMODEL_IPC:{
            
            if (isExistStartCode) {
                
                if ([ystNetworkHelperCMObj isKindOfBufInStartCode:(char *)networkBuffer]) {
                    
                    networkBuffer = networkBuffer + 8;
                }
                
                unsigned char *audioPcmBuf = NULL;
                
                [self lock];
                JAD_DecodeOneFrame(0, (unsigned char *)networkBuffer,  &audioPcmBuf);
                [self unLock];
                
                memcpy(pcmOutBuffer, audioPcmBuf, AudioSize_G711);
                
            }else{
                
                isDecoderAudioState = NO;
            }
            
        }
            break;
        default:
            break;
    }
    
    if (isDecoderAudioState  == YES ) {
        
        fwrite(pcmOutBuffer, 1, nAudioDataSize, audiofile);

          [[OpenALBufferViewcontroller shareOpenALBufferViewcontrollerobjInstance] openAudioFromQueue:(short *)pcmOutBuffer dataSize:nAudioDataSize playSoundType:isAudioType == YES ? playSoundType_8k16B : playSoundType_8k8B];
    }
  
    return YES;
}

@end
