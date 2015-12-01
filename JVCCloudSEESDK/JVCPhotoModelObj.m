//
//  JVCPhotoModelObj.m
//  CloudSEE_II
//
//  Created by Yanghu on 11/14/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import "JVCPhotoModelObj.h"

@implementation JVCPhotoModelObj

@synthesize ImgBig,ImgSmall,dateCreateImageDate;
@synthesize videoUrl;
@synthesize selectState;
-(void)dealloc{
    
    [ImgBig release];
    [ImgSmall release];
    [dateCreateImageDate release];
    [videoUrl release];
    [super dealloc];
    
}

@end
