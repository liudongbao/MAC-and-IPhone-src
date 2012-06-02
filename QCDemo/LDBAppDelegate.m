//
//  LDBAppDelegate.m
//  QCDemo
//
//  Created by liudongbao on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LDBAppDelegate.h"

@implementation LDBAppDelegate

@synthesize window = _window;
@synthesize qcView = _qcView;


- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)loadComposition:(id)sender {
    void (^handler)(NSInteger);
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setAllowedFileTypes:[NSArray arrayWithObjects: @"qtz", nil]];
    
    handler = ^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *filePath = [[[panel URLs] objectAtIndex:0] path];
            if (![_qcView loadCompositionFromFile:filePath]) {
                NSLog(@"Could not load composition");
            }
        }
    };
    
    [panel beginSheetModalForWindow:_window completionHandler:handler];
}
@end
