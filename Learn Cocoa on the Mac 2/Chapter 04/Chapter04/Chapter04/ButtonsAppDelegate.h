//
//  ButtonsAppDelegate.h
//  Chapter04
//
//  Created by Peter Clark on 5/31/12.
//  Copyright (c) 2012 Learn Cocoa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ButtonsAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label;

- (IBAction)buttonPressed:(id)sender;
@end
