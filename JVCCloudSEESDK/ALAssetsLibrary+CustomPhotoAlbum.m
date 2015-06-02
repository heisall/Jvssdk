//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface ALAssetsLibrary (Private)

/*! A block wraper to be executed after asset adding process done. (Private)
 *
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed to add the asset to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */
- (ALAssetsLibraryWriteImageCompletionBlock)_resultBlockOfAddingToAlbum:(NSString *)albumName
                                                             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! A block wraper to be executed after |-assetForURL:resultBlock:failureBlock:| succeed.
 *  Generally, this block will be excused when user confirmed the application's access
 *    to the library.
 *
 * \param group A group to be used to add photo to the target album
 * \param assetURL The URL for the target asset
 * \param completion Block to be executed when succeed to add the asset to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 *
 * \return An ALAssetsLibraryAssetForURLResultBlock type block
 */
- (ALAssetsLibraryAssetForURLResultBlock)_assetForURLResultBlockWithGroup:(ALAssetsGroup *)group
                                                                 assetURL:(NSURL *)assetURL
                                                               completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                  failure:(ALAssetsLibraryAccessFailureBlock)failure;

@end


@implementation ALAssetsLibrary (CustomPhotoAlbum)

#pragma mark - Private Method

- (ALAssetsLibraryWriteImageCompletionBlock)_resultBlockOfAddingToAlbum:(NSString *)albumName
                                                             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    return ^(NSURL *assetURL, NSError *error) {
        // run the completion block for writing image to saved
        //   photos album
        //if (completion) completion(assetURL, error);
        
        // if an error occured, do not try to add the asset to
        //   the custom photo album
        if (error != nil) {
            if (failure) failure(error);
            return;
        }
        
        // add the asset to the custom photo album
        [self addAssetURL:assetURL
                  toAlbum:albumName
               completion:completion
                  failure:failure];
    };
}

- (ALAssetsLibraryAssetForURLResultBlock)_assetForURLResultBlockWithGroup:(ALAssetsGroup *)group
                                                                 assetURL:(NSURL *)assetURL
                                                               completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                  failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    return ^(ALAsset *asset) {
        // add photo to the target album
        if ([group addAsset:asset]) {
            // run the completion block if the asset was added successfully
            if (completion) completion(assetURL, nil);
        }
        // |-addAsset:| may fail (return NO) if the group is not editable,
        //   or if the asset could not be added to the group.
        else {
            NSString * message = [NSString stringWithFormat:@"ALAssetsGroup failed to add asset: %@.", asset];
            failure([NSError errorWithDomain:@"LIB_ALAssetsLibrary_CustomPhotoAlbum"
                                        code:0
                                    userInfo:@{NSLocalizedDescriptionKey : message}]);
        }
    };
}

#pragma mark - Public Method

- (void)saveImage:(UIImage *)image
          toAlbum:(NSString *)albumName
       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    [self writeImageToSavedPhotosAlbum:image.CGImage
                           orientation:(ALAssetOrientation)image.imageOrientation
                       completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                              completion:completion
                                                                 failure:failure]];
}

- (void)saveVideo:(NSURL *)videoUrl
          toAlbum:(NSString *)albumName
       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
//    NSLog(@"==========002=======");

    [self writeVideoAtPathToSavedPhotosAlbum:videoUrl
                             completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                    completion:completion
                                                                       failure:failure]];
}

- (void)saveImageData:(NSData *)imageData
              toAlbum:(NSString *)albumName
             metadata:(NSDictionary *)metadata
           completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
              failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    [self writeImageDataToSavedPhotosAlbum:imageData
                                  metadata:metadata
                           completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                  completion:completion
                                                                     failure:failure]];
}

- (void)addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
         completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
            failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    __block BOOL albumWasFound = NO;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock;
    enumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        // compare the names of the albums
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            // target album is found
            albumWasFound = YES;
            
            // Get a hold of the photo's asset instance
            // If the user denies access to the application, or if no application is allowed to
            //   access the data, the failure block is called.
            ALAssetsLibraryAssetForURLResultBlock assetForURLResultBlock =
            [self _assetForURLResultBlockWithGroup:group
                                          assetURL:assetURL
                                        completion:completion
                                           failure:failure];
            [self assetForURL:assetURL
                  resultBlock:assetForURLResultBlock
                 failureBlock:failure];
            
            // album was found, bail out of the method
            return;
        }
        
        if (group == nil && albumWasFound == NO) {
            // photo albums are over, target album does not exist, thus create it
            
            // Since you use the assets library inside the block,
            //   ARC will complain on compile time that there’s a retain cycle.
            //   When you have this – you just make a weak copy of your object.
            __weak ALAssetsLibrary * weakSelf = self;
            
            // if iOS version is lower than 5.0, throw a warning message
            if (! [self respondsToSelector:@selector(addAssetsGroupAlbumWithName:resultBlock:failureBlock:)])
                NSLog(@"![WARNING][LIB:ALAssetsLibrary+CustomPhotoAlbum]: \
                      |-addAssetsGroupAlbumWithName:resultBlock:failureBlock:| \
                      only available on iOS 5.0 or later. \
                      ASSET cannot be saved to album!");
            // create new assets album
            else {
                
                [self addAssetsGroupAlbumWithName:albumName
                                      resultBlock:^(ALAssetsGroup *createdGroup) {
                                          // get the photo's instance
                                          //   add the photo to the newly created album
                                          ALAssetsLibraryAssetForURLResultBlock assetForURLResultBlock =
                                          [weakSelf _assetForURLResultBlockWithGroup:createdGroup
                                                                            assetURL:assetURL
                                                                          completion:completion
                                                                             failure:failure];
                                          [weakSelf assetForURL:assetURL
                                                    resultBlock:assetForURLResultBlock
                                                   failureBlock:failure];
                                      }
                                     failureBlock:failure];
            }
            
            // should be the last iteration anyway, but just in case
            return;
        }
    };
    
    // search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:enumerationBlock
                      failureBlock:failure];
}

@end
