//
//  JVCMediaAudioDecoder.m
//  JVCCloudSEESDK
//
//  Created by Yale on 15/6/3.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import "JVCMediaAudioDecoder.h"
#import <pthread.h>
#import "JVCAudioCodecInterface.h"
#import "OpenALBufferViewcontroller.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVCDecoderMacro.h"

@interface JVCMediaAudioDecoder () {
    
    pthread_mutex_t  mutex;
}

@end

@implementation JVCMediaAudioDecoder

@synthesize nAudioType,isOpenDecoder;

char          pcmOutBuffer[1024] = {0};

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
 *   打开播放器的音频解码器
 */
-(void)openAudioDecoder:(int)AudioType
{
    
    if(!self.isOpenDecoder){
        [self lock];
        JAD_DecodeOpen(0,AudioType);
        [self unLock];
    }
    
    [[OpenALBufferViewcontroller shareOpenALBufferViewcontrollerobjInstance] initOpenAL];
    self.isOpenDecoder = TRUE;
    nAudioType  = AudioType;
}

/**
 *  关闭音频解码器
 *
 *  @return YES:成功关闭 NO:不存在
 */
-(BOOL)closeAudioDecoder{
    
    BOOL result = YES;
    
    if (self.isOpenDecoder) {
        
        [self lock];
        JAD_DecodeClose(0);
        [self unLock];
        
        OpenALBufferViewcontroller *openAL = [OpenALBufferViewcontroller shareOpenALBufferViewcontrollerobjInstance];
        
        [openAL stopSound];
        [openAL cleanUpOpenALMath];
        self.isOpenDecoder = FALSE;
        
        
    }else {
        
        result = FALSE;
    }
    
    return result;
}

/**
 *  音频解码
 *
 *  @param networkBuffer         音频数据
 *  @param nBufferSize           音频数据大小
 *
 *  @return YES 转换失败 NO:转换失败
 */
-(BOOL)convertSoundBufferByNetworkBuffer:(unsigned char *)audioBuffer nBufferSize:(int)nBufferSize
{
    if(self.isOpenDecoder){
        if(self.nAudioType == AUDIO_DECODER_SAMR){
            
            unsigned char *audioPcmBuf = NULL;
            
            [self lock];
            
            JAD_DecodeOneFrame(0, audioBuffer,  &audioPcmBuf);
            memcpy(pcmOutBuffer, audioPcmBuf, AudioSize_PCM);
            
            JAD_DecodeOneFrame(0, audioBuffer+21,  &audioPcmBuf);
            memcpy(pcmOutBuffer+AudioSize_PCM, audioPcmBuf, AudioSize_PCM);
            
            [self unLock];
            
        }else if(self.nAudioType == AUDIO_DECODER_ALAW || self.nAudioType == AUDIO_DECODER_ULAW){
            unsigned char *audioPcmBuf = NULL;
            
            [self lock];
            JAD_DecodeOneFrame(0, audioBuffer,  &audioPcmBuf);
            [self unLock];
            
            memcpy(pcmOutBuffer, audioPcmBuf, AudioSize_G711);
            
        }
        
        [[OpenALBufferViewcontroller shareOpenALBufferViewcontrollerobjInstance] openAudioFromQueue:(short *)pcmOutBuffer dataSize:AudioSize_G711 playSoundType:playSoundType_8k16B];
        return true;
    }
    
    return false;
}


@end
