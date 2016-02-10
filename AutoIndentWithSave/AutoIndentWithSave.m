//
//  AutoIndentWithSave.m
//  AutoIndentWithSave
//
//  Created by Thilina Hewagama on 9/7/15.
//  Copyright (c) 2015 Thilina Hewagama. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "AutoIndentWithSave.h"
#import "xCodeHeaders.h"
#import "AutoIndentWithSaveSettings.h"


@interface AutoIndentWithSave()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end


@implementation AutoIndentWithSave

+ (instancetype)sharedPlugin{
  return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin{
  
  if (self = [super init]) {
    [self swizzler];
      
      [self addMenuChangedNotificationObserver];
    // reference to plugin's bundle, for resource access
    self.bundle = plugin;
  }
  return self;
}


- (void)swizzler{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class IDEEditorDocumentClass = NSClassFromString(@"IDEEditorDocument");
    //    [self swizzleClass:IDEEditorDocumentClass originalSelector:@selector(saveDocument:) swizzledSelector:@selector(xxx_saveDocument:) instanceMethod:YES];
    [self swizzleClass:IDEEditorDocumentClass originalSelector:@selector(ide_saveDocument:) swizzledSelector:@selector(xxx_ide_saveDocument:) instanceMethod:YES];
  });
}

- (void)dealloc{
    
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addMenuChangedNotificationObserver
{
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuDidChangeItemNotification
                                                                            object:nil
                                                                             queue:nil
                                                                        usingBlock:^(NSNotification * _Nonnull note) {
                                                                            [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                               [self createEnableMenu];
                                                                            [self addMenuChangedNotificationObserver];
                                                                        }];
}

- (void)createEnableMenu
{
    NSString * name = @"Enable Auto Indent with save";
    NSMenuItem * editorMenuItem = [[NSApp mainMenu] itemWithTitle: @"Editor"];
    
    if (editorMenuItem && ![editorMenuItem.submenu itemWithTitle: name]) {
        
        
        NSMenuItem * enableItem = [[NSMenuItem alloc] initWithTitle: name
                                                            action: @selector(enableDisable:)
                                                     keyEquivalent: @""];
        enableItem.target = self;
        enableItem.state = [AutoIndentWithSaveSettings sharedInstance].enabledPlugin ? NSOnState : NSOffState;
        [editorMenuItem.submenu addItem: [NSMenuItem separatorItem]];
        [editorMenuItem.submenu addItem: enableItem];
        
        //[editorMenuItem.submenu insertItem:enableItem atIndex:0];
       
        
    }
}

- (void)enableDisable:(NSMenuItem*)menuItem
{
    BOOL oldValue =[AutoIndentWithSaveSettings sharedInstance].enabledPlugin;
    [AutoIndentWithSaveSettings sharedInstance].enabledPlugin = !oldValue;
    
    menuItem.state = [AutoIndentWithSaveSettings sharedInstance].enabledPlugin ? NSOnState : NSOffState;
}


#pragma - Helper Methods

+ (id)currentEditor {
  NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
  if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
    IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
    IDEEditorArea *editorArea = [workspaceController editorArea];
    IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
    return [editorContext editor];
  }
  return nil;
}

+ (IDESourceCodeDocument *)currentSourceCodeDocument {
  if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
    IDESourceCodeEditor *editor = [self currentEditor];
    return editor.sourceCodeDocument;
  }
  
  if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
    IDESourceCodeComparisonEditor *editor = [[self class] currentEditor];
    if ([[editor primaryDocument] isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
      IDESourceCodeDocument *document = (IDESourceCodeDocument *)editor.primaryDocument;
      return document;
    }
  }
  
  return nil;
}

+ (NSTextView *)currentSourceCodeTextView {
  if ([[[self class] currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
    IDESourceCodeEditor *editor = [[self class] currentEditor];
    return editor.textView;
  }
  
  if ([[[self class] currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
    IDESourceCodeComparisonEditor *editor = [[self class] currentEditor];
    return editor.keyTextView;
  }
  
  return nil;
}

- (void)swizzleClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector instanceMethod:(BOOL)instanceMethod{
  if (class) {
    Method originalMethod;
    Method swizzledMethod;
    if (instanceMethod) {
      originalMethod = class_getInstanceMethod(class, originalSelector);
      swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    } else {
      originalMethod = class_getClassMethod(class, originalSelector);
      swizzledMethod = class_getClassMethod(class, swizzledSelector);
    }
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
      class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod);
    }
  }
}



@end


@implementation NSObject (CIAFxCodePlugin)

//-(void) xxx_saveDocument:(id)arg{
//  [self xxx_saveDocument:arg];
//}

-(void) xxx_ide_saveDocument:(id) arg{
    if([self isKindOfClass:NSClassFromString(@"IDEEditorDocument")]) [self indent];
    [self xxx_ide_saveDocument:arg];
}


-(void) indent{
    if([AutoIndentWithSaveSettings sharedInstance].enabledPlugin)
    {
        IDESourceCodeDocument *document = [AutoIndentWithSave currentSourceCodeDocument];
        if(!document) return;
        
        NSTextView *currentSourceCodeTextView = [AutoIndentWithSave currentSourceCodeTextView];
        if(!currentSourceCodeTextView) return;
        
        DVTTextStorage *textStorage = [document textStorage];
        if(!textStorage) return;
        
        NSUndoManager *undoManager = [document undoManager];
        
        NSInteger textLength = [currentSourceCodeTextView string].length;
        NSRange textRange = NSMakeRange(0, textLength);
        [textStorage indentCharacterRange:textRange undoManager:undoManager];
    }
}

@end