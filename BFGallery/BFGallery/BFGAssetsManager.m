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

#import "BFGAssetsManager.h"
#import "FlickrImage.h"
#import "FBImage.h"
#import "BFLog.h"
#import "FBUserPictures.h"

static BFGAssetsManager * _hiddenInstance= nil;

@implementation BFGAssetsManager

-(id)init{
    self=[super init];
    if(self){
        self.pics= [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldRefreshImagesFromUserLibrary:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

+(BFGAssetsManager *)sharedInstance{
    if(_hiddenInstance==nil){
        _hiddenInstance= [BFGAssetsManager new];
    }
    return _hiddenInstance;
}

-(void)readImagesFromProvider:(BFGAssetsManagerProvider)provider{
    if(provider==BFGAssetsManagerProviderPhotoLibrary){
        [self readUserImagesFromLibrary];
    }else if(provider==BFGAssetsManagerProviderFlickr){
        if(flickr){
            flickr.delegate=nil;
        }
        self.pics= [NSMutableArray array];
        flickr=[FlickrRequest new];
        [flickr performFlickrRequestWithCriteria:self.searchCriteria delegate:self];
    }else if (provider==BFGAssetsManagerProviderFacebook){
        if ([FBSession activeSession].isOpen) {
            [self loadFBImages];
            
        } else {
            [FBSession openActiveSessionWithReadPermissions:[self fbPermissions] allowLoginUI:TRUE completionHandler:^(FBSession * session,FBSessionState state, NSError *error) {
                if(!error){
                    [self loadFBImages];
                }else{
                    BFLog(@"error %@", error);
                }
            }];
        }
        
    }
    _provider=provider;
}

-(NSArray *)fbPermissions{
    return @[@"user_photos", @"user_photo_video_tags", @"friends_photos"];
}

-(void)loadFBImages{
    FBUserPicturesParser * parser= [FBUserPicturesParser new];
    [parser setDelegate:self];
    [parser start];
}

#pragma mark -
#pragma FBUserPicturesParser

-(void)parser:(FBUserPicturesParser *)fbParser didFinishDownloadingAlbum:(NSDictionary *)album{
    BFLog(@"parser did finish %@", album);
    if(!self.pics){
        self.pics= [NSMutableArray array];
    }
    [self.pics addObjectsFromArray:[album objectForKey:@"photos"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddedAssetsToLibrary object:self.pics];
}

-(void)parser:(FBUserPicturesParser *)fbParser failedToLoadAlbum:(NSDictionary *)album withError:(NSError *)error{
    if(!self.pics){
        self.pics= [NSMutableArray array];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddedAssetsToLibrary object:self.pics];
}

-(void)getMoreImages{
    if(_provider==BFGAssetsManagerProviderPhotoLibrary){
        
    }else if(_provider==BFGAssetsManagerProviderFlickr){
        [flickr getNextPageIfNeeded];
    }
}

-(void)shouldRefreshImagesFromUserLibrary:(NSNotification *)notif{
    [self readUserImagesFromLibrary];
}

-(void)readUserImagesFromLibrary{
    
    ALAssetsLibrary *al = [BFGAssetsManager defaultAssetsLibrary];
    self.pics= nil;
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if(!self.pics){
             self.pics= [[NSMutableArray alloc] init];
         }
         [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset!=nil) {
                  [self.pics addObject:asset];
              }
          }];
         if(group==nil){
             [[NSNotificationCenter defaultCenter] postNotificationName:kAddedAssetsToLibrary object:self.pics];
         }
     }
                    failureBlock:^(NSError *error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kUserDeniedAccessToPics object:self];
                    }
     ];
}

#pragma mark -
#pragma Flickr

- (void)parserDidDownloadImage:(FlickrImageParser *)parser{
    
}

- (void)didFinishParsing:(FlickrImageParser *)parser{
    //    [self.pics addObject:parser.images];
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    for (FlickrImage * img in parser.images){
        NSURLRequest * request= [NSURLRequest requestWithURL:img.thumbnailServerPath];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * resp, NSData * data, NSError * error){
            if(!error){
                img.thumbnail=[UIImage imageWithData:data];
                [self.pics addObject:img];
                [[NSNotificationCenter defaultCenter] postNotificationName:kAddedAssetsToLibrary object:self.pics];
            }
        }];
    }
}

- (void)parseErrorOccurred:(FlickrImageParser *)parser{
    UIAlertView * alert= [[UIAlertView alloc] initWithTitle:@"FLickr" message:parser.error.description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}

#pragma mark -
#pragma mark CameraRollSharing
#define kShouldShareToCameraRoll @"kShouldShareToCameraRoll"

-(BOOL)cameraRollAuthorizationStatus{
    return [ALAssetsLibrary authorizationStatus];
}

-(BOOL)shouldSharePicsToCameraRoll{
    NSUserDefaults * defaults= [NSUserDefaults standardUserDefaults];
    BOOL shouldShare=NO;
    id cam= [defaults objectForKey:kShouldShareToCameraRoll];
    if(cam){
        shouldShare= [defaults boolForKey:kShouldShareToCameraRoll];
    }else{
        shouldShare=NO;
    }
    shouldShare= [self cameraRollAuthorizationStatus]?shouldShare:NO;
    return shouldShare;
}

-(void)setShouldSharePicsToCameraRoll:(BOOL)shouldShare handler:(BFGAssetsManagerShareHandler)handler{
    NSUserDefaults * defaults= [NSUserDefaults standardUserDefaults];
    NSError * error=nil;
    if(!shouldShare){
        [defaults setBool:shouldShare forKey:kShouldShareToCameraRoll];
        [defaults synchronize];
        handler(shouldShare, error);
    }else{
        if([self cameraRollAuthorizationStatus]== ALAuthorizationStatusAuthorized){
            [defaults setBool:shouldShare forKey:kShouldShareToCameraRoll];
            [defaults synchronize];
            handler(shouldShare, error);
        }else if([self cameraRollAuthorizationStatus]==ALAuthorizationStatusDenied){
            NSError * error= [NSError errorWithDomain:@"User denied access to the pics." code:404 userInfo:nil];
            shouldShare=NO;
            [defaults setBool:shouldShare forKey:kShouldShareToCameraRoll];
            [defaults synchronize];
            handler(shouldShare, error);
        }else{
            ALAssetsLibrary *al = [BFGAssetsManager defaultAssetsLibrary];
            [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary
                              usingBlock:^(ALAssetsGroup *group, BOOL *stop)
             {
                 [defaults setBool:shouldShare forKey:kShouldShareToCameraRoll];
                 [defaults synchronize];
                 handler(shouldShare, error);
             }
             failureBlock:^(NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserDeniedAccessToPics object:self];
                 [defaults setBool:shouldShare forKey:kShouldShareToCameraRoll];
                 [defaults synchronize];
                 handler(shouldShare, error);
             }];
        }
    }
}

-(void)savePicToCameraRoll:(UIImage *)image completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)block{
    NSDictionary * dict= @{@"app" : @"LeRandomMe"};
    [[BFGAssetsManager defaultAssetsLibrary] writeImageDataToSavedPhotosAlbum: UIImagePNGRepresentation(image)  metadata:dict completionBlock:block];
}

#pragma mark -
#pragma Facebook

-(BOOL)handleOpenURL:(NSURL *)url{
    return [[FBSession activeSession] handleOpenURL:url];
}
@end
