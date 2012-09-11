//
//  IBTParser.h
//  webServicesText
//
//  Created by Dario Lencina on 2/1/11.
//  Copyright 2011 Ironbit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"


@class FlickrImageParser;

@protocol FlickrImageParserDelegate
- (void)didFinishParsing:(FlickrImageParser *)parser;
- (void)parseErrorOccurred:(FlickrImageParser *)parser;
@end

@interface FlickrImageParser : NSOperation {
	NSData * dataToParse;
	id __unsafe_unretained delegate;
    NSString * searchCriteria;
    NSArray * images;
    NSError * error;
}

@property(nonatomic, strong)    NSError * error;
@property(nonatomic, strong)    NSArray * images;
@property(nonatomic, strong)    NSString * searchCriteria;
@property(unsafe_unretained, atomic) id delegate;

- (id)initWithData:(NSData *)data criteria:(NSString *) criteria delegate:(id <FlickrImageParserDelegate>)theDelegate;
-(NSArray *)resultsFromString:(NSString *)string;
@end




