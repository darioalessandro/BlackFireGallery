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

#import "BFMenuViewController.h"
#import "BFMenuAssetsManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BFHorizontalTableViewController.h"

@implementation BFMenuViewController
@synthesize loadingPicsIndicator;
@synthesize tableView, lastSelectedRow;
@synthesize productsArray, isShowingGallery;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if(!productsArray){
            isShowingGallery=FALSE;
            [[[self navigationController] navigationItem] setHidesBackButton:TRUE];
        }
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [loadingPicsIndicator startAnimating];
    [[BFMenuAssetsManager sharedInstance] readUserImagesFromLibrary];
}

-(void)showLastPic:(id)caller{
    if(![[self productsArray] count]>0)
        return;
    
    NSIndexPath * indexPath= [NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0];
    [[self tableView] scrollToRowAtIndexPath:indexPath  atScrollPosition:UITableViewScrollPositionTop animated:NO];    
//    [self showGalleryDetailWithIndex:[[self productsArray] count]-1 fromView:self.view];
}

- (void)dealloc
{
    if(lastSelectedRow){
        [lastSelectedRow release];
    }
    [productsArray release];
    [tableView release];
    [loadingPicsIndicator release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddedAssets:) name:kAddedAssetsToLibrary object:nil];
    [[[self navigationController] navigationItem] setHidesBackButton:TRUE];
    [[[self navigationController] navigationBar] setHidden:TRUE];
    [[self tableView] setHidden:TRUE];
}

-(void)didAddedAssets:(NSNotification *)notif{
    id array= [notif object];
    self.productsArray=array;
    [self.tableView reloadData];

    [[self tableView] setHidden:NO];
    [self performSelector:@selector(showLastPic:) withObject:nil afterDelay:0.0];
    [self.loadingPicsIndicator stopAnimating];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setLoadingPicsIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	return TRUE;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfImages= [[[self getCell] imageViews] count];
    float modulo= [self.productsArray count]%numberOfImages;
    float numberOfCells= [self.productsArray count]/numberOfImages;
    NSInteger rounded= (NSInteger)numberOfCells;
    NSInteger corrected= (modulo!=0)?rounded+1:rounded;
    return corrected;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {        
        return 79;
    }
    return 146;
}

-(BFMenuCell *)getCell{
    NSString * fileName= @"BFMenuCell";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        fileName= [NSString stringWithFormat:@"%@_iphone", fileName];
    }else{
        fileName= [NSString stringWithFormat:@"%@_ipad", fileName];
    }
    
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])){
        fileName= [NSString stringWithFormat:@"%@_landscape", fileName];
    }
    
    BFMenuCell * cell= (BFMenuCell *)[self.tableView dequeueReusableCellWithIdentifier:fileName];
    if(cell==nil){
        cell= [[[NSBundle mainBundle] loadNibNamed:fileName owner:nil options:nil] objectAtIndex:0];
        
        [cell setSelectedBackgroundView:[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease]];
    }
    return cell;
}
                                                                                        
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BFMenuCell * cell= [self getCell];
    int numberOfImageViewsInCell= [[cell imageViews] count];
    int index0= indexPath.row * numberOfImageViewsInCell;

    NSInteger count= self.productsArray.count;
    
    for(int j=0;j<numberOfImageViewsInCell;j++){
        if(count>index0+j){
            ALAsset * image= [self.productsArray objectAtIndex:index0+j];
            UITapGestureRecognizer * tap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectedImage:)];            
            [[[cell imageViews] objectAtIndex:j] addGestureRecognizer:tap];            
            [tap release];
            
            [[[cell imageViews] objectAtIndex:j] setImage:[UIImage imageWithCGImage:[image thumbnail]]];            
            [[[cell imageViews] objectAtIndex:j] setTag:index0+j];
            
            UIPinchGestureRecognizer * pinch= [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchSelectedImage:)];            
            [[[cell imageViews] objectAtIndex:j] addGestureRecognizer:pinch];            
            [pinch release];
        }else{
            [[[cell imageViews] objectAtIndex:j] setHidden:TRUE];
        }

    }
    return cell;
}

-(void)pinchSelectedImage:(UIPinchGestureRecognizer *)pinch{
    UIView * PinchedView= [pinch view];
    if([pinch state]==UIGestureRecognizerStateBegan){
        [[PinchedView superview] bringSubviewToFront:[pinch view]];
    }else if([pinch state]==UIGestureRecognizerStateEnded || [pinch state]==UIGestureRecognizerStateFailed){
        if([pinch scale]>1.5){
            [self showGalleryWithImageSelected:(UIImageView *)[pinch view]];
        }
        [[pinch view] setTransform:CGAffineTransformMakeScale(1, 1)];
    }else if([pinch state]== UIGestureRecognizerStateChanged){
        [PinchedView setTransform:CGAffineTransformMakeScale(pinch.scale, pinch.scale)]; 
        if([pinch scale]>1.5){
            [self showGalleryWithImageSelected:(UIImageView *)[pinch view]];
        }
    }
}

-(void)showGalleryDetailWithIndex:(NSInteger)index fromView:(UIView *)originView{
    
    NSString * fileName= nil;
    fileName= @"BFMenuDetailViewController_iphone_portrait";
    
//    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])){
//        fileName= [NSString stringWithFormat:@"%@_landscape", fileName];
//    }else{
//    fileName= [NSString stringWithFormat:@"%@_portrait", fileName];        
//    }

    BFHorizontalTableViewController * controller= [[BFHorizontalTableViewController alloc] init];
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    controller.view.frame= self.tableView.frame;
    
//    BFMenuDetailViewController * controller= [[BFMenuDetailViewController alloc] initWithNibName:fileName bundle:nil];
//    [self addChildViewController:controller];
//    self.lastSelectedRow= [NSIndexPath indexPathForRow:index inSection:0];
//    [self.view addSubview:controller.view];
//    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])){
//        controller.view.frame= self.tableView.frame;
//    }
    NSLog(@"parent frame %@", NSStringFromCGRect([[self view] frame]));
    NSLog(@"parent frame %@", NSStringFromCGRect([[controller view] frame]));
//    [controller setDelegate:self];
//    [controller setInitialRowToShow:[NSIndexPath indexPathForRow:index inSection:0]];

}

-(void)showGalleryWithImageSelected:(UIImageView *)imageView{
    if(isShowingGallery==TRUE)
        return;
    
    isShowingGallery=TRUE;
    NSInteger index= [imageView tag];
    [self showGalleryDetailWithIndex:index fromView:imageView];
}

-(void)didSelectedImage:(UITapGestureRecognizer *)tap{
    [self showGalleryWithImageSelected:(UIImageView *)[tap view]];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
}

#pragma mark - SRMenuDetailViewControllerDelegate

-(NSDictionary *)menuDetailViewController:(BFMenuDetailViewController *)menuDetailViewController assetAtIndex:(NSInteger)index{
    return [productsArray objectAtIndex:index];
}

-(NSInteger)numberOfViewsInMenuDetailViewController:(BFMenuDetailViewController *)menuDetailViewController{
    return [self.productsArray count];
}

-(void)didKilledDetailViewController:(BFMenuDetailViewController *)menu{
    isShowingGallery=FALSE;
}

-(UIImage *)menuDetailViewController:(BFMenuDetailViewController *)menuDetailViewController imageAtIndex:(NSInteger)index{
    return nil;
}

@end
