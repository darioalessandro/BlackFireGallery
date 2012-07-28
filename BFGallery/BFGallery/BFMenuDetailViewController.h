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
#import <AssetsLibrary/AssetsLibrary.h>

@class BFMenuDetailViewController;
@protocol BFMenuDetailViewControllerDelegate <NSObject>
-(NSInteger)numberOfViewsInMenuDetailViewController:(BFMenuDetailViewController *)menuDetailViewController;
-(void)didKilledDetailViewController:(BFMenuDetailViewController *)menu;

@optional
-(ALAsset *)menuDetailViewController:(BFMenuDetailViewController *)menuDetailViewController assetAtIndex:(NSInteger)index;
-(UIImage *)menuDetailViewController:(BFMenuDetailViewController *)menuDetailViewController imageAtIndex:(NSInteger)index;

@end

@interface BFMenuDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    id <BFMenuDetailViewControllerDelegate> delegate;
    UITableView *galleryTableView;
    NSIndexPath * initialRowToShow;
    NSIndexPath * lastSelectedRow;
}
@property (nonatomic, retain) NSIndexPath * initialRowToShow;
@property (nonatomic, retain) NSIndexPath * lastSelectedRow;
@property (nonatomic, retain) IBOutlet UITableView *galleryTableView;
@property (nonatomic, assign) id <BFMenuDetailViewControllerDelegate> delegate;

-(void)showFromCoordinatesInView:(UIView *)baseView;
- (CGAffineTransform)transformForOrientation;
-(void)showLoginForm;
-(void)showView;
- (CGFloat)angleForCurrentOrientation;


@end


