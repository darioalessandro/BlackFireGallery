//
//  BFAppDelegate.m
//  BFGallery
//
//  Created by Dario Lencina on 5/26/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#import "BFAppDelegate.h"

#import "BFGalleryViewController.h"
#import "BFGAssetsManager.h"

@implementation BFAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[BFGalleryViewController alloc] initWithNibName:@"BFGalleryViewController" bundle:[NSBundle bundleForClass:[BFGalleryViewController class]] mediaProvider:BFGAssetsManagerProviderPhotoLibrary];
                                                            
    self.viewController.searchCriteria=@"Chicago";
    UINavigationController * controllert= [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [controllert.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [controllert setTitle:@"Facebook"];
    self.window.rootViewController = controllert;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //[FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[BFGAssetsManager sharedInstance] handleOpenURL:url];
}

@end
