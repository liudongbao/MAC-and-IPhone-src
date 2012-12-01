//
//  OpenGLES15AppDelegate.h
//  OpenGLES15
//
//  Created by Simon Maurice on 18/06/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface OpenGLES15AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

