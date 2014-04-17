//
//  Plugin.m
//  CustomPlugin
//
//  Created by maizhelun on 13-8-4.
//  Copyright (c) 2013年 maizhelun. All rights reserved.
//

#import "Plugin.h"

@interface Plugin()
@property (nonatomic, strong) NSTextView *textView;
@end

@implementation Plugin

+ (void) pluginDidLoad: (NSBundle*) plugin {
    NSLog(@"----     This is our first Xcode plugin!");

	static id sharedPlugin = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedPlugin = [[self alloc] init];
	});
}

- (id)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
	}
	return self;
}

- (void) applicationDidFinishLaunching:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionDidChange:)
                                                 name:NSTextViewDidChangeSelectionNotification
                                               object:nil];
    
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    NSMenuItem *item = [[editMenuItem submenu] itemWithTitle:@"Duplicate"];
    [item setKeyEquivalent:@""];

    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        {
            NSMenuItem* newMenuItem = [[NSMenuItem alloc] initWithTitle:@"删除一行"
                                                                 action:@selector(removeLine:)
                                                          keyEquivalent:@""];
            [newMenuItem setTarget:self];
            [newMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
            [[editMenuItem submenu] addItem:newMenuItem];
            
            [newMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
            [newMenuItem setKeyEquivalent:@"d"];
        }
    }
}

- (void) selectionDidChange: (NSNotification*) notification {
    if ([[notification object] isKindOfClass:[NSTextView class]]) {
        self.textView = (NSTextView *)[notification object];
    }
}

- (void)removeLine:(id)origin {
    
    NSArray* selectedRanges = [self.textView selectedRanges];
    if (selectedRanges.count == 0) {
        return;
    }

    NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
    NSString *originalText = self.textView.textStorage.string;

    NSInteger start = selectedRange.location;
    NSInteger end = selectedRange.location + selectedRange.length;
    for (NSInteger i = end; i < originalText.length; i ++) {
        char ch = [originalText characterAtIndex:i];
        if (ch == '\n') {
            end = i;
            break;
        }
    }
    if (end == start) {
        start -= 1;
    }
    for (NSInteger i = start; i > 0; i --) {
        char ch = [originalText characterAtIndex:i];
        if (ch == '\n') {
            start = i;
            break;
        }
    }

    NSRange replaceRange = NSMakeRange(start, end - start);
    if ([self.textView shouldChangeTextInRange:replaceRange replacementString:@""]) {
        [self.textView.textStorage beginEditing];
        [self.textView.textStorage replaceCharactersInRange:NSMakeRange(start, end - start)
                                                 withString:@""];
        [self.textView.textStorage endEditing];
    }
}

@end
