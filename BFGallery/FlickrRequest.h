//
//  FlickrRequest.h
//  lerandomme
//
//  Created by Dario Lencina on 5/19/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrImageParser.h"

@interface FlickrRequest : NSObject {
	NSMutableData * receivedData;
    NSURLConnection *theConnection;
    NSOperationQueue *queue;
    id <FlickrImageParserDelegate> delegate;
    NSString * searchCriteria;
}
@property (nonatomic, strong)    NSString * searchCriteria;
@property (nonatomic, unsafe_unretained)   id delegate;
@property (nonatomic, strong)	NSMutableData * receivedData;
@property (nonatomic, strong)   NSOperationQueue *queue;
-(void)performFlickrRequestWithCriteria:(NSString *)criteria delegate:(id <FlickrImageParserDelegate>)delegate;
@end
