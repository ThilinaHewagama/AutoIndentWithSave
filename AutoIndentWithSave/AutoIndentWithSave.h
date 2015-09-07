//
//  AutoIndentWithSave.h
//  AutoIndentWithSave
//
//  Created by Thilina Hewagama on 9/7/15.
//  Copyright (c) 2015 Thilina Hewagama. All rights reserved.
//

#import <AppKit/AppKit.h>

@class AutoIndentWithSave;

static AutoIndentWithSave *sharedPlugin;

@interface AutoIndentWithSave : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end