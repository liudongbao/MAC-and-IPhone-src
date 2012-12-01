//
//  Tutorial17AppDelegate.h
//  Tutorial17
//
//  Created by Simon Maurice on 25/07/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface Tutorial17AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

