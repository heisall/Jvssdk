//
//  JVCPhotoModelObj.h
//  CloudSEE_II
//
//  Created by Yanghu on 11/14/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JVCPhotoModelObj : NSObject
{
    UIImage *imgSmall;            //存放的小图
    UIImage *imgBig;              //存放的大图
    NSDate *dateCreateImageDate;  //存放的时间
    NSURL *videoUrl;                   //存放视频的URL
    BOOL  selectState;             //选中状态
    
}
@property(nonatomic,assign)BOOL  selectState;   
@property(nonatomic,retain)UIImage *ImgSmall;
@property(nonatomic,retain)UIImage *ImgBig;
@property(nonatomic,retain)NSDate *dateCreateImageDate;
@property(nonatomic,retain)NSURL *videoUrl;

@end
