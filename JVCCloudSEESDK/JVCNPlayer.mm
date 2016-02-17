//
//  JVCNPlayer.m
//  CloudSEE_II
//
//  Created by Yale on 15/6/11.
//  Copyright (c) 2015年 Yale. All rights reserved.
//

#import "JVCNPlayer.h"

#include <sys/time.h>
#include <sys/select.h>
#include "types.h"
#include "handler.h"
#include "nplayer.h"
#include "play_suit.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

static JVCNPlayer *jvcNPlayer = nil;

#define FRAME_SIZE 640
#define DUMMY_FILE "org.pcm"

class EchoHandler : public utils::Handler {
public:
    EchoHandler() {}
    ~EchoHandler() {}
    
    bool handle(int what, int arg1, int arg2, void *obj) {
        printf("echo: %d, %d, %d, %p\n", what, arg1, arg2, obj);
        return false;
    }
    
private:
    ONLY_EMPTY_CONSTRUCTION(EchoHandler);
};

@interface JVCNPlayer () {
    EchoHandler *handler;
    NSString *dummyPath;
    BOOL denoise;
    BOOL aes ;
}

@end

@implementation JVCNPlayer

@synthesize isAec,isDenoise;
nplayer::NPlayer *player = NULL;
nplayer::audio::Suit suit;

void nplayer_msleep(int millis) {
    if (millis > 0) {
        struct timeval tt;
        tt.tv_sec = millis / 1000;
        tt.tv_usec = (millis % 1000) * 1000;
        select(0, NULL, NULL, NULL, &tt);
    }
}

void shutdown_audio() {
    if (NULL != player) {
        player->stop_record_audio();
        player->enable_audio(false);
        
        nplayer_msleep(150);
        
        if (NULL != player) {
            delete player;
            player = NULL;
        }
    }
//    nplayer::NPlayer::deinit();
}
//
/**
 *  单例
 *
 *  @return 对象
 */
+(JVCNPlayer *)shareJVCNPlayer
{
    @synchronized(self)
    {
        if (jvcNPlayer == nil) {
            
            jvcNPlayer = [[self alloc] init];
            
        }
        return jvcNPlayer;
    }
    
    return jvcNPlayer;
}
//
//+ (id)allocWithZone:(struct _NSZone *)zone
//{
//    @synchronized(self)
//    {
//        if (jvcNPlayer == nil) {
//            
//            jvcNPlayer = [super allocWithZone:zone];
//            
//            return jvcNPlayer;
//        }
//    }
//    
//    return nil;
//}

-(void)initPlayerSampleRate:(int)rate frameSize:(int)size
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance]
     setCategory:AVAudioSessionCategoryPlayAndRecord
     withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
     error:nil];
    
    nplayer::PlaySuit *ps = NULL;
    float adjust_volume = 0.9f;//
    
    EchoHandler *handler = new EchoHandler();
    
    memset(&suit, 0, sizeof(nplayer::audio::Suit));
    suit.type = nplayer::audio::kTypeRawPCM;
    suit.sample_rate = rate;
    suit.channel_per_frame = 1;
    suit.bit_per_channel = 16;
    suit.block = size;
    
    // 开启降噪
    suit.enable_ns = isDenoise;
    // 开启回声抑制
    suit.enable_aec = isAec;
    
    ps = new nplayer::PlaySuit(1, nplayer::kPTypeByFPS, &suit, NULL);
    ps->set_audio(&suit);
    
    player = new nplayer::NPlayer(ps, handler);
    player->resume();
    player->enable_audio(true);
    player->adjust_track_volume(adjust_volume);

    NSLog(@"adjust_track_volume %f version %s\n",adjust_volume,nplayer::NPlayer::version());
}
+(void)initCore{
    nplayer::NPlayer::init();
    NSLog(@"version %s",nplayer::NPlayer::version());
}

+(void)deinitCore{
    nplayer::NPlayer::deinit();
}

/**
 *  播放器初始化
 */
-(void)initPlayer
{
    [self initPlayerSampleRate:8000 frameSize:FRAME_SIZE];
}

/*
 播放一帧音频  @param audioData 音频数据 @param frameSize 数据大小  */
-(void)appendAudioData:(const unsigned char*)audioData size:(int)frameSize
{
    if(player == NULL){
        NSLog(@"Player is null ,need to init!");
        return;
    }
    while (player->audio_working() &&
           false == player->append_audio_data(audioData, frameSize)) {
       [NSThread sleepForTimeInterval:0.05];
    }
//    NSLog(@"append audio data");
//    player->append_audio_data(audioData, frameSize);
}

-(void)resumeAudio{
    if(player == NULL){
        NSLog(@"Player is null ,need to init!");
        return;
    }
    player->resume();
    player->enable_audio(true);
    
}

-(void)pauseAudio{
    if(player == NULL){
        NSLog(@"Player is null ,need to init!");
        return;
    }
    player->pause();
    player->enable_audio(false);
}

-(void)startRecordAudio:(fetchcb)callback
{
    if(player == NULL){
        NSLog(@"Player is null ,need to init!");
        return;
    }
    NSLog(@"start record audio");
    player->start_record_audio(callback);
}

-(void)stopRecordAudio{
    if(player == NULL){
        NSLog(@"Player is null ,need to init!");
        return;
    }
    player->stop_record_audio();
}

-(void)stopPlayer
{
    NSLog(@"stopplayer");
    shutdown_audio();
}
-(void)soundConfig:(const char *)audioData size:(int)frameSize{
//    NSLog(<#NSString * _Nonnull format, ...#>)
    nplayer::NPlayer::gen_sound_config(audioData, frameSize);
}
@end
