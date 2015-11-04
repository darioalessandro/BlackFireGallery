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
#import "FBAlbum.h"

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
                                  [self parsingAlbum:nil failedWithError:error];
                                  return;
                              }else{
                                  [self parseAlbums:[(NSArray *)[result data] copy]];
                              }
    }];
}

-(void)parseAlbums:(NSArray *)rawAlbums{
    //TODO add the case when there are no pics.
    self.albums= [NSMutableArray array];
    for(NSDictionary * album in rawAlbums){
        FBAlbum * fbAlbum= [[FBAlbum alloc] init];
        fbAlbum.albumInfo=[album mutableCopy];
        [self.albums addObject:fbAlbum];
    }
    [[self delegate] parser:self didFinishDownloadingAlbums:self.albums];
}

-(void)picturesFromAlbum:(NSMutableDictionary *)album{
    NSString* photosGraphPath = [NSString stringWithFormat:@"%@/photos", [album objectForKey:@"id"]];
    [FBRequestConnection startWithGraphPath:photosGraphPath
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if(error){                                  
                                  [self parsingAlbum:album failedWithError:error];
                              }else{
                                  NSArray* photos = [(NSArray*)[result data] copy];
                                  [self parsePhotos:photos fromConnection:connection intoAlbum:album];
                              }
    }];
}

-(UIImage *)getPictureForAlbum:(NSDictionary *)album{
    NSString * photoGraphPath=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [album objectForKey:@"cover_photo"]];
    NSData * data=[NSData dataWithContentsOfURL:[NSURL URLWithString:photoGraphPath]];
    return [UIImage imageWithData:data];
}

-(void)parsingAlbum:(NSDictionary *)album failedWithError:(NSError *)error{
    BFLog(@"error %@", error);
     [self.delegate parser:self failedToLoadAlbum:album withError:error];
}

-(void)parsePhotos:(NSArray *)photos fromConnection:(FBRequestConnection *)connection intoAlbum:(NSMutableDictionary *)album{
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
                [self didFinishLoadingImage:image];
            }else{
                BFLog(@"error %@", error);
            }
            
        }];
    }
}

-(void)didFinishLoadingImage:(FBImage *)image{
    [self.delegate  parser:self didFinishDownloadingImage:image];
}


@end
