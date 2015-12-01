//
//  JVCMediaPlayerOpenAL.h
//  JVCCloudSEESDK
//
//  Created by Yale on 15/6/4.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <OpenAL/oalMacOSX_OALExtensions.h>


@interface JVCMediaPlayerOpenAL : NSObject
{
    ALCcontext *mContext;
    ALCdevice *mDevicde;
    ALuint outSourceId;
    NSMutableDictionary *soundDictionary;
    NSMutableArray *bufferStorageArray;
    ALuint buff;
    NSTimer *updateBufferTimer;
}
@property(nonatomic)ALCcontext *mContext;
@property(nonatomic)ALCdevice *mDevice;
@property(nonatomic,retain)NSMutableDictionary *soundDictionary;
@property(nonatomic,retain)NSMutableArray *bufferStorageArray;

/**
 *  单例
 *
 *  @return 返回OpenALBufferViewcontroller 单例
 */
+ (JVCMediaPlayerOpenAL *)shareMediaPlayerOpenALInstance;


-(void)initOpenAL;
-(void)openAudioFromQueue:(uint8_t *)data dataSize:(UInt32)dataSize;
-(BOOL)updataQueueBuffer;
-(void)playSound;
-(void)stopSound;
-(void)cleanUpOpenAL;

@end
