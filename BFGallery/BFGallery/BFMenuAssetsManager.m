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

#import "BFMenuAssetsManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

static BFMenuAssetsManager * _hiddenInstance= nil;

@implementation BFMenuAssetsManager

-(id)init{
    self= [super init];
    if(self!=nil){
        
        //This stupid duplicated step is to avoid a warning message.
    }
    return self;
}

+(BFMenuAssetsManager *)sharedInstance{
    if(_hiddenInstance==nil){
        _hiddenInstance= [BFMenuAssetsManager new];
    }
    return _hiddenInstance;
}

-(void)readUserImagesFromLibrary{
    
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if(!pics){
             pics= [[NSMutableArray alloc] init];
         }
         [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset!=nil) {
                  [pics addObject:asset];
              }
          }];
         if(group==nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddedAssetsToLibrary object:pics];
             [pics autorelease];
         }
     }
            failureBlock:^(NSError *error) { NSLog(@"error %@", error.description);}
     ];
}
@end
