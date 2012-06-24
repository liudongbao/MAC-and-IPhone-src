//
//  DisclosureButtonController.h
//  Nav
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"
@class DisclosureDetailController;

@interface DisclosureButtonController : SecondLevelViewController {
    NSArray    *list;
    DisclosureDetailController *childController;
}
@property (nonatomic, retain) NSArray *list;

@end
