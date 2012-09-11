/*Copyright (C) <2012> <Dario Alessandro Lencina Talarico>
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


#import "BFMenuDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#define kTransitionDuration 0.5


@implementation BFMenuDetailViewController{
    UIImage * initialImage;
    BOOL isFirstImage;
}
@synthesize imageView;
@synthesize galleryTableView, delegate, initialRowToShow;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self= [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mustDismissGalleryDetails:) name:@"MustDismissGalleryDetails" object:nil];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - dismissCallback

-(void)mustDismissGalleryDetails:(NSNotification *)notification{
    [self dismissDetailView:nil];
}

-(void)dismissDetailView:(UITapGestureRecognizer *)tapRecognizer
{
    if(delegate){
        [delegate didKilledDetailViewController:self];
    }
    [self removeCleanAndCutTicket:FALSE ];
}

-(void)showFromCoordinatesInView:(UIView *)baseView
{
    id asset= [delegate menuDetailViewController:self assetAtIndex:self.initialRowToShow.row];
    
    if([asset isMemberOfClass:[UIImage class]]){
        initialImage= asset;
    }else{
        initialImage= [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }
    [self.imageView setImage:initialImage];
    CGSize originalSize= baseView.frame.size;
    CGSize tableViewSize= self.imageView.frame.size;
    CGFloat scale= originalSize.width/tableViewSize.width;
    self.imageView.center= CGPointMake(baseView.frame.origin.x+ baseView.frame.size.width/2 , baseView.frame.origin.y + baseView.frame.size.height/2);
    [self.imageView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
	self.imageView.transform = CGAffineTransformMakeScale( scale, scale);
    self.imageView.alpha=0.01;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];

	self.imageView.transform = CGAffineTransformMakeScale( 1.0, 1.0);
    self.imageView.alpha=1;
    self.imageView.center= CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
	[UIView commitAnimations];
}

- (void)bounce1AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];    
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	self.imageView.transform = CGAffineTransformMakeScale( 0.95, 0.95);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];    
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce3AnimationStopped)];
	self.imageView.transform = CGAffineTransformMakeScale( 1.0, 1.0);
	[UIView commitAnimations];
}

- (CGFloat)angleForCurrentOrientation
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return M_PI;
    } else 	if (orientation == UIInterfaceOrientationLandscapeRight) {
        return 0;
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return M_PI_2;
	}
    return -M_PI_2;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstImage=TRUE;
    UITapGestureRecognizer * gestureRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDetailView:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8]];    
}

- (void)viewDidUnload
{
    [self setGalleryTableView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark Actions

-(void)removeCleanAndCutTicket:(BOOL)cutTicket
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAndClean2)];
	[UIView commitAnimations];
}

-(void)removeAndClean
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAndClean2)];
	[UIView commitAnimations];
}

-(void)removeAndClean2
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
	self.view.alpha = 0;
	[UIView commitAnimations];
}

- (void)postDismissCleanup
{
	//self.view.alpha = 100;
	[self.view removeFromSuperview];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}



@end
