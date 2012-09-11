//
//  FlickrRequest.m
//  lerandomme
//
//  Created by Dario Lencina on 5/19/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import "FlickrRequest.h"
#import "SharedConstants.h"


@implementation FlickrRequest
@synthesize receivedData, queue, searchCriteria;

-(void)performFlickrRequestWithCriteria:(NSString *)criteria delegate:(id <FlickrImageParserDelegate>)del{
    [self setSearchCriteria:criteria];
    [self setDelegate:del];
    NSLog(@"searchCriteria %@", searchCriteria);
    
	NSString * flickrURLRequest=[NSString stringWithFormat:flickrSearchMethodString, OBJECTIVE_FLICKR_API_KEY, searchCriteria];
    
        NSLog(@"flickrURLRequest %@", flickrURLRequest);
    
    NSString * encodedReq=[flickrURLRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"encodedReq %@", encodedReq);
    
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:encodedReq]
															cachePolicy:NSURLRequestReloadIgnoringCacheData
														timeoutInterval:20];
	[req setHTTPMethod:@"GET"];
	
	theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
	if (theConnection) {
		NSMutableData *data = [[NSMutableData alloc] init];
		self.receivedData = data;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

#pragma mark -
#pragma mark NSURLConnection Callbacks

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode >= 400)
        {
			[connection cancel];  // stop connecting; no more delegate messages
			NSError *statusError = [NSError errorWithDomain:@"fail"
													   code:statusCode
												   userInfo:nil];
			
			NSLog(@"Error with %d", statusCode);
			[self connection:connection didFailWithError:statusError];
        }
    }
	
	[receivedData setLength:0];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{
	//	NSLog(@"request %@", [request allHTTPHeaderFields]);
	//	NSLog(@"body %s", [[request HTTPBody] bytes]);	
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	UIAlertView * alert= [[UIAlertView alloc] initWithTitle:@"Dario:" 
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	
	self.receivedData = nil;
	//	[(UIActivityIndicatorView *)[self viewWithTag:1001] stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[connection cancel];  // stop connecting; no more delegate messages
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//	NSLog(@"datos %s", [self.receivedData bytes]);
	self.queue = [[NSOperationQueue alloc] init];
	NSData * data= self.receivedData;
    FlickrImageParser *parser = [[FlickrImageParser alloc] initWithData:data criteria:self.searchCriteria delegate:self.delegate];
    [queue addOperation:parser]; // this will start the "FlickrImageParser"
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
