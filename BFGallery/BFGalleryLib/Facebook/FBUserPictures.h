//
//  FBUserPictures.h
//  BFGallery
//
//  Created by Dario Lencina on 10/14/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kFBUserPicturesKey @"photos"
@class FBImage, FBUserPicturesParser;

@protocol FBUserPicturesParserDelegate <NSObject>
@required
-(void)parser:(FBUserPicturesParser *)fbParser didFinishDownloadingAlbum:(NSDictionary *)album;
-(void)parser:(FBUserPicturesParser *)fbParser failedToLoadAlbum:(NSDictionary *)album withError:(NSError *)error;
-(void)parser:(FBUserPicturesParser *)fbParser didFinishDownloadingImage:(FBImage *)image;
-(void)parser:(FBUserPicturesParser *)fbParser didFinishDownloadingAlbums:(NSArray *)albums;
@end

@interface FBUserPicturesParser : NSObject 
    -(void)start;
    @property (nonatomic, strong) NSMutableArray * albums;
    @property (nonatomic, strong) NSOperationQueue * queue;
    @property (nonatomic, weak) id<FBUserPicturesParserDelegate> delegate;
    -(void)picturesFromAlbum:(NSMutableDictionary *)album;
@end

