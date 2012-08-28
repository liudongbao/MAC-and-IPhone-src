//
//  AppDelegate.h
//  Raiders
//
//  Created by James Sugrue on 14/08/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> 

@property (strong, nonatomic) UIWindow *window;
@property (assign) BOOL useGameKit;

- (BOOL)isGameCenterAvailable;

@end
