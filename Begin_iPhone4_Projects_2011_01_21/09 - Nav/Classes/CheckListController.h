//
//  CheckListController.h
//  Nav
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"

@interface CheckListController : SecondLevelViewController {
    NSArray        *list;
    NSIndexPath    *lastIndexPath;
}
@property (nonatomic, retain) NSArray *list;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@end
