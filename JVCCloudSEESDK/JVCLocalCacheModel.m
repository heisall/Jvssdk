//
//  JVCLocalCacheModel.m
//  CloudSEE_II
//  缓存设备数据的Model,用于设置网络小助手
//  Created by chenzhenyang on 14-10-13.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCLocalCacheModel.h"

@implementation JVCLocalCacheModel
@synthesize strYstNumber,strUserName,strPassWord;

static NSString const *kLocalCacheModelWithYstNumber = @"ystNumber";
static NSString const *kLocalCacheModelWithUsername  = @"username";
static NSString const *kLocalCacheModelWithPassword  = @"password";

-(void)dealloc{
    
    [strYstNumber release];
    strYstNumber=nil;
    [strUserName release];
    strUserName=nil;
    [strPassWord release];
    strPassWord=nil;
    [super dealloc];
}

/**
 *对象序列化
 **/
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.strYstNumber forKey:(NSString *)kLocalCacheModelWithYstNumber];
    [aCoder encodeObject:self.strUserName  forKey:(NSString *)kLocalCacheModelWithUsername];
    [aCoder encodeObject:self.strPassWord  forKey:(NSString *)kLocalCacheModelWithPassword];
}

/**
 *对象反序列化
 **/
- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if(self=[self init]){
        
        self.strYstNumber = [aDecoder  decodeObjectForKey:(NSString *)kLocalCacheModelWithYstNumber];
        self.strUserName  = [aDecoder  decodeObjectForKey:(NSString *)kLocalCacheModelWithUsername];
        self.strPassWord  = [aDecoder  decodeObjectForKey:(NSString *)kLocalCacheModelWithPassword];
    }
    
    return self;
}

@end
