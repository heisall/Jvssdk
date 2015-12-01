//
//  JVCStruct2Dic.m
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-12-26.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCStruct2Dic.h"
#import "JVCCloudSEENetworkGeneralHelper.h"

@implementation JVCStruct2Dic

/**
 *  packet包转换字典
 *
 *  @param    packet  被转换的包
 *  @param    nSize   数据包的大小
 *  @param    nOffSet packet包acdata的偏移量
 *
 *  @return 转换后的字典
 */
+(NSMutableDictionary *)dicWithPacketStrcut:(char *)packetData withSize:(int)nSize withOffset:(UInt32)nOffSet{
    
    NSMutableDictionary *dicPacket = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];  //存放转换后的字典
    
    PAC stpacket = {0};
    memcpy(&stpacket, packetData, nSize);
    
    NSString *strData =  [[NSString alloc] initWithFormat:@"%s",stpacket.acData+nOffSet];
    
    
    [dicPacket setObject:[NSNumber numberWithInt:stpacket.nPacketType]  forKey:KPacketType];
    [dicPacket setObject:[NSNumber numberWithInt:stpacket.nPacketID]    forKey:KPacketID];
    [dicPacket setObject:[NSNumber numberWithInt:stpacket.nPacketLen]   forKey:KPacketLen];
    [dicPacket setObject:[NSNumber numberWithInt:stpacket.nPacketCount] forKey:KPacketCount];
    
    switch (stpacket.nPacketType) {
            
        case RC_EXTEND:{
            
            EXTEND *extend=(EXTEND*)stpacket.acData;
            
            NSMutableDictionary *dicExtend = [[NSMutableDictionary alloc] initWithCapacity:10] ;  //存放转换后的字典
            
            [dicExtend setObject:[NSNumber numberWithInt:extend->nType]   forKey:KExtendType];
            [dicExtend setObject:[NSNumber numberWithInt:extend->nParam1] forKey:KExtendParam1];
            [dicExtend setObject:[NSNumber numberWithInt:extend->nParam2] forKey:KExtendParam2];
            [dicExtend setObject:[NSNumber numberWithInt:extend->nParam3] forKey:KExtendParam3];
            
            NSString *extendData =  [[NSString alloc] initWithFormat:@"%s",extend->acData];
            
            switch (stpacket.nPacketCount) {
                    
                case RC_EX_ACCOUNT:{
                    
                    switch (extend->nType) {
                            
                        case EX_ACCOUNT_REFRESH:{
                            
                            [dicExtend setObject:[[JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper] convertAccountBufferToArray:extend->acData] forKey:KExtendAccount];
                        }
                            break;
                            
                        default:
                            [dicExtend setObject:extendData forKey:KExtendData];
                            break;
                    }
                }
                    break;
                default:
                    [dicExtend setObject:extendData forKey:KExtendData];
                    break;
            }
            
            [extendData release];
            
            [dicPacket setObject:dicExtend forKey:kExtendInfo];
            [dicExtend release];

        }
            break;
            
        default:{
            
            [dicPacket setObject:strData.length>0?strData:@"" forKey:KPacketData];
        }
            break;
    }
    
    [strData release];
    
    return dicPacket;
};

/**
 *  字典转结构体
 *
 *  @param dic 字典
 *
 *  @return 结构体
 */
+(BOOL)packetStrcutWithDic:(NSDictionary *)dic withStrcut:(PAC *)stpacket{
    
    if (dic == nil || stpacket == nil) {
        
        return FALSE;
    }

    
    if ([self checkValueWithKey:dic withKey:KPacketType]) {
        
        stpacket->nPacketType = [[dic objectForKey:KPacketType] intValue];
    }
    
    if ([self checkValueWithKey:dic withKey:KPacketCount]) {
        
        stpacket->nPacketCount = [[dic objectForKey:KPacketCount] intValue];
    }
    
    if ([self checkValueWithKey:dic withKey:KPacketID]) {
        
        stpacket->nPacketID = [[dic objectForKey:KPacketID] intValue];
    }
    
    if ([self checkValueWithKey:dic withKey:KPacketLen]) {
        
        stpacket->nPacketLen = [[dic objectForKey:KPacketLen] intValue];
    }
    
    switch (stpacket->nPacketType) {
            
        case RC_EXTEND:{
        
            EXTEND       *extend     = (EXTEND*)stpacket->acData;
            
            if ([self checkValueWithKey:dic withKey:kExtendInfo]) {
                
                NSDictionary *extendDic   = [dic objectForKey:kExtendInfo];
                
                if ([self checkValueWithKey:extendDic withKey:KExtendType]) {
                    
                    extend->nType = [[extendDic objectForKey:KExtendType] intValue];
                }
                
                if ([self checkValueWithKey:extendDic withKey:KExtendParam1]) {
                    
                    extend->nParam1 = [[extendDic objectForKey:KExtendParam1] intValue];
                }
                
                if ([self checkValueWithKey:extendDic withKey:KExtendParam2]) {
                    
                    extend->nParam2 = [[extendDic objectForKey:KExtendParam2] intValue];
                }
                
                if ([self checkValueWithKey:extendDic withKey:KExtendParam3]) {
                    
                    extend->nParam3 = [[extendDic objectForKey:KExtendParam3] intValue];
                }
                
                if ([self checkValueWithKey:extendDic withKey:KExtendData]) {
                    
                    const char *sendData = [[extendDic objectForKey:KExtendData] UTF8String];
                    
                    int len     = strlen(sendData);
                    int maxLen  = sizeof(extend->acData);
                    
                    memcpy(extend->acData, sendData,len<maxLen?len:maxLen-1);
                }
            }
        }
            break;
            
        default:{
            
            if ([self checkValueWithKey:dic withKey:(NSString *)KPacketData]) {
                
                const char *sendData = [[dic objectForKey:KPacketData] UTF8String];
        
                int len     = strlen(sendData);
                int maxLen  = sizeof(stpacket->acData);
                
                memcpy(stpacket->acData, sendData,len<maxLen?len:maxLen-1);
            }
            
        
        }
            break;
    }
    

    return YES;
}

//unicode编码以\u开头
+(NSString *)replaceUnicodeChar:(NSString *)unicodeStr
{
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

/**
 *  判断字典中是否存在指定的key值
 *
 *  @param dic 查询的字典
 *  @param key 查询的key
 *
 *  @return YES:存在
 */
+(BOOL)checkValueWithKey:(NSDictionary *)dic withKey:(id)key{
    
    return [dic objectForKey:key] == nil ? FALSE : TRUE;
}


@end
