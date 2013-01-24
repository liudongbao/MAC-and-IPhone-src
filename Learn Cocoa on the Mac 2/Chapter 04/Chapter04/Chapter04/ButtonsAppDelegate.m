//
//  ButtonsAppDelegate.m
//  Chapter04
//
//  Created by Peter Clark on 5/31/12.
//  Copyright (c) 2012 Learn Cocoa. All rights reserved.
//

#import "ButtonsAppDelegate.h"

@implementation ButtonsAppDelegate
@synthesize label;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)buttonPressed:(id)sender {
    NSString *title = [sender title];
    NSString *labelText = [NSString stringWithFormat:@"%@ button pressed.", title];
    [label setStringValue:labelText];
}
@end
