//
//  GKPongAppDelegate.h
//  GKPong
//
//  Created by Peter Bakhyryev on 6/12/09.
//  Copyright ByteClub LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKPongViewController;

@interface GKPongAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GKPongViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GKPongViewController *viewController;

@end

