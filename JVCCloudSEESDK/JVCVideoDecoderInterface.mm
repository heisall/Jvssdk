//
//  JVCVideoDecoderInterface.m
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCVideoDecoderInterface.h"

extern "C"
{
    
    /****************************************************************************
     非标准解码器对应接口*/
    void JVD04_InitSDK();
    //
    //    /*
    //     * Class:     com_jovetech_CloudSee_JVSH264_01
    //     * Method:    JVD04_ReleaseSDK
    //     * Signature: ()V
    //     */
    void JVD04_ReleaseSDK();
    
    /*
     * Class:     com_jovetech_CloudSee_JVSH264_01
     * Method:    JVD04_DecodeOpen
     * Signature: ()V
     */
    void JVD04_DecodeOpen(int width,int height,int nLocalChannel);
    
    /*
     * Class:     com_jovetech_CloudSee_JVSH264_01
     * Method:    JVD04_DecodeClose
     * Signature: ()V
     */
    void JVD04_DecodeClose(int nLocalChannel);
    
    /*
     * Class:     com_jovetech_CloudSee_JVSH264_01
     * Method:    JVD04_DecodeOneFrame
     * Signature: ()I
     */
    //int JVD04_DecodeOneFrame
    //  (unsigned char* inH264Data,int length,int nLocalChannel,int uchType);
    //int JVD04_DecodeOneFrame(unsigned char * inH264Data,unsigned char * outH264Data,int length,int nLocalChannel,int uchType,int systemVersion,int deviceType);
    
    int JVD04_DecodeOneFrame(unsigned char * inH264Data,int length, char * ydata,char *udata,char *vdata,int nLocalChannel,int uchType,int systemVersion);
    
    
    
    /******************************
     Function: JVD05_InitSDK
     Description: 加载avcodec-54.dll、avutil-51.dll
     Param: 无
     Return: FALSE, 表示失败, TRUE, 表示成功
     **********************************************************************************/
    BOOL JVD05_InitSDK();
    
    
    /**********************************************************************************
     Function: JVD05_ReleaseSDK
     Description: 释放avcodec-54.dll、avutil-51.dll
     Param: 无
     Return: 无
     **********************************************************************************/
    void JVD05_ReleaseSDK();
    
    
    /**********************************************************************************
     Function: JVD05_DecodeOpen
     Description: 打开解码器和JVD05_DecodeClose成对使用
     Param:
     无
     
     Return: 返回解码器句柄, NULL,表示失败,否则表示成功
     **********************************************************************************/
    //JDEC05_API JDEC05_HANDLE JVD05_DecodeOpen ();
    void JVD05_DecodeOpen (int nlchannel);
    
    /**********************************************************************************
     Function: JVD05_DecodeClose
     Description: 关闭解码器和JVD05_DecodeOpen成对使用
     Param:
     JDEC05_HANDLE h // 解码器句柄
     
     
     Return: 无
     **********************************************************************************/
    //JDEC05_API void JVD05_DecodeClose (JDEC05_HANDLE h);
    void  JVD05_DecodeClose (int nlchannel);
    
    
    /**********************************************************************************/
    int   JVD05_DecodeOneFrame(int nlchannel,int dataSize,unsigned char *inData , unsigned char *outData,unsigned char *outdata2,unsigned char *outdata3, int bDelayFrame,int systemVersion,int deviceType,int*decodeOutWidth,int* decodeOutHeight);
    
    /**
     *	返回H264的RGB数据
     *
     *	@param	nlchannel	解码的通道
     *	@param	outdata	    返回的RGB数据
     *	@param	systemVersion	iOS的系统版本
     */
    void  yuv_rgb(int nlchannel,unsigned int* outdata,int  systemVersion);
    
    unsigned char* CreateBitmap(unsigned char *pixels,int w,int h,int  systemVersion);
    
};

@implementation JVCVideoDecoderInterface

@end
