//
//  BFHorizontalTableViewController.h
//  BFGallery
//
//  Created by Dario Lencina on 7/28/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFHorizontalTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
