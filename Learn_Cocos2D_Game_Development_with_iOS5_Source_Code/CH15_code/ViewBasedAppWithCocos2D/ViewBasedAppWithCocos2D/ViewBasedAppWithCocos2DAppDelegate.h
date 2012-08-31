//
//  ViewBasedAppWithCocos2DAppDelegate.h
//  ViewBasedAppWithCocos2D
//
//  Created by Steffen Itterheim on 11.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewBasedAppWithCocos2DViewController;

@interface ViewBasedAppWithCocos2DAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet ViewBasedAppWithCocos2DViewController *viewController;

@end
