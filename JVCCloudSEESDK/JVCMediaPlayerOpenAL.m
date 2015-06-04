//
//  JVCMediaPlayerOpenAL.m
//  JVCCloudSEESDK
//
//  Created by Yale on 15/6/4.
//  Copyright (c) 2015年 chenzhenyang. All rights reserved.
//

#import "JVCMediaPlayerOpenAL.h"

@implementation JVCMediaPlayerOpenAL

@synthesize mDevice,mContext,soundDictionary,bufferStorageArray;

static JVCMediaPlayerOpenAL *openALInstance = nil;

/**
 *  单例
 *
 *  @return 返回OpenALBufferViewcontroller 单例
 */
+ (JVCMediaPlayerOpenAL *)shareMediaPlayerOpenALInstance
{
    @synchronized(self)
    {
        if (openALInstance == nil) {
            
            openALInstance = [[self alloc] init ];
            
        }
        
        return openALInstance;
    }
    
    return openALInstance;
}


+(id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (openALInstance == nil) {
            
            openALInstance = [super allocWithZone:zone];
            
            return openALInstance;
        }
    }
    
    return nil;
}

-(void)initOpenAL
{
    NSLog(@"=======initOpenAl===");
    mDevice=alcOpenDevice(NULL);
    if (mDevice) {
        mContext=alcCreateContext(mDevice, NULL);
        alcMakeContextCurrent(mContext);
    }
    
    alGenSources(1, &outSourceId);
    alSpeedOfSound(1.0);
    alDopplerVelocity(1.0);
    alDopplerFactor(1.0);
    alSourcef(outSourceId, AL_PITCH, 1.0f);
    alSourcef(outSourceId, AL_GAIN, 1.0f);
    alSourcei(outSourceId, AL_LOOPING, AL_FALSE);
    alSourcef(outSourceId, AL_SOURCE_TYPE, AL_STREAMING);
    
}


- (void) openAudioFromQueue:(unsigned char*)data dataSize:(UInt32)dataSize
{
    NSCondition* ticketCondition= [[NSCondition alloc] init];
    [ticketCondition lock];
    
    ALuint bufferID = 0;
    alGenBuffers(1, &bufferID);
    // NSLog(@"bufferID = %d",bufferID);
    NSData * tmpData = [NSData dataWithBytes:data length:dataSize];
    VideoFrameExtrator *temp = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] viewController] video];
    int aSampleRate,aBit,aChannel;
    aSampleRate = temp->sampleRates;
    aBit = temp->aBits;
    aChannel = temp->Channels;
    // NSLog(@"%d,%d,%d",aSampleRate,aBit,aChannel);
    ALenum format;
    
    if (aBit == 8) {
        if (aChannel == 1)
            format = AL_FORMAT_MONO8;
        else if(aChannel == 2)
            format = AL_FORMAT_STEREO8;
        else if( alIsExtensionPresent( "AL_EXT_MCFORMATS" ) )
        {
            if( aChannel == 4 )
            {
                format = alGetEnumValue( "AL_FORMAT_QUAD8" );
            }
            if( aChannel == 6 )
            {
                format = alGetEnumValue( "AL_FORMAT_51CHN8" );
            }
        }
    }
    
    if( aBit == 16 )
    {
        if( aChannel == 1 )
        {
            format = AL_FORMAT_MONO16;
        }
        if( aChannel == 2 )
        {
            // NSLog(@"achhenl= 2!!!!!");
            format = AL_FORMAT_STEREO16;
        }
        if( alIsExtensionPresent( "AL_EXT_MCFORMATS" ) )
        {
            if( aChannel == 4 )
            {
                format = alGetEnumValue( "AL_FORMAT_QUAD16" );
            }
            if( aChannel == 6 )
            {
                NSLog(@"achannel = 6!!!!!!");
                format = alGetEnumValue( "AL_FORMAT_51CHN16" );
            }
        }
    }
    //  NSLog(@"%d",format);
    alBufferData(bufferID, format, (char*)[tmpData bytes], (ALsizei)[tmpData length],aSampleRate);
    alSourceQueueBuffers(outSourceId, 1, &bufferID);
    
    [self updataQueueBuffer];
    
    ALint stateVaue;
    alGetSourcei(outSourceId, AL_SOURCE_STATE, &stateVaue);
    
    [ticketCondition unlock];
    ticketCondition = nil;
    
}


- (BOOL)updataQueueBuffer
{
    ALint stateVaue;
    int processed, queued;
    
    alGetSourcei(outSourceId, AL_BUFFERS_PROCESSED, &processed);
    alGetSourcei(outSourceId, AL_BUFFERS_QUEUED, &queued);
    
    //NSLog(@"Processed = %d\n", processed);
    //NSLog(@"Queued = %d\n", queued);
    
    alGetSourcei(outSourceId, AL_SOURCE_STATE, &stateVaue);
    
    if (stateVaue == AL_STOPPED ||
        stateVaue == AL_PAUSED ||
        stateVaue == AL_INITIAL)
    {
        if (queued < processed || queued == 0 ||(queued == 1 && processed ==1)) {
            NSLog(@"Audio Stop");
            [self stopSound];
            [self cleanUpOpenAL];
        }
        
        // NSLog(@"===statevaue ========================%d",stateVaue);
        [self playSound];
        return NO;
    }
    
    while(processed--)
    {
        // NSLog(@"queue = %d",queued);
        alSourceUnqueueBuffers(outSourceId, 1, &buff);
        alDeleteBuffers(1, &buff);
    }
    //NSLog(@"queue = %d",queued);
    return YES;
}


#pragma make - play/stop/clean function
-(void)playSound
{
    alSourcePlay(outSourceId);
}
-(void)stopSound
{
    alSourceStop(outSourceId);
}
-(void)cleanUpOpenAL
{
    [updateBufferTimer invalidate];
    updateBufferTimer = nil;
    alDeleteSources(1, &outSourceId);
    alDeleteBuffers(1, &buff);
    alcDestroyContext(mContext);
    alcCloseDevice(mDevicde);
}



-(void)dealloc
{
    NSLog(@"openal sound dealloc");
}


@end
