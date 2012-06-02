//
//  LDBAppDelegate.h
//  QCDemo
//
//  Created by liudongbao on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface LDBAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet QCView *qcView;

- (IBAction)loadComposition:(id)sender;



@end
