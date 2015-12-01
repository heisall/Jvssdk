//
//  JVCCloudSEENetworkGeneralHelper.m
//  CloudSEE_II
//  云视通网络库的通用方法封装类
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCCloudSEENetworkGeneralHelper.h"
#import "JVNetConst.h"
#import "JVCCloudSEESDK.h"
#import "JVCCloudSEEManagerHelper.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVNetConst.h"

@implementation JVCCloudSEENetworkGeneralHelper
static JVCCloudSEENetworkGeneralHelper *jvcCloudSEENetworkGeneralHelper = nil;
static NSString const * kCloudSEENetworkWithConnectedPassWord           =  @"password is wrong!";
static NSString const * kCloudSEENetworkWithConnectedLimit              =  @"client count limit!";
static NSString const * kCloudSEENetworkWithConnectedChannelIsNotOpen   =  @"channel is not open!";
static const    float   kDefaultFrameRate                               = 25.0f;
static const    int     kValueAndKeyLength                              = 1024*2;

/**
 *  单例
 *
 *  @return 返回JVCCloudSEENetworkGeneralHelper 单例
 */
+ (JVCCloudSEENetworkGeneralHelper *)shareJVCCloudSEENetworkGeneralHelper
{
    @synchronized(self)
    {
        if (jvcCloudSEENetworkGeneralHelper == nil) {
            
            jvcCloudSEENetworkGeneralHelper = [[self alloc] init ];
            
        }
        
        return jvcCloudSEENetworkGeneralHelper;
    }
    
    return jvcCloudSEENetworkGeneralHelper;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (jvcCloudSEENetworkGeneralHelper == nil) {
            
            jvcCloudSEENetworkGeneralHelper = [super allocWithZone:zone];
            
            return jvcCloudSEENetworkGeneralHelper;
            
        }
    }
    
    return nil;
}


/**
 *  判断设备传来的O帧是新帧头还是旧帧头 新的返回TRUE
 *
 *  @param pBuffer O帧数据
 *  @param dwSize  大小
 *
 *  @return 新的返回TRUE
 */
-(bool)IsFILE_HEADER_EX:(void *)pBuffer dwSize:(uint32_t)dwSize
{
	uint8_t *pacBuffer = (uint8_t*)pBuffer+2;
    
	if(pBuffer == NULL || dwSize < sizeof(JVS_FILE_HEADER_EX))
	{
		return FALSE;
	}
    
	return pacBuffer[32] == 'J' && pacBuffer[33] == 'F' && pacBuffer[34] == 'H';
}


/**
 *  判断是否带针头
 *
 *  @param buffer 视频数据
 *
 *  @return YES:存在 NO:FALSE
 */
-(BOOL)isKindOfBufInStartCode:(char*)buffer {
    
    uint8_t *pacBuffer = (uint8_t*)buffer;
    
	if(buffer == NULL )
	{
		return FALSE;
	}
	return pacBuffer[0] == 'J' && pacBuffer[1] == 'V' && pacBuffer[2] == 'S';
}



/**
 *  获取当前连接设备的StartCode、宽、高
 *
 *  @param buffer_O O 帧数据
 *
 */
-(void)getBufferOInInfo:(char *)buffer_O startCode:(int *)startCode videoWidth:(int *)videoWidth videoHeight:(int *)videoHeight{
    
    int startCodeValue   = *startCode;
    int videoWidthValue  = *videoHeight;
    int videoHeightValue = *videoHeight;
    
    memcpy(&startCodeValue, buffer_O+2, 4);
    memcpy(&videoWidthValue, buffer_O+6, 4);
    memcpy(&videoHeightValue, buffer_O+10, 4);
    
    //判断当前的设备是否为NVR
    if (startCodeValue==JVN_NVR_STARTCODE) {
        
        //获取NVR上连接的IPC的startCode
        memcpy(&startCodeValue, buffer_O+26, 4);
    }
    
    *startCode   = startCodeValue;
    *videoWidth  = videoWidthValue;
    *videoHeight = videoHeightValue;
}

/**
 *  获取当前连接设备是否是NVR设备
 *
 *  @param buffer_O O帧数据
 *
 *  @return YES：NVR NO:不是
 */
-(BOOL)checkDeviceIsNvrDevice:(char *)buffer_O {
    
    BOOL result = FALSE;
    
    int startCodeValue = 0;
    
    memcpy(&startCodeValue, buffer_O+2, 4);
    
    //判断当前的设备是否为NVR
    if (startCodeValue==JVN_NVR_STARTCODE) {
        
        result = TRUE;
    }
    
    return result;
}

/**
 *  判断连接的设备类型
 *
 *  @param startCode 设备编号
 *
 *  @return DEVICEMODEL枚举
 */
-(int)checkConnectDeviceModel:(int)startCode {
    
    int deviceModelType=DEVICEMODEL_SoftCard;
    
    switch (startCode) {
            
        case JVN_DSC_DVR:
        case DVR8004_STARTCOODE:
            
            deviceModelType=DEVICEMODEL_DVR;
            
            break;
        case JVSC950_STARTCOODE:
            
            deviceModelType=DEVICEMODEL_HardwareCard_950;
            
            break;
        case JVSC951_STARTCOODE:
            
            deviceModelType=DEVICEMODEL_HardwareCard_951;
            
            break;
        case IPC3507_STARTCODE:
        case IPC_DEC_STARTCODE:
            
            deviceModelType=DEVICEMODEL_IPC;
            break;
            
        default:
            break;
    }
    
    return deviceModelType;
}

/**
 *  获取连接设备视频的帧速率
 *
 *  @param startCode     设备的编号
 *  @param buffer_O      O帧数据
 *  @param buffer_O_size O帧数据
 *
 *  @return 视频的帧速率
 */
-(double)getPlayVideoframeFrate:(int)startCode buffer_O:(char *)buffer_O buffer_O_size:(int)buffer_O_size nAudioType:(int *)nAudionType wVideoCodecID:(int *)wVideoCodecID{
    
    double frameRate = kDefaultFrameRate;
    
    if ([self IsFILE_HEADER_EX:buffer_O dwSize:buffer_O_size]) {
        
        if (startCode==JVN_DSC_960CARD) {
            
            int frameRate = 0;
            memcpy(&frameRate, buffer_O+36, 4);
            frameRate = (double)frameRate/10000;
            
        }else{
            
            JVS_FILE_HEADER_EX *fileHeader;
            
            fileHeader = malloc(sizeof(JVS_FILE_HEADER_EX));
            memset(fileHeader, 0, sizeof(JVS_FILE_HEADER_EX));
            memcpy(fileHeader, buffer_O+2, sizeof(JVS_FILE_HEADER_EX));
            
            frameRate   = ((double)fileHeader->wFrameRateNum)/((double)fileHeader->wFrameRateDen);
            *nAudionType = fileHeader->wAudioCodecID;
            
            *wVideoCodecID = fileHeader->wVideoCodecID;
            
            free(fileHeader);
        }
    }
    
    return frameRate;
}

/**
 *  根据云视通号获取云视通组号和编号
 *
 *  @param YstNumberString 云视通号
 *  @param strYstgroup     云视通组号
 *  @param nYstNumber      云视通的编号
 */
-(void)getYstGroupStrAndYstNumberByYstNumberString:(NSString *)YstNumberString strYstgroup:(NSString **)strYstgroup nYstNumber:(int *)nYstNumber{
    
    
    NSRegularExpression *regexReplacingYstGroup  = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:0 error:NULL];
    NSRegularExpression *regexReplacingYstNumber = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:0 error:NULL];
    
    NSString *strNumber  = [regexReplacingYstGroup stringByReplacingMatchesInString:YstNumberString options:0 range:NSMakeRange(0, [YstNumberString length]) withTemplate:@""];
    NSString *strGroup   = [regexReplacingYstNumber stringByReplacingMatchesInString:YstNumberString options:0 range:NSMakeRange(0, [YstNumberString length]) withTemplate:@""];
    
    *strYstgroup =strGroup;
    *nYstNumber  =[strNumber intValue];
}


/**
 *  转换连接失败的详细情况
 *
 *  @param ConnectResultInfo 连接返回的信息
 *  @param conenctResultType 连接返回的类型
 */
-(void)getConnectFailedDetailedInfoByConnectResultInfo:(NSString *)ConnectResultInfo conenctResultType:(int *)conenctResultType{
    
    int connectResultValue    = *conenctResultType;
    
    
    if (connectResultValue == CONNECTRESULTTYPE_ConnectFailed) {
        
        if ([ConnectResultInfo isEqualToString:(NSString *)kCloudSEENetworkWithConnectedPassWord]) {
            
            *conenctResultType = CONNECTRESULTTYPE_VerifyFailed;
            
        }else if([ConnectResultInfo isEqualToString:(NSString *)kCloudSEENetworkWithConnectedLimit])
        {
            *conenctResultType = CONNECTRESULTTYPE_ConnectMaxNumber;
            
        }else if([ConnectResultInfo isEqualToString:(NSString *)kCloudSEENetworkWithConnectedChannelIsNotOpen]){
        
            *conenctResultType = CONNECTRESULTTYPE_ChannelIsNotOpen;
        }
    }
}

/**
 *  判断当前连接设备视频中是否包含帧头（主控采用05版编码的才生效）
 *
 *  @param startCode     设备的编号
 *  @param buffer_O      O帧数据
 *  @param buffer_O_size O帧数据大小
 *
 *  @return 包含返回 YES 否则：NO
 */
-(BOOL)checkConnectVideoInExistStartCode:(int)startCode buffer_O:(char *)buffer_O buffer_O_size:(int)buffer_O_size{
    
    
    if (startCode==JVN_DSC_960CARD || [self IsFILE_HEADER_EX:buffer_O dwSize:buffer_O_size]) {
        
        
        return YES;
        
    }else {
        
        return NO;
    }
}

/**
 *  判断当前主控采用的编码器版本 05或04
 *
 *  @param startCode     设备的编号
 *
 *  @return 05返回YES 否则返回NO
 */
-(BOOL)checkConnectDeviceEncodModel:(int)startCode {
    
    if (startCode == JVN_DSC_CARD || startCode == JVN_DSC_9800CARD) {
        
        return NO;
        
    }else {
        
        return YES;
    }
}

/**
 *  判断传输的视频数据是否为标准的视频数据
 *
 *  @param videoBuffer 网络传输的视频数据
 *
 *  @return YES:标准 NO:非标准
 */
-(BOOL)checkVideoDataIsH264:(char *)videoBuffer{
    
    int startCode = 0;
    
    memcpy(&startCode,videoBuffer, 4);
    
    return [self checkConnectDeviceEncodModel:startCode];
}

/**
 *   获取远程回放视频的 帧速率 、总帧数 、宽、高
 *
 *  @param buffer_O      O帧数据
 *  @param buffer_O_size O帧数据大小
 *  @param videoWidth    视频的宽
 *  @param videoHeight   视频的高
 *  @param dFrameRate    远程文件的帧速率
 *
 *  @return 回放文件的总帧数
 */
-(int)getRemotePlaybackTotalFrameAndframeFrate:(char *)buffer_O buffer_O_size:(int)buffer_O_size videoWidth:(int *)videoWidth videoHeight:(int *)videoHeight dFrameRate:(double *)dFrameRate {
    
    int    nRemotePlaybackTotalFrame = 0;
    
    int    nWidth                    = 0;
    int    nHeight                   = 0;
    double dPlayBackVideoframeFrate  = kDefaultFrameRate;
    
    //判断新头
    if([self IsFILE_HEADER_EX:buffer_O dwSize:buffer_O_size]){
        
        
        memcpy(&nWidth, buffer_O+6, 4);
        memcpy(&nHeight, buffer_O+10, 4);
        
        JVS_FILE_HEADER_EX *fileHeader;
        
        fileHeader = malloc(sizeof(JVS_FILE_HEADER_EX));
        memset(fileHeader, 0, sizeof(JVS_FILE_HEADER_EX));
        memcpy(fileHeader, buffer_O+2, sizeof(JVS_FILE_HEADER_EX));
        
        nRemotePlaybackTotalFrame = fileHeader->dwRecFileTotalFrames;
        dPlayBackVideoframeFrate  = ((double)fileHeader->wFrameRateNum)/((double)fileHeader->wFrameRateDen);
        
        free(fileHeader);
        
    }else{
        
        JVS_FILE_HEADER jHeader;
        
        if ((*(unsigned int*)buffer_O&0xFFFFFF)!=0x53564a) {
            
            memcpy(&jHeader.width, buffer_O, sizeof(int));
            memcpy(&jHeader.height, buffer_O+4, sizeof(int));
            
            if (buffer_O_size>=12) {
                
                memcpy(&jHeader.dwToatlFrames, buffer_O+8, sizeof(int));
                
            }else{
                
                jHeader.dwToatlFrames = 0;//总针数
            }
        }
        
        
        nRemotePlaybackTotalFrame = jHeader.dwToatlFrames;
        nWidth                    = jHeader.width;
        nHeight                   = jHeader.height;
        
    }
    
    *videoWidth  = nWidth;
    *videoHeight = nHeight;
    *dFrameRate  = dPlayBackVideoframeFrate;
    
    return nRemotePlaybackTotalFrame;
}

/**
 *  将网络库传的key-value的buffer数据转成字典
 *
 *  @param pBuffer key-value
 *
 *  @return key-value字典
 */
-(NSMutableDictionary *)convertpBufferToMDictionary:(char *)pBuffer{
    
    NSMutableDictionary *amRemoteListDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if ([self checkBufferIslegal:pBuffer]) {
        
        char name[kValueAndKeyLength], para[kValueAndKeyLength];
        
        while (true) {
            
            memset(name, 0, sizeof(name));
            memset(para, 0, sizeof(para));
            
            if(sscanf(pBuffer, "%[^=]=%[^;];", name, para))
            {
                pBuffer = strchr(pBuffer, ';');
                
                if(pBuffer == NULL)
                    break;
                
                if (name == NULL || para == NULL) {
                    
                    pBuffer++;
                    continue;
                }
                
                NSString  *strPara = [[NSString alloc] initWithCString:para encoding:NSUTF8StringEncoding];
                NSString  *strName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
                
                if (strPara !=nil) {
                    
                    [amRemoteListDic setObject:strPara forKey:strName];
                    
                }
                
                [strPara release];
                [strName release];
                
                pBuffer++;
            }
            else
                break;
        }

    }
    
    return [amRemoteListDic autorelease];
}


/**
 *  将网络库传的key-value的buffer数据转成字典
 *
 *  @param pBuffer key-value
 *
 *  @return key-value字典
 */
-(NSMutableDictionary *)convertpBufferNoUtf8ToMDictionary:(char *)pBuffer{
    
    NSMutableDictionary *amRemoteListDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if ([self checkBufferIslegal:pBuffer]) {
        
        char name[kValueAndKeyLength], para[kValueAndKeyLength];
        
        while (true) {
            
            memset(name, 0, sizeof(name));
            memset(para, 0, sizeof(para));
            
            if(sscanf(pBuffer, "%[^=]=%[^;];", name, para))
            {
                pBuffer = strchr(pBuffer, ';');
                
                if(pBuffer == NULL)
                    break;
                
                if (name == NULL || para == NULL) {
                    
                    pBuffer++;
                    continue;
                }
                
                NSString  *strPara = [[NSString alloc] initWithUTF8String:para];
                NSString  *strName = [[NSString alloc] initWithUTF8String:name];
                
                if (strPara !=nil) {
                    
                    [amRemoteListDic setObject:strPara forKey:strName];
                    
                }else {
                    
                    [amRemoteListDic setObject:@"" forKey:strName];
                }
                
                [strPara release];
                [strName release];
                
                pBuffer++;
            }
            else
                break;
        }
    }
    
    return [amRemoteListDic autorelease];
}


/**
 *  获取指定Key的value
 *
 *  @param pBuffer    遍历的内容
 *  @param nameBuffer 查询的Key
 *
 *  @return 返回Value
 */
-(NSMutableString *)findBufferInExitValueToByKey:(char *)pBuffer nameBuffer:(char *)nameBuffer{
    
    NSMutableString *mStrReturnValue = [[NSMutableString alloc] initWithCapacity:10];
    
    if ([self checkBufferIslegal:pBuffer]) {
        
        char name[kValueAndKeyLength], para[kValueAndKeyLength];
        
        memset(name, 0, sizeof(name));
        memset(para, 0, sizeof(para));
        
        char  *p = strstr(pBuffer, nameBuffer);
        
        if (p != NULL) {
            
            if(sscanf(p, "%[^=]=%[^;];", name, para))
            {
                NSString  *strPara = [[NSString alloc] initWithCString:para encoding:NSUTF8StringEncoding];
                [mStrReturnValue appendString:strPara];
                [strPara release];
                
            }
        }
    }
    
    return [mStrReturnValue autorelease];
}

/**
 *  获取指定通道的马流参数信息
 *
 *  @param pBuffer       配置信息
 *  @param nChannelValue 指定通道
 *
 *  @return 指定通道的参数信息
 */
-(NSMutableDictionary *)getFrameParamInfoByChannel:(char *)pBuffer nChannelValue:(int)nChannelValue{
    
    NSMutableDictionary *amRemoteListDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if ([self checkBufferIslegal:pBuffer]) {
        
        NSString            *strFindKey      = [NSString stringWithFormat:@"%@%d%@",MOBILECHFRAMEBEGIN,nChannelValue,MOBILECHFRAMEEND];
        
        char  *p1,*p = strstr(pBuffer, [strFindKey UTF8String]);
        
        p+=strlen([strFindKey UTF8String]);
        
        if (p == NULL) {
            
            return [amRemoteListDic autorelease];
        }
        
        if (sizeof(p) <= 0) {
            
            return [amRemoteListDic autorelease];
        }
        
        p1 = strstr(p, [MOBILECHFRAMEBEGIN UTF8String]);
        
        if (p1 == NULL) {
            
            int nBufferOffset = p - pBuffer;
            
            char findKeyBuffer[nBufferOffset] ;
            
            memset(findKeyBuffer, 0, nBufferOffset);
            memcpy(findKeyBuffer, p, nBufferOffset);
            
            [amRemoteListDic addEntriesFromDictionary:[self convertpBufferToMDictionary:findKeyBuffer]];
            
        }else {
            
            int nBufferOffset = p1 - p;
            char findKeyBuffer[ nBufferOffset ] ;
            
            memset(findKeyBuffer, 0, nBufferOffset);
            memcpy(findKeyBuffer, p, nBufferOffset);
            
            [amRemoteListDic addEntriesFromDictionary:[self convertpBufferToMDictionary:findKeyBuffer]];
        }
    }
    
    return [amRemoteListDic autorelease];
}

/**
 *  判断是否存在内容
 *
 *  @param pBuffer
 *
 *  @return YES 存在
 */
-(BOOL)checkBufferIslegal:(char *)pBuffer {

    return strlen(pBuffer) > 0 ? YES : FALSE;
}

/**
 *  将设备的链接用户名密码数组转成字典
 *
 *  @param pBuffer key-value
 *
 *  @return 存放的数组集合
 */
-(NSMutableArray *)convertAccountBufferToArray:(char *)pBuffer{
    
    NSMutableArray *accountArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    if ([self checkBufferIslegal:pBuffer]) {
        
        char name[kValueAndKeyLength], para[kValueAndKeyLength];
        
        NSMutableDictionary *accountDic = nil;
        
        while (true) {
            
            memset(name, 0, sizeof(name));
            memset(para, 0, sizeof(para));
            

            if(sscanf(pBuffer, "%[^=]=%[^;];", name, para))
            {
                pBuffer = strchr(pBuffer, ';');
                
                if(pBuffer == NULL)
                    break;
                
                if (name == NULL || para == NULL) {
                    
                    pBuffer++;
                    continue;
                }
                
                NSString  *strPara = [[NSString alloc] initWithUTF8String:para];
                NSString  *strName = [[NSString alloc] initWithUTF8String:name];
                
                if (accountDic == nil) {
                    
                    accountDic  = [[NSMutableDictionary alloc] initWithCapacity:10];
                    
                }else {
                    
                    if ([accountDic objectForKey:strName]) {
                        
                        [accountArray addObject:accountDic];
                        [accountDic release];
                        
                        accountDic  = [[NSMutableDictionary alloc] initWithCapacity:10];
                        
                    }
                }
                
                if (strPara !=nil) {
                    
                    [accountDic setObject:strPara forKey:strName];
                    
                }else {
                    
                    [accountDic setObject:@"" forKey:strName];
                }
               
                
                [strPara release];
                [strName release];
                
                pBuffer++;
            }
            else
                  break;
        }
        
        if (accountDic) {
            
            [accountArray addObject:accountDic];
            [accountDic release];
        }
    }
    
    return [accountArray autorelease];
}

@end
