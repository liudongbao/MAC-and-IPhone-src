//
//  OpenALCaptureAppDelegate.h
//  OpenALCapture
//
//  Created by Eric Wing on 7/7/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;
@class OpenALCaptureController;

@interface OpenALCaptureAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;
//@property (nonatomic, retain) IBOutlet OpenALCaptureController* openALCaptureController;

@end

