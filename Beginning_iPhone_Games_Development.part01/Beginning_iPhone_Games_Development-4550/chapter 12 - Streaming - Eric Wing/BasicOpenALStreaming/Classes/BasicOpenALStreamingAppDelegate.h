//
//  BasicOpenALStreamingAppDelegate.h
//  BasicOpenALStreaming
//
//  Created by Eric Wing on 8/1/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BasicOpenALStreamingViewController;

@interface BasicOpenALStreamingAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow* mainWindow;
	BasicOpenALStreamingViewController* viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow* mainWindow;
@property (nonatomic, retain) IBOutlet BasicOpenALStreamingViewController* viewController;

@end

