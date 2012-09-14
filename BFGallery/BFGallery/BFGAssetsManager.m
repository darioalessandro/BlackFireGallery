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
#import <AssetsLibrary/AssetsLibrary.h>


static BFGAssetsManager * _hiddenInstance= nil;

@implementation BFGAssetsManager

-(id)init{
    self= [super init];
    if(self!=nil){
        
        //This stupid duplicated step is to avoid a warning message.
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
        FlickrRequest * request=[FlickrRequest new];
        [request performFlickrRequestWithCriteria:self.searchCriteria delegate:self];
        
    }
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
            failureBlock:^(NSError *error) { NSLog(@"error %@", error.description);}
     ];
}

#pragma mark -
#pragma Flickr

- (void)didFinishParsing:(FlickrImageParser *)parser{
    self.pics= (NSMutableArray *)parser.images;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddedAssetsToLibrary object:self.pics];
}

- (void)parseErrorOccurred:(FlickrImageParser *)parser{
    UIAlertView * alert= [[UIAlertView alloc] initWithTitle:@"FLickr" message:parser.error.description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}
@end
