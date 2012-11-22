//
//  Hello_TriangleAppDelegate.h
//  Hello_Triangle
//
//  Created by Dan Ginsburg on 6/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
@class EAGLView;

@interface Hello_TriangleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow * _window;
    EAGLView * _glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

