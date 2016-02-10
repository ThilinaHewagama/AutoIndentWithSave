//
//  AutoIndentWithSaveSettings.h
//  AutoIndentWithSave
//
//  Created by joel on 10/02/16.
//  Copyright © 2016 Thilina Hewagama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoIndentWithSaveSettings : NSObject
+ (AutoIndentWithSaveSettings*)sharedInstance;
@property (nonatomic, assign) BOOL enabledPlugin;
@end
