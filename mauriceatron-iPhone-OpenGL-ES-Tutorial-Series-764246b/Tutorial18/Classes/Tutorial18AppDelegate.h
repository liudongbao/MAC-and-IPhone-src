//
//  Tutorial18AppDelegate.h
//  Tutorial18
//
//  Created by Simon Maurice on 2/08/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface Tutorial18AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

