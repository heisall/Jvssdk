//
//  JVCLocalCacheModel.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-10-13.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVCLocalCacheModel : NSObject <NSCoding>{
    
    NSString *strYstNumber;
    NSString *strUserName;
    NSString *strPassWord;
}

@property(nonatomic,retain) NSString *strYstNumber;
@property(nonatomic,retain) NSString *strUserName;
@property(nonatomic,retain) NSString *strPassWord;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
