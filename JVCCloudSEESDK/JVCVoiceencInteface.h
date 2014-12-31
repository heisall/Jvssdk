//
//  JVCVoiceencInteface.h
//  CloudSEE_II
//  需要引入 libtransSing.a 这个库 主要用于声波编码
//  Created by chenzhenyang on 14-10-13.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#ifndef CloudSEE_II_JVCVoiceencInteface_h
#define CloudSEE_II_JVCVoiceencInteface_h

#ifdef __cplusplus
extern "C" {
#endif
    /**
     *@brief 编码，将要发送的数据，编码成适合发送的数据
     *
     *@param data 要编码的数据
     *@param len 要编码的长度
     *@param code 编码后的数据
     *@param maxLen 编码后数据的最大长度。所需长度在 len*4到len*10之间，建议len*10
     *
     *@return 编码后数据的实际长度
     */
    int voiceenc_data2code(const unsigned char *data, int len, unsigned char *code, int maxLen);
    
    /**
     *@brief 将编码变成声音的原始PCM数据
     *
     *@param samplerate 采样率，至少为16000. 建议使用该值
     *@param signalCnt 信号的数量。该值越大，信号越长，声音越长。建议值为  40
     *@param code 要发送的编码数据
     *@param buffer 编好的音频数据
     *@param maxLen 音频数据Buffer的最大长度，其长度至少为：#samplerate * signalCnt / 1000
     *			其中，1000为采样频率的最低值
     *
     *@return 实际的数据长度
     */
    int voiceenc_code2pcm_16K16Bit(int samplerate, int signalCnt, unsigned char code, unsigned char *buffer, int maxLen);
#ifdef __cplusplus
}
#endif

#endif
