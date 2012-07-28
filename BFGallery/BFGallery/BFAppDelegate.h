//
//  BFAppDelegate.h
//  BFGallery
//
//  Created by Dario Lencina on 5/26/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BFMenuViewController;

@interface BFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BFMenuViewController *viewController;

@end
