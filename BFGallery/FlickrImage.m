//
//  FlickrImage.m
//  LeRandomMe
//
//  Created by Dario Lencina on 10/3/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import "FlickrImage.h"

@implementation FlickrImage

-(void)loadFullSizeImageWithQueue:(NSOperationQueue *)queue setResultInImageView:(UIImageView *)imageView{
    NSURLRequest * req= [NSURLRequest requestWithURL:self.fullSizeImageServerPath];
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler: ^(NSURLResponse * response, NSData * data, NSError * error){
        if(!error){
            self.fullSizeImage= [UIImage imageWithData:data];
            if(imageView){
                imageView.image=self.fullSizeImage;
            }
        }
    }];
}

@end
