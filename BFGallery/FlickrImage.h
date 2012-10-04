//
//  FlickrImage.h
//  LeRandomMe
//
//  Created by Dario Lencina on 10/3/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrImage : NSObject

-(void)loadFullSizeImageWithQueue:(NSOperationQueue *)queue setResultInImageView:(UIImageView *)imageView;

@property(nonatomic, strong) UIImage * thumbnail;
@property(nonatomic, strong) UIImage * fullSizeImage;
@property(nonatomic, strong) NSURL * thumbnailServerPath;
@property(nonatomic, strong) NSURL * fullSizeImageServerPath;
@property(nonatomic, strong) NSString * searchCriteria;
@property(nonatomic, strong) NSString * title;

@end
