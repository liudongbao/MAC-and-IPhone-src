//
//  OpenGLES16AppDelegate.h
//  OpenGLES16
//
//  Created by Simon Maurice on 22/06/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface OpenGLES16AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

