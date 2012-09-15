//
//  IBTParser.m
//  webServicesText
//
//  Created by Dario Lencina on 2/1/11.
//  Copyright 2011 Ironbit. All rights reserved.
//

#import "FlickrImageParser.h"
#import "SharedConstants.h"

@implementation FlickrImageParser

@synthesize delegate, searchCriteria, error;

- (id)initWithData:(NSData *)data  criteria:(NSString *) criteria delegate:(id <FlickrImageParserDelegate>)theDelegate{
	self= [super init];
	if(self){
		self.dataToParse= [[NSData alloc] initWithData:data];
		delegate= theDelegate;
        [self setSearchCriteria:criteria];
	}
	return self;
}

- (NSArray *)parseArray{
NSString * responseString = [[NSString alloc] initWithData:self.dataToParse encoding:NSUTF8StringEncoding];
	NSArray * URLArray=nil;
	NSArray * queryResult= [self resultsFromString:responseString];
	if(queryResult){
		NSMutableArray * mutableImagesArray= [NSMutableArray array];
		for(NSDictionary * photoDict in queryResult){
			NSString * photoURLString = [NSString stringWithFormat:littleImagesURLFormat, 
										 [photoDict objectForKey:@"farm"], [photoDict objectForKey:@"server"], 
										 [photoDict objectForKey:@"id"], [photoDict objectForKey:@"secret"]];
			NSData * data= [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]];
//			UIImage * _image= [UIImage imageWithData:data];
            UIImage * image= [UIImage imageWithData:data scale:0.1];
			if(image){
				[mutableImagesArray addObject:image];
                if(delegate){
                    self.images= [NSArray arrayWithArray:mutableImagesArray];
                    [self.delegate performSelectorOnMainThread:@selector(parserDidDownloadImage:)withObject:self waitUntilDone:YES];
                }
            }
		}
		if([mutableImagesArray count]>0){
			URLArray= [NSArray arrayWithArray:mutableImagesArray]; //Inmutable copy to prevent nasty stuff when using NSOperations
		}
	}
	
	if(responseString)
		responseString=nil;
	return URLArray;
}


- (void)main{
	[self setImages:[self parseArray]];
	if (![self isCancelled])
    {
		if(self.images!=nil && ![self.images isMemberOfClass:[NSNull class]])
			[self.delegate performSelectorOnMainThread:@selector(didFinishParsing:) withObject:self waitUntilDone:FALSE];
		else {
			self.error= [NSError errorWithDomain:[NSString stringWithFormat:@"No matches for criteria"]  code:401 userInfo:nil];
			[self.delegate performSelectorOnMainThread:@selector(parseErrorOccurred:)withObject:self waitUntilDone:FALSE];
		}

    }
}

-(NSArray *)resultsFromString:(NSString *)string{
	NSError *_error;
	SBJSON *json = [SBJSON new];
	
	NSDictionary *parsedJSON = [json objectWithString:string error:&_error];
	if(parsedJSON==nil){
		self.error= [NSError errorWithDomain:NSLocalizedString(@"JSON mal formado",@"JSON mal formado") code:401 userInfo:nil];
		[self.delegate performSelectorOnMainThread:@selector(parseErrorOccurred:)withObject:self waitUntilDone:FALSE];
		return nil;
	}
	NSDictionary *ResultSet = [parsedJSON objectForKey:@"photos"];
	if(ResultSet==nil){
		self.error= [NSError errorWithDomain:NSLocalizedString(@"JSON mal formado ResultSet=nil",@"JSON mal formado") code:401 userInfo:nil];
		[self.delegate performSelectorOnMainThread:@selector(parseErrorOccurred:)withObject:self waitUntilDone:FALSE];
		return nil;
	}
	NSLog(@"totalResultsReturned: %@", [ResultSet objectForKey:@"total"]);
	NSArray* Result = [ResultSet objectForKey:@"photo"];
	NSLog(@"did download resource %@", Result);
	return Result;
}


@end
