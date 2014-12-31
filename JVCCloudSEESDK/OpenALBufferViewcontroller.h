//
//  OpenALBufferViewcontroller.h
//  OpenALTest
//
//  Created by jovision on 13-5-15.
//
//

#import <UIKit/UIKit.h>
#import <OpenAL/alc.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <OpenAL/al.h>

@interface OpenALBufferViewcontroller : UIViewController{


    ALCcontext            *mContext;
    ALCdevice             *mDevice;
    ALuint                 outSourceID;
    NSMutableDictionary   *soundDictionary;
    NSMutableArray        *bufferStorageArray;
    ALuint                 buff;
    NSTimer               *updataBufferTimer;
}

enum playSoundType {
    
    playSoundType_8k8B   = 0,
    playSoundType_8k16B  = 1,
    playSoundType_16k16B = 2,
};
@property (nonatomic,assign) ALCcontext *mContext;
@property (nonatomic,assign) ALCdevice  *mDevice;
@property (nonatomic,retain) NSMutableDictionary* soundDictionary;
@property (nonatomic,retain) NSMutableArray* bufferStorageArray;

/**
 *  单例
 *
 *  @return 返回OpenALBufferViewcontroller 单例
 */
+ (OpenALBufferViewcontroller *)shareOpenALBufferViewcontrollerobjInstance;

/**
 *  初始化播放器
 */
-(void)initOpenAL;

/**
 *  播放音频
 *
 *  @param data          音频数据
 *  @param dataSize      音频数据的大小
 *  @param playSoundType 音频数据的类型 
 */
- (void)openAudioFromQueue:(short*)data dataSize:(UInt32)dataSize playSoundType:(int)playSoundType;

/**
 *  停止播放
 */
-(void)stopSound;

/**
 *  清除缓存声音
 */
-(void)cleanUpOpenALMath;

/**
 *  清除缓存声音的方法
 */
-(void)clear;

/**
 *  获取当前OpenAL是否在播放声音
 *
 *  @return 0x1014 播放结束
 */
-(int)checkOpenAlStatus;

@end
