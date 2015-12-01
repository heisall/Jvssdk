//
//  JVCDecoderMacro.h
//  CloudSEE_II
//
//  Created by lay on 15/4/10.
//  Copyright (c) 2015年 lay. All rights reserved.
//

#ifndef CloudSEE_II_JVCDecoderMacro_h
#define CloudSEE_II_JVCDecoderMacro_h


/**解码库对应的h264和h265标志**/
enum{
    VIDEO_DECODER_H264 = 0,
    VIDEO_DECODER_H265 = 1,
};

/**IPC对应的h264和h265标志**/
enum{
    IPC_VIDEO_DECODER_H264 = 1,
    IPC_VIDEO_DECODER_H265 = 2,
};

enum{
    AUDIO_DECODER_SAMR=1,
    AUDIO_DECODER_ALAW=2,
    AUDIO_DECODER_ULAW=3
};

#define DECODER_RESOLUTION 3000*2000


#endif
