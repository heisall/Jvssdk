//
//  JVCConstansALAssetsMathHelper.m
//  CloudSEE_II
//
//  Created by Yanghu on 11/14/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import "JVCConstansALAssetsMathHelper.h"
#import "JVCPhotoModelObj.h"
#import "JVCCloudSEESDKMacro.h"
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
#import <Photos/Photos.h>
//#endif

#define VideoCacheDataSize 1024*1024
char videoCacheData[VideoCacheDataSize];

#define IOS8    [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO

@implementation JVCConstansALAssetsMathHelper
@synthesize assetLibrary;
@synthesize AseeetDelegate;



-(id)init{
    
    if (self=[super init]) {
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        self.assetLibrary=library;
        [library release];
    }
    
    return self;
}

-(void)dealloc{
    
    
    [assetLibrary release];
    [super dealloc];
    
    
}

#pragma ----------------------------------------
#pragma mark  创建指定的相册文件夹和保存相册数据的方法
#pragma ----------------------------------------

/**
 *	保存图片、录像视频到相册失败时回调的Block
 *
 *	@return	失败时回调的Block
 */
-(ALAssetsLibraryAccessFailureBlock)returnALAssetsLibraryAccessFailureBlock{
    
    
    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
        
        //  "pictureLibraynoAutor" = "无法访问相册.请在'设置->定位服务'设置为打开状态.";
        if ([myerror.localizedDescription rangeOfString:NSLocalizedString(@"userDefine", nil)].location!=NSNotFound) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // [OperationSet showText:NSLocalizedString(@"pictureLibraynoAutor", nil) andPraent:self andTime:1 andYset:150];
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[OperationSet showText:NSLocalizedString(@"picturelibrayError", nil) andPraent:self andTime:1 andYset:150];
                //   NSLog(@"相册访问失败.");
                
            });
            
        }
    };
    
    return failureblock;
}

/**
 *
 *	抓拍保存到相册的函数
 *
 *	@param	saveImage	    保存的图片
 *	@param	albumGroupName	保存到指定的相册名称
 */
-(void)saveImageToAlbumPhoto:(UIImage *)saveImage albumGroupName:(NSString *)albumGroupName returnALAssetsLibraryAccessFailureBlock:(ALAssetsLibraryAccessFailureBlock)returnALAssetsLibraryAccessFailureBlock{
    
    
    void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
    
        if (!error){
            
            [self performSelectorOnMainThread:@selector(saveImagetoCustomAlbum:) withObject:[NSString stringWithFormat:@"%d",RESULT_SUCCESSFUL] waitUntilDone:NO];
            
        }else{
            
            [self performSelectorOnMainThread:@selector(saveImagetoCustomAlbum:) withObject:[NSString stringWithFormat:@"%d",RESULT_ERROR] waitUntilDone:NO];
        }
    };
    
    [self.assetLibrary saveImage:saveImage
                    toAlbum:albumGroupName
                 completion:completion
                    failure:returnALAssetsLibraryAccessFailureBlock];
    
}


/**
 *
 *	保存视频到相册
 *
 *	@param	videoUrl	    视频的地址
 *	@param	albumGroupName	视频的相册文件夹名称
 */
-(void)saveVideoToAlbumPhoto:(NSURL *)videoUrl albumGroupName:(NSString *)albumGroupName returnALAssetsLibraryAccessFailureBlock:(ALAssetsLibraryAccessFailureBlock)returnALAssetsLibraryAccessFailureBlock{
    
    
    void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        
        if (!error){
            
            [self performSelectorOnMainThread:@selector(saveVideotoCustomAlbum:) withObject:[NSString stringWithFormat:@"%d",RESULT_SUCCESSFUL] waitUntilDone:NO];
            
        }else{
            
            [self performSelectorOnMainThread:@selector(saveVideotoCustomAlbum:) withObject:[NSString stringWithFormat:@"%d",RESULT_ERROR] waitUntilDone:NO];
        }
    };
    
    [self.assetLibrary saveVideo:videoUrl toAlbum:albumGroupName completion:completion failure:returnALAssetsLibraryAccessFailureBlock];
    
}

/**
 *	检测相册里面是否存在指定的相册
 *  如果不存在就创建一个
 *
 *	@param	albumGroupName	指定的相册的名称 例如：jovision
 */
-(void)checkAlbumNameIsExist:(NSString *)albumGroupName{
    
    
    //存放已有相册名称的数组
    NSMutableArray  *albumNamesMArray=[[NSMutableArray alloc] initWithCapacity:10];
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group)
        {
            [albumNamesMArray addObject:group];
        }
        
        else
        {
            BOOL haveHDRGroup = NO;
            
            for (ALAssetsGroup *albumName in albumNamesMArray)
            {
                NSString *name =[albumName valueForProperty:ALAssetsGroupPropertyName];
                
                if ([name isEqualToString:albumGroupName])
                {
                    haveHDRGroup = YES;
                }
            }
            
            if (!haveHDRGroup)
            {
                //do add a group named "HDR"
                [self.assetLibrary addAssetsGroupAlbumWithName:albumGroupName
                                               resultBlock:^(ALAssetsGroup *group)
                 {
                     if (group!=nil) {
                         
                         [albumNamesMArray addObject:group];
                         
                     }else{
                         
                         if (IOS8) {
                             
                             [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                 
                                 [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumGroupName];
                                 
                             } completionHandler:^(BOOL success,NSError *error){
                                 
                                 // DDLogVerbose(@"%s-------success=%d",__FUNCTION__,success);
                                 
                             }];
                         }
                         
                     }
                 }
                 
                 failureBlock:nil];
                
                haveHDRGroup = YES;
            }
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        
        NSString *errorMessage = nil;
        
        switch ([error code]) {
                
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
    };
    
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock
                               failureBlock:failureBlock];
    
    [albumNamesMArray release];
    
}

/**
 *
 *  从ALAssetsLibrary中可读取特定groupName的ALAssetsGroup对象列表
 *
 *  @param	groupName	指定的ALAssetsGroup的名称
 *  @param  mathType    0:相册 1:视频
 *
 *	@return	特定ALAssetsGroup对象列表
 */
-(void)returnAblumGroupNameArrayDatas:(NSString *)groupName mathType:(int)mathType{
    
    
    //临时存放的所有ALAssetsGroup对象列表
    NSMutableArray *cacheGroupsMArray=[[NSMutableArray alloc] initWithCapacity:10];
    
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        
        if (!group) {
            
            bool checkresult=TRUE;
            
            //判断相册的所有group列表里面是否存在要查找的group,如果存在添加到返回的数组里面;
            for (ALAssetsGroup *albumName in cacheGroupsMArray)
            {
                NSString *name =[albumName valueForProperty:ALAssetsGroupPropertyName];
                
                if ([name isEqualToString:groupName])
                {
                    checkresult=FALSE;
                    
                    if (mathType==MATH_TYPE_PHOTO) {
                        
                        [self returnAblumGroupNameInALAssetDatas:groupName assetsGroup:albumName];
                        
                    }else{
                        
                        [self returnAblumGroupNameInALAssetVideoDatas:groupName assetsGroup:albumName];
                    }
                    
                    break;
                }
            }
            
            if (checkresult) {
                
                [self performSelectorOnMainThread:@selector(runCallBack:) withObject:nil waitUntilDone:NO];
                
            }
            
        }else{
            
            [cacheGroupsMArray addObject:group];
        }
        
    } failureBlock:^(NSError *error) {
        
        [self performSelectorOnMainThread:@selector(runCallBack:) withObject:nil waitUntilDone:NO];
        
    }];
    
    [cacheGroupsMArray release];
}


/**
 *
 *  从ALAssetsGroup对象遍历ALAssetsGroup中的所有ALAsset
 *
 *  @param	groupName	指定的ALAssetsGroup的名称
 *
 获取Assets的各种属性
 [assetsGroup posterImage];                             //相册封面图片
 [[[asset defaultRepresentation] url] absoluteString];  //照片url
 [asset thumbnail];                                     //照片缩略图
 [asset aspectRatioThumbnail];                          //照片缩略图
 [[asset defaultRepresentation] fullResolutionImage];   //照片全尺寸图
 [[asset defaultRepresentation] fullScreenImage];       //照片全屏图
 [asset valueForProperty:ALAssetPropertyDate];          //照片创建时间
 [asset valueForProperty:ALAssetPropertyLocation];      //照片拍摄位置(可能为nil)
 [[asset defaultRepresentation] dimensions];            //照片尺寸
 *	@return	特定ALAssets对象列表
 */
-(void)returnAblumGroupNameInALAssetDatas:(NSString *)groupName assetsGroup:(ALAssetsGroup*)assetsGroup{
    
    
    NSMutableArray *assetsGroupDatasMArray=[NSMutableArray arrayWithCapacity:10];
    
    if (assetsGroup) {
        
        [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (!result) {
                    
                    [self performSelectorOnMainThread:@selector(runCallBack:) withObject:assetsGroupDatasMArray waitUntilDone:NO];
                    
                }else{
                    
                   JVCPhotoModelObj *photo = [[JVCPhotoModelObj alloc] init];
                    
                    photo.imgSmall = [UIImage imageWithCGImage:result.thumbnail];
                    photo.imgBig=[UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]];
                    photo.dateCreateImageDate = [result valueForProperty:ALAssetPropertyDate];
                    [assetsGroupDatasMArray addObject:photo];
                    
                    [photo release];
                }
            }];
        });
        
    }
}


-(void)returnAblumGroupNameInALAssetVideoDatas:(NSString *)groupName assetsGroup:(ALAssetsGroup*)assetsGroup{
    
    
    __block int blockSize=VideoCacheDataSize;
    
    NSMutableArray *assetsGroupDatasMArray=[NSMutableArray arrayWithCapacity:10];
    
    if (assetsGroup) {
        
        [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (!result) {
                    
                    [self performSelectorOnMainThread:@selector(runCallBack:) withObject:assetsGroupDatasMArray waitUntilDone:NO];
                    
                }else{
                    
                    NSFileManager *fileManger=[NSFileManager defaultManager];
                    
                    NSString *documentPaths = NSTemporaryDirectory();
                    
                    NSString *filePath = [documentPaths stringByAppendingPathComponent:@"LocalValue"];
                    
                    NSMutableData *videoDataMData=[[NSMutableData alloc] initWithCapacity:10];
                    
                    if(![fileManger fileExistsAtPath:filePath]){
                        [fileManger createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
                    }
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"YYYYMMddHHmmssSSSS"];
                    
                    
                    NSFileHandle *outFile;
                    
                    JVCPhotoModelObj *photo = [[JVCPhotoModelObj alloc] init];
                    
                    photo.imgSmall = [UIImage imageWithCGImage:result.thumbnail];
                    
                    photo.imgBig=[UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]];
                    
                    photo.dateCreateImageDate = [result valueForProperty:ALAssetPropertyDate];
                    
                    
                    
                    NSString *VideoPath=[NSString stringWithFormat:@"%@/%@.mp4",filePath,[df stringFromDate:[NSDate date]]];
                    [df release];
                    
                    if (![fileManger fileExistsAtPath:VideoPath]) {
                        
                        [fileManger createFileAtPath:VideoPath contents:nil attributes:nil];
                    }
                    
                    photo.videoUrl=[NSURL URLWithString:VideoPath];
                    
                    NSString *assetType=[result valueForProperty:ALAssetPropertyType];
                    
                    if ([assetType isEqualToString:ALAssetTypeVideo]) {
                        
                        
                        ALAssetRepresentation *assetResper=[result defaultRepresentation];
                        
                        NSUInteger size=[assetResper size];
                        
                        outFile=[NSFileHandle fileHandleForWritingAtPath:VideoPath];
                        
                        if (size>0) {
                            
                            int redCountValue=size/blockSize;
                            int checkBlock=size%blockSize;
                            
                            if (checkBlock!=0) {
                                
                                redCountValue=redCountValue+1;
                            }
                            
                            for (int i=0; i<redCountValue; i++) {
                                
                                NSError *err=nil;
                                
                                memset(videoCacheData,0,blockSize);
                                int endSize=blockSize;
                                
                                if (blockSize*(i+1)>size) {
                                    
                                    endSize=size-blockSize*i;
                                    
                                }
                                
                                NSUInteger gotByteCount=[assetResper getBytes:(uint8_t *)videoCacheData fromOffset:blockSize*i length:endSize error:&err];
                                
                                
                                if (gotByteCount) {
                                    
                                    if (err) {
                                        
                                        break;
                                        
                                    }else{
                                        
                                        if (outFile!=nil) {
                                            
                                            [outFile seekToEndOfFile];
                                            
                                            [videoDataMData appendBytes:videoCacheData length:endSize];
                                            [outFile writeData:videoDataMData];
                                            [videoDataMData resetBytesInRange:NSMakeRange(0, videoDataMData.length)];
                                            [videoDataMData setLength:0];
                                        }
                                        
                                    }
                                }
                            }
                            
                            if (outFile!=nil) {
                                
                                [outFile closeFile];
                            }
                            
                        }
                        
                        
                    }
                    [videoDataMData release];
                    [assetsGroupDatasMArray addObject:photo];
                    [photo release];
                }
            }];
        });
        
    }
}

/**
 *
 *  获取指定的相册对象集合
 *
 *  @param	callbackData 回调返回的数据
 *
 */
-(void)runCallBack:(NSMutableArray *)callbackData{
    
    if (AseeetDelegate !=nil&&[AseeetDelegate respondsToSelector:@selector(alAssetsDatecallBack:)]) {
        
        [AseeetDelegate alAssetsDatecallBack:callbackData];
    }
}

- (void)saveVideotoCustomAlbum:(NSString *)result
{
    if (AseeetDelegate !=nil&&[AseeetDelegate respondsToSelector:@selector(saveVideoToAlassertsWithResult:)]) {
        
        [AseeetDelegate saveVideoToAlassertsWithResult:result.intValue];
    }
}

- (void)saveImagetoCustomAlbum:(NSString *)result
{
    if (AseeetDelegate !=nil&&[AseeetDelegate respondsToSelector:@selector(savePhotoToAlassertsWithResult:)]) {
        
        [AseeetDelegate savePhotoToAlassertsWithResult:result.intValue];
    }
}


@end
