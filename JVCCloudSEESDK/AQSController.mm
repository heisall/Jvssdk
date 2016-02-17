//
//  AQSController.mm
//  AQS
//  音频采集处理

//  step 01
//  Preprocessor Macros参数的值清空即可(操作:select the Target, open the Build Settings pane, search for "Preprocessor Macros". Leave the fields blank (I've got rid of a DEBUG entry)
//  Created by Midfar Sun on 2/3/12.
//  Copyright 2012 midfar.com. All rights reserved.
//

#import "AQSController.h"
#import "AQPlayer.h"
#import "AQRecorder.h"
#import <AVFoundation/AVFoundation.h>


@interface AQSController (){

	CFStringRef	  recordFilePath;
    AQRecorder    *recorder;
    BOOL          isRecoderState;
}

@end

@implementation AQSController
@synthesize delegate;

OSStatus errorState;

static AQSController *_AQSController = nil;

/**
 *  单例
 *
 *  @return 返回AQSController 单例
 */
+ (AQSController *)shareAQSControllerobjInstance
{
    @synchronized(self)
    {
        if (_AQSController == nil) {
            
            _AQSController = [[self alloc] init ];
            [_AQSController awakeFromNib];
            
        }
        
        return _AQSController;
    }
    
    return _AQSController;
}


+(id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (_AQSController == nil) {
            
            _AQSController = [super allocWithZone:zone];
            
            return _AQSController;
            
        }
    }
    
    return nil;
}

char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4], *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

-(void)setFileDescriptionForFormat: (CAStreamBasicDescription)format withName:(NSString*)name
{
	char buf[5];
	const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
	NSString* description = [[NSString alloc] initWithFormat:@"(%ld ch. %s @ %g Hz)", format.NumberChannels(), dataFormat, format.mSampleRate, nil];
	[description release];	
}

- (void)stopRecord
{
    if (isRecoderState) {
        
        recorder->StopRecord();
        
        if (errorState) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)errorState);
        
        else
        {
            UInt32 category = kAudioSessionCategory_AmbientSound;
            errorState = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
            
            errorState = AudioSessionSetActive(true);
            if (errorState) printf("AudioSessionSetActive (true) failed");
            
        }
        
        isRecoderState = FALSE;
    }
}

- (void)record:(int)cacheBufSize mChannelBit:(int)mchannelBit
{
    
    if (errorState) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)errorState);
	else
	{
        NSString *voiceType = [[NSUserDefaults standardUserDefaults] objectForKey:@"VOICETYPE"];
        if (voiceType.length == 0) {
            
            UInt32 category = kAudioSessionCategory_PlayAndRecord;
            errorState = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
            NSError *error = nil;
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            errorState = AudioSessionSetActive(true);
            if (errorState) printf("AudioSessionSetActive (true) failed");
            
        }else{
        
            UInt32 category = kAudioSessionCategory_PlayAndRecord;
            errorState = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
            
            errorState = AudioSessionSetActive(true);
            if (errorState) printf("AudioSessionSetActive (true) failed");
        }
        
    }
	if (recorder->IsRunning())
	{
		[self stopRecord];
	}
	else
	{
		recorder->StartRecord(CFSTR("recordedFile.wav"),cacheBufSize,mchannelBit);
		
		[self setFileDescriptionForFormat:recorder->DataFormat() withName:@"Recorded File"];
	}
	
    isRecoderState = TRUE ;
}

#pragma mark AudioSession listeners

void interruptionListener(	void *	inClientData,
							UInt32	inInterruptionState)
{
    AQSController *THIS = (AQSController*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS->recorder->IsRunning()) {
            
			[THIS stopRecord];
		}
	}
	else if (inInterruptionState == kAudioSessionEndInterruption)
	{
        
	}
}

void propListener(	void *                  inClientData,
					AudioSessionPropertyID	inID,
					UInt32                  inDataSize,
					const void *            inData)
{

    if (inID == kAudioSessionProperty_AudioRouteChange)
    {
        CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
        
        CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
        SInt32 reasonVal;
        CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
        
    }
}
				
#pragma mark Initialization routines
- (void)awakeFromNib
{

	recorder = new AQRecorder();
    
    recorder->RegisterAQSController(self);
    
    errorState = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
    if (errorState) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)errorState);
	else 
	{
        UInt32 category = kAudioSessionCategory_AmbientSound;
		errorState = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        
               
		if (errorState) printf("couldn't set audio category!");
        
        errorState = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (errorState) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)errorState);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);

		errorState = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (errorState) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)errorState);
        
        errorState = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
        if (errorState) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)errorState);
 
        errorState = AudioSessionSetActive(true); 
		if (errorState) printf("AudioSessionSetActive (true) failed");
    }
}

/**
 *  接收音频采集的回调函数
 *
 *  @param audioData    采集的音频数据
 *  @param audioDataSize 采集的音频数据的大小
 */
-(void)receiveAudioData:(char *)audioData audioDataSize:(long)audioDataSize{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(receiveAudioDataCallBack:audioDataSize:)]) {
        
        NSLog(@"receive audio data");
        [self.delegate receiveAudioDataCallBack:audioData audioDataSize:audioDataSize];
    }
}

/**
 *  长按对讲函数
 *
 *  @param recordState YES:采集发送 NO:采集不发送
 */
- (void)changeRecordState:(BOOL)recordState {
    
    if (recorder) {
        
        recorder -> IsRecord = recordState;
    }
}

#pragma mark Cleanup
- (void)dealloc
{
	delete recorder;
	[super dealloc];
}

@end
