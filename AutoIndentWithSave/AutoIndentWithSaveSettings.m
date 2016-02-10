//
//  AutoIndentWithSaveSettings.m
//  AutoIndentWithSave
//
//  Created by joel on 10/02/16.
//  Copyright © 2016 Thilina Hewagama. All rights reserved.
//

#import "AutoIndentWithSaveSettings.h"

NSString *const AUTOINDENT_WITH_SAVE_ENABLED_PREF_KEY =@"AutoIndentWithSaveEnabled";

@interface AutoIndentWithSaveSettings ()



@end

@implementation AutoIndentWithSaveSettings

static AutoIndentWithSaveSettings *_sharedInstance;

+ (AutoIndentWithSaveSettings*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AutoIndentWithSaveSettings alloc]init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{AUTOINDENT_WITH_SAVE_ENABLED_PREF_KEY:@YES}];
        
        _enabledPlugin = [[NSUserDefaults standardUserDefaults] boolForKey:AUTOINDENT_WITH_SAVE_ENABLED_PREF_KEY];
    }
    return self;
}

-(void)setEnabledPlugin:(BOOL)enabledPlugin
{
    [self willChangeValueForKey:@"enabledPlugin"];
    _enabledPlugin = enabledPlugin;
    [[NSUserDefaults standardUserDefaults] setBool:_enabledPlugin forKey:AUTOINDENT_WITH_SAVE_ENABLED_PREF_KEY];
    
    [self didChangeValueForKey:@"enabledPlugin"];
}
@end
