//
//  OpenGLES11AppDelegate.h
//  OpenGLES11
//
//  Created by Simon Maurice on 25/04/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface OpenGLES11AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

