//
//  xCodeHeaders.h
//  AutoIndentWithSave
//
//  Created by Thilina Hewagama on 9/8/15.
//  Copyright (c) 2015 Thilina Hewagama. All rights reserved.
//


@interface IDENavigatorArea : NSObject
- (id)currentNavigator;
@end

@interface IDEWorkspaceTabController : NSObject
@property (readonly) IDENavigatorArea *navigatorArea;
@end

@interface IDEEditorContext : NSObject
- (id)editor; // returns the current editor. If the editor is the code editor, the class is `IDESourceCodeEditor`
@end

@interface IDEEditorArea : NSObject
- (IDEEditorContext *)lastActiveEditorContext;
@end

@interface IDEEditorDocument : NSDocument
@end

@interface IDEWorkspaceWindowController : NSObject
@property (readonly) IDEWorkspaceTabController *activeWorkspaceTabController;
- (IDEEditorArea *)editorArea;
@end

@interface DVTSourceTextStorage : NSTextStorage
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string withUndoManager:(id)undoManager;
- (NSRange)lineRangeForCharacterRange:(NSRange)range;
- (NSRange)characterRangeForLineRange:(NSRange)range;
- (void)indentCharacterRange:(NSRange)range undoManager:(id)undoManager;
@end

@interface DVTTextStorage : NSTextStorage
- (void)indentCharacterRange:(struct _NSRange)arg1 undoManager:(id)arg2;
- (void)indentLineRange:(struct _NSRange)arg1 undoManager:(id)arg2;
@end

@interface IDESourceCodeDocument : NSDocument
- (DVTTextStorage *)textStorage;
- (NSUndoManager *)undoManager;
@end

@interface IDESourceCodeEditor : NSObject
@property (retain) NSTextView *textView;
- (IDESourceCodeDocument *)sourceCodeDocument;
@end

@interface IDESourceCodeComparisonEditor : NSObject
@property (readonly) NSTextView *keyTextView;
@property (retain) NSDocument *primaryDocument;
@end



