//
//  AVPlaybackAppDelegate.h
//  AVPlayback
//
//  Created by Eric Wing on 7/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlaybackViewController;

@interface AVPlaybackAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow* mainWindow;
	AVPlaybackViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow* mainWindow;
@property (nonatomic, retain) IBOutlet AVPlaybackViewController* viewController;

@end

