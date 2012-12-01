//
//  PhysicsAppDelegate.h
//  Physics
//
//  Created by Michael Kasprzak on 16/02/09.
//  Copyright Sykhronics Entertainment 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface PhysicsAppDelegate : NSObject <UIApplicationDelegate,UIAccelerometerDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

