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
#import "BFMenuGalleryCell.h"
#import <QuartzCore/QuartzCore.h>
#define kTransitionDuration 0.5


@implementation BFMenuDetailViewController{
    UIImage * initialImage;
    BOOL isFirstImage;
}
@synthesize galleryTableView, delegate, initialRowToShow, lastSelectedRow;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(!initialRowToShow)
        [initialRowToShow release];
    
    if(!lastSelectedRow)
        [lastSelectedRow release];
    
    [initialImage release];
    [galleryTableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - dismissCallback

-(void)dismissDetailView:(UITapGestureRecognizer *)tapRecognizer
{
    if(delegate){
        [delegate didKilledDetailViewController:self];
    }
    [self removeCleanAndCutTicket:FALSE ];
}

-(void)showFromCoordinatesInView:(UIView *)baseView
{
   self.lastSelectedRow= self.initialRowToShow;
    [self.parentViewController.view addSubview:self.view];
    
    CGSize originalSize= baseView.frame.size;
    CGSize tableViewSize= self.galleryTableView.frame.size;
    CGFloat scale= originalSize.width/tableViewSize.width;
    NSLog(@"Log %@", NSStringFromCGRect(self.galleryTableView.frame));
    //self.galleryTableView.center= CGPointMake(convertedRect.origin.x+ convertedRect.size.width/2 , convertedRect.origin.y + convertedRect.size.height/2);
    CGFloat angle= [self angleForCurrentOrientation];
    [self.galleryTableView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
	self.galleryTableView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle) , scale ,scale);
    self.galleryTableView.alpha=0.01;
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:kTransitionDuration/2];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    initialImage= [UIImage imageWithCGImage:[[[delegate menuDetailViewController:self assetAtIndex:self.initialRowToShow.row] defaultRepresentation] fullScreenImage]];
    [initialImage retain];
	self.galleryTableView.transform = CGAffineTransformScale([self transformForOrientation], 1.0, 1.0);
    self.galleryTableView.alpha=1;
    self.galleryTableView.center= CGPointMake(baseView.frame.size.width/2, baseView.frame.size.height/2);
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8]];
//	[UIView commitAnimations];
}

- (void)bounce1AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];    
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	self.galleryTableView.transform = CGAffineTransformScale([self transformForOrientation], 0.95, 0.95);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];    
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce3AnimationStopped)];
	self.galleryTableView.transform = CGAffineTransformScale([self transformForOrientation], 1, 1);
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

- (CGAffineTransform)transformForOrientation
{
    return CGAffineTransformMakeRotation([self angleForCurrentOrientation]);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstImage=TRUE;
    UITapGestureRecognizer * gestureRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDetailView:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self.galleryTableView setBackgroundColor:[UIColor clearColor]];
    [self layoutElements];
    NSLog(@"Log %@", NSStringFromCGRect(self.galleryTableView.frame));
}

-(void)layoutElements
{
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)){
        [[self galleryTableView] setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    }else{
        [[self galleryTableView] setFrame:CGRectMake(0,0,self.view.frame.size.height,self.view.frame.size.width)];
    }
}

-(void)viewWillAppear
{
    [galleryTableView scrollToRowAtIndexPath:initialRowToShow atScrollPosition:UITableViewScrollPositionMiddle animated:FALSE];
}

- (void)viewDidUnload
{
    [self setGalleryTableView:nil];
    [super viewDidUnload];
}

-(void)orientationChanged:(NSNotification *)notif
{
//    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
//    if(UIInterfaceOrientationIsLandscape(orientation)){
//        [[self galleryTableView] setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
//    }else{
//        [[self galleryTableView] setFrame:CGRectMake(0,0,self.view.frame.size.height,self.view.frame.size.width)];
//    }
//    self.galleryTableView.transform = CGAffineTransformScale([self transformForOrientation], 1, 1);
//    [[self galleryTableView] reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSInteger numberOfRows= [delegate numberOfViewsInMenuDetailViewController:self];
    return numberOfRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat height=0;
    if(UIInterfaceOrientationIsLandscape(orientation)){
        height=self.view.frame.size.height;
    }else{
        height=self.view.frame.size.width;
    }
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId= @"CellID";
    BFMenuGalleryCell * cell= (BFMenuGalleryCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell==nil){
        NSString * fileName= @"BFMenuGalleryCell_ipad";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            fileName= @"BFMenuGalleryCell_iphone";
        }
        
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])){
            fileName= [NSString stringWithFormat:@"%@_landscape", fileName];
        }else{
            fileName= [NSString stringWithFormat:@"%@_portrait", fileName];
        }
        cell= [[[NSBundle mainBundle] loadNibNamed:fileName owner:nil options:nil] objectAtIndex:0];
        [cell setSelectedBackgroundView:[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease]];
    }
    self.lastSelectedRow=indexPath;
    [cell.contentView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    if(delegate){
        ALAsset * asset=[delegate menuDetailViewController:self assetAtIndex:indexPath.row];
        UIImage * image=[delegate menuDetailViewController:self imageAtIndex:indexPath.row];
        if(isFirstImage==TRUE && indexPath.row!=initialRowToShow.row){
            isFirstImage=FALSE;
            [cell.dishImageView setImage:initialImage];
            return cell;
        }
            if(asset)
                [cell fillWithAsset:asset];
            else if(image){
                [cell fillWithImage:image];
            }
    }
        
            
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
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
	[self release];
}

-(void)showView
{
	[self showLoginForm];	
}

-(void)showLoginForm
{
	UIWindow * keyWindow= [[UIApplication sharedApplication] keyWindow];
	self.view.center=keyWindow.center;
	[keyWindow addSubview:self.view];
	self.view.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	self.view.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
	[UIView commitAnimations];		
}



@end
