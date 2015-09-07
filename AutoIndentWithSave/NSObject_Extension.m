//
//  NSObject_Extension.m
//  AutoIndentWithSave
//
//  Created by Thilina Hewagama on 9/7/15.
//  Copyright (c) 2015 Thilina Hewagama. All rights reserved.
//


#import "NSObject_Extension.h"
#import "AutoIndentWithSave.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[AutoIndentWithSave alloc] initWithBundle:plugin];
        });
    }
}

@end
