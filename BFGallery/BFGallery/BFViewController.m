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

#import "BFViewController.h"


@implementation BFViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)closeModalView:(id)sender{

    if(self.navigationController){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowOverlayViewController" object:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem * item= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(closeModalView:)];
    [[self navigationController] setToolbarHidden:FALSE];
    [[[self navigationController] navigationItem] setHidesBackButton:TRUE];
    [self setToolbarItems:[NSArray arrayWithObject:item]];
    [item setStyle:UIBarButtonItemStyleDone];
    [[[self navigationController] toolbar] setBarStyle:UIBarStyleBlackTranslucent];
    [[[self navigationController] toolbar] setBarStyle:UIBarStyleBlack];
    [item release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)didPressedSectionButton:(id)sender{
    if([delegate conformsToProtocol:@protocol(BFViewControllerSectionSelectorDelegate)]){
        [delegate srViewController:self didSelectedSectionAtIndex:[sender tag]];
    }
}

@end
