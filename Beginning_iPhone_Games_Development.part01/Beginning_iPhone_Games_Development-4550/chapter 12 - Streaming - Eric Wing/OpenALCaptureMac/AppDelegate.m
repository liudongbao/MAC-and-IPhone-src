//
//  AppDelegate.m
//  OpenALCaptureMac
//
//  Created by Eric Wing on 7/8/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate
// Remember that this class must be set as the delegate to NSApplication for this
// this to have any effect. This may be set through either IB or calling
// [NSApp setDelegate:self]; in awakeFromNib
- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)the_application
{
	return YES;
}

- (void) applicationDidFinishLaunching:(NSNotification*)the_notification
{
	
}

@end
