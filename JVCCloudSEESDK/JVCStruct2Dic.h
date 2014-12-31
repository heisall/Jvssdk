//
//  JVCStruct2Dic.h
//  CloudSEE_II
//  网络库结构体转换字典的助手类
//  Created by chenzhenyang on 14-12-26.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCStruct2DicMacro.h"
#import "JVNetConst.h"

@interface JVCStruct2Dic : NSObject

/**
 *  packet包转换字典
 *
 *  @param    packet  被转换的包
 *  @param    nSize   数据包的大小
 *  @param    nOffSet packet包acdata的偏移量
 *
 *  @return 转换后的字典
 */
+(NSMutableDictionary *)dicWithPacketStrcut:(char *)packetData withSize:(int)nSize withOffset:(UInt32)nOffSet;

/**
 *  字典转结构体
 *
 *  @param dic 字典
 *
 *  @return 结构体
 */
+(BOOL)packetStrcutWithDic:(NSDictionary *)dic withStrcut:(PAC *)stpacket;

@end
