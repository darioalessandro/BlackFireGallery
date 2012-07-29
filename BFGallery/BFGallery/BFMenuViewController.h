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

#import <UIKit/UIKit.h>
#import "BFMenuDetailViewController.h"
#import "BFViewControllerSectionSelectorDelegate.h"
#import "BFViewController.h"
#import "BFMenuCell.h"

@interface BFMenuViewController : BFViewController <BFMenuDetailViewControllerDelegate>{
    NSArray * productsArray;
    BOOL isShowingGallery;
    NSIndexPath * lastSelectedRow;
}

-(UINavigationController *)navController;
@property (retain, nonatomic)  NSIndexPath * lastSelectedRow;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingPicsIndicator;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, assign) BOOL isShowingGallery;
@property(nonatomic, retain) NSArray * productsArray;
-(void)showGalleryWithImageSelected:(UIImageView *)imageView;
-(BFMenuCell *)getCell;
@end
