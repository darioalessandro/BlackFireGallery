//
//  FBUserPictures.m
//  BFGallery
//
//  Created by Dario Lencina on 10/14/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import "FBUserPictures.h"
#import <FacebookSDK/FacebookSDK.h>
#import "BFLog.h"
#import "FBImage.h"

@implementation FBUserPicturesParser

-(id)init{
    self= [super init];
    if(self)
        self.queue= [NSOperationQueue new];
    return self;
}

-(void)start{
    [FBRequestConnection startWithGraphPath:@"/me/albums"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if(error) {
                                  BFLog(@"error %@", error);
                                  return;
                              }else{
                                  [self parseAlbums:(NSArray *)[result data]];
                              }
    }];
}

-(void)parseAlbums:(NSArray *)rawAlbums{
    //TODO add the case when there are no pics.
    self.albums= [NSMutableArray array];
    for(NSDictionary * album in rawAlbums){
        [self.albums addObject:[NSMutableDictionary dictionaryWithDictionary:album]];
    }
    
    NSArray* collection= self.albums;
    for(NSMutableDictionary * album in collection){
        [self getPicturesFromAlbum:album];
    }                                 
}

-(void)getPicturesFromAlbum:(NSMutableDictionary *)album{
    if([[album objectForKey:@"name"] hasPrefix:@"LeRandomMe"]){
        BFLog(@"filtering out LeRandomMe album");
        return;
    }
    
    NSString* photosGraphPath = [NSString stringWithFormat:@"%@/photos", [album objectForKey:@"id"]];
    [FBRequestConnection startWithGraphPath:photosGraphPath
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if(error){                                  
                                  [self parsingAlbum:album failedWithError:error];
                              }else{
                                  [self parsePhotosFromConnection:connection withResult:result intoAlbum:album];
                              }
    }];
}

-(void)parsingAlbum:(NSDictionary *)album failedWithError:(NSError *)error{
    BFLog(@"error %@", error);
     [self.delegate parser:self failedToLoadAlbum:album withError:error];
}

-(void)parsePhotosFromConnection:(FBRequestConnection *)connection withResult:(id)result intoAlbum:(NSMutableDictionary *)album{
    NSArray* photos = (NSArray*)[result data];
    NSMutableArray * mutablePhotos= [NSMutableArray array];
    [album setObject:mutablePhotos forKey:kFBUserPicturesKey];
    for(NSDictionary * photo in photos){
        NSArray * images=[photo objectForKey:@"images"];
        FBImage * image= [FBImage new];
        [image setAlbum:album];
        [mutablePhotos addObject:image];
        NSString * thumbPath= [images[7] objectForKey:@"source"];
        NSString * fullPath= [images[2] objectForKey:@"source"];
        [image setThumbnailServerPath:[NSURL URLWithString:thumbPath]];
        [image setFullSizeImageServerPath:[NSURL URLWithString:fullPath]];
        NSURLRequest * req= [NSURLRequest requestWithURL:image.thumbnailServerPath];
        [NSURLConnection sendAsynchronousRequest:req queue:self.queue completionHandler:^(NSURLResponse * resp, NSData * img, NSError * error){
            if(!error){
                image.thumbnail= [UIImage imageWithData:img];
            }else{
                BFLog(@"error %@", error);
            }
            [self didFinishLoadingImage:image];
        }];
    }
}

-(void)didFinishLoadingImage:(FBImage *)image{
    if(self.queue.operationCount==1){
        [self.delegate  parser:self didFinishDownloadingAlbum:image.album];
    }
}


@end
