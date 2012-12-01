//
//  AVRecorderAppDelegate.h
//  AVRecorder
//
//  Created by Eric Wing on 8/19/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVRecorderViewController;

@interface AVRecorderAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow* mainWindow;
	AVRecorderViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow* mainWindow;
@property (nonatomic, retain) IBOutlet AVRecorderViewController* viewController;

@end
