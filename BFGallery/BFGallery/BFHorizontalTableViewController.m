//
//  BFHorizontalTableViewController.m
//  BFGallery
//
//  Created by Dario Lencina on 7/28/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import "BFHorizontalTableViewController.h"

@interface BFHorizontalTableViewController ()

@end

@implementation BFHorizontalTableViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [tableView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
     [tableView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return TRUE;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])){
        return self.view.window.frame.size.height;
    }
    return self.view.window.frame.size.width;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    [self.view removeFromSuperview];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * string= @"sfsdf";
    UITableViewCell * cell= [tableView dequeueReusableCellWithIdentifier:string];
    if(cell==nil){
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
        [cell setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
        [cell setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    }
    [[cell textLabel] setText:@"asfsdf"];
    return cell;
}

- (void)dealloc {
    [tableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
